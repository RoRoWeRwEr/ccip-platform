BEGIN;

SELECT plan(15);

SELECT has_function('public', 'bootstrap_user_profile', ARRAY[]::TEXT[],
    'profile bootstrap function exists');
SELECT function_returns('public', 'bootstrap_user_profile', ARRAY[]::TEXT[], 'trigger',
    'profile bootstrap is a trigger function');
SELECT ok((
    SELECT prosecdef AND proconfig @> ARRAY['search_path=pg_catalog']
    FROM pg_catalog.pg_proc
    WHERE oid = 'public.bootstrap_user_profile()'::regprocedure
), 'profile bootstrap is hardened SECURITY DEFINER');
SELECT ok(NOT has_function_privilege('public', 'public.bootstrap_user_profile()', 'EXECUTE'),
    'PUBLIC cannot execute profile bootstrap');
SELECT ok(NOT has_function_privilege('anon', 'public.bootstrap_user_profile()', 'EXECUTE'),
    'anon cannot execute profile bootstrap');
SELECT ok(NOT has_function_privilege('authenticated', 'public.bootstrap_user_profile()', 'EXECUTE'),
    'authenticated cannot execute profile bootstrap');
SELECT has_trigger('auth', 'users', 'trg_auth_users_bootstrap_profile',
    'auth user profile bootstrap trigger exists');
SELECT ok(NOT has_table_privilege('authenticated', 'public.user_profiles', 'INSERT'),
    'authenticated retains no direct profile insert grant');

INSERT INTO auth.users (id, email) VALUES
    ('53000000-0000-4000-8000-000000000001', 'profile-one@example.invalid'),
    ('53000000-0000-4000-8000-000000000002', 'profile-two@example.invalid');

SELECT is((
    SELECT count(*)::INTEGER
    FROM public.user_profiles
    WHERE user_id IN (
        '53000000-0000-4000-8000-000000000001',
        '53000000-0000-4000-8000-000000000002'
    )
), 2, 'new auth users receive exactly one profile each');
SELECT is((SELECT account_status FROM public.user_profiles
    WHERE user_id = '53000000-0000-4000-8000-000000000001'), 'ACTIVE',
    'bootstrapped profile uses active account default');
SELECT is((SELECT onboarding_status FROM public.user_profiles
    WHERE user_id = '53000000-0000-4000-8000-000000000001'), 'NOT_STARTED',
    'bootstrapped profile starts onboarding safely');
SELECT is((SELECT preferred_language_code FROM public.user_profiles
    WHERE user_id = '53000000-0000-4000-8000-000000000001'), 'en',
    'bootstrap does not infer language from untrusted metadata');

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = '53000000-0000-4000-8000-000000000001';
SELECT is((SELECT count(*)::INTEGER FROM public.user_profiles), 1,
    'authenticated user sees only their own profile');
UPDATE public.user_profiles SET display_name = 'Profile One'
WHERE user_id = '53000000-0000-4000-8000-000000000001';
SELECT is((SELECT display_name FROM public.user_profiles), 'Profile One',
    'owner can update an allowed profile field');
SELECT throws_ok(
    $$UPDATE public.user_profiles SET account_status = 'SUSPENDED'$$,
    '42501',
    'permission denied for table user_profiles',
    'owner cannot escalate protected account state'
);
RESET ROLE;

SELECT * FROM finish();
ROLLBACK;
