-- Migration 0042 — authorization-change audit trigger coverage.
--
-- Confirms audit_platform_authorization_change writes the expected
-- audit_events row (correct action, entity linkage, personal-data flag,
-- and before/after payload shape) for both a create and a revoke of a
-- user_platform_role_assignments row.
BEGIN;

SELECT plan(4);

INSERT INTO auth.users (id, email) VALUES
    ('a0000000-0000-4000-8000-000000000031', 'audit-actor@example.invalid');

-- Explicit id so this test does not depend on capturing a generated UUID.
INSERT INTO public.user_platform_role_assignments (id, user_id, role_id)
VALUES (
    'a0000000-0000-4000-8000-0000000000f1'::uuid,
    'a0000000-0000-4000-8000-000000000031'::uuid,
    '42000000-0000-4000-8000-000000000006'::uuid
);

SELECT ok(
    (SELECT count(*) FROM public.audit_events
     WHERE event_category = 'AUTHORIZATION'
       AND entity_type = 'user_platform_role_assignments'
       AND entity_id = 'a0000000-0000-4000-8000-0000000000f1'::uuid
       AND event_action = 'CREATE') = 1,
    'inserting a role assignment writes exactly one CREATE audit_events row for that assignment'
);

UPDATE public.user_platform_role_assignments
SET revoked_at = now()
WHERE id = 'a0000000-0000-4000-8000-0000000000f1'::uuid;

SELECT ok(
    (SELECT count(*) FROM public.audit_events
     WHERE event_category = 'AUTHORIZATION'
       AND entity_type = 'user_platform_role_assignments'
       AND entity_id = 'a0000000-0000-4000-8000-0000000000f1'::uuid
       AND event_action = 'REVOKE') = 1,
    'revoking a role assignment writes exactly one REVOKE audit_events row for that assignment'
);

SELECT ok(
    (SELECT contains_personal_data FROM public.audit_events
     WHERE event_category = 'AUTHORIZATION'
       AND entity_type = 'user_platform_role_assignments'
       AND entity_id = 'a0000000-0000-4000-8000-0000000000f1'::uuid
       AND event_action = 'CREATE') = TRUE,
    'the audit event for a user_platform_role_assignments change is flagged as containing personal data'
);

SELECT ok(
    (SELECT before_values IS NULL AND after_values IS NOT NULL
     FROM public.audit_events
     WHERE event_category = 'AUTHORIZATION'
       AND entity_type = 'user_platform_role_assignments'
       AND entity_id = 'a0000000-0000-4000-8000-0000000000f1'::uuid
       AND event_action = 'CREATE'),
    'the CREATE audit event captures after_values with no before_values, matching an insert'
);

SELECT * FROM finish();

ROLLBACK;
