-- Migration 0052: bounded publication-aware recommendation candidate read model.

BEGIN;

ALTER TABLE public.cards
ADD COLUMN is_recommendation_eligible BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX idx_cards_recommendation_candidates
ON public.cards(id)
WHERE is_active AND is_recommendation_eligible
  AND availability_status = 'AVAILABLE' AND published_at IS NOT NULL;

CREATE OR REPLACE FUNCTION public.get_published_recommendation_candidates()
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog
AS $function$
SELECT COALESCE(pg_catalog.jsonb_agg(candidate.detail ORDER BY candidate.card_id), '[]'::JSONB)
FROM (
    SELECT card.id AS card_id, public.get_published_card_detail(card.slug) AS detail
    FROM public.catalog_publication_versions AS version
    JOIN public.cards AS card
      ON card.id = version.card_id
     AND card.is_active
     AND card.is_recommendation_eligible
     AND card.availability_status = 'AVAILABLE'
     AND card.published_at IS NOT NULL
     AND card.published_at <= pg_catalog.now()
    WHERE version.target_entity_type = 'CARD'
      AND version.lifecycle_status = 'PUBLISHED'
      AND version.effective_from <= pg_catalog.now()
      AND (version.effective_until IS NULL OR version.effective_until > pg_catalog.now())
      AND (version.scheduled_unpublish_at IS NULL OR version.scheduled_unpublish_at > pg_catalog.now())
      AND version.content_snapshot ->> 'id' = card.id::TEXT
      AND version.content_snapshot ->> 'slug' = card.slug
      AND version.content_snapshot ->> 'is_recommendation_eligible' = 'true'
    ORDER BY card.id
    LIMIT 50
) AS candidate
WHERE candidate.detail IS NOT NULL;
$function$;

COMMENT ON COLUMN public.cards.is_recommendation_eligible IS
    'Defense-in-depth core eligibility gate. Public recommendation requires this flag and an explicit true value in the currently effective published CARD snapshot.';
COMMENT ON FUNCTION public.get_published_recommendation_candidates() IS
    'SECURITY DEFINER provides at most 50 candidates through migration 0050 detail projections. Candidates must be active, available, core-eligible, and explicitly recommendation-eligible in an effective PUBLISHED snapshot.';

REVOKE ALL ON FUNCTION public.get_published_recommendation_candidates() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_published_recommendation_candidates() FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_published_recommendation_candidates() TO anon, authenticated, service_role;

COMMIT;
