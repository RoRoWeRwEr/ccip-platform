CREATE TABLE public.bank_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    bank_id UUID NOT NULL
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    recommendation_run_id UUID
        REFERENCES public.recommendation_runs(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_result_id UUID
        REFERENCES public.recommendation_results(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    comparison_id UUID
        REFERENCES public.card_comparisons(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    saved_card_id UUID
        REFERENCES public.user_saved_cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    financial_profile_id UUID
        REFERENCES public.customer_financial_profiles(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    spending_profile_id UUID
        REFERENCES public.customer_spending_profiles(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    preference_profile_id UUID
        REFERENCES public.customer_preferences(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    application_reference TEXT NOT NULL,

    bank_application_reference TEXT,

    partner_application_reference TEXT,

    referral_reference TEXT,

    session_reference TEXT,

    journey_reference TEXT,

    correlation_id TEXT,

    application_type TEXT NOT NULL DEFAULT 'NEW_CARD',

    application_channel TEXT NOT NULL DEFAULT 'PLATFORM',

    application_source TEXT NOT NULL DEFAULT 'CARD_DETAIL',

    application_status TEXT NOT NULL DEFAULT 'DRAFT',

    application_stage TEXT NOT NULL DEFAULT 'STARTED',

    application_priority TEXT NOT NULL DEFAULT 'NORMAL',

    applicant_type TEXT NOT NULL DEFAULT 'EXISTING_USER',

    employment_type TEXT,

    employment_sector TEXT,

    nationality_code TEXT,

    country_of_residence_code TEXT,

    preferred_language_code TEXT NOT NULL DEFAULT 'en',

    preferred_contact_channel TEXT,

    requested_credit_limit NUMERIC(18, 6),

    requested_credit_limit_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    approved_credit_limit NUMERIC(18, 6),

    approved_credit_limit_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    declared_monthly_income NUMERIC(18, 6),

    income_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    declared_monthly_obligations NUMERIC(18, 6),

    obligations_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    declared_debt_burden_ratio NUMERIC(9, 6),

    eligibility_status_at_application TEXT,

    eligibility_score_at_application NUMERIC(5, 2),

    eligibility_confidence_at_application NUMERIC(5, 2),

    recommendation_score_at_application NUMERIC(9, 4),

    recommendation_rank_at_application INTEGER,

    estimated_approval_probability NUMERIC(5, 2),

    estimated_first_year_value NUMERIC(18, 6),

    estimated_ongoing_annual_value NUMERIC(18, 6),

    estimated_value_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    annual_fee_at_application NUMERIC(18, 6),

    annual_fee_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    promotional_offer_applied BOOLEAN NOT NULL DEFAULT FALSE,

    offer_reference TEXT,

    offer_expires_at TIMESTAMPTZ,

    consent_to_share_data BOOLEAN NOT NULL DEFAULT FALSE,

    data_sharing_consent_at TIMESTAMPTZ,

    consent_version TEXT,

    privacy_policy_version TEXT,

    terms_version TEXT,

    marketing_consent BOOLEAN NOT NULL DEFAULT FALSE,

    open_banking_consent_reference TEXT,

    open_banking_consent_status TEXT,

    open_banking_consent_expires_at TIMESTAMPTZ,

    identity_verification_status TEXT NOT NULL DEFAULT 'NOT_STARTED',

    identity_verification_reference TEXT,

    identity_verified_at TIMESTAMPTZ,

    kyc_status TEXT NOT NULL DEFAULT 'NOT_STARTED',

    kyc_reference TEXT,

    kyc_completed_at TIMESTAMPTZ,

    aml_screening_status TEXT NOT NULL DEFAULT 'NOT_STARTED',

    aml_screening_reference TEXT,

    aml_screening_completed_at TIMESTAMPTZ,

    fraud_screening_status TEXT NOT NULL DEFAULT 'NOT_STARTED',

    fraud_screening_reference TEXT,

    fraud_screening_completed_at TIMESTAMPTZ,

    document_status TEXT NOT NULL DEFAULT 'NOT_REQUIRED',

    required_document_count INTEGER NOT NULL DEFAULT 0,

    submitted_document_count INTEGER NOT NULL DEFAULT 0,

    verified_document_count INTEGER NOT NULL DEFAULT 0,

    rejected_document_count INTEGER NOT NULL DEFAULT 0,

    pending_task_count INTEGER NOT NULL DEFAULT 0,

    completed_task_count INTEGER NOT NULL DEFAULT 0,

    sla_target_minutes INTEGER,

    sla_started_at TIMESTAMPTZ,

    sla_due_at TIMESTAMPTZ,

    sla_completed_at TIMESTAMPTZ,

    sla_breached BOOLEAN NOT NULL DEFAULT FALSE,

    expected_decision_at TIMESTAMPTZ,

    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    submitted_at TIMESTAMPTZ,

    received_by_bank_at TIMESTAMPTZ,

    review_started_at TIMESTAMPTZ,

    decision_at TIMESTAMPTZ,

    approved_at TIMESTAMPTZ,

    rejected_at TIMESTAMPTZ,

    withdrawn_at TIMESTAMPTZ,

    expired_at TIMESTAMPTZ,

    card_issued_at TIMESTAMPTZ,

    card_delivered_at TIMESTAMPTZ,

    card_activated_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    last_status_changed_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    last_customer_action_at TIMESTAMPTZ,

    last_bank_action_at TIMESTAMPTZ,

    last_platform_action_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    rejection_reason_code TEXT,

    rejection_reason_category TEXT,

    rejection_reason_text TEXT,

    withdrawal_reason_code TEXT,

    withdrawal_reason_text TEXT,

    cancellation_reason_code TEXT,

    cancellation_reason_text TEXT,

    customer_notes TEXT,

    internal_notes TEXT,

    bank_notes TEXT,

    next_required_action TEXT,

    next_required_action_due_at TIMESTAMPTZ,

    is_test_application BOOLEAN NOT NULL DEFAULT FALSE,

    is_manual_application BOOLEAN NOT NULL DEFAULT FALSE,

    is_assisted_application BOOLEAN NOT NULL DEFAULT FALSE,

    is_preapproved BOOLEAN NOT NULL DEFAULT FALSE,

    is_resubmission BOOLEAN NOT NULL DEFAULT FALSE,

    previous_application_id UUID
        REFERENCES public.bank_applications(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    is_archived BOOLEAN NOT NULL DEFAULT FALSE,

    archived_at TIMESTAMPTZ,

    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,

    deleted_at TIMESTAMPTZ,

    applicant_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    financial_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    spending_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    preference_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    card_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    eligibility_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    recommendation_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    application_payload JSONB NOT NULL DEFAULT '{}'::JSONB,

    bank_response_summary JSONB NOT NULL DEFAULT '{}'::JSONB,

    consent_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    risk_summary JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_bank_applications_reference
        UNIQUE (
            application_reference
        ),

    CONSTRAINT uq_bank_applications_bank_reference
        UNIQUE (
            bank_id,
            bank_application_reference
        ),

    CONSTRAINT chk_bank_applications_reference
        CHECK (
            application_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_bank_applications_bank_reference
        CHECK (
            bank_application_reference IS NULL
            OR length(trim(bank_application_reference)) > 0
        ),

    CONSTRAINT chk_bank_applications_partner_reference
        CHECK (
            partner_application_reference IS NULL
            OR length(trim(partner_application_reference)) > 0
        ),

    CONSTRAINT chk_bank_applications_referral_reference
        CHECK (
            referral_reference IS NULL
            OR length(trim(referral_reference)) > 0
        ),

    CONSTRAINT chk_bank_applications_type
        CHECK (
            application_type IN (
                'NEW_CARD',
                'ADDITIONAL_CARD',
                'SUPPLEMENTARY_CARD',
                'CARD_UPGRADE',
                'CARD_DOWNGRADE',
                'CARD_REPLACEMENT',
                'BALANCE_TRANSFER',
                'LIMIT_INCREASE',
                'PREAPPROVAL',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_applications_channel
        CHECK (
            application_channel IN (
                'PLATFORM',
                'BANK_API',
                'BANK_REDIRECT',
                'BANK_BRANCH',
                'BANK_CALL_CENTER',
                'BANK_MOBILE_APP',
                'BANK_WEBSITE',
                'PARTNER_API',
                'AFFILIATE_LINK',
                'ADVISOR',
                'ADMIN',
                'IMPORT',
                'MANUAL',
                'TEST',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_applications_source
        CHECK (
            application_source IN (
                'RECOMMENDATION_LIST',
                'RECOMMENDATION_DETAIL',
                'CARD_DETAIL',
                'CARD_COMPARISON',
                'SAVED_CARD',
                'COLLECTION',
                'SEARCH_RESULTS',
                'BANK_PAGE',
                'OFFER_PAGE',
                'ADVISOR',
                'ADMIN',
                'API',
                'IMPORT',
                'TEST',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_applications_status
        CHECK (
            application_status IN (
                'DRAFT',
                'INCOMPLETE',
                'READY_TO_SUBMIT',
                'SUBMITTING',
                'SUBMITTED',
                'RECEIVED',
                'DOCUMENTS_REQUIRED',
                'IDENTITY_VERIFICATION_REQUIRED',
                'KYC_REQUIRED',
                'UNDER_REVIEW',
                'PENDING_BANK_ACTION',
                'PENDING_CUSTOMER_ACTION',
                'PENDING_EXTERNAL_CHECK',
                'PREAPPROVED',
                'CONDITIONALLY_APPROVED',
                'APPROVED',
                'REJECTED',
                'WITHDRAWN',
                'CANCELLED',
                'EXPIRED',
                'CARD_ISSUED',
                'CARD_DELIVERED',
                'CARD_ACTIVATED',
                'COMPLETED',
                'FAILED',
                'ERROR'
            )
        ),

    CONSTRAINT chk_bank_applications_stage
        CHECK (
            application_stage IN (
                'STARTED',
                'PROFILE_CAPTURE',
                'ELIGIBILITY_CHECK',
                'CONSENT_CAPTURE',
                'IDENTITY_VERIFICATION',
                'DOCUMENT_COLLECTION',
                'READY_FOR_SUBMISSION',
                'SUBMISSION',
                'BANK_RECEIPT',
                'BANK_REVIEW',
                'ADDITIONAL_INFORMATION',
                'DECISION',
                'FULFILLMENT',
                'DELIVERY',
                'ACTIVATION',
                'COMPLETED',
                'CLOSED'
            )
        ),

    CONSTRAINT chk_bank_applications_priority
        CHECK (
            application_priority IN (
                'LOW',
                'NORMAL',
                'HIGH',
                'URGENT',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_bank_applications_applicant_type
        CHECK (
            applicant_type IN (
                'EXISTING_USER',
                'NEW_USER',
                'EXISTING_BANK_CUSTOMER',
                'NEW_TO_BANK',
                'PREQUALIFIED',
                'PREAPPROVED',
                'REFERRED',
                'ASSISTED',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_applications_employment_type
        CHECK (
            employment_type IS NULL
            OR employment_type IN (
                'GOVERNMENT',
                'SEMI_GOVERNMENT',
                'PRIVATE',
                'SELF_EMPLOYED',
                'BUSINESS_OWNER',
                'MILITARY',
                'RETIRED',
                'STUDENT',
                'UNEMPLOYED',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_applications_employment_sector
        CHECK (
            employment_sector IS NULL
            OR length(trim(employment_sector)) > 0
        ),

    CONSTRAINT chk_bank_applications_nationality
        CHECK (
            nationality_code IS NULL
            OR nationality_code ~ '^[A-Z]{2}$'
        ),

    CONSTRAINT chk_bank_applications_residence_country
        CHECK (
            country_of_residence_code IS NULL
            OR country_of_residence_code ~ '^[A-Z]{2}$'
        ),

    CONSTRAINT chk_bank_applications_language
        CHECK (
            preferred_language_code
                ~ '^[a-z]{2}(?:-[A-Z]{2})?$'
        ),

    CONSTRAINT chk_bank_applications_contact_channel
        CHECK (
            preferred_contact_channel IS NULL
            OR preferred_contact_channel IN (
                'IN_APP',
                'EMAIL',
                'PUSH',
                'SMS',
                'WHATSAPP',
                'PHONE'
            )
        ),

    CONSTRAINT chk_bank_applications_requested_limit
        CHECK (
            requested_credit_limit IS NULL
            OR requested_credit_limit >= 0
        ),

    CONSTRAINT chk_bank_applications_requested_limit_currency
        CHECK (
            (
                requested_credit_limit IS NULL
                AND requested_credit_limit_currency_id IS NULL
            )
            OR
            (
                requested_credit_limit IS NOT NULL
                AND requested_credit_limit_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_bank_applications_approved_limit
        CHECK (
            approved_credit_limit IS NULL
            OR approved_credit_limit >= 0
        ),

    CONSTRAINT chk_bank_applications_approved_limit_currency
        CHECK (
            (
                approved_credit_limit IS NULL
                AND approved_credit_limit_currency_id IS NULL
            )
            OR
            (
                approved_credit_limit IS NOT NULL
                AND approved_credit_limit_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_bank_applications_income
        CHECK (
            declared_monthly_income IS NULL
            OR declared_monthly_income >= 0
        ),

    CONSTRAINT chk_bank_applications_income_currency
        CHECK (
            (
                declared_monthly_income IS NULL
                AND income_currency_id IS NULL
            )
            OR
            (
                declared_monthly_income IS NOT NULL
                AND income_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_bank_applications_obligations
        CHECK (
            declared_monthly_obligations IS NULL
            OR declared_monthly_obligations >= 0
        ),

    CONSTRAINT chk_bank_applications_obligations_currency
        CHECK (
            (
                declared_monthly_obligations IS NULL
                AND obligations_currency_id IS NULL
            )
            OR
            (
                declared_monthly_obligations IS NOT NULL
                AND obligations_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_bank_applications_dbr
        CHECK (
            declared_debt_burden_ratio IS NULL
            OR declared_debt_burden_ratio BETWEEN 0 AND 10
        ),

    CONSTRAINT chk_bank_applications_eligibility_status
        CHECK (
            eligibility_status_at_application IS NULL
            OR eligibility_status_at_application IN (
                'ELIGIBLE',
                'LIKELY_ELIGIBLE',
                'CONDITIONALLY_ELIGIBLE',
                'INSUFFICIENT_DATA',
                'LIKELY_INELIGIBLE',
                'INELIGIBLE',
                'NOT_ASSESSED'
            )
        ),

    CONSTRAINT chk_bank_applications_eligibility_score
        CHECK (
            eligibility_score_at_application IS NULL
            OR eligibility_score_at_application BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_bank_applications_eligibility_confidence
        CHECK (
            eligibility_confidence_at_application IS NULL
            OR eligibility_confidence_at_application BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_bank_applications_recommendation_score
        CHECK (
            recommendation_score_at_application IS NULL
            OR recommendation_score_at_application BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_bank_applications_recommendation_rank
        CHECK (
            recommendation_rank_at_application IS NULL
            OR recommendation_rank_at_application > 0
        ),

    CONSTRAINT chk_bank_applications_approval_probability
        CHECK (
            estimated_approval_probability IS NULL
            OR estimated_approval_probability BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_bank_applications_value_currency
        CHECK (
            (
                estimated_first_year_value IS NULL
                AND estimated_ongoing_annual_value IS NULL
                AND estimated_value_currency_id IS NULL
            )
            OR
            (
                estimated_value_currency_id IS NOT NULL
                AND (
                    estimated_first_year_value IS NOT NULL
                    OR estimated_ongoing_annual_value IS NOT NULL
                )
            )
        ),

    CONSTRAINT chk_bank_applications_annual_fee
        CHECK (
            annual_fee_at_application IS NULL
            OR annual_fee_at_application >= 0
        ),

    CONSTRAINT chk_bank_applications_annual_fee_currency
        CHECK (
            (
                annual_fee_at_application IS NULL
                AND annual_fee_currency_id IS NULL
            )
            OR
            (
                annual_fee_at_application IS NOT NULL
                AND annual_fee_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_bank_applications_offer
        CHECK (
            promotional_offer_applied = FALSE
            OR offer_reference IS NOT NULL
        ),

    CONSTRAINT chk_bank_applications_offer_expiry
        CHECK (
            offer_expires_at IS NULL
            OR promotional_offer_applied = TRUE
        ),

    CONSTRAINT chk_bank_applications_data_consent
        CHECK (
            consent_to_share_data = FALSE
            OR data_sharing_consent_at IS NOT NULL
        ),

    CONSTRAINT chk_bank_applications_open_banking_status
        CHECK (
            open_banking_consent_status IS NULL
            OR open_banking_consent_status IN (
                'NOT_REQUESTED',
                'PENDING',
                'AUTHORIZED',
                'ACTIVE',
                'REVOKED',
                'EXPIRED',
                'FAILED'
            )
        ),

    CONSTRAINT chk_bank_applications_identity_status
        CHECK (
            identity_verification_status IN (
                'NOT_STARTED',
                'PENDING',
                'IN_PROGRESS',
                'VERIFIED',
                'PARTIALLY_VERIFIED',
                'FAILED',
                'EXPIRED',
                'NOT_REQUIRED'
            )
        ),

    CONSTRAINT chk_bank_applications_identity_verified
        CHECK (
            identity_verified_at IS NULL
            OR identity_verification_status = 'VERIFIED'
        ),

    CONSTRAINT chk_bank_applications_kyc_status
        CHECK (
            kyc_status IN (
                'NOT_STARTED',
                'PENDING',
                'IN_PROGRESS',
                'PASSED',
                'CONDITIONALLY_PASSED',
                'FAILED',
                'EXPIRED',
                'NOT_REQUIRED'
            )
        ),

    CONSTRAINT chk_bank_applications_kyc_completed
        CHECK (
            kyc_completed_at IS NULL
            OR kyc_status IN (
                'PASSED',
                'CONDITIONALLY_PASSED',
                'FAILED'
            )
        ),

    CONSTRAINT chk_bank_applications_aml_status
        CHECK (
            aml_screening_status IN (
                'NOT_STARTED',
                'PENDING',
                'IN_PROGRESS',
                'CLEAR',
                'POTENTIAL_MATCH',
                'MATCH_CONFIRMED',
                'ESCALATED',
                'FAILED',
                'NOT_REQUIRED'
            )
        ),

    CONSTRAINT chk_bank_applications_aml_completed
        CHECK (
            aml_screening_completed_at IS NULL
            OR aml_screening_status IN (
                'CLEAR',
                'POTENTIAL_MATCH',
                'MATCH_CONFIRMED',
                'ESCALATED',
                'FAILED'
            )
        ),

    CONSTRAINT chk_bank_applications_fraud_status
        CHECK (
            fraud_screening_status IN (
                'NOT_STARTED',
                'PENDING',
                'IN_PROGRESS',
                'CLEAR',
                'REVIEW_REQUIRED',
                'HIGH_RISK',
                'BLOCKED',
                'FAILED',
                'NOT_REQUIRED'
            )
        ),

    CONSTRAINT chk_bank_applications_fraud_completed
        CHECK (
            fraud_screening_completed_at IS NULL
            OR fraud_screening_status IN (
                'CLEAR',
                'REVIEW_REQUIRED',
                'HIGH_RISK',
                'BLOCKED',
                'FAILED'
            )
        ),

    CONSTRAINT chk_bank_applications_document_status
        CHECK (
            document_status IN (
                'NOT_REQUIRED',
                'NOT_STARTED',
                'INCOMPLETE',
                'SUBMITTED',
                'UNDER_REVIEW',
                'ADDITIONAL_DOCUMENTS_REQUIRED',
                'VERIFIED',
                'REJECTED',
                'EXPIRED'
            )
        ),

    CONSTRAINT chk_bank_applications_document_counts
        CHECK (
            required_document_count >= 0
            AND submitted_document_count >= 0
            AND verified_document_count >= 0
            AND rejected_document_count >= 0
            AND submitted_document_count <= required_document_count
            AND verified_document_count <= submitted_document_count
            AND rejected_document_count <= submitted_document_count
        ),

    CONSTRAINT chk_bank_applications_task_counts
        CHECK (
            pending_task_count >= 0
            AND completed_task_count >= 0
        ),

    CONSTRAINT chk_bank_applications_sla_target
        CHECK (
            sla_target_minutes IS NULL
            OR sla_target_minutes > 0
        ),

    CONSTRAINT chk_bank_applications_sla_due
        CHECK (
            sla_due_at IS NULL
            OR sla_started_at IS NULL
            OR sla_due_at >= sla_started_at
        ),

    CONSTRAINT chk_bank_applications_sla_completed
        CHECK (
            sla_completed_at IS NULL
            OR sla_started_at IS NULL
            OR sla_completed_at >= sla_started_at
        ),

    CONSTRAINT chk_bank_applications_submission_timeline
        CHECK (
            submitted_at IS NULL
            OR submitted_at >= started_at
        ),

    CONSTRAINT chk_bank_applications_bank_receipt_timeline
        CHECK (
            received_by_bank_at IS NULL
            OR submitted_at IS NULL
            OR received_by_bank_at >= submitted_at
        ),

    CONSTRAINT chk_bank_applications_review_timeline
        CHECK (
            review_started_at IS NULL
            OR submitted_at IS NULL
            OR review_started_at >= submitted_at
        ),

    CONSTRAINT chk_bank_applications_decision_timeline
        CHECK (
            decision_at IS NULL
            OR decision_at >= started_at
        ),

    CONSTRAINT chk_bank_applications_approved_timeline
        CHECK (
            approved_at IS NULL
            OR approved_at >= started_at
        ),

    CONSTRAINT chk_bank_applications_rejected_timeline
        CHECK (
            rejected_at IS NULL
            OR rejected_at >= started_at
        ),

    CONSTRAINT chk_bank_applications_withdrawn_timeline
        CHECK (
            withdrawn_at IS NULL
            OR withdrawn_at >= started_at
        ),

    CONSTRAINT chk_bank_applications_expired_timeline
        CHECK (
            expired_at IS NULL
            OR expired_at >= started_at
        ),

    CONSTRAINT chk_bank_applications_issued_timeline
        CHECK (
            card_issued_at IS NULL
            OR approved_at IS NULL
            OR card_issued_at >= approved_at
        ),

    CONSTRAINT chk_bank_applications_delivered_timeline
        CHECK (
            card_delivered_at IS NULL
            OR card_issued_at IS NULL
            OR card_delivered_at >= card_issued_at
        ),

    CONSTRAINT chk_bank_applications_activated_timeline
        CHECK (
            card_activated_at IS NULL
            OR card_delivered_at IS NULL
            OR card_activated_at >= card_delivered_at
        ),

    CONSTRAINT chk_bank_applications_completed_timeline
        CHECK (
            completed_at IS NULL
            OR completed_at >= started_at
        ),

    CONSTRAINT chk_bank_applications_expiry
        CHECK (
            expires_at IS NULL
            OR expires_at >= started_at
        ),

    CONSTRAINT chk_bank_applications_rejection_reason_code
        CHECK (
            rejection_reason_code IS NULL
            OR rejection_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_bank_applications_rejection_category
        CHECK (
            rejection_reason_category IS NULL
            OR rejection_reason_category IN (
                'ELIGIBILITY',
                'INCOME',
                'EMPLOYMENT',
                'CREDIT_HISTORY',
                'DEBT_BURDEN',
                'IDENTITY',
                'KYC',
                'AML',
                'FRAUD',
                'DOCUMENTATION',
                'BANK_POLICY',
                'DUPLICATE_APPLICATION',
                'CUSTOMER_REQUEST',
                'TECHNICAL',
                'UNKNOWN',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_applications_withdrawal_reason
        CHECK (
            withdrawal_reason_code IS NULL
            OR withdrawal_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_bank_applications_cancellation_reason
        CHECK (
            cancellation_reason_code IS NULL
            OR cancellation_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_bank_applications_resubmission
        CHECK (
            is_resubmission = FALSE
            OR previous_application_id IS NOT NULL
        ),

    CONSTRAINT chk_bank_applications_previous_application
        CHECK (
            previous_application_id IS NULL
            OR previous_application_id <> id
        ),

    CONSTRAINT chk_bank_applications_archived
        CHECK (
            (
                is_archived = FALSE
                AND archived_at IS NULL
            )
            OR
            (
                is_archived = TRUE
                AND archived_at IS NOT NULL
            )
        ),

    CONSTRAINT chk_bank_applications_deleted
        CHECK (
            (
                is_deleted = FALSE
                AND deleted_at IS NULL
            )
            OR
            (
                is_deleted = TRUE
                AND deleted_at IS NOT NULL
            )
        ),

    CONSTRAINT chk_bank_applications_deleted_archived
        CHECK (
            is_deleted = FALSE
            OR is_archived = TRUE
        ),

    CONSTRAINT chk_bank_applications_applicant_snapshot
        CHECK (
            jsonb_typeof(applicant_snapshot) = 'object'
        ),

    CONSTRAINT chk_bank_applications_financial_snapshot
        CHECK (
            jsonb_typeof(financial_snapshot) = 'object'
        ),

    CONSTRAINT chk_bank_applications_spending_snapshot
        CHECK (
            jsonb_typeof(spending_snapshot) = 'object'
        ),

    CONSTRAINT chk_bank_applications_preference_snapshot
        CHECK (
            jsonb_typeof(preference_snapshot) = 'object'
        ),

    CONSTRAINT chk_bank_applications_card_snapshot
        CHECK (
            jsonb_typeof(card_snapshot) = 'object'
        ),

    CONSTRAINT chk_bank_applications_eligibility_snapshot
        CHECK (
            jsonb_typeof(eligibility_snapshot) = 'object'
        ),

    CONSTRAINT chk_bank_applications_recommendation_snapshot
        CHECK (
            jsonb_typeof(recommendation_snapshot) = 'object'
        ),

    CONSTRAINT chk_bank_applications_payload
        CHECK (
            jsonb_typeof(application_payload) = 'object'
        ),

    CONSTRAINT chk_bank_applications_bank_response
        CHECK (
            jsonb_typeof(bank_response_summary) = 'object'
        ),

    CONSTRAINT chk_bank_applications_consent_details
        CHECK (
            jsonb_typeof(consent_details) = 'object'
        ),

    CONSTRAINT chk_bank_applications_risk_summary
        CHECK (
            jsonb_typeof(risk_summary) = 'object'
        ),

    CONSTRAINT chk_bank_applications_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.bank_application_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    application_id UUID NOT NULL
        REFERENCES public.bank_applications(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    document_reference TEXT NOT NULL,

    document_type TEXT NOT NULL,

    document_category TEXT NOT NULL,

    document_name TEXT,

    document_status TEXT NOT NULL DEFAULT 'REQUIRED',

    verification_status TEXT NOT NULL DEFAULT 'NOT_VERIFIED',

    storage_provider TEXT,

    storage_bucket TEXT,

    storage_path TEXT,

    original_file_name TEXT,

    mime_type TEXT,

    file_extension TEXT,

    file_size_bytes BIGINT,

    file_hash TEXT,

    document_number_masked TEXT,

    issuing_country_code TEXT,

    issued_at DATE,

    expires_at DATE,

    requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    uploaded_at TIMESTAMPTZ,

    submitted_at TIMESTAMPTZ,

    received_at TIMESTAMPTZ,

    verification_started_at TIMESTAMPTZ,

    verified_at TIMESTAMPTZ,

    rejected_at TIMESTAMPTZ,

    superseded_at TIMESTAMPTZ,

    required_by TIMESTAMPTZ,

    requested_by_entity TEXT NOT NULL DEFAULT 'PLATFORM',

    verified_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    rejection_reason_code TEXT,

    rejection_reason_text TEXT,

    verification_provider TEXT,

    verification_reference TEXT,

    confidence_score NUMERIC(5, 2),

    extracted_data JSONB NOT NULL DEFAULT '{}'::JSONB,

    verification_results JSONB NOT NULL DEFAULT '{}'::JSONB,

    access_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    is_required BOOLEAN NOT NULL DEFAULT TRUE,

    is_sensitive BOOLEAN NOT NULL DEFAULT TRUE,

    is_encrypted BOOLEAN NOT NULL DEFAULT FALSE,

    is_current BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_bank_application_documents_reference
        UNIQUE (
            document_reference
        ),

    CONSTRAINT chk_bank_application_documents_reference
        CHECK (
            document_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_bank_application_documents_type
        CHECK (
            document_type IN (
                'NATIONAL_ID',
                'IQAMA',
                'PASSPORT',
                'SALARY_CERTIFICATE',
                'EMPLOYMENT_LETTER',
                'BANK_STATEMENT',
                'PROOF_OF_ADDRESS',
                'TAX_DOCUMENT',
                'COMMERCIAL_REGISTRATION',
                'BUSINESS_LICENSE',
                'FINANCIAL_STATEMENT',
                'SIGNED_APPLICATION',
                'CONSENT_FORM',
                'SELFIE',
                'SIGNATURE',
                'INCOME_PROOF',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_documents_category
        CHECK (
            document_category IN (
                'IDENTITY',
                'EMPLOYMENT',
                'INCOME',
                'FINANCIAL',
                'ADDRESS',
                'BUSINESS',
                'CONSENT',
                'SIGNATURE',
                'COMPLIANCE',
                'SUPPORTING',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_documents_status
        CHECK (
            document_status IN (
                'REQUIRED',
                'REQUESTED',
                'UPLOADING',
                'UPLOADED',
                'SUBMITTED',
                'RECEIVED',
                'UNDER_REVIEW',
                'VERIFIED',
                'REJECTED',
                'EXPIRED',
                'SUPERSEDED',
                'WAIVED',
                'NOT_REQUIRED'
            )
        ),

    CONSTRAINT chk_bank_application_documents_verification_status
        CHECK (
            verification_status IN (
                'NOT_VERIFIED',
                'PENDING',
                'IN_PROGRESS',
                'VERIFIED',
                'PARTIALLY_VERIFIED',
                'FAILED',
                'REJECTED',
                'EXPIRED',
                'NOT_REQUIRED'
            )
        ),

    CONSTRAINT chk_bank_application_documents_file_size
        CHECK (
            file_size_bytes IS NULL
            OR file_size_bytes >= 0
        ),

    CONSTRAINT chk_bank_application_documents_country
        CHECK (
            issuing_country_code IS NULL
            OR issuing_country_code ~ '^[A-Z]{2}$'
        ),

    CONSTRAINT chk_bank_application_documents_dates
        CHECK (
            expires_at IS NULL
            OR issued_at IS NULL
            OR expires_at >= issued_at
        ),

    CONSTRAINT chk_bank_application_documents_upload_timeline
        CHECK (
            uploaded_at IS NULL
            OR uploaded_at >= requested_at
        ),

    CONSTRAINT chk_bank_application_documents_submit_timeline
        CHECK (
            submitted_at IS NULL
            OR uploaded_at IS NULL
            OR submitted_at >= uploaded_at
        ),

    CONSTRAINT chk_bank_application_documents_receive_timeline
        CHECK (
            received_at IS NULL
            OR submitted_at IS NULL
            OR received_at >= submitted_at
        ),

    CONSTRAINT chk_bank_application_documents_verification_timeline
        CHECK (
            verification_started_at IS NULL
            OR uploaded_at IS NULL
            OR verification_started_at >= uploaded_at
        ),

    CONSTRAINT chk_bank_application_documents_verified_timeline
        CHECK (
            verified_at IS NULL
            OR verification_started_at IS NULL
            OR verified_at >= verification_started_at
        ),

    CONSTRAINT chk_bank_application_documents_rejected_timeline
        CHECK (
            rejected_at IS NULL
            OR uploaded_at IS NULL
            OR rejected_at >= uploaded_at
        ),

    CONSTRAINT chk_bank_application_documents_requested_by
        CHECK (
            requested_by_entity IN (
                'PLATFORM',
                'BANK',
                'PARTNER',
                'COMPLIANCE',
                'ADVISOR',
                'ADMIN',
                'SYSTEM',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_documents_rejection_code
        CHECK (
            rejection_reason_code IS NULL
            OR rejection_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_bank_application_documents_confidence
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_bank_application_documents_extracted_data
        CHECK (
            jsonb_typeof(extracted_data) = 'object'
        ),

    CONSTRAINT chk_bank_application_documents_verification_results
        CHECK (
            jsonb_typeof(verification_results) = 'object'
        ),

    CONSTRAINT chk_bank_application_documents_access
        CHECK (
            jsonb_typeof(access_configuration) = 'object'
        ),

    CONSTRAINT chk_bank_application_documents_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.bank_application_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    application_id UUID NOT NULL
        REFERENCES public.bank_applications(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    event_reference TEXT NOT NULL,

    event_type TEXT NOT NULL,

    event_category TEXT NOT NULL,

    event_source TEXT NOT NULL DEFAULT 'PLATFORM',

    event_status TEXT NOT NULL DEFAULT 'COMPLETED',

    actor_type TEXT NOT NULL DEFAULT 'SYSTEM',

    actor_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    previous_application_status TEXT,

    new_application_status TEXT,

    previous_application_stage TEXT,

    new_application_stage TEXT,

    title TEXT,

    description TEXT,

    reason_code TEXT,

    reason_text TEXT,

    correlation_id TEXT,

    external_reference TEXT,

    occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    received_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    processed_at TIMESTAMPTZ,

    event_payload JSONB NOT NULL DEFAULT '{}'::JSONB,

    change_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_bank_application_events_reference
        UNIQUE (
            event_reference
        ),

    CONSTRAINT chk_bank_application_events_reference
        CHECK (
            event_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_bank_application_events_type
        CHECK (
            event_type IN (
                'APPLICATION_CREATED',
                'APPLICATION_UPDATED',
                'APPLICATION_STARTED',
                'APPLICATION_SUBMITTED',
                'APPLICATION_RECEIVED',
                'APPLICATION_RESUBMITTED',
                'STATUS_CHANGED',
                'STAGE_CHANGED',
                'DOCUMENT_REQUESTED',
                'DOCUMENT_UPLOADED',
                'DOCUMENT_SUBMITTED',
                'DOCUMENT_VERIFIED',
                'DOCUMENT_REJECTED',
                'CUSTOMER_ACTION_REQUIRED',
                'CUSTOMER_ACTION_COMPLETED',
                'BANK_ACTION_REQUIRED',
                'BANK_REVIEW_STARTED',
                'IDENTITY_VERIFICATION_STARTED',
                'IDENTITY_VERIFIED',
                'IDENTITY_VERIFICATION_FAILED',
                'KYC_STARTED',
                'KYC_COMPLETED',
                'KYC_FAILED',
                'AML_SCREENING_STARTED',
                'AML_SCREENING_COMPLETED',
                'FRAUD_SCREENING_STARTED',
                'FRAUD_SCREENING_COMPLETED',
                'PREAPPROVED',
                'CONDITIONALLY_APPROVED',
                'APPROVED',
                'REJECTED',
                'WITHDRAWN',
                'CANCELLED',
                'EXPIRED',
                'CARD_ISSUED',
                'CARD_DELIVERED',
                'CARD_ACTIVATED',
                'APPLICATION_COMPLETED',
                'API_REQUEST_SENT',
                'API_RESPONSE_RECEIVED',
                'WEBHOOK_RECEIVED',
                'ERROR_OCCURRED',
                'NOTE_ADDED',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_events_category
        CHECK (
            event_category IN (
                'APPLICATION',
                'STATUS',
                'STAGE',
                'DOCUMENT',
                'TASK',
                'IDENTITY',
                'KYC',
                'AML',
                'FRAUD',
                'DECISION',
                'FULFILLMENT',
                'DELIVERY',
                'ACTIVATION',
                'INTEGRATION',
                'ERROR',
                'NOTE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_events_source
        CHECK (
            event_source IN (
                'PLATFORM',
                'CUSTOMER',
                'BANK',
                'PARTNER',
                'API',
                'WEBHOOK',
                'SCHEDULED_JOB',
                'ADMIN',
                'ADVISOR',
                'SYSTEM',
                'IMPORT',
                'TEST',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_events_status
        CHECK (
            event_status IN (
                'PENDING',
                'PROCESSING',
                'COMPLETED',
                'PARTIALLY_COMPLETED',
                'FAILED',
                'IGNORED',
                'CANCELLED'
            )
        ),

    CONSTRAINT chk_bank_application_events_actor
        CHECK (
            actor_type IN (
                'CUSTOMER',
                'BANK_USER',
                'PARTNER_USER',
                'PLATFORM_USER',
                'ADVISOR',
                'ADMIN',
                'SYSTEM',
                'API',
                'WEBHOOK',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_events_reason_code
        CHECK (
            reason_code IS NULL
            OR reason_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_bank_application_events_received
        CHECK (
            received_at >= occurred_at
        ),

    CONSTRAINT chk_bank_application_events_processed
        CHECK (
            processed_at IS NULL
            OR processed_at >= received_at
        ),

    CONSTRAINT chk_bank_application_events_payload
        CHECK (
            jsonb_typeof(event_payload) = 'object'
        ),

    CONSTRAINT chk_bank_application_events_change_details
        CHECK (
            jsonb_typeof(change_details) = 'object'
        ),

    CONSTRAINT chk_bank_application_events_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.bank_application_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    application_id UUID NOT NULL
        REFERENCES public.bank_applications(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    document_id UUID
        REFERENCES public.bank_application_documents(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    task_reference TEXT NOT NULL,

    task_type TEXT NOT NULL,

    task_category TEXT NOT NULL,

    task_status TEXT NOT NULL DEFAULT 'PENDING',

    task_priority TEXT NOT NULL DEFAULT 'NORMAL',

    assigned_entity_type TEXT NOT NULL,

    assigned_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    title TEXT NOT NULL,

    description TEXT,

    instructions TEXT,

    action_url TEXT,

    completion_method TEXT,

    created_from_event_reference TEXT,

    external_task_reference TEXT,

    starts_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    due_at TIMESTAMPTZ,

    reminder_at TIMESTAMPTZ,

    started_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    cancelled_at TIMESTAMPTZ,

    expired_at TIMESTAMPTZ,

    completion_code TEXT,

    completion_notes TEXT,

    cancellation_reason_code TEXT,

    cancellation_reason_text TEXT,

    reminder_count INTEGER NOT NULL DEFAULT 0,

    maximum_reminder_count INTEGER NOT NULL DEFAULT 3,

    is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,

    blocks_application_progress BOOLEAN NOT NULL DEFAULT FALSE,

    requires_document BOOLEAN NOT NULL DEFAULT FALSE,

    requires_customer_presence BOOLEAN NOT NULL DEFAULT FALSE,

    task_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    completion_payload JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_bank_application_tasks_reference
        UNIQUE (
            task_reference
        ),

    CONSTRAINT chk_bank_application_tasks_reference
        CHECK (
            task_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_bank_application_tasks_type
        CHECK (
            task_type IN (
                'COMPLETE_PROFILE',
                'VERIFY_IDENTITY',
                'COMPLETE_KYC',
                'PROVIDE_DOCUMENT',
                'REPLACE_DOCUMENT',
                'SIGN_DOCUMENT',
                'PROVIDE_CONSENT',
                'UPDATE_INFORMATION',
                'ANSWER_QUESTION',
                'CONTACT_BANK',
                'VISIT_BRANCH',
                'COMPLETE_BANK_STEP',
                'REVIEW_APPLICATION',
                'REVIEW_DOCUMENT',
                'MAKE_DECISION',
                'ISSUE_CARD',
                'DELIVER_CARD',
                'ACTIVATE_CARD',
                'FOLLOW_UP',
                'RESOLVE_ERROR',
                'MANUAL_REVIEW',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_tasks_category
        CHECK (
            task_category IN (
                'CUSTOMER_ACTION',
                'BANK_ACTION',
                'PLATFORM_ACTION',
                'PARTNER_ACTION',
                'DOCUMENT',
                'IDENTITY',
                'KYC',
                'COMPLIANCE',
                'DECISION',
                'FULFILLMENT',
                'DELIVERY',
                'ACTIVATION',
                'TECHNICAL',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_tasks_status
        CHECK (
            task_status IN (
                'PENDING',
                'AVAILABLE',
                'IN_PROGRESS',
                'WAITING',
                'COMPLETED',
                'FAILED',
                'CANCELLED',
                'EXPIRED',
                'WAIVED'
            )
        ),

    CONSTRAINT chk_bank_application_tasks_priority
        CHECK (
            task_priority IN (
                'LOW',
                'NORMAL',
                'HIGH',
                'URGENT',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_bank_application_tasks_assigned_entity
        CHECK (
            assigned_entity_type IN (
                'CUSTOMER',
                'BANK',
                'PARTNER',
                'PLATFORM',
                'ADVISOR',
                'ADMIN',
                'SYSTEM',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_tasks_title
        CHECK (
            length(trim(title)) > 0
        ),

    CONSTRAINT chk_bank_application_tasks_completion_method
        CHECK (
            completion_method IS NULL
            OR completion_method IN (
                'IN_APP',
                'DOCUMENT_UPLOAD',
                'E_SIGNATURE',
                'BANK_API',
                'BANK_REDIRECT',
                'PHONE',
                'BRANCH_VISIT',
                'MANUAL',
                'AUTOMATIC',
                'WEBHOOK',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_tasks_due
        CHECK (
            due_at IS NULL
            OR due_at >= starts_at
        ),

    CONSTRAINT chk_bank_application_tasks_reminder
        CHECK (
            reminder_at IS NULL
            OR reminder_at >= starts_at
        ),

    CONSTRAINT chk_bank_application_tasks_started
        CHECK (
            started_at IS NULL
            OR started_at >= starts_at
        ),

    CONSTRAINT chk_bank_application_tasks_completed
        CHECK (
            completed_at IS NULL
            OR completed_at >= starts_at
        ),

    CONSTRAINT chk_bank_application_tasks_cancelled
        CHECK (
            cancelled_at IS NULL
            OR cancelled_at >= starts_at
        ),

    CONSTRAINT chk_bank_application_tasks_expired
        CHECK (
            expired_at IS NULL
            OR expired_at >= starts_at
        ),

    CONSTRAINT chk_bank_application_tasks_completion_code
        CHECK (
            completion_code IS NULL
            OR completion_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_bank_application_tasks_cancellation_code
        CHECK (
            cancellation_reason_code IS NULL
            OR cancellation_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_bank_application_tasks_reminder_count
        CHECK (
            reminder_count >= 0
            AND maximum_reminder_count >= 0
            AND reminder_count <= maximum_reminder_count
        ),

    CONSTRAINT chk_bank_application_tasks_document_required
        CHECK (
            requires_document = FALSE
            OR document_id IS NOT NULL
        ),

    CONSTRAINT chk_bank_application_tasks_configuration
        CHECK (
            jsonb_typeof(task_configuration) = 'object'
        ),

    CONSTRAINT chk_bank_application_tasks_completion_payload
        CHECK (
            jsonb_typeof(completion_payload) = 'object'
        ),

    CONSTRAINT chk_bank_application_tasks_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.bank_application_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    application_id UUID NOT NULL
        REFERENCES public.bank_applications(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    decision_reference TEXT NOT NULL,

    decision_type TEXT NOT NULL,

    decision_status TEXT NOT NULL,

    decision_source TEXT NOT NULL,

    decision_version INTEGER NOT NULL DEFAULT 1,

    decision_sequence INTEGER NOT NULL DEFAULT 1,

    is_final_decision BOOLEAN NOT NULL DEFAULT FALSE,

    decided_by_entity TEXT NOT NULL,

    decided_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    decision_code TEXT,

    decision_title TEXT,

    decision_reason_category TEXT,

    decision_reason_code TEXT,

    decision_reason_text TEXT,

    approved_credit_limit NUMERIC(18, 6),

    approved_credit_limit_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    approved_annual_fee NUMERIC(18, 6),

    approved_annual_fee_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    approval_probability NUMERIC(5, 2),

    risk_score NUMERIC(9, 4),

    affordability_score NUMERIC(9, 4),

    eligibility_score NUMERIC(9, 4),

    fraud_score NUMERIC(9, 4),

    confidence_score NUMERIC(5, 2),

    conditions_required BOOLEAN NOT NULL DEFAULT FALSE,

    conditions_due_at TIMESTAMPTZ,

    valid_until TIMESTAMPTZ,

    decided_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    communicated_to_customer_at TIMESTAMPTZ,

    acknowledged_by_customer_at TIMESTAMPTZ,

    decision_conditions JSONB NOT NULL DEFAULT '[]'::JSONB,

    score_breakdown JSONB NOT NULL DEFAULT '{}'::JSONB,

    policy_results JSONB NOT NULL DEFAULT '[]'::JSONB,

    decision_payload JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_bank_application_decisions_reference
        UNIQUE (
            decision_reference
        ),

    CONSTRAINT uq_bank_application_decisions_sequence
        UNIQUE (
            application_id,
            decision_sequence
        ),

    CONSTRAINT chk_bank_application_decisions_reference
        CHECK (
            decision_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_bank_application_decisions_type
        CHECK (
            decision_type IN (
                'PREQUALIFICATION',
                'PREAPPROVAL',
                'INITIAL_DECISION',
                'CONDITIONAL_DECISION',
                'FINAL_DECISION',
                'MANUAL_OVERRIDE',
                'APPEAL_DECISION',
                'RESUBMISSION_DECISION'
            )
        ),

    CONSTRAINT chk_bank_application_decisions_status
        CHECK (
            decision_status IN (
                'PENDING',
                'REFERRED',
                'PREAPPROVED',
                'CONDITIONALLY_APPROVED',
                'APPROVED',
                'REJECTED',
                'DECLINED',
                'WITHDRAWN',
                'CANCELLED',
                'EXPIRED',
                'ERROR'
            )
        ),

    CONSTRAINT chk_bank_application_decisions_source
        CHECK (
            decision_source IN (
                'BANK',
                'BANK_API',
                'BANK_USER',
                'PLATFORM_ENGINE',
                'PARTNER',
                'ADVISOR',
                'ADMIN',
                'MANUAL',
                'IMPORT',
                'TEST',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_decisions_version
        CHECK (
            decision_version > 0
        ),

    CONSTRAINT chk_bank_application_decisions_sequence_positive
        CHECK (
            decision_sequence > 0
        ),

    CONSTRAINT chk_bank_application_decisions_decided_by
        CHECK (
            decided_by_entity IN (
                'BANK',
                'BANK_USER',
                'PLATFORM',
                'PLATFORM_ENGINE',
                'PARTNER',
                'ADVISOR',
                'ADMIN',
                'SYSTEM',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_decisions_code
        CHECK (
            decision_code IS NULL
            OR decision_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_bank_application_decisions_reason_category
        CHECK (
            decision_reason_category IS NULL
            OR decision_reason_category IN (
                'ELIGIBILITY',
                'INCOME',
                'EMPLOYMENT',
                'AFFORDABILITY',
                'CREDIT_HISTORY',
                'DEBT_BURDEN',
                'IDENTITY',
                'KYC',
                'AML',
                'FRAUD',
                'DOCUMENTATION',
                'BANK_POLICY',
                'PRODUCT_POLICY',
                'MANUAL_REVIEW',
                'CUSTOMER_REQUEST',
                'TECHNICAL',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_decisions_reason_code
        CHECK (
            decision_reason_code IS NULL
            OR decision_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_bank_application_decisions_approved_limit
        CHECK (
            approved_credit_limit IS NULL
            OR approved_credit_limit >= 0
        ),

    CONSTRAINT chk_bank_application_decisions_approved_limit_currency
        CHECK (
            (
                approved_credit_limit IS NULL
                AND approved_credit_limit_currency_id IS NULL
            )
            OR
            (
                approved_credit_limit IS NOT NULL
                AND approved_credit_limit_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_bank_application_decisions_approved_fee
        CHECK (
            approved_annual_fee IS NULL
            OR approved_annual_fee >= 0
        ),

    CONSTRAINT chk_bank_application_decisions_approved_fee_currency
        CHECK (
            (
                approved_annual_fee IS NULL
                AND approved_annual_fee_currency_id IS NULL
            )
            OR
            (
                approved_annual_fee IS NOT NULL
                AND approved_annual_fee_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_bank_application_decisions_scores
        CHECK (
            (
                approval_probability IS NULL
                OR approval_probability BETWEEN 0 AND 100
            )
            AND
            (
                risk_score IS NULL
                OR risk_score BETWEEN 0 AND 100
            )
            AND
            (
                affordability_score IS NULL
                OR affordability_score BETWEEN 0 AND 100
            )
            AND
            (
                eligibility_score IS NULL
                OR eligibility_score BETWEEN 0 AND 100
            )
            AND
            (
                fraud_score IS NULL
                OR fraud_score BETWEEN 0 AND 100
            )
            AND
            (
                confidence_score IS NULL
                OR confidence_score BETWEEN 0 AND 100
            )
        ),

    CONSTRAINT chk_bank_application_decisions_conditions
        CHECK (
            conditions_required = FALSE
            OR jsonb_array_length(decision_conditions) > 0
        ),

    CONSTRAINT chk_bank_application_decisions_conditions_due
        CHECK (
            conditions_due_at IS NULL
            OR conditions_required = TRUE
        ),

    CONSTRAINT chk_bank_application_decisions_validity
        CHECK (
            valid_until IS NULL
            OR valid_until >= decided_at
        ),

    CONSTRAINT chk_bank_application_decisions_communicated
        CHECK (
            communicated_to_customer_at IS NULL
            OR communicated_to_customer_at >= decided_at
        ),

    CONSTRAINT chk_bank_application_decisions_acknowledged
        CHECK (
            acknowledged_by_customer_at IS NULL
            OR communicated_to_customer_at IS NULL
            OR acknowledged_by_customer_at >= communicated_to_customer_at
        ),

    CONSTRAINT chk_bank_application_decisions_conditions_json
        CHECK (
            jsonb_typeof(decision_conditions) = 'array'
        ),

    CONSTRAINT chk_bank_application_decisions_score_breakdown
        CHECK (
            jsonb_typeof(score_breakdown) = 'object'
        ),

    CONSTRAINT chk_bank_application_decisions_policy_results
        CHECK (
            jsonb_typeof(policy_results) = 'array'
        ),

    CONSTRAINT chk_bank_application_decisions_payload
        CHECK (
            jsonb_typeof(decision_payload) = 'object'
        ),

    CONSTRAINT chk_bank_application_decisions_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.bank_application_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    application_id UUID NOT NULL
        REFERENCES public.bank_applications(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    integration_reference TEXT NOT NULL,

    integration_type TEXT NOT NULL,

    integration_direction TEXT NOT NULL,

    integration_status TEXT NOT NULL DEFAULT 'PENDING',

    integration_provider TEXT NOT NULL,

    operation_code TEXT NOT NULL,

    endpoint_reference TEXT,

    http_method TEXT,

    request_reference TEXT,

    external_correlation_id TEXT,

    idempotency_key TEXT,

    webhook_event_reference TEXT,

    attempt_number INTEGER NOT NULL DEFAULT 1,

    maximum_attempts INTEGER NOT NULL DEFAULT 3,

    request_sent_at TIMESTAMPTZ,

    response_received_at TIMESTAMPTZ,

    processing_completed_at TIMESTAMPTZ,

    next_retry_at TIMESTAMPTZ,

    timeout_at TIMESTAMPTZ,

    http_status_code INTEGER,

    provider_status_code TEXT,

    provider_status_message TEXT,

    error_code TEXT,

    error_category TEXT,

    error_message TEXT,

    request_duration_milliseconds BIGINT,

    request_headers JSONB NOT NULL DEFAULT '{}'::JSONB,

    request_payload JSONB NOT NULL DEFAULT '{}'::JSONB,

    response_headers JSONB NOT NULL DEFAULT '{}'::JSONB,

    response_payload JSONB NOT NULL DEFAULT '{}'::JSONB,

    normalized_response JSONB NOT NULL DEFAULT '{}'::JSONB,

    error_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_bank_application_integrations_reference
        UNIQUE (
            integration_reference
        ),

    CONSTRAINT uq_bank_application_integrations_idempotency
        UNIQUE (
            integration_provider,
            idempotency_key
        ),

    CONSTRAINT chk_bank_application_integrations_reference
        CHECK (
            integration_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_bank_application_integrations_type
        CHECK (
            integration_type IN (
                'APPLICATION_SUBMISSION',
                'APPLICATION_UPDATE',
                'STATUS_INQUIRY',
                'DOCUMENT_UPLOAD',
                'DOCUMENT_VERIFICATION',
                'IDENTITY_VERIFICATION',
                'KYC_CHECK',
                'AML_CHECK',
                'FRAUD_CHECK',
                'CREDIT_CHECK',
                'OPEN_BANKING',
                'DECISION_RETRIEVAL',
                'CARD_ISSUANCE',
                'DELIVERY_TRACKING',
                'ACTIVATION',
                'WEBHOOK',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_integrations_direction
        CHECK (
            integration_direction IN (
                'OUTBOUND',
                'INBOUND',
                'BIDIRECTIONAL'
            )
        ),

    CONSTRAINT chk_bank_application_integrations_status
        CHECK (
            integration_status IN (
                'PENDING',
                'QUEUED',
                'SENDING',
                'SENT',
                'RECEIVED',
                'PROCESSING',
                'COMPLETED',
                'PARTIALLY_COMPLETED',
                'RETRY_PENDING',
                'FAILED',
                'TIMED_OUT',
                'CANCELLED',
                'IGNORED'
            )
        ),

    CONSTRAINT chk_bank_application_integrations_provider
        CHECK (
            length(trim(integration_provider)) > 0
        ),

    CONSTRAINT chk_bank_application_integrations_operation
        CHECK (
            operation_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_bank_application_integrations_http_method
        CHECK (
            http_method IS NULL
            OR http_method IN (
                'GET',
                'POST',
                'PUT',
                'PATCH',
                'DELETE'
            )
        ),

    CONSTRAINT chk_bank_application_integrations_attempts
        CHECK (
            attempt_number > 0
            AND maximum_attempts > 0
            AND attempt_number <= maximum_attempts
        ),

    CONSTRAINT chk_bank_application_integrations_response_timeline
        CHECK (
            response_received_at IS NULL
            OR request_sent_at IS NULL
            OR response_received_at >= request_sent_at
        ),

    CONSTRAINT chk_bank_application_integrations_completion_timeline
        CHECK (
            processing_completed_at IS NULL
            OR response_received_at IS NULL
            OR processing_completed_at >= response_received_at
        ),

    CONSTRAINT chk_bank_application_integrations_http_status
        CHECK (
            http_status_code IS NULL
            OR http_status_code BETWEEN 100 AND 599
        ),

    CONSTRAINT chk_bank_application_integrations_error_category
        CHECK (
            error_category IS NULL
            OR error_category IN (
                'AUTHENTICATION',
                'AUTHORIZATION',
                'VALIDATION',
                'BUSINESS_RULE',
                'RATE_LIMIT',
                'NETWORK',
                'TIMEOUT',
                'PROVIDER',
                'DATA_MAPPING',
                'DUPLICATE',
                'SECURITY',
                'UNKNOWN',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_application_integrations_duration
        CHECK (
            request_duration_milliseconds IS NULL
            OR request_duration_milliseconds >= 0
        ),

    CONSTRAINT chk_bank_application_integrations_request_headers
        CHECK (
            jsonb_typeof(request_headers) = 'object'
        ),

    CONSTRAINT chk_bank_application_integrations_request_payload
        CHECK (
            jsonb_typeof(request_payload) = 'object'
        ),

    CONSTRAINT chk_bank_application_integrations_response_headers
        CHECK (
            jsonb_typeof(response_headers) = 'object'
        ),

    CONSTRAINT chk_bank_application_integrations_response_payload
        CHECK (
            jsonb_typeof(response_payload) = 'object'
        ),

    CONSTRAINT chk_bank_application_integrations_normalized_response
        CHECK (
            jsonb_typeof(normalized_response) = 'object'
        ),

    CONSTRAINT chk_bank_application_integrations_error_details
        CHECK (
            jsonb_typeof(error_details) = 'object'
        ),

    CONSTRAINT chk_bank_application_integrations_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE INDEX idx_bank_applications_user
ON public.bank_applications(
    user_id,
    created_at DESC
)
WHERE is_deleted = FALSE;

CREATE INDEX idx_bank_applications_user_status
ON public.bank_applications(
    user_id,
    application_status,
    updated_at DESC
)
WHERE is_deleted = FALSE;

CREATE INDEX idx_bank_applications_bank
ON public.bank_applications(
    bank_id,
    application_status,
    created_at DESC
)
WHERE is_deleted = FALSE;

CREATE INDEX idx_bank_applications_card
ON public.bank_applications(
    card_id,
    application_status,
    created_at DESC
)
WHERE is_deleted = FALSE;

CREATE INDEX idx_bank_applications_recommendation_run
ON public.bank_applications(
    recommendation_run_id,
    created_at DESC
)
WHERE recommendation_run_id IS NOT NULL;

CREATE INDEX idx_bank_applications_recommendation_result
ON public.bank_applications(
    recommendation_result_id,
    created_at DESC
)
WHERE recommendation_result_id IS NOT NULL;

CREATE INDEX idx_bank_applications_comparison
ON public.bank_applications(
    comparison_id,
    created_at DESC
)
WHERE comparison_id IS NOT NULL;

CREATE INDEX idx_bank_applications_saved_card
ON public.bank_applications(
    saved_card_id,
    created_at DESC
)
WHERE saved_card_id IS NOT NULL;

CREATE INDEX idx_bank_applications_active
ON public.bank_applications(
    application_priority,
    updated_at DESC
)
WHERE application_status IN (
    'DRAFT',
    'INCOMPLETE',
    'READY_TO_SUBMIT',
    'SUBMITTING',
    'SUBMITTED',
    'RECEIVED',
    'DOCUMENTS_REQUIRED',
    'IDENTITY_VERIFICATION_REQUIRED',
    'KYC_REQUIRED',
    'UNDER_REVIEW',
    'PENDING_BANK_ACTION',
    'PENDING_CUSTOMER_ACTION',
    'PENDING_EXTERNAL_CHECK',
    'PREAPPROVED',
    'CONDITIONALLY_APPROVED',
    'APPROVED',
    'CARD_ISSUED',
    'CARD_DELIVERED'
)
  AND is_deleted = FALSE;

CREATE INDEX idx_bank_applications_pending_customer_action
ON public.bank_applications(
    next_required_action_due_at,
    application_priority
)
WHERE application_status = 'PENDING_CUSTOMER_ACTION'
  AND is_deleted = FALSE;

CREATE INDEX idx_bank_applications_pending_bank_action
ON public.bank_applications(
    bank_id,
    last_bank_action_at,
    application_priority
)
WHERE application_status IN (
    'RECEIVED',
    'UNDER_REVIEW',
    'PENDING_BANK_ACTION'
)
  AND is_deleted = FALSE;

CREATE INDEX idx_bank_applications_sla
ON public.bank_applications(
    sla_due_at,
    application_priority
)
WHERE sla_due_at IS NOT NULL
  AND sla_completed_at IS NULL
  AND is_deleted = FALSE;

CREATE INDEX idx_bank_applications_expected_decision
ON public.bank_applications(expected_decision_at)
WHERE expected_decision_at IS NOT NULL
  AND application_status NOT IN (
      'APPROVED',
      'REJECTED',
      'WITHDRAWN',
      'CANCELLED',
      'EXPIRED',
      'COMPLETED',
      'FAILED',
      'ERROR'
  )
  AND is_deleted = FALSE;

CREATE INDEX idx_bank_applications_expiring
ON public.bank_applications(expires_at)
WHERE expires_at IS NOT NULL
  AND application_status NOT IN (
      'EXPIRED',
      'COMPLETED',
      'CANCELLED',
      'WITHDRAWN'
  )
  AND is_deleted = FALSE;

CREATE INDEX idx_bank_applications_bank_reference
ON public.bank_applications(
    bank_id,
    bank_application_reference
)
WHERE bank_application_reference IS NOT NULL;

CREATE INDEX idx_bank_applications_partner_reference
ON public.bank_applications(partner_application_reference)
WHERE partner_application_reference IS NOT NULL;

CREATE INDEX idx_bank_applications_referral
ON public.bank_applications(referral_reference)
WHERE referral_reference IS NOT NULL;

CREATE INDEX idx_bank_applications_correlation
ON public.bank_applications(correlation_id)
WHERE correlation_id IS NOT NULL;

CREATE INDEX idx_bank_applications_journey
ON public.bank_applications(
    journey_reference,
    created_at DESC
)
WHERE journey_reference IS NOT NULL;

CREATE INDEX idx_bank_applications_resubmission
ON public.bank_applications(previous_application_id)
WHERE previous_application_id IS NOT NULL;

CREATE INDEX idx_bank_applications_approved
ON public.bank_applications(
    bank_id,
    approved_at DESC
)
WHERE application_status IN (
    'APPROVED',
    'CARD_ISSUED',
    'CARD_DELIVERED',
    'CARD_ACTIVATED',
    'COMPLETED'
)
  AND is_deleted = FALSE;

CREATE INDEX idx_bank_applications_rejected
ON public.bank_applications(
    bank_id,
    rejection_reason_category,
    rejected_at DESC
)
WHERE application_status = 'REJECTED'
  AND is_deleted = FALSE;

CREATE INDEX idx_bank_applications_applicant_snapshot
ON public.bank_applications
USING GIN (applicant_snapshot);

CREATE INDEX idx_bank_applications_financial_snapshot
ON public.bank_applications
USING GIN (financial_snapshot);

CREATE INDEX idx_bank_applications_card_snapshot
ON public.bank_applications
USING GIN (card_snapshot);

CREATE INDEX idx_bank_applications_application_payload
ON public.bank_applications
USING GIN (application_payload);

CREATE INDEX idx_bank_applications_risk_summary
ON public.bank_applications
USING GIN (risk_summary);

CREATE INDEX idx_bank_applications_metadata
ON public.bank_applications
USING GIN (metadata);

CREATE UNIQUE INDEX uq_bank_application_documents_current_type
ON public.bank_application_documents(
    application_id,
    document_type
)
WHERE is_current = TRUE
  AND document_status <> 'SUPERSEDED';

CREATE INDEX idx_bank_application_documents_application
ON public.bank_application_documents(
    application_id,
    document_category,
    requested_at
)
WHERE is_current = TRUE;

CREATE INDEX idx_bank_application_documents_required
ON public.bank_application_documents(
    application_id,
    required_by
)
WHERE is_required = TRUE
  AND document_status IN (
      'REQUIRED',
      'REQUESTED',
      'UPLOADING',
      'UPLOADED',
      'REJECTED'
  );

CREATE INDEX idx_bank_application_documents_verification
ON public.bank_application_documents(
    verification_status,
    verification_started_at
)
WHERE verification_status IN (
    'PENDING',
    'IN_PROGRESS',
    'PARTIALLY_VERIFIED'
);

CREATE INDEX idx_bank_application_documents_expiring
ON public.bank_application_documents(expires_at)
WHERE expires_at IS NOT NULL
  AND is_current = TRUE;

CREATE INDEX idx_bank_application_documents_storage
ON public.bank_application_documents(
    storage_provider,
    storage_bucket,
    storage_path
)
WHERE storage_path IS NOT NULL;

CREATE INDEX idx_bank_application_documents_extracted_data
ON public.bank_application_documents
USING GIN (extracted_data);

CREATE INDEX idx_bank_application_documents_verification_results
ON public.bank_application_documents
USING GIN (verification_results);

CREATE INDEX idx_bank_application_documents_metadata
ON public.bank_application_documents
USING GIN (metadata);

CREATE INDEX idx_bank_application_events_application
ON public.bank_application_events(
    application_id,
    occurred_at DESC
);

CREATE INDEX idx_bank_application_events_type
ON public.bank_application_events(
    event_type,
    occurred_at DESC
);

CREATE INDEX idx_bank_application_events_category
ON public.bank_application_events(
    event_category,
    occurred_at DESC
);

CREATE INDEX idx_bank_application_events_source
ON public.bank_application_events(
    event_source,
    occurred_at DESC
);

CREATE INDEX idx_bank_application_events_status_change
ON public.bank_application_events(
    application_id,
    occurred_at DESC
)
WHERE event_type IN (
    'STATUS_CHANGED',
    'STAGE_CHANGED'
);

CREATE INDEX idx_bank_application_events_correlation
ON public.bank_application_events(correlation_id)
WHERE correlation_id IS NOT NULL;

CREATE INDEX idx_bank_application_events_external_reference
ON public.bank_application_events(external_reference)
WHERE external_reference IS NOT NULL;

CREATE INDEX idx_bank_application_events_payload
ON public.bank_application_events
USING GIN (event_payload);

CREATE INDEX idx_bank_application_events_change_details
ON public.bank_application_events
USING GIN (change_details);

CREATE INDEX idx_bank_application_events_metadata
ON public.bank_application_events
USING GIN (metadata);

CREATE INDEX idx_bank_application_tasks_application
ON public.bank_application_tasks(
    application_id,
    task_status,
    task_priority,
    due_at
);

CREATE INDEX idx_bank_application_tasks_pending
ON public.bank_application_tasks(
    task_priority,
    due_at,
    starts_at
)
WHERE task_status IN (
    'PENDING',
    'AVAILABLE',
    'IN_PROGRESS',
    'WAITING'
);

CREATE INDEX idx_bank_application_tasks_customer
ON public.bank_application_tasks(
    application_id,
    due_at
)
WHERE assigned_entity_type = 'CUSTOMER'
  AND task_status IN (
      'PENDING',
      'AVAILABLE',
      'IN_PROGRESS',
      'WAITING'
  );

CREATE INDEX idx_bank_application_tasks_bank
ON public.bank_application_tasks(
    application_id,
    due_at
)
WHERE assigned_entity_type = 'BANK'
  AND task_status IN (
      'PENDING',
      'AVAILABLE',
      'IN_PROGRESS',
      'WAITING'
  );

CREATE INDEX idx_bank_application_tasks_document
ON public.bank_application_tasks(document_id)
WHERE document_id IS NOT NULL;

CREATE INDEX idx_bank_application_tasks_assigned_user
ON public.bank_application_tasks(
    assigned_user_id,
    task_status,
    due_at
)
WHERE assigned_user_id IS NOT NULL;

CREATE INDEX idx_bank_application_tasks_reminders
ON public.bank_application_tasks(reminder_at)
WHERE reminder_at IS NOT NULL
  AND task_status IN (
      'PENDING',
      'AVAILABLE',
      'IN_PROGRESS',
      'WAITING'
  )
  AND reminder_count < maximum_reminder_count;

CREATE INDEX idx_bank_application_tasks_blocking
ON public.bank_application_tasks(
    application_id,
    task_priority,
    due_at
)
WHERE blocks_application_progress = TRUE
  AND task_status NOT IN (
      'COMPLETED',
      'CANCELLED',
      'WAIVED'
  );

CREATE INDEX idx_bank_application_tasks_configuration
ON public.bank_application_tasks
USING GIN (task_configuration);

CREATE INDEX idx_bank_application_tasks_metadata
ON public.bank_application_tasks
USING GIN (metadata);

CREATE UNIQUE INDEX uq_bank_application_decisions_final
ON public.bank_application_decisions(application_id)
WHERE is_final_decision = TRUE;

CREATE INDEX idx_bank_application_decisions_application
ON public.bank_application_decisions(
    application_id,
    decision_sequence DESC
);

CREATE INDEX idx_bank_application_decisions_status
ON public.bank_application_decisions(
    decision_status,
    decided_at DESC
);

CREATE INDEX idx_bank_application_decisions_source
ON public.bank_application_decisions(
    decision_source,
    decided_at DESC
);

CREATE INDEX idx_bank_application_decisions_conditions_due
ON public.bank_application_decisions(conditions_due_at)
WHERE conditions_required = TRUE
  AND conditions_due_at IS NOT NULL;

CREATE INDEX idx_bank_application_decisions_valid_until
ON public.bank_application_decisions(valid_until)
WHERE valid_until IS NOT NULL;

CREATE INDEX idx_bank_application_decisions_conditions
ON public.bank_application_decisions
USING GIN (decision_conditions);

CREATE INDEX idx_bank_application_decisions_score_breakdown
ON public.bank_application_decisions
USING GIN (score_breakdown);

CREATE INDEX idx_bank_application_decisions_policy_results
ON public.bank_application_decisions
USING GIN (policy_results);

CREATE INDEX idx_bank_application_decisions_metadata
ON public.bank_application_decisions
USING GIN (metadata);

CREATE INDEX idx_bank_application_integrations_application
ON public.bank_application_integrations(
    application_id,
    created_at DESC
);

CREATE INDEX idx_bank_application_integrations_pending
ON public.bank_application_integrations(
    integration_provider,
    integration_status,
    created_at
)
WHERE integration_status IN (
    'PENDING',
    'QUEUED',
    'SENDING',
    'SENT',
    'RECEIVED',
    'PROCESSING',
    'RETRY_PENDING'
);

CREATE INDEX idx_bank_application_integrations_retry
ON public.bank_application_integrations(
    next_retry_at,
    integration_provider
)
WHERE integration_status = 'RETRY_PENDING'
  AND attempt_number < maximum_attempts;

CREATE INDEX idx_bank_application_integrations_provider
ON public.bank_application_integrations(
    integration_provider,
    operation_code,
    created_at DESC
);

CREATE INDEX idx_bank_application_integrations_external_correlation
ON public.bank_application_integrations(external_correlation_id)
WHERE external_correlation_id IS NOT NULL;

CREATE INDEX idx_bank_application_integrations_request_reference
ON public.bank_application_integrations(request_reference)
WHERE request_reference IS NOT NULL;

CREATE INDEX idx_bank_application_integrations_webhook
ON public.bank_application_integrations(webhook_event_reference)
WHERE webhook_event_reference IS NOT NULL;

CREATE INDEX idx_bank_application_integrations_failed
ON public.bank_application_integrations(
    error_category,
    error_code,
    created_at DESC
)
WHERE integration_status IN (
    'FAILED',
    'TIMED_OUT'
);

CREATE INDEX idx_bank_application_integrations_request_payload
ON public.bank_application_integrations
USING GIN (request_payload);

CREATE INDEX idx_bank_application_integrations_response_payload
ON public.bank_application_integrations
USING GIN (response_payload);

CREATE INDEX idx_bank_application_integrations_normalized_response
ON public.bank_application_integrations
USING GIN (normalized_response);

CREATE INDEX idx_bank_application_integrations_error_details
ON public.bank_application_integrations
USING GIN (error_details);

CREATE INDEX idx_bank_application_integrations_metadata
ON public.bank_application_integrations
USING GIN (metadata);

CREATE TRIGGER trg_bank_applications_updated_at
BEFORE UPDATE
ON public.bank_applications
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_bank_application_documents_updated_at
BEFORE UPDATE
ON public.bank_application_documents
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_bank_application_tasks_updated_at
BEFORE UPDATE
ON public.bank_application_tasks
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_bank_application_decisions_updated_at
BEFORE UPDATE
ON public.bank_application_decisions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_bank_application_integrations_updated_at
BEFORE UPDATE
ON public.bank_application_integrations
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.bank_applications IS
'Credit-card application records covering customer initiation, consent, submission, bank review, decision, issuance, delivery, activation, and completion.';

COMMENT ON COLUMN public.bank_applications.application_reference IS
'Unique public-safe platform identifier for the bank application.';

COMMENT ON COLUMN public.bank_applications.bank_application_reference IS
'Application identifier assigned by the receiving bank.';

COMMENT ON COLUMN public.bank_applications.referral_reference IS
'Reference connecting the application to an affiliate, referral, campaign, or acquisition journey.';

COMMENT ON COLUMN public.bank_applications.application_status IS
'Current detailed lifecycle status of the application.';

COMMENT ON COLUMN public.bank_applications.application_stage IS
'Current high-level application journey stage used for progress tracking.';

COMMENT ON COLUMN public.bank_applications.estimated_approval_probability IS
'Estimated likelihood of approval calculated before or during submission.';

COMMENT ON COLUMN public.bank_applications.applicant_snapshot IS
'Historical applicant-data snapshot captured when the application was created or submitted.';

COMMENT ON COLUMN public.bank_applications.bank_response_summary IS
'Normalized summary of the latest material response received from the bank.';

COMMENT ON TABLE public.bank_application_documents IS
'Documents requested, uploaded, submitted, verified, rejected, expired, or superseded during a bank application.';

COMMENT ON COLUMN public.bank_application_documents.storage_path IS
'Secure object-storage path; the database record does not contain the document binary.';

COMMENT ON COLUMN public.bank_application_documents.extracted_data IS
'Structured information extracted from the document by OCR or another document-processing service.';

COMMENT ON TABLE public.bank_application_events IS
'Immutable-style timeline of application events, status changes, customer actions, bank actions, decisions, integrations, and errors.';

COMMENT ON COLUMN public.bank_application_events.change_details IS
'Structured before-and-after values associated with the application event.';

COMMENT ON TABLE public.bank_application_tasks IS
'Action items assigned to customers, banks, partners, advisors, administrators, or platform services during the application lifecycle.';

COMMENT ON COLUMN public.bank_application_tasks.blocks_application_progress IS
'Indicates that the application cannot move to the next stage until this task is completed or waived.';

COMMENT ON TABLE public.bank_application_decisions IS
'Prequalification, preapproval, conditional, final, manual, and appeal decisions associated with a bank application.';

COMMENT ON COLUMN public.bank_application_decisions.is_final_decision IS
'Identifies the authoritative final decision for the application.';

COMMENT ON COLUMN public.bank_application_decisions.policy_results IS
'Structured results from bank policies, eligibility rules, affordability rules, and risk checks.';

COMMENT ON TABLE public.bank_application_integrations IS
'Inbound and outbound bank, partner, identity, compliance, open-banking, document, decision, and fulfillment integration transactions.';

COMMENT ON COLUMN public.bank_application_integrations.idempotency_key IS
'Provider-scoped key used to prevent duplicate external operations.';

COMMENT ON COLUMN public.bank_application_integrations.normalized_response IS
'Provider-independent representation of the external response used by the application engine.';
