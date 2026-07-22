-- Migration 0042 — RLS policy coverage for role assignment and profile updates.
--
-- Confirms: an administrator holding IDENTITY_ACCESS_MANAGE can create a
-- PLATFORM role assignment for another user; an unprivileged authenticated
-- user cannot, even when the target role id is already known to them (this
-- isolates the INSERT/WITH CHECK policy itself from read-side RLS on
-- platform_roles); and a user cannot modify a protected user_profiles
-- column on their own row while still being able to modify an
-- unprotected one.
BEGIN;

SELECT plan(5);

INSERT INTO auth.users (id, email) VALUES
    ('a0000000-0000-4000-8000-000000000021', 'rls-admin@example.invalid'),
    ('a0000000-0000-4000-8000-000000000022', 'rls-target@example.invalid'),
    ('a0000000-0000-4000-8000-000000000023', 'rls-unprivileged@example.invalid'),
    ('a0000000-0000-4000-8000-000000000024', 'rls-profile-owner@example.invalid');

-- Fixture: rls-admin already holds PLATFORM_ADMINISTRATOR (and therefore
-- IDENTITY_ACCESS_MANAGE via the seeded role-permission mapping).
INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES ('a0000000-0000-4000-8000-000000000021'::uuid, '42000000-0000-4000-8000-000000000001'::uuid);

-- Positive path: the administrator can create a PLATFORM assignment for someone else.
SET ROLE authenticated;
SET LOCAL app.current_uid = 'a0000000-0000-4000-8000-000000000021';

SELECT lives_ok(
    $$INSERT INTO public.user_platform_role_assignments (user_id, role_id)
      VALUES ('a0000000-0000-4000-8000-000000000022'::uuid, '42000000-0000-4000-8000-000000000005'::uuid)$$,
    'an authenticated user holding IDENTITY_ACCESS_MANAGE can create a PLATFORM role assignment for another user'
);

RESET ROLE;

SELECT ok(
    EXISTS (
        SELECT 1 FROM public.user_platform_role_assignments
        WHERE user_id = 'a0000000-0000-4000-8000-000000000022'::uuid
          AND role_id = '42000000-0000-4000-8000-000000000005'::uuid
    ),
    'the administrator-created assignment is actually persisted'
);

-- Negative path: an unprivileged authenticated user cannot self-assign a role,
-- even with the role id supplied directly (not looked up through RLS-filtered reads).
SET ROLE authenticated;
SET LOCAL app.current_uid = 'a0000000-0000-4000-8000-000000000023';

SELECT throws_ok(
    $$INSERT INTO public.user_platform_role_assignments (user_id, role_id)
      VALUES ('a0000000-0000-4000-8000-000000000023'::uuid, '42000000-0000-4000-8000-000000000005'::uuid)$$,
    '42501',
    NULL,
    'an unprivileged authenticated user cannot self-assign a platform role'
);

RESET ROLE;

-- Protected user_profiles columns: the owner cannot change account_status on their own row,
-- but can still update an ordinary self-service column.
INSERT INTO public.user_profiles (id, user_id)
VALUES (gen_random_uuid(), 'a0000000-0000-4000-8000-000000000024'::uuid);

SET ROLE authenticated;
SET LOCAL app.current_uid = 'a0000000-0000-4000-8000-000000000024';

SELECT throws_ok(
    $$UPDATE public.user_profiles SET account_status = 'SUSPENDED'
      WHERE user_id = 'a0000000-0000-4000-8000-000000000024'::uuid$$,
    '42501',
    NULL,
    'an authenticated user cannot modify the protected account_status column on their own profile'
);

SELECT lives_ok(
    $$UPDATE public.user_profiles SET display_name = 'Updated Name'
      WHERE user_id = 'a0000000-0000-4000-8000-000000000024'::uuid$$,
    'the same user can update a non-protected column (display_name) on their own profile'
);

RESET ROLE;

SELECT * FROM finish();

ROLLBACK;
