CREATE TABLE public.governance_controls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    control_reference TEXT NOT NULL,

    control_name TEXT NOT NULL,

    control_description TEXT,

    control_domain TEXT NOT NULL,

    control_category TEXT NOT NULL,

    control_type TEXT NOT NULL,

    control_frequency TEXT NOT NULL DEFAULT 'CONTINUOUS',

    control_status TEXT NOT NULL DEFAULT 'DRAFT',

    control_owner_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    evidence_owner_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    approval_owner_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    risk_level TEXT NOT NULL DEFAULT 'MEDIUM',

    automation_level TEXT NOT NULL DEFAULT 'MANUAL',

    requires_evidence BOOLEAN NOT NULL DEFAULT TRUE,

    requires_approval BOOLEAN NOT NULL DEFAULT FALSE,

    requires_periodic_testing BOOLEAN NOT NULL DEFAULT TRUE,

    testing_interval_days INTEGER,

    evidence_retention_days INTEGER,

    effective_from TIMESTAMPTZ,

    effective_until TIMESTAMPTZ,

    last_reviewed_at TIMESTAMPTZ,

    next_review_due_at TIMESTAMPTZ,

    approved_at TIMESTAMPTZ,

    approved_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    suspended_at TIMESTAMPTZ,

    suspension_reason TEXT,

    retired_at TIMESTAMPTZ,

    retirement_reason TEXT,

    regulatory_references JSONB NOT NULL DEFAULT '[]'::JSONB,

    policy_references JSONB NOT NULL DEFAULT '[]'::JSONB,

    implementation_guidance JSONB NOT NULL DEFAULT '{}'::JSONB,

    testing_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    evidence_requirements JSONB NOT NULL DEFAULT '[]'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_governance_controls_reference
        UNIQUE (
            control_reference
        ),

    CONSTRAINT chk_governance_controls_reference
        CHECK (
            control_reference
                ~ '^[A-Z0-9]+(?:[-_.:][A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_governance_controls_name
        CHECK (
            length(trim(control_name)) > 0
        ),

    CONSTRAINT chk_governance_controls_domain
        CHECK (
            control_domain IN (
                'GOVERNANCE',
                'RISK_MANAGEMENT',
                'INFORMATION_SECURITY',
                'CYBERSECURITY',
                'DATA_GOVERNANCE',
                'DATA_PRIVACY',
                'IDENTITY_AND_ACCESS',
                'APPLICATION_SECURITY',
                'CHANGE_MANAGEMENT',
                'BUSINESS_CONTINUITY',
                'INCIDENT_MANAGEMENT',
                'THIRD_PARTY_RISK',
                'REGULATORY_COMPLIANCE',
                'FINANCIAL_CRIME',
                'CUSTOMER_PROTECTION',
                'MODEL_GOVERNANCE',
                'AUDIT',
                'RECORDS_MANAGEMENT',
                'OTHER'
            )
        ),

    CONSTRAINT chk_governance_controls_category
        CHECK (
            control_category IN (
                'PREVENTIVE',
                'DETECTIVE',
                'CORRECTIVE',
                'DIRECTIVE',
                'COMPENSATING',
                'RECOVERY',
                'GOVERNANCE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_governance_controls_type
        CHECK (
            control_type IN (
                'POLICY',
                'PROCEDURE',
                'TECHNICAL',
                'ADMINISTRATIVE',
                'PHYSICAL',
                'MONITORING',
                'RECONCILIATION',
                'APPROVAL',
                'SEGREGATION_OF_DUTIES',
                'VALIDATION',
                'REVIEW',
                'TRAINING',
                'CONTRACTUAL',
                'OTHER'
            )
        ),

    CONSTRAINT chk_governance_controls_frequency
        CHECK (
            control_frequency IN (
                'CONTINUOUS',
                'EVENT_DRIVEN',
                'DAILY',
                'WEEKLY',
                'MONTHLY',
                'QUARTERLY',
                'SEMI_ANNUAL',
                'ANNUAL',
                'BIENNIAL',
                'AD_HOC'
            )
        ),

    CONSTRAINT chk_governance_controls_status
        CHECK (
            control_status IN (
                'DRAFT',
                'UNDER_REVIEW',
                'APPROVED',
                'ACTIVE',
                'PARTIALLY_IMPLEMENTED',
                'INEFFECTIVE',
                'SUSPENDED',
                'RETIRED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_governance_controls_risk_level
        CHECK (
            risk_level IN (
                'LOW',
                'MEDIUM',
                'HIGH',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_governance_controls_automation
        CHECK (
            automation_level IN (
                'MANUAL',
                'SEMI_AUTOMATED',
                'AUTOMATED',
                'CONTINUOUS_MONITORING'
            )
        ),

    CONSTRAINT chk_governance_controls_testing_interval
        CHECK (
            testing_interval_days IS NULL
            OR testing_interval_days > 0
        ),

    CONSTRAINT chk_governance_controls_evidence_retention
        CHECK (
            evidence_retention_days IS NULL
            OR evidence_retention_days >= 0
        ),

    CONSTRAINT chk_governance_controls_effective_dates
        CHECK (
            effective_until IS NULL
            OR effective_from IS NULL
            OR effective_until >= effective_from
        ),

    CONSTRAINT chk_governance_controls_review_dates
        CHECK (
            next_review_due_at IS NULL
            OR last_reviewed_at IS NULL
            OR next_review_due_at >= last_reviewed_at
        ),

    CONSTRAINT chk_governance_controls_approval
        CHECK (
            approved_by IS NULL
            OR approved_at IS NOT NULL
        ),

    CONSTRAINT chk_governance_controls_suspension
        CHECK (
            suspended_at IS NULL
            OR control_status IN (
                'SUSPENDED',
                'RETIRED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_governance_controls_retirement
        CHECK (
            retired_at IS NULL
            OR control_status IN (
                'RETIRED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_governance_controls_regulatory_references
        CHECK (
            jsonb_typeof(regulatory_references) = 'array'
        ),

    CONSTRAINT chk_governance_controls_policy_references
        CHECK (
            jsonb_typeof(policy_references) = 'array'
        ),

    CONSTRAINT chk_governance_controls_guidance
        CHECK (
            jsonb_typeof(implementation_guidance) = 'object'
        ),

    CONSTRAINT chk_governance_controls_testing_configuration
        CHECK (
            jsonb_typeof(testing_configuration) = 'object'
        ),

    CONSTRAINT chk_governance_controls_evidence_requirements
        CHECK (
            jsonb_typeof(evidence_requirements) = 'array'
        ),

    CONSTRAINT chk_governance_controls_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.governance_control_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    control_id UUID NOT NULL
        REFERENCES public.governance_controls(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    assessment_reference TEXT NOT NULL,

    assessment_type TEXT NOT NULL,

    assessment_status TEXT NOT NULL DEFAULT 'PLANNED',

    assessment_result TEXT,

    assessment_period_start DATE,

    assessment_period_end DATE,

    scheduled_at TIMESTAMPTZ,

    started_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    reviewed_at TIMESTAMPTZ,

    approved_at TIMESTAMPTZ,

    assessor_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    reviewer_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    approver_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    sample_size INTEGER,

    exceptions_found INTEGER NOT NULL DEFAULT 0,

    severity TEXT,

    effectiveness_score NUMERIC(5, 2),

    confidence_score NUMERIC(5, 2),

    remediation_required BOOLEAN NOT NULL DEFAULT FALSE,

    remediation_due_at TIMESTAMPTZ,

    remediation_completed_at TIMESTAMPTZ,

    conclusion TEXT,

    assessor_notes TEXT,

    reviewer_notes TEXT,

    evidence_summary JSONB NOT NULL DEFAULT '[]'::JSONB,

    test_procedures JSONB NOT NULL DEFAULT '[]'::JSONB,

    test_results JSONB NOT NULL DEFAULT '[]'::JSONB,

    exceptions JSONB NOT NULL DEFAULT '[]'::JSONB,

    remediation_plan JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_governance_control_assessments_reference
        UNIQUE (
            assessment_reference
        ),

    CONSTRAINT chk_governance_control_assessments_reference
        CHECK (
            assessment_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_governance_control_assessments_type
        CHECK (
            assessment_type IN (
                'DESIGN_EFFECTIVENESS',
                'OPERATING_EFFECTIVENESS',
                'SELF_ASSESSMENT',
                'INTERNAL_AUDIT',
                'EXTERNAL_AUDIT',
                'REGULATORY_REVIEW',
                'CONTINUOUS_MONITORING',
                'REMEDIATION_VALIDATION',
                'AD_HOC'
            )
        ),

    CONSTRAINT chk_governance_control_assessments_status
        CHECK (
            assessment_status IN (
                'PLANNED',
                'SCHEDULED',
                'IN_PROGRESS',
                'PENDING_EVIDENCE',
                'PENDING_REVIEW',
                'COMPLETED',
                'APPROVED',
                'REJECTED',
                'CANCELLED'
            )
        ),

    CONSTRAINT chk_governance_control_assessments_result
        CHECK (
            assessment_result IS NULL
            OR assessment_result IN (
                'EFFECTIVE',
                'MOSTLY_EFFECTIVE',
                'PARTIALLY_EFFECTIVE',
                'INEFFECTIVE',
                'NOT_IMPLEMENTED',
                'NOT_APPLICABLE',
                'INCONCLUSIVE'
            )
        ),

    CONSTRAINT chk_governance_control_assessments_period
        CHECK (
            assessment_period_end IS NULL
            OR assessment_period_start IS NULL
            OR assessment_period_end >= assessment_period_start
        ),

    CONSTRAINT chk_governance_control_assessments_started
        CHECK (
            started_at IS NULL
            OR scheduled_at IS NULL
            OR started_at >= scheduled_at
        ),

    CONSTRAINT chk_governance_control_assessments_completed
        CHECK (
            completed_at IS NULL
            OR started_at IS NULL
            OR completed_at >= started_at
        ),

    CONSTRAINT chk_governance_control_assessments_reviewed
        CHECK (
            reviewed_at IS NULL
            OR completed_at IS NULL
            OR reviewed_at >= completed_at
        ),

    CONSTRAINT chk_governance_control_assessments_approved
        CHECK (
            approved_at IS NULL
            OR reviewed_at IS NULL
            OR approved_at >= reviewed_at
        ),

    CONSTRAINT chk_governance_control_assessments_sample_size
        CHECK (
            sample_size IS NULL
            OR sample_size >= 0
        ),

    CONSTRAINT chk_governance_control_assessments_exceptions
        CHECK (
            exceptions_found >= 0
            AND (
                sample_size IS NULL
                OR exceptions_found <= sample_size
            )
        ),

    CONSTRAINT chk_governance_control_assessments_severity
        CHECK (
            severity IS NULL
            OR severity IN (
                'INFORMATIONAL',
                'LOW',
                'MEDIUM',
                'HIGH',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_governance_control_assessments_scores
        CHECK (
            (
                effectiveness_score IS NULL
                OR effectiveness_score BETWEEN 0 AND 100
            )
            AND
            (
                confidence_score IS NULL
                OR confidence_score BETWEEN 0 AND 100
            )
        ),

    CONSTRAINT chk_governance_control_assessments_remediation
        CHECK (
            remediation_required = FALSE
            OR remediation_due_at IS NOT NULL
        ),

    CONSTRAINT chk_governance_control_assessments_remediation_completion
        CHECK (
            remediation_completed_at IS NULL
            OR remediation_due_at IS NULL
            OR remediation_completed_at >= completed_at
        ),

    CONSTRAINT chk_governance_control_assessments_evidence
        CHECK (
            jsonb_typeof(evidence_summary) = 'array'
        ),

    CONSTRAINT chk_governance_control_assessments_procedures
        CHECK (
            jsonb_typeof(test_procedures) = 'array'
        ),

    CONSTRAINT chk_governance_control_assessments_results
        CHECK (
            jsonb_typeof(test_results) = 'array'
        ),

    CONSTRAINT chk_governance_control_assessments_exceptions_json
        CHECK (
            jsonb_typeof(exceptions) = 'array'
        ),

    CONSTRAINT chk_governance_control_assessments_remediation_plan
        CHECK (
            jsonb_typeof(remediation_plan) = 'object'
        ),

    CONSTRAINT chk_governance_control_assessments_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    audit_reference TEXT NOT NULL,

    occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    received_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    event_category TEXT NOT NULL,

    event_type TEXT NOT NULL,

    event_action TEXT NOT NULL,

    event_outcome TEXT NOT NULL DEFAULT 'SUCCESS',

    severity TEXT NOT NULL DEFAULT 'INFORMATIONAL',

    actor_type TEXT NOT NULL DEFAULT 'SYSTEM',

    actor_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    actor_reference TEXT,

    actor_display_name TEXT,

    impersonated_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    session_reference TEXT,

    request_reference TEXT,

    correlation_id TEXT,

    trace_id TEXT,

    source_service TEXT,

    source_component TEXT,

    source_environment TEXT,

    source_ip_hash TEXT,

    user_agent_hash TEXT,

    device_reference TEXT,

    entity_type TEXT,

    entity_id UUID,

    entity_reference TEXT,

    parent_entity_type TEXT,

    parent_entity_id UUID,

    operation_name TEXT,

    reason_code TEXT,

    reason_text TEXT,

    approval_reference TEXT,

    data_classification TEXT,

    contains_personal_data BOOLEAN NOT NULL DEFAULT FALSE,

    contains_sensitive_data BOOLEAN NOT NULL DEFAULT FALSE,

    contains_financial_data BOOLEAN NOT NULL DEFAULT FALSE,

    contains_authentication_data BOOLEAN NOT NULL DEFAULT FALSE,

    before_values JSONB,

    after_values JSONB,

    changed_fields JSONB NOT NULL DEFAULT '[]'::JSONB,

    event_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    security_context JSONB NOT NULL DEFAULT '{}'::JSONB,

    compliance_context JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    retention_until TIMESTAMPTZ,

    legal_hold_applied BOOLEAN NOT NULL DEFAULT FALSE,

    integrity_hash TEXT,

    previous_integrity_hash TEXT,

    is_exported BOOLEAN NOT NULL DEFAULT FALSE,

    exported_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_audit_events_reference
        UNIQUE (
            audit_reference
        ),

    CONSTRAINT chk_audit_events_reference
        CHECK (
            audit_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_audit_events_received
        CHECK (
            received_at >= occurred_at
        ),

    CONSTRAINT chk_audit_events_category
        CHECK (
            event_category IN (
                'AUTHENTICATION',
                'AUTHORIZATION',
                'USER_MANAGEMENT',
                'DATA_ACCESS',
                'DATA_CHANGE',
                'DATA_EXPORT',
                'DATA_DELETION',
                'CONSENT',
                'APPLICATION',
                'RECOMMENDATION',
                'BANK_INTEGRATION',
                'PARTNERSHIP',
                'COMMISSION',
                'SETTLEMENT',
                'SECURITY',
                'PRIVACY',
                'COMPLIANCE',
                'GOVERNANCE',
                'ADMINISTRATION',
                'SYSTEM',
                'OTHER'
            )
        ),

    CONSTRAINT chk_audit_events_action
        CHECK (
            event_action IN (
                'CREATE',
                'READ',
                'UPDATE',
                'DELETE',
                'RESTORE',
                'SUBMIT',
                'APPROVE',
                'REJECT',
                'CANCEL',
                'ACTIVATE',
                'DEACTIVATE',
                'ARCHIVE',
                'EXPORT',
                'IMPORT',
                'DOWNLOAD',
                'UPLOAD',
                'LOGIN',
                'LOGOUT',
                'VERIFY',
                'EXECUTE',
                'SEND',
                'RECEIVE',
                'CALCULATE',
                'OVERRIDE',
                'ASSIGN',
                'UNASSIGN',
                'GRANT',
                'REVOKE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_audit_events_outcome
        CHECK (
            event_outcome IN (
                'SUCCESS',
                'PARTIAL_SUCCESS',
                'FAILURE',
                'DENIED',
                'BLOCKED',
                'PENDING',
                'CANCELLED',
                'UNKNOWN'
            )
        ),

    CONSTRAINT chk_audit_events_severity
        CHECK (
            severity IN (
                'INFORMATIONAL',
                'LOW',
                'MEDIUM',
                'HIGH',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_audit_events_actor_type
        CHECK (
            actor_type IN (
                'CUSTOMER',
                'ADMIN',
                'ADVISOR',
                'BANK_USER',
                'PARTNER_USER',
                'SERVICE_ACCOUNT',
                'SYSTEM',
                'API',
                'WEBHOOK',
                'SCHEDULED_JOB',
                'ANONYMOUS',
                'OTHER'
            )
        ),

    CONSTRAINT chk_audit_events_environment
        CHECK (
            source_environment IS NULL
            OR source_environment IN (
                'LOCAL',
                'DEVELOPMENT',
                'TEST',
                'STAGING',
                'PRODUCTION',
                'DISASTER_RECOVERY',
                'OTHER'
            )
        ),

    CONSTRAINT chk_audit_events_reason_code
        CHECK (
            reason_code IS NULL
            OR reason_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_audit_events_data_classification
        CHECK (
            data_classification IS NULL
            OR data_classification IN (
                'PUBLIC',
                'INTERNAL',
                'CONFIDENTIAL',
                'RESTRICTED',
                'HIGHLY_RESTRICTED'
            )
        ),

    CONSTRAINT chk_audit_events_before_values
        CHECK (
            before_values IS NULL
            OR jsonb_typeof(before_values) = 'object'
        ),

    CONSTRAINT chk_audit_events_after_values
        CHECK (
            after_values IS NULL
            OR jsonb_typeof(after_values) = 'object'
        ),

    CONSTRAINT chk_audit_events_changed_fields
        CHECK (
            jsonb_typeof(changed_fields) = 'array'
        ),

    CONSTRAINT chk_audit_events_event_details
        CHECK (
            jsonb_typeof(event_details) = 'object'
        ),

    CONSTRAINT chk_audit_events_security_context
        CHECK (
            jsonb_typeof(security_context) = 'object'
        ),

    CONSTRAINT chk_audit_events_compliance_context
        CHECK (
            jsonb_typeof(compliance_context) = 'object'
        ),

    CONSTRAINT chk_audit_events_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        ),

    CONSTRAINT chk_audit_events_exported
        CHECK (
            is_exported = FALSE
            OR exported_at IS NOT NULL
        )
);

CREATE TABLE public.approval_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    approval_reference TEXT NOT NULL,

    approval_type TEXT NOT NULL,

    approval_status TEXT NOT NULL DEFAULT 'DRAFT',

    approval_priority TEXT NOT NULL DEFAULT 'NORMAL',

    entity_type TEXT NOT NULL,

    entity_id UUID,

    entity_reference TEXT,

    requested_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    requested_by_actor_type TEXT NOT NULL DEFAULT 'USER',

    requested_at TIMESTAMPTZ,

    submitted_at TIMESTAMPTZ,

    due_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    cancelled_at TIMESTAMPTZ,

    expired_at TIMESTAMPTZ,

    minimum_approvals_required INTEGER NOT NULL DEFAULT 1,

    approvals_received INTEGER NOT NULL DEFAULT 0,

    rejections_received INTEGER NOT NULL DEFAULT 0,

    allow_self_approval BOOLEAN NOT NULL DEFAULT FALSE,

    require_sequential_approval BOOLEAN NOT NULL DEFAULT FALSE,

    require_unanimous_approval BOOLEAN NOT NULL DEFAULT FALSE,

    escalation_enabled BOOLEAN NOT NULL DEFAULT FALSE,

    escalation_after_minutes INTEGER,

    escalation_level INTEGER NOT NULL DEFAULT 0,

    current_approval_step INTEGER NOT NULL DEFAULT 1,

    total_approval_steps INTEGER NOT NULL DEFAULT 1,

    request_title TEXT NOT NULL,

    request_description TEXT,

    business_justification TEXT,

    risk_summary TEXT,

    requested_changes JSONB NOT NULL DEFAULT '{}'::JSONB,

    approval_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    supporting_evidence JSONB NOT NULL DEFAULT '[]'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_approval_requests_reference
        UNIQUE (
            approval_reference
        ),

    CONSTRAINT chk_approval_requests_reference
        CHECK (
            approval_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_approval_requests_type
        CHECK (
            approval_type IN (
                'DATA_CHANGE',
                'DATA_EXPORT',
                'DATA_DELETION',
                'ACCESS_GRANT',
                'ACCESS_REVOCATION',
                'ROLE_ASSIGNMENT',
                'USER_IMPERSONATION',
                'MANUAL_OVERRIDE',
                'BANK_APPLICATION',
                'BANK_PARTNERSHIP',
                'COMMISSION_RULE',
                'COMMISSION_ADJUSTMENT',
                'SETTLEMENT',
                'REFUND',
                'SECURITY_EXCEPTION',
                'PRIVACY_EXCEPTION',
                'RETENTION_EXCEPTION',
                'MODEL_CHANGE',
                'POLICY_CHANGE',
                'CONTROL_CHANGE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_approval_requests_status
        CHECK (
            approval_status IN (
                'DRAFT',
                'SUBMITTED',
                'PENDING',
                'IN_REVIEW',
                'PARTIALLY_APPROVED',
                'APPROVED',
                'REJECTED',
                'CANCELLED',
                'EXPIRED',
                'WITHDRAWN'
            )
        ),

    CONSTRAINT chk_approval_requests_priority
        CHECK (
            approval_priority IN (
                'LOW',
                'NORMAL',
                'HIGH',
                'URGENT',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_approval_requests_actor_type
        CHECK (
            requested_by_actor_type IN (
                'USER',
                'ADMIN',
                'ADVISOR',
                'BANK_USER',
                'PARTNER_USER',
                'SERVICE_ACCOUNT',
                'SYSTEM',
                'OTHER'
            )
        ),

    CONSTRAINT chk_approval_requests_title
        CHECK (
            length(trim(request_title)) > 0
        ),

    CONSTRAINT chk_approval_requests_counts
        CHECK (
            minimum_approvals_required > 0
            AND approvals_received >= 0
            AND rejections_received >= 0
            AND approvals_received <= total_approval_steps
            AND current_approval_step > 0
            AND total_approval_steps > 0
            AND current_approval_step <= total_approval_steps
        ),

    CONSTRAINT chk_approval_requests_escalation
        CHECK (
            escalation_after_minutes IS NULL
            OR escalation_after_minutes > 0
        ),

    CONSTRAINT chk_approval_requests_escalation_level
        CHECK (
            escalation_level >= 0
        ),

    CONSTRAINT chk_approval_requests_requested
        CHECK (
            requested_at IS NULL
            OR requested_at >= created_at
        ),

    CONSTRAINT chk_approval_requests_submitted
        CHECK (
            submitted_at IS NULL
            OR requested_at IS NULL
            OR submitted_at >= requested_at
        ),

    CONSTRAINT chk_approval_requests_due
        CHECK (
            due_at IS NULL
            OR submitted_at IS NULL
            OR due_at >= submitted_at
        ),

    CONSTRAINT chk_approval_requests_completed
        CHECK (
            completed_at IS NULL
            OR submitted_at IS NULL
            OR completed_at >= submitted_at
        ),

    CONSTRAINT chk_approval_requests_cancelled
        CHECK (
            cancelled_at IS NULL
            OR cancelled_at >= created_at
        ),

    CONSTRAINT chk_approval_requests_expired
        CHECK (
            expired_at IS NULL
            OR expired_at >= created_at
        ),

    CONSTRAINT chk_approval_requests_changes
        CHECK (
            jsonb_typeof(requested_changes) = 'object'
        ),

    CONSTRAINT chk_approval_requests_configuration
        CHECK (
            jsonb_typeof(approval_configuration) = 'object'
        ),

    CONSTRAINT chk_approval_requests_evidence
        CHECK (
            jsonb_typeof(supporting_evidence) = 'array'
        ),

    CONSTRAINT chk_approval_requests_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.approval_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    approval_request_id UUID NOT NULL
        REFERENCES public.approval_requests(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    decision_reference TEXT NOT NULL,

    approval_step INTEGER NOT NULL DEFAULT 1,

    decision_sequence INTEGER NOT NULL DEFAULT 1,

    decision_status TEXT NOT NULL DEFAULT 'PENDING',

    approver_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    approver_role_reference TEXT,

    delegated_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    opened_at TIMESTAMPTZ,

    decided_at TIMESTAMPTZ,

    due_at TIMESTAMPTZ,

    decision_reason_code TEXT,

    decision_reason_text TEXT,

    conditions JSONB NOT NULL DEFAULT '[]'::JSONB,

    decision_context JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_approval_decisions_reference
        UNIQUE (
            decision_reference
        ),

    CONSTRAINT uq_approval_decisions_sequence
        UNIQUE (
            approval_request_id,
            approval_step,
            decision_sequence
        ),

    CONSTRAINT chk_approval_decisions_reference
        CHECK (
            decision_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_approval_decisions_step
        CHECK (
            approval_step > 0
            AND decision_sequence > 0
        ),

    CONSTRAINT chk_approval_decisions_status
        CHECK (
            decision_status IN (
                'PENDING',
                'IN_REVIEW',
                'APPROVED',
                'REJECTED',
                'ABSTAINED',
                'DELEGATED',
                'CANCELLED',
                'EXPIRED'
            )
        ),

    CONSTRAINT chk_approval_decisions_opened
        CHECK (
            opened_at IS NULL
            OR opened_at >= assigned_at
        ),

    CONSTRAINT chk_approval_decisions_decided
        CHECK (
            decided_at IS NULL
            OR decided_at >= assigned_at
        ),

    CONSTRAINT chk_approval_decisions_due
        CHECK (
            due_at IS NULL
            OR due_at >= assigned_at
        ),

    CONSTRAINT chk_approval_decisions_reason_code
        CHECK (
            decision_reason_code IS NULL
            OR decision_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_approval_decisions_conditions
        CHECK (
            jsonb_typeof(conditions) = 'array'
        ),

    CONSTRAINT chk_approval_decisions_context
        CHECK (
            jsonb_typeof(decision_context) = 'object'
        ),

    CONSTRAINT chk_approval_decisions_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.consent_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    consent_reference TEXT NOT NULL,

    consent_type TEXT NOT NULL,

    consent_status TEXT NOT NULL DEFAULT 'PENDING',

    consent_scope TEXT NOT NULL,

    consent_version TEXT NOT NULL,

    policy_version TEXT,

    terms_version TEXT,

    language_code TEXT NOT NULL DEFAULT 'en',

    collection_channel TEXT NOT NULL DEFAULT 'WEB',

    collection_method TEXT NOT NULL DEFAULT 'EXPLICIT',

    purpose_reference TEXT,

    legal_basis TEXT,

    controller_reference TEXT,

    processor_reference TEXT,

    bank_id UUID
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    bank_application_id UUID
        REFERENCES public.bank_applications(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    granted_at TIMESTAMPTZ,

    effective_from TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    withdrawn_at TIMESTAMPTZ,

    revoked_at TIMESTAMPTZ,

    superseded_at TIMESTAMPTZ,

    withdrawal_reason TEXT,

    revocation_reason TEXT,

    source_ip_hash TEXT,

    user_agent_hash TEXT,

    session_reference TEXT,

    evidence_reference TEXT,

    proof_hash TEXT,

    is_mandatory BOOLEAN NOT NULL DEFAULT FALSE,

    allows_data_sharing BOOLEAN NOT NULL DEFAULT FALSE,

    allows_marketing BOOLEAN NOT NULL DEFAULT FALSE,

    allows_profiling BOOLEAN NOT NULL DEFAULT FALSE,

    allows_automated_decisioning BOOLEAN NOT NULL DEFAULT FALSE,

    allows_cross_border_transfer BOOLEAN NOT NULL DEFAULT FALSE,

    consent_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    purpose_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    data_categories JSONB NOT NULL DEFAULT '[]'::JSONB,

    recipient_categories JSONB NOT NULL DEFAULT '[]'::JSONB,

    evidence_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_consent_records_reference
        UNIQUE (
            consent_reference
        ),

    CONSTRAINT chk_consent_records_reference
        CHECK (
            consent_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_consent_records_type
        CHECK (
            consent_type IN (
                'PRIVACY_POLICY',
                'TERMS_OF_SERVICE',
                'DATA_PROCESSING',
                'DATA_SHARING',
                'BANK_APPLICATION',
                'OPEN_BANKING',
                'MARKETING_EMAIL',
                'MARKETING_SMS',
                'MARKETING_PUSH',
                'MARKETING_WHATSAPP',
                'PROFILING',
                'AUTOMATED_DECISIONING',
                'CREDIT_ASSESSMENT',
                'IDENTITY_VERIFICATION',
                'KYC_AML',
                'LOCATION_DATA',
                'COOKIES',
                'ANALYTICS',
                'RESEARCH',
                'CROSS_BORDER_TRANSFER',
                'OTHER'
            )
        ),

    CONSTRAINT chk_consent_records_status
        CHECK (
            consent_status IN (
                'PENDING',
                'GRANTED',
                'DENIED',
                'WITHDRAWN',
                'REVOKED',
                'EXPIRED',
                'SUPERSEDED',
                'NOT_REQUIRED'
            )
        ),

    CONSTRAINT chk_consent_records_scope
        CHECK (
            length(trim(consent_scope)) > 0
        ),

    CONSTRAINT chk_consent_records_version
        CHECK (
            length(trim(consent_version)) > 0
        ),

    CONSTRAINT chk_consent_records_language
        CHECK (
            language_code
                ~ '^[a-z]{2}(?:-[A-Z]{2})?$'
        ),

    CONSTRAINT chk_consent_records_channel
        CHECK (
            collection_channel IN (
                'WEB',
                'MOBILE_APP',
                'BANK_REDIRECT',
                'BANK_API',
                'PARTNER_API',
                'CALL_CENTER',
                'BRANCH',
                'EMAIL',
                'SMS',
                'WHATSAPP',
                'PAPER',
                'ADMIN',
                'OTHER'
            )
        ),

    CONSTRAINT chk_consent_records_method
        CHECK (
            collection_method IN (
                'EXPLICIT',
                'IMPLIED',
                'DIGITAL_SIGNATURE',
                'CHECKBOX',
                'OTP',
                'BIOMETRIC',
                'VOICE',
                'PAPER_SIGNATURE',
                'BANK_CONFIRMED',
                'SYSTEM',
                'OTHER'
            )
        ),

    CONSTRAINT chk_consent_records_legal_basis
        CHECK (
            legal_basis IS NULL
            OR legal_basis IN (
                'CONSENT',
                'CONTRACT',
                'LEGAL_OBLIGATION',
                'VITAL_INTEREST',
                'PUBLIC_INTEREST',
                'LEGITIMATE_INTEREST',
                'REGULATORY_REQUIREMENT',
                'OTHER'
            )
        ),

    CONSTRAINT chk_consent_records_granted
        CHECK (
            granted_at IS NULL
            OR consent_status IN (
                'GRANTED',
                'WITHDRAWN',
                'REVOKED',
                'EXPIRED',
                'SUPERSEDED'
            )
        ),

    CONSTRAINT chk_consent_records_effective
        CHECK (
            effective_from IS NULL
            OR granted_at IS NULL
            OR effective_from >= granted_at
        ),

    CONSTRAINT chk_consent_records_expiry
        CHECK (
            expires_at IS NULL
            OR effective_from IS NULL
            OR expires_at >= effective_from
        ),

    CONSTRAINT chk_consent_records_withdrawal
        CHECK (
            withdrawn_at IS NULL
            OR granted_at IS NULL
            OR withdrawn_at >= granted_at
        ),

    CONSTRAINT chk_consent_records_revocation
        CHECK (
            revoked_at IS NULL
            OR granted_at IS NULL
            OR revoked_at >= granted_at
        ),

    CONSTRAINT chk_consent_records_superseded
        CHECK (
            superseded_at IS NULL
            OR created_at IS NULL
            OR superseded_at >= created_at
        ),

    CONSTRAINT chk_consent_records_details
        CHECK (
            jsonb_typeof(consent_details) = 'object'
        ),

    CONSTRAINT chk_consent_records_purpose_details
        CHECK (
            jsonb_typeof(purpose_details) = 'object'
        ),

    CONSTRAINT chk_consent_records_data_categories
        CHECK (
            jsonb_typeof(data_categories) = 'array'
        ),

    CONSTRAINT chk_consent_records_recipients
        CHECK (
            jsonb_typeof(recipient_categories) = 'array'
        ),

    CONSTRAINT chk_consent_records_evidence
        CHECK (
            jsonb_typeof(evidence_details) = 'object'
        ),

    CONSTRAINT chk_consent_records_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.data_classification_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    classification_reference TEXT NOT NULL,

    schema_name TEXT NOT NULL DEFAULT 'public',

    table_name TEXT NOT NULL,

    column_name TEXT,

    entity_type TEXT,

    classification_level TEXT NOT NULL,

    data_category TEXT NOT NULL,

    sensitivity_type TEXT,

    regulatory_scope TEXT,

    masking_required BOOLEAN NOT NULL DEFAULT FALSE,

    encryption_required BOOLEAN NOT NULL DEFAULT FALSE,

    tokenization_required BOOLEAN NOT NULL DEFAULT FALSE,

    access_logging_required BOOLEAN NOT NULL DEFAULT TRUE,

    export_restricted BOOLEAN NOT NULL DEFAULT FALSE,

    cross_border_transfer_restricted BOOLEAN NOT NULL DEFAULT FALSE,

    customer_consent_required BOOLEAN NOT NULL DEFAULT FALSE,

    privileged_access_required BOOLEAN NOT NULL DEFAULT FALSE,

    minimum_retention_days INTEGER,

    maximum_retention_days INTEGER,

    effective_from TIMESTAMPTZ NOT NULL DEFAULT now(),

    effective_until TIMESTAMPTZ,

    rule_status TEXT NOT NULL DEFAULT 'ACTIVE',

    masking_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    encryption_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    access_conditions JSONB NOT NULL DEFAULT '[]'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_data_classification_rules_reference
        UNIQUE (
            classification_reference
        ),

    CONSTRAINT uq_data_classification_rules_column
        UNIQUE (
            schema_name,
            table_name,
            column_name
        ),

    CONSTRAINT chk_data_classification_rules_reference
        CHECK (
            classification_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_data_classification_rules_schema
        CHECK (
            schema_name
                ~ '^[a-z_][a-z0-9_]*$'
        ),

    CONSTRAINT chk_data_classification_rules_table
        CHECK (
            table_name
                ~ '^[a-z_][a-z0-9_]*$'
        ),

    CONSTRAINT chk_data_classification_rules_column
        CHECK (
            column_name IS NULL
            OR column_name ~ '^[a-z_][a-z0-9_]*$'
        ),

    CONSTRAINT chk_data_classification_rules_level
        CHECK (
            classification_level IN (
                'PUBLIC',
                'INTERNAL',
                'CONFIDENTIAL',
                'RESTRICTED',
                'HIGHLY_RESTRICTED'
            )
        ),

    CONSTRAINT chk_data_classification_rules_category
        CHECK (
            data_category IN (
                'IDENTITY',
                'CONTACT',
                'DEMOGRAPHIC',
                'EMPLOYMENT',
                'FINANCIAL',
                'CREDIT',
                'TRANSACTION',
                'AUTHENTICATION',
                'SECURITY',
                'BIOMETRIC',
                'LOCATION',
                'DEVICE',
                'BEHAVIORAL',
                'PREFERENCE',
                'CONSENT',
                'HEALTH',
                'LEGAL',
                'BUSINESS',
                'TECHNICAL',
                'OPERATIONAL',
                'AUDIT',
                'OTHER'
            )
        ),

    CONSTRAINT chk_data_classification_rules_sensitivity
        CHECK (
            sensitivity_type IS NULL
            OR sensitivity_type IN (
                'PERSONAL_DATA',
                'SENSITIVE_PERSONAL_DATA',
                'FINANCIAL_DATA',
                'PAYMENT_DATA',
                'CREDENTIAL',
                'SECRET',
                'TOKEN',
                'REGULATORY_DATA',
                'BANK_CONFIDENTIAL',
                'COMMERCIAL_CONFIDENTIAL',
                'INTERNAL_ONLY',
                'OTHER'
            )
        ),

    CONSTRAINT chk_data_classification_rules_status
        CHECK (
            rule_status IN (
                'DRAFT',
                'ACTIVE',
                'SUSPENDED',
                'EXPIRED',
                'RETIRED'
            )
        ),

    CONSTRAINT chk_data_classification_rules_retention
        CHECK (
            (
                minimum_retention_days IS NULL
                OR minimum_retention_days >= 0
            )
            AND
            (
                maximum_retention_days IS NULL
                OR maximum_retention_days >= 0
            )
            AND
            (
                minimum_retention_days IS NULL
                OR maximum_retention_days IS NULL
                OR maximum_retention_days >= minimum_retention_days
            )
        ),

    CONSTRAINT chk_data_classification_rules_effective
        CHECK (
            effective_until IS NULL
            OR effective_until >= effective_from
        ),

    CONSTRAINT chk_data_classification_rules_masking
        CHECK (
            jsonb_typeof(masking_configuration) = 'object'
        ),

    CONSTRAINT chk_data_classification_rules_encryption
        CHECK (
            jsonb_typeof(encryption_configuration) = 'object'
        ),

    CONSTRAINT chk_data_classification_rules_access
        CHECK (
            jsonb_typeof(access_conditions) = 'array'
        ),

    CONSTRAINT chk_data_classification_rules_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.data_retention_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    retention_policy_reference TEXT NOT NULL,

    policy_name TEXT NOT NULL,

    policy_status TEXT NOT NULL DEFAULT 'DRAFT',

    entity_type TEXT NOT NULL,

    schema_name TEXT,

    table_name TEXT,

    retention_trigger TEXT NOT NULL,

    retention_period_days INTEGER NOT NULL,

    archive_after_days INTEGER,

    anonymize_after_days INTEGER,

    delete_after_days INTEGER,

    review_interval_days INTEGER,

    legal_basis TEXT,

    regulatory_reference TEXT,

    disposition_method TEXT NOT NULL DEFAULT 'DELETE',

    archive_storage_class TEXT,

    approval_required BOOLEAN NOT NULL DEFAULT TRUE,

    legal_hold_override BOOLEAN NOT NULL DEFAULT TRUE,

    automated_execution BOOLEAN NOT NULL DEFAULT FALSE,

    effective_from TIMESTAMPTZ NOT NULL DEFAULT now(),

    effective_until TIMESTAMPTZ,

    last_reviewed_at TIMESTAMPTZ,

    next_review_due_at TIMESTAMPTZ,

    approved_at TIMESTAMPTZ,

    approved_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    policy_conditions JSONB NOT NULL DEFAULT '[]'::JSONB,

    exclusion_conditions JSONB NOT NULL DEFAULT '[]'::JSONB,

    archive_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    deletion_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_data_retention_policies_reference
        UNIQUE (
            retention_policy_reference
        ),

    CONSTRAINT uq_data_retention_policies_entity
        UNIQUE (
            entity_type,
            schema_name,
            table_name,
            retention_trigger
        ),

    CONSTRAINT chk_data_retention_policies_reference
        CHECK (
            retention_policy_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_data_retention_policies_name
        CHECK (
            length(trim(policy_name)) > 0
        ),

    CONSTRAINT chk_data_retention_policies_status
        CHECK (
            policy_status IN (
                'DRAFT',
                'UNDER_REVIEW',
                'APPROVED',
                'ACTIVE',
                'SUSPENDED',
                'EXPIRED',
                'RETIRED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_data_retention_policies_trigger
        CHECK (
            retention_trigger IN (
                'RECORD_CREATED',
                'RECORD_UPDATED',
                'ACCOUNT_CLOSED',
                'APPLICATION_COMPLETED',
                'APPLICATION_REJECTED',
                'CONTRACT_TERMINATED',
                'CONSENT_WITHDRAWN',
                'LAST_ACTIVITY',
                'LEGAL_OBLIGATION_END',
                'MANUAL',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_data_retention_policies_period
        CHECK (
            retention_period_days >= 0
        ),

    CONSTRAINT chk_data_retention_policies_archive
        CHECK (
            archive_after_days IS NULL
            OR archive_after_days >= 0
        ),

    CONSTRAINT chk_data_retention_policies_anonymize
        CHECK (
            anonymize_after_days IS NULL
            OR anonymize_after_days >= 0
        ),

    CONSTRAINT chk_data_retention_policies_delete
        CHECK (
            delete_after_days IS NULL
            OR delete_after_days >= retention_period_days
        ),

    CONSTRAINT chk_data_retention_policies_review
        CHECK (
            review_interval_days IS NULL
            OR review_interval_days > 0
        ),

    CONSTRAINT chk_data_retention_policies_disposition
        CHECK (
            disposition_method IN (
                'DELETE',
                'SOFT_DELETE',
                'ANONYMIZE',
                'PSEUDONYMIZE',
                'ARCHIVE',
                'ARCHIVE_THEN_DELETE',
                'MANUAL_REVIEW',
                'RETAIN_INDEFINITELY',
                'OTHER'
            )
        ),

    CONSTRAINT chk_data_retention_policies_effective
        CHECK (
            effective_until IS NULL
            OR effective_until >= effective_from
        ),

    CONSTRAINT chk_data_retention_policies_review_dates
        CHECK (
            next_review_due_at IS NULL
            OR last_reviewed_at IS NULL
            OR next_review_due_at >= last_reviewed_at
        ),

    CONSTRAINT chk_data_retention_policies_approval
        CHECK (
            approved_by IS NULL
            OR approved_at IS NOT NULL
        ),

    CONSTRAINT chk_data_retention_policies_conditions
        CHECK (
            jsonb_typeof(policy_conditions) = 'array'
        ),

    CONSTRAINT chk_data_retention_policies_exclusions
        CHECK (
            jsonb_typeof(exclusion_conditions) = 'array'
        ),

    CONSTRAINT chk_data_retention_policies_archive_configuration
        CHECK (
            jsonb_typeof(archive_configuration) = 'object'
        ),

    CONSTRAINT chk_data_retention_policies_deletion_configuration
        CHECK (
            jsonb_typeof(deletion_configuration) = 'object'
        ),

    CONSTRAINT chk_data_retention_policies_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.data_retention_executions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    retention_policy_id UUID NOT NULL
        REFERENCES public.data_retention_policies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    execution_reference TEXT NOT NULL,

    execution_status TEXT NOT NULL DEFAULT 'PENDING',

    execution_type TEXT NOT NULL DEFAULT 'SCHEDULED',

    entity_type TEXT NOT NULL,

    entity_id UUID,

    entity_reference TEXT,

    scheduled_at TIMESTAMPTZ,

    started_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    failed_at TIMESTAMPTZ,

    executed_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    records_evaluated INTEGER NOT NULL DEFAULT 0,

    records_archived INTEGER NOT NULL DEFAULT 0,

    records_anonymized INTEGER NOT NULL DEFAULT 0,

    records_deleted INTEGER NOT NULL DEFAULT 0,

    records_skipped INTEGER NOT NULL DEFAULT 0,

    records_failed INTEGER NOT NULL DEFAULT 0,

    legal_hold_records INTEGER NOT NULL DEFAULT 0,

    approval_request_id UUID
        REFERENCES public.approval_requests(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    error_code TEXT,

    error_message TEXT,

    execution_summary JSONB NOT NULL DEFAULT '{}'::JSONB,

    affected_records JSONB NOT NULL DEFAULT '[]'::JSONB,

    errors JSONB NOT NULL DEFAULT '[]'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_data_retention_executions_reference
        UNIQUE (
            execution_reference
        ),

    CONSTRAINT chk_data_retention_executions_reference
        CHECK (
            execution_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_data_retention_executions_status
        CHECK (
            execution_status IN (
                'PENDING',
                'AWAITING_APPROVAL',
                'APPROVED',
                'RUNNING',
                'PARTIALLY_COMPLETED',
                'COMPLETED',
                'FAILED',
                'CANCELLED',
                'SKIPPED'
            )
        ),

    CONSTRAINT chk_data_retention_executions_type
        CHECK (
            execution_type IN (
                'SCHEDULED',
                'MANUAL',
                'EVENT_DRIVEN',
                'CUSTOMER_REQUEST',
                'REGULATORY_REQUEST',
                'LEGAL_REQUEST',
                'CORRECTIVE_ACTION',
                'TEST'
            )
        ),

    CONSTRAINT chk_data_retention_executions_started
        CHECK (
            started_at IS NULL
            OR scheduled_at IS NULL
            OR started_at >= scheduled_at
        ),

    CONSTRAINT chk_data_retention_executions_completed
        CHECK (
            completed_at IS NULL
            OR started_at IS NULL
            OR completed_at >= started_at
        ),

    CONSTRAINT chk_data_retention_executions_failed
        CHECK (
            failed_at IS NULL
            OR started_at IS NULL
            OR failed_at >= started_at
        ),

    CONSTRAINT chk_data_retention_executions_counts
        CHECK (
            records_evaluated >= 0
            AND records_archived >= 0
            AND records_anonymized >= 0
            AND records_deleted >= 0
            AND records_skipped >= 0
            AND records_failed >= 0
            AND legal_hold_records >= 0
            AND records_archived <= records_evaluated
            AND records_anonymized <= records_evaluated
            AND records_deleted <= records_evaluated
            AND records_skipped <= records_evaluated
            AND records_failed <= records_evaluated
            AND legal_hold_records <= records_evaluated
        ),

    CONSTRAINT chk_data_retention_executions_error_code
        CHECK (
            error_code IS NULL
            OR error_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_data_retention_executions_summary
        CHECK (
            jsonb_typeof(execution_summary) = 'object'
        ),

    CONSTRAINT chk_data_retention_executions_records
        CHECK (
            jsonb_typeof(affected_records) = 'array'
        ),

    CONSTRAINT chk_data_retention_executions_errors
        CHECK (
            jsonb_typeof(errors) = 'array'
        ),

    CONSTRAINT chk_data_retention_executions_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.legal_holds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    legal_hold_reference TEXT NOT NULL,

    hold_name TEXT NOT NULL,

    hold_status TEXT NOT NULL DEFAULT 'DRAFT',

    hold_type TEXT NOT NULL,

    legal_authority TEXT,

    case_reference TEXT,

    matter_reference TEXT,

    issuing_entity TEXT,

    reason TEXT NOT NULL,

    scope_description TEXT NOT NULL,

    effective_from TIMESTAMPTZ NOT NULL DEFAULT now(),

    effective_until TIMESTAMPTZ,

    released_at TIMESTAMPTZ,

    release_reason TEXT,

    custodian_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    requested_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    approved_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    approved_at TIMESTAMPTZ,

    released_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    entity_types JSONB NOT NULL DEFAULT '[]'::JSONB,

    entity_references JSONB NOT NULL DEFAULT '[]'::JSONB,

    user_references JSONB NOT NULL DEFAULT '[]'::JSONB,

    data_scope JSONB NOT NULL DEFAULT '{}'::JSONB,

    collection_instructions JSONB NOT NULL DEFAULT '{}'::JSONB,

    notification_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_legal_holds_reference
        UNIQUE (
            legal_hold_reference
        ),

    CONSTRAINT chk_legal_holds_reference
        CHECK (
            legal_hold_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_legal_holds_name
        CHECK (
            length(trim(hold_name)) > 0
        ),

    CONSTRAINT chk_legal_holds_status
        CHECK (
            hold_status IN (
                'DRAFT',
                'PENDING_APPROVAL',
                'ACTIVE',
                'SUSPENDED',
                'RELEASED',
                'EXPIRED',
                'CANCELLED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_legal_holds_type
        CHECK (
            hold_type IN (
                'LITIGATION',
                'REGULATORY',
                'INVESTIGATION',
                'LAW_ENFORCEMENT',
                'AUDIT',
                'INTERNAL_INVESTIGATION',
                'CUSTOMER_DISPUTE',
                'FRAUD_INVESTIGATION',
                'SECURITY_INCIDENT',
                'OTHER'
            )
        ),

    CONSTRAINT chk_legal_holds_reason
        CHECK (
            length(trim(reason)) > 0
        ),

    CONSTRAINT chk_legal_holds_scope
        CHECK (
            length(trim(scope_description)) > 0
        ),

    CONSTRAINT chk_legal_holds_effective
        CHECK (
            effective_until IS NULL
            OR effective_until >= effective_from
        ),

    CONSTRAINT chk_legal_holds_release
        CHECK (
            released_at IS NULL
            OR released_at >= effective_from
        ),

    CONSTRAINT chk_legal_holds_approval
        CHECK (
            approved_by_user_id IS NULL
            OR approved_at IS NOT NULL
        ),

    CONSTRAINT chk_legal_holds_entity_types
        CHECK (
            jsonb_typeof(entity_types) = 'array'
        ),

    CONSTRAINT chk_legal_holds_entity_references
        CHECK (
            jsonb_typeof(entity_references) = 'array'
        ),

    CONSTRAINT chk_legal_holds_user_references
        CHECK (
            jsonb_typeof(user_references) = 'array'
        ),

    CONSTRAINT chk_legal_holds_data_scope
        CHECK (
            jsonb_typeof(data_scope) = 'object'
        ),

    CONSTRAINT chk_legal_holds_collection
        CHECK (
            jsonb_typeof(collection_instructions) = 'object'
        ),

    CONSTRAINT chk_legal_holds_notifications
        CHECK (
            jsonb_typeof(notification_details) = 'object'
        ),

    CONSTRAINT chk_legal_holds_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.legal_hold_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    legal_hold_id UUID NOT NULL
        REFERENCES public.legal_holds(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    hold_item_reference TEXT NOT NULL,

    entity_type TEXT NOT NULL,

    entity_id UUID,

    entity_reference TEXT,

    user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    item_status TEXT NOT NULL DEFAULT 'ACTIVE',

    preserved_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    released_at TIMESTAMPTZ,

    preservation_method TEXT NOT NULL DEFAULT 'LOGICAL_HOLD',

    storage_reference TEXT,

    integrity_hash TEXT,

    source_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    preservation_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_legal_hold_items_reference
        UNIQUE (
            hold_item_reference
        ),

    CONSTRAINT uq_legal_hold_items_entity
        UNIQUE (
            legal_hold_id,
            entity_type,
            entity_id,
            entity_reference
        ),

    CONSTRAINT chk_legal_hold_items_reference
        CHECK (
            hold_item_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_legal_hold_items_entity
        CHECK (
            entity_id IS NOT NULL
            OR entity_reference IS NOT NULL
            OR user_id IS NOT NULL
        ),

    CONSTRAINT chk_legal_hold_items_status
        CHECK (
            item_status IN (
                'ACTIVE',
                'PRESERVED',
                'VERIFIED',
                'RELEASED',
                'FAILED',
                'EXCLUDED'
            )
        ),

    CONSTRAINT chk_legal_hold_items_release
        CHECK (
            released_at IS NULL
            OR released_at >= preserved_at
        ),

    CONSTRAINT chk_legal_hold_items_method
        CHECK (
            preservation_method IN (
                'LOGICAL_HOLD',
                'DATABASE_SNAPSHOT',
                'OBJECT_STORAGE_COPY',
                'EXPORT',
                'BACKUP',
                'IMMUTABLE_ARCHIVE',
                'MANUAL',
                'OTHER'
            )
        ),

    CONSTRAINT chk_legal_hold_items_snapshot
        CHECK (
            jsonb_typeof(source_snapshot) = 'object'
        ),

    CONSTRAINT chk_legal_hold_items_details
        CHECK (
            jsonb_typeof(preservation_details) = 'object'
        ),

    CONSTRAINT chk_legal_hold_items_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.data_access_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    access_reference TEXT NOT NULL,

    user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    actor_type TEXT NOT NULL DEFAULT 'USER',

    actor_reference TEXT,

    impersonated_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    access_type TEXT NOT NULL,

    access_outcome TEXT NOT NULL DEFAULT 'ALLOWED',

    access_purpose TEXT NOT NULL,

    legal_basis TEXT,

    entity_type TEXT NOT NULL,

    entity_id UUID,

    entity_reference TEXT,

    data_classification TEXT NOT NULL DEFAULT 'INTERNAL',

    data_categories JSONB NOT NULL DEFAULT '[]'::JSONB,

    fields_accessed JSONB NOT NULL DEFAULT '[]'::JSONB,

    record_count INTEGER NOT NULL DEFAULT 1,

    source_service TEXT,

    source_component TEXT,

    session_reference TEXT,

    request_reference TEXT,

    correlation_id TEXT,

    source_ip_hash TEXT,

    user_agent_hash TEXT,

    device_reference TEXT,

    accessed_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    access_duration_milliseconds BIGINT,

    approval_reference TEXT,

    consent_reference TEXT,

    denial_reason_code TEXT,

    denial_reason_text TEXT,

    query_fingerprint TEXT,

    access_context JSONB NOT NULL DEFAULT '{}'::JSONB,

    security_context JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_data_access_logs_reference
        UNIQUE (
            access_reference
        ),

    CONSTRAINT chk_data_access_logs_reference
        CHECK (
            access_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_data_access_logs_actor
        CHECK (
            actor_type IN (
                'CUSTOMER',
                'USER',
                'ADMIN',
                'ADVISOR',
                'BANK_USER',
                'PARTNER_USER',
                'SERVICE_ACCOUNT',
                'SYSTEM',
                'API',
                'WEBHOOK',
                'SCHEDULED_JOB',
                'ANONYMOUS',
                'OTHER'
            )
        ),

    CONSTRAINT chk_data_access_logs_type
        CHECK (
            access_type IN (
                'VIEW',
                'SEARCH',
                'QUERY',
                'DOWNLOAD',
                'EXPORT',
                'PRINT',
                'COPY',
                'API_READ',
                'REPORT',
                'ANALYTICS',
                'MODEL_INFERENCE',
                'ADMIN_ACCESS',
                'SUPPORT_ACCESS',
                'OTHER'
            )
        ),

    CONSTRAINT chk_data_access_logs_outcome
        CHECK (
            access_outcome IN (
                'ALLOWED',
                'PARTIALLY_ALLOWED',
                'DENIED',
                'BLOCKED',
                'FAILED',
                'CANCELLED'
            )
        ),

    CONSTRAINT chk_data_access_logs_purpose
        CHECK (
            access_purpose IN (
                'CUSTOMER_SERVICE',
                'APPLICATION_PROCESSING',
                'ELIGIBILITY_ASSESSMENT',
                'RECOMMENDATION',
                'FRAUD_PREVENTION',
                'KYC_AML',
                'BANK_INTEGRATION',
                'COMMISSION_PROCESSING',
                'SETTLEMENT',
                'AUDIT',
                'COMPLIANCE',
                'SECURITY',
                'ANALYTICS',
                'REPORTING',
                'LEGAL',
                'REGULATORY',
                'SUPPORT',
                'SYSTEM_OPERATION',
                'OTHER'
            )
        ),

    CONSTRAINT chk_data_access_logs_legal_basis
        CHECK (
            legal_basis IS NULL
            OR legal_basis IN (
                'CONSENT',
                'CONTRACT',
                'LEGAL_OBLIGATION',
                'LEGITIMATE_INTEREST',
                'REGULATORY_REQUIREMENT',
                'CUSTOMER_REQUEST',
                'SECURITY_REQUIREMENT',
                'OTHER'
            )
        ),

    CONSTRAINT chk_data_access_logs_classification
        CHECK (
            data_classification IN (
                'PUBLIC',
                'INTERNAL',
                'CONFIDENTIAL',
                'RESTRICTED',
                'HIGHLY_RESTRICTED'
            )
        ),

    CONSTRAINT chk_data_access_logs_record_count
        CHECK (
            record_count >= 0
        ),

    CONSTRAINT chk_data_access_logs_duration
        CHECK (
            access_duration_milliseconds IS NULL
            OR access_duration_milliseconds >= 0
        ),

    CONSTRAINT chk_data_access_logs_denial_code
        CHECK (
            denial_reason_code IS NULL
            OR denial_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_data_access_logs_categories
        CHECK (
            jsonb_typeof(data_categories) = 'array'
        ),

    CONSTRAINT chk_data_access_logs_fields
        CHECK (
            jsonb_typeof(fields_accessed) = 'array'
        ),

    CONSTRAINT chk_data_access_logs_context
        CHECK (
            jsonb_typeof(access_context) = 'object'
        ),

    CONSTRAINT chk_data_access_logs_security_context
        CHECK (
            jsonb_typeof(security_context) = 'object'
        ),

    CONSTRAINT chk_data_access_logs_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.data_export_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    export_reference TEXT NOT NULL,

    requested_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    subject_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    export_type TEXT NOT NULL,

    export_status TEXT NOT NULL DEFAULT 'DRAFT',

    export_purpose TEXT NOT NULL,

    export_format TEXT NOT NULL DEFAULT 'JSON',

    data_scope TEXT NOT NULL,

    entity_types JSONB NOT NULL DEFAULT '[]'::JSONB,

    requested_fields JSONB NOT NULL DEFAULT '[]'::JSONB,

    filters JSONB NOT NULL DEFAULT '{}'::JSONB,

    requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    submitted_at TIMESTAMPTZ,

    approved_at TIMESTAMPTZ,

    processing_started_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    downloaded_at TIMESTAMPTZ,

    cancelled_at TIMESTAMPTZ,

    failed_at TIMESTAMPTZ,

    approval_request_id UUID
        REFERENCES public.approval_requests(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    consent_reference TEXT,

    legal_basis TEXT,

    data_classification TEXT NOT NULL DEFAULT 'CONFIDENTIAL',

    encryption_required BOOLEAN NOT NULL DEFAULT TRUE,

    password_protected BOOLEAN NOT NULL DEFAULT FALSE,

    watermark_required BOOLEAN NOT NULL DEFAULT FALSE,

    redaction_required BOOLEAN NOT NULL DEFAULT TRUE,

    storage_provider TEXT,

    storage_bucket TEXT,

    storage_path TEXT,

    file_name TEXT,

    file_size_bytes BIGINT,

    file_hash TEXT,

    encryption_key_reference TEXT,

    download_count INTEGER NOT NULL DEFAULT 0,

    maximum_download_count INTEGER NOT NULL DEFAULT 1,

    record_count INTEGER,

    failure_code TEXT,

    failure_message TEXT,

    export_summary JSONB NOT NULL DEFAULT '{}'::JSONB,

    redaction_summary JSONB NOT NULL DEFAULT '{}'::JSONB,

    delivery_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_data_export_requests_reference
        UNIQUE (
            export_reference
        ),

    CONSTRAINT chk_data_export_requests_reference
        CHECK (
            export_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_data_export_requests_type
        CHECK (
            export_type IN (
                'CUSTOMER_DATA_REQUEST',
                'REGULATORY_EXPORT',
                'LEGAL_EXPORT',
                'AUDIT_EXPORT',
                'BANK_EXPORT',
                'PARTNER_EXPORT',
                'REPORT_EXPORT',
                'ANALYTICS_EXPORT',
                'BACKUP_EXPORT',
                'ADMIN_EXPORT',
                'OTHER'
            )
        ),

    CONSTRAINT chk_data_export_requests_status
        CHECK (
            export_status IN (
                'DRAFT',
                'SUBMITTED',
                'PENDING_APPROVAL',
                'APPROVED',
                'PROCESSING',
                'READY',
                'DELIVERED',
                'DOWNLOADED',
                'EXPIRED',
                'REJECTED',
                'CANCELLED',
                'FAILED',
                'DELETED'
            )
        ),

    CONSTRAINT chk_data_export_requests_purpose
        CHECK (
            export_purpose IN (
                'CUSTOMER_REQUEST',
                'DATA_PORTABILITY',
                'REGULATORY_REPORTING',
                'LEGAL_DISCOVERY',
                'AUDIT',
                'BANK_RECONCILIATION',
                'PARTNER_REPORTING',
                'ANALYTICS',
                'BUSINESS_REPORTING',
                'INCIDENT_INVESTIGATION',
                'BACKUP',
                'OTHER'
            )
        ),

    CONSTRAINT chk_data_export_requests_format
        CHECK (
            export_format IN (
                'JSON',
                'CSV',
                'XLSX',
                'PDF',
                'XML',
                'PARQUET',
                'ZIP',
                'SQL',
                'OTHER'
            )
        ),

    CONSTRAINT chk_data_export_requests_scope
        CHECK (
            length(trim(data_scope)) > 0
        ),

    CONSTRAINT chk_data_export_requests_legal_basis
        CHECK (
            legal_basis IS NULL
            OR legal_basis IN (
                'CONSENT',
                'CONTRACT',
                'LEGAL_OBLIGATION',
                'CUSTOMER_REQUEST',
                'REGULATORY_REQUIREMENT',
                'LEGITIMATE_INTEREST',
                'OTHER'
            )
        ),

    CONSTRAINT chk_data_export_requests_classification
        CHECK (
            data_classification IN (
                'PUBLIC',
                'INTERNAL',
                'CONFIDENTIAL',
                'RESTRICTED',
                'HIGHLY_RESTRICTED'
            )
        ),

    CONSTRAINT chk_data_export_requests_submitted
        CHECK (
            submitted_at IS NULL
            OR submitted_at >= requested_at
        ),

    CONSTRAINT chk_data_export_requests_approved
        CHECK (
            approved_at IS NULL
            OR submitted_at IS NULL
            OR approved_at >= submitted_at
        ),

    CONSTRAINT chk_data_export_requests_processing
        CHECK (
            processing_started_at IS NULL
            OR approved_at IS NULL
            OR processing_started_at >= approved_at
        ),

    CONSTRAINT chk_data_export_requests_completed
        CHECK (
            completed_at IS NULL
            OR processing_started_at IS NULL
            OR completed_at >= processing_started_at
        ),

    CONSTRAINT chk_data_export_requests_expiry
        CHECK (
            expires_at IS NULL
            OR completed_at IS NULL
            OR expires_at >= completed_at
        ),

    CONSTRAINT chk_data_export_requests_downloaded
        CHECK (
            downloaded_at IS NULL
            OR completed_at IS NULL
            OR downloaded_at >= completed_at
        ),

    CONSTRAINT chk_data_export_requests_cancelled
        CHECK (
            cancelled_at IS NULL
            OR cancelled_at >= requested_at
        ),

    CONSTRAINT chk_data_export_requests_failed
        CHECK (
            failed_at IS NULL
            OR failed_at >= requested_at
        ),

    CONSTRAINT chk_data_export_requests_file_size
        CHECK (
            file_size_bytes IS NULL
            OR file_size_bytes >= 0
        ),

    CONSTRAINT chk_data_export_requests_download_count
        CHECK (
            download_count >= 0
            AND maximum_download_count >= 0
            AND download_count <= maximum_download_count
        ),

    CONSTRAINT chk_data_export_requests_record_count
        CHECK (
            record_count IS NULL
            OR record_count >= 0
        ),

    CONSTRAINT chk_data_export_requests_failure_code
        CHECK (
            failure_code IS NULL
            OR failure_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_data_export_requests_entity_types
        CHECK (
            jsonb_typeof(entity_types) = 'array'
        ),

    CONSTRAINT chk_data_export_requests_fields
        CHECK (
            jsonb_typeof(requested_fields) = 'array'
        ),

    CONSTRAINT chk_data_export_requests_filters
        CHECK (
            jsonb_typeof(filters) = 'object'
        ),

    CONSTRAINT chk_data_export_requests_summary
        CHECK (
            jsonb_typeof(export_summary) = 'object'
        ),

    CONSTRAINT chk_data_export_requests_redaction
        CHECK (
            jsonb_typeof(redaction_summary) = 'object'
        ),

    CONSTRAINT chk_data_export_requests_delivery
        CHECK (
            jsonb_typeof(delivery_details) = 'object'
        ),

    CONSTRAINT chk_data_export_requests_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.compliance_cases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    case_reference TEXT NOT NULL,

    case_type TEXT NOT NULL,

    case_status TEXT NOT NULL DEFAULT 'OPEN',

    case_priority TEXT NOT NULL DEFAULT 'NORMAL',

    case_severity TEXT NOT NULL DEFAULT 'MEDIUM',

    case_title TEXT NOT NULL,

    case_description TEXT,

    source_type TEXT NOT NULL,

    source_reference TEXT,

    subject_type TEXT,

    subject_id UUID,

    subject_reference TEXT,

    subject_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    bank_id UUID
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    bank_application_id UUID
        REFERENCES public.bank_applications(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    assigned_to_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    assigned_team_reference TEXT,

    opened_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    acknowledged_at TIMESTAMPTZ,

    investigation_started_at TIMESTAMPTZ,

    due_at TIMESTAMPTZ,

    escalated_at TIMESTAMPTZ,

    resolved_at TIMESTAMPTZ,

    closed_at TIMESTAMPTZ,

    regulatory_report_required BOOLEAN NOT NULL DEFAULT FALSE,

    regulatory_report_due_at TIMESTAMPTZ,

    regulatory_reported_at TIMESTAMPTZ,

    customer_notification_required BOOLEAN NOT NULL DEFAULT FALSE,

    customer_notified_at TIMESTAMPTZ,

    root_cause_category TEXT,

    resolution_code TEXT,

    resolution_summary TEXT,

    financial_impact_amount NUMERIC(18, 6),

    financial_impact_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    affected_customer_count INTEGER NOT NULL DEFAULT 0,

    related_controls JSONB NOT NULL DEFAULT '[]'::JSONB,

    allegations JSONB NOT NULL DEFAULT '[]'::JSONB,

    investigation_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    findings JSONB NOT NULL DEFAULT '[]'::JSONB,

    remediation_actions JSONB NOT NULL DEFAULT '[]'::JSONB,

    regulatory_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_compliance_cases_reference
        UNIQUE (
            case_reference
        ),

    CONSTRAINT chk_compliance_cases_reference
        CHECK (
            case_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_compliance_cases_type
        CHECK (
            case_type IN (
                'REGULATORY_BREACH',
                'PRIVACY_INCIDENT',
                'DATA_QUALITY',
                'CUSTOMER_COMPLAINT',
                'CONDUCT_RISK',
                'CONFLICT_OF_INTEREST',
                'FRAUD',
                'AML',
                'SANCTIONS',
                'KYC',
                'SECURITY_INCIDENT',
                'ACCESS_VIOLATION',
                'POLICY_VIOLATION',
                'CONTROL_FAILURE',
                'AUDIT_FINDING',
                'THIRD_PARTY_ISSUE',
                'MODEL_RISK',
                'RECORDS_MANAGEMENT',
                'OTHER'
            )
        ),

    CONSTRAINT chk_compliance_cases_status
        CHECK (
            case_status IN (
                'OPEN',
                'ACKNOWLEDGED',
                'TRIAGE',
                'INVESTIGATING',
                'PENDING_INFORMATION',
                'PENDING_REVIEW',
                'REMEDIATION',
                'RESOLVED',
                'CLOSED',
                'REOPENED',
                'CANCELLED'
            )
        ),

    CONSTRAINT chk_compliance_cases_priority
        CHECK (
            case_priority IN (
                'LOW',
                'NORMAL',
                'HIGH',
                'URGENT',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_compliance_cases_severity
        CHECK (
            case_severity IN (
                'INFORMATIONAL',
                'LOW',
                'MEDIUM',
                'HIGH',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_compliance_cases_title
        CHECK (
            length(trim(case_title)) > 0
        ),

    CONSTRAINT chk_compliance_cases_source
        CHECK (
            source_type IN (
                'AUTOMATED_MONITORING',
                'CUSTOMER',
                'EMPLOYEE',
                'BANK',
                'PARTNER',
                'REGULATOR',
                'INTERNAL_AUDIT',
                'EXTERNAL_AUDIT',
                'SECURITY_MONITORING',
                'WHISTLEBLOWING',
                'MANAGEMENT',
                'OTHER'
            )
        ),

    CONSTRAINT chk_compliance_cases_acknowledged
        CHECK (
            acknowledged_at IS NULL
            OR acknowledged_at >= opened_at
        ),

    CONSTRAINT chk_compliance_cases_investigation
        CHECK (
            investigation_started_at IS NULL
            OR investigation_started_at >= opened_at
        ),

    CONSTRAINT chk_compliance_cases_due
        CHECK (
            due_at IS NULL
            OR due_at >= opened_at
        ),

    CONSTRAINT chk_compliance_cases_escalated
        CHECK (
            escalated_at IS NULL
            OR escalated_at >= opened_at
        ),

    CONSTRAINT chk_compliance_cases_resolved
        CHECK (
            resolved_at IS NULL
            OR resolved_at >= opened_at
        ),

    CONSTRAINT chk_compliance_cases_closed
        CHECK (
            closed_at IS NULL
            OR resolved_at IS NULL
            OR closed_at >= resolved_at
        ),

    CONSTRAINT chk_compliance_cases_regulatory_report
        CHECK (
            regulatory_reported_at IS NULL
            OR regulatory_report_required = TRUE
        ),

    CONSTRAINT chk_compliance_cases_customer_notification
        CHECK (
            customer_notified_at IS NULL
            OR customer_notification_required = TRUE
        ),

    CONSTRAINT chk_compliance_cases_root_cause
        CHECK (
            root_cause_category IS NULL
            OR root_cause_category IN (
                'PEOPLE',
                'PROCESS',
                'TECHNOLOGY',
                'DATA',
                'GOVERNANCE',
                'THIRD_PARTY',
                'POLICY',
                'TRAINING',
                'CONTROL_DESIGN',
                'CONTROL_OPERATION',
                'EXTERNAL_EVENT',
                'UNKNOWN',
                'OTHER'
            )
        ),

    CONSTRAINT chk_compliance_cases_resolution_code
        CHECK (
            resolution_code IS NULL
            OR resolution_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_compliance_cases_financial_impact
        CHECK (
            financial_impact_amount IS NULL
            OR financial_impact_amount >= 0
        ),

    CONSTRAINT chk_compliance_cases_financial_currency
        CHECK (
            (
                financial_impact_amount IS NULL
                AND financial_impact_currency_id IS NULL
            )
            OR
            (
                financial_impact_amount IS NOT NULL
                AND financial_impact_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_compliance_cases_customers
        CHECK (
            affected_customer_count >= 0
        ),

    CONSTRAINT chk_compliance_cases_controls
        CHECK (
            jsonb_typeof(related_controls) = 'array'
        ),

    CONSTRAINT chk_compliance_cases_allegations
        CHECK (
            jsonb_typeof(allegations) = 'array'
        ),

    CONSTRAINT chk_compliance_cases_investigation_details
        CHECK (
            jsonb_typeof(investigation_details) = 'object'
        ),

    CONSTRAINT chk_compliance_cases_findings
        CHECK (
            jsonb_typeof(findings) = 'array'
        ),

    CONSTRAINT chk_compliance_cases_remediation
        CHECK (
            jsonb_typeof(remediation_actions) = 'array'
        ),

    CONSTRAINT chk_compliance_cases_regulatory_details
        CHECK (
            jsonb_typeof(regulatory_details) = 'object'
        ),

    CONSTRAINT chk_compliance_cases_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.compliance_case_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    compliance_case_id UUID NOT NULL
        REFERENCES public.compliance_cases(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    event_reference TEXT NOT NULL,

    event_type TEXT NOT NULL,

    event_status TEXT NOT NULL DEFAULT 'COMPLETED',

    actor_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    actor_type TEXT NOT NULL DEFAULT 'SYSTEM',

    previous_case_status TEXT,

    new_case_status TEXT,

    title TEXT,

    description TEXT,

    reason_code TEXT,

    occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    event_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    attachments JSONB NOT NULL DEFAULT '[]'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_compliance_case_events_reference
        UNIQUE (
            event_reference
        ),

    CONSTRAINT chk_compliance_case_events_reference
        CHECK (
            event_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_compliance_case_events_type
        CHECK (
            event_type IN (
                'CASE_CREATED',
                'CASE_UPDATED',
                'STATUS_CHANGED',
                'ASSIGNED',
                'REASSIGNED',
                'ACKNOWLEDGED',
                'INVESTIGATION_STARTED',
                'EVIDENCE_ADDED',
                'FINDING_ADDED',
                'REMEDIATION_ADDED',
                'ESCALATED',
                'REGULATOR_NOTIFIED',
                'CUSTOMER_NOTIFIED',
                'RESOLVED',
                'CLOSED',
                'REOPENED',
                'NOTE_ADDED',
                'OTHER'
            )
        ),

    CONSTRAINT chk_compliance_case_events_status
        CHECK (
            event_status IN (
                'PENDING',
                'PROCESSING',
                'COMPLETED',
                'FAILED',
                'CANCELLED'
            )
        ),

    CONSTRAINT chk_compliance_case_events_actor
        CHECK (
            actor_type IN (
                'CUSTOMER',
                'USER',
                'ADMIN',
                'COMPLIANCE',
                'AUDITOR',
                'BANK_USER',
                'PARTNER_USER',
                'SYSTEM',
                'API',
                'WEBHOOK',
                'OTHER'
            )
        ),

    CONSTRAINT chk_compliance_case_events_reason_code
        CHECK (
            reason_code IS NULL
            OR reason_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_compliance_case_events_details
        CHECK (
            jsonb_typeof(event_details) = 'object'
        ),

    CONSTRAINT chk_compliance_case_events_attachments
        CHECK (
            jsonb_typeof(attachments) = 'array'
        ),

    CONSTRAINT chk_compliance_case_events_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE INDEX idx_governance_controls_domain
ON public.governance_controls(
    control_domain,
    control_status,
    risk_level
);

CREATE INDEX idx_governance_controls_owner
ON public.governance_controls(
    control_owner_user_id,
    control_status
)
WHERE control_owner_user_id IS NOT NULL;

CREATE INDEX idx_governance_controls_review_due
ON public.governance_controls(next_review_due_at)
WHERE next_review_due_at IS NOT NULL
  AND control_status IN (
      'APPROVED',
      'ACTIVE',
      'PARTIALLY_IMPLEMENTED',
      'INEFFECTIVE'
  );

CREATE INDEX idx_governance_controls_effective
ON public.governance_controls(
    effective_from,
    effective_until
)
WHERE control_status IN (
    'APPROVED',
    'ACTIVE'
);

CREATE INDEX idx_governance_controls_regulatory
ON public.governance_controls
USING GIN (regulatory_references);

CREATE INDEX idx_governance_controls_metadata
ON public.governance_controls
USING GIN (metadata);

CREATE INDEX idx_governance_control_assessments_control
ON public.governance_control_assessments(
    control_id,
    created_at DESC
);

CREATE INDEX idx_governance_control_assessments_status
ON public.governance_control_assessments(
    assessment_status,
    scheduled_at
);

CREATE INDEX idx_governance_control_assessments_result
ON public.governance_control_assessments(
    assessment_result,
    severity,
    completed_at DESC
)
WHERE assessment_result IS NOT NULL;

CREATE INDEX idx_governance_control_assessments_remediation
ON public.governance_control_assessments(remediation_due_at)
WHERE remediation_required = TRUE
  AND remediation_completed_at IS NULL;

CREATE INDEX idx_governance_control_assessments_exceptions
ON public.governance_control_assessments
USING GIN (exceptions);

CREATE INDEX idx_governance_control_assessments_metadata
ON public.governance_control_assessments
USING GIN (metadata);

CREATE INDEX idx_audit_events_occurred
ON public.audit_events(occurred_at DESC);

CREATE INDEX idx_audit_events_actor
ON public.audit_events(
    actor_user_id,
    occurred_at DESC
)
WHERE actor_user_id IS NOT NULL;

CREATE INDEX idx_audit_events_entity
ON public.audit_events(
    entity_type,
    entity_id,
    occurred_at DESC
)
WHERE entity_type IS NOT NULL;

CREATE INDEX idx_audit_events_entity_reference
ON public.audit_events(
    entity_type,
    entity_reference,
    occurred_at DESC
)
WHERE entity_reference IS NOT NULL;

CREATE INDEX idx_audit_events_category
ON public.audit_events(
    event_category,
    event_action,
    occurred_at DESC
);

CREATE INDEX idx_audit_events_security
ON public.audit_events(
    severity,
    occurred_at DESC
)
WHERE event_category IN (
    'AUTHENTICATION',
    'AUTHORIZATION',
    'SECURITY',
    'PRIVACY'
);

CREATE INDEX idx_audit_events_failure
ON public.audit_events(
    event_outcome,
    severity,
    occurred_at DESC
)
WHERE event_outcome IN (
    'FAILURE',
    'DENIED',
    'BLOCKED'
);

CREATE INDEX idx_audit_events_request
ON public.audit_events(request_reference)
WHERE request_reference IS NOT NULL;

CREATE INDEX idx_audit_events_correlation
ON public.audit_events(correlation_id)
WHERE correlation_id IS NOT NULL;

CREATE INDEX idx_audit_events_trace
ON public.audit_events(trace_id)
WHERE trace_id IS NOT NULL;

CREATE INDEX idx_audit_events_retention
ON public.audit_events(retention_until)
WHERE retention_until IS NOT NULL
  AND legal_hold_applied = FALSE;

CREATE INDEX idx_audit_events_legal_hold
ON public.audit_events(occurred_at DESC)
WHERE legal_hold_applied = TRUE;

CREATE INDEX idx_audit_events_changed_fields
ON public.audit_events
USING GIN (changed_fields);

CREATE INDEX idx_audit_events_details
ON public.audit_events
USING GIN (event_details);

CREATE INDEX idx_audit_events_metadata
ON public.audit_events
USING GIN (metadata);

CREATE INDEX idx_approval_requests_entity
ON public.approval_requests(
    entity_type,
    entity_id,
    created_at DESC
);

CREATE INDEX idx_approval_requests_status
ON public.approval_requests(
    approval_status,
    approval_priority,
    due_at
);

CREATE INDEX idx_approval_requests_requester
ON public.approval_requests(
    requested_by_user_id,
    created_at DESC
)
WHERE requested_by_user_id IS NOT NULL;

CREATE INDEX idx_approval_requests_pending
ON public.approval_requests(
    due_at,
    approval_priority
)
WHERE approval_status IN (
    'SUBMITTED',
    'PENDING',
    'IN_REVIEW',
    'PARTIALLY_APPROVED'
);

CREATE INDEX idx_approval_requests_escalation
ON public.approval_requests(
    escalation_level,
    due_at
)
WHERE escalation_enabled = TRUE
  AND approval_status IN (
      'SUBMITTED',
      'PENDING',
      'IN_REVIEW',
      'PARTIALLY_APPROVED'
  );

CREATE INDEX idx_approval_requests_metadata
ON public.approval_requests
USING GIN (metadata);

CREATE INDEX idx_approval_decisions_request
ON public.approval_decisions(
    approval_request_id,
    approval_step,
    decision_sequence
);

CREATE INDEX idx_approval_decisions_approver
ON public.approval_decisions(
    approver_user_id,
    decision_status,
    due_at
)
WHERE approver_user_id IS NOT NULL;

CREATE INDEX idx_approval_decisions_pending
ON public.approval_decisions(
    due_at,
    assigned_at
)
WHERE decision_status IN (
    'PENDING',
    'IN_REVIEW'
);

CREATE INDEX idx_approval_decisions_metadata
ON public.approval_decisions
USING GIN (metadata);

CREATE INDEX idx_consent_records_user
ON public.consent_records(
    user_id,
    consent_type,
    created_at DESC
)
WHERE user_id IS NOT NULL;

CREATE INDEX idx_consent_records_application
ON public.consent_records(
    bank_application_id,
    consent_type,
    created_at DESC
)
WHERE bank_application_id IS NOT NULL;

CREATE INDEX idx_consent_records_bank
ON public.consent_records(
    bank_id,
    consent_type,
    created_at DESC
)
WHERE bank_id IS NOT NULL;

CREATE INDEX idx_consent_records_active
ON public.consent_records(
    consent_type,
    expires_at
)
WHERE consent_status = 'GRANTED';

CREATE INDEX idx_consent_records_expiring
ON public.consent_records(expires_at)
WHERE expires_at IS NOT NULL
  AND consent_status = 'GRANTED';

CREATE INDEX idx_consent_records_withdrawn
ON public.consent_records(
    withdrawn_at,
    consent_type
)
WHERE consent_status = 'WITHDRAWN';

CREATE INDEX idx_consent_records_data_categories
ON public.consent_records
USING GIN (data_categories);

CREATE INDEX idx_consent_records_metadata
ON public.consent_records
USING GIN (metadata);

CREATE INDEX idx_data_classification_rules_table
ON public.data_classification_rules(
    schema_name,
    table_name,
    classification_level
);

CREATE INDEX idx_data_classification_rules_category
ON public.data_classification_rules(
    data_category,
    sensitivity_type,
    rule_status
);

CREATE INDEX idx_data_classification_rules_restricted
ON public.data_classification_rules(
    table_name,
    column_name
)
WHERE classification_level IN (
    'RESTRICTED',
    'HIGHLY_RESTRICTED'
);

CREATE INDEX idx_data_classification_rules_access
ON public.data_classification_rules
USING GIN (access_conditions);

CREATE INDEX idx_data_classification_rules_metadata
ON public.data_classification_rules
USING GIN (metadata);

CREATE INDEX idx_data_retention_policies_entity
ON public.data_retention_policies(
    entity_type,
    policy_status
);

CREATE INDEX idx_data_retention_policies_table
ON public.data_retention_policies(
    schema_name,
    table_name,
    policy_status
)
WHERE table_name IS NOT NULL;

CREATE INDEX idx_data_retention_policies_review
ON public.data_retention_policies(next_review_due_at)
WHERE next_review_due_at IS NOT NULL
  AND policy_status IN (
      'APPROVED',
      'ACTIVE'
  );

CREATE INDEX idx_data_retention_policies_conditions
ON public.data_retention_policies
USING GIN (policy_conditions);

CREATE INDEX idx_data_retention_policies_metadata
ON public.data_retention_policies
USING GIN (metadata);

CREATE INDEX idx_data_retention_executions_policy
ON public.data_retention_executions(
    retention_policy_id,
    created_at DESC
);

CREATE INDEX idx_data_retention_executions_status
ON public.data_retention_executions(
    execution_status,
    scheduled_at
);

CREATE INDEX idx_data_retention_executions_entity
ON public.data_retention_executions(
    entity_type,
    entity_id,
    created_at DESC
);

CREATE INDEX idx_data_retention_executions_failed
ON public.data_retention_executions(
    failed_at DESC,
    error_code
)
WHERE execution_status = 'FAILED';

CREATE INDEX idx_data_retention_executions_metadata
ON public.data_retention_executions
USING GIN (metadata);

CREATE INDEX idx_legal_holds_status
ON public.legal_holds(
    hold_status,
    effective_from,
    effective_until
);

CREATE INDEX idx_legal_holds_case
ON public.legal_holds(case_reference)
WHERE case_reference IS NOT NULL;

CREATE INDEX idx_legal_holds_active
ON public.legal_holds(effective_from)
WHERE hold_status = 'ACTIVE';

CREATE INDEX idx_legal_holds_entities
ON public.legal_holds
USING GIN (entity_references);

CREATE INDEX idx_legal_holds_users
ON public.legal_holds
USING GIN (user_references);

CREATE INDEX idx_legal_holds_metadata
ON public.legal_holds
USING GIN (metadata);

CREATE INDEX idx_legal_hold_items_hold
ON public.legal_hold_items(
    legal_hold_id,
    item_status,
    preserved_at DESC
);

CREATE INDEX idx_legal_hold_items_entity
ON public.legal_hold_items(
    entity_type,
    entity_id
)
WHERE entity_id IS NOT NULL;

CREATE INDEX idx_legal_hold_items_user
ON public.legal_hold_items(
    user_id,
    item_status
)
WHERE user_id IS NOT NULL;

CREATE INDEX idx_legal_hold_items_metadata
ON public.legal_hold_items
USING GIN (metadata);

CREATE INDEX idx_data_access_logs_user
ON public.data_access_logs(
    user_id,
    accessed_at DESC
)
WHERE user_id IS NOT NULL;

CREATE INDEX idx_data_access_logs_entity
ON public.data_access_logs(
    entity_type,
    entity_id,
    accessed_at DESC
);

CREATE INDEX idx_data_access_logs_purpose
ON public.data_access_logs(
    access_purpose,
    accessed_at DESC
);

CREATE INDEX idx_data_access_logs_restricted
ON public.data_access_logs(
    data_classification,
    accessed_at DESC
)
WHERE data_classification IN (
    'RESTRICTED',
    'HIGHLY_RESTRICTED'
);

CREATE INDEX idx_data_access_logs_denied
ON public.data_access_logs(
    denial_reason_code,
    accessed_at DESC
)
WHERE access_outcome IN (
    'DENIED',
    'BLOCKED',
    'FAILED'
);

CREATE INDEX idx_data_access_logs_request
ON public.data_access_logs(request_reference)
WHERE request_reference IS NOT NULL;

CREATE INDEX idx_data_access_logs_correlation
ON public.data_access_logs(correlation_id)
WHERE correlation_id IS NOT NULL;

CREATE INDEX idx_data_access_logs_categories
ON public.data_access_logs
USING GIN (data_categories);

CREATE INDEX idx_data_access_logs_fields
ON public.data_access_logs
USING GIN (fields_accessed);

CREATE INDEX idx_data_access_logs_metadata
ON public.data_access_logs
USING GIN (metadata);

CREATE INDEX idx_data_export_requests_requester
ON public.data_export_requests(
    requested_by_user_id,
    created_at DESC
)
WHERE requested_by_user_id IS NOT NULL;

CREATE INDEX idx_data_export_requests_subject
ON public.data_export_requests(
    subject_user_id,
    created_at DESC
)
WHERE subject_user_id IS NOT NULL;

CREATE INDEX idx_data_export_requests_status
ON public.data_export_requests(
    export_status,
    requested_at DESC
);

CREATE INDEX idx_data_export_requests_pending
ON public.data_export_requests(
    requested_at,
    data_classification
)
WHERE export_status IN (
    'SUBMITTED',
    'PENDING_APPROVAL',
    'APPROVED',
    'PROCESSING'
);

CREATE INDEX idx_data_export_requests_expiring
ON public.data_export_requests(expires_at)
WHERE expires_at IS NOT NULL
  AND export_status = 'READY';

CREATE INDEX idx_data_export_requests_storage
ON public.data_export_requests(
    storage_provider,
    storage_bucket,
    storage_path
)
WHERE storage_path IS NOT NULL;

CREATE INDEX idx_data_export_requests_entity_types
ON public.data_export_requests
USING GIN (entity_types);

CREATE INDEX idx_data_export_requests_metadata
ON public.data_export_requests
USING GIN (metadata);

CREATE INDEX idx_compliance_cases_status
ON public.compliance_cases(
    case_status,
    case_priority,
    due_at
);

CREATE INDEX idx_compliance_cases_type
ON public.compliance_cases(
    case_type,
    case_severity,
    opened_at DESC
);

CREATE INDEX idx_compliance_cases_assignee
ON public.compliance_cases(
    assigned_to_user_id,
    case_status,
    due_at
)
WHERE assigned_to_user_id IS NOT NULL;

CREATE INDEX idx_compliance_cases_subject
ON public.compliance_cases(
    subject_type,
    subject_id,
    opened_at DESC
)
WHERE subject_type IS NOT NULL;

CREATE INDEX idx_compliance_cases_user
ON public.compliance_cases(
    subject_user_id,
    opened_at DESC
)
WHERE subject_user_id IS NOT NULL;

CREATE INDEX idx_compliance_cases_application
ON public.compliance_cases(
    bank_application_id,
    opened_at DESC
)
WHERE bank_application_id IS NOT NULL;

CREATE INDEX idx_compliance_cases_regulatory_due
ON public.compliance_cases(regulatory_report_due_at)
WHERE regulatory_report_required = TRUE
  AND regulatory_reported_at IS NULL;

CREATE INDEX idx_compliance_cases_overdue
ON public.compliance_cases(
    due_at,
    case_severity
)
WHERE due_at IS NOT NULL
  AND case_status NOT IN (
      'RESOLVED',
      'CLOSED',
      'CANCELLED'
  );

CREATE INDEX idx_compliance_cases_controls
ON public.compliance_cases
USING GIN (related_controls);

CREATE INDEX idx_compliance_cases_findings
ON public.compliance_cases
USING GIN (findings);

CREATE INDEX idx_compliance_cases_metadata
ON public.compliance_cases
USING GIN (metadata);

CREATE INDEX idx_compliance_case_events_case
ON public.compliance_case_events(
    compliance_case_id,
    occurred_at DESC
);

CREATE INDEX idx_compliance_case_events_type
ON public.compliance_case_events(
    event_type,
    occurred_at DESC
);

CREATE INDEX idx_compliance_case_events_actor
ON public.compliance_case_events(
    actor_user_id,
    occurred_at DESC
)
WHERE actor_user_id IS NOT NULL;

CREATE INDEX idx_compliance_case_events_details
ON public.compliance_case_events
USING GIN (event_details);

CREATE INDEX idx_compliance_case_events_metadata
ON public.compliance_case_events
USING GIN (metadata);

CREATE TRIGGER trg_governance_controls_updated_at
BEFORE UPDATE
ON public.governance_controls
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_governance_control_assessments_updated_at
BEFORE UPDATE
ON public.governance_control_assessments
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_approval_requests_updated_at
BEFORE UPDATE
ON public.approval_requests
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_approval_decisions_updated_at
BEFORE UPDATE
ON public.approval_decisions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_consent_records_updated_at
BEFORE UPDATE
ON public.consent_records
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_data_classification_rules_updated_at
BEFORE UPDATE
ON public.data_classification_rules
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_data_retention_policies_updated_at
BEFORE UPDATE
ON public.data_retention_policies
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_data_retention_executions_updated_at
BEFORE UPDATE
ON public.data_retention_executions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_legal_holds_updated_at
BEFORE UPDATE
ON public.legal_holds
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_legal_hold_items_updated_at
BEFORE UPDATE
ON public.legal_hold_items
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_data_export_requests_updated_at
BEFORE UPDATE
ON public.data_export_requests
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_compliance_cases_updated_at
BEFORE UPDATE
ON public.compliance_cases
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.governance_controls IS
'Central governance and compliance control library covering policy, technical, administrative, monitoring, approval, and regulatory controls.';

COMMENT ON COLUMN public.governance_controls.control_reference IS
'Stable business identifier for the governance control.';

COMMENT ON COLUMN public.governance_controls.testing_configuration IS
'Structured configuration describing how the control should be tested and evaluated.';

COMMENT ON TABLE public.governance_control_assessments IS
'Design and operating effectiveness assessments, audit tests, self-assessments, and remediation validations for governance controls.';

COMMENT ON COLUMN public.governance_control_assessments.effectiveness_score IS
'Normalized control-effectiveness score from zero to one hundred.';

COMMENT ON TABLE public.audit_events IS
'Central append-oriented audit trail for authentication, access, changes, approvals, applications, partnerships, commissions, security, privacy, and system operations.';

COMMENT ON COLUMN public.audit_events.before_values IS
'Redacted structured values before a change; highly sensitive secrets should never be stored directly.';

COMMENT ON COLUMN public.audit_events.after_values IS
'Redacted structured values after a change; highly sensitive secrets should never be stored directly.';

COMMENT ON COLUMN public.audit_events.integrity_hash IS
'Optional integrity hash used to detect unauthorized modification of an audit record.';

COMMENT ON TABLE public.approval_requests IS
'Governed approval workflow requests for sensitive changes, exports, deletions, role assignments, overrides, partnerships, commissions, settlements, policies, and controls.';

COMMENT ON COLUMN public.approval_requests.minimum_approvals_required IS
'Minimum number of approving decisions required before the request can be completed.';

COMMENT ON TABLE public.approval_decisions IS
'Individual approval, rejection, delegation, abstention, or expiry decisions associated with approval requests.';

COMMENT ON TABLE public.consent_records IS
'Versioned consent evidence for privacy, data sharing, bank applications, marketing, profiling, automated decisions, open banking, identity verification, and related purposes.';

COMMENT ON COLUMN public.consent_records.proof_hash IS
'Integrity proof for the consent evidence captured at the time of the customer decision.';

COMMENT ON TABLE public.data_classification_rules IS
'Data classification registry defining sensitivity, masking, encryption, tokenization, access logging, export, consent, and transfer requirements at table or column level.';

COMMENT ON TABLE public.data_retention_policies IS
'Retention, archival, anonymization, deletion, review, approval, and legal-hold policies for platform records.';

COMMENT ON TABLE public.data_retention_executions IS
'Execution history for scheduled, manual, regulatory, legal, and customer-requested retention actions.';

COMMENT ON TABLE public.legal_holds IS
'Legal, regulatory, investigation, audit, dispute, fraud, and incident holds that suspend normal data disposition.';

COMMENT ON TABLE public.legal_hold_items IS
'Specific users, entities, records, snapshots, or stored artifacts preserved under a legal hold.';

COMMENT ON TABLE public.data_access_logs IS
'Detailed access history for customer, financial, identity, application, recommendation, commission, settlement, audit, and compliance data.';

COMMENT ON COLUMN public.data_access_logs.query_fingerprint IS
'Non-sensitive fingerprint of the query or retrieval pattern used for monitoring unusual access.';

COMMENT ON TABLE public.data_export_requests IS
'Governed data-export workflow including approval, encryption, redaction, delivery, expiry, download controls, and audit evidence.';

COMMENT ON TABLE public.compliance_cases IS
'Compliance, privacy, fraud, AML, KYC, security, customer-protection, control, audit, data-quality, and regulatory case management.';

COMMENT ON TABLE public.compliance_case_events IS
'Chronological event and evidence trail for compliance-case investigation, escalation, notification, remediation, resolution, and closure.';
