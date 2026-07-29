-- Migration 0046: catalog source provenance.
--
-- Records where catalog evidence came from (official bank/product/terms/fee/
-- rewards/loyalty/regulatory sources or approved manual entry), when it was
-- retrieved and verified, and which catalog entity it supports. This is a
-- foundation for later catalog publication governance; it does not itself
-- implement publication approval, web crawling/scraping, document storage,
-- or automated reconciliation.
--
-- Design note (polymorphic vs. explicit target reference): this table uses
-- one nullable, typed foreign key per eligible entity type (bank_id, card_id,
-- card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id,
-- card_eligibility_requirement_id) rather than a bare (entity_type, entity_id)
-- pair. A CHECK constraint requires exactly one of these to be populated and
-- to match target_entity_type. This makes "reject unsupported entity types"
-- and "reject missing target entities" real, always-enforced FK/CHECK
-- constraints rather than a trigger-only convention that a service-role
-- write could bypass. A GENERATED STORED target_entity_id column then gives
-- a single, uniform identifier for indexing, deduplication, and audit
-- references without sacrificing referential integrity.

BEGIN;

CREATE TABLE public.catalog_source_provenance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    target_entity_type TEXT NOT NULL,

    bank_id UUID
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    card_fee_id UUID
        REFERENCES public.card_fees(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    card_benefit_id UUID
        REFERENCES public.card_benefits(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    reward_rule_id UUID
        REFERENCES public.reward_rules(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    loyalty_program_id UUID
        REFERENCES public.loyalty_programs(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    card_eligibility_requirement_id UUID
        REFERENCES public.card_eligibility_requirements(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    target_entity_id UUID GENERATED ALWAYS AS (
        COALESCE(
            bank_id, card_id, card_fee_id, card_benefit_id,
            reward_rule_id, loyalty_program_id, card_eligibility_requirement_id
        )
    ) STORED,

    source_type TEXT NOT NULL,
    authority_level TEXT NOT NULL,

    source_locator_type TEXT NOT NULL DEFAULT 'URL',
    source_locator TEXT NOT NULL,
    source_title TEXT NOT NULL,
    source_owner TEXT NOT NULL,
    source_version TEXT,

    content_hash TEXT,

    retrieved_at TIMESTAMPTZ NOT NULL DEFAULT now(),

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

    lifecycle_status TEXT NOT NULL DEFAULT 'ACTIVE',
    superseded_at TIMESTAMPTZ,
    superseded_by_provenance_id UUID
        REFERENCES public.catalog_source_provenance(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    archived_at TIMESTAMPTZ,
    archived_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    effective_from DATE,
    effective_until DATE,

    notes TEXT,
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

    CONSTRAINT chk_catalog_source_provenance_target_type
        CHECK (
            target_entity_type IN (
                'BANK', 'CARD', 'CARD_FEE', 'CARD_BENEFIT',
                'REWARD_RULE', 'LOYALTY_PROGRAM', 'CARD_ELIGIBILITY_REQUIREMENT'
            )
        ),

    CONSTRAINT chk_catalog_source_provenance_target_match
        CHECK (
            (target_entity_type = 'BANK' AND bank_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id) = 1)
            OR (target_entity_type = 'CARD' AND card_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id) = 1)
            OR (target_entity_type = 'CARD_FEE' AND card_fee_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id) = 1)
            OR (target_entity_type = 'CARD_BENEFIT' AND card_benefit_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id) = 1)
            OR (target_entity_type = 'REWARD_RULE' AND reward_rule_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id) = 1)
            OR (target_entity_type = 'LOYALTY_PROGRAM' AND loyalty_program_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id) = 1)
            OR (target_entity_type = 'CARD_ELIGIBILITY_REQUIREMENT' AND card_eligibility_requirement_id IS NOT NULL
                AND num_nonnulls(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id, loyalty_program_id, card_eligibility_requirement_id) = 1)
        ),

    CONSTRAINT chk_catalog_source_provenance_source_type
        CHECK (
            source_type IN (
                'OFFICIAL_BANK_WEBSITE',
                'OFFICIAL_PRODUCT_PAGE',
                'OFFICIAL_TERMS_AND_CONDITIONS',
                'OFFICIAL_FEE_SCHEDULE',
                'OFFICIAL_REWARDS_DOCUMENTATION',
                'OFFICIAL_LOYALTY_PROGRAM_DOCUMENTATION',
                'OFFICIAL_REGULATORY_SOURCE',
                'MANUAL_ENTRY_APPROVED',
                'OTHER'
            )
        ),

    CONSTRAINT chk_catalog_source_provenance_authority_level
        CHECK (
            authority_level IN (
                'OFFICIAL_PRIMARY',
                'OFFICIAL_REGULATORY',
                'AUTHORIZED_SECONDARY',
                'UNVERIFIED_SECONDARY'
            )
        ),

    CONSTRAINT chk_catalog_source_provenance_locator_type
        CHECK (source_locator_type IN ('URL', 'DOCUMENT_REFERENCE', 'OTHER')),

    CONSTRAINT chk_catalog_source_provenance_locator
        CHECK (length(trim(source_locator)) BETWEEN 1 AND 2048),

    CONSTRAINT chk_catalog_source_provenance_locator_url_format
        CHECK (
            source_locator_type <> 'URL'
            OR source_locator ~ '^[a-zA-Z][a-zA-Z0-9+.-]*://\S+$'
        ),

    CONSTRAINT chk_catalog_source_provenance_title
        CHECK (length(trim(source_title)) BETWEEN 1 AND 500),

    CONSTRAINT chk_catalog_source_provenance_owner
        CHECK (length(trim(source_owner)) BETWEEN 1 AND 300),

    CONSTRAINT chk_catalog_source_provenance_version
        CHECK (source_version IS NULL OR length(trim(source_version)) BETWEEN 1 AND 200),

    CONSTRAINT chk_catalog_source_provenance_content_hash
        CHECK (content_hash IS NULL OR content_hash ~ '^[0-9a-f]{64}$'),

    CONSTRAINT chk_catalog_source_provenance_notes
        CHECK (notes IS NULL OR length(trim(notes)) > 0),

    CONSTRAINT chk_catalog_source_provenance_metadata
        CHECK (jsonb_typeof(metadata) = 'object'),

    CONSTRAINT chk_catalog_source_provenance_verification_status
        CHECK (verification_status IN ('UNVERIFIED', 'VERIFIED', 'REJECTED')),

    CONSTRAINT chk_catalog_source_provenance_verification
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

    CONSTRAINT chk_catalog_source_provenance_lifecycle_status
        CHECK (lifecycle_status IN ('ACTIVE', 'SUPERSEDED', 'ARCHIVED')),

    CONSTRAINT chk_catalog_source_provenance_lifecycle
        CHECK (
            (lifecycle_status = 'ACTIVE'
                AND superseded_at IS NULL AND superseded_by_provenance_id IS NULL
                AND archived_at IS NULL AND archived_by_user_id IS NULL)
            OR (lifecycle_status = 'SUPERSEDED'
                AND superseded_at IS NOT NULL
                AND archived_at IS NULL AND archived_by_user_id IS NULL)
            OR (lifecycle_status = 'ARCHIVED'
                AND archived_at IS NOT NULL AND archived_by_user_id IS NOT NULL)
        ),

    CONSTRAINT chk_catalog_source_provenance_rejected_is_archived
        CHECK (verification_status <> 'REJECTED' OR lifecycle_status = 'ARCHIVED'),

    CONSTRAINT chk_catalog_source_provenance_supersedes_self
        CHECK (superseded_by_provenance_id IS NULL OR superseded_by_provenance_id <> id),

    CONSTRAINT chk_catalog_source_provenance_supersedes_lifecycle
        CHECK (
            superseded_by_provenance_id IS NULL
            OR lifecycle_status IN ('SUPERSEDED', 'ARCHIVED')
        ),

    CONSTRAINT chk_catalog_source_provenance_effective_range
        CHECK (effective_until IS NULL OR effective_from IS NULL OR effective_until >= effective_from),

    CONSTRAINT chk_catalog_source_provenance_verified_after_retrieved
        CHECK (verified_at IS NULL OR verified_at >= retrieved_at),

    CONSTRAINT chk_catalog_source_provenance_rejected_after_retrieved
        CHECK (rejected_at IS NULL OR rejected_at >= retrieved_at),

    CONSTRAINT chk_catalog_source_provenance_rejected_after_verified
        CHECK (rejected_at IS NULL OR verified_at IS NULL OR rejected_at >= verified_at),

    CONSTRAINT chk_catalog_source_provenance_superseded_after_retrieved
        CHECK (superseded_at IS NULL OR superseded_at >= retrieved_at),

    CONSTRAINT chk_catalog_source_provenance_archived_after_retrieved
        CHECK (archived_at IS NULL OR archived_at >= retrieved_at),

    CONSTRAINT chk_catalog_source_provenance_archived_after_superseded
        CHECK (archived_at IS NULL OR superseded_at IS NULL OR archived_at >= superseded_at)
);

CREATE INDEX idx_catalog_source_provenance_bank
ON public.catalog_source_provenance(bank_id) WHERE bank_id IS NOT NULL;

CREATE INDEX idx_catalog_source_provenance_card
ON public.catalog_source_provenance(card_id) WHERE card_id IS NOT NULL;

CREATE INDEX idx_catalog_source_provenance_card_fee
ON public.catalog_source_provenance(card_fee_id) WHERE card_fee_id IS NOT NULL;

CREATE INDEX idx_catalog_source_provenance_card_benefit
ON public.catalog_source_provenance(card_benefit_id) WHERE card_benefit_id IS NOT NULL;

CREATE INDEX idx_catalog_source_provenance_reward_rule
ON public.catalog_source_provenance(reward_rule_id) WHERE reward_rule_id IS NOT NULL;

CREATE INDEX idx_catalog_source_provenance_loyalty_program
ON public.catalog_source_provenance(loyalty_program_id) WHERE loyalty_program_id IS NOT NULL;

CREATE INDEX idx_catalog_source_provenance_eligibility_requirement
ON public.catalog_source_provenance(card_eligibility_requirement_id) WHERE card_eligibility_requirement_id IS NOT NULL;

CREATE INDEX idx_catalog_source_provenance_target
ON public.catalog_source_provenance(target_entity_type, target_entity_id);

CREATE INDEX idx_catalog_source_provenance_current
ON public.catalog_source_provenance(target_entity_type, target_entity_id)
WHERE lifecycle_status = 'ACTIVE';

CREATE INDEX idx_catalog_source_provenance_verification_status
ON public.catalog_source_provenance(verification_status);

CREATE INDEX idx_catalog_source_provenance_lifecycle_status
ON public.catalog_source_provenance(lifecycle_status);

CREATE INDEX idx_catalog_source_provenance_created_by
ON public.catalog_source_provenance(created_by_user_id) WHERE created_by_user_id IS NOT NULL;

CREATE INDEX idx_catalog_source_provenance_updated_by
ON public.catalog_source_provenance(updated_by_user_id) WHERE updated_by_user_id IS NOT NULL;

CREATE INDEX idx_catalog_source_provenance_verified_by
ON public.catalog_source_provenance(verified_by_user_id) WHERE verified_by_user_id IS NOT NULL;

CREATE INDEX idx_catalog_source_provenance_rejected_by
ON public.catalog_source_provenance(rejected_by_user_id) WHERE rejected_by_user_id IS NOT NULL;

CREATE INDEX idx_catalog_source_provenance_archived_by
ON public.catalog_source_provenance(archived_by_user_id) WHERE archived_by_user_id IS NOT NULL;

CREATE INDEX idx_catalog_source_provenance_supersedes
ON public.catalog_source_provenance(superseded_by_provenance_id) WHERE superseded_by_provenance_id IS NOT NULL;

-- Duplicate prevention: a currently active fingerprinted or versioned
-- observation cannot be re-inserted verbatim for the same target and
-- locator. Historical (SUPERSEDED/ARCHIVED) rows are exempt so genuine
-- re-verification of unchanged content is never permanently blocked.
CREATE UNIQUE INDEX uq_catalog_source_provenance_fingerprint
ON public.catalog_source_provenance(target_entity_type, target_entity_id, source_locator, content_hash)
WHERE content_hash IS NOT NULL AND lifecycle_status = 'ACTIVE';

CREATE UNIQUE INDEX uq_catalog_source_provenance_version
ON public.catalog_source_provenance(target_entity_type, target_entity_id, source_locator, source_version)
WHERE source_version IS NOT NULL AND lifecycle_status = 'ACTIVE';

CREATE OR REPLACE FUNCTION public.manage_catalog_source_provenance_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
DECLARE
    target_id UUID;
BEGIN
    target_id := COALESCE(
        NEW.bank_id, NEW.card_id, NEW.card_fee_id, NEW.card_benefit_id,
        NEW.reward_rule_id, NEW.loyalty_program_id, NEW.card_eligibility_requirement_id
    );

    IF NEW.superseded_by_provenance_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1
            FROM public.catalog_source_provenance AS successor
            WHERE successor.id = NEW.superseded_by_provenance_id
              AND successor.target_entity_type = NEW.target_entity_type
              AND successor.target_entity_id = target_id
        ) THEN
            RAISE EXCEPTION 'superseded_by_provenance_id must reference a provenance record for the same target entity'
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
               OR NEW.target_entity_type IS DISTINCT FROM OLD.target_entity_type
               OR NEW.bank_id IS DISTINCT FROM OLD.bank_id
               OR NEW.card_id IS DISTINCT FROM OLD.card_id
               OR NEW.card_fee_id IS DISTINCT FROM OLD.card_fee_id
               OR NEW.card_benefit_id IS DISTINCT FROM OLD.card_benefit_id
               OR NEW.reward_rule_id IS DISTINCT FROM OLD.reward_rule_id
               OR NEW.loyalty_program_id IS DISTINCT FROM OLD.loyalty_program_id
               OR NEW.card_eligibility_requirement_id IS DISTINCT FROM OLD.card_eligibility_requirement_id
               OR NEW.retrieved_at IS DISTINCT FROM OLD.retrieved_at
               OR NEW.content_hash IS DISTINCT FROM OLD.content_hash
               OR NEW.created_by_user_id IS DISTINCT FROM OLD.created_by_user_id
               OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
                RAISE EXCEPTION 'catalog source provenance identity, target reference, and captured-evidence fields may not be modified'
                    USING ERRCODE = '42501';
            END IF;

            IF OLD.lifecycle_status = 'ARCHIVED' THEN
                RAISE EXCEPTION 'archived catalog source provenance records are immutable; capture new evidence in a new record'
                    USING ERRCODE = '42501';
            END IF;

            IF NEW.lifecycle_status IS DISTINCT FROM OLD.lifecycle_status
               AND NOT (
                   (OLD.lifecycle_status = 'ACTIVE' AND NEW.lifecycle_status IN ('SUPERSEDED', 'ARCHIVED'))
                   OR (OLD.lifecycle_status = 'SUPERSEDED' AND NEW.lifecycle_status = 'ARCHIVED')
               ) THEN
                RAISE EXCEPTION 'invalid catalog source provenance lifecycle transition from % to %', OLD.lifecycle_status, NEW.lifecycle_status
                    USING ERRCODE = '23514';
            END IF;

            IF NEW.verification_status IS DISTINCT FROM OLD.verification_status
               AND NOT (
                   (OLD.verification_status = 'UNVERIFIED' AND NEW.verification_status IN ('VERIFIED', 'REJECTED'))
                   OR (OLD.verification_status = 'VERIFIED' AND NEW.verification_status = 'REJECTED')
               ) THEN
                RAISE EXCEPTION 'invalid catalog source provenance verification transition from % to %', OLD.verification_status, NEW.verification_status
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
    END IF;

    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.manage_catalog_source_provenance_change() IS
    'SECURITY INVOKER trigger that protects immutable identity/target/capture fields, enforces valid lifecycle and verification transitions for authenticated administrators, forces rejected evidence to archive, and stamps administrator actors and derived timestamps.';

CREATE OR REPLACE FUNCTION public.audit_catalog_source_provenance_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE
    changed_record JSONB;
    previous_record JSONB;
    changed_record_id UUID;
    changed_record_reference TEXT;
    audit_action TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        changed_record = to_jsonb(NEW);
        previous_record = NULL;
        changed_record_id = NEW.id;
        changed_record_reference = NEW.target_entity_type || ':' || NEW.target_entity_id::TEXT;
        audit_action = 'CREATE';
    ELSIF TG_OP = 'UPDATE' THEN
        changed_record = to_jsonb(NEW);
        previous_record = to_jsonb(OLD);
        changed_record_id = NEW.id;
        changed_record_reference = NEW.target_entity_type || ':' || NEW.target_entity_id::TEXT;
        audit_action = CASE
            WHEN NEW.verification_status = 'REJECTED' AND OLD.verification_status <> 'REJECTED' THEN 'REJECT'
            WHEN NEW.verification_status = 'VERIFIED' AND OLD.verification_status <> 'VERIFIED' THEN 'VERIFY'
            WHEN NEW.lifecycle_status = 'ARCHIVED' AND OLD.lifecycle_status <> 'ARCHIVED' THEN 'ARCHIVE'
            ELSE 'UPDATE'
        END;
    ELSE
        changed_record = NULL;
        previous_record = to_jsonb(OLD);
        changed_record_id = OLD.id;
        changed_record_reference = OLD.target_entity_type || ':' || OLD.target_entity_id::TEXT;
        audit_action = 'DELETE';
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
        entity_reference,
        operation_name,
        data_classification,
        before_values,
        after_values,
        changed_fields,
        event_details
    )
    VALUES (
        'catalog-source-provenance.' || gen_random_uuid()::TEXT,
        'ADMINISTRATION',
        'catalog_source_provenance_' || lower(TG_OP),
        audit_action,
        CASE WHEN auth.uid() IS NULL THEN 'SYSTEM' ELSE 'ADMIN' END,
        auth.uid(),
        'DATABASE_CATALOG_SOURCE_PROVENANCE',
        'catalog_source_provenance',
        changed_record_id,
        changed_record_reference,
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

COMMENT ON FUNCTION public.audit_catalog_source_provenance_change() IS
    'SECURITY DEFINER is necessary so every catalog_source_provenance mutation is recorded in audit_events without granting callers direct audit-log writes. References are schema-qualified and search_path is pinned.';

CREATE TRIGGER trg_catalog_source_provenance_manage_change
BEFORE INSERT OR UPDATE ON public.catalog_source_provenance
FOR EACH ROW
EXECUTE FUNCTION public.manage_catalog_source_provenance_change();

CREATE TRIGGER trg_catalog_source_provenance_audit
AFTER INSERT OR UPDATE OR DELETE ON public.catalog_source_provenance
FOR EACH ROW
EXECUTE FUNCTION public.audit_catalog_source_provenance_change();

ALTER TABLE public.catalog_source_provenance ENABLE ROW LEVEL SECURITY;

CREATE POLICY catalog_administrator_read_catalog_source_provenance
ON public.catalog_source_provenance FOR SELECT TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'));

CREATE POLICY catalog_administrator_create_catalog_source_provenance
ON public.catalog_source_provenance FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));

CREATE POLICY catalog_administrator_update_catalog_source_provenance
ON public.catalog_source_provenance FOR UPDATE TO authenticated
USING (public.has_active_platform_permission('CATALOG_MANAGE'))
WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));

REVOKE ALL ON TABLE public.catalog_source_provenance FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.manage_catalog_source_provenance_change()
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.audit_catalog_source_provenance_change()
FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE ON TABLE public.catalog_source_provenance TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.catalog_source_provenance TO service_role;

COMMENT ON TABLE public.catalog_source_provenance IS
    'Auditable evidence of where catalog data came from (official bank/product/terms/fee/rewards/loyalty/regulatory sources or approved manual entry), supporting exactly one bank, card, card_fee, card_benefit, reward_rule, loyalty_program, or card_eligibility_requirement row. Foundation for future catalog publication governance; does not itself gate publication.';
COMMENT ON COLUMN public.catalog_source_provenance.target_entity_type IS
    'Discriminator naming which single typed foreign key column is populated; enforced by chk_catalog_source_provenance_target_match.';
COMMENT ON COLUMN public.catalog_source_provenance.target_entity_id IS
    'Generated, stored convenience identifier equal to whichever single typed foreign key is populated; used for uniform indexing and deduplication.';
COMMENT ON COLUMN public.catalog_source_provenance.source_locator IS
    'The source URL when source_locator_type is URL, or a stable non-URL source identifier (e.g. a regulatory document reference) otherwise.';
COMMENT ON COLUMN public.catalog_source_provenance.content_hash IS
    'Optional lowercase hexadecimal SHA-256 fingerprint of the retrieved content, used to detect unchanged versus changed evidence.';
COMMENT ON COLUMN public.catalog_source_provenance.verification_status IS
    'UNVERIFIED, VERIFIED, or REJECTED; VERIFIED requires verified_at/verified_by_user_id, REJECTED requires rejected_at/rejected_by_user_id/rejection_reason and forces lifecycle_status to ARCHIVED.';
COMMENT ON COLUMN public.catalog_source_provenance.lifecycle_status IS
    'ACTIVE (current evidence), SUPERSEDED (replaced by a newer record, see superseded_by_provenance_id), or ARCHIVED (terminal; retained for history, never reactivated).';
COMMENT ON COLUMN public.catalog_source_provenance.superseded_by_provenance_id IS
    'Optional pointer to the later provenance record, for the same target entity, that supersedes this one.';

COMMIT;
