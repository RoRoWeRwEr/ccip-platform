CREATE TABLE public.recommendation_explanations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    recommendation_result_id UUID NOT NULL
        REFERENCES public.recommendation_results(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_run_id UUID NOT NULL
        REFERENCES public.recommendation_runs(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_run_card_id UUID NOT NULL
        REFERENCES public.recommendation_run_cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    explanation_type public.explanation_type NOT NULL,

    explanation_code TEXT NOT NULL,

    explanation_title_en TEXT,

    explanation_title_ar TEXT,

    explanation_text_en TEXT NOT NULL,

    explanation_text_ar TEXT,

    short_text_en TEXT,

    short_text_ar TEXT,

    explanation_category TEXT NOT NULL,

    explanation_sentiment TEXT NOT NULL DEFAULT 'NEUTRAL',

    explanation_severity TEXT NOT NULL DEFAULT 'INFO',

    source_entity TEXT,

    source_record_id UUID,

    source_field TEXT,

    factor_code TEXT,

    preference_code TEXT,

    value_component_code TEXT,

    actual_numeric_value NUMERIC(18, 6),

    expected_numeric_value NUMERIC(18, 6),

    minimum_numeric_value NUMERIC(18, 6),

    maximum_numeric_value NUMERIC(18, 6),

    currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    actual_text_value TEXT,

    expected_text_value TEXT,

    actual_boolean_value BOOLEAN,

    expected_boolean_value BOOLEAN,

    score_contribution NUMERIC(9, 4),

    weighted_score_contribution NUMERIC(9, 4),

    financial_value_contribution NUMERIC(18, 6),

    confidence_score NUMERIC(5, 2),

    importance_score NUMERIC(9, 4),

    display_priority SMALLINT NOT NULL DEFAULT 1,

    display_group TEXT,

    icon_code TEXT,

    badge_code TEXT,

    callout_code TEXT,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    is_positive BOOLEAN NOT NULL DEFAULT FALSE,

    is_negative BOOLEAN NOT NULL DEFAULT FALSE,

    is_warning BOOLEAN NOT NULL DEFAULT FALSE,

    is_customer_visible BOOLEAN NOT NULL DEFAULT TRUE,

    is_advisor_visible BOOLEAN NOT NULL DEFAULT TRUE,

    is_admin_visible BOOLEAN NOT NULL DEFAULT TRUE,

    is_actionable BOOLEAN NOT NULL DEFAULT FALSE,

    action_code TEXT,

    action_label_en TEXT,

    action_label_ar TEXT,

    action_url TEXT,

    generation_method TEXT NOT NULL DEFAULT 'RULE_BASED',

    generation_version TEXT NOT NULL DEFAULT '1.0',

    template_code TEXT,

    template_variables JSONB NOT NULL DEFAULT '{}'::JSONB,

    evidence JSONB NOT NULL DEFAULT '[]'::JSONB,

    calculation_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    presentation_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_recommendation_explanations_result_code
        UNIQUE (
            recommendation_result_id,
            explanation_code
        ),

    CONSTRAINT chk_recommendation_explanations_code
        CHECK (
            explanation_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_explanations_title_en
        CHECK (
            explanation_title_en IS NULL
            OR length(trim(explanation_title_en)) > 0
        ),

    CONSTRAINT chk_recommendation_explanations_title_ar
        CHECK (
            explanation_title_ar IS NULL
            OR length(trim(explanation_title_ar)) > 0
        ),

    CONSTRAINT chk_recommendation_explanations_text_en
        CHECK (
            length(trim(explanation_text_en)) > 0
        ),

    CONSTRAINT chk_recommendation_explanations_text_ar
        CHECK (
            explanation_text_ar IS NULL
            OR length(trim(explanation_text_ar)) > 0
        ),

    CONSTRAINT chk_recommendation_explanations_short_text_en
        CHECK (
            short_text_en IS NULL
            OR length(trim(short_text_en)) > 0
        ),

    CONSTRAINT chk_recommendation_explanations_short_text_ar
        CHECK (
            short_text_ar IS NULL
            OR length(trim(short_text_ar)) > 0
        ),

    CONSTRAINT chk_recommendation_explanations_category
        CHECK (
            explanation_category IN (
                'OVERALL',
                'ELIGIBILITY',
                'FINANCIAL_VALUE',
                'REWARDS',
                'FEES',
                'PREFERENCES',
                'TRAVEL',
                'LOUNGE',
                'DINING',
                'INSURANCE',
                'INSTALLMENTS',
                'OFFERS',
                'LIFESTYLE',
                'SIMPLICITY',
                'BANK_RELATIONSHIP',
                'DATA_QUALITY',
                'CONFIDENCE',
                'EXCLUSION',
                'WARNING',
                'TRADEOFF',
                'ACTION',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_explanations_sentiment
        CHECK (
            explanation_sentiment IN (
                'POSITIVE',
                'NEGATIVE',
                'NEUTRAL',
                'MIXED'
            )
        ),

    CONSTRAINT chk_recommendation_explanations_severity
        CHECK (
            explanation_severity IN (
                'INFO',
                'SUCCESS',
                'WARNING',
                'ERROR',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_recommendation_explanations_source_entity
        CHECK (
            source_entity IS NULL
            OR source_entity IN (
                'CUSTOMER_FINANCIAL_PROFILE',
                'CUSTOMER_SPENDING_PROFILE',
                'CUSTOMER_SPENDING_CATEGORY',
                'CUSTOMER_PREFERENCE_PROFILE',
                'CUSTOMER_PREFERENCE',
                'CARD',
                'CARD_FEE',
                'CARD_BENEFIT',
                'CARD_ELIGIBILITY_REQUIREMENT',
                'ELIGIBILITY_ASSESSMENT',
                'ELIGIBILITY_REQUIREMENT_ASSESSMENT',
                'CARD_VALUE_SIMULATION',
                'CARD_VALUE_SIMULATION_COMPONENT',
                'REWARD_RULE',
                'REWARD_TARGET',
                'REWARD_EXCLUSION',
                'REWARD_REDEMPTION_RATE',
                'CARD_OFFER',
                'CARD_LOUNGE_BENEFIT',
                'CARD_TRAVEL_BENEFIT',
                'CARD_DINING_BENEFIT',
                'CARD_INSURANCE_BENEFIT',
                'CARD_INSTALLMENT_PLAN',
                'CARD_NETWORK_BENEFIT',
                'RECOMMENDATION_MODEL',
                'RECOMMENDATION_MODEL_FACTOR',
                'RECOMMENDATION_RESULT',
                'CALCULATED',
                'MANUAL',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_explanations_source_field
        CHECK (
            source_field IS NULL
            OR length(trim(source_field)) > 0
        ),

    CONSTRAINT chk_recommendation_explanations_factor_code
        CHECK (
            factor_code IS NULL
            OR factor_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_explanations_preference_code
        CHECK (
            preference_code IS NULL
            OR preference_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_explanations_value_component_code
        CHECK (
            value_component_code IS NULL
            OR value_component_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_explanations_numeric_range
        CHECK (
            minimum_numeric_value IS NULL
            OR maximum_numeric_value IS NULL
            OR maximum_numeric_value >= minimum_numeric_value
        ),

    CONSTRAINT chk_recommendation_explanations_actual_minimum
        CHECK (
            actual_numeric_value IS NULL
            OR minimum_numeric_value IS NULL
            OR actual_numeric_value >= minimum_numeric_value
        ),

    CONSTRAINT chk_recommendation_explanations_actual_maximum
        CHECK (
            actual_numeric_value IS NULL
            OR maximum_numeric_value IS NULL
            OR actual_numeric_value <= maximum_numeric_value
        ),

    CONSTRAINT chk_recommendation_explanations_currency
        CHECK (
            (
                actual_numeric_value IS NULL
                AND expected_numeric_value IS NULL
                AND minimum_numeric_value IS NULL
                AND maximum_numeric_value IS NULL
            )
            OR currency_id IS NOT NULL
            OR explanation_category NOT IN (
                'FINANCIAL_VALUE',
                'FEES',
                'REWARDS'
            )
        ),

    CONSTRAINT chk_recommendation_explanations_score_contribution
        CHECK (
            score_contribution IS NULL
            OR score_contribution BETWEEN -100 AND 100
        ),

    CONSTRAINT chk_recommendation_explanations_weighted_contribution
        CHECK (
            weighted_score_contribution IS NULL
            OR weighted_score_contribution BETWEEN -100 AND 100
        ),

    CONSTRAINT chk_recommendation_explanations_confidence
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_explanations_importance
        CHECK (
            importance_score IS NULL
            OR importance_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_explanations_display_priority
        CHECK (
            display_priority > 0
        ),

    CONSTRAINT chk_recommendation_explanations_display_group
        CHECK (
            display_group IS NULL
            OR length(trim(display_group)) > 0
        ),

    CONSTRAINT chk_recommendation_explanations_icon_code
        CHECK (
            icon_code IS NULL
            OR icon_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_explanations_badge_code
        CHECK (
            badge_code IS NULL
            OR badge_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_explanations_callout_code
        CHECK (
            callout_code IS NULL
            OR callout_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_explanations_flags
        CHECK (
            (
                is_positive = TRUE
            )::INTEGER
            +
            (
                is_negative = TRUE
            )::INTEGER
            +
            (
                is_warning = TRUE
            )::INTEGER
            <= 1
        ),

    CONSTRAINT chk_recommendation_explanations_sentiment_flags
        CHECK (
            (
                is_positive = FALSE
                OR explanation_sentiment = 'POSITIVE'
            )
            AND
            (
                is_negative = FALSE
                OR explanation_sentiment = 'NEGATIVE'
            )
            AND
            (
                is_warning = FALSE
                OR explanation_severity IN (
                    'WARNING',
                    'ERROR',
                    'CRITICAL'
                )
            )
        ),

    CONSTRAINT chk_recommendation_explanations_action_code
        CHECK (
            action_code IS NULL
            OR action_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_explanations_actionable
        CHECK (
            is_actionable = FALSE
            OR action_code IS NOT NULL
        ),

    CONSTRAINT chk_recommendation_explanations_action_url
        CHECK (
            action_url IS NULL
            OR length(trim(action_url)) > 0
        ),

    CONSTRAINT chk_recommendation_explanations_generation_method
        CHECK (
            generation_method IN (
                'RULE_BASED',
                'TEMPLATE',
                'CALCULATED',
                'MANUAL',
                'AI_ASSISTED',
                'HYBRID',
                'IMPORTED',
                'TEST'
            )
        ),

    CONSTRAINT chk_recommendation_explanations_generation_version
        CHECK (
            length(trim(generation_version)) > 0
        ),

    CONSTRAINT chk_recommendation_explanations_template_code
        CHECK (
            template_code IS NULL
            OR template_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_explanations_template_variables
        CHECK (
            jsonb_typeof(template_variables) = 'object'
        ),

    CONSTRAINT chk_recommendation_explanations_evidence
        CHECK (
            jsonb_typeof(evidence) = 'array'
        ),

    CONSTRAINT chk_recommendation_explanations_calculation_details
        CHECK (
            jsonb_typeof(calculation_details) = 'object'
        ),

    CONSTRAINT chk_recommendation_explanations_presentation
        CHECK (
            jsonb_typeof(presentation_configuration) = 'object'
        ),

    CONSTRAINT chk_recommendation_explanations_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE INDEX idx_recommendation_explanations_result
ON public.recommendation_explanations(recommendation_result_id);

CREATE INDEX idx_recommendation_explanations_run
ON public.recommendation_explanations(recommendation_run_id);

CREATE INDEX idx_recommendation_explanations_run_card
ON public.recommendation_explanations(recommendation_run_card_id);

CREATE INDEX idx_recommendation_explanations_card
ON public.recommendation_explanations(card_id);

CREATE INDEX idx_recommendation_explanations_type
ON public.recommendation_explanations(
    explanation_type,
    explanation_category
);

CREATE INDEX idx_recommendation_explanations_result_priority
ON public.recommendation_explanations(
    recommendation_result_id,
    display_priority,
    explanation_code
);

CREATE INDEX idx_recommendation_explanations_primary
ON public.recommendation_explanations(
    recommendation_result_id,
    explanation_category
)
WHERE is_primary = TRUE;

CREATE UNIQUE INDEX uq_recommendation_explanations_primary_category
ON public.recommendation_explanations(
    recommendation_result_id,
    explanation_category
)
WHERE is_primary = TRUE;

CREATE INDEX idx_recommendation_explanations_positive
ON public.recommendation_explanations(
    recommendation_result_id,
    display_priority
)
WHERE is_positive = TRUE
  AND is_customer_visible = TRUE;

CREATE INDEX idx_recommendation_explanations_negative
ON public.recommendation_explanations(
    recommendation_result_id,
    display_priority
)
WHERE is_negative = TRUE
  AND is_customer_visible = TRUE;

CREATE INDEX idx_recommendation_explanations_warnings
ON public.recommendation_explanations(
    recommendation_result_id,
    explanation_severity,
    display_priority
)
WHERE is_warning = TRUE
  AND is_customer_visible = TRUE;

CREATE INDEX idx_recommendation_explanations_customer_visible
ON public.recommendation_explanations(
    recommendation_result_id,
    display_group,
    display_priority
)
WHERE is_customer_visible = TRUE;

CREATE INDEX idx_recommendation_explanations_advisor_visible
ON public.recommendation_explanations(
    recommendation_result_id,
    display_priority
)
WHERE is_advisor_visible = TRUE;

CREATE INDEX idx_recommendation_explanations_actionable
ON public.recommendation_explanations(
    recommendation_result_id,
    action_code
)
WHERE is_actionable = TRUE;

CREATE INDEX idx_recommendation_explanations_source
ON public.recommendation_explanations(
    source_entity,
    source_record_id
)
WHERE source_entity IS NOT NULL
  AND source_record_id IS NOT NULL;

CREATE INDEX idx_recommendation_explanations_factor
ON public.recommendation_explanations(
    factor_code
)
WHERE factor_code IS NOT NULL;

CREATE INDEX idx_recommendation_explanations_preference
ON public.recommendation_explanations(
    preference_code
)
WHERE preference_code IS NOT NULL;

CREATE INDEX idx_recommendation_explanations_value_component
ON public.recommendation_explanations(
    value_component_code
)
WHERE value_component_code IS NOT NULL;

CREATE INDEX idx_recommendation_explanations_template_variables
ON public.recommendation_explanations
USING GIN (template_variables);

CREATE INDEX idx_recommendation_explanations_evidence
ON public.recommendation_explanations
USING GIN (evidence);

CREATE INDEX idx_recommendation_explanations_calculation_details
ON public.recommendation_explanations
USING GIN (calculation_details);

CREATE INDEX idx_recommendation_explanations_presentation
ON public.recommendation_explanations
USING GIN (presentation_configuration);

CREATE INDEX idx_recommendation_explanations_metadata
ON public.recommendation_explanations
USING GIN (metadata);

CREATE TRIGGER trg_recommendation_explanations_updated_at
BEFORE UPDATE
ON public.recommendation_explanations
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.recommendation_explanations IS
'Structured multilingual explanations describing why a card was recommended, excluded, penalized, or assigned a specific score.';

COMMENT ON COLUMN public.recommendation_explanations.explanation_type IS
'High-level explanation classification defined by the explanation_type enum.';

COMMENT ON COLUMN public.recommendation_explanations.explanation_code IS
'Stable standardized code identifying the explanation within a recommendation result.';

COMMENT ON COLUMN public.recommendation_explanations.explanation_category IS
'Business area addressed by the explanation, such as eligibility, rewards, fees, preferences, value, confidence, or tradeoffs.';

COMMENT ON COLUMN public.recommendation_explanations.source_entity IS
'Data entity that provided the evidence used to generate the explanation.';

COMMENT ON COLUMN public.recommendation_explanations.source_record_id IS
'Optional identifier of the specific source record supporting the explanation.';

COMMENT ON COLUMN public.recommendation_explanations.score_contribution IS
'Raw positive or negative score contribution associated with the explanation.';

COMMENT ON COLUMN public.recommendation_explanations.weighted_score_contribution IS
'Score contribution after applying the recommendation model factor weight.';

COMMENT ON COLUMN public.recommendation_explanations.financial_value_contribution IS
'Estimated monetary value added or lost because of the explained factor.';

COMMENT ON COLUMN public.recommendation_explanations.is_primary IS
'Identifies the main explanation within a result and explanation category.';

COMMENT ON COLUMN public.recommendation_explanations.is_actionable IS
'Indicates whether the explanation includes an action the customer or advisor may take.';

COMMENT ON COLUMN public.recommendation_explanations.template_variables IS
'Values inserted into the multilingual explanation template during generation.';

COMMENT ON COLUMN public.recommendation_explanations.evidence IS
'Structured evidence records supporting the generated explanation.';

COMMENT ON COLUMN public.recommendation_explanations.calculation_details IS
'Structured calculation details supporting score or financial-value contributions.';

COMMENT ON COLUMN public.recommendation_explanations.presentation_configuration IS
'Optional UI configuration controlling how the explanation is grouped and displayed.';
