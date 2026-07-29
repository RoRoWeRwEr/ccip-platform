-- Migration 0047 — merchant aliases, relationships, category assignments,
-- market presence, and domain business-rule coverage.
BEGIN;

SELECT plan(19);

INSERT INTO public.countries (id, code, slug, name_en, name_ar) VALUES
    ('c4710000-0000-4000-8000-000000000001', 'SA', 'saudi-arabia-4710', 'Saudi Arabia', 'السعودية'),
    ('c4710000-0000-4000-8000-000000000002', 'AE', 'united-arab-emirates-4710', 'United Arab Emirates', 'الإمارات');

INSERT INTO public.merchants (id, slug, display_name_en, display_name_ar) VALUES
    ('47100000-0000-4000-8000-000000000001', 'alpha-merchant-4710', 'Alpha Merchant', 'تاجر ألفا'),
    ('47100000-0000-4000-8000-000000000002', 'beta-merchant-4710', 'Beta Merchant', 'تاجر بيتا'),
    ('47100000-0000-4000-8000-000000000003', 'gamma-merchant-4710', 'Gamma Merchant', 'تاجر جاما'),
    ('47100000-0000-4000-8000-000000000004', 'delta-merchant-4710', 'Delta Merchant', 'تاجر دلتا');

-- 12. Valid alias creation.
SELECT lives_ok(
    $$INSERT INTO public.merchant_aliases (merchant_id, alias, alias_language)
      VALUES ('47100000-0000-4000-8000-000000000001', 'Alpha Co', 'en')$$,
    'a valid alias is accepted'
);

-- 13. Duplicate alias prevention (same merchant, same normalized text).
SELECT throws_ok(
    $$INSERT INTO public.merchant_aliases (merchant_id, alias, alias_language)
      VALUES ('47100000-0000-4000-8000-000000000001', '  alpha co  ', 'en')$$,
    '23505', NULL, 'a duplicate normalized alias for the same merchant is rejected'
);

-- 14. Alias normalization (trims and lowercases for comparison and dedup).
SELECT is(
    (SELECT normalized_alias FROM public.merchant_aliases
     WHERE merchant_id = '47100000-0000-4000-8000-000000000001' AND alias = 'Alpha Co'),
    'alpha co',
    'normalized_alias trims and lowercases the alias'
);

-- Global alias dedup: a different merchant cannot claim the same normalized alias while active.
SELECT throws_ok(
    $$INSERT INTO public.merchant_aliases (merchant_id, alias, alias_language)
      VALUES ('47100000-0000-4000-8000-000000000002', 'ALPHA CO', 'en')$$,
    '23505', NULL, 'a different merchant cannot claim an already-active alias'
);

SELECT throws_ok(
    $$INSERT INTO public.merchant_aliases (merchant_id, alias, alias_language)
      VALUES ('47100000-0000-4000-8000-000000000001', 'Alpha Company', 'fr')$$,
    '23514', NULL, 'an unsupported alias_language is rejected'
);

-- 15. Valid parent-child relationship.
SELECT lives_ok(
    $$INSERT INTO public.merchant_relationships (parent_merchant_id, child_merchant_id, relationship_type)
      VALUES ('47100000-0000-4000-8000-000000000001', '47100000-0000-4000-8000-000000000002', 'PARENT_SUBSIDIARY')$$,
    'a valid parent-subsidiary relationship is accepted'
);

-- 16. Self-parent rejection.
SELECT throws_ok(
    $$INSERT INTO public.merchant_relationships (parent_merchant_id, child_merchant_id, relationship_type)
      VALUES ('47100000-0000-4000-8000-000000000001', '47100000-0000-4000-8000-000000000001', 'PARENT_SUBSIDIARY')$$,
    '23514', NULL, 'a self-parenting relationship is rejected'
);

-- 17. Invalid hierarchy (cycle) rejection.
INSERT INTO public.merchant_relationships (parent_merchant_id, child_merchant_id, relationship_type)
VALUES ('47100000-0000-4000-8000-000000000002', '47100000-0000-4000-8000-000000000003', 'PARENT_SUBSIDIARY');

SELECT throws_ok(
    $$INSERT INTO public.merchant_relationships (parent_merchant_id, child_merchant_id, relationship_type)
      VALUES ('47100000-0000-4000-8000-000000000003', '47100000-0000-4000-8000-000000000001', 'PARENT_SUBSIDIARY')$$,
    '23514', NULL, 'a relationship that would create a hierarchy cycle is rejected'
);

-- A child may have only one active parent per relationship_type.
SELECT throws_ok(
    $$INSERT INTO public.merchant_relationships (parent_merchant_id, child_merchant_id, relationship_type)
      VALUES ('47100000-0000-4000-8000-000000000004', '47100000-0000-4000-8000-000000000002', 'PARENT_SUBSIDIARY')$$,
    '23505', NULL, 'a child cannot have two active parents of the same relationship_type'
);

SELECT throws_ok(
    $$INSERT INTO public.merchant_relationships (parent_merchant_id, child_merchant_id, relationship_type)
      VALUES ('47100000-0000-4000-8000-000000000001', '47100000-0000-4000-8000-000000000002', 'NOT_A_TYPE')$$,
    '23514', NULL, 'an unsupported relationship_type is rejected'
);

-- 18. Valid classification/category assignment (using the existing merchant_categories table from migration 0004).
INSERT INTO public.merchant_categories (id, code, slug, name_en, name_ar)
VALUES ('4a710000-0000-4000-8000-000000000001', '5812', 'restaurants-4710', 'Restaurants', 'مطاعم');

SELECT lives_ok(
    $$INSERT INTO public.merchant_category_assignments (merchant_id, merchant_category_id, is_primary)
      VALUES ('47100000-0000-4000-8000-000000000001', '4a710000-0000-4000-8000-000000000001', TRUE)$$,
    'a valid merchant category assignment is accepted'
);

-- 19. Duplicate classification assignment prevention.
SELECT throws_ok(
    $$INSERT INTO public.merchant_category_assignments (merchant_id, merchant_category_id)
      VALUES ('47100000-0000-4000-8000-000000000001', '4a710000-0000-4000-8000-000000000001')$$,
    '23505', NULL, 'assigning the same category twice to the same merchant is rejected'
);

INSERT INTO public.merchant_categories (id, code, slug, name_en, name_ar)
VALUES ('4a710000-0000-4000-8000-000000000002', '5813', 'bars-4710', 'Bars', 'حانات');
SELECT throws_ok(
    $$INSERT INTO public.merchant_category_assignments (merchant_id, merchant_category_id, is_primary)
      VALUES ('47100000-0000-4000-8000-000000000001', '4a710000-0000-4000-8000-000000000002', TRUE)$$,
    '23505', NULL, 'a merchant cannot have two primary category assignments'
);

-- 20. Valid country/market presence.
SELECT lives_ok(
    $$INSERT INTO public.merchant_market_presence (merchant_id, country_id, presence_type)
      VALUES ('47100000-0000-4000-8000-000000000001', 'c4710000-0000-4000-8000-000000000001', 'PHYSICAL_AND_ONLINE')$$,
    'a valid market presence record is accepted'
);
SELECT throws_ok(
    $$INSERT INTO public.merchant_market_presence (merchant_id, country_id)
      VALUES ('47100000-0000-4000-8000-000000000001', 'c4710000-0000-4000-8000-000000000001')$$,
    '23505', NULL, 'a duplicate market-presence country for the same merchant is rejected'
);
SELECT throws_ok(
    $$INSERT INTO public.merchant_market_presence (merchant_id, country_id, presence_type)
      VALUES ('47100000-0000-4000-8000-000000000001', 'c4710000-0000-4000-8000-000000000002', 'NOT_A_PRESENCE')$$,
    '23514', NULL, 'an unsupported presence_type is rejected'
);

-- 21-22. Domain uniqueness (single-column format coverage lives in the constraints test).
INSERT INTO public.merchant_domains (merchant_id, domain, is_primary)
VALUES ('47100000-0000-4000-8000-000000000001', 'alpha.example', TRUE);
SELECT throws_ok(
    $$INSERT INTO public.merchant_domains (merchant_id, domain)
      VALUES ('47100000-0000-4000-8000-000000000001', 'alpha.example')$$,
    '23505', NULL, 'a duplicate domain for the same merchant is rejected'
);
SELECT throws_ok(
    $$INSERT INTO public.merchant_domains (merchant_id, domain)
      VALUES ('47100000-0000-4000-8000-000000000002', 'alpha.example')$$,
    '23505', NULL, 'the same active domain cannot be claimed by a different merchant'
);
SELECT throws_ok(
    $$INSERT INTO public.merchant_domains (merchant_id, domain, is_primary)
      VALUES ('47100000-0000-4000-8000-000000000001', 'alpha-secondary.example', TRUE)$$,
    '23505', NULL, 'a merchant cannot have two primary domains'
);

SELECT * FROM finish();
ROLLBACK;
