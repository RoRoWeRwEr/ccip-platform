-- Migration 0043: platform-wide feature flags.
--
-- This migration deliberately supports PLATFORM-wide flags only. Resource,
-- tenant, bank, country, customer, and functional-area targeting are not
-- represented because the authorization and evaluation semantics for those
-- scopes do not yet exist in this repository.

CREATE TABLE public.feature_flags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flag_key TEXT NOT NULL,
    display_name TEXT NOT NULL,
    description TEXT,
    lifecycle_status TEXT NOT NULL DEFAULT 'DRAFT',
    default_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    rollout_percentage NUMERIC(5,2),
    activates_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    administrative_reason TEXT NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
    created_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    updated_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_feature_flags_key UNIQUE (flag_key),
    CONSTRAINT chk_feature_flags_key
        CHECK (flag_key ~ '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$'),
    CONSTRAINT chk_feature_flags_display_name
        CHECK (length(trim(display_name)) BETWEEN 1 AND 200),
    CONSTRAINT chk_feature_flags_description
        CHECK (description IS NULL OR length(trim(description)) > 0),
    CONSTRAINT chk_feature_flags_lifecycle_status
        CHECK (lifecycle_status IN ('DRAFT', 'ACTIVE', 'INACTIVE', 'ARCHIVED')),
    CONSTRAINT chk_feature_flags_rollout_percentage
        CHECK (
            rollout_percentage IS NULL
            OR rollout_percentage BETWEEN 0.00 AND 100.00
        ),
    CONSTRAINT chk_feature_flags_schedule
        CHECK (expires_at IS NULL OR activates_at IS NULL OR expires_at > activates_at),
    CONSTRAINT chk_feature_flags_administrative_reason
        CHECK (length(trim(administrative_reason)) BETWEEN 1 AND 1000),
    CONSTRAINT chk_feature_flags_metadata
        CHECK (jsonb_typeof(metadata) = 'object')
);

COMMENT ON TABLE public.feature_flags IS
    'PLATFORM-wide feature flag definitions. Only active flags inside their schedule can evaluate enabled; narrower targeting is intentionally unsupported.';
COMMENT ON COLUMN public.feature_flags.flag_key IS
    'Stable, unique, lower-case machine key used by runtime callers.';
COMMENT ON COLUMN public.feature_flags.default_enabled IS
    'Fallback result when rollout_percentage is null or no rollout subject is supplied.';
COMMENT ON COLUMN public.feature_flags.rollout_percentage IS
    'Optional deterministic enabled percentage from 0 through 100, applied only when a rollout subject is supplied.';
COMMENT ON COLUMN public.feature_flags.administrative_reason IS
    'Required operator rationale for the current flag configuration; changes are captured in audit_events.';

CREATE INDEX idx_feature_flags_runtime_lookup
ON public.feature_flags(flag_key, lifecycle_status, activates_at, expires_at);

CREATE INDEX idx_feature_flags_active_schedule
ON public.feature_flags(activates_at, expires_at)
WHERE lifecycle_status = 'ACTIVE';

CREATE INDEX idx_feature_flags_updated_by
ON public.feature_flags(updated_by_user_id)
WHERE updated_by_user_id IS NOT NULL;

CREATE OR REPLACE FUNCTION public.manage_feature_flag_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
    IF current_user = 'authenticated' THEN
        IF TG_OP = 'INSERT' THEN
            NEW.created_by_user_id = auth.uid();
            NEW.created_at = now();
        ELSE
            IF NEW.id IS DISTINCT FROM OLD.id
               OR NEW.flag_key IS DISTINCT FROM OLD.flag_key
               OR NEW.created_by_user_id IS DISTINCT FROM OLD.created_by_user_id
               OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
                RAISE EXCEPTION 'feature flag identity and creation audit fields may not be modified'
                    USING ERRCODE = '42501';
            END IF;
        END IF;

        NEW.updated_by_user_id = auth.uid();
    END IF;

    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.manage_feature_flag_change() IS
    'SECURITY INVOKER trigger that protects immutable feature-flag identity/audit fields and stamps authenticated administrators.';

CREATE OR REPLACE FUNCTION public.is_feature_enabled(
    requested_flag_key TEXT,
    rollout_subject TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
    SELECT COALESCE((
        SELECT CASE
            WHEN flag.lifecycle_status <> 'ACTIVE' THEN FALSE
            WHEN flag.activates_at IS NOT NULL
                 AND flag.activates_at > statement_timestamp() THEN FALSE
            WHEN flag.expires_at IS NOT NULL
                 AND flag.expires_at <= statement_timestamp() THEN FALSE
            WHEN flag.rollout_percentage IS NULL OR rollout_subject IS NULL
                THEN flag.default_enabled
            WHEN flag.rollout_percentage = 100.00 THEN TRUE
            WHEN flag.rollout_percentage = 0.00 THEN FALSE
            ELSE (
                (
                    ('x' || substr(md5(flag.flag_key || ':' || rollout_subject), 1, 8))::bit(32)::bigint
                    % 10000
                ) < (flag.rollout_percentage * 100)::bigint
            )
        END
        FROM public.feature_flags AS flag
        WHERE flag.flag_key = requested_flag_key
    ), FALSE);
$$;

COMMENT ON FUNCTION public.is_feature_enabled(TEXT, TEXT) IS
    'SECURITY DEFINER is necessary to expose only a boolean flag decision to runtime callers while RLS keeps administrative definitions private. The function returns false for missing, non-ACTIVE, not-yet-active, and expired flags; percentage rollout is deterministic by flag key and caller-supplied subject. All references are schema-qualified and search_path is pinned.';

CREATE OR REPLACE FUNCTION public.audit_feature_flag_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE
    changed_record JSONB;
    previous_record JSONB;
    changed_record_id UUID;
    changed_record_reference TEXT;
    audit_action TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        changed_record = to_jsonb(NEW);
        previous_record = NULL;
        changed_record_id = NEW.id;
        changed_record_reference = NEW.flag_key;
        audit_action = 'CREATE';
    ELSIF TG_OP = 'UPDATE' THEN
        changed_record = to_jsonb(NEW);
        previous_record = to_jsonb(OLD);
        changed_record_id = NEW.id;
        changed_record_reference = NEW.flag_key;
        audit_action = CASE
            WHEN NEW.lifecycle_status = 'ARCHIVED'
                 AND OLD.lifecycle_status <> 'ARCHIVED' THEN 'ARCHIVE'
            WHEN NEW.lifecycle_status = 'ACTIVE'
                 AND OLD.lifecycle_status <> 'ACTIVE' THEN 'ACTIVATE'
            WHEN NEW.lifecycle_status = 'INACTIVE'
                 AND OLD.lifecycle_status <> 'INACTIVE' THEN 'DEACTIVATE'
            ELSE 'UPDATE'
        END;
    ELSE
        changed_record = NULL;
        previous_record = to_jsonb(OLD);
        changed_record_id = OLD.id;
        changed_record_reference = OLD.flag_key;
        audit_action = 'DELETE';
    END IF;

    INSERT INTO public.audit_events (
        audit_reference,
        event_category,
        event_type,
        event_action,
        actor_type,
        actor_user_id,
        source_component,
        entity_type,
        entity_id,
        entity_reference,
        operation_name,
        data_classification,
        before_values,
        after_values,
        changed_fields,
        event_details
    )
    VALUES (
        'feature-flag.' || gen_random_uuid()::TEXT,
        'ADMINISTRATION',
        'feature_flag_' || lower(TG_OP),
        audit_action,
        CASE WHEN auth.uid() IS NULL THEN 'SYSTEM' ELSE 'ADMIN' END,
        auth.uid(),
        'DATABASE_FEATURE_FLAGS',
        'feature_flags',
        changed_record_id,
        changed_record_reference,
        TG_OP,
        'INTERNAL',
        previous_record,
        changed_record,
        CASE
            WHEN TG_OP = 'UPDATE' THEN (
                SELECT COALESCE(jsonb_agg(key ORDER BY key), '[]'::JSONB)
                FROM jsonb_each(changed_record) AS current_value(key, value)
                WHERE previous_record -> key IS DISTINCT FROM value
            )
            ELSE '[]'::JSONB
        END,
        jsonb_build_object('trigger_operation', TG_OP)
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.audit_feature_flag_change() IS
    'SECURITY DEFINER is necessary so every feature_flags mutation is recorded in audit_events without granting callers direct audit-log writes. References are schema-qualified and search_path is pinned.';

CREATE TRIGGER trg_feature_flags_manage_change
BEFORE INSERT OR UPDATE ON public.feature_flags
FOR EACH ROW
EXECUTE FUNCTION public.manage_feature_flag_change();

CREATE TRIGGER trg_feature_flags_audit
AFTER INSERT OR UPDATE OR DELETE ON public.feature_flags
FOR EACH ROW
EXECUTE FUNCTION public.audit_feature_flag_change();

ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;

CREATE POLICY platform_administrator_read_feature_flags
ON public.feature_flags FOR SELECT TO authenticated
USING (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));

CREATE POLICY platform_administrator_create_feature_flags
ON public.feature_flags FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));

CREATE POLICY platform_administrator_update_feature_flags
ON public.feature_flags FOR UPDATE TO authenticated
USING (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'))
WITH CHECK (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));

REVOKE ALL ON TABLE public.feature_flags FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.manage_feature_flag_change()
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.audit_feature_flag_change()
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.is_feature_enabled(TEXT, TEXT)
FROM PUBLIC;

GRANT SELECT, INSERT, UPDATE ON TABLE public.feature_flags TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.feature_flags TO service_role;
GRANT EXECUTE ON FUNCTION public.is_feature_enabled(TEXT, TEXT)
TO anon, authenticated, service_role;
