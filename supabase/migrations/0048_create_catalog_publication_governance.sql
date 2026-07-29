-- Migration 0048: catalog publication governance.
-- Reuses the generic approval_requests/approval_decisions engine from 0040
-- and the CATALOG_MANAGE permission from 0042. Resource-scoped catalog-admin
-- authorization and permission assignment remain migration 0049 scope.

BEGIN;

ALTER TABLE public.approval_requests
    DROP CONSTRAINT chk_approval_requests_type;
ALTER TABLE public.approval_requests
    ADD CONSTRAINT chk_approval_requests_type CHECK (
        approval_type IN (
            'DATA_CHANGE', 'DATA_EXPORT', 'DATA_DELETION', 'ACCESS_GRANT',
            'ACCESS_REVOCATION', 'ROLE_ASSIGNMENT', 'USER_IMPERSONATION',
            'MANUAL_OVERRIDE', 'BANK_APPLICATION', 'BANK_PARTNERSHIP',
            'COMMISSION_RULE', 'COMMISSION_ADJUSTMENT', 'SETTLEMENT', 'REFUND',
            'SECURITY_EXCEPTION', 'PRIVACY_EXCEPTION', 'RETENTION_EXCEPTION',
            'MODEL_CHANGE', 'POLICY_CHANGE', 'CONTROL_CHANGE',
            'CATALOG_PUBLICATION', 'OTHER'
        )
    );

CREATE TABLE public.catalog_publication_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_entity_type TEXT NOT NULL,
    bank_id UUID REFERENCES public.banks(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    card_id UUID REFERENCES public.cards(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    card_fee_id UUID REFERENCES public.card_fees(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    card_benefit_id UUID REFERENCES public.card_benefits(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    reward_rule_id UUID REFERENCES public.reward_rules(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    loyalty_program_id UUID REFERENCES public.loyalty_programs(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    card_eligibility_requirement_id UUID REFERENCES public.card_eligibility_requirements(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    merchant_id UUID REFERENCES public.merchants(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    target_entity_id UUID GENERATED ALWAYS AS (
        COALESCE(bank_id, card_id, card_fee_id, card_benefit_id, reward_rule_id,
                 loyalty_program_id, card_eligibility_requirement_id, merchant_id)
    ) STORED,
    version_number INTEGER NOT NULL,
    lifecycle_status TEXT NOT NULL DEFAULT 'DRAFT',
    content_snapshot JSONB NOT NULL,
    change_summary TEXT NOT NULL,
    source_provenance_id UUID REFERENCES public.catalog_source_provenance(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    effective_from TIMESTAMPTZ,
    effective_until TIMESTAMPTZ,
    scheduled_publish_at TIMESTAMPTZ,
    scheduled_unpublish_at TIMESTAMPTZ,
    published_at TIMESTAMPTZ,
    unpublished_at TIMESTAMPTZ,
    suspended_at TIMESTAMPTZ,
    suspension_reason TEXT,
    archived_at TIMESTAMPTZ,
    rejected_at TIMESTAMPTZ,
    rejection_reason TEXT,
    supersedes_version_id UUID REFERENCES public.catalog_publication_versions(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    rollback_of_version_id UUID REFERENCES public.catalog_publication_versions(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    created_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_catalog_publication_versions_number UNIQUE (target_entity_type, target_entity_id, version_number),
    CONSTRAINT chk_catalog_publication_versions_target_type CHECK (target_entity_type IN (
        'BANK', 'CARD', 'CARD_FEE', 'CARD_BENEFIT', 'REWARD_RULE',
        'LOYALTY_PROGRAM', 'CARD_ELIGIBILITY_REQUIREMENT', 'MERCHANT')),
    CONSTRAINT chk_catalog_publication_versions_target_match CHECK (
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
    ),
    CONSTRAINT chk_catalog_publication_versions_number CHECK (version_number > 0),
    CONSTRAINT chk_catalog_publication_versions_status CHECK (lifecycle_status IN (
        'DRAFT', 'IN_REVIEW', 'APPROVED', 'SCHEDULED', 'PUBLISHED',
        'SUSPENDED', 'ARCHIVED', 'REJECTED')),
    CONSTRAINT chk_catalog_publication_versions_snapshot CHECK (jsonb_typeof(content_snapshot) = 'object'),
    CONSTRAINT chk_catalog_publication_versions_summary CHECK (length(trim(change_summary)) BETWEEN 1 AND 2000),
    CONSTRAINT chk_catalog_publication_versions_effective_window CHECK (effective_until IS NULL OR (effective_from IS NOT NULL AND effective_until > effective_from)),
    CONSTRAINT chk_catalog_publication_versions_schedule CHECK (scheduled_unpublish_at IS NULL OR (scheduled_publish_at IS NOT NULL AND scheduled_unpublish_at > scheduled_publish_at)),
    CONSTRAINT chk_catalog_publication_versions_publish_state CHECK (lifecycle_status <> 'PUBLISHED' OR (published_at IS NOT NULL AND effective_from IS NOT NULL)),
    CONSTRAINT chk_catalog_publication_versions_suspend_state CHECK (lifecycle_status <> 'SUSPENDED' OR (suspended_at IS NOT NULL AND length(trim(suspension_reason)) BETWEEN 1 AND 2000)),
    CONSTRAINT chk_catalog_publication_versions_archive_state CHECK (lifecycle_status <> 'ARCHIVED' OR archived_at IS NOT NULL),
    CONSTRAINT chk_catalog_publication_versions_reject_state CHECK (lifecycle_status <> 'REJECTED' OR (rejected_at IS NOT NULL AND length(trim(rejection_reason)) BETWEEN 1 AND 2000)),
    CONSTRAINT chk_catalog_publication_versions_supersession CHECK (supersedes_version_id IS NULL OR supersedes_version_id <> id),
    CONSTRAINT chk_catalog_publication_versions_rollback CHECK (rollback_of_version_id IS NULL OR rollback_of_version_id <> id),
    CONSTRAINT ex_catalog_publication_versions_active_window EXCLUDE USING gist (
        target_entity_type WITH =,
        target_entity_id WITH =,
        tstzrange(effective_from, effective_until, '[)') WITH &&
    ) WHERE (lifecycle_status = 'PUBLISHED')
);

CREATE TABLE public.catalog_publication_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    publication_version_id UUID NOT NULL UNIQUE REFERENCES public.catalog_publication_versions(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    approval_request_id UUID NOT NULL UNIQUE REFERENCES public.approval_requests(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    request_status TEXT NOT NULL DEFAULT 'IN_REVIEW',
    requester_user_id UUID NOT NULL REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    reviewer_user_id UUID NOT NULL REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    final_approver_user_id UUID NOT NULL REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    decided_at TIMESTAMPTZ,
    decision_comments TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_catalog_publication_requests_status CHECK (request_status IN ('IN_REVIEW', 'APPROVED', 'REJECTED', 'CANCELLED')),
    CONSTRAINT chk_catalog_publication_requests_separation CHECK (requester_user_id <> final_approver_user_id),
    CONSTRAINT chk_catalog_publication_requests_decision CHECK (
        (request_status = 'IN_REVIEW' AND decided_at IS NULL)
        OR (request_status IN ('APPROVED', 'REJECTED', 'CANCELLED') AND decided_at IS NOT NULL)
    ),
    CONSTRAINT chk_catalog_publication_requests_comments CHECK (decision_comments IS NULL OR length(trim(decision_comments)) BETWEEN 1 AND 4000)
);

CREATE TABLE public.catalog_publication_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    publication_version_id UUID NOT NULL REFERENCES public.catalog_publication_versions(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    publication_request_id UUID REFERENCES public.catalog_publication_requests(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    event_sequence BIGINT GENERATED ALWAYS AS IDENTITY,
    event_type TEXT NOT NULL,
    from_status TEXT,
    to_status TEXT,
    actor_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    event_comment TEXT,
    event_details JSONB NOT NULL DEFAULT '{}'::JSONB,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_catalog_publication_events_sequence UNIQUE (event_sequence),
    CONSTRAINT chk_catalog_publication_events_type CHECK (event_type IN (
        'DRAFT_CREATED', 'SUBMITTED', 'REVIEW_APPROVED', 'APPROVED', 'REJECTED',
        'SCHEDULED', 'PUBLISHED', 'SUSPENDED', 'UNPUBLISHED', 'ARCHIVED',
        'SUPERSEDED', 'ROLLBACK_PUBLISHED')),
    CONSTRAINT chk_catalog_publication_events_statuses CHECK (
        (from_status IS NULL OR from_status IN ('DRAFT', 'IN_REVIEW', 'APPROVED', 'SCHEDULED', 'PUBLISHED', 'SUSPENDED', 'ARCHIVED', 'REJECTED'))
        AND (to_status IS NULL OR to_status IN ('DRAFT', 'IN_REVIEW', 'APPROVED', 'SCHEDULED', 'PUBLISHED', 'SUSPENDED', 'ARCHIVED', 'REJECTED'))),
    CONSTRAINT chk_catalog_publication_events_details CHECK (jsonb_typeof(event_details) = 'object'),
    CONSTRAINT chk_catalog_publication_events_comment CHECK (event_comment IS NULL OR length(trim(event_comment)) BETWEEN 1 AND 4000)
);

CREATE INDEX idx_catalog_publication_versions_target ON public.catalog_publication_versions(target_entity_type, target_entity_id, version_number DESC);
CREATE INDEX idx_catalog_publication_versions_work_queue ON public.catalog_publication_versions(lifecycle_status, scheduled_publish_at) WHERE lifecycle_status IN ('IN_REVIEW', 'APPROVED', 'SCHEDULED');
CREATE INDEX idx_catalog_publication_versions_supersedes ON public.catalog_publication_versions(supersedes_version_id) WHERE supersedes_version_id IS NOT NULL;
CREATE INDEX idx_catalog_publication_versions_rollback ON public.catalog_publication_versions(rollback_of_version_id) WHERE rollback_of_version_id IS NOT NULL;
CREATE INDEX idx_catalog_publication_requests_reviewer ON public.catalog_publication_requests(reviewer_user_id, request_status, submitted_at);
CREATE INDEX idx_catalog_publication_requests_approver ON public.catalog_publication_requests(final_approver_user_id, request_status, submitted_at);
CREATE INDEX idx_catalog_publication_events_version ON public.catalog_publication_events(publication_version_id, event_sequence);
CREATE INDEX idx_catalog_publication_events_request ON public.catalog_publication_events(publication_request_id, event_sequence) WHERE publication_request_id IS NOT NULL;

CREATE OR REPLACE FUNCTION public.manage_catalog_publication_version_change()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY INVOKER SET search_path = pg_catalog AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.lifecycle_status := 'DRAFT';
        NEW.created_by_user_id := COALESCE(auth.uid(), NEW.created_by_user_id);
        NEW.published_at := NULL; NEW.unpublished_at := NULL; NEW.suspended_at := NULL;
        NEW.suspension_reason := NULL; NEW.archived_at := NULL;
        NEW.rejected_at := NULL; NEW.rejection_reason := NULL;
    ELSE
        IF NEW.id IS DISTINCT FROM OLD.id OR NEW.target_entity_type IS DISTINCT FROM OLD.target_entity_type
           OR NEW.bank_id IS DISTINCT FROM OLD.bank_id OR NEW.card_id IS DISTINCT FROM OLD.card_id
           OR NEW.card_fee_id IS DISTINCT FROM OLD.card_fee_id OR NEW.card_benefit_id IS DISTINCT FROM OLD.card_benefit_id
           OR NEW.reward_rule_id IS DISTINCT FROM OLD.reward_rule_id OR NEW.loyalty_program_id IS DISTINCT FROM OLD.loyalty_program_id
           OR NEW.card_eligibility_requirement_id IS DISTINCT FROM OLD.card_eligibility_requirement_id
           OR NEW.merchant_id IS DISTINCT FROM OLD.merchant_id
           OR NEW.version_number IS DISTINCT FROM OLD.version_number
           OR NEW.created_by_user_id IS DISTINCT FROM OLD.created_by_user_id
           OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
            RAISE EXCEPTION 'protected publication-version identity fields may not be modified' USING ERRCODE = '42501';
        END IF;
        IF current_user = 'authenticated' AND NEW.lifecycle_status IS DISTINCT FROM OLD.lifecycle_status THEN
            RAISE EXCEPTION 'publication lifecycle transitions must use governance functions' USING ERRCODE = '42501';
        END IF;
        IF current_user = 'authenticated' AND OLD.lifecycle_status <> 'DRAFT'
           AND (NEW.content_snapshot IS DISTINCT FROM OLD.content_snapshot
                OR NEW.change_summary IS DISTINCT FROM OLD.change_summary
                OR NEW.source_provenance_id IS DISTINCT FROM OLD.source_provenance_id
                OR NEW.effective_from IS DISTINCT FROM OLD.effective_from
                OR NEW.effective_until IS DISTINCT FROM OLD.effective_until
                OR NEW.scheduled_publish_at IS DISTINCT FROM OLD.scheduled_publish_at
                OR NEW.scheduled_unpublish_at IS DISTINCT FROM OLD.scheduled_unpublish_at
                OR NEW.supersedes_version_id IS DISTINCT FROM OLD.supersedes_version_id
                OR NEW.rollback_of_version_id IS DISTINCT FROM OLD.rollback_of_version_id) THEN
            RAISE EXCEPTION 'submitted publication version content and schedule are immutable' USING ERRCODE = '42501';
        END IF;
        IF OLD.lifecycle_status IN ('ARCHIVED', 'REJECTED') THEN
            RAISE EXCEPTION 'terminal publication versions are immutable' USING ERRCODE = '42501';
        END IF;
        IF (OLD.lifecycle_status, NEW.lifecycle_status) NOT IN (
            ('DRAFT','DRAFT'), ('DRAFT','IN_REVIEW'), ('IN_REVIEW','IN_REVIEW'),
            ('IN_REVIEW','APPROVED'), ('IN_REVIEW','SCHEDULED'), ('IN_REVIEW','REJECTED'),
            ('APPROVED','APPROVED'), ('APPROVED','SCHEDULED'), ('APPROVED','PUBLISHED'), ('APPROVED','ARCHIVED'),
            ('SCHEDULED','SCHEDULED'), ('SCHEDULED','PUBLISHED'), ('SCHEDULED','ARCHIVED'),
            ('PUBLISHED','PUBLISHED'), ('PUBLISHED','SUSPENDED'), ('PUBLISHED','ARCHIVED'),
            ('SUSPENDED','SUSPENDED'), ('SUSPENDED','PUBLISHED'), ('SUSPENDED','ARCHIVED')
        ) THEN
            RAISE EXCEPTION 'invalid catalog publication transition: % to %', OLD.lifecycle_status, NEW.lifecycle_status USING ERRCODE = '23514';
        END IF;
    END IF;
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.record_catalog_publication_event()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_type TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN v_type := 'DRAFT_CREATED';
    ELSIF NEW.lifecycle_status = OLD.lifecycle_status THEN RETURN NEW;
    ELSE v_type := CASE NEW.lifecycle_status
        WHEN 'IN_REVIEW' THEN 'SUBMITTED' WHEN 'APPROVED' THEN 'APPROVED'
        WHEN 'SCHEDULED' THEN 'SCHEDULED' WHEN 'PUBLISHED' THEN
            CASE WHEN NEW.rollback_of_version_id IS NULL THEN 'PUBLISHED' ELSE 'ROLLBACK_PUBLISHED' END
        WHEN 'SUSPENDED' THEN 'SUSPENDED' WHEN 'ARCHIVED' THEN
            CASE WHEN NEW.supersedes_version_id IS NULL THEN 'ARCHIVED' ELSE 'SUPERSEDED' END
        WHEN 'REJECTED' THEN 'REJECTED' END;
    END IF;
    INSERT INTO public.catalog_publication_events(publication_version_id, event_type, from_status, to_status, actor_user_id)
    VALUES (NEW.id, v_type, CASE WHEN TG_OP = 'INSERT' THEN NULL ELSE OLD.lifecycle_status END, NEW.lifecycle_status, auth.uid());
    INSERT INTO public.audit_events(audit_reference,event_category,event_type,event_action,actor_type,actor_user_id,source_component,entity_type,entity_id,operation_name,data_classification,before_values,after_values,event_details)
    VALUES ('catalog-publication.'||gen_random_uuid()::text,'GOVERNANCE','catalog_publication_'||lower(v_type),
        CASE v_type WHEN 'SUBMITTED' THEN 'SUBMIT' WHEN 'APPROVED' THEN 'APPROVE' WHEN 'REJECTED' THEN 'REJECT' WHEN 'PUBLISHED' THEN 'ACTIVATE' WHEN 'ROLLBACK_PUBLISHED' THEN 'RESTORE' WHEN 'SUSPENDED' THEN 'DEACTIVATE' ELSE CASE WHEN TG_OP='INSERT' THEN 'CREATE' ELSE 'UPDATE' END END,
        CASE WHEN auth.uid() IS NULL THEN 'SYSTEM' ELSE 'ADMIN' END,auth.uid(),'DATABASE_CATALOG_PUBLICATION','catalog_publication_versions',NEW.id,TG_OP,'INTERNAL',CASE WHEN TG_OP='INSERT' THEN NULL ELSE to_jsonb(OLD) END,to_jsonb(NEW),jsonb_build_object('event_type',v_type));
    RETURN NEW;
END;
$$;
COMMENT ON FUNCTION public.record_catalog_publication_event() IS 'SECURITY DEFINER is required to append domain history and audit_events for every publication transition without granting callers direct write access; all references are schema-qualified and search_path is pinned.';

CREATE OR REPLACE FUNCTION public.submit_catalog_publication(
    requested_version_id UUID, reviewer_id UUID, final_approver_id UUID,
    publish_at TIMESTAMPTZ DEFAULT NULL, unpublish_at TIMESTAMPTZ DEFAULT NULL,
    effective_start TIMESTAMPTZ DEFAULT NULL, effective_end TIMESTAMPTZ DEFAULT NULL
) RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v public.catalog_publication_versions; request_id UUID := gen_random_uuid(); approval_id UUID := gen_random_uuid(); actor UUID := auth.uid();
BEGIN
    IF actor IS NULL OR NOT public.has_active_platform_permission('CATALOG_MANAGE') THEN RAISE EXCEPTION 'CATALOG_MANAGE permission required' USING ERRCODE='42501'; END IF;
    SELECT * INTO v FROM public.catalog_publication_versions WHERE id=requested_version_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'publication version not found' USING ERRCODE='P0002'; END IF;
    IF v.lifecycle_status <> 'DRAFT' THEN
        SELECT id INTO request_id FROM public.catalog_publication_requests WHERE publication_version_id=requested_version_id;
        IF request_id IS NOT NULL THEN RETURN request_id; END IF;
        RAISE EXCEPTION 'only DRAFT versions may be submitted' USING ERRCODE='23514';
    END IF;
    IF actor = final_approver_id THEN RAISE EXCEPTION 'requester may not be final approver' USING ERRCODE='23514'; END IF;
    IF reviewer_id = final_approver_id THEN RAISE EXCEPTION 'reviewer and final approver must be different users' USING ERRCODE='23514'; END IF;
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
COMMENT ON FUNCTION public.submit_catalog_publication(UUID,UUID,UUID,TIMESTAMPTZ,TIMESTAMPTZ,TIMESTAMPTZ,TIMESTAMPTZ) IS 'SECURITY DEFINER provides an atomic, concurrency-safe submission boundary across publication and existing generic approval tables; authorization is checked with CATALOG_MANAGE and search_path is pinned.';

CREATE OR REPLACE FUNCTION public.decide_catalog_publication(requested_request_id UUID, decision TEXT, comments TEXT)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE r public.catalog_publication_requests; d public.approval_decisions; actor UUID:=auth.uid(); next_status TEXT;
BEGIN
    IF actor IS NULL OR NOT public.has_active_platform_permission('CATALOG_MANAGE') THEN RAISE EXCEPTION 'CATALOG_MANAGE permission required' USING ERRCODE='42501'; END IF;
    IF decision NOT IN ('APPROVED','REJECTED') OR comments IS NULL OR length(trim(comments))=0 THEN RAISE EXCEPTION 'decision and comments are required' USING ERRCODE='23514'; END IF;
    SELECT * INTO r FROM public.catalog_publication_requests WHERE id=requested_request_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'publication request not found' USING ERRCODE='P0002'; END IF;
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
COMMENT ON FUNCTION public.decide_catalog_publication(UUID,TEXT,TEXT) IS 'SECURITY DEFINER serializes assigned reviewer/final-approver decisions, enforces ordered two-person approval and requester/final-approver separation, and updates generic approval records atomically. CATALOG_MANAGE is an interim platform-wide gate pending 0049.';

CREATE OR REPLACE FUNCTION public.publish_catalog_version(requested_version_id UUID)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v public.catalog_publication_versions; actor UUID:=auth.uid();
BEGIN
    IF actor IS NOT NULL AND NOT public.has_active_platform_permission('CATALOG_MANAGE') THEN RAISE EXCEPTION 'CATALOG_MANAGE permission required' USING ERRCODE='42501'; END IF;
    SELECT * INTO v FROM public.catalog_publication_versions WHERE id=requested_version_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'publication version not found' USING ERRCODE='P0002'; END IF;
    IF v.lifecycle_status='PUBLISHED' THEN RETURN 'PUBLISHED'; END IF;
    IF v.lifecycle_status NOT IN ('APPROVED','SCHEDULED','SUSPENDED') THEN RAISE EXCEPTION 'version is not publishable' USING ERRCODE='23514'; END IF;
    IF v.scheduled_publish_at IS NOT NULL AND v.scheduled_publish_at>statement_timestamp() THEN RAISE EXCEPTION 'scheduled publication time has not arrived' USING ERRCODE='23514'; END IF;
    UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED',published_at=COALESCE(published_at,now()),effective_from=COALESCE(effective_from,scheduled_publish_at,now()),unpublished_at=NULL,suspended_at=NULL,suspension_reason=NULL WHERE id=v.id;
    RETURN 'PUBLISHED';
END;
$$;
COMMENT ON FUNCTION public.publish_catalog_version(UUID) IS 'SECURITY DEFINER is the idempotent, row-locked publication boundary used by administrators or a trusted scheduler; it checks CATALOG_MANAGE for authenticated callers and relies on the exclusion constraint for concurrency-safe window enforcement.';

CREATE OR REPLACE FUNCTION public.unpublish_catalog_version(requested_version_id UUID, archive BOOLEAN, reason TEXT)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v public.catalog_publication_versions; actor UUID:=auth.uid(); target TEXT;
BEGIN
    IF actor IS NOT NULL AND NOT public.has_active_platform_permission('CATALOG_MANAGE') THEN RAISE EXCEPTION 'CATALOG_MANAGE permission required' USING ERRCODE='42501'; END IF;
    IF reason IS NULL OR length(trim(reason))=0 THEN RAISE EXCEPTION 'unpublication reason is required' USING ERRCODE='23514'; END IF;
    SELECT * INTO v FROM public.catalog_publication_versions WHERE id=requested_version_id FOR UPDATE;
    target:=CASE WHEN archive THEN 'ARCHIVED' ELSE 'SUSPENDED' END;
    IF v.lifecycle_status=target THEN RETURN target; END IF;
    IF v.lifecycle_status NOT IN ('PUBLISHED','SUSPENDED') THEN RAISE EXCEPTION 'version is not published or suspended' USING ERRCODE='23514'; END IF;
    UPDATE public.catalog_publication_versions SET lifecycle_status=target,unpublished_at=COALESCE(unpublished_at,now()),suspended_at=CASE WHEN target='SUSPENDED' THEN now() ELSE suspended_at END,suspension_reason=CASE WHEN target='SUSPENDED' THEN reason ELSE suspension_reason END,archived_at=CASE WHEN target='ARCHIVED' THEN now() ELSE archived_at END WHERE id=v.id;
    RETURN target;
END;
$$;
COMMENT ON FUNCTION public.unpublish_catalog_version(UUID,BOOLEAN,TEXT) IS 'SECURITY DEFINER provides an idempotent, row-locked suspend/archive boundary with mandatory rationale and CATALOG_MANAGE authorization.';

CREATE OR REPLACE FUNCTION public.rollback_catalog_version(current_version_id UUID, replacement_version_id UUID, reason TEXT)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE current_v public.catalog_publication_versions; replacement_v public.catalog_publication_versions; actor UUID:=auth.uid();
BEGIN
    IF actor IS NOT NULL AND NOT public.has_active_platform_permission('CATALOG_MANAGE') THEN RAISE EXCEPTION 'CATALOG_MANAGE permission required' USING ERRCODE='42501'; END IF;
    IF reason IS NULL OR length(trim(reason))=0 OR current_version_id=replacement_version_id THEN RAISE EXCEPTION 'valid rollback target and reason are required' USING ERRCODE='23514'; END IF;
    PERFORM pg_advisory_xact_lock(hashtextextended(least(current_version_id::text,replacement_version_id::text)||greatest(current_version_id::text,replacement_version_id::text),0));
    SELECT * INTO current_v FROM public.catalog_publication_versions WHERE id=current_version_id FOR UPDATE;
    SELECT * INTO replacement_v FROM public.catalog_publication_versions WHERE id=replacement_version_id FOR UPDATE;
    IF current_v.lifecycle_status<>'PUBLISHED' OR replacement_v.lifecycle_status NOT IN ('APPROVED','SCHEDULED','SUSPENDED') THEN RAISE EXCEPTION 'invalid rollback states' USING ERRCODE='23514'; END IF;
    IF current_v.target_entity_type<>replacement_v.target_entity_type OR current_v.target_entity_id<>replacement_v.target_entity_id THEN RAISE EXCEPTION 'rollback versions must target the same entity' USING ERRCODE='23514'; END IF;
    UPDATE public.catalog_publication_versions SET lifecycle_status='ARCHIVED',archived_at=now(),unpublished_at=now(),supersedes_version_id=replacement_version_id WHERE id=current_v.id;
    UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED',published_at=COALESCE(published_at,now()),effective_from=now(),effective_until=NULL,rollback_of_version_id=current_v.id,suspended_at=NULL,suspension_reason=NULL WHERE id=replacement_v.id;
    RETURN 'PUBLISHED';
END;
$$;
COMMENT ON FUNCTION public.rollback_catalog_version(UUID,UUID,TEXT) IS 'SECURITY DEFINER takes a deterministic advisory lock plus row locks, archives the current version, and republishes an approved prior/replacement version atomically with rollback lineage and CATALOG_MANAGE authorization.';

CREATE TRIGGER trg_catalog_publication_versions_manage BEFORE INSERT OR UPDATE ON public.catalog_publication_versions FOR EACH ROW EXECUTE FUNCTION public.manage_catalog_publication_version_change();
CREATE TRIGGER trg_catalog_publication_versions_events AFTER INSERT OR UPDATE ON public.catalog_publication_versions FOR EACH ROW EXECUTE FUNCTION public.record_catalog_publication_event();
CREATE TRIGGER trg_catalog_publication_versions_updated_at BEFORE UPDATE ON public.catalog_publication_versions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_catalog_publication_requests_updated_at BEFORE UPDATE ON public.catalog_publication_requests FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.catalog_publication_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.catalog_publication_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.catalog_publication_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY catalog_governance_manage_versions ON public.catalog_publication_versions FOR ALL TO authenticated USING (public.has_active_platform_permission('CATALOG_MANAGE')) WITH CHECK (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_governance_read_requests ON public.catalog_publication_requests FOR SELECT TO authenticated USING (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_governance_read_events ON public.catalog_publication_events FOR SELECT TO authenticated USING (public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_governance_read_approval_requests ON public.approval_requests FOR SELECT TO authenticated USING (approval_type='CATALOG_PUBLICATION' AND public.has_active_platform_permission('CATALOG_MANAGE'));
CREATE POLICY catalog_governance_read_approval_decisions ON public.approval_decisions FOR SELECT TO authenticated USING (public.has_active_platform_permission('CATALOG_MANAGE') AND EXISTS (SELECT 1 FROM public.approval_requests WHERE approval_requests.id=approval_decisions.approval_request_id AND approval_requests.approval_type='CATALOG_PUBLICATION'));

REVOKE ALL ON TABLE public.catalog_publication_versions,public.catalog_publication_requests,public.catalog_publication_events FROM PUBLIC,anon,authenticated;
GRANT SELECT,INSERT,UPDATE ON public.catalog_publication_versions TO authenticated;
GRANT SELECT ON public.catalog_publication_requests,public.catalog_publication_events TO authenticated;
GRANT SELECT ON public.approval_requests,public.approval_decisions TO authenticated;
GRANT SELECT,INSERT,UPDATE,DELETE ON public.catalog_publication_versions,public.catalog_publication_requests,public.catalog_publication_events TO service_role;
REVOKE EXECUTE ON FUNCTION public.manage_catalog_publication_version_change(),public.record_catalog_publication_event() FROM PUBLIC,anon,authenticated;
REVOKE EXECUTE ON FUNCTION public.submit_catalog_publication(UUID,UUID,UUID,TIMESTAMPTZ,TIMESTAMPTZ,TIMESTAMPTZ,TIMESTAMPTZ),public.decide_catalog_publication(UUID,TEXT,TEXT),public.publish_catalog_version(UUID),public.unpublish_catalog_version(UUID,BOOLEAN,TEXT),public.rollback_catalog_version(UUID,UUID,TEXT) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.submit_catalog_publication(UUID,UUID,UUID,TIMESTAMPTZ,TIMESTAMPTZ,TIMESTAMPTZ,TIMESTAMPTZ),public.decide_catalog_publication(UUID,TEXT,TEXT),public.publish_catalog_version(UUID),public.unpublish_catalog_version(UUID,BOOLEAN,TEXT),public.rollback_catalog_version(UUID,UUID,TEXT) TO authenticated,service_role;

COMMENT ON TABLE public.catalog_publication_versions IS 'Immutable-target catalog content versions governed from draft through review, approval, scheduling, publication, suspension, rejection, supersession, rollback, and archival. Typed target foreign keys prevent unsupported or dangling catalog references.';
COMMENT ON TABLE public.catalog_publication_requests IS 'Publication-specific projection linked one-to-one to the generic 0040 approval request; reviewer/final-approver work items are reused from approval_decisions rather than duplicated.';
COMMENT ON TABLE public.catalog_publication_events IS 'Append-only, ordered domain history for catalog publication lifecycle events; direct authenticated writes are intentionally not granted.';
COMMENT ON CONSTRAINT ex_catalog_publication_versions_active_window ON public.catalog_publication_versions IS 'Prevents overlapping effective windows for simultaneously PUBLISHED versions of the same catalog entity, including concurrent transactions.';

COMMIT;
