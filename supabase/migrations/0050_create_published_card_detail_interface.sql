-- Migration 0050: read-only published card-detail interface for P3.3.
--
-- The publication snapshots created by 0048 are the authoritative public
-- content. Reading mutable core rows after merely checking that some version
-- is published could leak a later draft edit, so this function uses core rows
-- only to validate typed relationships and active reference data. Every
-- governed payload is projected from its effective PUBLISHED snapshot through
-- an explicit column allowlist.

BEGIN;

CREATE OR REPLACE FUNCTION public.get_published_card_detail(requested_slug TEXT)
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog
AS $function$
WITH effective_versions AS (
    SELECT
        version.id,
        version.target_entity_type,
        version.target_entity_id,
        version.bank_id,
        version.card_id,
        version.card_fee_id,
        version.card_benefit_id,
        version.reward_rule_id,
        version.loyalty_program_id,
        version.card_eligibility_requirement_id,
        version.merchant_id,
        version.version_number,
        version.content_snapshot,
        version.source_provenance_id,
        version.effective_from,
        version.effective_until,
        version.published_at
    FROM public.catalog_publication_versions AS version
    WHERE version.lifecycle_status = 'PUBLISHED'
      AND version.effective_from <= pg_catalog.now()
      AND (version.effective_until IS NULL OR version.effective_until > pg_catalog.now())
      AND (version.scheduled_unpublish_at IS NULL OR version.scheduled_unpublish_at > pg_catalog.now())
),
published_card AS (
    SELECT card.*, version.id AS publication_version_id,
           version.version_number, version.content_snapshot,
           version.source_provenance_id, version.effective_from,
           version.effective_until, version.published_at AS version_published_at
    FROM public.cards AS card
    JOIN effective_versions AS version
      ON version.target_entity_type = 'CARD'
     AND version.card_id = card.id
    WHERE requested_slug IS NOT NULL
      AND requested_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
      AND card.slug = requested_slug
      AND card.is_active
      AND card.availability_status = 'AVAILABLE'
      AND card.published_at IS NOT NULL
      AND card.published_at <= pg_catalog.now()
      AND version.content_snapshot ->> 'id' = card.id::TEXT
      AND version.content_snapshot ->> 'slug' = requested_slug
),
card_context AS (
    SELECT card.*
    FROM published_card AS card
    JOIN public.banks AS bank
      ON bank.id = card.bank_id AND bank.is_active
    JOIN effective_versions AS bank_version
      ON bank_version.target_entity_type = 'BANK'
     AND bank_version.bank_id = bank.id
     AND bank_version.content_snapshot ->> 'id' = bank.id::TEXT
    JOIN public.card_networks AS network
      ON network.id = card.card_network_id AND network.is_active
    JOIN public.currencies AS currency
      ON currency.id = card.currency_id AND currency.is_active
    WHERE card.content_snapshot ->> 'bank_id' = card.bank_id::TEXT
      AND card.content_snapshot ->> 'card_network_id' = card.card_network_id::TEXT
      AND card.content_snapshot ->> 'currency_id' = card.currency_id::TEXT
),
detail AS (
    SELECT pg_catalog.jsonb_build_object(
        'card', pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
            'id', card.content_snapshot -> 'id',
            'slug', card.content_snapshot -> 'slug',
            'name_en', card.content_snapshot -> 'name_en',
            'name_ar', card.content_snapshot -> 'name_ar',
            'description_en', card.content_snapshot -> 'description_en',
            'description_ar', card.content_snapshot -> 'description_ar',
            'card_tier', card.content_snapshot -> 'card_tier',
            'target_user', card.content_snapshot -> 'target_user',
            'annual_fee', card.content_snapshot -> 'annual_fee',
            'minimum_salary', card.content_snapshot -> 'minimum_salary',
            'credit_limit_min', card.content_snapshot -> 'credit_limit_min',
            'credit_limit_max', card.content_snapshot -> 'credit_limit_max',
            'purchase_rate', card.content_snapshot -> 'purchase_rate',
            'cash_advance_rate', card.content_snapshot -> 'cash_advance_rate',
            'foreign_transaction_fee_rate', card.content_snapshot -> 'foreign_transaction_fee_rate',
            'image_url', card.content_snapshot -> 'image_url',
            'application_url', card.content_snapshot -> 'application_url',
            'terms_url', card.content_snapshot -> 'terms_url',
            'is_featured', card.content_snapshot -> 'is_featured'
        )),
        'bank', (
            SELECT pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
                'id', bank_version.content_snapshot -> 'id',
                'slug', bank_version.content_snapshot -> 'slug',
                'name_en', bank_version.content_snapshot -> 'name_en',
                'name_ar', bank_version.content_snapshot -> 'name_ar',
                'short_name_en', bank_version.content_snapshot -> 'short_name_en',
                'short_name_ar', bank_version.content_snapshot -> 'short_name_ar',
                'website_url', bank_version.content_snapshot -> 'website_url',
                'logo_url', bank_version.content_snapshot -> 'logo_url'
            ))
            FROM effective_versions AS bank_version
            WHERE bank_version.target_entity_type = 'BANK'
              AND bank_version.bank_id = card.bank_id
              AND bank_version.content_snapshot ->> 'id' = card.bank_id::TEXT
        ),
        'network', (
            SELECT pg_catalog.jsonb_build_object(
                'id', network.id, 'slug', network.slug,
                'name_en', network.name_en, 'name_ar', network.name_ar,
                'logo_url', network.logo_url
            )
            FROM public.card_networks AS network
            WHERE network.id = card.card_network_id AND network.is_active
        ),
        'currency', (
            SELECT pg_catalog.jsonb_build_object(
                'id', currency.id, 'code', currency.code,
                'name_en', currency.name_en, 'name_ar', currency.name_ar,
                'symbol', currency.symbol, 'decimal_places', currency.decimal_places
            )
            FROM public.currencies AS currency
            WHERE currency.id = card.currency_id AND currency.is_active
        ),
        'loyalty_program', (
            SELECT pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
                'id', loyalty.content_snapshot -> 'id',
                'slug', loyalty.content_snapshot -> 'slug',
                'name_en', loyalty.content_snapshot -> 'name_en',
                'name_ar', loyalty.content_snapshot -> 'name_ar',
                'type', loyalty.content_snapshot -> 'type',
                'website_url', loyalty.content_snapshot -> 'website_url',
                'logo_url', loyalty.content_snapshot -> 'logo_url',
                'publication', pg_catalog.jsonb_build_object(
                    'version_number', loyalty.version_number,
                    'effective_from', loyalty.effective_from,
                    'effective_until', loyalty.effective_until,
                    'published_at', loyalty.published_at
                )
            ))
            FROM effective_versions AS loyalty
            JOIN public.loyalty_programs AS program
              ON program.id = loyalty.loyalty_program_id AND program.is_active
            WHERE loyalty.target_entity_type = 'LOYALTY_PROGRAM'
              AND loyalty.loyalty_program_id = card.loyalty_program_id
              AND card.content_snapshot ->> 'loyalty_program_id' = program.id::TEXT
              AND loyalty.content_snapshot ->> 'id' = program.id::TEXT
        ),
        'fees', (
            SELECT coalesce(pg_catalog.jsonb_agg(
                pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
                    'id', version.content_snapshot -> 'id',
                    'fee_type', version.content_snapshot -> 'fee_type',
                    'name_en', version.content_snapshot -> 'name_en',
                    'name_ar', version.content_snapshot -> 'name_ar',
                    'description_en', version.content_snapshot -> 'description_en',
                    'description_ar', version.content_snapshot -> 'description_ar',
                    'amount', version.content_snapshot -> 'amount',
                    'percentage', version.content_snapshot -> 'percentage',
                    'billing_period', version.content_snapshot -> 'billing_period',
                    'waiver_type', version.content_snapshot -> 'waiver_type',
                    'waiver_threshold_amount', version.content_snapshot -> 'waiver_threshold_amount',
                    'waiver_threshold_period', version.content_snapshot -> 'waiver_threshold_period'
                )) ORDER BY fee.fee_type::TEXT, fee.id
            ), '[]'::JSONB)
            FROM effective_versions AS version
            JOIN public.card_fees AS fee
              ON fee.id = version.card_fee_id
             AND fee.card_id = card.id
             AND fee.is_active
            WHERE version.target_entity_type = 'CARD_FEE'
              AND version.content_snapshot ->> 'id' = fee.id::TEXT
              AND version.content_snapshot ->> 'card_id' = card.id::TEXT
        ),
        'benefits', (
            SELECT coalesce(pg_catalog.jsonb_agg(
                pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
                    'id', version.content_snapshot -> 'id',
                    'slug', version.content_snapshot -> 'slug',
                    'name_en', version.content_snapshot -> 'name_en',
                    'name_ar', version.content_snapshot -> 'name_ar',
                    'description_en', version.content_snapshot -> 'description_en',
                    'description_ar', version.content_snapshot -> 'description_ar',
                    'benefit_value', version.content_snapshot -> 'benefit_value',
                    'benefit_unit', version.content_snapshot -> 'benefit_unit',
                    'terms_en', version.content_snapshot -> 'terms_en',
                    'terms_ar', version.content_snapshot -> 'terms_ar',
                    'valid_from', version.content_snapshot -> 'valid_from',
                    'valid_to', version.content_snapshot -> 'valid_to',
                    'is_featured', version.content_snapshot -> 'is_featured'
                )) ORDER BY benefit.display_order, benefit.id
            ), '[]'::JSONB)
            FROM effective_versions AS version
            JOIN public.card_benefits AS benefit
              ON benefit.id = version.card_benefit_id
             AND benefit.card_id = card.id
             AND benefit.is_active
             AND (benefit.valid_from IS NULL OR benefit.valid_from <= CURRENT_DATE)
             AND (benefit.valid_to IS NULL OR benefit.valid_to >= CURRENT_DATE)
            WHERE version.target_entity_type = 'CARD_BENEFIT'
              AND version.content_snapshot ->> 'id' = benefit.id::TEXT
              AND version.content_snapshot ->> 'card_id' = card.id::TEXT
        ),
        'reward_rules', (
            SELECT coalesce(pg_catalog.jsonb_agg(
                pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
                    'id', version.content_snapshot -> 'id',
                    'reward_type', version.content_snapshot -> 'reward_type',
                    'calculation_method', version.content_snapshot -> 'calculation_method',
                    'reward_value', version.content_snapshot -> 'reward_value',
                    'minimum_spend', version.content_snapshot -> 'minimum_spend',
                    'minimum_spend_period', version.content_snapshot -> 'minimum_spend_period',
                    'cap_amount', version.content_snapshot -> 'cap_amount',
                    'cap_period', version.content_snapshot -> 'cap_period',
                    'rounding_method', version.content_snapshot -> 'rounding_method',
                    'priority', version.content_snapshot -> 'priority',
                    'valid_from', version.content_snapshot -> 'valid_from',
                    'valid_to', version.content_snapshot -> 'valid_to',
                    'targets', (
                        SELECT coalesce(pg_catalog.jsonb_agg(
                            pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
                                'id', target.id,
                                'target_type', target.target_type,
                                'category_slug', target.category_slug,
                                'merchant_category', CASE WHEN category.id IS NULL THEN NULL ELSE
                                    pg_catalog.jsonb_build_object(
                                        'id', category.id, 'code', category.code,
                                        'slug', category.slug, 'name_en', category.name_en,
                                        'name_ar', category.name_ar)
                                END
                            )) ORDER BY target.id
                        ), '[]'::JSONB)
                        FROM public.reward_targets AS target
                        LEFT JOIN public.merchant_categories AS category
                          ON category.id = target.merchant_category_id AND category.is_active
                        WHERE target.reward_rule_id = rule.id
                          AND (version.content_snapshot -> 'target_ids') ? target.id::TEXT
                    )
                )) ORDER BY rule.priority, rule.id
            ), '[]'::JSONB)
            FROM effective_versions AS version
            JOIN public.reward_rules AS rule
              ON rule.id = version.reward_rule_id
             AND rule.card_id = card.id
             AND rule.is_active
             AND (rule.valid_from IS NULL OR rule.valid_from <= CURRENT_DATE)
             AND (rule.valid_to IS NULL OR rule.valid_to >= CURRENT_DATE)
            WHERE version.target_entity_type = 'REWARD_RULE'
              AND version.content_snapshot ->> 'id' = rule.id::TEXT
              AND version.content_snapshot ->> 'card_id' = card.id::TEXT
              AND pg_catalog.jsonb_typeof(version.content_snapshot -> 'target_ids') = 'array'
        ),
        'eligibility', (
            SELECT coalesce(pg_catalog.jsonb_agg(
                pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
                    'id', version.content_snapshot -> 'id',
                    'requirement_type', version.content_snapshot -> 'requirement_type',
                    'name_en', version.content_snapshot -> 'name_en',
                    'name_ar', version.content_snapshot -> 'name_ar',
                    'description_en', version.content_snapshot -> 'description_en',
                    'description_ar', version.content_snapshot -> 'description_ar',
                    'minimum_amount', version.content_snapshot -> 'minimum_amount',
                    'maximum_amount', version.content_snapshot -> 'maximum_amount',
                    'minimum_age', version.content_snapshot -> 'minimum_age',
                    'maximum_age', version.content_snapshot -> 'maximum_age',
                    'minimum_employment_months', version.content_snapshot -> 'minimum_employment_months',
                    'required_boolean_value', version.content_snapshot -> 'required_boolean_value',
                    'allowed_values', version.content_snapshot -> 'allowed_values',
                    'priority', version.content_snapshot -> 'priority',
                    'is_mandatory', version.content_snapshot -> 'is_mandatory',
                    'valid_from', version.content_snapshot -> 'valid_from',
                    'valid_to', version.content_snapshot -> 'valid_to'
                )) ORDER BY requirement.priority, requirement.id
            ), '[]'::JSONB)
            FROM effective_versions AS version
            JOIN public.card_eligibility_requirements AS requirement
              ON requirement.id = version.card_eligibility_requirement_id
             AND requirement.card_id = card.id
             AND requirement.is_active
             AND (requirement.valid_from IS NULL OR requirement.valid_from <= CURRENT_DATE)
             AND (requirement.valid_to IS NULL OR requirement.valid_to >= CURRENT_DATE)
            WHERE version.target_entity_type = 'CARD_ELIGIBILITY_REQUIREMENT'
              AND version.content_snapshot ->> 'id' = requirement.id::TEXT
              AND version.content_snapshot ->> 'card_id' = card.id::TEXT
        ),
        'merchants', (
            SELECT coalesce(pg_catalog.jsonb_agg(merchant_payload ORDER BY merchant_payload ->> 'slug'), '[]'::JSONB)
            FROM (
                SELECT DISTINCT pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
                    'id', merchant_version.content_snapshot -> 'id',
                    'slug', merchant_version.content_snapshot -> 'slug',
                    'display_name_en', merchant_version.content_snapshot -> 'display_name_en',
                    'display_name_ar', merchant_version.content_snapshot -> 'display_name_ar',
                    'description_en', merchant_version.content_snapshot -> 'description_en',
                    'description_ar', merchant_version.content_snapshot -> 'description_ar',
                    'merchant_classification', merchant_version.content_snapshot -> 'merchant_classification',
                    'channel_type', merchant_version.content_snapshot -> 'channel_type'
                )) AS merchant_payload
                FROM effective_versions AS rule_version
                JOIN public.reward_rules AS rule
                  ON rule.id = rule_version.reward_rule_id
                 AND rule.card_id = card.id AND rule.is_active
                JOIN public.reward_targets AS target
                  ON target.reward_rule_id = rule.id
                 AND (rule_version.content_snapshot -> 'target_ids') ? target.id::TEXT
                JOIN public.merchant_category_assignments AS assignment
                  ON assignment.merchant_category_id = target.merchant_category_id
                JOIN public.merchants AS merchant
                  ON merchant.id = assignment.merchant_id
                 AND merchant.lifecycle_status = 'ACTIVE'
                JOIN effective_versions AS merchant_version
                  ON merchant_version.target_entity_type = 'MERCHANT'
                 AND merchant_version.merchant_id = merchant.id
                 AND merchant_version.content_snapshot ->> 'id' = merchant.id::TEXT
                WHERE rule_version.target_entity_type = 'REWARD_RULE'
                  AND rule_version.content_snapshot ->> 'id' = rule.id::TEXT
                  AND rule_version.content_snapshot ->> 'card_id' = card.id::TEXT
                  AND pg_catalog.jsonb_typeof(rule_version.content_snapshot -> 'target_ids') = 'array'
            ) AS published_merchants
        ),
        'publication', pg_catalog.jsonb_build_object(
            'version_number', card.version_number,
            'effective_from', card.effective_from,
            'effective_until', card.effective_until,
            'published_at', card.version_published_at
        ),
        'provenance', (
            SELECT pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
                'source_type', provenance.source_type,
                'authority_level', provenance.authority_level,
                'source_locator_type', provenance.source_locator_type,
                'source_locator', provenance.source_locator,
                'source_title', provenance.source_title,
                'source_owner', provenance.source_owner,
                'source_version', provenance.source_version,
                'retrieved_at', provenance.retrieved_at,
                'verified_at', provenance.verified_at,
                'effective_from', provenance.effective_from,
                'effective_until', provenance.effective_until
            ))
            FROM public.catalog_source_provenance AS provenance
            WHERE provenance.id = card.source_provenance_id
              AND provenance.lifecycle_status = 'ACTIVE'
              AND provenance.verification_status = 'VERIFIED'
              AND (provenance.effective_from IS NULL OR provenance.effective_from <= CURRENT_DATE)
              AND (provenance.effective_until IS NULL OR provenance.effective_until >= CURRENT_DATE)
        )
    ) AS payload
    FROM card_context AS card
)
SELECT detail.payload FROM detail
$function$;

COMMENT ON FUNCTION public.get_published_card_detail(TEXT) IS
    'SECURITY DEFINER is required to read publication-governance snapshots without exposing those administrative tables. The function pins search_path, schema-qualifies objects, projects an explicit public allowlist, and returns only currently effective PUBLISHED card data and independently published governed relationships.';

REVOKE ALL ON FUNCTION public.get_published_card_detail(TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_published_card_detail(TEXT) FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_published_card_detail(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_published_card_detail(TEXT) TO service_role;

COMMIT;
