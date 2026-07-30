-- Migration 0049: scoped catalog-administrator authorization.
--
-- Catalog administrators receive explicit GLOBAL or BANK scopes attached to
-- an existing CATALOG_ADMINISTRATOR platform-role assignment. Existing
-- unscoped catalog-role assignments fail closed. PLATFORM_ADMINISTRATOR
-- remains explicitly global. This migration scopes the controlled catalog
-- surfaces introduced by 0046-0048 and does not grant writes to earlier core
-- catalog tables or bypass 0048's publication workflow.

BEGIN;

CREATE TABLE public.catalog_administrator_scope_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_assignment_id UUID NOT NULL
        REFERENCES public.user_platform_role_assignments(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    scope_type TEXT NOT NULL,
    bank_id UUID
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    valid_from TIMESTAMPTZ NOT NULL DEFAULT now(),
    valid_until TIMESTAMPTZ,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    assigned_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    assignment_reason TEXT NOT NULL,
    assignment_reference TEXT,
    revoked_at TIMESTAMPTZ,
    revoked_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    revocation_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_catalog_admin_scopes_type CHECK (
        (scope_type = 'GLOBAL' AND bank_id IS NULL)
        OR (scope_type = 'BANK' AND bank_id IS NOT NULL)
    ),
    CONSTRAINT chk_catalog_admin_scopes_validity CHECK (
        valid_until IS NULL OR valid_until > valid_from
    ),
    CONSTRAINT chk_catalog_admin_scopes_assignment_time CHECK (
        assigned_at <= valid_from
    ),
    CONSTRAINT chk_catalog_admin_scopes_reason CHECK (
        length(trim(assignment_reason)) BETWEEN 1 AND 1000
    ),
    CONSTRAINT chk_catalog_admin_scopes_reference CHECK (
        assignment_reference IS NULL
        OR assignment_reference ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
    ),
    CONSTRAINT chk_catalog_admin_scopes_revocation CHECK (
        (revoked_at IS NULL AND revoked_by_user_id IS NULL AND revocation_reason IS NULL)
        OR (
            revoked_at IS NOT NULL
            AND revoked_at >= valid_from
            AND length(trim(revocation_reason)) BETWEEN 1 AND 1000
        )
    ),
    CONSTRAINT ex_catalog_admin_global_scope_window
        EXCLUDE USING gist (
            role_assignment_id WITH =,
            tstzrange(valid_from, valid_until, '[)') WITH &&
        ) WHERE (scope_type = 'GLOBAL' AND revoked_at IS NULL),
    CONSTRAINT ex_catalog_admin_bank_scope_window
        EXCLUDE USING gist (
            role_assignment_id WITH =,
            bank_id WITH =,
            tstzrange(valid_from, valid_until, '[)') WITH &&
        ) WHERE (scope_type = 'BANK' AND revoked_at IS NULL)
);

CREATE INDEX idx_catalog_admin_scopes_role_active
ON public.catalog_administrator_scope_assignments(
    role_assignment_id, scope_type, bank_id, valid_from, valid_until
)
WHERE revoked_at IS NULL;

CREATE INDEX idx_catalog_admin_scopes_bank_active
ON public.catalog_administrator_scope_assignments(
    bank_id, role_assignment_id, valid_from, valid_until
)
WHERE scope_type = 'BANK' AND revoked_at IS NULL;

CREATE INDEX idx_catalog_admin_scopes_assigned_by
ON public.catalog_administrator_scope_assignments(assigned_by_user_id)
WHERE assigned_by_user_id IS NOT NULL;

CREATE INDEX idx_catalog_admin_scopes_revoked_by
ON public.catalog_administrator_scope_assignments(revoked_by_user_id)
WHERE revoked_by_user_id IS NOT NULL;

CREATE OR REPLACE FUNCTION public.manage_catalog_administrator_scope_assignment()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
DECLARE
    parent_assignment public.user_platform_role_assignments;
    parent_role_code TEXT;
BEGIN
    IF current_user = 'authenticated'
       AND NOT public.has_active_platform_role('PLATFORM_ADMINISTRATOR') THEN
        RAISE EXCEPTION 'PLATFORM_ADMINISTRATOR is required to manage catalog scope'
            USING ERRCODE = '42501';
    END IF;

    SELECT assignment.*
      INTO parent_assignment
      FROM public.user_platform_role_assignments AS assignment
      JOIN public.platform_roles AS role ON role.id = assignment.role_id
     WHERE assignment.id = NEW.role_assignment_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'catalog scope requires an existing role assignment'
            USING ERRCODE = '23514';
    END IF;
    SELECT role.role_code
      INTO parent_role_code
      FROM public.platform_roles AS role
     WHERE role.id = parent_assignment.role_id;
    IF parent_role_code <> 'CATALOG_ADMINISTRATOR' THEN
        RAISE EXCEPTION 'catalog scope requires a CATALOG_ADMINISTRATOR role assignment'
            USING ERRCODE = '23514';
    END IF;
    IF parent_assignment.scope_type <> 'PLATFORM' THEN
        RAISE EXCEPTION 'catalog scope parent must use the 0042 PLATFORM role-assignment shape'
            USING ERRCODE = '23514';
    END IF;
    IF parent_assignment.revoked_at IS NOT NULL
       OR NEW.valid_from < parent_assignment.valid_from
       OR (
           parent_assignment.valid_until IS NOT NULL
           AND (NEW.valid_until IS NULL OR NEW.valid_until > parent_assignment.valid_until)
       ) THEN
        RAISE EXCEPTION 'catalog scope validity must be contained by an active parent role assignment'
            USING ERRCODE = '23514';
    END IF;

    IF TG_OP = 'INSERT' THEN
        NEW.assigned_at := now();
        NEW.assigned_by_user_id := CASE
            WHEN current_user = 'authenticated' THEN auth.uid()
            ELSE NEW.assigned_by_user_id
        END;
    ELSE
        IF NEW.id IS DISTINCT FROM OLD.id
           OR NEW.role_assignment_id IS DISTINCT FROM OLD.role_assignment_id
           OR NEW.scope_type IS DISTINCT FROM OLD.scope_type
           OR NEW.bank_id IS DISTINCT FROM OLD.bank_id
           OR NEW.valid_from IS DISTINCT FROM OLD.valid_from
           OR NEW.assigned_at IS DISTINCT FROM OLD.assigned_at
           OR NEW.assigned_by_user_id IS DISTINCT FROM OLD.assigned_by_user_id
           OR NEW.created_at IS DISTINCT FROM OLD.created_at
           OR OLD.revoked_at IS NOT NULL THEN
            RAISE EXCEPTION 'catalog scope identity and lifecycle history may not be modified'
                USING ERRCODE = '42501';
        END IF;
        IF NEW.revoked_at IS NOT NULL AND OLD.revoked_at IS NULL THEN
            NEW.revoked_at := now();
            NEW.revoked_by_user_id := CASE
                WHEN current_user = 'authenticated' THEN auth.uid()
                ELSE NEW.revoked_by_user_id
            END;
        END IF;
    END IF;

    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.audit_catalog_administrator_scope_assignment()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE
    before_record JSONB;
    after_record JSONB;
    action TEXT;
    record_id UUID;
BEGIN
    IF TG_OP = 'DELETE' THEN
        before_record := to_jsonb(OLD);
        after_record := NULL;
        record_id := OLD.id;
        action := 'DELETE';
    ELSE
        before_record := CASE WHEN TG_OP = 'INSERT' THEN NULL ELSE to_jsonb(OLD) END;
        after_record := to_jsonb(NEW);
        record_id := NEW.id;
        action := CASE
            WHEN TG_OP = 'INSERT' THEN 'CREATE'
            WHEN NEW.revoked_at IS NOT NULL AND OLD.revoked_at IS NULL THEN 'REVOKE'
            ELSE 'UPDATE'
        END;
    END IF;

    INSERT INTO public.audit_events (
        audit_reference, event_category, event_type, event_action, actor_type,
        actor_user_id, source_component, entity_type, entity_id, operation_name,
        data_classification, contains_personal_data, before_values, after_values,
        event_details
    ) VALUES (
        'catalog-authorization.' || gen_random_uuid()::TEXT,
        'AUTHORIZATION', 'catalog_administrator_scope_' || lower(TG_OP), action,
        CASE WHEN auth.uid() IS NULL THEN 'SYSTEM' ELSE 'ADMIN' END,
        auth.uid(), 'DATABASE_CATALOG_AUTHORIZATION',
        'catalog_administrator_scope_assignments', record_id, TG_OP,
        'CONFIDENTIAL', TRUE, before_record, after_record,
        jsonb_build_object(
            'scope_type',
            CASE WHEN TG_OP = 'DELETE' THEN OLD.scope_type ELSE NEW.scope_type END
        )
    );

    IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.catalog_user_has_active_scope(
    requested_user_id UUID,
    requested_bank_id UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
    SELECT EXISTS (
            SELECT 1
              FROM public.user_platform_role_assignments AS platform_assignment
              JOIN public.platform_roles AS platform_role
                ON platform_role.id = platform_assignment.role_id
             WHERE platform_assignment.user_id = requested_user_id
               AND platform_role.role_code = 'PLATFORM_ADMINISTRATOR'
               AND platform_role.is_active = TRUE
               AND platform_assignment.scope_type = 'PLATFORM'
               AND platform_assignment.revoked_at IS NULL
               AND platform_assignment.valid_from <= statement_timestamp()
               AND (platform_assignment.valid_until IS NULL OR platform_assignment.valid_until > statement_timestamp())
        )
        OR EXISTS (
            SELECT 1
              FROM public.catalog_administrator_scope_assignments AS scope_assignment
              JOIN public.user_platform_role_assignments AS role_assignment
                ON role_assignment.id = scope_assignment.role_assignment_id
              JOIN public.platform_roles AS role
                ON role.id = role_assignment.role_id
              JOIN public.platform_role_permissions AS role_permission
                ON role_permission.role_id = role.id
              JOIN public.platform_permissions AS permission
                ON permission.id = role_permission.permission_id
             WHERE role_assignment.user_id = requested_user_id
               AND role.role_code = 'CATALOG_ADMINISTRATOR'
               AND role.is_active = TRUE
               AND permission.permission_code = 'CATALOG_MANAGE'
               AND permission.is_active = TRUE
               AND role_assignment.scope_type = 'PLATFORM'
               AND role_assignment.revoked_at IS NULL
               AND role_assignment.valid_from <= statement_timestamp()
               AND (role_assignment.valid_until IS NULL OR role_assignment.valid_until > statement_timestamp())
               AND role_permission.revoked_at IS NULL
               AND role_permission.valid_from <= statement_timestamp()
               AND (role_permission.valid_until IS NULL OR role_permission.valid_until > statement_timestamp())
               AND scope_assignment.revoked_at IS NULL
               AND scope_assignment.valid_from <= statement_timestamp()
               AND (scope_assignment.valid_until IS NULL OR scope_assignment.valid_until > statement_timestamp())
               AND (
                   scope_assignment.scope_type = 'GLOBAL'
                   OR (
                       requested_bank_id IS NOT NULL
                       AND scope_assignment.scope_type = 'BANK'
                       AND scope_assignment.bank_id = requested_bank_id
                   )
               )
        );
$$;

CREATE OR REPLACE FUNCTION public.has_active_catalog_scope(requested_bank_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
    SELECT public.catalog_user_has_active_scope((SELECT auth.uid()), requested_bank_id);
$$;

CREATE OR REPLACE FUNCTION public.catalog_target_bank_id(
    requested_target_type TEXT,
    requested_target_id UUID
)
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
    SELECT CASE requested_target_type
        WHEN 'BANK' THEN (
            SELECT bank.id FROM public.banks AS bank WHERE bank.id = requested_target_id
        )
        WHEN 'CARD' THEN (
            SELECT card.bank_id FROM public.cards AS card WHERE card.id = requested_target_id
        )
        WHEN 'CARD_FEE' THEN (
            SELECT card.bank_id
              FROM public.card_fees AS fee
              JOIN public.cards AS card ON card.id = fee.card_id
             WHERE fee.id = requested_target_id
        )
        WHEN 'CARD_BENEFIT' THEN (
            SELECT card.bank_id
              FROM public.card_benefits AS benefit
              JOIN public.cards AS card ON card.id = benefit.card_id
             WHERE benefit.id = requested_target_id
        )
        WHEN 'REWARD_RULE' THEN (
            SELECT card.bank_id
              FROM public.reward_rules AS rule
              JOIN public.cards AS card ON card.id = rule.card_id
             WHERE rule.id = requested_target_id
        )
        WHEN 'CARD_ELIGIBILITY_REQUIREMENT' THEN (
            SELECT card.bank_id
              FROM public.card_eligibility_requirements AS requirement
              JOIN public.cards AS card ON card.id = requirement.card_id
             WHERE requirement.id = requested_target_id
        )
        ELSE NULL
    END;
$$;

CREATE OR REPLACE FUNCTION public.catalog_user_has_target_access(
    requested_user_id UUID,
    requested_target_type TEXT,
    requested_target_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE
    target_bank_id UUID;
BEGIN
    IF requested_target_type IN ('LOYALTY_PROGRAM', 'MERCHANT') THEN
        IF requested_target_type = 'LOYALTY_PROGRAM'
           AND NOT EXISTS (SELECT 1 FROM public.loyalty_programs WHERE id = requested_target_id) THEN
            RETURN FALSE;
        ELSIF requested_target_type = 'MERCHANT'
           AND NOT EXISTS (SELECT 1 FROM public.merchants WHERE id = requested_target_id) THEN
            RETURN FALSE;
        END IF;
        RETURN public.catalog_user_has_active_scope(requested_user_id, NULL);
    ELSIF requested_target_type NOT IN (
        'BANK', 'CARD', 'CARD_FEE', 'CARD_BENEFIT', 'REWARD_RULE',
        'CARD_ELIGIBILITY_REQUIREMENT'
    ) THEN
        RETURN FALSE;
    END IF;

    target_bank_id := public.catalog_target_bank_id(requested_target_type, requested_target_id);
    RETURN target_bank_id IS NOT NULL
       AND public.catalog_user_has_active_scope(requested_user_id, target_bank_id);
END;
$$;

CREATE OR REPLACE FUNCTION public.has_catalog_target_access(
    requested_target_type TEXT,
    requested_target_id UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
    SELECT public.catalog_user_has_target_access(
        (SELECT auth.uid()), requested_target_type, requested_target_id
    );
$$;

CREATE OR REPLACE FUNCTION public.has_catalog_publication_version_access(
    requested_version_id UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
    SELECT COALESCE((
        SELECT public.has_catalog_target_access(version.target_entity_type, version.target_entity_id)
          FROM public.catalog_publication_versions AS version
         WHERE version.id = requested_version_id
    ), FALSE);
$$;

COMMENT ON FUNCTION public.has_active_catalog_scope(UUID) IS
    'SECURITY DEFINER evaluates explicit GLOBAL/BANK catalog scopes without exposing assignment rows; PLATFORM_ADMINISTRATOR is explicitly global, legacy unscoped CATALOG_ADMINISTRATOR assignments fail closed, references are schema-qualified, and search_path is pinned.';
COMMENT ON FUNCTION public.catalog_user_has_active_scope(UUID, UUID) IS
    'Internal SECURITY DEFINER evaluator used to validate assigned publication decision-makers against explicit GLOBAL/BANK scopes without exposing assignment rows; direct authenticated execution is revoked, references are schema-qualified, and search_path is pinned.';
COMMENT ON FUNCTION public.catalog_target_bank_id(TEXT, UUID) IS
    'SECURITY DEFINER resolves only the six explicitly bank-owned 0046/0048 target types through real foreign keys; GLOBAL targets and unknown identifiers return null, references are schema-qualified, and search_path is pinned.';
COMMENT ON FUNCTION public.has_catalog_target_access(TEXT, UUID) IS
    'SECURITY DEFINER maps explicit catalog target types to BANK or GLOBAL authorization and returns only a boolean decision; arbitrary entity types fail closed, references are schema-qualified, and search_path is pinned.';
COMMENT ON FUNCTION public.catalog_user_has_target_access(UUID, TEXT, UUID) IS
    'Internal SECURITY DEFINER target evaluator used to prevent assignment of publication work to users outside the target BANK/GLOBAL scope; direct authenticated execution is revoked, references are schema-qualified, and search_path is pinned.';
COMMENT ON FUNCTION public.has_catalog_publication_version_access(UUID) IS
    'SECURITY DEFINER resolves a publication version to its typed target and returns only the scope decision; references are schema-qualified and search_path is pinned.';
COMMENT ON FUNCTION public.audit_catalog_administrator_scope_assignment() IS
    'SECURITY DEFINER writes catalog-scope lifecycle changes to audit_events without granting direct audit-log writes; references are schema-qualified and search_path is pinned.';

CREATE TRIGGER trg_catalog_admin_scopes_manage
BEFORE INSERT OR UPDATE ON public.catalog_administrator_scope_assignments
FOR EACH ROW EXECUTE FUNCTION public.manage_catalog_administrator_scope_assignment();

CREATE TRIGGER trg_catalog_admin_scopes_updated_at
BEFORE UPDATE ON public.catalog_administrator_scope_assignments
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_catalog_admin_scopes_audit
AFTER INSERT OR UPDATE OR DELETE ON public.catalog_administrator_scope_assignments
FOR EACH ROW EXECUTE FUNCTION public.audit_catalog_administrator_scope_assignment();

ALTER TABLE public.catalog_administrator_scope_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY platform_administrator_read_catalog_scopes
ON public.catalog_administrator_scope_assignments FOR SELECT TO authenticated
USING (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));

CREATE POLICY platform_administrator_create_catalog_scopes
ON public.catalog_administrator_scope_assignments FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));

CREATE POLICY platform_administrator_update_catalog_scopes
ON public.catalog_administrator_scope_assignments FOR UPDATE TO authenticated
USING (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'))
WITH CHECK (public.has_active_platform_role('PLATFORM_ADMINISTRATOR'));

-- Replace 0046's interim platform-wide provenance policies.
DROP POLICY catalog_administrator_read_catalog_source_provenance
ON public.catalog_source_provenance;
DROP POLICY catalog_administrator_create_catalog_source_provenance
ON public.catalog_source_provenance;
DROP POLICY catalog_administrator_update_catalog_source_provenance
ON public.catalog_source_provenance;

CREATE POLICY catalog_scope_read_catalog_source_provenance
ON public.catalog_source_provenance FOR SELECT TO authenticated
USING (public.has_catalog_target_access(target_entity_type, target_entity_id));
CREATE POLICY catalog_scope_create_catalog_source_provenance
ON public.catalog_source_provenance FOR INSERT TO authenticated
WITH CHECK (public.has_catalog_target_access(target_entity_type, target_entity_id));
CREATE POLICY catalog_scope_update_catalog_source_provenance
ON public.catalog_source_provenance FOR UPDATE TO authenticated
USING (public.has_catalog_target_access(target_entity_type, target_entity_id))
WITH CHECK (public.has_catalog_target_access(target_entity_type, target_entity_id));

-- Merchant catalog records are shared GLOBAL resources.
DROP POLICY catalog_administrator_read_merchants ON public.merchants;
DROP POLICY catalog_administrator_create_merchants ON public.merchants;
DROP POLICY catalog_administrator_update_merchants ON public.merchants;
DROP POLICY catalog_administrator_read_merchant_aliases ON public.merchant_aliases;
DROP POLICY catalog_administrator_create_merchant_aliases ON public.merchant_aliases;
DROP POLICY catalog_administrator_update_merchant_aliases ON public.merchant_aliases;
DROP POLICY catalog_administrator_read_merchant_relationships ON public.merchant_relationships;
DROP POLICY catalog_administrator_create_merchant_relationships ON public.merchant_relationships;
DROP POLICY catalog_administrator_update_merchant_relationships ON public.merchant_relationships;
DROP POLICY catalog_administrator_read_merchant_category_assignments ON public.merchant_category_assignments;
DROP POLICY catalog_administrator_create_merchant_category_assignments ON public.merchant_category_assignments;
DROP POLICY catalog_administrator_update_merchant_category_assignments ON public.merchant_category_assignments;
DROP POLICY catalog_administrator_read_merchant_market_presence ON public.merchant_market_presence;
DROP POLICY catalog_administrator_create_merchant_market_presence ON public.merchant_market_presence;
DROP POLICY catalog_administrator_update_merchant_market_presence ON public.merchant_market_presence;
DROP POLICY catalog_administrator_read_merchant_domains ON public.merchant_domains;
DROP POLICY catalog_administrator_create_merchant_domains ON public.merchant_domains;
DROP POLICY catalog_administrator_update_merchant_domains ON public.merchant_domains;

CREATE POLICY catalog_global_read_merchants ON public.merchants FOR SELECT TO authenticated
USING (public.has_active_catalog_scope(NULL));
CREATE POLICY catalog_global_create_merchants ON public.merchants FOR INSERT TO authenticated
WITH CHECK (public.has_active_catalog_scope(NULL));
CREATE POLICY catalog_global_update_merchants ON public.merchants FOR UPDATE TO authenticated
USING (public.has_active_catalog_scope(NULL)) WITH CHECK (public.has_active_catalog_scope(NULL));

DO $$
DECLARE child_table TEXT;
BEGIN
    FOREACH child_table IN ARRAY ARRAY[
        'merchant_aliases', 'merchant_relationships',
        'merchant_category_assignments', 'merchant_market_presence',
        'merchant_domains'
    ] LOOP
        EXECUTE format(
            'CREATE POLICY catalog_global_read_%1$I ON public.%1$I FOR SELECT TO authenticated USING (public.has_active_catalog_scope(NULL))',
            child_table
        );
        EXECUTE format(
            'CREATE POLICY catalog_global_create_%1$I ON public.%1$I FOR INSERT TO authenticated WITH CHECK (public.has_active_catalog_scope(NULL))',
            child_table
        );
        EXECUTE format(
            'CREATE POLICY catalog_global_update_%1$I ON public.%1$I FOR UPDATE TO authenticated USING (public.has_active_catalog_scope(NULL)) WITH CHECK (public.has_active_catalog_scope(NULL))',
            child_table
        );
    END LOOP;
END;
$$;

-- Replace 0048's interim platform-wide governance visibility and writes.
DROP POLICY catalog_governance_manage_versions ON public.catalog_publication_versions;
DROP POLICY catalog_governance_read_requests ON public.catalog_publication_requests;
DROP POLICY catalog_governance_read_events ON public.catalog_publication_events;
DROP POLICY catalog_governance_read_approval_requests ON public.approval_requests;
DROP POLICY catalog_governance_read_approval_decisions ON public.approval_decisions;

CREATE POLICY catalog_scope_manage_versions
ON public.catalog_publication_versions FOR ALL TO authenticated
USING (public.has_catalog_target_access(target_entity_type, target_entity_id))
WITH CHECK (public.has_catalog_target_access(target_entity_type, target_entity_id));

CREATE POLICY catalog_scope_read_requests
ON public.catalog_publication_requests FOR SELECT TO authenticated
USING (public.has_catalog_publication_version_access(publication_version_id));

CREATE POLICY catalog_scope_read_events
ON public.catalog_publication_events FOR SELECT TO authenticated
USING (public.has_catalog_publication_version_access(publication_version_id));

CREATE POLICY catalog_scope_read_approval_requests
ON public.approval_requests FOR SELECT TO authenticated
USING (
    approval_type = 'CATALOG_PUBLICATION'
    AND EXISTS (
        SELECT 1
          FROM public.catalog_publication_requests AS publication_request
         WHERE publication_request.approval_request_id = approval_requests.id
           AND public.has_catalog_publication_version_access(publication_request.publication_version_id)
    )
);

CREATE POLICY catalog_scope_read_approval_decisions
ON public.approval_decisions FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1
          FROM public.catalog_publication_requests AS publication_request
         WHERE publication_request.approval_request_id = approval_decisions.approval_request_id
           AND public.has_catalog_publication_version_access(publication_request.publication_version_id)
    )
);

-- Scope every controlled publication workflow entry point. The underlying
-- state-machine behavior remains the 0048 implementation.
CREATE OR REPLACE FUNCTION public.submit_catalog_publication(
    requested_version_id UUID, reviewer_id UUID, final_approver_id UUID,
    publish_at TIMESTAMPTZ DEFAULT NULL, unpublish_at TIMESTAMPTZ DEFAULT NULL,
    effective_start TIMESTAMPTZ DEFAULT NULL, effective_end TIMESTAMPTZ DEFAULT NULL
) RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v public.catalog_publication_versions; request_id UUID := gen_random_uuid(); approval_id UUID := gen_random_uuid(); actor UUID := auth.uid();
BEGIN
    IF actor IS NULL THEN RAISE EXCEPTION 'authenticated catalog administrator required' USING ERRCODE='42501'; END IF;
    SELECT * INTO v FROM public.catalog_publication_versions WHERE id=requested_version_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'publication version not found' USING ERRCODE='P0002'; END IF;
    IF NOT public.has_catalog_target_access(v.target_entity_type,v.target_entity_id) THEN RAISE EXCEPTION 'catalog scope does not authorize this publication target' USING ERRCODE='42501'; END IF;
    IF v.lifecycle_status <> 'DRAFT' THEN
        SELECT id INTO request_id FROM public.catalog_publication_requests WHERE publication_version_id=requested_version_id;
        IF request_id IS NOT NULL THEN RETURN request_id; END IF;
        RAISE EXCEPTION 'only DRAFT versions may be submitted' USING ERRCODE='23514';
    END IF;
    IF actor = final_approver_id THEN RAISE EXCEPTION 'requester may not be final approver' USING ERRCODE='23514'; END IF;
    IF reviewer_id = final_approver_id THEN RAISE EXCEPTION 'reviewer and final approver must be different users' USING ERRCODE='23514'; END IF;
    IF NOT public.catalog_user_has_target_access(reviewer_id,v.target_entity_type,v.target_entity_id)
       OR NOT public.catalog_user_has_target_access(final_approver_id,v.target_entity_type,v.target_entity_id) THEN
        RAISE EXCEPTION 'reviewer and final approver must hold GLOBAL or matching BANK catalog scope' USING ERRCODE='23514';
    END IF;
    IF unpublish_at IS NOT NULL AND (publish_at IS NULL OR unpublish_at <= publish_at) THEN RAISE EXCEPTION 'invalid publication schedule' USING ERRCODE='23514'; END IF;
    IF effective_end IS NOT NULL AND (effective_start IS NULL OR effective_end <= effective_start) THEN RAISE EXCEPTION 'invalid effective window' USING ERRCODE='23514'; END IF;
    INSERT INTO public.approval_requests(id,approval_reference,approval_type,approval_status,entity_type,entity_id,requested_by_user_id,requested_by_actor_type,requested_at,submitted_at,minimum_approvals_required,total_approval_steps,request_title,business_justification)
    VALUES (approval_id,'catalog-publication.'||approval_id::text,'CATALOG_PUBLICATION','IN_REVIEW','catalog_publication_version',requested_version_id,actor,'ADMIN',now(),now(),2,2,'Catalog publication version '||v.version_number,v.change_summary);
    INSERT INTO public.approval_decisions(approval_request_id,decision_reference,approval_step,decision_sequence,approver_user_id)
    VALUES (approval_id,'catalog-publication-review.'||approval_id::text,1,1,reviewer_id),(approval_id,'catalog-publication-approval.'||approval_id::text,2,1,final_approver_id);
    INSERT INTO public.catalog_publication_requests(id,publication_version_id,approval_request_id,requester_user_id,reviewer_user_id,final_approver_user_id)
    VALUES (request_id,requested_version_id,approval_id,actor,reviewer_id,final_approver_id);
    UPDATE public.catalog_publication_versions SET lifecycle_status='IN_REVIEW',scheduled_publish_at=publish_at,scheduled_unpublish_at=unpublish_at,effective_from=effective_start,effective_until=effective_end WHERE id=requested_version_id;
    RETURN request_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.decide_catalog_publication(requested_request_id UUID, decision TEXT, comments TEXT)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE r public.catalog_publication_requests; d public.approval_decisions; actor UUID:=auth.uid(); next_status TEXT;
BEGIN
    IF actor IS NULL THEN RAISE EXCEPTION 'authenticated catalog administrator required' USING ERRCODE='42501'; END IF;
    IF decision NOT IN ('APPROVED','REJECTED') OR comments IS NULL OR length(trim(comments))=0 THEN RAISE EXCEPTION 'decision and comments are required' USING ERRCODE='23514'; END IF;
    SELECT * INTO r FROM public.catalog_publication_requests WHERE id=requested_request_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'publication request not found' USING ERRCODE='P0002'; END IF;
    IF NOT public.has_catalog_publication_version_access(r.publication_version_id) THEN RAISE EXCEPTION 'catalog scope does not authorize this publication target' USING ERRCODE='42501'; END IF;
    IF r.request_status <> 'IN_REVIEW' THEN RETURN r.request_status; END IF;
    SELECT * INTO d FROM public.approval_decisions WHERE approval_request_id=r.approval_request_id AND approver_user_id=actor AND decision_status IN ('PENDING','IN_REVIEW') ORDER BY approval_step LIMIT 1 FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'caller has no pending assignment' USING ERRCODE='42501'; END IF;
    IF d.approval_step=2 AND NOT EXISTS (SELECT 1 FROM public.approval_decisions WHERE approval_request_id=r.approval_request_id AND approval_step=1 AND decision_status='APPROVED') THEN RAISE EXCEPTION 'review approval is required before final approval' USING ERRCODE='23514'; END IF;
    UPDATE public.approval_decisions SET decision_status=decision,opened_at=COALESCE(opened_at,now()),decided_at=now(),decision_reason_text=comments WHERE id=d.id;
    IF decision='REJECTED' THEN
        UPDATE public.approval_requests SET approval_status='REJECTED',rejections_received=rejections_received+1,completed_at=now() WHERE id=r.approval_request_id;
        UPDATE public.catalog_publication_requests SET request_status='REJECTED',decided_at=now(),decision_comments=comments WHERE id=r.id;
        UPDATE public.catalog_publication_versions SET lifecycle_status='REJECTED',rejected_at=now(),rejection_reason=comments WHERE id=r.publication_version_id;
        RETURN 'REJECTED';
    ELSIF d.approval_step=1 THEN
        UPDATE public.approval_requests SET approvals_received=1,current_approval_step=2,approval_status='PARTIALLY_APPROVED' WHERE id=r.approval_request_id;
        INSERT INTO public.catalog_publication_events(publication_version_id,publication_request_id,event_type,from_status,to_status,actor_user_id,event_comment) VALUES(r.publication_version_id,r.id,'REVIEW_APPROVED','IN_REVIEW','IN_REVIEW',actor,comments);
        RETURN 'IN_REVIEW';
    END IF;
    SELECT CASE WHEN scheduled_publish_at IS NULL THEN 'APPROVED' ELSE 'SCHEDULED' END INTO next_status FROM public.catalog_publication_versions WHERE id=r.publication_version_id;
    UPDATE public.approval_requests SET approvals_received=2,approval_status='APPROVED',completed_at=now() WHERE id=r.approval_request_id;
    UPDATE public.catalog_publication_requests SET request_status='APPROVED',decided_at=now(),decision_comments=comments WHERE id=r.id;
    UPDATE public.catalog_publication_versions SET lifecycle_status=next_status WHERE id=r.publication_version_id;
    RETURN next_status;
END;
$$;

CREATE OR REPLACE FUNCTION public.publish_catalog_version(requested_version_id UUID)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v public.catalog_publication_versions; actor UUID:=auth.uid();
BEGIN
    SELECT * INTO v FROM public.catalog_publication_versions WHERE id=requested_version_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'publication version not found' USING ERRCODE='P0002'; END IF;
    IF actor IS NOT NULL AND NOT public.has_catalog_target_access(v.target_entity_type,v.target_entity_id) THEN RAISE EXCEPTION 'catalog scope does not authorize this publication target' USING ERRCODE='42501'; END IF;
    IF v.lifecycle_status='PUBLISHED' THEN RETURN 'PUBLISHED'; END IF;
    IF v.lifecycle_status NOT IN ('APPROVED','SCHEDULED','SUSPENDED') THEN RAISE EXCEPTION 'version is not publishable' USING ERRCODE='23514'; END IF;
    IF v.scheduled_publish_at IS NOT NULL AND v.scheduled_publish_at>statement_timestamp() THEN RAISE EXCEPTION 'scheduled publication time has not arrived' USING ERRCODE='23514'; END IF;
    UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED',published_at=COALESCE(published_at,now()),effective_from=COALESCE(effective_from,scheduled_publish_at,now()),unpublished_at=NULL,suspended_at=NULL,suspension_reason=NULL WHERE id=v.id;
    RETURN 'PUBLISHED';
END;
$$;

CREATE OR REPLACE FUNCTION public.unpublish_catalog_version(requested_version_id UUID, archive BOOLEAN, reason TEXT)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v public.catalog_publication_versions; actor UUID:=auth.uid(); target TEXT;
BEGIN
    IF reason IS NULL OR length(trim(reason))=0 THEN RAISE EXCEPTION 'unpublication reason is required' USING ERRCODE='23514'; END IF;
    SELECT * INTO v FROM public.catalog_publication_versions WHERE id=requested_version_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'publication version not found' USING ERRCODE='P0002'; END IF;
    IF actor IS NOT NULL AND NOT public.has_catalog_target_access(v.target_entity_type,v.target_entity_id) THEN RAISE EXCEPTION 'catalog scope does not authorize this publication target' USING ERRCODE='42501'; END IF;
    target:=CASE WHEN archive THEN 'ARCHIVED' ELSE 'SUSPENDED' END;
    IF v.lifecycle_status=target THEN RETURN target; END IF;
    IF v.lifecycle_status NOT IN ('PUBLISHED','SUSPENDED') THEN RAISE EXCEPTION 'version is not published or suspended' USING ERRCODE='23514'; END IF;
    UPDATE public.catalog_publication_versions SET lifecycle_status=target,unpublished_at=COALESCE(unpublished_at,now()),suspended_at=CASE WHEN target='SUSPENDED' THEN now() ELSE suspended_at END,suspension_reason=CASE WHEN target='SUSPENDED' THEN reason ELSE suspension_reason END,archived_at=CASE WHEN target='ARCHIVED' THEN now() ELSE archived_at END WHERE id=v.id;
    RETURN target;
END;
$$;

CREATE OR REPLACE FUNCTION public.rollback_catalog_version(current_version_id UUID, replacement_version_id UUID, reason TEXT)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE current_v public.catalog_publication_versions; replacement_v public.catalog_publication_versions; actor UUID:=auth.uid();
BEGIN
    IF reason IS NULL OR length(trim(reason))=0 OR current_version_id=replacement_version_id THEN RAISE EXCEPTION 'valid rollback target and reason are required' USING ERRCODE='23514'; END IF;
    PERFORM pg_advisory_xact_lock(hashtextextended(least(current_version_id::text,replacement_version_id::text)||greatest(current_version_id::text,replacement_version_id::text),0));
    SELECT * INTO current_v FROM public.catalog_publication_versions WHERE id=current_version_id FOR UPDATE;
    SELECT * INTO replacement_v FROM public.catalog_publication_versions WHERE id=replacement_version_id FOR UPDATE;
    IF current_v.id IS NULL OR replacement_v.id IS NULL THEN RAISE EXCEPTION 'publication version not found' USING ERRCODE='P0002'; END IF;
    IF actor IS NOT NULL AND NOT public.has_catalog_target_access(current_v.target_entity_type,current_v.target_entity_id) THEN RAISE EXCEPTION 'catalog scope does not authorize this publication target' USING ERRCODE='42501'; END IF;
    IF current_v.lifecycle_status<>'PUBLISHED' OR replacement_v.lifecycle_status NOT IN ('APPROVED','SCHEDULED','SUSPENDED') THEN RAISE EXCEPTION 'invalid rollback states' USING ERRCODE='23514'; END IF;
    IF current_v.target_entity_type<>replacement_v.target_entity_type OR current_v.target_entity_id<>replacement_v.target_entity_id THEN RAISE EXCEPTION 'rollback versions must target the same entity' USING ERRCODE='23514'; END IF;
    UPDATE public.catalog_publication_versions SET lifecycle_status='ARCHIVED',archived_at=now(),unpublished_at=now(),supersedes_version_id=replacement_version_id WHERE id=current_v.id;
    UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED',published_at=COALESCE(published_at,now()),effective_from=now(),effective_until=NULL,rollback_of_version_id=current_v.id,suspended_at=NULL,suspension_reason=NULL WHERE id=replacement_v.id;
    RETURN 'PUBLISHED';
END;
$$;

COMMENT ON FUNCTION public.submit_catalog_publication(UUID,UUID,UUID,TIMESTAMPTZ,TIMESTAMPTZ,TIMESTAMPTZ,TIMESTAMPTZ) IS 'SECURITY DEFINER provides the 0048 atomic submission boundary and now requires BANK/GLOBAL access to the typed target; references are schema-qualified and search_path is pinned.';
COMMENT ON FUNCTION public.decide_catalog_publication(UUID,TEXT,TEXT) IS 'SECURITY DEFINER preserves ordered two-person approval while requiring BANK/GLOBAL access to the publication target; references are schema-qualified and search_path is pinned.';
COMMENT ON FUNCTION public.publish_catalog_version(UUID) IS 'SECURITY DEFINER preserves the 0048 publication state machine while requiring BANK/GLOBAL target access for authenticated callers; service_role remains the trusted scheduler path; references are schema-qualified and search_path is pinned.';
COMMENT ON FUNCTION public.unpublish_catalog_version(UUID,BOOLEAN,TEXT) IS 'SECURITY DEFINER preserves the 0048 suspend/archive state machine while requiring BANK/GLOBAL target access for authenticated callers; references are schema-qualified and search_path is pinned.';
COMMENT ON FUNCTION public.rollback_catalog_version(UUID,UUID,TEXT) IS 'SECURITY DEFINER preserves the 0048 atomic rollback boundary while requiring BANK/GLOBAL access to the common typed target; references are schema-qualified and search_path is pinned.';

REVOKE ALL ON TABLE public.catalog_administrator_scope_assignments
FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.catalog_administrator_scope_assignments
TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.catalog_administrator_scope_assignments
TO service_role;

REVOKE EXECUTE ON FUNCTION public.manage_catalog_administrator_scope_assignment(),
    public.audit_catalog_administrator_scope_assignment(),
    public.catalog_target_bank_id(TEXT, UUID),
    public.catalog_user_has_active_scope(UUID, UUID),
    public.catalog_user_has_target_access(UUID, TEXT, UUID)
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.has_active_catalog_scope(UUID),
    public.has_catalog_target_access(TEXT, UUID),
    public.has_catalog_publication_version_access(UUID)
FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.has_active_catalog_scope(UUID),
    public.has_catalog_target_access(TEXT, UUID),
    public.has_catalog_publication_version_access(UUID)
TO authenticated, service_role;

COMMENT ON TABLE public.catalog_administrator_scope_assignments IS
    'History-preserving GLOBAL or BANK authorization attached to an existing CATALOG_ADMINISTRATOR platform-role assignment. Only active PLATFORM_ADMINISTRATOR callers may create or revoke scopes; legacy unscoped catalog assignments grant no catalog access.';
COMMENT ON COLUMN public.catalog_administrator_scope_assignments.scope_type IS
    'GLOBAL covers shared catalog resources and every bank; BANK covers only the referenced bank and resources reached through explicit bank/card foreign-key chains.';
COMMENT ON COLUMN public.catalog_administrator_scope_assignments.bank_id IS
    'Required only for BANK scope. No arbitrary resource identifiers or inferred scope strings are accepted.';

COMMIT;
