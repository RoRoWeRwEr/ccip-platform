-- Migration 0045: bounded PostgreSQL background-job infrastructure.
--
-- Workers and scheduling loops remain application concerns. This migration
-- provides durable definitions, schedules, executions, retry metadata, atomic
-- leasing, heartbeats, cancellation, results, failures, auditing, and RLS for
-- the first two consumers: data retention and commission settlements.

BEGIN;

CREATE TABLE public.background_job_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_code TEXT NOT NULL,
    display_name TEXT NOT NULL,
    description TEXT NOT NULL,
    consumer_type TEXT NOT NULL,
    lifecycle_status TEXT NOT NULL DEFAULT 'ACTIVE',
    maximum_attempts INTEGER NOT NULL DEFAULT 3,
    retry_backoff_strategy TEXT NOT NULL DEFAULT 'EXPONENTIAL',
    retry_base_delay_seconds INTEGER NOT NULL DEFAULT 60,
    retry_max_delay_seconds INTEGER NOT NULL DEFAULT 3600,
    retry_jitter_percent INTEGER NOT NULL DEFAULT 10,
    execution_timeout_seconds INTEGER NOT NULL DEFAULT 3600,
    lease_duration_seconds INTEGER NOT NULL DEFAULT 300,
    heartbeat_timeout_seconds INTEGER NOT NULL DEFAULT 120,
    default_priority SMALLINT NOT NULL DEFAULT 100,
    created_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_background_job_definitions_code UNIQUE (job_code),
    CONSTRAINT chk_background_job_definitions_code CHECK (
        job_code ~ '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$'
    ),
    CONSTRAINT chk_background_job_definitions_name CHECK (
        length(trim(display_name)) BETWEEN 1 AND 200
    ),
    CONSTRAINT chk_background_job_definitions_description CHECK (
        length(trim(description)) BETWEEN 1 AND 2000
    ),
    CONSTRAINT chk_background_job_definitions_consumer CHECK (
        consumer_type IN ('DATA_RETENTION_EXECUTION', 'COMMISSION_SETTLEMENT')
    ),
    CONSTRAINT chk_background_job_definitions_status CHECK (
        lifecycle_status IN ('ACTIVE', 'PAUSED', 'RETIRED')
    ),
    CONSTRAINT chk_background_job_definitions_retry CHECK (
        maximum_attempts BETWEEN 1 AND 100
        AND retry_backoff_strategy IN ('FIXED', 'LINEAR', 'EXPONENTIAL')
        AND retry_base_delay_seconds BETWEEN 1 AND 86400
        AND retry_max_delay_seconds BETWEEN retry_base_delay_seconds AND 604800
        AND retry_jitter_percent BETWEEN 0 AND 100
    ),
    CONSTRAINT chk_background_job_definitions_execution CHECK (
        execution_timeout_seconds BETWEEN 1 AND 604800
        AND lease_duration_seconds BETWEEN 5 AND execution_timeout_seconds
        AND heartbeat_timeout_seconds BETWEEN 5 AND lease_duration_seconds
    ),
    CONSTRAINT chk_background_job_definitions_priority CHECK (
        default_priority BETWEEN 1 AND 1000
    ),
    CONSTRAINT chk_background_job_definitions_metadata CHECK (
        jsonb_typeof(metadata) = 'object'
    )
);

CREATE TABLE public.background_job_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_definition_id UUID NOT NULL
        REFERENCES public.background_job_definitions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    schedule_code TEXT NOT NULL,
    display_name TEXT NOT NULL,
    schedule_type TEXT NOT NULL,
    interval_seconds INTEGER,
    scheduled_once_at TIMESTAMPTZ,
    next_run_at TIMESTAMPTZ NOT NULL,
    last_materialized_at TIMESTAMPTZ,
    is_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    priority SMALLINT,
    data_retention_execution_id UUID
        REFERENCES public.data_retention_executions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    commission_settlement_id UUID
        REFERENCES public.commission_settlements(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    payload JSONB NOT NULL DEFAULT '{}'::JSONB,
    created_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_background_job_schedules_code UNIQUE (schedule_code),
    CONSTRAINT chk_background_job_schedules_code CHECK (
        schedule_code ~ '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$'
    ),
    CONSTRAINT chk_background_job_schedules_name CHECK (
        length(trim(display_name)) BETWEEN 1 AND 200
    ),
    CONSTRAINT chk_background_job_schedules_type CHECK (
        (schedule_type = 'INTERVAL' AND interval_seconds BETWEEN 60 AND 2592000 AND scheduled_once_at IS NULL)
        OR
        (schedule_type = 'ONE_TIME' AND interval_seconds IS NULL AND scheduled_once_at IS NOT NULL
            AND next_run_at = scheduled_once_at)
    ),
    CONSTRAINT chk_background_job_schedules_priority CHECK (
        priority IS NULL OR priority BETWEEN 1 AND 1000
    ),
    CONSTRAINT chk_background_job_schedules_target CHECK (
        num_nonnulls(data_retention_execution_id, commission_settlement_id) = 1
    ),
    CONSTRAINT chk_background_job_schedules_payload CHECK (
        jsonb_typeof(payload) = 'object'
    ),
    CONSTRAINT chk_background_job_schedules_metadata CHECK (
        jsonb_typeof(metadata) = 'object'
    )
);

CREATE TABLE public.background_job_executions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_definition_id UUID NOT NULL
        REFERENCES public.background_job_definitions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    schedule_id UUID
        REFERENCES public.background_job_schedules(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    execution_reference TEXT NOT NULL,
    idempotency_key TEXT,
    execution_status TEXT NOT NULL DEFAULT 'QUEUED',
    priority SMALLINT NOT NULL,
    attempt_count INTEGER NOT NULL DEFAULT 0,
    available_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    scheduled_for TIMESTAMPTZ,
    queued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    leased_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    cancellation_requested_at TIMESTAMPTZ,
    cancellation_requested_by_user_id UUID
        REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    cancellation_reason TEXT,
    worker_id TEXT,
    lease_token UUID,
    lease_expires_at TIMESTAMPTZ,
    heartbeat_at TIMESTAMPTZ,
    data_retention_execution_id UUID
        REFERENCES public.data_retention_executions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    commission_settlement_id UUID
        REFERENCES public.commission_settlements(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    payload JSONB NOT NULL DEFAULT '{}'::JSONB,
    result JSONB,
    failure_code TEXT,
    failure_message TEXT,
    failure_details JSONB,
    retryable BOOLEAN,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_background_job_executions_reference UNIQUE (execution_reference),
    CONSTRAINT uq_background_job_executions_idempotency UNIQUE (job_definition_id, idempotency_key),
    CONSTRAINT uq_background_job_executions_schedule_occurrence UNIQUE (schedule_id, scheduled_for),
    CONSTRAINT chk_background_job_executions_reference CHECK (
        execution_reference ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
    ),
    CONSTRAINT chk_background_job_executions_idempotency CHECK (
        idempotency_key IS NULL OR length(trim(idempotency_key)) BETWEEN 1 AND 500
    ),
    CONSTRAINT chk_background_job_executions_status CHECK (
        execution_status IN (
            'QUEUED', 'LEASED', 'RUNNING', 'CANCELLATION_REQUESTED',
            'SUCCEEDED', 'FAILED', 'CANCELLED'
        )
    ),
    CONSTRAINT chk_background_job_executions_priority CHECK (
        priority BETWEEN 1 AND 1000
    ),
    CONSTRAINT chk_background_job_executions_attempt CHECK (
        attempt_count BETWEEN 0 AND 100
    ),
    CONSTRAINT chk_background_job_executions_target CHECK (
        num_nonnulls(data_retention_execution_id, commission_settlement_id) = 1
    ),
    CONSTRAINT chk_background_job_executions_schedule CHECK (
        (schedule_id IS NULL AND scheduled_for IS NULL)
        OR (schedule_id IS NOT NULL AND scheduled_for IS NOT NULL)
    ),
    CONSTRAINT chk_background_job_executions_timeline CHECK (
        (leased_at IS NULL OR leased_at >= queued_at)
        AND (started_at IS NULL OR started_at >= queued_at)
        AND (completed_at IS NULL OR completed_at >= COALESCE(started_at, leased_at, queued_at))
        AND (failed_at IS NULL OR failed_at >= COALESCE(started_at, leased_at, queued_at))
        AND (cancelled_at IS NULL OR cancelled_at >= queued_at)
        AND (cancellation_requested_at IS NULL OR cancellation_requested_at >= queued_at)
    ),
    CONSTRAINT chk_background_job_executions_lease CHECK (
        (execution_status IN ('LEASED', 'RUNNING', 'CANCELLATION_REQUESTED')
            AND worker_id IS NOT NULL AND length(trim(worker_id)) BETWEEN 1 AND 200
            AND lease_token IS NOT NULL AND leased_at IS NOT NULL
            AND lease_expires_at IS NOT NULL AND lease_expires_at > leased_at
            AND heartbeat_at IS NOT NULL AND heartbeat_at >= leased_at)
        OR
        (execution_status NOT IN ('LEASED', 'RUNNING', 'CANCELLATION_REQUESTED')
            AND worker_id IS NULL AND lease_token IS NULL AND lease_expires_at IS NULL
            AND heartbeat_at IS NULL)
    ),
    CONSTRAINT chk_background_job_executions_terminal CHECK (
        (execution_status = 'SUCCEEDED' AND completed_at IS NOT NULL
            AND failed_at IS NULL AND cancelled_at IS NULL AND result IS NOT NULL)
        OR
        (execution_status = 'FAILED' AND failed_at IS NOT NULL
            AND completed_at IS NULL AND cancelled_at IS NULL
            AND failure_code IS NOT NULL AND failure_message IS NOT NULL
            AND retryable IS NOT NULL)
        OR
        (execution_status = 'CANCELLED' AND cancelled_at IS NOT NULL
            AND completed_at IS NULL AND failed_at IS NULL
            AND cancellation_requested_at IS NOT NULL
            AND cancellation_reason IS NOT NULL)
        OR
        (execution_status NOT IN ('SUCCEEDED', 'FAILED', 'CANCELLED')
            AND completed_at IS NULL AND failed_at IS NULL AND cancelled_at IS NULL)
    ),
    CONSTRAINT chk_background_job_executions_cancellation CHECK (
        (cancellation_requested_at IS NULL
            AND cancellation_requested_by_user_id IS NULL
            AND cancellation_reason IS NULL)
        OR
        (cancellation_requested_at IS NOT NULL
            AND length(trim(cancellation_reason)) BETWEEN 1 AND 1000)
    ),
    CONSTRAINT chk_background_job_executions_failure CHECK (
        (failure_code IS NULL AND failure_message IS NULL
            AND failure_details IS NULL AND retryable IS NULL)
        OR
        (failure_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
            AND length(trim(failure_message)) BETWEEN 1 AND 4000
            AND jsonb_typeof(failure_details) = 'object'
            AND retryable IS NOT NULL)
    ),
    CONSTRAINT chk_background_job_executions_payload CHECK (
        jsonb_typeof(payload) = 'object'
    ),
    CONSTRAINT chk_background_job_executions_result CHECK (
        result IS NULL OR jsonb_typeof(result) IN ('object', 'array')
    )
);

CREATE INDEX idx_background_job_definitions_active
    ON public.background_job_definitions(job_code)
    WHERE lifecycle_status = 'ACTIVE';
CREATE INDEX idx_background_job_schedules_due
    ON public.background_job_schedules(next_run_at, id)
    WHERE is_enabled = TRUE;
CREATE INDEX idx_background_job_executions_claim
    ON public.background_job_executions(priority, available_at, queued_at, id)
    WHERE execution_status = 'QUEUED';
CREATE INDEX idx_background_job_executions_expired_lease
    ON public.background_job_executions(lease_expires_at, id)
    WHERE execution_status IN ('LEASED', 'RUNNING', 'CANCELLATION_REQUESTED');
CREATE INDEX idx_background_job_executions_stale_heartbeat
    ON public.background_job_executions(heartbeat_at, id)
    WHERE execution_status IN ('LEASED', 'RUNNING', 'CANCELLATION_REQUESTED');
CREATE INDEX idx_background_job_executions_definition_status
    ON public.background_job_executions(job_definition_id, execution_status, created_at DESC);
CREATE INDEX idx_background_job_executions_retention
    ON public.background_job_executions(data_retention_execution_id, created_at DESC)
    WHERE data_retention_execution_id IS NOT NULL;
CREATE INDEX idx_background_job_executions_settlement
    ON public.background_job_executions(commission_settlement_id, created_at DESC)
    WHERE commission_settlement_id IS NOT NULL;

CREATE OR REPLACE FUNCTION public.validate_background_job_target()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
DECLARE expected_consumer TEXT;
BEGIN
    SELECT definition.consumer_type
      INTO expected_consumer
      FROM public.background_job_definitions AS definition
     WHERE definition.id = NEW.job_definition_id;

    IF expected_consumer = 'DATA_RETENTION_EXECUTION'
       AND (NEW.data_retention_execution_id IS NULL OR NEW.commission_settlement_id IS NOT NULL) THEN
        RAISE EXCEPTION 'data-retention jobs require a data_retention_execution_id'
            USING ERRCODE = '23514';
    ELSIF expected_consumer = 'COMMISSION_SETTLEMENT'
       AND (NEW.commission_settlement_id IS NULL OR NEW.data_retention_execution_id IS NOT NULL) THEN
        RAISE EXCEPTION 'commission-settlement jobs require a commission_settlement_id'
            USING ERRCODE = '23514';
    END IF;

    IF TG_TABLE_NAME = 'background_job_executions' AND NEW.schedule_id IS NOT NULL
       AND NOT EXISTS (
           SELECT 1
             FROM public.background_job_schedules AS schedule
            WHERE schedule.id = NEW.schedule_id
              AND schedule.job_definition_id = NEW.job_definition_id
              AND schedule.data_retention_execution_id IS NOT DISTINCT FROM NEW.data_retention_execution_id
              AND schedule.commission_settlement_id IS NOT DISTINCT FROM NEW.commission_settlement_id
       ) THEN
        RAISE EXCEPTION 'execution definition and target must match its schedule'
            USING ERRCODE = '23514';
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.manage_background_job_metadata()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
    IF current_user = 'authenticated' THEN
        IF TG_OP = 'INSERT' THEN
            NEW.created_by_user_id := auth.uid();
        END IF;
        NEW.updated_by_user_id := auth.uid();
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF NEW.id IS DISTINCT FROM OLD.id
           OR NEW.created_at IS DISTINCT FROM OLD.created_at
           OR NEW.created_by_user_id IS DISTINCT FROM OLD.created_by_user_id THEN
            RAISE EXCEPTION 'background-job identity and creation audit fields may not be modified'
                USING ERRCODE = '42501';
        END IF;
        IF TG_TABLE_NAME = 'background_job_definitions'
           AND (NEW.job_code IS DISTINCT FROM OLD.job_code
                OR NEW.consumer_type IS DISTINCT FROM OLD.consumer_type) THEN
            RAISE EXCEPTION 'job code and consumer type may not be modified'
                USING ERRCODE = '42501';
        ELSIF TG_TABLE_NAME = 'background_job_schedules'
           AND (NEW.schedule_code IS DISTINCT FROM OLD.schedule_code
                OR NEW.job_definition_id IS DISTINCT FROM OLD.job_definition_id
                OR NEW.data_retention_execution_id IS DISTINCT FROM OLD.data_retention_execution_id
                OR NEW.commission_settlement_id IS DISTINCT FROM OLD.commission_settlement_id) THEN
            RAISE EXCEPTION 'schedule identity, definition, and target may not be modified'
                USING ERRCODE = '42501';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.enqueue_background_job(
    requested_job_code TEXT,
    requested_data_retention_execution_id UUID DEFAULT NULL,
    requested_commission_settlement_id UUID DEFAULT NULL,
    requested_payload JSONB DEFAULT '{}'::JSONB,
    requested_available_at TIMESTAMPTZ DEFAULT now(),
    requested_priority SMALLINT DEFAULT NULL,
    requested_idempotency_key TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE definition public.background_job_definitions%ROWTYPE;
DECLARE execution_id UUID;
BEGIN
    SELECT *
      INTO definition
      FROM public.background_job_definitions
     WHERE job_code = requested_job_code
       AND lifecycle_status = 'ACTIVE';
    IF NOT FOUND THEN
        RAISE EXCEPTION 'active background job definition not found'
            USING ERRCODE = 'P0002';
    END IF;

    INSERT INTO public.background_job_executions (
        job_definition_id, execution_reference, idempotency_key, priority,
        available_at, data_retention_execution_id, commission_settlement_id, payload
    ) VALUES (
        definition.id, 'job.' || gen_random_uuid()::TEXT, requested_idempotency_key,
        COALESCE(requested_priority, definition.default_priority),
        requested_available_at, requested_data_retention_execution_id,
        requested_commission_settlement_id, requested_payload
    )
    ON CONFLICT (job_definition_id, idempotency_key)
        WHERE idempotency_key IS NOT NULL
    DO UPDATE SET idempotency_key = EXCLUDED.idempotency_key
    RETURNING id INTO execution_id;
    RETURN execution_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.materialize_due_background_jobs(requested_limit INTEGER DEFAULT 100)
RETURNS SETOF UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE schedule_record public.background_job_schedules%ROWTYPE;
DECLARE execution_id UUID;
BEGIN
    IF requested_limit NOT BETWEEN 1 AND 1000 THEN
        RAISE EXCEPTION 'requested_limit must be between 1 and 1000'
            USING ERRCODE = '22023';
    END IF;

    FOR schedule_record IN
        SELECT schedule.*
          FROM public.background_job_schedules AS schedule
          JOIN public.background_job_definitions AS definition
            ON definition.id = schedule.job_definition_id
         WHERE schedule.is_enabled
           AND schedule.next_run_at <= statement_timestamp()
           AND definition.lifecycle_status = 'ACTIVE'
         ORDER BY schedule.next_run_at, schedule.id
         FOR UPDATE OF schedule SKIP LOCKED
         LIMIT requested_limit
    LOOP
        INSERT INTO public.background_job_executions (
            job_definition_id, schedule_id, execution_reference, execution_status,
            priority, available_at, scheduled_for, data_retention_execution_id,
            commission_settlement_id, payload
        )
        SELECT schedule_record.job_definition_id, schedule_record.id,
               'job.' || gen_random_uuid()::TEXT, 'QUEUED',
               COALESCE(schedule_record.priority, definition.default_priority),
               schedule_record.next_run_at, schedule_record.next_run_at,
               schedule_record.data_retention_execution_id,
               schedule_record.commission_settlement_id, schedule_record.payload
          FROM public.background_job_definitions AS definition
         WHERE definition.id = schedule_record.job_definition_id
        ON CONFLICT (schedule_id, scheduled_for) DO NOTHING
        RETURNING id INTO execution_id;

        UPDATE public.background_job_schedules
           SET last_materialized_at = statement_timestamp(),
               next_run_at = CASE
                   WHEN schedule_record.schedule_type = 'INTERVAL'
                       THEN schedule_record.next_run_at
                            + make_interval(secs => schedule_record.interval_seconds)
                   ELSE schedule_record.next_run_at
               END,
               is_enabled = CASE
                   WHEN schedule_record.schedule_type = 'ONE_TIME' THEN FALSE
                   ELSE is_enabled
               END
         WHERE id = schedule_record.id;

        IF execution_id IS NOT NULL THEN
            RETURN NEXT execution_id;
        END IF;
        execution_id := NULL;
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION public.lease_background_jobs(
    requested_worker_id TEXT,
    requested_limit INTEGER DEFAULT 1
)
RETURNS SETOF public.background_job_executions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
BEGIN
    IF length(trim(requested_worker_id)) NOT BETWEEN 1 AND 200 THEN
        RAISE EXCEPTION 'worker identifier must contain 1 to 200 characters'
            USING ERRCODE = '22023';
    END IF;
    IF requested_limit NOT BETWEEN 1 AND 100 THEN
        RAISE EXCEPTION 'requested_limit must be between 1 and 100'
            USING ERRCODE = '22023';
    END IF;

    RETURN QUERY
    WITH candidates AS (
        SELECT execution.id
          FROM public.background_job_executions AS execution
          JOIN public.background_job_definitions AS definition
            ON definition.id = execution.job_definition_id
         WHERE execution.execution_status = 'QUEUED'
           AND execution.available_at <= statement_timestamp()
           AND execution.attempt_count < definition.maximum_attempts
           AND definition.lifecycle_status = 'ACTIVE'
         ORDER BY execution.priority, execution.available_at, execution.queued_at, execution.id
         FOR UPDATE OF execution SKIP LOCKED
         LIMIT requested_limit
    )
    UPDATE public.background_job_executions AS execution
       SET execution_status = 'LEASED',
           attempt_count = execution.attempt_count + 1,
           worker_id = requested_worker_id,
           lease_token = gen_random_uuid(),
           leased_at = statement_timestamp(),
           heartbeat_at = statement_timestamp(),
           lease_expires_at = statement_timestamp()
               + make_interval(secs => definition.lease_duration_seconds)
      FROM candidates, public.background_job_definitions AS definition
     WHERE execution.id = candidates.id
       AND definition.id = execution.job_definition_id
    RETURNING execution.*;
END;
$$;

CREATE OR REPLACE FUNCTION public.start_background_job_execution(
    requested_execution_id UUID,
    requested_lease_token UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
BEGIN
    UPDATE public.background_job_executions
       SET execution_status = 'RUNNING',
           started_at = COALESCE(started_at, statement_timestamp())
     WHERE id = requested_execution_id
       AND lease_token = requested_lease_token
       AND execution_status = 'LEASED'
       AND lease_expires_at > statement_timestamp();
    RETURN FOUND;
END;
$$;

CREATE OR REPLACE FUNCTION public.heartbeat_background_job_execution(
    requested_execution_id UUID,
    requested_lease_token UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
BEGIN
    UPDATE public.background_job_executions AS execution
       SET heartbeat_at = statement_timestamp(),
           lease_expires_at = statement_timestamp()
               + make_interval(secs => definition.lease_duration_seconds)
      FROM public.background_job_definitions AS definition
     WHERE execution.id = requested_execution_id
       AND definition.id = execution.job_definition_id
       AND execution.lease_token = requested_lease_token
       AND execution.execution_status IN ('LEASED', 'RUNNING', 'CANCELLATION_REQUESTED')
       AND execution.lease_expires_at > statement_timestamp();
    RETURN FOUND;
END;
$$;

CREATE OR REPLACE FUNCTION public.complete_background_job_execution(
    requested_execution_id UUID,
    requested_lease_token UUID,
    requested_result JSONB
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
BEGIN
    UPDATE public.background_job_executions
       SET execution_status = 'SUCCEEDED',
           completed_at = statement_timestamp(),
           result = requested_result,
           worker_id = NULL, lease_token = NULL, lease_expires_at = NULL, heartbeat_at = NULL
     WHERE id = requested_execution_id
       AND lease_token = requested_lease_token
       AND execution_status IN ('LEASED', 'RUNNING')
       AND lease_expires_at > statement_timestamp();
    RETURN FOUND;
END;
$$;

CREATE OR REPLACE FUNCTION public.fail_background_job_execution(
    requested_execution_id UUID,
    requested_lease_token UUID,
    requested_failure_code TEXT,
    requested_failure_message TEXT,
    requested_failure_details JSONB DEFAULT '{}'::JSONB,
    requested_retryable BOOLEAN DEFAULT TRUE
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE execution_record public.background_job_executions%ROWTYPE;
DECLARE definition public.background_job_definitions%ROWTYPE;
DECLARE delay_seconds NUMERIC;
DECLARE next_status TEXT;
BEGIN
    SELECT execution.*
      INTO execution_record
      FROM public.background_job_executions AS execution
     WHERE execution.id = requested_execution_id
       AND execution.lease_token = requested_lease_token
       AND execution.execution_status IN ('LEASED', 'RUNNING')
       AND execution.lease_expires_at > statement_timestamp()
     FOR UPDATE OF execution;
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    SELECT job_definition.*
      INTO STRICT definition
      FROM public.background_job_definitions AS job_definition
     WHERE job_definition.id = execution_record.job_definition_id;

    IF requested_retryable AND execution_record.attempt_count < definition.maximum_attempts THEN
        delay_seconds := CASE definition.retry_backoff_strategy
            WHEN 'FIXED' THEN definition.retry_base_delay_seconds
            WHEN 'LINEAR' THEN definition.retry_base_delay_seconds * execution_record.attempt_count
            ELSE definition.retry_base_delay_seconds * power(2::NUMERIC, execution_record.attempt_count - 1)
        END;
        delay_seconds := least(delay_seconds, definition.retry_max_delay_seconds);
        delay_seconds := delay_seconds * (
            1 + ((random() * 2 - 1) * definition.retry_jitter_percent / 100.0)
        );
        next_status := 'QUEUED';
        UPDATE public.background_job_executions
           SET execution_status = 'QUEUED',
               available_at = statement_timestamp()
                   + make_interval(secs => greatest(1, round(delay_seconds)::INTEGER)),
               failure_code = requested_failure_code,
               failure_message = requested_failure_message,
               failure_details = requested_failure_details,
               retryable = TRUE,
               worker_id = NULL, lease_token = NULL, lease_expires_at = NULL, heartbeat_at = NULL
         WHERE id = requested_execution_id;
    ELSE
        next_status := 'FAILED';
        UPDATE public.background_job_executions
           SET execution_status = 'FAILED',
               failed_at = statement_timestamp(),
               failure_code = requested_failure_code,
               failure_message = requested_failure_message,
               failure_details = requested_failure_details,
               retryable = requested_retryable,
               worker_id = NULL, lease_token = NULL, lease_expires_at = NULL, heartbeat_at = NULL
         WHERE id = requested_execution_id;
    END IF;
    RETURN next_status;
END;
$$;

CREATE OR REPLACE FUNCTION public.request_background_job_cancellation(
    requested_execution_id UUID,
    requested_reason TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
BEGIN
    IF NOT public.has_active_platform_role('PLATFORM_ADMINISTRATOR') THEN
        RAISE EXCEPTION 'active platform administrator role required'
            USING ERRCODE = '42501';
    END IF;

    UPDATE public.background_job_executions
       SET execution_status = CASE
               WHEN execution_status = 'QUEUED' THEN 'CANCELLED'
               ELSE 'CANCELLATION_REQUESTED'
           END,
           cancellation_requested_at = statement_timestamp(),
           cancellation_requested_by_user_id = auth.uid(),
           cancellation_reason = requested_reason,
           cancelled_at = CASE
               WHEN execution_status = 'QUEUED' THEN statement_timestamp()
               ELSE cancelled_at
           END,
           worker_id = CASE WHEN execution_status = 'QUEUED' THEN NULL ELSE worker_id END,
           lease_token = CASE WHEN execution_status = 'QUEUED' THEN NULL ELSE lease_token END,
           lease_expires_at = CASE WHEN execution_status = 'QUEUED' THEN NULL ELSE lease_expires_at END,
           heartbeat_at = CASE WHEN execution_status = 'QUEUED' THEN NULL ELSE heartbeat_at END
     WHERE id = requested_execution_id
       AND execution_status IN ('QUEUED', 'LEASED', 'RUNNING');
    RETURN FOUND;
END;
$$;

CREATE OR REPLACE FUNCTION public.acknowledge_background_job_cancellation(
    requested_execution_id UUID,
    requested_lease_token UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
BEGIN
    UPDATE public.background_job_executions
       SET execution_status = 'CANCELLED',
           cancelled_at = statement_timestamp(),
           worker_id = NULL, lease_token = NULL, lease_expires_at = NULL, heartbeat_at = NULL
     WHERE id = requested_execution_id
       AND lease_token = requested_lease_token
       AND execution_status = 'CANCELLATION_REQUESTED';
    RETURN FOUND;
END;
$$;

CREATE OR REPLACE FUNCTION public.reap_expired_background_job_leases(requested_limit INTEGER DEFAULT 100)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE affected_count INTEGER;
BEGIN
    IF requested_limit NOT BETWEEN 1 AND 1000 THEN
        RAISE EXCEPTION 'requested_limit must be between 1 and 1000'
            USING ERRCODE = '22023';
    END IF;

    WITH expired AS (
        SELECT execution.id
          FROM public.background_job_executions AS execution
          JOIN public.background_job_definitions AS definition
            ON definition.id = execution.job_definition_id
         WHERE execution.execution_status IN ('LEASED', 'RUNNING', 'CANCELLATION_REQUESTED')
           AND (
               execution.lease_expires_at <= statement_timestamp()
               OR execution.heartbeat_at
                    + make_interval(secs => definition.heartbeat_timeout_seconds)
                    <= statement_timestamp()
               OR (
                   execution.started_at IS NOT NULL
                   AND execution.started_at
                       + make_interval(secs => definition.execution_timeout_seconds)
                       <= statement_timestamp()
               )
           )
         ORDER BY execution.lease_expires_at, execution.id
         FOR UPDATE SKIP LOCKED
         LIMIT requested_limit
    )
    UPDATE public.background_job_executions AS execution
       SET execution_status = CASE
               WHEN execution.execution_status = 'CANCELLATION_REQUESTED' THEN 'CANCELLED'
               WHEN execution.attempt_count < definition.maximum_attempts THEN 'QUEUED'
               ELSE 'FAILED'
           END,
           available_at = CASE
               WHEN execution.execution_status <> 'CANCELLATION_REQUESTED'
                    AND execution.attempt_count < definition.maximum_attempts
                   THEN statement_timestamp() + make_interval(secs => definition.retry_base_delay_seconds)
               ELSE execution.available_at
           END,
           cancelled_at = CASE
               WHEN execution.execution_status = 'CANCELLATION_REQUESTED'
                   THEN statement_timestamp()
               ELSE execution.cancelled_at
           END,
           failed_at = CASE
               WHEN execution.execution_status <> 'CANCELLATION_REQUESTED'
                    AND execution.attempt_count >= definition.maximum_attempts
                   THEN statement_timestamp()
               ELSE execution.failed_at
           END,
           failure_code = CASE
               WHEN execution.execution_status = 'CANCELLATION_REQUESTED' THEN execution.failure_code
               ELSE 'LEASE_EXPIRED'
           END,
           failure_message = CASE
               WHEN execution.execution_status = 'CANCELLATION_REQUESTED' THEN execution.failure_message
               ELSE 'Worker lease expired before execution reached a terminal state'
           END,
           failure_details = CASE
               WHEN execution.execution_status = 'CANCELLATION_REQUESTED' THEN execution.failure_details
               ELSE jsonb_build_object('expired_at', statement_timestamp())
           END,
           retryable = CASE
               WHEN execution.execution_status = 'CANCELLATION_REQUESTED' THEN execution.retryable
               ELSE execution.attempt_count < definition.maximum_attempts
           END,
           worker_id = NULL, lease_token = NULL, lease_expires_at = NULL, heartbeat_at = NULL
      FROM expired, public.background_job_definitions AS definition
     WHERE execution.id = expired.id
       AND definition.id = execution.job_definition_id;
    GET DIAGNOSTICS affected_count = ROW_COUNT;
    RETURN affected_count;
END;
$$;

CREATE OR REPLACE FUNCTION public.audit_background_job_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE before_record JSONB;
DECLARE after_record JSONB;
DECLARE record_id UUID;
DECLARE action TEXT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        before_record := to_jsonb(OLD) - 'lease_token';
        after_record := NULL;
        record_id := OLD.id;
        action := 'DELETE';
    ELSE
        before_record := CASE
            WHEN TG_OP = 'INSERT' THEN NULL
            ELSE to_jsonb(OLD) - 'lease_token'
        END;
        after_record := to_jsonb(NEW) - 'lease_token';
        record_id := NEW.id;
        IF TG_OP = 'INSERT' THEN
            action := 'CREATE';
        ELSIF TG_TABLE_NAME = 'background_job_executions' THEN
            IF NEW.execution_status = 'CANCELLED'
               AND OLD.execution_status <> 'CANCELLED' THEN
                action := 'CANCEL';
            ELSE
                action := 'UPDATE';
            END IF;
        ELSE
            action := 'UPDATE';
        END IF;
    END IF;

    IF TG_TABLE_NAME = 'background_job_executions'
       AND TG_OP = 'UPDATE'
       AND (after_record - ARRAY['heartbeat_at', 'lease_expires_at', 'updated_at'])
           = (before_record - ARRAY['heartbeat_at', 'lease_expires_at', 'updated_at']) THEN
        RETURN NEW;
    END IF;

    INSERT INTO public.audit_events (
        audit_reference, event_category, event_type, event_action, actor_type,
        actor_user_id, source_component, entity_type, entity_id, operation_name,
        data_classification, before_values, after_values, changed_fields, event_details
    ) VALUES (
        'background-job.' || gen_random_uuid()::TEXT,
        CASE WHEN TG_TABLE_NAME = 'background_job_executions' THEN 'SYSTEM' ELSE 'ADMINISTRATION' END,
        'background_job_' || lower(TG_OP), action,
        CASE WHEN auth.uid() IS NULL THEN 'SYSTEM' ELSE 'ADMIN' END,
        auth.uid(), 'DATABASE_BACKGROUND_JOBS', TG_TABLE_NAME, record_id, TG_OP,
        'CONFIDENTIAL', before_record, after_record,
        CASE WHEN TG_OP = 'UPDATE' THEN (
            SELECT COALESCE(jsonb_agg(key ORDER BY key), '[]'::JSONB)
              FROM jsonb_each(after_record) AS item(key, value)
             WHERE before_record -> key IS DISTINCT FROM value
        ) ELSE '[]'::JSONB END,
        jsonb_build_object('heartbeat_only_suppressed', FALSE)
    );
    IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_background_job_definitions_manage
BEFORE INSERT OR UPDATE ON public.background_job_definitions
FOR EACH ROW EXECUTE FUNCTION public.manage_background_job_metadata();
CREATE TRIGGER trg_background_job_schedules_manage
BEFORE INSERT OR UPDATE ON public.background_job_schedules
FOR EACH ROW EXECUTE FUNCTION public.manage_background_job_metadata();
CREATE TRIGGER trg_background_job_schedules_validate
BEFORE INSERT OR UPDATE ON public.background_job_schedules
FOR EACH ROW EXECUTE FUNCTION public.validate_background_job_target();
CREATE TRIGGER trg_background_job_executions_validate
BEFORE INSERT OR UPDATE ON public.background_job_executions
FOR EACH ROW EXECUTE FUNCTION public.validate_background_job_target();

CREATE TRIGGER trg_background_job_definitions_updated_at
BEFORE UPDATE ON public.background_job_definitions
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_background_job_schedules_updated_at
BEFORE UPDATE ON public.background_job_schedules
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_background_job_executions_updated_at
BEFORE UPDATE ON public.background_job_executions
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_background_job_definitions_audit
AFTER INSERT OR UPDATE OR DELETE ON public.background_job_definitions
FOR EACH ROW EXECUTE FUNCTION public.audit_background_job_change();
CREATE TRIGGER trg_background_job_schedules_audit
AFTER INSERT OR UPDATE OR DELETE ON public.background_job_schedules
FOR EACH ROW EXECUTE FUNCTION public.audit_background_job_change();
CREATE TRIGGER trg_background_job_executions_audit
AFTER INSERT OR UPDATE OR DELETE ON public.background_job_executions
FOR EACH ROW EXECUTE FUNCTION public.audit_background_job_change();

ALTER TABLE public.background_job_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.background_job_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.background_job_executions ENABLE ROW LEVEL SECURITY;

CREATE POLICY platform_administrator_read_background_job_definitions
ON public.background_job_definitions FOR SELECT TO authenticated
USING (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));
CREATE POLICY platform_administrator_create_background_job_definitions
ON public.background_job_definitions FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));
CREATE POLICY platform_administrator_update_background_job_definitions
ON public.background_job_definitions FOR UPDATE TO authenticated
USING (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'))
WITH CHECK (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));

CREATE POLICY platform_administrator_read_background_job_schedules
ON public.background_job_schedules FOR SELECT TO authenticated
USING (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));
CREATE POLICY platform_administrator_create_background_job_schedules
ON public.background_job_schedules FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));
CREATE POLICY platform_administrator_update_background_job_schedules
ON public.background_job_schedules FOR UPDATE TO authenticated
USING (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'))
WITH CHECK (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));

CREATE POLICY platform_administrator_read_background_job_executions
ON public.background_job_executions FOR SELECT TO authenticated
USING (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));

COMMENT ON TABLE public.background_job_definitions IS
'Durable job types and bounded retry, timeout, lease, heartbeat, and priority defaults.';
COMMENT ON TABLE public.background_job_schedules IS
'Database-backed one-time or interval schedules. An external trusted loop calls materialize_due_background_jobs; PostgreSQL cron is not installed.';
COMMENT ON TABLE public.background_job_executions IS
'Durable execution lifecycle, consumer target, lease token, heartbeat, cancellation, failure, and result metadata.';
COMMENT ON COLUMN public.background_job_executions.lease_token IS
'Unpredictable fencing token required for every worker lifecycle mutation; cleared whenever the lease ends.';
COMMENT ON FUNCTION public.enqueue_background_job(TEXT, UUID, UUID, JSONB, TIMESTAMPTZ, SMALLINT, TEXT) IS
'SECURITY DEFINER service-role entry point for validated, idempotent enqueueing while execution tables remain hidden from untrusted writers.';
COMMENT ON FUNCTION public.materialize_due_background_jobs(INTEGER) IS
'SECURITY DEFINER service-role scheduler primitive using row locks and unique occurrences to materialize due schedules exactly once.';
COMMENT ON FUNCTION public.lease_background_jobs(TEXT, INTEGER) IS
'SECURITY DEFINER service-role worker primitive atomically claims eligible work with FOR UPDATE SKIP LOCKED and returns lease tokens.';
COMMENT ON FUNCTION public.heartbeat_background_job_execution(UUID, UUID) IS
'SECURITY DEFINER service-role heartbeat validates the fencing token and extends only a live lease.';
COMMENT ON FUNCTION public.request_background_job_cancellation(UUID, TEXT) IS
'SECURITY DEFINER permits only active platform administrators to request cancellation without granting execution-table writes.';
COMMENT ON FUNCTION public.audit_background_job_change() IS
'SECURITY DEFINER writes lifecycle and administrative mutations to audit_events without granting audit-table writes; lease tokens are redacted and heartbeat-only updates are suppressed.';

REVOKE ALL ON TABLE public.background_job_definitions,
    public.background_job_schedules, public.background_job_executions
    FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.background_job_definitions,
    public.background_job_schedules TO authenticated;
GRANT SELECT ON TABLE public.background_job_executions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.background_job_definitions,
    public.background_job_schedules, public.background_job_executions TO service_role;

REVOKE EXECUTE ON FUNCTION public.validate_background_job_target(),
    public.manage_background_job_metadata(),
    public.enqueue_background_job(TEXT, UUID, UUID, JSONB, TIMESTAMPTZ, SMALLINT, TEXT),
    public.materialize_due_background_jobs(INTEGER),
    public.lease_background_jobs(TEXT, INTEGER),
    public.start_background_job_execution(UUID, UUID),
    public.heartbeat_background_job_execution(UUID, UUID),
    public.complete_background_job_execution(UUID, UUID, JSONB),
    public.fail_background_job_execution(UUID, UUID, TEXT, TEXT, JSONB, BOOLEAN),
    public.request_background_job_cancellation(UUID, TEXT),
    public.acknowledge_background_job_cancellation(UUID, UUID),
    public.reap_expired_background_job_leases(INTEGER),
    public.audit_background_job_change()
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION
    public.enqueue_background_job(TEXT, UUID, UUID, JSONB, TIMESTAMPTZ, SMALLINT, TEXT),
    public.materialize_due_background_jobs(INTEGER),
    public.lease_background_jobs(TEXT, INTEGER),
    public.start_background_job_execution(UUID, UUID),
    public.heartbeat_background_job_execution(UUID, UUID),
    public.complete_background_job_execution(UUID, UUID, JSONB),
    public.fail_background_job_execution(UUID, UUID, TEXT, TEXT, JSONB, BOOLEAN),
    public.acknowledge_background_job_cancellation(UUID, UUID),
    public.reap_expired_background_job_leases(INTEGER)
TO service_role;
GRANT EXECUTE ON FUNCTION public.request_background_job_cancellation(UUID, TEXT)
TO authenticated;

COMMIT;
