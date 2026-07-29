-- Migration 0047 — merchants and merchant-catalog child table authorization
-- and RLS coverage.
BEGIN;

SELECT plan(32);

SELECT ok(
    (SELECT relrowsecurity FROM pg_catalog.pg_class WHERE oid = 'public.merchants'::regclass),
    'row-level security is enabled on merchants'
);
SELECT ok(
    (SELECT relrowsecurity FROM pg_catalog.pg_class WHERE oid = 'public.merchant_aliases'::regclass),
    'row-level security is enabled on merchant_aliases'
);
SELECT ok(
    (SELECT relrowsecurity FROM pg_catalog.pg_class WHERE oid = 'public.merchant_relationships'::regclass),
    'row-level security is enabled on merchant_relationships'
);
SELECT ok(
    (SELECT relrowsecurity FROM pg_catalog.pg_class WHERE oid = 'public.merchant_category_assignments'::regclass),
    'row-level security is enabled on merchant_category_assignments'
);
SELECT ok(
    (SELECT relrowsecurity FROM pg_catalog.pg_class WHERE oid = 'public.merchant_market_presence'::regclass),
    'row-level security is enabled on merchant_market_presence'
);
SELECT ok(
    (SELECT relrowsecurity FROM pg_catalog.pg_class WHERE oid = 'public.merchant_domains'::regclass),
    'row-level security is enabled on merchant_domains'
);

INSERT INTO auth.users (id, email) VALUES
    ('a4730000-0000-4000-8000-000000000001', 'merchant-admin@example.invalid'),
    ('a4730000-0000-4000-8000-000000000002', 'merchant-user@example.invalid'),
    ('a4730000-0000-4000-8000-000000000003', 'merchant-expired-admin@example.invalid'),
    ('a4730000-0000-4000-8000-000000000004', 'merchant-revoked-admin@example.invalid'),
    ('a4730000-0000-4000-8000-000000000005', 'merchant-platform-admin@example.invalid');

-- Active CATALOG_ADMINISTRATOR.
INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES ('a4730000-0000-4000-8000-000000000001'::uuid, '42000000-0000-4000-8000-000000000002'::uuid);

-- Expired CATALOG_ADMINISTRATOR assignment.
INSERT INTO public.user_platform_role_assignments (user_id, role_id, assigned_at, valid_from, valid_until)
VALUES (
    'a4730000-0000-4000-8000-000000000003'::uuid, '42000000-0000-4000-8000-000000000002'::uuid,
    now() - interval '3 days', now() - interval '2 days', now() - interval '1 day'
);

-- Revoked CATALOG_ADMINISTRATOR assignment.
INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES ('a4730000-0000-4000-8000-000000000004'::uuid, '42000000-0000-4000-8000-000000000002'::uuid);
UPDATE public.user_platform_role_assignments
SET revoked_at = now()
WHERE user_id = 'a4730000-0000-4000-8000-000000000004'::uuid;

-- PLATFORM_ADMINISTRATOR also carries CATALOG_MANAGE via its permission mapping.
INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES ('a4730000-0000-4000-8000-000000000005'::uuid, '42000000-0000-4000-8000-000000000001'::uuid);

-- 30. Authorized catalog-administrator management.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4730000-0000-4000-8000-000000000001';

SELECT lives_ok(
    $$INSERT INTO public.merchants (id, slug, display_name_en, display_name_ar)
      VALUES ('47300000-0000-4000-8000-000000000001', 'rls-merchant-4730', 'RLS Merchant', 'تاجر آر إل إس')$$,
    'an active catalog administrator can create a merchant'
);

RESET ROLE;
SELECT ok(
    (SELECT created_by_user_id = 'a4730000-0000-4000-8000-000000000001'::uuid
     FROM public.merchants WHERE id = '47300000-0000-4000-8000-000000000001'),
    'administrator identity is stamped into created_by_user_id'
);

-- 33. Anonymous callers may read active/published merchants but not manage them.
SET ROLE anon;
SELECT is(
    (SELECT count(*)::integer FROM public.merchants WHERE id = '47300000-0000-4000-8000-000000000001'),
    1,
    'anonymous callers can read an ACTIVE merchant'
);
SELECT throws_ok(
    $$INSERT INTO public.merchants (slug, display_name_en, display_name_ar) VALUES ('anon-attempt-4730', 'x', 'س')$$,
    '42501', NULL, 'anonymous callers cannot create a merchant'
);
RESET ROLE;

-- 32. Unauthorized authenticated-user rejection (read active catalog, but no write).
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4730000-0000-4000-8000-000000000002';
SELECT is(
    (SELECT count(*)::integer FROM public.merchants WHERE id = '47300000-0000-4000-8000-000000000001'),
    1,
    'an unprivileged authenticated user can still read an ACTIVE merchant'
);
SELECT throws_ok(
    $$INSERT INTO public.merchants (slug, display_name_en, display_name_ar) VALUES ('unauthorized-attempt-4730', 'x', 'س')$$,
    '42501', NULL, 'an unprivileged authenticated user cannot create a merchant'
);
RESET ROLE;

-- 35. Expired administrator rejection.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4730000-0000-4000-8000-000000000003';
SELECT throws_ok(
    $$INSERT INTO public.merchants (slug, display_name_en, display_name_ar) VALUES ('expired-attempt-4730', 'x', 'س')$$,
    '42501', NULL, 'an expired catalog administrator assignment no longer permits creation'
);
RESET ROLE;

-- 34. Revoked administrator rejection.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4730000-0000-4000-8000-000000000004';
SELECT throws_ok(
    $$INSERT INTO public.merchants (slug, display_name_en, display_name_ar) VALUES ('revoked-attempt-4730', 'x', 'س')$$,
    '42501', NULL, 'a revoked catalog administrator assignment no longer permits creation'
);
RESET ROLE;

-- 31. Platform-administrator management (via CATALOG_MANAGE permission mapping).
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4730000-0000-4000-8000-000000000005';
SELECT lives_ok(
    $$INSERT INTO public.merchants (id, slug, display_name_en, display_name_ar)
      VALUES ('47300000-0000-4000-8000-000000000002', 'platform-admin-merchant-4730', 'Platform Admin Merchant', 'تاجر مدير المنصة')$$,
    'a platform administrator (holding CATALOG_MANAGE) can also create a merchant'
);
RESET ROLE;

-- 37. UPDATE and DELETE RLS behavior for the authorized administrator.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4730000-0000-4000-8000-000000000001';
SELECT lives_ok(
    $$UPDATE public.merchants SET description_en = 'reviewed' WHERE id = '47300000-0000-4000-8000-000000000001'$$,
    'an active catalog administrator can update a merchant'
);
SELECT throws_ok(
    $$DELETE FROM public.merchants WHERE id = '47300000-0000-4000-8000-000000000001'$$,
    '42501', NULL, 'even an authorized catalog administrator cannot hard-delete a merchant'
);

-- Child-table management by the same administrator.
SELECT lives_ok(
    $$INSERT INTO public.merchant_aliases (merchant_id, alias, alias_language)
      VALUES ('47300000-0000-4000-8000-000000000001', 'RLS Merchant Alias', 'en')$$,
    'an authorized catalog administrator can create a merchant alias'
);
RESET ROLE;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4730000-0000-4000-8000-000000000002';
SELECT throws_ok(
    $$INSERT INTO public.merchant_aliases (merchant_id, alias, alias_language)
      VALUES ('47300000-0000-4000-8000-000000000001', 'Unauthorized Alias', 'en')$$,
    '42501', NULL, 'an unprivileged authenticated user cannot create a merchant alias'
);
SELECT is(
    (SELECT count(*)::integer FROM public.merchant_aliases WHERE merchant_id = '47300000-0000-4000-8000-000000000001'),
    1,
    'an unprivileged authenticated user can still read the alias of an ACTIVE merchant'
);
RESET ROLE;

-- 36. service_role behavior: full CRUD, RLS bypass via BYPASSRLS.
SET ROLE service_role;
SELECT lives_ok(
    $$INSERT INTO public.merchants (id, slug, display_name_en, display_name_ar)
      VALUES ('47300000-0000-4000-8000-000000000099', 'service-role-merchant-4730', 'Service Role Merchant', 'تاجر دور الخدمة')$$,
    'service_role can insert a merchant'
);
SELECT lives_ok(
    $$DELETE FROM public.merchants WHERE id = '47300000-0000-4000-8000-000000000099'$$,
    'service_role can hard-delete a merchant'
);
RESET ROLE;

-- 39. Function execution permissions: trigger-only functions are not directly callable.
SELECT ok(
    NOT has_function_privilege('anon', 'public.manage_merchant_change()', 'EXECUTE'),
    'anon cannot execute the merchant management trigger function directly'
);
SELECT ok(
    NOT has_function_privilege('authenticated', 'public.manage_merchant_change()', 'EXECUTE'),
    'authenticated cannot execute the merchant management trigger function directly'
);
SELECT ok(
    NOT has_function_privilege('authenticated', 'public.manage_merchant_child_change()', 'EXECUTE'),
    'authenticated cannot execute the merchant child management trigger function directly'
);
SELECT ok(
    NOT has_function_privilege('authenticated', 'public.audit_merchant_catalog_change()', 'EXECUTE'),
    'authenticated cannot execute the merchant audit trigger function directly'
);
SELECT ok(
    NOT has_function_privilege('authenticated', 'public.sync_catalog_source_provenance_target_entity_id()', 'EXECUTE'),
    'authenticated cannot execute the provenance sync trigger function directly'
);

-- 40. SECURITY DEFINER safety properties.
SELECT ok(
    (SELECT prosecdef FROM pg_catalog.pg_proc WHERE oid = 'public.audit_merchant_catalog_change()'::regprocedure),
    'audit_merchant_catalog_change is SECURITY DEFINER'
);
SELECT ok(
    (SELECT proconfig @> ARRAY['search_path=pg_catalog']
     FROM pg_catalog.pg_proc WHERE oid = 'public.audit_merchant_catalog_change()'::regprocedure),
    'audit_merchant_catalog_change pins search_path to pg_catalog'
);
SELECT ok(
    NOT (SELECT prosecdef FROM pg_catalog.pg_proc WHERE oid = 'public.manage_merchant_change()'::regprocedure),
    'manage_merchant_change is SECURITY INVOKER, not SECURITY DEFINER'
);
SELECT ok(
    NOT (SELECT prosecdef FROM pg_catalog.pg_proc WHERE oid = 'public.manage_merchant_child_change()'::regprocedure),
    'manage_merchant_child_change is SECURITY INVOKER, not SECURITY DEFINER'
);
SELECT ok(
    NOT (SELECT prosecdef FROM pg_catalog.pg_proc WHERE oid = 'public.sync_catalog_source_provenance_target_entity_id()'::regprocedure),
    'sync_catalog_source_provenance_target_entity_id is SECURITY INVOKER, not SECURITY DEFINER'
);

SELECT * FROM finish();
ROLLBACK;
