-- Migration 0043 — administrator-only management and RLS coverage.
BEGIN;

SELECT plan(10);

INSERT INTO auth.users (id, email) VALUES
    ('a3000000-0000-4000-8000-000000000001', 'flag-admin@example.invalid'),
    ('a3000000-0000-4000-8000-000000000002', 'flag-user@example.invalid'),
    ('a3000000-0000-4000-8000-000000000003', 'flag-expired-admin@example.invalid'),
    ('a3000000-0000-4000-8000-000000000004', 'flag-revoked-admin@example.invalid');

INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES (
    'a3000000-0000-4000-8000-000000000001'::uuid,
    '42000000-0000-4000-8000-000000000001'::uuid
);

INSERT INTO public.user_platform_role_assignments (
    user_id, role_id, assigned_at, valid_from, valid_until
) VALUES (
    'a3000000-0000-4000-8000-000000000003'::uuid,
    '42000000-0000-4000-8000-000000000001'::uuid,
    now() - interval '3 days', now() - interval '2 days', now() - interval '1 day'
);

INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES (
    'a3000000-0000-4000-8000-000000000004'::uuid,
    '42000000-0000-4000-8000-000000000001'::uuid
);
UPDATE public.user_platform_role_assignments
SET revoked_at = now()
WHERE user_id = 'a3000000-0000-4000-8000-000000000004'::uuid;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a3000000-0000-4000-8000-000000000001';

SELECT lives_ok(
    $$INSERT INTO public.feature_flags
        (flag_key, display_name, lifecycle_status, administrative_reason)
      VALUES ('tests.admin-created', 'Admin created', 'ACTIVE', 'RLS positive path')$$,
    'an active platform administrator can create a flag'
);
SELECT is(
    (SELECT count(*)::integer FROM public.feature_flags WHERE flag_key = 'tests.admin-created'),
    1,
    'an active platform administrator can read the created flag through RLS'
);
SELECT lives_ok(
    $$UPDATE public.feature_flags
      SET default_enabled = TRUE, administrative_reason = 'RLS positive update'
      WHERE flag_key = 'tests.admin-created'$$,
    'an active platform administrator can update a flag'
);

RESET ROLE;
SELECT ok(
    (SELECT created_by_user_id = 'a3000000-0000-4000-8000-000000000001'::uuid
         AND updated_by_user_id = 'a3000000-0000-4000-8000-000000000001'::uuid
     FROM public.feature_flags WHERE flag_key = 'tests.admin-created'),
    'administrator identity is stamped into protected creation and update fields'
);

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a3000000-0000-4000-8000-000000000002';

SELECT throws_ok(
    $$INSERT INTO public.feature_flags (flag_key, display_name, administrative_reason)
      VALUES ('tests.unauthorized', 'Unauthorized', 'negative path')$$,
    '42501', NULL, 'an unprivileged authenticated user cannot create a flag'
);
SELECT is(
    (SELECT count(*)::integer FROM public.feature_flags),
    0,
    'an unprivileged authenticated user cannot read flag definitions'
);
SELECT lives_ok(
    $$UPDATE public.feature_flags SET default_enabled = FALSE
      WHERE flag_key = 'tests.admin-created'$$,
    'an unauthorized update affects no visible rows rather than bypassing RLS'
);

RESET ROLE;
SELECT ok(
    (SELECT default_enabled FROM public.feature_flags WHERE flag_key = 'tests.admin-created'),
    'the unauthorized update did not change the flag'
);

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a3000000-0000-4000-8000-000000000003';
SELECT throws_ok(
    $$INSERT INTO public.feature_flags (flag_key, display_name, administrative_reason)
      VALUES ('tests.expired-admin', 'Expired admin', 'negative path')$$,
    '42501', NULL, 'an expired administrator assignment no longer permits creation'
);

SET LOCAL request.jwt.claim.sub = 'a3000000-0000-4000-8000-000000000004';
SELECT throws_ok(
    $$INSERT INTO public.feature_flags (flag_key, display_name, administrative_reason)
      VALUES ('tests.revoked-admin', 'Revoked admin', 'negative path')$$,
    '42501', NULL, 'a revoked administrator assignment no longer permits creation'
);

RESET ROLE;
SELECT * FROM finish();
ROLLBACK;
