-- Migration 0042 — has_active_platform_role / has_active_platform_permission coverage.
--
-- Confirms both functions return true only for an assignment that is
-- currently active (not expired, not revoked, not merely absent), and
-- false in every other case.
BEGIN;

SELECT plan(8);

INSERT INTO auth.users (id, email) VALUES
    ('a0000000-0000-4000-8000-000000000011', 'auth-fn-active@example.invalid'),
    ('a0000000-0000-4000-8000-000000000012', 'auth-fn-expired@example.invalid'),
    ('a0000000-0000-4000-8000-000000000013', 'auth-fn-revoked@example.invalid'),
    ('a0000000-0000-4000-8000-000000000014', 'auth-fn-none@example.invalid');

-- Active assignment: REPORTING_VIEWER, currently within its validity window.
INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES ('a0000000-0000-4000-8000-000000000011'::uuid, '42000000-0000-4000-8000-000000000006'::uuid);

-- Expired assignment: valid window already closed. assigned_at must precede
-- valid_from per chk_user_platform_role_assignments_assignment_time.
INSERT INTO public.user_platform_role_assignments (user_id, role_id, assigned_at, valid_from, valid_until)
VALUES (
    'a0000000-0000-4000-8000-000000000012'::uuid,
    '42000000-0000-4000-8000-000000000006'::uuid,
    now() - interval '11 days',
    now() - interval '10 days',
    now() - interval '1 day'
);

-- Revoked assignment: still inside its original validity window, but revoked.
INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES ('a0000000-0000-4000-8000-000000000013'::uuid, '42000000-0000-4000-8000-000000000006'::uuid);

UPDATE public.user_platform_role_assignments
SET revoked_at = now()
WHERE user_id = 'a0000000-0000-4000-8000-000000000013'::uuid;

-- Active-assignment holder: both functions return true for the held role/permission,
-- and has_active_platform_role correctly returns false for a role not held.
SET LOCAL request.jwt.claim.sub = 'a0000000-0000-4000-8000-000000000011';

SELECT ok(
    public.has_active_platform_role('REPORTING_VIEWER'),
    'has_active_platform_role returns true for an active, unexpired, unrevoked assignment'
);
SELECT ok(
    public.has_active_platform_permission('REPORTING_READ'),
    'has_active_platform_permission returns true for a permission reachable through an active role'
);
SELECT ok(
    NOT public.has_active_platform_role('PLATFORM_ADMINISTRATOR'),
    'has_active_platform_role returns false for a role the user does not hold'
);

-- Expired assignment: treated as not active by both functions.
SET LOCAL request.jwt.claim.sub = 'a0000000-0000-4000-8000-000000000012';

SELECT ok(
    NOT public.has_active_platform_role('REPORTING_VIEWER'),
    'has_active_platform_role returns false once valid_until has passed'
);
SELECT ok(
    NOT public.has_active_platform_permission('REPORTING_READ'),
    'has_active_platform_permission returns false for an expired assignment'
);

-- Revoked assignment: treated as not active by both functions even though valid_until
-- has not yet been reached.
SET LOCAL request.jwt.claim.sub = 'a0000000-0000-4000-8000-000000000013';

SELECT ok(
    NOT public.has_active_platform_role('REPORTING_VIEWER'),
    'has_active_platform_role returns false for a revoked assignment even within its original validity window'
);
SELECT ok(
    NOT public.has_active_platform_permission('REPORTING_READ'),
    'has_active_platform_permission returns false for a revoked assignment'
);

-- No assignment at all.
SET LOCAL request.jwt.claim.sub = 'a0000000-0000-4000-8000-000000000014';

SELECT ok(
    NOT public.has_active_platform_role('REPORTING_VIEWER'),
    'has_active_platform_role returns false for a user with no assignment at all'
);

SELECT * FROM finish();

ROLLBACK;
