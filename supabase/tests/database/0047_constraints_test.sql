-- Migration 0047 — merchants schema, constraint, and index coverage.
BEGIN;

SELECT plan(45);

-- 1. Object existence.
SELECT has_table('public', 'merchants', 'merchants table exists');
SELECT has_table('public', 'merchant_aliases', 'merchant_aliases table exists');
SELECT has_table('public', 'merchant_relationships', 'merchant_relationships table exists');
SELECT has_table('public', 'merchant_category_assignments', 'merchant_category_assignments table exists');
SELECT has_table('public', 'merchant_market_presence', 'merchant_market_presence table exists');
SELECT has_table('public', 'merchant_domains', 'merchant_domains table exists');

-- 2. Column types and nullability.
SELECT col_type_is('public', 'merchants', 'id', 'uuid', 'merchants.id is uuid');
SELECT col_type_is('public', 'merchants', 'slug', 'text', 'merchants.slug is text');
SELECT col_type_is('public', 'merchants', 'display_name_en', 'text', 'merchants.display_name_en is text');
SELECT col_type_is('public', 'merchants', 'merchant_classification', 'text', 'merchants.merchant_classification is text');
SELECT col_type_is('public', 'merchants', 'metadata', 'jsonb', 'merchants.metadata is jsonb');
SELECT col_type_is('public', 'merchant_aliases', 'normalized_alias', 'text', 'merchant_aliases.normalized_alias is text');
SELECT col_not_null('public', 'merchants', 'slug', 'merchants.slug is NOT NULL');
SELECT col_not_null('public', 'merchants', 'display_name_en', 'merchants.display_name_en is NOT NULL');
SELECT col_not_null('public', 'merchants', 'display_name_ar', 'merchants.display_name_ar is NOT NULL');
SELECT col_not_null('public', 'merchants', 'lifecycle_status', 'merchants.lifecycle_status is NOT NULL');
SELECT col_is_null('public', 'merchants', 'legal_name_en', 'merchants.legal_name_en is nullable');
SELECT col_is_null('public', 'merchants', 'superseded_by_merchant_id', 'merchants.superseded_by_merchant_id is nullable');

-- 3. Primary keys, foreign keys, unique constraints, checks, and indexes.
SELECT col_is_pk('public', 'merchants', 'id', 'merchants.id is the primary key');
SELECT col_is_fk('public', 'merchants', 'headquarters_country_id', 'merchants.headquarters_country_id is a foreign key');
SELECT col_is_fk('public', 'merchants', 'superseded_by_merchant_id', 'merchants.superseded_by_merchant_id is a self-referencing foreign key');
SELECT col_is_fk('public', 'merchant_aliases', 'merchant_id', 'merchant_aliases.merchant_id is a foreign key');
SELECT col_is_fk('public', 'merchant_relationships', 'parent_merchant_id', 'merchant_relationships.parent_merchant_id is a foreign key');
SELECT col_is_fk('public', 'merchant_relationships', 'child_merchant_id', 'merchant_relationships.child_merchant_id is a foreign key');
SELECT col_is_fk('public', 'merchant_category_assignments', 'merchant_category_id', 'merchant_category_assignments.merchant_category_id is a foreign key');
SELECT col_is_fk('public', 'merchant_market_presence', 'country_id', 'merchant_market_presence.country_id is a foreign key');
SELECT col_is_fk('public', 'merchant_domains', 'merchant_id', 'merchant_domains.merchant_id is a foreign key');
SELECT has_check('public', 'merchants', 'a CHECK constraint exists on merchants');
SELECT has_index('public', 'merchants', 'idx_merchants_active', 'active-merchant lookup index exists');
SELECT has_index('public', 'merchant_aliases', 'uq_merchant_aliases_normalized_active', 'alias global dedup index exists');
SELECT has_index('public', 'merchant_relationships', 'uq_merchant_relationships_single_active_parent', 'single-active-parent index exists');
SELECT has_index('public', 'merchant_domains', 'uq_merchant_domains_active_global', 'domain global dedup index exists');
SELECT has_index('public', 'merchant_category_assignments', 'uq_merchant_category_assignments_primary', 'single-primary-category index exists');

-- 9. Valid merchant creation, with Arabic and English names (test matrix items 9-10).
SELECT lives_ok(
    $$INSERT INTO public.merchants (id, slug, display_name_en, display_name_ar)
      VALUES ('47000000-0000-4000-8000-000000000001', 'test-merchant-47', 'Test Merchant', 'متجر تجريبي')$$,
    'a valid merchant with English and Arabic names is accepted'
);
SELECT is(
    (SELECT display_name_ar FROM public.merchants WHERE id = '47000000-0000-4000-8000-000000000001'),
    'متجر تجريبي',
    'Arabic display name is stored correctly'
);

-- 11. Duplicate canonical merchant (slug) prevention.
SELECT throws_ok(
    $$INSERT INTO public.merchants (slug, display_name_en, display_name_ar)
      VALUES ('test-merchant-47', 'Duplicate', 'مكرر')$$,
    '23505', NULL, 'a duplicate slug is rejected as a duplicate canonical merchant'
);

SELECT throws_ok(
    $$INSERT INTO public.merchants (slug, display_name_en, display_name_ar)
      VALUES ('Not A Valid Slug', 'x', 'س')$$,
    '23514', NULL, 'a malformed slug is rejected'
);

SELECT throws_ok(
    $$INSERT INTO public.merchants (slug, display_name_en, display_name_ar, merchant_classification)
      VALUES ('bad-classification-47', 'x', 'س', 'NOT_A_CLASSIFICATION')$$,
    '23514', NULL, 'an unsupported merchant_classification is rejected'
);

SELECT throws_ok(
    $$INSERT INTO public.merchants (slug, display_name_en, display_name_ar, channel_type)
      VALUES ('bad-channel-47', 'x', 'س', 'NOT_A_CHANNEL')$$,
    '23514', NULL, 'an unsupported channel_type is rejected'
);

SELECT throws_ok(
    $$INSERT INTO public.merchants (slug, display_name_en, display_name_ar)
      VALUES ('empty-display-name-47', '', 'س')$$,
    '23514', NULL, 'an empty display_name_en is rejected'
);

-- Verification-completeness checks (mirrors 0046's pattern).
SELECT throws_ok(
    $$INSERT INTO public.merchants (slug, display_name_en, display_name_ar, verification_status)
      VALUES ('incomplete-verified-47', 'x', 'س', 'VERIFIED')$$,
    '23514', NULL, 'VERIFIED without verified_at/verified_by_user_id is rejected'
);
SELECT throws_ok(
    $$INSERT INTO public.merchants (slug, display_name_en, display_name_ar, verification_status)
      VALUES ('incomplete-rejected-47', 'x', 'س', 'REJECTED')$$,
    '23514', NULL, 'REJECTED without rejection_reason is rejected'
);

-- merchant_domains format validation (test matrix items 21-22).
INSERT INTO public.merchants (id, slug, display_name_en, display_name_ar)
VALUES ('47000000-0000-4000-8000-000000000002', 'domain-owner-47', 'Domain Owner', 'مالك النطاق');

SELECT lives_ok(
    $$INSERT INTO public.merchant_domains (merchant_id, domain)
      VALUES ('47000000-0000-4000-8000-000000000002', 'example.com')$$,
    'a valid official domain is accepted'
);
SELECT throws_ok(
    $$INSERT INTO public.merchant_domains (merchant_id, domain)
      VALUES ('47000000-0000-4000-8000-000000000002', 'not a domain!')$$,
    '23514', NULL, 'a malformed domain is rejected'
);
SELECT throws_ok(
    $$INSERT INTO public.merchant_domains (merchant_id, domain)
      VALUES ('47000000-0000-4000-8000-000000000002', 'EXAMPLE.COM')$$,
    '23514', NULL, 'an uppercase domain is rejected (must be pre-normalized to lowercase)'
);

SELECT * FROM finish();
ROLLBACK;
