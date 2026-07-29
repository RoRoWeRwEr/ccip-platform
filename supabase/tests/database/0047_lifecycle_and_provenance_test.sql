-- Migration 0047 — merchant lifecycle/verification transitions, historical
-- preservation, provenance integration (migration 0046 extension), and
-- audit-event coverage.
BEGIN;

SELECT plan(25);

INSERT INTO auth.users (id, email) VALUES
    ('a4720000-0000-4000-8000-000000000001', 'merchant-admin-4720@example.invalid');
INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES ('a4720000-0000-4000-8000-000000000001'::uuid, '42000000-0000-4000-8000-000000000002'::uuid);

INSERT INTO public.countries (id, code, slug, name_en, name_ar) VALUES
    ('c4720000-0000-4000-8000-000000000001', 'SA', 'saudi-arabia-4720', 'Saudi Arabia', 'السعودية');
INSERT INTO public.banks (id, country_id, slug, name_en, name_ar) VALUES
    ('b4720000-0000-4000-8000-000000000001', 'c4720000-0000-4000-8000-000000000001', 'test-bank-4720', 'Test Bank', 'بنك تجريبي');
INSERT INTO public.merchant_categories (id, code, slug, name_en, name_ar) VALUES
    ('4a720000-0000-4000-8000-000000000001', '5411', 'grocery-4720', 'Grocery', 'بقالة');

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4720000-0000-4000-8000-000000000001';

INSERT INTO public.merchants (id, slug, display_name_en, display_name_ar)
VALUES ('47200000-0000-4000-8000-000000000001', 'lifecycle-merchant-4720', 'Lifecycle Merchant', 'تاجر دورة الحياة');

-- 23. Lifecycle transition validation: ACTIVE -> INACTIVE -> ACTIVE is reversible.
SELECT lives_ok(
    $$UPDATE public.merchants SET lifecycle_status = 'INACTIVE' WHERE id = '47200000-0000-4000-8000-000000000001'$$,
    'ACTIVE to INACTIVE is a valid transition'
);
SELECT lives_ok(
    $$UPDATE public.merchants SET lifecycle_status = 'ACTIVE' WHERE id = '47200000-0000-4000-8000-000000000001'$$,
    'INACTIVE back to ACTIVE is a valid transition'
);

-- 24. Verification-status transition validation.
UPDATE public.merchants SET verification_status = 'VERIFIED' WHERE id = '47200000-0000-4000-8000-000000000001';
SELECT ok(
    (SELECT verification_status = 'VERIFIED' AND verified_at IS NOT NULL AND verified_by_user_id IS NOT NULL
     FROM public.merchants WHERE id = '47200000-0000-4000-8000-000000000001'),
    'transitioning to VERIFIED stamps verified_at and verified_by_user_id'
);
SELECT throws_ok(
    $$UPDATE public.merchants SET verification_status = 'UNVERIFIED' WHERE id = '47200000-0000-4000-8000-000000000001'$$,
    '23514', NULL, 'reverting a VERIFIED merchant to UNVERIFIED is rejected'
);

-- 25. Archive/supersession behavior.
INSERT INTO public.merchants (id, slug, display_name_en, display_name_ar)
VALUES ('47200000-0000-4000-8000-000000000002', 'superseded-merchant-4720', 'Superseded Merchant', 'تاجر مدمج');
UPDATE public.merchants
SET lifecycle_status = 'SUPERSEDED', superseded_by_merchant_id = '47200000-0000-4000-8000-000000000001'
WHERE id = '47200000-0000-4000-8000-000000000002';
SELECT ok(
    (SELECT lifecycle_status = 'SUPERSEDED' AND superseded_at IS NOT NULL AND superseded_by_merchant_id = '47200000-0000-4000-8000-000000000001'
     FROM public.merchants WHERE id = '47200000-0000-4000-8000-000000000002'),
    'superseding a merchant stamps superseded_at and records the successor'
);
SELECT throws_ok(
    $$UPDATE public.merchants SET lifecycle_status = 'ACTIVE' WHERE id = '47200000-0000-4000-8000-000000000002'$$,
    '23514', NULL, 'reactivating a SUPERSEDED merchant is rejected'
);
UPDATE public.merchants SET lifecycle_status = 'ARCHIVED' WHERE id = '47200000-0000-4000-8000-000000000002';
SELECT throws_ok(
    $$UPDATE public.merchants SET description_en = 'edit attempt' WHERE id = '47200000-0000-4000-8000-000000000002'$$,
    '42501', NULL, 'an ARCHIVED merchant is immutable, including for the authorized administrator'
);

RESET ROLE;

-- 26. Historical reference preservation: superseded/archived merchants are retained, not deleted.
SELECT is(
    (SELECT count(*)::integer FROM public.merchants
     WHERE id IN ('47200000-0000-4000-8000-000000000001', '47200000-0000-4000-8000-000000000002')),
    2,
    'active and superseded/archived merchants are both preserved rather than removed'
);

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4720000-0000-4000-8000-000000000001';

-- 27. Merchant provenance integration (forward-compatible 0046 extension).
SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, merchant_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('MERCHANT', '47200000-0000-4000-8000-000000000001', 'MANUAL_ENTRY_APPROVED', 'AUTHORIZED_SECONDARY', 'https://x.example/merchant', 'Merchant evidence', 'Admin')$$,
    'a valid MERCHANT provenance record is accepted'
);
SELECT is(
    (SELECT target_entity_id FROM public.catalog_source_provenance
     WHERE target_entity_type = 'MERCHANT' AND merchant_id = '47200000-0000-4000-8000-000000000001'),
    '47200000-0000-4000-8000-000000000001'::uuid,
    'target_entity_id is synchronized to merchant_id for MERCHANT provenance rows'
);

-- 28. Missing-merchant provenance rejection: no merchant_id at all.
SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('MERCHANT', 'MANUAL_ENTRY_APPROVED', 'AUTHORIZED_SECONDARY', 'https://x.example/missing', 't', 'o')$$,
    '23514', NULL, 'a MERCHANT provenance row with no merchant_id is rejected'
);
-- Missing-merchant provenance rejection: a merchant_id that does not exist.
SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, merchant_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('MERCHANT', 'ffffffff-0000-4000-8000-000000000099', 'MANUAL_ENTRY_APPROVED', 'AUTHORIZED_SECONDARY', 'https://x.example/nonexistent', 't', 'o')$$,
    '23503', NULL, 'a reference to a non-existent merchant is rejected by the foreign key'
);

-- Merchant provenance may not set the optional successor pointer (documented,
-- deliberate limitation from 0046's fixed cross-record validation function).
INSERT INTO public.catalog_source_provenance
    (id, target_entity_type, merchant_id, source_type, authority_level, source_locator, source_title, source_owner)
VALUES ('47600000-0000-4000-8000-000000000001', 'MERCHANT', '47200000-0000-4000-8000-000000000001', 'MANUAL_ENTRY_APPROVED', 'AUTHORIZED_SECONDARY', 'https://x.example/successor-source', 't', 'o');
UPDATE public.catalog_source_provenance SET lifecycle_status = 'SUPERSEDED' WHERE id = '47600000-0000-4000-8000-000000000001';
SELECT throws_ok(
    $$UPDATE public.catalog_source_provenance
      SET superseded_by_provenance_id = '46000000-0000-4000-8000-000000000001'
      WHERE id = '47600000-0000-4000-8000-000000000001'$$,
    '23514', NULL, 'a MERCHANT provenance row may not set superseded_by_provenance_id'
);

-- 29. Existing migration 0046 entity types still work unchanged.
SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('BANK', 'b4720000-0000-4000-8000-000000000001', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/bank-4720', 't', 'o')$$,
    'a BANK provenance record (migration 0046 entity type) is still accepted'
);
SELECT is(
    (SELECT target_entity_id FROM public.catalog_source_provenance
     WHERE target_entity_type = 'BANK' AND bank_id = 'b4720000-0000-4000-8000-000000000001'),
    'b4720000-0000-4000-8000-000000000001'::uuid,
    'target_entity_id is still synchronized to bank_id for BANK provenance rows'
);

RESET ROLE;

-- Fixtures for the child-table audit assertions below.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4720000-0000-4000-8000-000000000001';
INSERT INTO public.merchant_aliases (id, merchant_id, alias, alias_language)
VALUES ('47100000-0000-4000-8000-000000004720', '47200000-0000-4000-8000-000000000001', 'Lifecycle Merchant Alias 4720', 'en');
INSERT INTO public.merchant_category_assignments (id, merchant_id, merchant_category_id)
VALUES ('47300000-0000-4000-8000-000000004720', '47200000-0000-4000-8000-000000000001', '4a720000-0000-4000-8000-000000000001');
INSERT INTO public.merchant_domains (id, merchant_id, domain)
VALUES ('47500000-0000-4000-8000-000000004720', '47200000-0000-4000-8000-000000000001', 'lifecycle-merchant-4720.example');
INSERT INTO public.merchants (id, slug, display_name_en, display_name_ar)
VALUES ('47200000-0000-4000-8000-000000000004', 'relationship-child-4720', 'Relationship Child', 'تاجر فرعي');
INSERT INTO public.merchant_relationships (id, parent_merchant_id, child_merchant_id, relationship_type)
VALUES ('47200000-0000-4000-8000-000000014720', '47200000-0000-4000-8000-000000000001', '47200000-0000-4000-8000-000000000004', 'PARENT_SUBSIDIARY');
RESET ROLE;

-- 38. Audit events for required actions.
SELECT ok(
    EXISTS (SELECT 1 FROM public.audit_events WHERE entity_type = 'merchants' AND entity_id = '47200000-0000-4000-8000-000000000001'::uuid AND event_action = 'CREATE'),
    'creating a merchant writes a CREATE audit event'
);
SELECT ok(
    EXISTS (SELECT 1 FROM public.audit_events WHERE entity_type = 'merchants' AND entity_id = '47200000-0000-4000-8000-000000000001'::uuid AND event_action = 'VERIFY'),
    'verifying a merchant writes a VERIFY audit event'
);
SELECT ok(
    EXISTS (SELECT 1 FROM public.audit_events WHERE entity_type = 'merchants' AND entity_id = '47200000-0000-4000-8000-000000000002'::uuid AND event_action = 'ARCHIVE'),
    'archiving a merchant writes an ARCHIVE audit event'
);
SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
        WHERE entity_type = 'merchant_aliases'
          AND parent_entity_type = 'merchant'
          AND event_action = 'CREATE'
    ),
    'creating a merchant alias writes a CREATE audit event linked to its parent merchant'
);
SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
        WHERE entity_type = 'merchant_category_assignments' AND event_action = 'CREATE'
    ),
    'creating a merchant category assignment writes a CREATE audit event'
);
SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
        WHERE entity_type = 'merchant_domains' AND event_action = 'CREATE'
    ),
    'creating a merchant domain writes a CREATE audit event'
);
SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
        WHERE entity_type = 'merchant_relationships' AND event_action = 'CREATE'
    ),
    'creating a merchant relationship (hierarchy change) writes a CREATE audit event'
);

-- Activation/deactivation audit coverage.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4720000-0000-4000-8000-000000000001';
INSERT INTO public.merchants (id, slug, display_name_en, display_name_ar)
VALUES ('47200000-0000-4000-8000-000000000003', 'toggle-merchant-4720', 'Toggle Merchant', 'تاجر التبديل');
UPDATE public.merchants SET lifecycle_status = 'INACTIVE' WHERE id = '47200000-0000-4000-8000-000000000003';
UPDATE public.merchants SET lifecycle_status = 'ACTIVE' WHERE id = '47200000-0000-4000-8000-000000000003';
RESET ROLE;

SELECT ok(
    EXISTS (SELECT 1 FROM public.audit_events WHERE entity_type = 'merchants' AND entity_id = '47200000-0000-4000-8000-000000000003'::uuid AND event_action = 'DEACTIVATE'),
    'deactivating a merchant writes a DEACTIVATE audit event'
);
SELECT ok(
    EXISTS (SELECT 1 FROM public.audit_events WHERE entity_type = 'merchants' AND entity_id = '47200000-0000-4000-8000-000000000003'::uuid AND event_action = 'ACTIVATE'),
    'reactivating a merchant writes an ACTIVATE audit event'
);

-- Deletion audit coverage (service_role only).
SET ROLE service_role;
INSERT INTO public.merchant_domains (id, merchant_id, domain)
VALUES ('47500000-0000-4000-8000-000000000001', '47200000-0000-4000-8000-000000000003', 'delete-target-4720.example');
DELETE FROM public.merchant_domains WHERE id = '47500000-0000-4000-8000-000000000001';
RESET ROLE;

SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
        WHERE entity_type = 'merchant_domains'
          AND entity_id = '47500000-0000-4000-8000-000000000001'::uuid
          AND event_action = 'DELETE'
          AND before_values IS NOT NULL
          AND after_values IS NULL
    ),
    'deleting a merchant domain writes a DELETE audit event using only the OLD row values'
);

SELECT * FROM finish();
ROLLBACK;
