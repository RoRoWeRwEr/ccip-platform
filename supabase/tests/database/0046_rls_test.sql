-- Migration 0046 — catalog_source_provenance authorization and RLS coverage.
BEGIN;

SELECT plan(19);

SELECT ok(
    (SELECT relrowsecurity FROM pg_catalog.pg_class WHERE oid = 'public.catalog_source_provenance'::regclass),
    'row-level security is enabled on catalog_source_provenance'
);

INSERT INTO auth.users (id, email) VALUES
    ('a4600000-0000-4000-8000-000000000001', 'provenance-admin@example.invalid'),
    ('a4600000-0000-4000-8000-000000000002', 'provenance-user@example.invalid'),
    ('a4600000-0000-4000-8000-000000000003', 'provenance-expired-admin@example.invalid'),
    ('a4600000-0000-4000-8000-000000000004', 'provenance-revoked-admin@example.invalid'),
    ('a4600000-0000-4000-8000-000000000005', 'provenance-platform-admin@example.invalid');

-- Active CATALOG_ADMINISTRATOR.
INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES ('a4600000-0000-4000-8000-000000000001'::uuid, '42000000-0000-4000-8000-000000000002'::uuid);

-- Expired CATALOG_ADMINISTRATOR assignment.
INSERT INTO public.user_platform_role_assignments (user_id, role_id, assigned_at, valid_from, valid_until)
VALUES (
    'a4600000-0000-4000-8000-000000000003'::uuid, '42000000-0000-4000-8000-000000000002'::uuid,
    now() - interval '3 days', now() - interval '2 days', now() - interval '1 day'
);

-- Revoked CATALOG_ADMINISTRATOR assignment (still within its original window).
INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES ('a4600000-0000-4000-8000-000000000004'::uuid, '42000000-0000-4000-8000-000000000002'::uuid);
UPDATE public.user_platform_role_assignments
SET revoked_at = now()
WHERE user_id = 'a4600000-0000-4000-8000-000000000004'::uuid;

-- PLATFORM_ADMINISTRATOR also carries CATALOG_MANAGE via its permission mapping.
INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES ('a4600000-0000-4000-8000-000000000005'::uuid, '42000000-0000-4000-8000-000000000001'::uuid);

INSERT INTO public.countries (id, code, slug, name_en, name_ar) VALUES
    ('c4600000-0000-4000-8000-000000000001', 'SA', 'saudi-arabia-46', 'Saudi Arabia', 'السعودية');
INSERT INTO public.banks (id, country_id, slug, name_en, name_ar) VALUES
    ('b4600000-0000-4000-8000-000000000001', 'c4600000-0000-4000-8000-000000000001', 'test-bank-46', 'Test Bank', 'بنك تجريبي');

-- 4. Valid creation by an authorized administrator.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4600000-0000-4000-8000-000000000001';

SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance
        (id, target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES (
        '46000000-0000-4000-8000-000000000001', 'BANK', 'b4600000-0000-4000-8000-000000000001',
        'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://test-bank.example/about', 'About Test Bank', 'Test Bank'
      )$$,
    'an active catalog administrator can create a provenance record'
);
SELECT is(
    (SELECT count(*)::integer FROM public.catalog_source_provenance),
    1,
    'an active catalog administrator can read the created record through RLS'
);

RESET ROLE;
SELECT ok(
    (SELECT created_by_user_id = 'a4600000-0000-4000-8000-000000000001'::uuid
     FROM public.catalog_source_provenance WHERE id = '46000000-0000-4000-8000-000000000001'),
    'administrator identity is stamped into created_by_user_id'
);

-- 6. Anonymous access rejection.
SET ROLE anon;
SELECT throws_ok(
    $$SELECT count(*) FROM public.catalog_source_provenance$$,
    '42501', NULL, 'anonymous callers receive no direct table access'
);
RESET ROLE;

-- 5. Unauthorized authenticated creation rejection.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4600000-0000-4000-8000-000000000002';

SELECT is(
    (SELECT count(*)::integer FROM public.catalog_source_provenance),
    0,
    'an unprivileged authenticated user cannot read provenance records'
);
SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('BANK', 'b4600000-0000-4000-8000-000000000001', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example', 't', 'o')$$,
    '42501', NULL, 'an unprivileged authenticated user cannot create a provenance record'
);
SELECT lives_ok(
    $$UPDATE public.catalog_source_provenance SET notes = 'unauthorized' WHERE id = '46000000-0000-4000-8000-000000000001'$$,
    'an unauthorized update affects no visible rows rather than bypassing RLS'
);

RESET ROLE;
SELECT ok(
    (SELECT notes IS NULL FROM public.catalog_source_provenance WHERE id = '46000000-0000-4000-8000-000000000001'),
    'the unauthorized update did not change the record'
);

-- 7. Revoked or expired administrator rejection.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4600000-0000-4000-8000-000000000003';
SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('BANK', 'b4600000-0000-4000-8000-000000000001', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/expired', 't', 'o')$$,
    '42501', NULL, 'an expired catalog administrator assignment no longer permits creation'
);

SET LOCAL request.jwt.claim.sub = 'a4600000-0000-4000-8000-000000000004';
SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('BANK', 'b4600000-0000-4000-8000-000000000001', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/revoked', 't', 'o')$$,
    '42501', NULL, 'a revoked catalog administrator assignment no longer permits creation'
);
RESET ROLE;

-- A PLATFORM_ADMINISTRATOR (via CATALOG_MANAGE permission mapping) is also authorized.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4600000-0000-4000-8000-000000000005';
SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('BANK', 'b4600000-0000-4000-8000-000000000001', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/platform-admin', 't', 'o')$$,
    'a platform administrator (holding CATALOG_MANAGE) can also create a provenance record'
);
RESET ROLE;

-- 16. RLS update behavior for the authorized administrator.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4600000-0000-4000-8000-000000000001';
SELECT lives_ok(
    $$UPDATE public.catalog_source_provenance SET notes = 'reviewed' WHERE id = '46000000-0000-4000-8000-000000000001'$$,
    'an active catalog administrator can update a provenance record'
);
RESET ROLE;

-- 16. No DELETE grant/policy exists for authenticated administrators.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4600000-0000-4000-8000-000000000001';
SELECT throws_ok(
    $$DELETE FROM public.catalog_source_provenance WHERE id = '46000000-0000-4000-8000-000000000001'$$,
    '42501', NULL, 'even an authorized catalog administrator cannot hard-delete a provenance record'
);
RESET ROLE;

-- 17. service_role behavior: full CRUD, RLS bypass via BYPASSRLS.
SET ROLE service_role;
SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance
        (id, target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES (
        '46000000-0000-4000-8000-000000000099', 'BANK', 'b4600000-0000-4000-8000-000000000001',
        'MANUAL_ENTRY_APPROVED', 'AUTHORIZED_SECONDARY', 'https://service-role.example', 'Service ingestion', 'System'
      )$$,
    'service_role can insert a provenance record'
);
SELECT lives_ok(
    $$DELETE FROM public.catalog_source_provenance WHERE id = '46000000-0000-4000-8000-000000000099'$$,
    'service_role can hard-delete a provenance record'
);
RESET ROLE;

-- 20. Function execution permissions: trigger-only functions are not directly callable.
SELECT ok(
    NOT has_function_privilege('anon', 'public.manage_catalog_source_provenance_change()', 'EXECUTE'),
    'anon cannot execute the management trigger function directly'
);
SELECT ok(
    NOT has_function_privilege('authenticated', 'public.manage_catalog_source_provenance_change()', 'EXECUTE'),
    'authenticated cannot execute the management trigger function directly'
);
SELECT ok(
    NOT has_function_privilege('authenticated', 'public.audit_catalog_source_provenance_change()', 'EXECUTE'),
    'authenticated cannot execute the audit trigger function directly'
);

SELECT * FROM finish();
ROLLBACK;
