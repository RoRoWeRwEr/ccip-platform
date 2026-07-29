-- Migration 0047: merchants.
--
-- Establishes a reusable canonical merchant identity foundation for CCIP:
-- normalized merchant records (bilingual display names, optional bilingual
-- legal names, classification, channel, headquarters country, lifecycle and
-- verification state machines), alternate names/spellings for future
-- transaction-description matching, parent/subsidiary/brand/chain
-- relationships, category assignments against the existing
-- merchant_categories reference table, country market presence, and official
-- domains. It does not implement offers, publication governance, merchant
-- scraping/crawling, transaction ingestion, or automated/fuzzy merchant
-- matching — those remain future, separately authorized migrations.
--
-- Design notes:
--
-- * Canonical identity vs. hierarchy: rather than modeling "brand" and
--   "legal entity" as distinct table shapes, every merchant is one row in
--   `merchants`, and the relationship between a brand and its owning legal
--   entity (or a parent and its subsidiary, or a chain and its members) is
--   expressed as a typed edge in `merchant_relationships`. This mirrors how
--   `catalog_source_provenance` (0046) uses one typed discriminator rather
--   than inventing parallel table shapes per case, and keeps the object
--   count minimal while still satisfying every relationship shape asked for.
-- * Lifecycle vs. verification: as in 0046, `lifecycle_status` (operational
--   visibility: ACTIVE/INACTIVE/SUPERSEDED/ARCHIVED) and `verification_status`
--   (evidence quality: UNVERIFIED/VERIFIED/REJECTED) are independent axes.
--   Unlike 0046, ACTIVE and INACTIVE both reverse freely (a merchant can be
--   deactivated and reactivated), because "active and inactive merchants"
--   is an explicit, ordinary, reversible catalog-visibility toggle here —
--   SUPERSEDED (merged into a canonical successor) and ARCHIVED remain
--   terminal, exactly as in 0046, so merge/consolidation history is never
--   destroyed.
-- * Duplicate prevention: `slug` is the admin-chosen canonical dedup key
--   (this migration does not implement fuzzy/AI matching, so canonical
--   identity dedup is a deliberate admin decision, not inferred). Aliases
--   and domains are additionally unique among currently active rows
--   platform-wide, so an alternate name or domain resolves unambiguously to
--   at most one canonical merchant — the property future transaction-
--   description matching will depend on.
-- * Provenance integration with 0046 (forward-compatible extension, not a
--   rewrite): `catalog_source_provenance` cannot be edited (immutable merged
--   migration), so this migration extends it only via ALTER statements.
--   `target_entity_id` was a `GENERATED ALWAYS AS (...) STORED` column
--   computed from the original seven typed foreign keys; PostgreSQL has no
--   `ALTER COLUMN ... SET EXPRESSION`, so extending its formula to include
--   `merchant_id` requires either dropping and recreating the column, or
--   converting it to a plain column with `DROP EXPRESSION` (data-preserving,
--   PostgreSQL's documented mechanism for this exact case) and maintaining it
--   thereafter with a new trigger. This migration uses `DROP EXPRESSION` —
--   it preserves every existing stored value verbatim and touches none of
--   0046's existing indexes, constraints, or data, which is a materially
--   safer change than a column drop/recreate for what would otherwise be the
--   first `DROP COLUMN` in this repository's history. A new
--   `sync_catalog_source_provenance_target_entity_id()` trigger then
--   maintains the same COALESCE-of-typed-FKs value going forward, across all
--   eight now-eligible entity types, byte-for-byte reproducing 0046's
--   original formula for its seven pre-existing types.
-- * Known, deliberately accepted limitation: 0046's
--   `manage_catalog_source_provenance_change()` trigger independently
--   recomputes a local `target_id` from only the original seven typed
--   foreign keys (not `merchant_id`) to validate `superseded_by_provenance_id`
--   points at a provenance record for the *same* target. That function
--   cannot be edited (0046 is immutable), so for `target_entity_type =
--   'MERCHANT'` rows that local recomputation is always NULL and the
--   cross-record check would spuriously reject any successor link. Rather
--   than leave that as a latent trap, `chk_catalog_source_provenance_
--   merchant_no_successor_link` makes it an explicit, tested, enforced rule:
--   merchant provenance rows may still transition ACTIVE -> SUPERSEDED ->
--   ARCHIVED (superseded_at/archived_at are unaffected), they just cannot
--   also set the optional `superseded_by_provenance_id` successor pointer.
--   Every other 0046 behavior, for all seven pre-existing entity types, is
--   unchanged.

BEGIN;

CREATE TABLE public.merchants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    slug TEXT NOT NULL,

    display_name_en TEXT NOT NULL,
    display_name_ar TEXT NOT NULL,

    legal_name_en TEXT,
    legal_name_ar TEXT,

    merchant_classification TEXT NOT NULL DEFAULT 'OTHER',
    channel_type TEXT NOT NULL DEFAULT 'OMNICHANNEL',

    headquarters_country_id UUID
        REFERENCES public.countries(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    description_en TEXT,
    description_ar TEXT,

    lifecycle_status TEXT NOT NULL DEFAULT 'ACTIVE',
    superseded_at TIMESTAMPTZ,
    superseded_by_merchant_id UUID
        REFERENCES public.merchants(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    archived_at TIMESTAMPTZ,
    archived_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    verification_status TEXT NOT NULL DEFAULT 'UNVERIFIED',
    verified_at TIMESTAMPTZ,
    verified_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    rejected_at TIMESTAMPTZ,
    rejected_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    rejection_reason TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    updated_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_merchants_slug UNIQUE (slug),

    CONSTRAINT chk_merchants_slug
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),

    CONSTRAINT chk_merchants_display_name_en
        CHECK (length(trim(display_name_en)) BETWEEN 1 AND 300),
    CONSTRAINT chk_merchants_display_name_ar
        CHECK (length(trim(display_name_ar)) BETWEEN 1 AND 300),

    CONSTRAINT chk_merchants_legal_name_en
        CHECK (legal_name_en IS NULL OR length(trim(legal_name_en)) BETWEEN 1 AND 300),
    CONSTRAINT chk_merchants_legal_name_ar
        CHECK (legal_name_ar IS NULL OR length(trim(legal_name_ar)) BETWEEN 1 AND 300),

    CONSTRAINT chk_merchants_classification
        CHECK (
            merchant_classification IN (
                'MARKETPLACE',
                'GOVERNMENT',
                'UTILITY',
                'AIRLINE',
                'HOTEL',
                'RESTAURANT',
                'RETAIL',
                'FUEL',
                'HEALTHCARE',
                'EDUCATION',
                'TELECOM',
                'TRANSPORT',
                'ENTERTAINMENT',
                'FINANCIAL_SERVICES',
                'OTHER'
            )
        ),

    CONSTRAINT chk_merchants_channel_type
        CHECK (channel_type IN ('ONLINE_ONLY', 'PHYSICAL_ONLY', 'OMNICHANNEL')),

    CONSTRAINT chk_merchants_description_en
        CHECK (description_en IS NULL OR length(trim(description_en)) > 0),
    CONSTRAINT chk_merchants_description_ar
        CHECK (description_ar IS NULL OR length(trim(description_ar)) > 0),

    CONSTRAINT chk_merchants_lifecycle_status
        CHECK (lifecycle_status IN ('ACTIVE', 'INACTIVE', 'SUPERSEDED', 'ARCHIVED')),

    CONSTRAINT chk_merchants_lifecycle
        CHECK (
            (lifecycle_status IN ('ACTIVE', 'INACTIVE')
                AND superseded_at IS NULL AND superseded_by_merchant_id IS NULL
                AND archived_at IS NULL AND archived_by_user_id IS NULL)
            OR (lifecycle_status = 'SUPERSEDED'
                AND superseded_at IS NOT NULL
                AND archived_at IS NULL AND archived_by_user_id IS NULL)
            OR (lifecycle_status = 'ARCHIVED'
                AND archived_at IS NOT NULL AND archived_by_user_id IS NOT NULL)
        ),

    CONSTRAINT chk_merchants_supersedes_self
        CHECK (superseded_by_merchant_id IS NULL OR superseded_by_merchant_id <> id),

    CONSTRAINT chk_merchants_supersedes_lifecycle
        CHECK (
            superseded_by_merchant_id IS NULL
            OR lifecycle_status IN ('SUPERSEDED', 'ARCHIVED')
        ),

    CONSTRAINT chk_merchants_verification_status
        CHECK (verification_status IN ('UNVERIFIED', 'VERIFIED', 'REJECTED')),

    CONSTRAINT chk_merchants_verification
        CHECK (
            (verification_status = 'UNVERIFIED'
                AND verified_at IS NULL AND verified_by_user_id IS NULL
                AND rejected_at IS NULL AND rejected_by_user_id IS NULL AND rejection_reason IS NULL)
            OR (verification_status = 'VERIFIED'
                AND verified_at IS NOT NULL AND verified_by_user_id IS NOT NULL
                AND rejected_at IS NULL AND rejected_by_user_id IS NULL AND rejection_reason IS NULL)
            OR (verification_status = 'REJECTED'
                AND rejected_at IS NOT NULL AND rejected_by_user_id IS NOT NULL
                AND length(trim(rejection_reason)) BETWEEN 1 AND 1000)
        ),

    CONSTRAINT chk_merchants_rejected_is_archived
        CHECK (verification_status <> 'REJECTED' OR lifecycle_status = 'ARCHIVED'),

    CONSTRAINT chk_merchants_metadata
        CHECK (jsonb_typeof(metadata) = 'object'),

    CONSTRAINT chk_merchants_verified_after_created
        CHECK (verified_at IS NULL OR verified_at >= created_at),
    CONSTRAINT chk_merchants_rejected_after_created
        CHECK (rejected_at IS NULL OR rejected_at >= created_at),
    CONSTRAINT chk_merchants_rejected_after_verified
        CHECK (rejected_at IS NULL OR verified_at IS NULL OR rejected_at >= verified_at),
    CONSTRAINT chk_merchants_superseded_after_created
        CHECK (superseded_at IS NULL OR superseded_at >= created_at),
    CONSTRAINT chk_merchants_archived_after_created
        CHECK (archived_at IS NULL OR archived_at >= created_at),
    CONSTRAINT chk_merchants_archived_after_superseded
        CHECK (archived_at IS NULL OR superseded_at IS NULL OR archived_at >= superseded_at)
);

CREATE TABLE public.merchant_aliases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    merchant_id UUID NOT NULL
        REFERENCES public.merchants(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    alias TEXT NOT NULL,
    alias_language TEXT NOT NULL,
    alias_type TEXT NOT NULL DEFAULT 'ALTERNATE_NAME',

    normalized_alias TEXT GENERATED ALWAYS AS (lower(trim(alias))) STORED,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    notes TEXT,

    created_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    updated_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_merchant_aliases_merchant_normalized UNIQUE (merchant_id, normalized_alias),

    CONSTRAINT chk_merchant_aliases_alias
        CHECK (length(trim(alias)) BETWEEN 1 AND 300),
    CONSTRAINT chk_merchant_aliases_language
        CHECK (alias_language IN ('en', 'ar')),
    CONSTRAINT chk_merchant_aliases_type
        CHECK (
            alias_type IN (
                'ALTERNATE_NAME',
                'ABBREVIATION',
                'FORMER_NAME',
                'TRANSLATION',
                'MISSPELLING_VARIANT',
                'OTHER'
            )
        ),
    CONSTRAINT chk_merchant_aliases_notes
        CHECK (notes IS NULL OR length(trim(notes)) > 0)
);

CREATE TABLE public.merchant_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    parent_merchant_id UUID NOT NULL
        REFERENCES public.merchants(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    child_merchant_id UUID NOT NULL
        REFERENCES public.merchants(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    relationship_type TEXT NOT NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    notes TEXT,

    created_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    updated_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_merchant_relationships UNIQUE (parent_merchant_id, child_merchant_id, relationship_type),

    CONSTRAINT chk_merchant_relationships_type
        CHECK (relationship_type IN ('PARENT_SUBSIDIARY', 'BRAND_OF', 'CHAIN_MEMBER_OF')),
    CONSTRAINT chk_merchant_relationships_not_self
        CHECK (parent_merchant_id <> child_merchant_id),
    CONSTRAINT chk_merchant_relationships_notes
        CHECK (notes IS NULL OR length(trim(notes)) > 0)
);

-- Each child merchant may have at most one active parent per relationship
-- type, keeping every relationship type a forest rather than an arbitrary
-- graph; this is what makes the cycle check in
-- manage_merchant_child_change() a bounded, terminating traversal.
CREATE UNIQUE INDEX uq_merchant_relationships_single_active_parent
ON public.merchant_relationships(child_merchant_id, relationship_type)
WHERE is_active;

CREATE TABLE public.merchant_category_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    merchant_id UUID NOT NULL
        REFERENCES public.merchants(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    merchant_category_id UUID NOT NULL
        REFERENCES public.merchant_categories(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    created_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    updated_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_merchant_category_assignments UNIQUE (merchant_id, merchant_category_id)
);

CREATE UNIQUE INDEX uq_merchant_category_assignments_primary
ON public.merchant_category_assignments(merchant_id)
WHERE is_primary;

CREATE TABLE public.merchant_market_presence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    merchant_id UUID NOT NULL
        REFERENCES public.merchants(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    country_id UUID NOT NULL
        REFERENCES public.countries(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    presence_type TEXT NOT NULL DEFAULT 'PHYSICAL_AND_ONLINE',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    updated_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_merchant_market_presence UNIQUE (merchant_id, country_id),

    CONSTRAINT chk_merchant_market_presence_type
        CHECK (presence_type IN ('PHYSICAL_PRESENCE', 'ONLINE_PRESENCE', 'PHYSICAL_AND_ONLINE'))
);

CREATE TABLE public.merchant_domains (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    merchant_id UUID NOT NULL
        REFERENCES public.merchants(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    domain TEXT NOT NULL,
    domain_type TEXT NOT NULL DEFAULT 'OFFICIAL_WEBSITE',

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    updated_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_merchant_domains UNIQUE (merchant_id, domain),

    CONSTRAINT chk_merchant_domains_domain
        CHECK (
            domain ~ '^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?(\.[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?)+$'
        ),
    CONSTRAINT chk_merchant_domains_type
        CHECK (
            domain_type IN (
                'OFFICIAL_WEBSITE',
                'MOBILE_APP_LINK',
                'MARKETPLACE_STOREFRONT',
                'SOCIAL_MEDIA',
                'OTHER'
            )
        )
);

-- Global dedup: an active domain resolves unambiguously to one merchant.
CREATE UNIQUE INDEX uq_merchant_domains_active_global
ON public.merchant_domains(domain)
WHERE is_active;

CREATE UNIQUE INDEX uq_merchant_domains_primary
ON public.merchant_domains(merchant_id)
WHERE is_primary AND is_active;

-- Global dedup: an active alias resolves unambiguously to one merchant,
-- which is what future transaction-description matching will rely on.
CREATE UNIQUE INDEX uq_merchant_aliases_normalized_active
ON public.merchant_aliases(normalized_alias)
WHERE is_active;

CREATE INDEX idx_merchants_lifecycle_status
ON public.merchants(lifecycle_status);

CREATE INDEX idx_merchants_active
ON public.merchants(slug)
WHERE lifecycle_status = 'ACTIVE';

CREATE INDEX idx_merchants_verification_status
ON public.merchants(verification_status);

CREATE INDEX idx_merchants_classification
ON public.merchants(merchant_classification);

CREATE INDEX idx_merchants_channel_type
ON public.merchants(channel_type);

CREATE INDEX idx_merchants_headquarters_country
ON public.merchants(headquarters_country_id) WHERE headquarters_country_id IS NOT NULL;

CREATE INDEX idx_merchants_superseded_by
ON public.merchants(superseded_by_merchant_id) WHERE superseded_by_merchant_id IS NOT NULL;

CREATE INDEX idx_merchants_created_by
ON public.merchants(created_by_user_id) WHERE created_by_user_id IS NOT NULL;
CREATE INDEX idx_merchants_updated_by
ON public.merchants(updated_by_user_id) WHERE updated_by_user_id IS NOT NULL;
CREATE INDEX idx_merchants_verified_by
ON public.merchants(verified_by_user_id) WHERE verified_by_user_id IS NOT NULL;
CREATE INDEX idx_merchants_rejected_by
ON public.merchants(rejected_by_user_id) WHERE rejected_by_user_id IS NOT NULL;
CREATE INDEX idx_merchants_archived_by
ON public.merchants(archived_by_user_id) WHERE archived_by_user_id IS NOT NULL;

CREATE INDEX idx_merchant_aliases_merchant
ON public.merchant_aliases(merchant_id);
CREATE INDEX idx_merchant_aliases_active
ON public.merchant_aliases(normalized_alias) WHERE is_active;

CREATE INDEX idx_merchant_relationships_parent
ON public.merchant_relationships(parent_merchant_id);
CREATE INDEX idx_merchant_relationships_child
ON public.merchant_relationships(child_merchant_id);

CREATE INDEX idx_merchant_category_assignments_merchant
ON public.merchant_category_assignments(merchant_id);
CREATE INDEX idx_merchant_category_assignments_category
ON public.merchant_category_assignments(merchant_category_id);

CREATE INDEX idx_merchant_market_presence_merchant
ON public.merchant_market_presence(merchant_id);
CREATE INDEX idx_merchant_market_presence_country
ON public.merchant_market_presence(country_id);

CREATE INDEX idx_merchant_domains_merchant
ON public.merchant_domains(merchant_id);

CREATE OR REPLACE FUNCTION public.manage_merchant_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF current_user = 'authenticated' THEN
            NEW.created_by_user_id = auth.uid();
            NEW.updated_by_user_id = auth.uid();
        END IF;
    ELSE
        IF current_user = 'authenticated' THEN
            IF NEW.id IS DISTINCT FROM OLD.id
               OR NEW.created_by_user_id IS DISTINCT FROM OLD.created_by_user_id
               OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
                RAISE EXCEPTION 'merchant identity and creation fields may not be modified'
                    USING ERRCODE = '42501';
            END IF;

            IF OLD.lifecycle_status = 'ARCHIVED' THEN
                RAISE EXCEPTION 'archived merchant records are immutable; supersede or correct via a new record'
                    USING ERRCODE = '42501';
            END IF;

            IF NEW.lifecycle_status IS DISTINCT FROM OLD.lifecycle_status
               AND NOT (
                   (OLD.lifecycle_status = 'ACTIVE' AND NEW.lifecycle_status IN ('INACTIVE', 'SUPERSEDED', 'ARCHIVED'))
                   OR (OLD.lifecycle_status = 'INACTIVE' AND NEW.lifecycle_status IN ('ACTIVE', 'SUPERSEDED', 'ARCHIVED'))
                   OR (OLD.lifecycle_status = 'SUPERSEDED' AND NEW.lifecycle_status = 'ARCHIVED')
               ) THEN
                RAISE EXCEPTION 'invalid merchant lifecycle transition from % to %', OLD.lifecycle_status, NEW.lifecycle_status
                    USING ERRCODE = '23514';
            END IF;

            IF NEW.verification_status IS DISTINCT FROM OLD.verification_status
               AND NOT (
                   (OLD.verification_status = 'UNVERIFIED' AND NEW.verification_status IN ('VERIFIED', 'REJECTED'))
                   OR (OLD.verification_status = 'VERIFIED' AND NEW.verification_status = 'REJECTED')
               ) THEN
                RAISE EXCEPTION 'invalid merchant verification transition from % to %', OLD.verification_status, NEW.verification_status
                    USING ERRCODE = '23514';
            END IF;

            NEW.updated_by_user_id = auth.uid();
        END IF;

        IF NEW.verification_status = 'VERIFIED' AND OLD.verification_status IS DISTINCT FROM 'VERIFIED' THEN
            NEW.verified_at = COALESCE(NEW.verified_at, now());
            IF current_user = 'authenticated' THEN
                NEW.verified_by_user_id = auth.uid();
            END IF;
        END IF;

        IF NEW.verification_status = 'REJECTED' AND OLD.verification_status IS DISTINCT FROM 'REJECTED' THEN
            NEW.rejected_at = COALESCE(NEW.rejected_at, now());
            IF current_user = 'authenticated' THEN
                NEW.rejected_by_user_id = auth.uid();
            END IF;
            NEW.lifecycle_status = 'ARCHIVED';
            NEW.archived_at = COALESCE(NEW.archived_at, now());
            NEW.archived_by_user_id = COALESCE(NEW.archived_by_user_id, NEW.rejected_by_user_id);
        END IF;

        IF NEW.lifecycle_status = 'SUPERSEDED' AND OLD.lifecycle_status IS DISTINCT FROM 'SUPERSEDED' THEN
            NEW.superseded_at = COALESCE(NEW.superseded_at, now());
        END IF;

        IF NEW.lifecycle_status = 'ARCHIVED' AND OLD.lifecycle_status IS DISTINCT FROM 'ARCHIVED' THEN
            NEW.archived_at = COALESCE(NEW.archived_at, now());
            IF current_user = 'authenticated' THEN
                NEW.archived_by_user_id = COALESCE(NEW.archived_by_user_id, auth.uid());
            END IF;
        END IF;

        IF NEW.lifecycle_status = 'ACTIVE' AND OLD.lifecycle_status = 'INACTIVE' THEN
            NEW.superseded_at = NULL;
            NEW.superseded_by_merchant_id = NULL;
        END IF;
    END IF;

    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.manage_merchant_change() IS
    'SECURITY INVOKER trigger that protects immutable identity/creation fields, enforces valid lifecycle and verification transitions for authenticated administrators, forces rejected merchants to archive, and stamps administrator actors and derived timestamps.';

CREATE OR REPLACE FUNCTION public.manage_merchant_child_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
    IF TG_TABLE_NAME = 'merchant_relationships' AND TG_OP IN ('INSERT', 'UPDATE') THEN
        IF EXISTS (
            WITH RECURSIVE ancestors AS (
                SELECT parent_merchant_id AS ancestor_id
                FROM public.merchant_relationships
                WHERE child_merchant_id = NEW.parent_merchant_id
                  AND relationship_type = NEW.relationship_type
                  AND (TG_OP = 'INSERT' OR id <> NEW.id)
                UNION
                SELECT r.parent_merchant_id
                FROM public.merchant_relationships AS r
                JOIN ancestors AS a ON r.child_merchant_id = a.ancestor_id
                WHERE r.relationship_type = NEW.relationship_type
                  AND (TG_OP = 'INSERT' OR r.id <> NEW.id)
            )
            SELECT 1 FROM ancestors WHERE ancestor_id = NEW.child_merchant_id
        ) THEN
            RAISE EXCEPTION 'merchant relationship would create a hierarchy cycle for relationship_type %', NEW.relationship_type
                USING ERRCODE = '23514';
        END IF;
    END IF;

    IF TG_OP = 'INSERT' THEN
        IF current_user = 'authenticated' THEN
            NEW.created_by_user_id = auth.uid();
            NEW.updated_by_user_id = auth.uid();
        END IF;
    ELSE
        IF current_user = 'authenticated' THEN
            IF NEW.id IS DISTINCT FROM OLD.id
               OR NEW.created_by_user_id IS DISTINCT FROM OLD.created_by_user_id
               OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
                RAISE EXCEPTION 'protected identity and creation fields may not be modified'
                    USING ERRCODE = '42501';
            END IF;
            NEW.updated_by_user_id = auth.uid();
        END IF;
    END IF;

    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.manage_merchant_child_change() IS
    'SECURITY INVOKER trigger shared by merchant_aliases, merchant_relationships, merchant_category_assignments, merchant_market_presence, and merchant_domains: rejects hierarchy cycles for merchant_relationships specifically, protects identity/creation fields, and stamps administrator actors and updated_at.';

CREATE OR REPLACE FUNCTION public.sync_catalog_source_provenance_target_entity_id()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
    NEW.target_entity_id := COALESCE(
        NEW.bank_id, NEW.card_id, NEW.card_fee_id, NEW.card_benefit_id,
        NEW.reward_rule_id, NEW.loyalty_program_id, NEW.card_eligibility_requirement_id,
        NEW.merchant_id
    );
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.sync_catalog_source_provenance_target_entity_id() IS
    'SECURITY INVOKER trigger that maintains catalog_source_provenance.target_entity_id (a plain column since this migration, previously GENERATED ALWAYS AS STORED) across all eight eligible entity types, reproducing 0046''s original generation formula unchanged for its seven pre-existing types.';

CREATE OR REPLACE FUNCTION public.audit_merchant_catalog_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE
    changed_record JSONB;
    previous_record JSONB;
    changed_record_id UUID;
    parent_id UUID;
    audit_action TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        changed_record = to_jsonb(NEW);
        previous_record = NULL;
        changed_record_id = NEW.id;
    ELSIF TG_OP = 'UPDATE' THEN
        changed_record = to_jsonb(NEW);
        previous_record = to_jsonb(OLD);
        changed_record_id = NEW.id;
    ELSE
        changed_record = NULL;
        previous_record = to_jsonb(OLD);
        changed_record_id = OLD.id;
    END IF;

    IF TG_TABLE_NAME = 'merchants' THEN
        parent_id = NULL;
        audit_action = CASE
            WHEN TG_OP = 'DELETE' THEN 'DELETE'
            WHEN TG_OP = 'INSERT' THEN 'CREATE'
            WHEN NEW.verification_status = 'REJECTED' AND OLD.verification_status <> 'REJECTED' THEN 'REJECT'
            WHEN NEW.verification_status = 'VERIFIED' AND OLD.verification_status <> 'VERIFIED' THEN 'VERIFY'
            WHEN NEW.lifecycle_status = 'ARCHIVED' AND OLD.lifecycle_status <> 'ARCHIVED' THEN 'ARCHIVE'
            WHEN NEW.lifecycle_status = 'ACTIVE' AND OLD.lifecycle_status = 'INACTIVE' THEN 'ACTIVATE'
            WHEN NEW.lifecycle_status = 'INACTIVE' AND OLD.lifecycle_status = 'ACTIVE' THEN 'DEACTIVATE'
            ELSE 'UPDATE'
        END;
    ELSE
        parent_id = COALESCE((changed_record ->> 'merchant_id')::UUID, (previous_record ->> 'merchant_id')::UUID);
        audit_action = CASE TG_OP WHEN 'INSERT' THEN 'CREATE' WHEN 'DELETE' THEN 'DELETE' ELSE 'UPDATE' END;
    END IF;

    INSERT INTO public.audit_events (
        audit_reference,
        event_category,
        event_type,
        event_action,
        actor_type,
        actor_user_id,
        source_component,
        entity_type,
        entity_id,
        parent_entity_type,
        parent_entity_id,
        operation_name,
        data_classification,
        before_values,
        after_values,
        changed_fields,
        event_details
    )
    VALUES (
        'merchant-catalog.' || gen_random_uuid()::TEXT,
        'ADMINISTRATION',
        TG_TABLE_NAME || '_' || lower(TG_OP),
        audit_action,
        CASE WHEN auth.uid() IS NULL THEN 'SYSTEM' ELSE 'ADMIN' END,
        auth.uid(),
        'DATABASE_MERCHANT_CATALOG',
        TG_TABLE_NAME,
        changed_record_id,
        CASE WHEN TG_TABLE_NAME = 'merchants' THEN NULL ELSE 'merchant' END,
        parent_id,
        TG_OP,
        'INTERNAL',
        previous_record,
        changed_record,
        CASE
            WHEN TG_OP = 'UPDATE' THEN (
                SELECT COALESCE(jsonb_agg(key ORDER BY key), '[]'::JSONB)
                FROM jsonb_each(changed_record) AS current_value(key, value)
                WHERE previous_record -> key IS DISTINCT FROM value
            )
            ELSE '[]'::JSONB
        END,
        jsonb_build_object('trigger_operation', TG_OP)
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.audit_merchant_catalog_change() IS
    'SECURITY DEFINER is necessary so every merchant-catalog table mutation (merchants and its five child tables) is recorded in audit_events without granting callers direct audit-log writes. References are schema-qualified and search_path is pinned.';

CREATE TRIGGER trg_merchants_manage_change
BEFORE INSERT OR UPDATE ON public.merchants
FOR EACH ROW
EXECUTE FUNCTION public.manage_merchant_change();

CREATE TRIGGER trg_merchants_audit
AFTER INSERT OR UPDATE OR DELETE ON public.merchants
FOR EACH ROW
EXECUTE FUNCTION public.audit_merchant_catalog_change();

CREATE TRIGGER trg_merchant_aliases_manage_change
BEFORE INSERT OR UPDATE ON public.merchant_aliases
FOR EACH ROW
EXECUTE FUNCTION public.manage_merchant_child_change();
CREATE TRIGGER trg_merchant_aliases_audit
AFTER INSERT OR UPDATE OR DELETE ON public.merchant_aliases
FOR EACH ROW
EXECUTE FUNCTION public.audit_merchant_catalog_change();

CREATE TRIGGER trg_merchant_relationships_manage_change
BEFORE INSERT OR UPDATE ON public.merchant_relationships
FOR EACH ROW
EXECUTE FUNCTION public.manage_merchant_child_change();
CREATE TRIGGER trg_merchant_relationships_audit
AFTER INSERT OR UPDATE OR DELETE ON public.merchant_relationships
FOR EACH ROW
EXECUTE FUNCTION public.audit_merchant_catalog_change();

CREATE TRIGGER trg_merchant_category_assignments_manage_change
BEFORE INSERT OR UPDATE ON public.merchant_category_assignments
FOR EACH ROW
EXECUTE FUNCTION public.manage_merchant_child_change();
CREATE TRIGGER trg_merchant_category_assignments_audit
AFTER INSERT OR UPDATE OR DELETE ON public.merchant_category_assignments
FOR EACH ROW
EXECUTE FUNCTION public.audit_merchant_catalog_change();

CREATE TRIGGER trg_merchant_market_presence_manage_change
BEFORE INSERT OR UPDATE ON public.merchant_market_presence
FOR EACH ROW
EXECUTE FUNCTION public.manage_merchant_child_change();
CREATE TRIGGER trg_merchant_market_presence_audit
AFTER INSERT OR UPDATE OR DELETE ON public.merchant_market_presence
FOR EACH ROW
EXECUTE FUNCTION public.audit_merchant_catalog_change();

CREATE TRIGGER trg_merchant_domains_manage_change
BEFORE INSERT OR UPDATE ON public.merchant_domains
FOR EACH ROW
EXECUTE FUNCTION public.manage_merchant_child_change();
CREATE TRIGGER trg_merchant_domains_audit
AFTER INSERT OR UPDATE OR DELETE ON public.merchant_domains
FOR EACH ROW
EXECUTE FUNCTION public.audit_merchant_catalog_change();

ALTER TABLE public.merchants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchant_aliases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchant_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchant_category_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchant_market_presence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchant_domains ENABLE ROW LEVEL SECURITY;

CREATE POLICY catalog_read_active_merchants
ON public.merchants FOR SELECT TO anon, authenticated
USING (lifecycle_status = 'ACTIVE');

CREATE POLICY catalog_administrator_read_merchants
ON public.merchants FOR SELECT TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'));

CREATE POLICY catalog_administrator_create_merchants
ON public.merchants FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));

CREATE POLICY catalog_administrator_update_merchants
ON public.merchants FOR UPDATE TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'))
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));

CREATE POLICY catalog_read_active_merchant_aliases
ON public.merchant_aliases FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND EXISTS (SELECT 1 FROM public.merchants WHERE merchants.id = merchant_aliases.merchant_id AND merchants.lifecycle_status = 'ACTIVE')
);
CREATE POLICY catalog_administrator_read_merchant_aliases
ON public.merchant_aliases FOR SELECT TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_administrator_create_merchant_aliases
ON public.merchant_aliases FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_administrator_update_merchant_aliases
ON public.merchant_aliases FOR UPDATE TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'))
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));

CREATE POLICY catalog_read_active_merchant_relationships
ON public.merchant_relationships FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND EXISTS (SELECT 1 FROM public.merchants WHERE merchants.id = merchant_relationships.parent_merchant_id AND merchants.lifecycle_status = 'ACTIVE')
    AND EXISTS (SELECT 1 FROM public.merchants WHERE merchants.id = merchant_relationships.child_merchant_id AND merchants.lifecycle_status = 'ACTIVE')
);
CREATE POLICY catalog_administrator_read_merchant_relationships
ON public.merchant_relationships FOR SELECT TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_administrator_create_merchant_relationships
ON public.merchant_relationships FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_administrator_update_merchant_relationships
ON public.merchant_relationships FOR UPDATE TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'))
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));

CREATE POLICY catalog_read_active_merchant_category_assignments
ON public.merchant_category_assignments FOR SELECT TO anon, authenticated
USING (
    EXISTS (SELECT 1 FROM public.merchants WHERE merchants.id = merchant_category_assignments.merchant_id AND merchants.lifecycle_status = 'ACTIVE')
);
CREATE POLICY catalog_administrator_read_merchant_category_assignments
ON public.merchant_category_assignments FOR SELECT TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_administrator_create_merchant_category_assignments
ON public.merchant_category_assignments FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_administrator_update_merchant_category_assignments
ON public.merchant_category_assignments FOR UPDATE TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'))
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));

CREATE POLICY catalog_read_active_merchant_market_presence
ON public.merchant_market_presence FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND EXISTS (SELECT 1 FROM public.merchants WHERE merchants.id = merchant_market_presence.merchant_id AND merchants.lifecycle_status = 'ACTIVE')
);
CREATE POLICY catalog_administrator_read_merchant_market_presence
ON public.merchant_market_presence FOR SELECT TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_administrator_create_merchant_market_presence
ON public.merchant_market_presence FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_administrator_update_merchant_market_presence
ON public.merchant_market_presence FOR UPDATE TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'))
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));

CREATE POLICY catalog_read_active_merchant_domains
ON public.merchant_domains FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND EXISTS (SELECT 1 FROM public.merchants WHERE merchants.id = merchant_domains.merchant_id AND merchants.lifecycle_status = 'ACTIVE')
);
CREATE POLICY catalog_administrator_read_merchant_domains
ON public.merchant_domains FOR SELECT TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_administrator_create_merchant_domains
ON public.merchant_domains FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_administrator_update_merchant_domains
ON public.merchant_domains FOR UPDATE TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'))
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));

REVOKE ALL ON TABLE
    public.merchants,
    public.merchant_aliases,
    public.merchant_relationships,
    public.merchant_category_assignments,
    public.merchant_market_presence,
    public.merchant_domains
FROM PUBLIC, anon, authenticated;

REVOKE EXECUTE ON FUNCTION public.manage_merchant_change()
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.manage_merchant_child_change()
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.sync_catalog_source_provenance_target_entity_id()
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.audit_merchant_catalog_change()
FROM PUBLIC, anon, authenticated;

GRANT SELECT ON TABLE
    public.merchants,
    public.merchant_aliases,
    public.merchant_relationships,
    public.merchant_category_assignments,
    public.merchant_market_presence,
    public.merchant_domains
TO anon, authenticated;

GRANT INSERT, UPDATE ON TABLE
    public.merchants,
    public.merchant_aliases,
    public.merchant_relationships,
    public.merchant_category_assignments,
    public.merchant_market_presence,
    public.merchant_domains
TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
    public.merchants,
    public.merchant_aliases,
    public.merchant_relationships,
    public.merchant_category_assignments,
    public.merchant_market_presence,
    public.merchant_domains
TO service_role;

-- Forward-compatible provenance integration for merchants (0046 remains
-- unmodified; see the migration header note above for the target_entity_id
-- design decision).
ALTER TABLE public.catalog_source_provenance
    ADD COLUMN merchant_id UUID
        REFERENCES public.merchants(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

ALTER TABLE public.catalog_source_provenance
    ALTER COLUMN target_entity_id DROP EXPRESSION;

ALTER TABLE public.catalog_source_provenance
    DROP CONSTRAINT chk_catalog_source_provenance_target_type;
ALTER TABLE public.catalog_source_provenance
    ADD CONSTRAINT chk_catalog_source_provenance_target_type
        CHECK (
            target_entity_type IN (
                'BANK', 'CARD', 'CARD_FEE', 'CARD_BENEFIT',
                'REWARD_RULE', 'LOYALTY_PROGRAM', 'CARD_ELIGIBILITY_REQUIREMENT',
                'MERCHANT'
            )
        );

ALTER TABLE public.catalog_source_provenance
    DROP CONSTRAINT chk_catalog_source_provenance_target_match;
ALTER TABLE public.catalog_source_provenance
    ADD CONSTRAINT chk_catalog_source_provenance_target_match
        CHECK (
            (target_entity_type = 'BANK' AND bank_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id, merchant_id) = 1)
            OR (target_entity_type = 'CARD' AND card_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id, merchant_id) = 1)
            OR (target_entity_type = 'CARD_FEE' AND card_fee_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id, merchant_id) = 1)
            OR (target_entity_type = 'CARD_BENEFIT' AND card_benefit_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id, merchant_id) = 1)
            OR (target_entity_type = 'REWARD_RULE' AND reward_rule_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id, merchant_id) = 1)
            OR (target_entity_type = 'LOYALTY_PROGRAM' AND loyalty_program_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id, merchant_id) = 1)
            OR (target_entity_type = 'CARD_ELIGIBILITY_REQUIREMENT' AND card_eligibility_requirement_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id, merchant_id) = 1)
            OR (target_entity_type = 'MERCHANT' AND merchant_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id, merchant_id) = 1)
        );

ALTER TABLE public.catalog_source_provenance
    ADD CONSTRAINT chk_catalog_source_provenance_merchant_no_successor_link
        CHECK (target_entity_type <> 'MERCHANT' OR superseded_by_provenance_id IS NULL);

CREATE INDEX idx_catalog_source_provenance_merchant
ON public.catalog_source_provenance(merchant_id) WHERE merchant_id IS NOT NULL;

CREATE TRIGGER trg_catalog_source_provenance_sync_target_entity_id
BEFORE INSERT OR UPDATE ON public.catalog_source_provenance
FOR EACH ROW
EXECUTE FUNCTION public.sync_catalog_source_provenance_target_entity_id();

COMMENT ON COLUMN public.catalog_source_provenance.merchant_id IS
    'Added by migration 0047. Eighth eligible provenance target, alongside the seven typed foreign keys created in 0046.';
COMMENT ON COLUMN public.catalog_source_provenance.target_entity_id IS
    'Maintained by trg_catalog_source_provenance_sync_target_entity_id (migration 0047) since ALTER COLUMN ... DROP EXPRESSION converted it from a GENERATED ALWAYS AS STORED column to a plain, trigger-maintained one; existing stored values from migration 0046 are unchanged.';

COMMENT ON TABLE public.merchants IS
    'Canonical merchant identities referenced by future offers, reward rules, benefits, campaigns, loyalty programs, and transaction-description matching. Does not implement offers, publication governance, scraping, transaction ingestion, or automated matching.';
COMMENT ON COLUMN public.merchants.slug IS
    'Admin-chosen canonical dedup key; this migration performs no automated or fuzzy merchant deduplication.';
COMMENT ON COLUMN public.merchants.lifecycle_status IS
    'ACTIVE and INACTIVE toggle freely (ordinary catalog visibility); SUPERSEDED (merged into superseded_by_merchant_id) and ARCHIVED are terminal, preserving merge/consolidation history.';
COMMENT ON COLUMN public.merchants.superseded_by_merchant_id IS
    'Optional pointer to the canonical merchant this record was merged/consolidated into; the superseded row is retained, never deleted.';
COMMENT ON COLUMN public.merchants.verification_status IS
    'UNVERIFIED, VERIFIED, or REJECTED; VERIFIED requires verified_at/verified_by_user_id, REJECTED requires rejected_at/rejected_by_user_id/rejection_reason and forces lifecycle_status to ARCHIVED.';

COMMENT ON TABLE public.merchant_aliases IS
    'Alternate names, abbreviations, former names, translations, and spelling variants for a merchant; normalized_alias is globally unique among active rows so an alias resolves to exactly one merchant.';
COMMENT ON TABLE public.merchant_relationships IS
    'Typed edges between merchants: PARENT_SUBSIDIARY, BRAND_OF (a public brand and its owning legal entity), or CHAIN_MEMBER_OF. Each child has at most one active parent per relationship_type, and manage_merchant_child_change() rejects any edge that would create a cycle.';
COMMENT ON TABLE public.merchant_category_assignments IS
    'Assigns a merchant to one or more existing merchant_categories rows (created in migration 0004); at most one assignment per merchant may be marked is_primary.';
COMMENT ON TABLE public.merchant_market_presence IS
    'Countries (from the existing countries reference table) where a merchant has a physical, online, or omnichannel presence.';
COMMENT ON TABLE public.merchant_domains IS
    'Official websites, mobile app links, marketplace storefronts, and social media domains for a merchant; domain is globally unique among active rows so a domain resolves to exactly one merchant.';

COMMIT;
