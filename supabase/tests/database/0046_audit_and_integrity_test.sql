-- Migration 0046 — catalog_source_provenance target integrity, lifecycle,
-- verification, audit, and historical-preservation coverage.
BEGIN;

SELECT plan(24);

INSERT INTO auth.users (id, email) VALUES
    ('a4610000-0000-4000-8000-000000000001', 'provenance-admin-2@example.invalid');
INSERT INTO public.user_platform_role_assignments (user_id, role_id)
VALUES ('a4610000-0000-4000-8000-000000000001'::uuid, '42000000-0000-4000-8000-000000000002'::uuid);

INSERT INTO public.countries (id, code, slug, name_en, name_ar) VALUES
    ('c4610000-0000-4000-8000-000000000001', 'SA', 'saudi-arabia-461', 'Saudi Arabia', 'السعودية');
INSERT INTO public.banks (id, country_id, slug, name_en, name_ar) VALUES
    ('b4610000-0000-4000-8000-000000000001', 'c4610000-0000-4000-8000-000000000001', 'test-bank-461', 'Test Bank', 'بنك تجريبي');
INSERT INTO public.card_networks (id, slug, name_en, name_ar) VALUES
    ('e4610000-0000-4000-8000-000000000001', 'test-net-461', 'Test Network', 'شبكة تجريبية');
INSERT INTO public.currencies (id, code, slug, name_en, name_ar, symbol) VALUES
    ('f4610000-0000-4000-8000-000000000001', 'SAR', 'saudi-riyal-461', 'Saudi Riyal', 'ريال سعودي', 'SAR');
INSERT INTO public.cards (id, bank_id, card_network_id, currency_id, slug, name_en, name_ar) VALUES
    ('d4610000-0000-4000-8000-000000000001', 'b4610000-0000-4000-8000-000000000001',
     'e4610000-0000-4000-8000-000000000001', 'f4610000-0000-4000-8000-000000000001',
     'test-card-461', 'Test Card', 'بطاقة تجريبية');
INSERT INTO public.card_fees (id, card_id, fee_type, name_en, name_ar, amount) VALUES
    ('11610000-0000-4000-8000-000000000001', 'd4610000-0000-4000-8000-000000000001', 'ANNUAL', 'Annual fee', 'رسوم سنوية', 500);
INSERT INTO public.card_benefits (id, card_id, slug, name_en, name_ar) VALUES
    ('12610000-0000-4000-8000-000000000001', 'd4610000-0000-4000-8000-000000000001', 'test-benefit', 'Test benefit', 'ميزة تجريبية');
INSERT INTO public.reward_categories (id, slug, name_en, name_ar) VALUES
    ('13610000-0000-4000-8000-000000000001', 'test-reward-cat-461', 'Test reward category', 'فئة مكافأة تجريبية');
INSERT INTO public.reward_rules (id, card_id, reward_type, calculation_method, reward_value) VALUES
    ('14610000-0000-4000-8000-000000000001', 'd4610000-0000-4000-8000-000000000001', 'CASHBACK', 'PERCENTAGE', 1.5);
INSERT INTO public.loyalty_programs (id, slug, name_en, name_ar, type) VALUES
    ('15610000-0000-4000-8000-000000000001', 'test-loyalty-461', 'Test Loyalty', 'ولاء تجريبي', 'BANK_POINTS');
INSERT INTO public.card_eligibility_requirements (id, card_id, requirement_type, name_en, name_ar, minimum_amount, currency_id) VALUES
    ('16610000-0000-4000-8000-000000000001', 'd4610000-0000-4000-8000-000000000001', 'MINIMUM_SALARY', 'Minimum salary', 'الحد الأدنى للراتب', 5000, 'f4610000-0000-4000-8000-000000000001');

INSERT INTO public.catalog_administrator_scope_assignments
    (role_assignment_id, scope_type, assignment_reason)
SELECT id, 'GLOBAL', '0046 integrity regression coverage'
FROM public.user_platform_role_assignments
WHERE user_id = 'a4610000-0000-4000-8000-000000000001';

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4610000-0000-4000-8000-000000000001';

-- 8. Valid supported target references for all seven eligible entity types.
SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance (target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('BANK', 'b4610000-0000-4000-8000-000000000001', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/bank', 't', 'o')$$,
    'a valid BANK provenance record is accepted'
);
SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance (target_entity_type, card_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('CARD', 'd4610000-0000-4000-8000-000000000001', 'OFFICIAL_PRODUCT_PAGE', 'OFFICIAL_PRIMARY', 'https://x.example/card', 't', 'o')$$,
    'a valid CARD provenance record is accepted'
);
SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance (target_entity_type, card_fee_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('CARD_FEE', '11610000-0000-4000-8000-000000000001', 'OFFICIAL_FEE_SCHEDULE', 'OFFICIAL_PRIMARY', 'https://x.example/fee', 't', 'o')$$,
    'a valid CARD_FEE provenance record is accepted'
);
SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance (target_entity_type, card_benefit_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('CARD_BENEFIT', '12610000-0000-4000-8000-000000000001', 'OFFICIAL_TERMS_AND_CONDITIONS', 'OFFICIAL_PRIMARY', 'https://x.example/benefit', 't', 'o')$$,
    'a valid CARD_BENEFIT provenance record is accepted'
);
SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance (target_entity_type, reward_rule_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('REWARD_RULE', '14610000-0000-4000-8000-000000000001', 'OFFICIAL_REWARDS_DOCUMENTATION', 'OFFICIAL_PRIMARY', 'https://x.example/reward', 't', 'o')$$,
    'a valid REWARD_RULE provenance record is accepted'
);
SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance (target_entity_type, loyalty_program_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('LOYALTY_PROGRAM', '15610000-0000-4000-8000-000000000001', 'OFFICIAL_LOYALTY_PROGRAM_DOCUMENTATION', 'OFFICIAL_PRIMARY', 'https://x.example/loyalty', 't', 'o')$$,
    'a valid LOYALTY_PROGRAM provenance record is accepted'
);
SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance (target_entity_type, card_eligibility_requirement_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('CARD_ELIGIBILITY_REQUIREMENT', '16610000-0000-4000-8000-000000000001', 'OFFICIAL_TERMS_AND_CONDITIONS', 'OFFICIAL_PRIMARY', 'https://x.example/eligibility', 't', 'o')$$,
    'a valid CARD_ELIGIBILITY_REQUIREMENT provenance record is accepted'
);

-- 10. Missing target-entity rejection (FK enforcement) for a second entity type.
RESET ROLE;
SET ROLE service_role;
SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance (target_entity_type, card_id, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('CARD', 'ffffffff-0000-4000-8000-000000000099', 'OFFICIAL_PRODUCT_PAGE', 'OFFICIAL_PRIMARY', 'https://x.example/missing', 't', 'o')$$,
    '23503', NULL, 'a reference to a non-existent card is rejected by the foreign key'
);

RESET ROLE;

-- 11. Duplicate-source prevention (fingerprint and version), scoped to ACTIVE evidence.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4610000-0000-4000-8000-000000000001';

INSERT INTO public.catalog_source_provenance (id, target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner, content_hash)
VALUES ('20610000-0000-4000-8000-000000000001', 'BANK', 'b4610000-0000-4000-8000-000000000001', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/dup', 't', 'o', repeat('a', 64));

SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance (target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner, content_hash)
      VALUES ('BANK', 'b4610000-0000-4000-8000-000000000001', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/dup', 't', 'o', repeat('a', 64))$$,
    '23505', NULL, 'an identical active fingerprint for the same target and locator is rejected as a meaningless duplicate'
);

INSERT INTO public.catalog_source_provenance (id, target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner, source_version)
VALUES ('20610000-0000-4000-8000-000000000002', 'BANK', 'b4610000-0000-4000-8000-000000000001', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/dup-version', 't', 'o', 'v1');

SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance (target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner, source_version)
      VALUES ('BANK', 'b4610000-0000-4000-8000-000000000001', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/dup-version', 't', 'o', 'v1')$$,
    '23505', NULL, 'an identical active source_version for the same target and locator is rejected as a meaningless duplicate'
);

-- 13. Lifecycle transition validation.
UPDATE public.catalog_source_provenance SET lifecycle_status = 'SUPERSEDED' WHERE id = '20610000-0000-4000-8000-000000000001';
SELECT throws_ok(
    $$UPDATE public.catalog_source_provenance SET lifecycle_status = 'ACTIVE' WHERE id = '20610000-0000-4000-8000-000000000001'$$,
    '23514', NULL, 'reactivating a SUPERSEDED record is rejected'
);
UPDATE public.catalog_source_provenance SET lifecycle_status = 'ARCHIVED' WHERE id = '20610000-0000-4000-8000-000000000001';
SELECT throws_ok(
    $$UPDATE public.catalog_source_provenance SET notes = 'edit attempt' WHERE id = '20610000-0000-4000-8000-000000000001'$$,
    '42501', NULL, 'an ARCHIVED record is immutable, including for the authorized administrator'
);

-- 14. Verification-status transition validation.
UPDATE public.catalog_source_provenance SET verification_status = 'VERIFIED' WHERE id = '20610000-0000-4000-8000-000000000002';
SELECT ok(
    (SELECT verification_status = 'VERIFIED' AND verified_at IS NOT NULL AND verified_by_user_id IS NOT NULL
     FROM public.catalog_source_provenance WHERE id = '20610000-0000-4000-8000-000000000002'),
    'transitioning to VERIFIED stamps verified_at and verified_by_user_id'
);
SELECT throws_ok(
    $$UPDATE public.catalog_source_provenance SET verification_status = 'UNVERIFIED' WHERE id = '20610000-0000-4000-8000-000000000002'$$,
    '23514', NULL, 'reverting a VERIFIED record to UNVERIFIED is rejected'
);

-- 15. Retrieval and verification timestamp validation, and REJECTED forcing ARCHIVED.
INSERT INTO public.catalog_source_provenance (id, target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner)
VALUES ('20610000-0000-4000-8000-000000000003', 'BANK', 'b4610000-0000-4000-8000-000000000001', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/reject', 't', 'o');

UPDATE public.catalog_source_provenance
SET verification_status = 'REJECTED', rejection_reason = 'content no longer matches source'
WHERE id = '20610000-0000-4000-8000-000000000003';

SELECT ok(
    (SELECT verification_status = 'REJECTED' AND lifecycle_status = 'ARCHIVED'
         AND rejected_at IS NOT NULL AND rejected_by_user_id IS NOT NULL
         AND archived_at IS NOT NULL
     FROM public.catalog_source_provenance WHERE id = '20610000-0000-4000-8000-000000000003'),
    'rejecting a record stamps rejection fields and automatically archives it'
);

RESET ROLE;

-- 19. Historical provenance preservation: superseded/archived rows are retained, not deleted.
SELECT is(
    (SELECT count(*)::integer FROM public.catalog_source_provenance
     WHERE id IN ('20610000-0000-4000-8000-000000000001', '20610000-0000-4000-8000-000000000003')),
    2,
    'superseded and rejected/archived provenance rows are preserved rather than removed'
);

-- 18. Audit-event creation for required actions.
SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
        WHERE entity_type = 'catalog_source_provenance'
          AND entity_id = '20610000-0000-4000-8000-000000000001'::uuid
          AND event_action = 'CREATE'
    ),
    'creating a provenance record writes a CREATE audit event'
);
SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
        WHERE entity_type = 'catalog_source_provenance'
          AND entity_id = '20610000-0000-4000-8000-000000000002'::uuid
          AND event_action = 'VERIFY'
    ),
    'verifying a provenance record writes a VERIFY audit event'
);
SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
        WHERE entity_type = 'catalog_source_provenance'
          AND entity_id = '20610000-0000-4000-8000-000000000003'::uuid
          AND event_action = 'REJECT'
    ),
    'rejecting a provenance record writes a REJECT audit event'
);
SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
        WHERE entity_type = 'catalog_source_provenance'
          AND entity_id = '20610000-0000-4000-8000-000000000001'::uuid
          AND event_action = 'ARCHIVE'
    ),
    'archiving a provenance record writes an ARCHIVE audit event'
);

INSERT INTO public.catalog_source_provenance (id, target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner)
VALUES ('20610000-0000-4000-8000-000000000004', 'BANK', 'b4610000-0000-4000-8000-000000000001', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/delete-target', 't', 'o');

SET ROLE service_role;
DELETE FROM public.catalog_source_provenance WHERE id = '20610000-0000-4000-8000-000000000004';
RESET ROLE;

SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
        WHERE entity_type = 'catalog_source_provenance'
          AND entity_id = '20610000-0000-4000-8000-000000000004'::uuid
          AND event_action = 'DELETE'
          AND before_values IS NOT NULL
          AND after_values IS NULL
    ),
    'deleting a provenance record writes a DELETE event using only the OLD row values'
);

-- 21. SECURITY DEFINER safety properties: schema-qualified, pinned search_path, minimal surface.
SELECT ok(
    (SELECT prosecdef FROM pg_catalog.pg_proc WHERE oid = 'public.audit_catalog_source_provenance_change()'::regprocedure),
    'audit_catalog_source_provenance_change is SECURITY DEFINER'
);
SELECT ok(
    (SELECT proconfig @> ARRAY['search_path=pg_catalog']
     FROM pg_catalog.pg_proc WHERE oid = 'public.audit_catalog_source_provenance_change()'::regprocedure),
    'audit_catalog_source_provenance_change pins search_path to pg_catalog'
);
SELECT ok(
    NOT (SELECT prosecdef FROM pg_catalog.pg_proc WHERE oid = 'public.manage_catalog_source_provenance_change()'::regprocedure),
    'manage_catalog_source_provenance_change is SECURITY INVOKER, not SECURITY DEFINER'
);

SELECT * FROM finish();
ROLLBACK;
