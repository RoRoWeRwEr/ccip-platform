CREATE TABLE public.recommendation_outcomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    recommendation_run_id UUID NOT NULL
        REFERENCES public.recommendation_runs(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_result_id UUID
        REFERENCES public.recommendation_results(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_run_card_id UUID
        REFERENCES public.recommendation_run_cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_interaction_id UUID
        REFERENCES public.recommendation_interactions(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_feedback_id UUID
        REFERENCES public.recommendation_feedback(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    bank_id UUID
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    financial_profile_id UUID
        REFERENCES public.customer_financial_profiles(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    outcome_reference TEXT NOT NULL,

    external_application_reference TEXT,

    partner_reference TEXT,

    bank_application_reference TEXT,

    attribution_reference TEXT,

    correlation_id TEXT,

    idempotency_key TEXT,

    outcome_type TEXT NOT NULL,

    outcome_status TEXT NOT NULL DEFAULT 'PENDING',

    outcome_source TEXT NOT NULL DEFAULT 'PLATFORM',

    outcome_channel TEXT,

    application_status TEXT,

    application_decision TEXT,

    application_rejection_reason_code TEXT,

    application_rejection_reason_text TEXT,

    approval_type TEXT,

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

    issued_card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    issued_card_variant TEXT,

    application_started_at TIMESTAMPTZ,

    application_submitted_at TIMESTAMPTZ,

    application_received_at TIMESTAMPTZ,

    documents_requested_at TIMESTAMPTZ,

    documents_completed_at TIMESTAMPTZ,

    decision_at TIMESTAMPTZ,

    approved_at TIMESTAMPTZ,

    rejected_at TIMESTAMPTZ,

    withdrawn_at TIMESTAMPTZ,

    expired_at TIMESTAMPTZ,

    card_issued_at TIMESTAMPTZ,

    card_delivered_at TIMESTAMPTZ,

    card_activated_at TIMESTAMPTZ,

    first_transaction_at TIMESTAMPTZ,

    outcome_occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    outcome_received_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    outcome_processed_at TIMESTAMPTZ,

    attribution_model TEXT NOT NULL DEFAULT 'LAST_RECOMMENDATION',

    attribution_status TEXT NOT NULL DEFAULT 'ATTRIBUTED',

    attribution_confidence_score NUMERIC(5, 2),

    attribution_window_days INTEGER,

    is_attributed_to_platform BOOLEAN NOT NULL DEFAULT TRUE,

    is_attributed_to_recommendation BOOLEAN NOT NULL DEFAULT TRUE,

    is_top_recommendation_selected BOOLEAN,

    selected_recommendation_rank INTEGER,

    selected_recommendation_score NUMERIC(9, 4),

    selected_expected_net_value NUMERIC(18, 6),

    selected_value_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    recommendation_match_status TEXT,

    recommendation_accuracy_score NUMERIC(5, 2),

    recommendation_success BOOLEAN,

    eligibility_prediction_correct BOOLEAN,

    approval_prediction_correct BOOLEAN,

    expected_value_prediction_validated BOOLEAN,

    actual_first_year_reward_value NUMERIC(18, 6),

    actual_first_year_benefit_value NUMERIC(18, 6),

    actual_first_year_cost NUMERIC(18, 6),

    actual_first_year_net_value NUMERIC(18, 6),

    actual_value_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    expected_first_year_net_value NUMERIC(18, 6),

    expected_value_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    net_value_variance NUMERIC(18, 6),

    net_value_variance_percentage NUMERIC(9, 4),

    commission_status TEXT NOT NULL DEFAULT 'NOT_APPLICABLE',

    commission_type TEXT,

    commission_amount NUMERIC(18, 6),

    commission_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    commission_rate NUMERIC(9, 6),

    commission_eligible_at TIMESTAMPTZ,

    commission_confirmed_at TIMESTAMPTZ,

    commission_invoiced_at TIMESTAMPTZ,

    commission_paid_at TIMESTAMPTZ,

    commission_reversed_at TIMESTAMPTZ,

    commission_reversal_reason TEXT,

    partner_settlement_reference TEXT,

    partner_name TEXT,

    partner_type TEXT,

    reconciliation_status TEXT NOT NULL DEFAULT 'NOT_REQUIRED',

    reconciliation_batch_reference TEXT,

    reconciliation_difference_amount NUMERIC(18, 6),

    reconciliation_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    reconciled_at TIMESTAMPTZ,

    reconciled_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    manual_review_required BOOLEAN NOT NULL DEFAULT FALSE,

    manual_review_status TEXT,

    manual_review_reason TEXT,

    reviewed_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    reviewed_at TIMESTAMPTZ,

    is_final BOOLEAN NOT NULL DEFAULT FALSE,

    finalized_at TIMESTAMPTZ,

    is_test BOOLEAN NOT NULL DEFAULT FALSE,

    source_payload JSONB NOT NULL DEFAULT '{}'::JSONB,

    attribution_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    application_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    financial_outcome_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    reconciliation_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    validation_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    processing_errors JSONB NOT NULL DEFAULT '[]'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_recommendation_outcomes_reference
        UNIQUE (
            outcome_reference
        ),

    CONSTRAINT uq_recommendation_outcomes_idempotency
        UNIQUE (
            idempotency_key
        ),

    CONSTRAINT chk_recommendation_outcomes_reference
        CHECK (
            outcome_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_recommendation_outcomes_external_application_reference
        CHECK (
            external_application_reference IS NULL
            OR length(trim(external_application_reference)) > 0
        ),

    CONSTRAINT chk_recommendation_outcomes_partner_reference
        CHECK (
            partner_reference IS NULL
            OR length(trim(partner_reference)) > 0
        ),

    CONSTRAINT chk_recommendation_outcomes_bank_application_reference
        CHECK (
            bank_application_reference IS NULL
            OR length(trim(bank_application_reference)) > 0
        ),

    CONSTRAINT chk_recommendation_outcomes_type
        CHECK (
            outcome_type IN (
                'APPLICATION_STARTED',
                'APPLICATION_SUBMITTED',
                'APPLICATION_RECEIVED',
                'ADDITIONAL_DOCUMENTS_REQUESTED',
                'ADDITIONAL_DOCUMENTS_SUBMITTED',
                'APPLICATION_UNDER_REVIEW',
                'APPLICATION_APPROVED',
                'APPLICATION_CONDITIONALLY_APPROVED',
                'APPLICATION_REJECTED',
                'APPLICATION_WITHDRAWN',
                'APPLICATION_EXPIRED',
                'CARD_ISSUED',
                'CARD_DELIVERED',
                'CARD_ACTIVATED',
                'FIRST_TRANSACTION_COMPLETED',
                'CARD_ACQUIRED',
                'CARD_NOT_ACQUIRED',
                'COMMISSION_ELIGIBLE',
                'COMMISSION_CONFIRMED',
                'COMMISSION_INVOICED',
                'COMMISSION_PAID',
                'COMMISSION_REVERSED',
                'RECONCILIATION_COMPLETED',
                'OUTCOME_CORRECTED',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_status
        CHECK (
            outcome_status IN (
                'PENDING',
                'RECEIVED',
                'PROCESSING',
                'CONFIRMED',
                'COMPLETED',
                'FAILED',
                'CANCELLED',
                'REVERSED',
                'DISPUTED',
                'CORRECTED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_source
        CHECK (
            outcome_source IN (
                'PLATFORM',
                'CUSTOMER',
                'BANK',
                'PARTNER',
                'OPEN_BANKING',
                'API',
                'WEBHOOK',
                'BATCH_IMPORT',
                'MANUAL',
                'ADVISOR',
                'ADMIN',
                'RECONCILIATION',
                'TEST',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_application_status
        CHECK (
            application_status IS NULL
            OR application_status IN (
                'NOT_STARTED',
                'STARTED',
                'IN_PROGRESS',
                'SUBMITTED',
                'RECEIVED',
                'DOCUMENTS_REQUIRED',
                'DOCUMENTS_PENDING',
                'UNDER_REVIEW',
                'APPROVED',
                'CONDITIONALLY_APPROVED',
                'REJECTED',
                'WITHDRAWN',
                'EXPIRED',
                'CANCELLED',
                'CARD_ISSUED',
                'COMPLETED',
                'UNKNOWN'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_application_decision
        CHECK (
            application_decision IS NULL
            OR application_decision IN (
                'APPROVED',
                'CONDITIONALLY_APPROVED',
                'REJECTED',
                'REFERRED',
                'PENDING',
                'WITHDRAWN',
                'EXPIRED',
                'CANCELLED',
                'UNKNOWN'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_rejection_reason_code
        CHECK (
            application_rejection_reason_code IS NULL
            OR application_rejection_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_outcomes_approval_type
        CHECK (
            approval_type IS NULL
            OR approval_type IN (
                'AUTOMATIC',
                'MANUAL',
                'CONDITIONAL',
                'PRE_APPROVED',
                'SECURED',
                'REFERRED',
                'UNKNOWN'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_credit_limit
        CHECK (
            approved_credit_limit IS NULL
            OR approved_credit_limit >= 0
        ),

    CONSTRAINT chk_recommendation_outcomes_credit_limit_currency
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

    CONSTRAINT chk_recommendation_outcomes_annual_fee
        CHECK (
            approved_annual_fee IS NULL
            OR approved_annual_fee >= 0
        ),

    CONSTRAINT chk_recommendation_outcomes_annual_fee_currency
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

    CONSTRAINT chk_recommendation_outcomes_application_timeline
        CHECK (
            application_submitted_at IS NULL
            OR application_started_at IS NULL
            OR application_submitted_at >= application_started_at
        ),

    CONSTRAINT chk_recommendation_outcomes_received_timeline
        CHECK (
            application_received_at IS NULL
            OR application_submitted_at IS NULL
            OR application_received_at >= application_submitted_at
        ),

    CONSTRAINT chk_recommendation_outcomes_documents_timeline
        CHECK (
            documents_completed_at IS NULL
            OR documents_requested_at IS NULL
            OR documents_completed_at >= documents_requested_at
        ),

    CONSTRAINT chk_recommendation_outcomes_decision_timeline
        CHECK (
            decision_at IS NULL
            OR application_received_at IS NULL
            OR decision_at >= application_received_at
        ),

    CONSTRAINT chk_recommendation_outcomes_approved_timeline
        CHECK (
            approved_at IS NULL
            OR decision_at IS NULL
            OR approved_at >= decision_at
        ),

    CONSTRAINT chk_recommendation_outcomes_rejected_timeline
        CHECK (
            rejected_at IS NULL
            OR decision_at IS NULL
            OR rejected_at >= decision_at
        ),

    CONSTRAINT chk_recommendation_outcomes_issue_timeline
        CHECK (
            card_issued_at IS NULL
            OR approved_at IS NULL
            OR card_issued_at >= approved_at
        ),

    CONSTRAINT chk_recommendation_outcomes_delivery_timeline
        CHECK (
            card_delivered_at IS NULL
            OR card_issued_at IS NULL
            OR card_delivered_at >= card_issued_at
        ),

    CONSTRAINT chk_recommendation_outcomes_activation_timeline
        CHECK (
            card_activated_at IS NULL
            OR card_issued_at IS NULL
            OR card_activated_at >= card_issued_at
        ),

    CONSTRAINT chk_recommendation_outcomes_first_transaction_timeline
        CHECK (
            first_transaction_at IS NULL
            OR card_activated_at IS NULL
            OR first_transaction_at >= card_activated_at
        ),

    CONSTRAINT chk_recommendation_outcomes_received
        CHECK (
            outcome_received_at >= outcome_occurred_at
        ),

    CONSTRAINT chk_recommendation_outcomes_processed
        CHECK (
            outcome_processed_at IS NULL
            OR outcome_processed_at >= outcome_received_at
        ),

    CONSTRAINT chk_recommendation_outcomes_attribution_model
        CHECK (
            attribution_model IN (
                'FIRST_RECOMMENDATION',
                'LAST_RECOMMENDATION',
                'FIRST_INTERACTION',
                'LAST_INTERACTION',
                'LINEAR',
                'POSITION_BASED',
                'TIME_DECAY',
                'DIRECT',
                'MANUAL',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_attribution_status
        CHECK (
            attribution_status IN (
                'ATTRIBUTED',
                'PARTIALLY_ATTRIBUTED',
                'UNATTRIBUTED',
                'PENDING',
                'DISPUTED',
                'REJECTED',
                'MANUALLY_ASSIGNED'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_attribution_confidence
        CHECK (
            attribution_confidence_score IS NULL
            OR attribution_confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_outcomes_attribution_window
        CHECK (
            attribution_window_days IS NULL
            OR attribution_window_days >= 0
        ),

    CONSTRAINT chk_recommendation_outcomes_selected_rank
        CHECK (
            selected_recommendation_rank IS NULL
            OR selected_recommendation_rank > 0
        ),

    CONSTRAINT chk_recommendation_outcomes_selected_score
        CHECK (
            selected_recommendation_score IS NULL
            OR selected_recommendation_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_outcomes_selected_value_currency
        CHECK (
            (
                selected_expected_net_value IS NULL
                AND selected_value_currency_id IS NULL
            )
            OR
            (
                selected_expected_net_value IS NOT NULL
                AND selected_value_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_match_status
        CHECK (
            recommendation_match_status IS NULL
            OR recommendation_match_status IN (
                'TOP_RECOMMENDATION_SELECTED',
                'RECOMMENDED_ALTERNATIVE_SELECTED',
                'NON_RECOMMENDED_PLATFORM_CARD_SELECTED',
                'EXTERNAL_CARD_SELECTED',
                'NO_CARD_SELECTED',
                'APPLICATION_REJECTED',
                'APPLICATION_WITHDRAWN',
                'UNKNOWN'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_accuracy_score
        CHECK (
            recommendation_accuracy_score IS NULL
            OR recommendation_accuracy_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_outcomes_actual_values
        CHECK (
            (
                actual_first_year_reward_value IS NULL
                OR actual_first_year_reward_value >= 0
            )
            AND
            (
                actual_first_year_benefit_value IS NULL
                OR actual_first_year_benefit_value >= 0
            )
            AND
            (
                actual_first_year_cost IS NULL
                OR actual_first_year_cost >= 0
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_actual_currency
        CHECK (
            (
                actual_first_year_reward_value IS NULL
                AND actual_first_year_benefit_value IS NULL
                AND actual_first_year_cost IS NULL
                AND actual_first_year_net_value IS NULL
                AND actual_value_currency_id IS NULL
            )
            OR
            (
                actual_value_currency_id IS NOT NULL
                AND (
                    actual_first_year_reward_value IS NOT NULL
                    OR actual_first_year_benefit_value IS NOT NULL
                    OR actual_first_year_cost IS NOT NULL
                    OR actual_first_year_net_value IS NOT NULL
                )
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_expected_currency
        CHECK (
            (
                expected_first_year_net_value IS NULL
                AND expected_value_currency_id IS NULL
            )
            OR
            (
                expected_first_year_net_value IS NOT NULL
                AND expected_value_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_variance_percentage
        CHECK (
            net_value_variance_percentage IS NULL
            OR net_value_variance_percentage BETWEEN -100000 AND 100000
        ),

    CONSTRAINT chk_recommendation_outcomes_commission_status
        CHECK (
            commission_status IN (
                'NOT_APPLICABLE',
                'PENDING_ELIGIBILITY',
                'ELIGIBLE',
                'CONFIRMED',
                'INVOICED',
                'PAID',
                'PARTIALLY_PAID',
                'REVERSED',
                'DISPUTED',
                'REJECTED',
                'EXPIRED'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_commission_type
        CHECK (
            commission_type IS NULL
            OR commission_type IN (
                'FIXED',
                'PERCENTAGE',
                'TIERED',
                'HYBRID',
                'LEAD_FEE',
                'APPLICATION_FEE',
                'APPROVAL_FEE',
                'ACTIVATION_FEE',
                'FIRST_TRANSACTION_FEE',
                'REVENUE_SHARE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_commission_amount
        CHECK (
            commission_amount IS NULL
            OR commission_amount >= 0
        ),

    CONSTRAINT chk_recommendation_outcomes_commission_currency
        CHECK (
            (
                commission_amount IS NULL
                AND commission_currency_id IS NULL
            )
            OR
            (
                commission_amount IS NOT NULL
                AND commission_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_commission_rate
        CHECK (
            commission_rate IS NULL
            OR commission_rate BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_outcomes_commission_timeline
        CHECK (
            (
                commission_confirmed_at IS NULL
                OR commission_eligible_at IS NULL
                OR commission_confirmed_at >= commission_eligible_at
            )
            AND
            (
                commission_invoiced_at IS NULL
                OR commission_confirmed_at IS NULL
                OR commission_invoiced_at >= commission_confirmed_at
            )
            AND
            (
                commission_paid_at IS NULL
                OR commission_invoiced_at IS NULL
                OR commission_paid_at >= commission_invoiced_at
            )
            AND
            (
                commission_reversed_at IS NULL
                OR commission_confirmed_at IS NULL
                OR commission_reversed_at >= commission_confirmed_at
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_partner_type
        CHECK (
            partner_type IS NULL
            OR partner_type IN (
                'BANK',
                'FINANCIAL_INSTITUTION',
                'CARD_ISSUER',
                'AFFILIATE_NETWORK',
                'LEAD_AGGREGATOR',
                'LOYALTY_PROGRAM',
                'FINTECH',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_reconciliation_status
        CHECK (
            reconciliation_status IN (
                'NOT_REQUIRED',
                'PENDING',
                'MATCHED',
                'PARTIALLY_MATCHED',
                'MISMATCHED',
                'DISPUTED',
                'RESOLVED',
                'FAILED'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_reconciliation_currency
        CHECK (
            (
                reconciliation_difference_amount IS NULL
                AND reconciliation_currency_id IS NULL
            )
            OR
            (
                reconciliation_difference_amount IS NOT NULL
                AND reconciliation_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_manual_review_status
        CHECK (
            manual_review_status IS NULL
            OR manual_review_status IN (
                'PENDING',
                'IN_PROGRESS',
                'VALIDATED',
                'CORRECTED',
                'REJECTED',
                'ESCALATED',
                'COMPLETED'
            )
        ),

    CONSTRAINT chk_recommendation_outcomes_manual_review_required
        CHECK (
            manual_review_required = FALSE
            OR manual_review_status IS NOT NULL
        ),

    CONSTRAINT chk_recommendation_outcomes_reviewed
        CHECK (
            reviewed_by IS NULL
            OR reviewed_at IS NOT NULL
        ),

    CONSTRAINT chk_recommendation_outcomes_reviewed_timeline
        CHECK (
            reviewed_at IS NULL
            OR reviewed_at >= outcome_received_at
        ),

    CONSTRAINT chk_recommendation_outcomes_finalized
        CHECK (
            is_final = FALSE
            OR finalized_at IS NOT NULL
        ),

    CONSTRAINT chk_recommendation_outcomes_finalized_timeline
        CHECK (
            finalized_at IS NULL
            OR finalized_at >= outcome_received_at
        ),

    CONSTRAINT chk_recommendation_outcomes_source_payload
        CHECK (
            jsonb_typeof(source_payload) = 'object'
        ),

    CONSTRAINT chk_recommendation_outcomes_attribution_details
        CHECK (
            jsonb_typeof(attribution_details) = 'object'
        ),

    CONSTRAINT chk_recommendation_outcomes_application_details
        CHECK (
            jsonb_typeof(application_details) = 'object'
        ),

    CONSTRAINT chk_recommendation_outcomes_financial_details
        CHECK (
            jsonb_typeof(financial_outcome_details) = 'object'
        ),

    CONSTRAINT chk_recommendation_outcomes_reconciliation_details
        CHECK (
            jsonb_typeof(reconciliation_details) = 'object'
        ),

    CONSTRAINT chk_recommendation_outcomes_validation_details
        CHECK (
            jsonb_typeof(validation_details) = 'object'
        ),

    CONSTRAINT chk_recommendation_outcomes_processing_errors
        CHECK (
            jsonb_typeof(processing_errors) = 'array'
        ),

    CONSTRAINT chk_recommendation_outcomes_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE INDEX idx_recommendation_outcomes_run
ON public.recommendation_outcomes(
    recommendation_run_id,
    outcome_occurred_at DESC
);

CREATE INDEX idx_recommendation_outcomes_result
ON public.recommendation_outcomes(
    recommendation_result_id,
    outcome_occurred_at DESC
)
WHERE recommendation_result_id IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_run_card
ON public.recommendation_outcomes(
    recommendation_run_card_id,
    outcome_occurred_at DESC
)
WHERE recommendation_run_card_id IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_interaction
ON public.recommendation_outcomes(recommendation_interaction_id)
WHERE recommendation_interaction_id IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_feedback
ON public.recommendation_outcomes(recommendation_feedback_id)
WHERE recommendation_feedback_id IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_card
ON public.recommendation_outcomes(
    card_id,
    outcome_occurred_at DESC
)
WHERE card_id IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_bank
ON public.recommendation_outcomes(
    bank_id,
    outcome_occurred_at DESC
)
WHERE bank_id IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_profile
ON public.recommendation_outcomes(
    financial_profile_id,
    outcome_occurred_at DESC
)
WHERE financial_profile_id IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_user
ON public.recommendation_outcomes(
    user_id,
    outcome_occurred_at DESC
)
WHERE user_id IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_type
ON public.recommendation_outcomes(
    outcome_type,
    outcome_occurred_at DESC
);

CREATE INDEX idx_recommendation_outcomes_status
ON public.recommendation_outcomes(
    outcome_status,
    outcome_received_at
);

CREATE INDEX idx_recommendation_outcomes_application_status
ON public.recommendation_outcomes(
    application_status,
    outcome_occurred_at DESC
)
WHERE application_status IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_application_decision
ON public.recommendation_outcomes(
    application_decision,
    decision_at DESC
)
WHERE application_decision IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_external_application
ON public.recommendation_outcomes(external_application_reference)
WHERE external_application_reference IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_bank_application
ON public.recommendation_outcomes(bank_application_reference)
WHERE bank_application_reference IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_partner_reference
ON public.recommendation_outcomes(partner_reference)
WHERE partner_reference IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_correlation
ON public.recommendation_outcomes(correlation_id)
WHERE correlation_id IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_pending_processing
ON public.recommendation_outcomes(outcome_received_at)
WHERE outcome_processed_at IS NULL;

CREATE INDEX idx_recommendation_outcomes_approved
ON public.recommendation_outcomes(
    bank_id,
    approved_at DESC
)
WHERE application_decision IN (
    'APPROVED',
    'CONDITIONALLY_APPROVED'
);

CREATE INDEX idx_recommendation_outcomes_rejected
ON public.recommendation_outcomes(
    bank_id,
    rejected_at DESC
)
WHERE application_decision = 'REJECTED';

CREATE INDEX idx_recommendation_outcomes_card_activated
ON public.recommendation_outcomes(
    card_id,
    card_activated_at DESC
)
WHERE card_activated_at IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_success
ON public.recommendation_outcomes(
    recommendation_success,
    outcome_occurred_at DESC
)
WHERE recommendation_success IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_match_status
ON public.recommendation_outcomes(
    recommendation_match_status,
    outcome_occurred_at DESC
)
WHERE recommendation_match_status IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_accuracy
ON public.recommendation_outcomes(
    recommendation_accuracy_score DESC,
    outcome_occurred_at DESC
)
WHERE recommendation_accuracy_score IS NOT NULL;

CREATE INDEX idx_recommendation_outcomes_commission_status
ON public.recommendation_outcomes(
    commission_status,
    commission_eligible_at
)
WHERE commission_status <> 'NOT_APPLICABLE';

CREATE INDEX idx_recommendation_outcomes_commission_paid
ON public.recommendation_outcomes(
    commission_paid_at DESC,
    commission_amount DESC
)
WHERE commission_status = 'PAID';

CREATE INDEX idx_recommendation_outcomes_reconciliation
ON public.recommendation_outcomes(
    reconciliation_status,
    outcome_received_at
)
WHERE reconciliation_status NOT IN (
    'NOT_REQUIRED',
    'MATCHED',
    'RESOLVED'
);

CREATE INDEX idx_recommendation_outcomes_manual_review
ON public.recommendation_outcomes(
    manual_review_status,
    outcome_received_at
)
WHERE manual_review_required = TRUE;

CREATE INDEX idx_recommendation_outcomes_unfinalized
ON public.recommendation_outcomes(outcome_received_at)
WHERE is_final = FALSE;

CREATE INDEX idx_recommendation_outcomes_attributed
ON public.recommendation_outcomes(
    recommendation_run_id,
    attribution_status
)
WHERE is_attributed_to_recommendation = TRUE;

CREATE INDEX idx_recommendation_outcomes_source_payload
ON public.recommendation_outcomes
USING GIN (source_payload);

CREATE INDEX idx_recommendation_outcomes_attribution_details
ON public.recommendation_outcomes
USING GIN (attribution_details);

CREATE INDEX idx_recommendation_outcomes_application_details
ON public.recommendation_outcomes
USING GIN (application_details);

CREATE INDEX idx_recommendation_outcomes_financial_details
ON public.recommendation_outcomes
USING GIN (financial_outcome_details);

CREATE INDEX idx_recommendation_outcomes_reconciliation_details
ON public.recommendation_outcomes
USING GIN (reconciliation_details);

CREATE INDEX idx_recommendation_outcomes_validation_details
ON public.recommendation_outcomes
USING GIN (validation_details);

CREATE INDEX idx_recommendation_outcomes_processing_errors
ON public.recommendation_outcomes
USING GIN (processing_errors);

CREATE INDEX idx_recommendation_outcomes_metadata
ON public.recommendation_outcomes
USING GIN (metadata);

CREATE TRIGGER trg_recommendation_outcomes_updated_at
BEFORE UPDATE
ON public.recommendation_outcomes
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.recommendation_outcomes IS
'Stores verified real-world outcomes following a card recommendation, including applications, approval decisions, card issuance, activation, financial value validation, commissions, and partner reconciliation.';

COMMENT ON COLUMN public.recommendation_outcomes.outcome_reference IS
'Unique public-safe identifier assigned to the outcome event.';

COMMENT ON COLUMN public.recommendation_outcomes.external_application_reference IS
'Application reference received from a bank, partner, affiliate platform, or external application system.';

COMMENT ON COLUMN public.recommendation_outcomes.outcome_type IS
'Business event representing the real-world result following a recommendation or application journey.';

COMMENT ON COLUMN public.recommendation_outcomes.application_decision IS
'Final or interim decision received from the issuing bank or financial partner.';

COMMENT ON COLUMN public.recommendation_outcomes.recommendation_match_status IS
'Describes whether the customer selected the top recommendation, another recommended card, a non-recommended card, or no card.';

COMMENT ON COLUMN public.recommendation_outcomes.recommendation_accuracy_score IS
'Outcome-based score indicating how accurately the recommendation predicted the customer selection, eligibility, approval, and realized financial value.';

COMMENT ON COLUMN public.recommendation_outcomes.actual_first_year_net_value IS
'Observed first-year net financial value after actual rewards, benefits, fees, and other costs become available.';

COMMENT ON COLUMN public.recommendation_outcomes.net_value_variance IS
'Difference between actual and expected first-year net value.';

COMMENT ON COLUMN public.recommendation_outcomes.commission_amount IS
'Referral, acquisition, activation, revenue-share, or other commission associated with the attributed customer outcome.';

COMMENT ON COLUMN public.recommendation_outcomes.reconciliation_status IS
'Status of matching the platform outcome and commission record with partner or bank settlement records.';

COMMENT ON COLUMN public.recommendation_outcomes.is_final IS
'Indicates that the outcome has reached a finalized state and is no longer expected to receive ordinary lifecycle updates.';

COMMENT ON COLUMN public.recommendation_outcomes.source_payload IS
'Normalized copy of the external or internal payload from which the outcome record was generated.';

COMMENT ON COLUMN public.recommendation_outcomes.attribution_details IS
'Structured information explaining how the outcome was attributed to a recommendation, interaction, campaign, or platform channel.';

COMMENT ON COLUMN public.recommendation_outcomes.financial_outcome_details IS
'Structured financial details used to validate realized customer value, commissions, and commercial performance.';

COMMENT ON COLUMN public.recommendation_outcomes.validation_details IS
'Structured checks confirming outcome authenticity, consistency, eligibility prediction accuracy, and recommendation success.';
