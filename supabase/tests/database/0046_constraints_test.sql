-- Migration 0046 — catalog_source_provenance schema, constraint, and index coverage.
BEGIN;

SELECT plan(39);

INSERT INTO public.countries (id, code, slug, name_en, name_ar) VALUES
    ('c4600000-0000-4000-8000-000000000099', 'SA', 'saudi-arabia-460-c', 'Saudi Arabia', 'السعودية');
INSERT INTO public.banks (id, country_id, slug, name_en, name_ar) VALUES
    ('b4600000-0000-4000-8000-000000000099', 'c4600000-0000-4000-8000-000000000099', 'test-bank-460-c', 'Test Bank', 'بنك تجريبي');

-- 1. Object existence.
SELECT has_table('public', 'catalog_source_provenance', 'catalog_source_provenance table exists');

-- 2. Column types and nullability (representative sample of required columns).
SELECT col_type_is('public', 'catalog_source_provenance', 'id', 'uuid', 'id is uuid');
SELECT col_type_is('public', 'catalog_source_provenance', 'target_entity_type', 'text', 'target_entity_type is text');
SELECT col_type_is('public', 'catalog_source_provenance', 'target_entity_id', 'uuid', 'target_entity_id is uuid');
SELECT col_type_is('public', 'catalog_source_provenance', 'retrieved_at', 'timestamp with time zone', 'retrieved_at is timestamptz');
SELECT col_type_is('public', 'catalog_source_provenance', 'content_hash', 'text', 'content_hash is text');
SELECT col_type_is('public', 'catalog_source_provenance', 'metadata', 'jsonb', 'metadata is jsonb');
SELECT col_not_null('public', 'catalog_source_provenance', 'target_entity_type', 'target_entity_type is NOT NULL');
SELECT col_not_null('public', 'catalog_source_provenance', 'source_locator', 'source_locator is NOT NULL');
SELECT col_not_null('public', 'catalog_source_provenance', 'source_title', 'source_title is NOT NULL');
SELECT col_not_null('public', 'catalog_source_provenance', 'source_owner', 'source_owner is NOT NULL');
SELECT col_is_null('public', 'catalog_source_provenance', 'content_hash', 'content_hash is nullable');
SELECT col_is_null('public', 'catalog_source_provenance', 'verified_at', 'verified_at is nullable');

-- 3. Primary keys, foreign keys, checks, and unique constraints.
SELECT col_is_pk('public', 'catalog_source_provenance', 'id', 'id is the primary key');
SELECT col_is_fk('public', 'catalog_source_provenance', 'bank_id', 'bank_id is a foreign key');
SELECT col_is_fk('public', 'catalog_source_provenance', 'card_id', 'card_id is a foreign key');
SELECT col_is_fk('public', 'catalog_source_provenance', 'card_fee_id', 'card_fee_id is a foreign key');
SELECT col_is_fk('public', 'catalog_source_provenance', 'card_benefit_id', 'card_benefit_id is a foreign key');
SELECT col_is_fk('public', 'catalog_source_provenance', 'reward_rule_id', 'reward_rule_id is a foreign key');
SELECT col_is_fk('public', 'catalog_source_provenance', 'loyalty_program_id', 'loyalty_program_id is a foreign key');
SELECT col_is_fk('public', 'catalog_source_provenance', 'card_eligibility_requirement_id', 'card_eligibility_requirement_id is a foreign key');
SELECT col_is_fk('public', 'catalog_source_provenance', 'superseded_by_provenance_id', 'superseded_by_provenance_id is a self-referencing foreign key');
SELECT has_check('public', 'catalog_source_provenance', 'a CHECK constraint exists on catalog_source_provenance');

SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('BANK', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example', 'Title', 'Owner')$$,
    '23514', NULL, 'a BANK row with no bank_id violates the target-match check'
);

SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('MERCHANT', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example', 'Title', 'Owner')$$,
    '23514', NULL, 'an unsupported target_entity_type is rejected'
);

SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('BANK', 'NOT_A_TYPE', 'OFFICIAL_PRIMARY', 'https://x.example', 'Title', 'Owner')$$,
    '23514', NULL, 'an unsupported source_type is rejected'
);

SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, source_type, authority_level, source_locator, source_title, source_owner)
      VALUES ('BANK', 'OFFICIAL_BANK_WEBSITE', 'MADE_UP', 'https://x.example', 'Title', 'Owner')$$,
    '23514', NULL, 'an unsupported authority_level is rejected'
);

SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, source_type, authority_level, source_locator, source_title, source_owner, source_locator_type)
      VALUES ('BANK', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'not-a-url', 'Title', 'Owner', 'URL')$$,
    '23514', NULL, 'a malformed URL locator is rejected when source_locator_type is URL'
);

SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner, source_locator_type)
      VALUES ('BANK', 'b4600000-0000-4000-8000-000000000099', 'OFFICIAL_REGULATORY_SOURCE', 'OFFICIAL_REGULATORY', 'SAMA-CIRCULAR-2026-014', 'Circular', 'SAMA', 'DOCUMENT_REFERENCE')$$,
    'a non-URL stable source identifier is accepted when source_locator_type is DOCUMENT_REFERENCE'
);

SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, source_type, authority_level, source_locator, source_title, source_owner, content_hash)
      VALUES ('BANK', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example', 'Title', 'Owner', 'not-hex')$$,
    '23514', NULL, 'a malformed content_hash is rejected'
);

-- Effective-date validation.
SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, source_type, authority_level, source_locator, source_title, source_owner, effective_from, effective_until)
      VALUES ('BANK', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example', 'Title', 'Owner', '2026-06-01', '2026-01-01')$$,
    '23514', NULL, 'an effective_until before effective_from is rejected'
);

SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, bank_id, source_type, authority_level, source_locator, source_title, source_owner, effective_from, effective_until)
      VALUES ('BANK', 'b4600000-0000-4000-8000-000000000099', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/eff', 'Title', 'Owner', '2026-01-01', '2026-06-01')$$,
    'a valid non-decreasing effective date range is accepted'
);

-- Retrieval/verification timestamp validation.
SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, source_type, authority_level, source_locator, source_title, source_owner, retrieved_at, verification_status, verified_at, verified_by_user_id)
      VALUES ('BANK', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/ver', 'Title', 'Owner', now(), 'VERIFIED', now() - interval '1 day', NULL)$$,
    '23514', NULL, 'a verified_at before retrieved_at is rejected'
);

SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, source_type, authority_level, source_locator, source_title, source_owner, verification_status)
      VALUES ('BANK', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/incomplete', 'Title', 'Owner', 'VERIFIED')$$,
    '23514', NULL, 'VERIFIED without verified_at/verified_by_user_id is rejected'
);

SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type, source_type, authority_level, source_locator, source_title, source_owner, verification_status)
      VALUES ('BANK', 'OFFICIAL_BANK_WEBSITE', 'OFFICIAL_PRIMARY', 'https://x.example/incomplete2', 'Title', 'Owner', 'REJECTED')$$,
    '23514', NULL, 'REJECTED without rejection_reason is rejected'
);

-- Indexes (test matrix item 22): target lookup and current-evidence lookup exist.
SELECT has_index('public', 'catalog_source_provenance', 'idx_catalog_source_provenance_target', 'target lookup index exists');
SELECT has_index('public', 'catalog_source_provenance', 'idx_catalog_source_provenance_current', 'current-evidence partial index exists');
SELECT has_index('public', 'catalog_source_provenance', 'uq_catalog_source_provenance_fingerprint', 'fingerprint deduplication index exists');
SELECT has_index('public', 'catalog_source_provenance', 'uq_catalog_source_provenance_version', 'version deduplication index exists');

SELECT * FROM finish();
ROLLBACK;
