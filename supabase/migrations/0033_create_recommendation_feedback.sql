CREATE TABLE public.recommendation_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    recommendation_run_id UUID NOT NULL
        REFERENCES public.recommendation_runs(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_result_id UUID
        REFERENCES public.recommendation_results(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_run_card_id UUID
        REFERENCES public.recommendation_run_cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    card_id UUID
        REFERENCES public.cards(id)
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

    interaction_reference TEXT NOT NULL,

    interaction_type TEXT NOT NULL,

    interaction_source TEXT NOT NULL DEFAULT 'WEB_APPLICATION',

    interaction_channel TEXT,

    interaction_context TEXT,

    session_reference TEXT,

    journey_reference TEXT,

    correlation_id TEXT,

    idempotency_key TEXT,

    recommendation_rank_at_interaction INTEGER,

    recommendation_score_at_interaction NUMERIC(9, 4),

    expected_net_value_at_interaction NUMERIC(18, 6),

    value_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    interaction_value NUMERIC(18, 6),

    interaction_value_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    page_code TEXT,

    component_code TEXT,

    placement_code TEXT,

    call_to_action_code TEXT,

    destination_type TEXT,

    destination_reference TEXT,

    destination_url TEXT,

    comparison_card_ids UUID[],

    duration_ms BIGINT,

    sequence_number INTEGER,

    occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    received_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    processed_at TIMESTAMPTZ,

    is_authenticated BOOLEAN NOT NULL DEFAULT FALSE,

    is_customer_initiated BOOLEAN NOT NULL DEFAULT TRUE,

    is_conversion_event BOOLEAN NOT NULL DEFAULT FALSE,

    is_unique_interaction BOOLEAN NOT NULL DEFAULT TRUE,

    device_type TEXT,

    operating_system TEXT,

    browser_family TEXT,

    application_version TEXT,

    locale_code TEXT,

    country_code TEXT,

    region_code TEXT,

    city_code TEXT,

    ip_address_hash TEXT,

    user_agent_hash TEXT,

    referrer_hash TEXT,

    attribution_source TEXT,

    attribution_medium TEXT,

    attribution_campaign TEXT,

    attribution_content TEXT,

    attribution_term TEXT,

    experiment_code TEXT,

    experiment_variant TEXT,

    event_properties JSONB NOT NULL DEFAULT '{}'::JSONB,

    attribution_data JSONB NOT NULL DEFAULT '{}'::JSONB,

    device_data JSONB NOT NULL DEFAULT '{}'::JSONB,

    processing_metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_recommendation_interactions_reference
        UNIQUE (
            interaction_reference
        ),

    CONSTRAINT uq_recommendation_interactions_idempotency
        UNIQUE (
            idempotency_key
        ),

    CONSTRAINT chk_recommendation_interactions_reference
        CHECK (
            interaction_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_recommendation_interactions_type
        CHECK (
            interaction_type IN (
                'RESULT_IMPRESSION',
                'RESULT_VIEW',
                'RESULT_EXPANDED',
                'CARD_DETAIL_VIEW',
                'EXPLANATION_VIEW',
                'BENEFIT_VIEW',
                'FEE_VIEW',
                'ELIGIBILITY_VIEW',
                'VALUE_SIMULATION_VIEW',
                'COMPARE_ADDED',
                'COMPARE_REMOVED',
                'COMPARISON_VIEW',
                'SAVED',
                'UNSAVED',
                'SHARED',
                'DOWNLOADED',
                'CALL_TO_ACTION_CLICK',
                'BANK_REDIRECT',
                'APPLICATION_STARTED',
                'APPLICATION_CONTINUED',
                'APPLICATION_COMPLETED',
                'APPLICATION_ABANDONED',
                'APPLICATION_APPROVED',
                'APPLICATION_REJECTED',
                'CARD_ACTIVATED',
                'CARD_ACQUIRED',
                'RECOMMENDATION_ACCEPTED',
                'RECOMMENDATION_REJECTED',
                'RECOMMENDATION_DISMISSED',
                'RECOMMENDATION_REFRESHED',
                'ALTERNATIVE_REQUESTED',
                'ADVISOR_CONTACT_REQUESTED',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_interactions_source
        CHECK (
            interaction_source IN (
                'WEB_APPLICATION',
                'MOBILE_APPLICATION',
                'ADMIN_PORTAL',
                'ADVISOR_PORTAL',
                'PUBLIC_API',
                'INTERNAL_API',
                'BANK_REDIRECT',
                'EMAIL',
                'SMS',
                'PUSH_NOTIFICATION',
                'IMPORT',
                'TEST',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_interactions_context
        CHECK (
            interaction_context IS NULL
            OR interaction_context IN (
                'RECOMMENDATION_LIST',
                'RECOMMENDATION_DETAIL',
                'CARD_DETAIL',
                'CARD_COMPARISON',
                'SAVED_CARDS',
                'APPLICATION_JOURNEY',
                'ADVISOR_REVIEW',
                'ADMIN_REVIEW',
                'NOTIFICATION',
                'EXTERNAL_REDIRECT',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_interactions_rank
        CHECK (
            recommendation_rank_at_interaction IS NULL
            OR recommendation_rank_at_interaction > 0
        ),

    CONSTRAINT chk_recommendation_interactions_score
        CHECK (
            recommendation_score_at_interaction IS NULL
            OR recommendation_score_at_interaction BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_interactions_expected_value_currency
        CHECK (
            (
                expected_net_value_at_interaction IS NULL
                AND value_currency_id IS NULL
            )
            OR
            (
                expected_net_value_at_interaction IS NOT NULL
                AND value_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_recommendation_interactions_value_currency
        CHECK (
            (
                interaction_value IS NULL
                AND interaction_value_currency_id IS NULL
            )
            OR
            (
                interaction_value IS NOT NULL
                AND interaction_value_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_recommendation_interactions_page_code
        CHECK (
            page_code IS NULL
            OR page_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_interactions_component_code
        CHECK (
            component_code IS NULL
            OR component_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_interactions_placement_code
        CHECK (
            placement_code IS NULL
            OR placement_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_interactions_cta_code
        CHECK (
            call_to_action_code IS NULL
            OR call_to_action_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_interactions_destination_type
        CHECK (
            destination_type IS NULL
            OR destination_type IN (
                'INTERNAL_PAGE',
                'CARD_PAGE',
                'COMPARISON_PAGE',
                'BANK_WEBSITE',
                'APPLICATION_FORM',
                'ADVISOR_FORM',
                'DOWNLOAD',
                'EXTERNAL_URL',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_interactions_destination_url
        CHECK (
            destination_url IS NULL
            OR length(trim(destination_url)) > 0
        ),

    CONSTRAINT chk_recommendation_interactions_comparison_cards
        CHECK (
            comparison_card_ids IS NULL
            OR cardinality(comparison_card_ids) > 0
        ),

    CONSTRAINT chk_recommendation_interactions_duration
        CHECK (
            duration_ms IS NULL
            OR duration_ms >= 0
        ),

    CONSTRAINT chk_recommendation_interactions_sequence
        CHECK (
            sequence_number IS NULL
            OR sequence_number > 0
        ),

    CONSTRAINT chk_recommendation_interactions_received
        CHECK (
            received_at >= occurred_at
        ),

    CONSTRAINT chk_recommendation_interactions_processed
        CHECK (
            processed_at IS NULL
            OR processed_at >= received_at
        ),

    CONSTRAINT chk_recommendation_interactions_authenticated
        CHECK (
            is_authenticated = FALSE
            OR user_id IS NOT NULL
        ),

    CONSTRAINT chk_recommendation_interactions_device_type
        CHECK (
            device_type IS NULL
            OR device_type IN (
                'DESKTOP',
                'MOBILE',
                'TABLET',
                'WEBVIEW',
                'BOT',
                'UNKNOWN',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_interactions_locale
        CHECK (
            locale_code IS NULL
            OR locale_code ~ '^[a-z]{2}(?:-[A-Z]{2})?$'
        ),

    CONSTRAINT chk_recommendation_interactions_country
        CHECK (
            country_code IS NULL
            OR country_code ~ '^[A-Z]{2}$'
        ),

    CONSTRAINT chk_recommendation_interactions_event_properties
        CHECK (
            jsonb_typeof(event_properties) = 'object'
        ),

    CONSTRAINT chk_recommendation_interactions_attribution_data
        CHECK (
            jsonb_typeof(attribution_data) = 'object'
        ),

    CONSTRAINT chk_recommendation_interactions_device_data
        CHECK (
            jsonb_typeof(device_data) = 'object'
        ),

    CONSTRAINT chk_recommendation_interactions_processing_metadata
        CHECK (
            jsonb_typeof(processing_metadata) = 'object'
        ),

    CONSTRAINT chk_recommendation_interactions_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.recommendation_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    recommendation_run_id UUID NOT NULL
        REFERENCES public.recommendation_runs(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_result_id UUID
        REFERENCES public.recommendation_results(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_run_card_id UUID
        REFERENCES public.recommendation_run_cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_interaction_id UUID
        REFERENCES public.recommendation_interactions(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    card_id UUID
        REFERENCES public.cards(id)
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

    feedback_reference TEXT NOT NULL,

    feedback_type TEXT NOT NULL,

    feedback_source TEXT NOT NULL DEFAULT 'CUSTOMER',

    feedback_status TEXT NOT NULL DEFAULT 'SUBMITTED',

    overall_rating SMALLINT,

    relevance_rating SMALLINT,

    accuracy_rating SMALLINT,

    explanation_rating SMALLINT,

    value_estimate_rating SMALLINT,

    eligibility_rating SMALLINT,

    ease_of_use_rating SMALLINT,

    recommendation_helpful BOOLEAN,

    recommendation_accepted BOOLEAN,

    recommendation_was_expected BOOLEAN,

    result_was_understandable BOOLEAN,

    value_estimate_was_realistic BOOLEAN,

    eligibility_assessment_was_accurate BOOLEAN,

    selected_card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    selected_recommendation_result_id UUID
        REFERENCES public.recommendation_results(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    selected_alternative_type TEXT,

    selected_alternative_reference TEXT,

    primary_reason_code TEXT,

    secondary_reason_codes TEXT[],

    positive_reason_codes TEXT[],

    negative_reason_codes TEXT[],

    missing_feature_codes TEXT[],

    feedback_title TEXT,

    feedback_comment TEXT,

    improvement_suggestion TEXT,

    expected_recommendation TEXT,

    rejection_reason TEXT,

    reported_issue_type TEXT,

    reported_issue_severity TEXT,

    reported_issue_description TEXT,

    contact_permission BOOLEAN NOT NULL DEFAULT FALSE,

    follow_up_required BOOLEAN NOT NULL DEFAULT FALSE,

    follow_up_status TEXT,

    follow_up_owner_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    follow_up_due_at TIMESTAMPTZ,

    followed_up_at TIMESTAMPTZ,

    resolution_code TEXT,

    resolution_notes TEXT,

    model_training_eligible BOOLEAN NOT NULL DEFAULT TRUE,

    quality_review_required BOOLEAN NOT NULL DEFAULT FALSE,

    quality_review_status TEXT,

    quality_reviewed_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    quality_reviewed_at TIMESTAMPTZ,

    submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    withdrawn_at TIMESTAMPTZ,

    resolved_at TIMESTAMPTZ,

    feedback_context JSONB NOT NULL DEFAULT '{}'::JSONB,

    structured_feedback JSONB NOT NULL DEFAULT '{}'::JSONB,

    quality_review_data JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_recommendation_feedback_reference
        UNIQUE (
            feedback_reference
        ),

    CONSTRAINT chk_recommendation_feedback_reference
        CHECK (
            feedback_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_recommendation_feedback_type
        CHECK (
            feedback_type IN (
                'GENERAL_RATING',
                'RESULT_RATING',
                'CARD_RATING',
                'RELEVANCE_FEEDBACK',
                'ACCURACY_FEEDBACK',
                'ELIGIBILITY_FEEDBACK',
                'VALUE_ESTIMATE_FEEDBACK',
                'EXPLANATION_FEEDBACK',
                'RECOMMENDATION_ACCEPTANCE',
                'RECOMMENDATION_REJECTION',
                'SELECTED_ALTERNATIVE',
                'MISSING_CARD',
                'INCORRECT_CARD_DATA',
                'INCORRECT_FEE_DATA',
                'INCORRECT_REWARD_DATA',
                'INCORRECT_ELIGIBILITY_DATA',
                'TECHNICAL_ISSUE',
                'COMPLAINT',
                'SUGGESTION',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_feedback_source
        CHECK (
            feedback_source IN (
                'CUSTOMER',
                'ADVISOR',
                'ADMIN',
                'BANK',
                'QUALITY_REVIEW',
                'AUTOMATED_VALIDATION',
                'CUSTOMER_SUPPORT',
                'IMPORT',
                'TEST',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_feedback_status
        CHECK (
            feedback_status IN (
                'DRAFT',
                'SUBMITTED',
                'UNDER_REVIEW',
                'ACTION_REQUIRED',
                'RESOLVED',
                'REJECTED',
                'WITHDRAWN',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_recommendation_feedback_ratings
        CHECK (
            (
                overall_rating IS NULL
                OR overall_rating BETWEEN 1 AND 5
            )
            AND
            (
                relevance_rating IS NULL
                OR relevance_rating BETWEEN 1 AND 5
            )
            AND
            (
                accuracy_rating IS NULL
                OR accuracy_rating BETWEEN 1 AND 5
            )
            AND
            (
                explanation_rating IS NULL
                OR explanation_rating BETWEEN 1 AND 5
            )
            AND
            (
                value_estimate_rating IS NULL
                OR value_estimate_rating BETWEEN 1 AND 5
            )
            AND
            (
                eligibility_rating IS NULL
                OR eligibility_rating BETWEEN 1 AND 5
            )
            AND
            (
                ease_of_use_rating IS NULL
                OR ease_of_use_rating BETWEEN 1 AND 5
            )
        ),

    CONSTRAINT chk_recommendation_feedback_selected_alternative_type
        CHECK (
            selected_alternative_type IS NULL
            OR selected_alternative_type IN (
                'ANOTHER_RECOMMENDED_CARD',
                'NON_RECOMMENDED_PLATFORM_CARD',
                'EXTERNAL_CARD',
                'DEBIT_CARD',
                'PREPAID_CARD',
                'NO_CARD',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_feedback_primary_reason
        CHECK (
            primary_reason_code IS NULL
            OR primary_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_feedback_secondary_reasons
        CHECK (
            secondary_reason_codes IS NULL
            OR cardinality(secondary_reason_codes) > 0
        ),

    CONSTRAINT chk_recommendation_feedback_positive_reasons
        CHECK (
            positive_reason_codes IS NULL
            OR cardinality(positive_reason_codes) > 0
        ),

    CONSTRAINT chk_recommendation_feedback_negative_reasons
        CHECK (
            negative_reason_codes IS NULL
            OR cardinality(negative_reason_codes) > 0
        ),

    CONSTRAINT chk_recommendation_feedback_missing_features
        CHECK (
            missing_feature_codes IS NULL
            OR cardinality(missing_feature_codes) > 0
        ),

    CONSTRAINT chk_recommendation_feedback_title
        CHECK (
            feedback_title IS NULL
            OR length(trim(feedback_title)) > 0
        ),

    CONSTRAINT chk_recommendation_feedback_comment
        CHECK (
            feedback_comment IS NULL
            OR length(trim(feedback_comment)) > 0
        ),

    CONSTRAINT chk_recommendation_feedback_issue_type
        CHECK (
            reported_issue_type IS NULL
            OR reported_issue_type IN (
                'PRODUCT_DATA',
                'ELIGIBILITY',
                'REWARD_CALCULATION',
                'FEE_CALCULATION',
                'VALUE_SIMULATION',
                'RANKING',
                'EXPLANATION',
                'TRANSLATION',
                'USER_INTERFACE',
                'REDIRECT',
                'APPLICATION_PROCESS',
                'PRIVACY',
                'SECURITY',
                'PERFORMANCE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_feedback_issue_severity
        CHECK (
            reported_issue_severity IS NULL
            OR reported_issue_severity IN (
                'LOW',
                'MEDIUM',
                'HIGH',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_recommendation_feedback_follow_up_status
        CHECK (
            follow_up_status IS NULL
            OR follow_up_status IN (
                'NOT_REQUIRED',
                'PENDING',
                'IN_PROGRESS',
                'WAITING_FOR_CUSTOMER',
                'COMPLETED',
                'CANCELLED'
            )
        ),

    CONSTRAINT chk_recommendation_feedback_follow_up_required
        CHECK (
            follow_up_required = FALSE
            OR follow_up_status IS NOT NULL
        ),

    CONSTRAINT chk_recommendation_feedback_follow_up_owner
        CHECK (
            follow_up_owner_id IS NULL
            OR follow_up_required = TRUE
        ),

    CONSTRAINT chk_recommendation_feedback_follow_up_due
        CHECK (
            follow_up_due_at IS NULL
            OR follow_up_required = TRUE
        ),

    CONSTRAINT chk_recommendation_feedback_followed_up
        CHECK (
            followed_up_at IS NULL
            OR followed_up_at >= submitted_at
        ),

    CONSTRAINT chk_recommendation_feedback_quality_status
        CHECK (
            quality_review_status IS NULL
            OR quality_review_status IN (
                'PENDING',
                'IN_PROGRESS',
                'VALIDATED',
                'INVALID',
                'DUPLICATE',
                'CORRECTED',
                'ESCALATED',
                'CLOSED'
            )
        ),

    CONSTRAINT chk_recommendation_feedback_quality_required
        CHECK (
            quality_review_required = FALSE
            OR quality_review_status IS NOT NULL
        ),

    CONSTRAINT chk_recommendation_feedback_quality_reviewer
        CHECK (
            quality_reviewed_by IS NULL
            OR quality_reviewed_at IS NOT NULL
        ),

    CONSTRAINT chk_recommendation_feedback_quality_reviewed_at
        CHECK (
            quality_reviewed_at IS NULL
            OR quality_reviewed_at >= submitted_at
        ),

    CONSTRAINT chk_recommendation_feedback_withdrawn
        CHECK (
            withdrawn_at IS NULL
            OR withdrawn_at >= submitted_at
        ),

    CONSTRAINT chk_recommendation_feedback_resolved
        CHECK (
            resolved_at IS NULL
            OR resolved_at >= submitted_at
        ),

    CONSTRAINT chk_recommendation_feedback_terminal_dates
        CHECK (
            withdrawn_at IS NULL
            OR resolved_at IS NULL
        ),

    CONSTRAINT chk_recommendation_feedback_context
        CHECK (
            jsonb_typeof(feedback_context) = 'object'
        ),

    CONSTRAINT chk_recommendation_feedback_structured
        CHECK (
            jsonb_typeof(structured_feedback) = 'object'
        ),

    CONSTRAINT chk_recommendation_feedback_quality_data
        CHECK (
            jsonb_typeof(quality_review_data) = 'object'
        ),

    CONSTRAINT chk_recommendation_feedback_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE INDEX idx_recommendation_interactions_run
ON public.recommendation_interactions(
    recommendation_run_id,
    occurred_at DESC
);

CREATE INDEX idx_recommendation_interactions_result
ON public.recommendation_interactions(
    recommendation_result_id,
    occurred_at DESC
)
WHERE recommendation_result_id IS NOT NULL;

CREATE INDEX idx_recommendation_interactions_run_card
ON public.recommendation_interactions(
    recommendation_run_card_id,
    occurred_at DESC
)
WHERE recommendation_run_card_id IS NOT NULL;

CREATE INDEX idx_recommendation_interactions_card
ON public.recommendation_interactions(
    card_id,
    occurred_at DESC
)
WHERE card_id IS NOT NULL;

CREATE INDEX idx_recommendation_interactions_profile
ON public.recommendation_interactions(
    financial_profile_id,
    occurred_at DESC
)
WHERE financial_profile_id IS NOT NULL;

CREATE INDEX idx_recommendation_interactions_user
ON public.recommendation_interactions(
    user_id,
    occurred_at DESC
)
WHERE user_id IS NOT NULL;

CREATE INDEX idx_recommendation_interactions_type
ON public.recommendation_interactions(
    interaction_type,
    occurred_at DESC
);

CREATE INDEX idx_recommendation_interactions_session
ON public.recommendation_interactions(
    session_reference,
    sequence_number,
    occurred_at
)
WHERE session_reference IS NOT NULL;

CREATE INDEX idx_recommendation_interactions_journey
ON public.recommendation_interactions(
    journey_reference,
    occurred_at
)
WHERE journey_reference IS NOT NULL;

CREATE INDEX idx_recommendation_interactions_correlation
ON public.recommendation_interactions(correlation_id)
WHERE correlation_id IS NOT NULL;

CREATE INDEX idx_recommendation_interactions_conversion
ON public.recommendation_interactions(
    interaction_type,
    occurred_at DESC
)
WHERE is_conversion_event = TRUE;

CREATE INDEX idx_recommendation_interactions_unique
ON public.recommendation_interactions(
    recommendation_result_id,
    interaction_type,
    occurred_at DESC
)
WHERE is_unique_interaction = TRUE
  AND recommendation_result_id IS NOT NULL;

CREATE INDEX idx_recommendation_interactions_unprocessed
ON public.recommendation_interactions(received_at)
WHERE processed_at IS NULL;

CREATE INDEX idx_recommendation_interactions_experiment
ON public.recommendation_interactions(
    experiment_code,
    experiment_variant,
    occurred_at DESC
)
WHERE experiment_code IS NOT NULL;

CREATE INDEX idx_recommendation_interactions_comparison_cards
ON public.recommendation_interactions
USING GIN (comparison_card_ids)
WHERE comparison_card_ids IS NOT NULL;

CREATE INDEX idx_recommendation_interactions_event_properties
ON public.recommendation_interactions
USING GIN (event_properties);

CREATE INDEX idx_recommendation_interactions_attribution_data
ON public.recommendation_interactions
USING GIN (attribution_data);

CREATE INDEX idx_recommendation_interactions_device_data
ON public.recommendation_interactions
USING GIN (device_data);

CREATE INDEX idx_recommendation_interactions_metadata
ON public.recommendation_interactions
USING GIN (metadata);

CREATE INDEX idx_recommendation_feedback_run
ON public.recommendation_feedback(
    recommendation_run_id,
    submitted_at DESC
);

CREATE INDEX idx_recommendation_feedback_result
ON public.recommendation_feedback(
    recommendation_result_id,
    submitted_at DESC
)
WHERE recommendation_result_id IS NOT NULL;

CREATE INDEX idx_recommendation_feedback_run_card
ON public.recommendation_feedback(
    recommendation_run_card_id,
    submitted_at DESC
)
WHERE recommendation_run_card_id IS NOT NULL;

CREATE INDEX idx_recommendation_feedback_interaction
ON public.recommendation_feedback(recommendation_interaction_id)
WHERE recommendation_interaction_id IS NOT NULL;

CREATE INDEX idx_recommendation_feedback_card
ON public.recommendation_feedback(
    card_id,
    submitted_at DESC
)
WHERE card_id IS NOT NULL;

CREATE INDEX idx_recommendation_feedback_profile
ON public.recommendation_feedback(
    financial_profile_id,
    submitted_at DESC
)
WHERE financial_profile_id IS NOT NULL;

CREATE INDEX idx_recommendation_feedback_user
ON public.recommendation_feedback(
    user_id,
    submitted_at DESC
)
WHERE user_id IS NOT NULL;

CREATE INDEX idx_recommendation_feedback_type
ON public.recommendation_feedback(
    feedback_type,
    submitted_at DESC
);

CREATE INDEX idx_recommendation_feedback_status
ON public.recommendation_feedback(
    feedback_status,
    submitted_at DESC
);

CREATE INDEX idx_recommendation_feedback_rating
ON public.recommendation_feedback(
    overall_rating,
    submitted_at DESC
)
WHERE overall_rating IS NOT NULL;

CREATE INDEX idx_recommendation_feedback_negative
ON public.recommendation_feedback(
    submitted_at DESC
)
WHERE recommendation_helpful = FALSE
   OR recommendation_accepted = FALSE
   OR overall_rating <= 2;

CREATE INDEX idx_recommendation_feedback_follow_up
ON public.recommendation_feedback(
    follow_up_due_at,
    feedback_status
)
WHERE follow_up_required = TRUE
  AND followed_up_at IS NULL;

CREATE INDEX idx_recommendation_feedback_quality_review
ON public.recommendation_feedback(
    quality_review_status,
    submitted_at
)
WHERE quality_review_required = TRUE;

CREATE INDEX idx_recommendation_feedback_training
ON public.recommendation_feedback(
    feedback_type,
    submitted_at DESC
)
WHERE model_training_eligible = TRUE
  AND feedback_status NOT IN (
      'DRAFT',
      'WITHDRAWN',
      'REJECTED'
  );

CREATE INDEX idx_recommendation_feedback_primary_reason
ON public.recommendation_feedback(primary_reason_code)
WHERE primary_reason_code IS NOT NULL;

CREATE INDEX idx_recommendation_feedback_secondary_reasons
ON public.recommendation_feedback
USING GIN (secondary_reason_codes);

CREATE INDEX idx_recommendation_feedback_positive_reasons
ON public.recommendation_feedback
USING GIN (positive_reason_codes);

CREATE INDEX idx_recommendation_feedback_negative_reasons
ON public.recommendation_feedback
USING GIN (negative_reason_codes);

CREATE INDEX idx_recommendation_feedback_missing_features
ON public.recommendation_feedback
USING GIN (missing_feature_codes);

CREATE INDEX idx_recommendation_feedback_context
ON public.recommendation_feedback
USING GIN (feedback_context);

CREATE INDEX idx_recommendation_feedback_structured
ON public.recommendation_feedback
USING GIN (structured_feedback);

CREATE INDEX idx_recommendation_feedback_quality_data
ON public.recommendation_feedback
USING GIN (quality_review_data);

CREATE INDEX idx_recommendation_feedback_metadata
ON public.recommendation_feedback
USING GIN (metadata);

CREATE TRIGGER trg_recommendation_interactions_updated_at
BEFORE UPDATE
ON public.recommendation_interactions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_recommendation_feedback_updated_at
BEFORE UPDATE
ON public.recommendation_feedback
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.recommendation_interactions IS
'Records customer, advisor, administrator, and system interactions with card recommendation results throughout the recommendation and application journey.';

COMMENT ON COLUMN public.recommendation_interactions.interaction_reference IS
'Unique public-safe identifier for the recommendation interaction event.';

COMMENT ON COLUMN public.recommendation_interactions.interaction_type IS
'Business event performed against a recommendation, such as viewing, comparing, saving, redirecting, applying, accepting, or rejecting.';

COMMENT ON COLUMN public.recommendation_interactions.recommendation_rank_at_interaction IS
'Recommendation rank displayed when the interaction occurred, retained for historical analytics even if rankings later change.';

COMMENT ON COLUMN public.recommendation_interactions.recommendation_score_at_interaction IS
'Recommendation score displayed when the interaction occurred.';

COMMENT ON COLUMN public.recommendation_interactions.is_conversion_event IS
'Indicates that the interaction represents a measurable conversion milestone in the recommendation or card-application journey.';

COMMENT ON COLUMN public.recommendation_interactions.comparison_card_ids IS
'Cards included in the customer comparison context when the interaction occurred.';

COMMENT ON COLUMN public.recommendation_interactions.event_properties IS
'Structured event-specific properties that do not require dedicated relational columns.';

COMMENT ON TABLE public.recommendation_feedback IS
'Structured and free-text feedback used to assess recommendation relevance, accuracy, explainability, product-data quality, and customer satisfaction.';

COMMENT ON COLUMN public.recommendation_feedback.feedback_type IS
'Classification of the submitted feedback, including ratings, acceptance, rejection, data issues, complaints, and suggestions.';

COMMENT ON COLUMN public.recommendation_feedback.overall_rating IS
'Overall customer or reviewer rating using a one-to-five scale.';

COMMENT ON COLUMN public.recommendation_feedback.recommendation_accepted IS
'Indicates whether the customer accepted or intended to act on the recommendation.';

COMMENT ON COLUMN public.recommendation_feedback.selected_card_id IS
'Card ultimately selected by the customer, whether or not it was the highest-ranked recommendation.';

COMMENT ON COLUMN public.recommendation_feedback.primary_reason_code IS
'Primary standardized reason supporting positive or negative feedback.';

COMMENT ON COLUMN public.recommendation_feedback.model_training_eligible IS
'Indicates whether validated feedback may be used for recommendation-model analysis, calibration, or future training datasets.';

COMMENT ON COLUMN public.recommendation_feedback.quality_review_required IS
'Indicates that the feedback requires human quality review before being used operationally or analytically.';

COMMENT ON COLUMN public.recommendation_feedback.feedback_context IS
'Snapshot of the recommendation, displayed values, model version, and customer journey context when feedback was submitted.';

COMMENT ON COLUMN public.recommendation_feedback.structured_feedback IS
'Additional structured responses, selected options, categories, and feedback attributes.';

COMMENT ON COLUMN public.recommendation_feedback.quality_review_data IS
'Structured validation findings and corrective actions recorded during quality review.';
