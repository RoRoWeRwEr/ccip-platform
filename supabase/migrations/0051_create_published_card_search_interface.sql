-- Migration 0051: publication-aware, read-only card list/search for P3.4.
-- Governed values are read only from effective PUBLISHED snapshots. Core rows
-- are used solely to validate active typed relationships and reference data.

BEGIN;

CREATE INDEX idx_catalog_publication_versions_public_read
ON public.catalog_publication_versions(target_entity_type, target_entity_id, effective_from, effective_until)
WHERE lifecycle_status = 'PUBLISHED';

CREATE OR REPLACE FUNCTION public.search_published_cards(
    requested_locale TEXT DEFAULT 'en',
    requested_search TEXT DEFAULT NULL,
    requested_bank_slug TEXT DEFAULT NULL,
    requested_network_slug TEXT DEFAULT NULL,
    requested_max_annual_fee NUMERIC DEFAULT NULL,
    requested_persona TEXT DEFAULT NULL,
    requested_maximum_salary NUMERIC DEFAULT NULL,
    requested_reward_type TEXT DEFAULT NULL,
    requested_reward_category_slug TEXT DEFAULT NULL,
    requested_min_reward_value NUMERIC DEFAULT NULL,
    requested_sort TEXT DEFAULT 'PUBLISHED_DESC',
    requested_page INTEGER DEFAULT 1,
    requested_page_size INTEGER DEFAULT 12
)
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog
AS $function$
WITH parameters AS (
    SELECT
        CASE WHEN requested_locale = 'ar' THEN 'ar' ELSE 'en' END AS locale,
        NULLIF(pg_catalog.left(pg_catalog.btrim(requested_search), 100), '') AS search_term,
        NULLIF(pg_catalog.btrim(requested_bank_slug), '') AS bank_slug,
        NULLIF(pg_catalog.btrim(requested_network_slug), '') AS network_slug,
        CASE WHEN requested_max_annual_fee >= 0 THEN requested_max_annual_fee END AS max_annual_fee,
        NULLIF(pg_catalog.btrim(requested_persona), '') AS persona,
        CASE WHEN requested_maximum_salary >= 0 THEN requested_maximum_salary END AS maximum_salary,
        NULLIF(pg_catalog.btrim(requested_reward_type), '') AS reward_type,
        NULLIF(pg_catalog.btrim(requested_reward_category_slug), '') AS reward_category_slug,
        CASE WHEN requested_min_reward_value >= 0 THEN requested_min_reward_value END AS min_reward_value,
        CASE WHEN requested_sort IN ('PUBLISHED_DESC','NAME_ASC','ANNUAL_FEE_ASC','ANNUAL_FEE_DESC','REWARD_VALUE_DESC')
             THEN requested_sort ELSE 'PUBLISHED_DESC' END AS sort_key,
        GREATEST(COALESCE(requested_page, 1), 1) AS page_number,
        LEAST(GREATEST(COALESCE(requested_page_size, 12), 1), 50) AS page_size
),
effective_versions AS (
    SELECT version.target_entity_type, version.target_entity_id, version.bank_id,
           version.card_id, version.reward_rule_id, version.version_number,
           version.content_snapshot, version.effective_from,
           version.effective_until, version.published_at
    FROM public.catalog_publication_versions AS version
    WHERE version.lifecycle_status = 'PUBLISHED'
      AND version.effective_from <= pg_catalog.now()
      AND (version.effective_until IS NULL OR version.effective_until > pg_catalog.now())
      AND (version.scheduled_unpublish_at IS NULL OR version.scheduled_unpublish_at > pg_catalog.now())
),
published_rewards AS (
    SELECT rule.card_id, version.content_snapshot,
           CASE WHEN version.content_snapshot ->> 'reward_value' ~ '^[0-9]+(?:\.[0-9]+)?$'
                THEN (version.content_snapshot ->> 'reward_value')::NUMERIC END AS reward_value,
           category.slug AS reward_category_slug,
           (SELECT COALESCE(pg_catalog.jsonb_agg(
                       pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
                           'target_type', target.target_type,
                           'category_slug', target.category_slug,
                           'merchant_category_slug', merchant_category.slug
                       )) ORDER BY target.id), '[]'::JSONB)
              FROM public.reward_targets AS target
              LEFT JOIN public.merchant_categories AS merchant_category
                ON merchant_category.id = target.merchant_category_id
               AND merchant_category.is_active
             WHERE target.reward_rule_id = rule.id
               AND pg_catalog.jsonb_typeof(version.content_snapshot -> 'target_ids') = 'array'
               AND (version.content_snapshot -> 'target_ids') ? target.id::TEXT) AS targets
    FROM effective_versions AS version
    JOIN public.reward_rules AS rule
      ON rule.id = version.reward_rule_id
     AND rule.is_active
     AND (rule.valid_from IS NULL OR rule.valid_from <= CURRENT_DATE)
     AND (rule.valid_to IS NULL OR rule.valid_to >= CURRENT_DATE)
    LEFT JOIN public.reward_categories AS category
      ON category.id = rule.reward_category_id AND category.is_active
    WHERE version.target_entity_type = 'REWARD_RULE'
      AND version.content_snapshot ->> 'id' = rule.id::TEXT
      AND version.content_snapshot ->> 'card_id' = rule.card_id::TEXT
      AND (rule.reward_category_id IS NULL
           OR version.content_snapshot ->> 'reward_category_id' = rule.reward_category_id::TEXT)
),
card_rows AS (
    SELECT card.id, card.bank_id, card.card_network_id,
           version.content_snapshot, version.version_number,
           version.effective_from, version.effective_until, version.published_at,
           bank_version.content_snapshot AS bank_snapshot,
           network.slug AS card_network_slug, network.name_en AS network_name_en,
           network.name_ar AS network_name_ar, network.logo_url AS network_logo_url,
           CASE WHEN version.content_snapshot ->> 'annual_fee' ~ '^[0-9]+(?:\.[0-9]+)?$'
                THEN (version.content_snapshot ->> 'annual_fee')::NUMERIC END AS annual_fee,
           CASE WHEN version.content_snapshot ->> 'minimum_salary' ~ '^[0-9]+(?:\.[0-9]+)?$'
                THEN (version.content_snapshot ->> 'minimum_salary')::NUMERIC END AS minimum_salary,
           reward_summary.rewards, reward_summary.maximum_reward_value
    FROM effective_versions AS version
    JOIN public.cards AS card
      ON card.id = version.card_id AND card.is_active
     AND card.availability_status = 'AVAILABLE'
     AND card.published_at IS NOT NULL AND card.published_at <= pg_catalog.now()
    JOIN public.banks AS bank ON bank.id = card.bank_id AND bank.is_active
    JOIN effective_versions AS bank_version
      ON bank_version.target_entity_type = 'BANK' AND bank_version.bank_id = bank.id
     AND bank_version.content_snapshot ->> 'id' = bank.id::TEXT
    JOIN public.card_networks AS network
      ON network.id = card.card_network_id AND network.is_active
    JOIN public.currencies AS currency
      ON currency.id = card.currency_id AND currency.is_active
    LEFT JOIN LATERAL (
        SELECT COALESCE(pg_catalog.jsonb_agg(
                   pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
                       'reward_type', reward.content_snapshot -> 'reward_type',
                       'reward_value', reward.content_snapshot -> 'reward_value',
                       'calculation_method', reward.content_snapshot -> 'calculation_method',
                       'reward_category_slug', reward.reward_category_slug,
                       'targets', reward.targets
                   )) ORDER BY reward.reward_value DESC NULLS LAST), '[]'::JSONB) AS rewards,
               pg_catalog.max(reward.reward_value) AS maximum_reward_value
        FROM published_rewards AS reward WHERE reward.card_id = card.id
    ) AS reward_summary ON TRUE
    WHERE version.target_entity_type = 'CARD'
      AND version.content_snapshot ->> 'id' = card.id::TEXT
      AND version.content_snapshot ->> 'slug' = card.slug
      AND version.content_snapshot ->> 'bank_id' = card.bank_id::TEXT
      AND version.content_snapshot ->> 'card_network_id' = card.card_network_id::TEXT
      AND version.content_snapshot ->> 'currency_id' = card.currency_id::TEXT
),
filtered AS (
    SELECT row.*, parameters.*
    FROM card_rows AS row CROSS JOIN parameters
    WHERE (parameters.search_term IS NULL OR pg_catalog.strpos(
              pg_catalog.lower(CASE WHEN parameters.locale = 'ar'
                  THEN row.content_snapshot ->> 'name_ar'
                  ELSE row.content_snapshot ->> 'name_en' END),
              pg_catalog.lower(parameters.search_term)) > 0)
      AND (parameters.bank_slug IS NULL OR row.bank_snapshot ->> 'slug' = parameters.bank_slug)
      AND (parameters.network_slug IS NULL OR row.card_network_slug = parameters.network_slug)
      AND (parameters.max_annual_fee IS NULL OR row.annual_fee <= parameters.max_annual_fee)
      AND (parameters.persona IS NULL OR row.content_snapshot ->> 'target_user' = parameters.persona)
      AND (parameters.maximum_salary IS NULL OR row.minimum_salary <= parameters.maximum_salary)
      AND ((parameters.reward_type IS NULL AND parameters.reward_category_slug IS NULL
            AND parameters.min_reward_value IS NULL) OR EXISTS (
          SELECT 1 FROM published_rewards AS reward
          WHERE reward.card_id = row.id
            AND (parameters.reward_type IS NULL OR reward.content_snapshot ->> 'reward_type' = parameters.reward_type)
            AND (parameters.reward_category_slug IS NULL OR reward.reward_category_slug = parameters.reward_category_slug
                 OR EXISTS (SELECT 1 FROM pg_catalog.jsonb_array_elements(reward.targets) AS target(value)
                            WHERE target.value ->> 'category_slug' = parameters.reward_category_slug
                               OR target.value ->> 'merchant_category_slug' = parameters.reward_category_slug))
            AND (parameters.min_reward_value IS NULL OR reward.reward_value >= parameters.min_reward_value)))
),
ordered AS (
    SELECT filtered.*, pg_catalog.count(*) OVER () AS total_count
    FROM filtered
    ORDER BY
      CASE WHEN sort_key = 'NAME_ASC' THEN pg_catalog.lower(CASE WHEN locale='ar' THEN content_snapshot->>'name_ar' ELSE content_snapshot->>'name_en' END) END ASC,
      CASE WHEN sort_key = 'ANNUAL_FEE_ASC' THEN annual_fee END ASC NULLS LAST,
      CASE WHEN sort_key = 'ANNUAL_FEE_DESC' THEN annual_fee END DESC NULLS LAST,
      CASE WHEN sort_key = 'REWARD_VALUE_DESC' THEN maximum_reward_value END DESC NULLS LAST,
      CASE WHEN sort_key = 'PUBLISHED_DESC' THEN published_at END DESC,
      id ASC
),
paged AS (
    SELECT * FROM ordered
    OFFSET ((SELECT page_number - 1 FROM parameters) * (SELECT page_size FROM parameters))
    LIMIT (SELECT page_size FROM parameters)
)
SELECT pg_catalog.jsonb_build_object(
    'items', COALESCE((SELECT pg_catalog.jsonb_agg(
        pg_catalog.jsonb_build_object(
          'card', pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
            'id', content_snapshot->'id', 'slug', content_snapshot->'slug',
            'name_en', content_snapshot->'name_en', 'name_ar', content_snapshot->'name_ar',
            'card_tier', content_snapshot->'card_tier', 'target_user', content_snapshot->'target_user',
            'annual_fee', content_snapshot->'annual_fee', 'minimum_salary', content_snapshot->'minimum_salary',
            'image_url', content_snapshot->'image_url', 'is_featured', content_snapshot->'is_featured')),
          'bank', pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
            'id', bank_snapshot->'id', 'slug', bank_snapshot->'slug',
            'name_en', bank_snapshot->'name_en', 'name_ar', bank_snapshot->'name_ar',
            'logo_url', bank_snapshot->'logo_url')),
          'network', pg_catalog.jsonb_strip_nulls(pg_catalog.jsonb_build_object(
            'slug', card_network_slug, 'name_en', network_name_en,
            'name_ar', network_name_ar, 'logo_url', network_logo_url)),
          'reward_summary', rewards,
          'publication', pg_catalog.jsonb_build_object('version_number', version_number,
            'effective_from', effective_from, 'effective_until', effective_until,
            'published_at', published_at)) ORDER BY
          CASE WHEN sort_key = 'NAME_ASC' THEN pg_catalog.lower(CASE WHEN locale='ar' THEN content_snapshot->>'name_ar' ELSE content_snapshot->>'name_en' END) END ASC,
          CASE WHEN sort_key = 'ANNUAL_FEE_ASC' THEN annual_fee END ASC NULLS LAST,
          CASE WHEN sort_key = 'ANNUAL_FEE_DESC' THEN annual_fee END DESC NULLS LAST,
          CASE WHEN sort_key = 'REWARD_VALUE_DESC' THEN maximum_reward_value END DESC NULLS LAST,
          CASE WHEN sort_key = 'PUBLISHED_DESC' THEN published_at END DESC, id ASC) FROM paged), '[]'::JSONB),
    'page', (SELECT page_number FROM parameters),
    'page_size', (SELECT page_size FROM parameters),
    'total_count', COALESCE((SELECT pg_catalog.max(total_count) FROM ordered), 0),
    'total_pages', CASE WHEN (SELECT pg_catalog.count(*) FROM filtered) = 0 THEN 0
        ELSE pg_catalog.ceil((SELECT pg_catalog.count(*) FROM filtered)::NUMERIC / (SELECT page_size FROM parameters))::INTEGER END
)
$function$;

COMMENT ON FUNCTION public.search_published_cards(TEXT,TEXT,TEXT,TEXT,NUMERIC,TEXT,NUMERIC,TEXT,TEXT,NUMERIC,TEXT,INTEGER,INTEGER) IS
    'SECURITY DEFINER permits a bounded read of 0048 publication snapshots without granting access to governance tables. The pinned, schema-qualified function exposes an explicit public allowlist and only independently effective PUBLISHED card, bank, and reward data.';

REVOKE ALL ON FUNCTION public.search_published_cards(TEXT,TEXT,TEXT,TEXT,NUMERIC,TEXT,NUMERIC,TEXT,TEXT,NUMERIC,TEXT,INTEGER,INTEGER) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.search_published_cards(TEXT,TEXT,TEXT,TEXT,NUMERIC,TEXT,NUMERIC,TEXT,TEXT,NUMERIC,TEXT,INTEGER,INTEGER) FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.search_published_cards(TEXT,TEXT,TEXT,TEXT,NUMERIC,TEXT,NUMERIC,TEXT,TEXT,NUMERIC,TEXT,INTEGER,INTEGER) TO anon, authenticated, service_role;

COMMIT;
