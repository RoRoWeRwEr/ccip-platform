-- Migration 0043 — runtime evaluation and audit-event coverage.
BEGIN;

SELECT plan(15);

INSERT INTO public.feature_flags (
    id, flag_key, display_name, lifecycle_status, default_enabled,
    rollout_percentage, activates_at, expires_at, administrative_reason
) VALUES
    ('43000000-0000-4000-8000-000000000001', 'tests.active-default', 'Active default', 'ACTIVE', TRUE, NULL, NULL, NULL, 'evaluation test'),
    ('43000000-0000-4000-8000-000000000002', 'tests.inactive', 'Inactive', 'INACTIVE', TRUE, NULL, NULL, NULL, 'evaluation test'),
    ('43000000-0000-4000-8000-000000000003', 'tests.archived', 'Archived', 'ARCHIVED', TRUE, NULL, NULL, NULL, 'evaluation test'),
    ('43000000-0000-4000-8000-000000000004', 'tests.draft', 'Draft', 'DRAFT', TRUE, NULL, NULL, NULL, 'evaluation test'),
    ('43000000-0000-4000-8000-000000000005', 'tests.future', 'Future', 'ACTIVE', TRUE, NULL, now() + interval '1 day', NULL, 'evaluation test'),
    ('43000000-0000-4000-8000-000000000006', 'tests.expired', 'Expired', 'ACTIVE', TRUE, NULL, now() - interval '2 days', now() - interval '1 day', 'evaluation test'),
    ('43000000-0000-4000-8000-000000000007', 'tests.zero', 'Zero rollout', 'ACTIVE', TRUE, 0.00, NULL, NULL, 'evaluation test'),
    ('43000000-0000-4000-8000-000000000008', 'tests.full', 'Full rollout', 'ACTIVE', FALSE, 100.00, NULL, NULL, 'evaluation test'),
    ('43000000-0000-4000-8000-000000000009', 'tests.half', 'Half rollout', 'ACTIVE', FALSE, 50.00, NULL, NULL, 'evaluation test');

SET ROLE anon;

SELECT ok(public.is_feature_enabled('tests.active-default'), 'an active unscheduled flag returns its default state');
SELECT ok(NOT public.is_feature_enabled('tests.inactive'), 'an inactive flag always evaluates false');
SELECT ok(NOT public.is_feature_enabled('tests.archived'), 'an archived flag always evaluates false');
SELECT ok(NOT public.is_feature_enabled('tests.draft'), 'a draft flag always evaluates false');
SELECT ok(NOT public.is_feature_enabled('tests.future'), 'a not-yet-active flag evaluates false');
SELECT ok(NOT public.is_feature_enabled('tests.expired'), 'an expired flag evaluates false');
SELECT ok(NOT public.is_feature_enabled('tests.missing'), 'a missing flag fails closed');
SELECT ok(NOT public.is_feature_enabled('tests.zero', 'subject-1'), 'zero percent rollout disables every supplied subject');
SELECT ok(public.is_feature_enabled('tests.full', 'subject-1'), 'one hundred percent rollout enables every supplied subject');
SELECT ok(NOT public.is_feature_enabled('tests.full'), 'without a rollout subject the configured default is used');
SELECT ok(
    public.is_feature_enabled('tests.half', 'stable-subject')
        IS NOT DISTINCT FROM public.is_feature_enabled('tests.half', 'stable-subject'),
    'a subject receives the same deterministic result on repeated hash-based rollout evaluation'
);

RESET ROLE;

SELECT ok(
    (SELECT count(*) FROM public.audit_events
     WHERE event_category = 'ADMINISTRATION'
       AND entity_type = 'feature_flags'
       AND event_action = 'CREATE') = 9,
    'each feature flag creation writes one administrative audit event'
);

DELETE FROM public.feature_flags
WHERE id = '43000000-0000-4000-8000-000000000004'::uuid;

SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
        WHERE event_category = 'ADMINISTRATION'
          AND entity_type = 'feature_flags'
          AND entity_id = '43000000-0000-4000-8000-000000000004'::uuid
          AND entity_reference = 'tests.draft'
          AND event_action = 'DELETE'
          AND before_values IS NOT NULL
          AND after_values IS NULL
    ),
    'deleting a flag writes a DELETE event using only the OLD row values'
);

UPDATE public.feature_flags
SET lifecycle_status = 'ARCHIVED', administrative_reason = 'archive audit test'
WHERE id = '43000000-0000-4000-8000-000000000001'::uuid;

SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
        WHERE event_category = 'ADMINISTRATION'
          AND entity_type = 'feature_flags'
          AND entity_id = '43000000-0000-4000-8000-000000000001'::uuid
          AND entity_reference = 'tests.active-default'
          AND event_action = 'ARCHIVE'
          AND before_values IS NOT NULL
          AND after_values IS NOT NULL
          AND changed_fields ? 'lifecycle_status'
    ),
    'archiving a flag writes an ARCHIVE event with before/after values and changed fields'
);

SELECT ok(
    (SELECT data_classification = 'INTERNAL'
         AND contains_personal_data = FALSE
     FROM public.audit_events
     WHERE entity_id = '43000000-0000-4000-8000-000000000001'::uuid
       AND event_action = 'CREATE'),
    'feature flag audit events are internal and do not claim to contain personal data'
);

SELECT * FROM finish();
ROLLBACK;
