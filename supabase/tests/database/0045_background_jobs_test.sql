-- Migration 0045 — schema, scheduling, leasing, lifecycle, RLS, and audit coverage.
BEGIN;
SELECT plan(36);

SELECT has_table('public', 'background_job_definitions', 'job definitions exist');
SELECT has_table('public', 'background_job_schedules', 'job schedules exist');
SELECT has_table('public', 'background_job_executions', 'job executions exist');
SELECT has_function('public', 'lease_background_jobs', ARRAY['text', 'integer'],
    'atomic worker leasing function exists');
SELECT has_function('public', 'heartbeat_background_job_execution', ARRAY['uuid', 'uuid'],
    'heartbeat function exists');
SELECT ok((
    SELECT bool_and(relrowsecurity)
      FROM pg_catalog.pg_class
     WHERE oid IN (
        'public.background_job_definitions'::regclass,
        'public.background_job_schedules'::regclass,
        'public.background_job_executions'::regclass
     )
), 'RLS is enabled on every background-job table');

INSERT INTO auth.users (id, email) VALUES
 ('a4500000-0000-4000-8000-000000000001', 'jobs-admin@example.invalid'),
 ('a4500000-0000-4000-8000-000000000002', 'jobs-user@example.invalid');
INSERT INTO public.user_platform_role_assignments (user_id, role_id) VALUES
 ('a4500000-0000-4000-8000-000000000001', '42000000-0000-4000-8000-000000000001');

INSERT INTO public.countries (id, code, slug, name_en, name_ar) VALUES
 ('45000000-0000-4000-8000-000000000001', 'ZZ', 'jobs-test-country', 'Jobs Test', 'اختبار');
INSERT INTO public.currencies (id, code, slug, name_en, name_ar) VALUES
 ('45000000-0000-4000-8000-000000000002', 'XTS', 'jobs-test-currency', 'Test Currency', 'عملة اختبار');
INSERT INTO public.banks (id, country_id, slug, name_en, name_ar) VALUES
 ('45000000-0000-4000-8000-000000000003',
  '45000000-0000-4000-8000-000000000001', 'jobs-test-bank', 'Jobs Test Bank', 'بنك اختبار');
INSERT INTO public.bank_partnerships (
    id, bank_id, partnership_reference, partnership_name, default_currency_id
) VALUES (
    '45000000-0000-4000-8000-000000000004',
    '45000000-0000-4000-8000-000000000003',
    'PARTNER.JOBS.TEST', 'Jobs Test Partnership',
    '45000000-0000-4000-8000-000000000002'
);
INSERT INTO public.commission_settlements (
    id, partnership_id, bank_id, settlement_reference,
    settlement_period_start, settlement_period_end, settlement_currency_id
) VALUES (
    '45000000-0000-4000-8000-000000000005',
    '45000000-0000-4000-8000-000000000004',
    '45000000-0000-4000-8000-000000000003',
    'SETTLEMENT.JOBS.TEST', DATE '2026-01-01', DATE '2026-01-31',
    '45000000-0000-4000-8000-000000000002'
);
INSERT INTO public.data_retention_policies (
    id, retention_policy_reference, policy_name, entity_type,
    retention_trigger, retention_period_days
) VALUES (
    '45000000-0000-4000-8000-000000000006',
    'RETENTION.JOBS.TEST', 'Jobs Test Retention', 'audit_events',
    'RECORD_CREATED', 365
);
INSERT INTO public.data_retention_executions (
    id, retention_policy_id, execution_reference, entity_type
) VALUES (
    '45000000-0000-4000-8000-000000000007',
    '45000000-0000-4000-8000-000000000006',
    'RETENTION.EXECUTION.JOBS.TEST', 'audit_events'
);

INSERT INTO public.background_job_definitions (
    id, job_code, display_name, description, consumer_type,
    maximum_attempts, retry_backoff_strategy, retry_base_delay_seconds,
    retry_max_delay_seconds, retry_jitter_percent, lease_duration_seconds,
    heartbeat_timeout_seconds
) VALUES
 ('45000000-0000-4000-8000-000000000010', 'retention.execute',
  'Execute retention', 'Executes an approved data-retention execution.',
  'DATA_RETENTION_EXECUTION', 2, 'FIXED', 1, 1, 0, 60, 30),
 ('45000000-0000-4000-8000-000000000011', 'settlement.process',
  'Process settlement', 'Processes a commission settlement lifecycle step.',
  'COMMISSION_SETTLEMENT', 3, 'EXPONENTIAL', 1, 4, 0, 60, 30);

SELECT ok(EXISTS (
    SELECT 1 FROM public.audit_events
     WHERE entity_type = 'background_job_definitions'
       AND entity_id = '45000000-0000-4000-8000-000000000010'
       AND event_action = 'CREATE'
), 'job-definition creation is audited');

SELECT throws_ok(
 $$INSERT INTO public.background_job_definitions
   (job_code, display_name, description, consumer_type, maximum_attempts)
   VALUES ('invalid.job', 'Invalid', 'Invalid retry metadata.',
           'DATA_RETENTION_EXECUTION', 0)$$,
 '23514', NULL, 'invalid retry metadata is rejected');

SELECT throws_ok(
 $$INSERT INTO public.background_job_executions
   (job_definition_id, execution_reference, priority, commission_settlement_id)
   VALUES ('45000000-0000-4000-8000-000000000010',
           'JOB.WRONG.TARGET', 100,
           '45000000-0000-4000-8000-000000000005')$$,
 '23514', 'data-retention jobs require a data_retention_execution_id',
 'consumer-specific targets are enforced');

SELECT is(
 public.enqueue_background_job(
   'retention.execute',
   '45000000-0000-4000-8000-000000000007',
   NULL, '{"source":"manual"}', now(), 50, 'retention-idempotent'
 ),
 public.enqueue_background_job(
   'retention.execute',
   '45000000-0000-4000-8000-000000000007',
   NULL, '{"source":"ignored-duplicate"}', now(), 50, 'retention-idempotent'
 ),
 'enqueueing with the same scoped idempotency key returns the same execution');
SELECT is((
    SELECT count(*)::INTEGER FROM public.background_job_executions
     WHERE idempotency_key = 'retention-idempotent'
), 1, 'idempotent enqueue creates one execution');

INSERT INTO public.background_job_schedules (
    id, job_definition_id, schedule_code, display_name, schedule_type,
    interval_seconds, next_run_at, commission_settlement_id, payload
) VALUES (
    '45000000-0000-4000-8000-000000000012',
    '45000000-0000-4000-8000-000000000011',
    'settlement.interval', 'Settlement interval', 'INTERVAL', 60,
    now() - interval '1 second',
    '45000000-0000-4000-8000-000000000005',
    '{"source":"schedule"}'
);
SELECT ok(EXISTS (
    SELECT 1 FROM public.audit_events
     WHERE entity_type = 'background_job_schedules'
       AND entity_id = '45000000-0000-4000-8000-000000000012'
       AND event_action = 'CREATE'
), 'job-schedule creation exercises the shared audit trigger safely');
SELECT is((
    SELECT count(*)::INTEGER FROM public.materialize_due_background_jobs(10)
), 1, 'a due schedule materializes one execution');
SELECT is((
    SELECT count(*)::INTEGER FROM public.materialize_due_background_jobs(10)
), 0, 'the same schedule occurrence is not materialized twice');
SELECT ok((
    SELECT next_run_at > last_materialized_at
      FROM public.background_job_schedules
     WHERE id = '45000000-0000-4000-8000-000000000012'
), 'interval schedule advances after materialization');
SELECT ok(EXISTS (
    SELECT 1 FROM public.background_job_executions
     WHERE schedule_id = '45000000-0000-4000-8000-000000000012'
       AND commission_settlement_id = '45000000-0000-4000-8000-000000000005'
), 'scheduled execution preserves its commission-settlement target');

CREATE TEMP TABLE leased_execution AS
SELECT id, lease_token, execution_status, attempt_count, worker_id
  FROM public.lease_background_jobs('worker-a', 1);
SELECT is((SELECT execution_status FROM leased_execution), 'LEASED',
    'an eligible execution is atomically leased');
SELECT is((SELECT attempt_count FROM leased_execution), 1,
    'leasing increments the attempt count');
SELECT is((SELECT worker_id FROM leased_execution), 'worker-a',
    'the lease records its worker identity');
SELECT ok((SELECT lease_token IS NOT NULL FROM leased_execution),
    'the lease returns an unpredictable fencing token');
SELECT ok(NOT public.start_background_job_execution(
    (SELECT id FROM leased_execution),
    'ffffffff-ffff-4fff-8fff-ffffffffffff'
), 'an invalid fencing token cannot start execution');
SELECT ok(public.start_background_job_execution(
    (SELECT id FROM leased_execution),
    (SELECT lease_token FROM leased_execution)
), 'the valid lease holder can start execution');
SELECT ok(public.heartbeat_background_job_execution(
    (SELECT id FROM leased_execution),
    (SELECT lease_token FROM leased_execution)
), 'the valid lease holder can heartbeat');
SELECT is(public.fail_background_job_execution(
    (SELECT id FROM leased_execution),
    (SELECT lease_token FROM leased_execution),
    'TRANSIENT_FAILURE', 'Temporary failure', '{"retry":"safe"}', TRUE
), 'QUEUED', 'a retryable failure is requeued below the attempt limit');
SELECT is((
    SELECT execution_status FROM public.background_job_executions
     WHERE id = (SELECT id FROM leased_execution)
), 'QUEUED', 'retry clears the active lease and returns execution to the queue');

UPDATE public.background_job_executions
   SET available_at = now() - interval '1 second'
 WHERE id = (SELECT id FROM leased_execution);
TRUNCATE leased_execution;
INSERT INTO leased_execution
SELECT id, lease_token, execution_status, attempt_count, worker_id
  FROM public.lease_background_jobs('worker-b', 1);
SELECT is(public.fail_background_job_execution(
    (SELECT id FROM leased_execution),
    (SELECT lease_token FROM leased_execution),
    'PERMANENT_FAILURE', 'Attempts exhausted', '{}', TRUE
), 'FAILED', 'a failure becomes terminal at the attempt limit');
SELECT ok((
    SELECT failed_at IS NOT NULL AND failure_code = 'PERMANENT_FAILURE'
      FROM public.background_job_executions
     WHERE id = (SELECT id FROM leased_execution)
), 'terminal failure metadata is retained');

SELECT public.enqueue_background_job(
   'settlement.process', NULL,
   '45000000-0000-4000-8000-000000000005',
   '{"action":"complete"}', now(), 1, 'completion-test'
);
TRUNCATE leased_execution;
INSERT INTO leased_execution
SELECT id, lease_token, execution_status, attempt_count, worker_id
  FROM public.lease_background_jobs('worker-c', 1);
SELECT ok(public.complete_background_job_execution(
    (SELECT id FROM leased_execution),
    (SELECT lease_token FROM leased_execution),
    '{"settled":true}'
), 'the lease holder can complete an execution');
SELECT results_eq(
 $$SELECT execution_status, result
     FROM public.background_job_executions
    WHERE id = (SELECT id FROM leased_execution)$$,
 $$VALUES ('SUCCEEDED'::TEXT, '{"settled":true}'::JSONB)$$,
 'successful execution retains structured result metadata');

SELECT public.enqueue_background_job(
   'settlement.process', NULL,
   '45000000-0000-4000-8000-000000000005',
   '{}', now(), 1, 'cancel-test'
);
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4500000-0000-4000-8000-000000000002';
SELECT is((SELECT count(*)::INTEGER FROM public.background_job_definitions), 0,
    'unprivileged authenticated users cannot read job metadata');
SELECT throws_ok(
 $$SELECT public.request_background_job_cancellation(
   (SELECT id FROM public.background_job_executions WHERE idempotency_key='cancel-test'),
   'not authorized')$$,
 '42501', 'active platform administrator role required',
 'unprivileged users cannot request cancellation');
RESET ROLE;
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4500000-0000-4000-8000-000000000001';
SELECT is((SELECT count(*)::INTEGER FROM public.background_job_definitions), 2,
    'platform administrators can read job definitions');
SELECT ok(public.request_background_job_cancellation(
   (SELECT id FROM public.background_job_executions WHERE idempotency_key='cancel-test'),
   'operator cancelled queued work'
), 'platform administrators can cancel queued work through the narrow helper');
RESET ROLE;
SELECT is((
    SELECT execution_status FROM public.background_job_executions
     WHERE idempotency_key = 'cancel-test'
), 'CANCELLED', 'queued cancellation is immediately terminal');
SELECT ok(EXISTS (
    SELECT 1 FROM public.audit_events AS audit
    JOIN public.background_job_executions AS execution ON execution.id = audit.entity_id
     WHERE execution.idempotency_key = 'cancel-test'
       AND audit.entity_type = 'background_job_executions'
       AND audit.event_action = 'CANCEL'
), 'execution cancellation is audited');
SELECT is((
    SELECT count(*)::INTEGER
      FROM information_schema.role_table_grants
     WHERE table_schema = 'public'
       AND table_name = 'background_job_executions'
       AND grantee = 'authenticated'
       AND privilege_type IN ('INSERT', 'UPDATE', 'DELETE')
), 0, 'authenticated callers have no direct execution mutation grants');

SELECT * FROM finish();
ROLLBACK;
