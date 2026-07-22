-- Migration 0042 — scope constraint coverage.
--
-- Confirms user_platform_role_assignments accepts PLATFORM scope only,
-- rejects BANK / COUNTRY / FUNCTIONAL_AREA outright, and still enforces
-- the pre-existing overlapping-active-assignment exclusion constraint.
BEGIN;

SELECT plan(6);

INSERT INTO auth.users (id, email) VALUES
    ('a0000000-0000-4000-8000-000000000001', 'scope-test-1@example.invalid'),
    ('a0000000-0000-4000-8000-000000000002', 'scope-test-2@example.invalid');

-- PLATFORM scope with no scope_reference is the only supported shape and must succeed.
SELECT lives_ok(
    $$INSERT INTO public.user_platform_role_assignments (user_id, role_id)
      VALUES ('a0000000-0000-4000-8000-000000000001'::uuid, '42000000-0000-4000-8000-000000000005'::uuid)$$,
    'a PLATFORM-scoped assignment with no scope_reference is accepted'
);

-- BANK scope is rejected by chk_user_platform_role_assignments_scope.
SELECT throws_ok(
    $$INSERT INTO public.user_platform_role_assignments (user_id, role_id, scope_type, scope_reference)
      VALUES ('a0000000-0000-4000-8000-000000000002'::uuid, '42000000-0000-4000-8000-000000000005'::uuid, 'BANK', 'some-bank')$$,
    '23514',
    NULL,
    'a BANK-scoped assignment is rejected by the scope check constraint'
);

-- COUNTRY scope is rejected.
SELECT throws_ok(
    $$INSERT INTO public.user_platform_role_assignments (user_id, role_id, scope_type, scope_reference)
      VALUES ('a0000000-0000-4000-8000-000000000002'::uuid, '42000000-0000-4000-8000-000000000005'::uuid, 'COUNTRY', 'SA')$$,
    '23514',
    NULL,
    'a COUNTRY-scoped assignment is rejected by the scope check constraint'
);

-- FUNCTIONAL_AREA scope is rejected.
SELECT throws_ok(
    $$INSERT INTO public.user_platform_role_assignments (user_id, role_id, scope_type, scope_reference)
      VALUES ('a0000000-0000-4000-8000-000000000002'::uuid, '42000000-0000-4000-8000-000000000005'::uuid, 'FUNCTIONAL_AREA', 'ops')$$,
    '23514',
    NULL,
    'a FUNCTIONAL_AREA-scoped assignment is rejected by the scope check constraint'
);

-- PLATFORM scope with a non-null scope_reference is also rejected (both halves of the
-- constraint are enforced, not just the scope_type value).
SELECT throws_ok(
    $$INSERT INTO public.user_platform_role_assignments (user_id, role_id, scope_type, scope_reference)
      VALUES ('a0000000-0000-4000-8000-000000000002'::uuid, '42000000-0000-4000-8000-000000000005'::uuid, 'PLATFORM', 'unexpected')$$,
    '23514',
    NULL,
    'a PLATFORM-scoped assignment with a non-null scope_reference is rejected'
);

-- Overlapping active assignments of the same role to the same user are still rejected
-- (ex_user_platform_roles_active_window), unaffected by the scope restriction above.
SELECT throws_ok(
    $$INSERT INTO public.user_platform_role_assignments (user_id, role_id)
      VALUES ('a0000000-0000-4000-8000-000000000001'::uuid, '42000000-0000-4000-8000-000000000005'::uuid)$$,
    '23P01',
    NULL,
    'a second overlapping active assignment of the same role to the same user is rejected'
);

SELECT * FROM finish();

ROLLBACK;
