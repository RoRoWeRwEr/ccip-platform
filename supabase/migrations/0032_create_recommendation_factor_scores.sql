CREATE TABLE public.recommendation_factor_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    recommendation_run_id UUID NOT NULL
        REFERENCES public.recommendation_runs(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_run_card_id UUID NOT NULL
        REFERENCES public.recommendation_run_cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_result_id UUID
        REFERENCES public.recommendation_results(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_model_id UUID NOT NULL
        REFERENCES public.recommendation_models(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    recommendation_model_factor_id UUID NOT NULL
        REFERENCES public.recommendation_model_factors(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    factor_code TEXT NOT NULL,

    factor_category TEXT NOT NULL,

    factor_name_en TEXT NOT NULL,

    factor_name_ar TEXT,

    factor_value_type TEXT NOT NULL,

    factor_direction TEXT NOT NULL,

    source_entity TEXT NOT NULL,

    source_field TEXT,

    source_record_id UUID,

    raw_numeric_value NUMERIC(18, 8),

    normalized_numeric_value NUMERIC(18, 8),

    raw_text_value TEXT,

    normalized_text_value TEXT,

    raw_boolean_value BOOLEAN,

    normalized_boolean_value BOOLEAN,

    raw_json_value JSONB,

    minimum_input_value NUMERIC(18, 8),

    maximum_input_value NUMERIC(18, 8),

    target_input_value NUMERIC(18, 8),

    threshold_value NUMERIC(18, 8),

    threshold_operator TEXT,

    threshold_satisfied BOOLEAN,

    factor_applied BOOLEAN NOT NULL DEFAULT TRUE,

    factor_skipped BOOLEAN NOT NULL DEFAULT FALSE,

    factor_failed BOOLEAN NOT NULL DEFAULT FALSE,

    hard_requirement BOOLEAN NOT NULL DEFAULT FALSE,

    hard_requirement_satisfied BOOLEAN,

    exclusion_if_failed BOOLEAN NOT NULL DEFAULT FALSE,

    exclusion_triggered BOOLEAN NOT NULL DEFAULT FALSE,

    exclusion_reason public.recommendation_exclusion_reason,

    missing_value BOOLEAN NOT NULL DEFAULT FALSE,

    missing_value_strategy TEXT,

    default_value_applied BOOLEAN NOT NULL DEFAULT FALSE,

    default_numeric_value NUMERIC(18, 8),

    default_text_value TEXT,

    default_boolean_value BOOLEAN,

    normalization_method TEXT,

    raw_score NUMERIC(9, 4),

    normalized_score NUMERIC(9, 4),

    minimum_output_score NUMERIC(9, 4),

    maximum_output_score NUMERIC(9, 4),

    neutral_output_score NUMERIC(9, 4),

    factor_weight NUMERIC(9, 6) NOT NULL DEFAULT 1,

    category_weight NUMERIC(9, 6) NOT NULL DEFAULT 1,

    segment_weight_multiplier NUMERIC(9, 6) NOT NULL DEFAULT 1,

    confidence_multiplier NUMERIC(9, 6) NOT NULL DEFAULT 1,

    completeness_multiplier NUMERIC(9, 6) NOT NULL DEFAULT 1,

    preference_multiplier NUMERIC(9, 6) NOT NULL DEFAULT 1,

    penalty_multiplier NUMERIC(9, 6) NOT NULL DEFAULT 1,

    weighted_score NUMERIC(12, 6),

    adjusted_score NUMERIC(12, 6),

    final_score_contribution NUMERIC(12, 6),

    penalty_score NUMERIC(12, 6) NOT NULL DEFAULT 0,

    bonus_score NUMERIC(12, 6) NOT NULL DEFAULT 0,

    confidence_score NUMERIC(5, 2),

    data_completeness_score NUMERIC(5, 2),

    evaluation_status TEXT NOT NULL DEFAULT 'COMPLETED',

    evaluation_method TEXT NOT NULL DEFAULT 'RULE_BASED',

    evaluation_version TEXT NOT NULL DEFAULT '1.0',

    evaluation_sequence INTEGER,

    calculation_formula TEXT,

    calculation_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    applied_conditions JSONB NOT NULL DEFAULT '{}'::JSONB,

    scoring_band JSONB NOT NULL DEFAULT '{}'::JSONB,

    evidence JSONB NOT NULL DEFAULT '[]'::JSONB,

    warnings JSONB NOT NULL DEFAULT '[]'::JSONB,

    errors JSONB NOT NULL DEFAULT '[]'::JSONB,

    evaluated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    execution_duration_ms BIGINT,

    is_visible_to_customer BOOLEAN NOT NULL DEFAULT FALSE,

    is_visible_to_advisor BOOLEAN NOT NULL DEFAULT TRUE,

    is_visible_to_admin BOOLEAN NOT NULL DEFAULT TRUE,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_recommendation_factor_scores_run_card_factor
        UNIQUE (
            recommendation_run_card_id,
            recommendation_model_factor_id
        ),

    CONSTRAINT chk_recommendation_factor_scores_code
        CHECK (
            factor_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_factor_scores_name_en
        CHECK (
            length(trim(factor_name_en)) > 0
        ),

    CONSTRAINT chk_recommendation_factor_scores_name_ar
        CHECK (
            factor_name_ar IS NULL
            OR length(trim(factor_name_ar)) > 0
        ),

    CONSTRAINT chk_recommendation_factor_scores_category
        CHECK (
            factor_category IN (
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
                'CUSTOMER_SEGMENT',
                'CONFIDENCE',
                'DATA_QUALITY',
                'OTHER'
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_value_type
        CHECK (
            factor_value_type IN (
                'NUMERIC',
                'BOOLEAN',
                'TEXT',
                'ENUM',
                'DATE',
                'COUNT',
                'PERCENTAGE',
                'CURRENCY',
                'JSON',
                'CALCULATED'
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_direction
        CHECK (
            factor_direction IN (
                'HIGHER_IS_BETTER',
                'LOWER_IS_BETTER',
                'TARGET_IS_BETTER',
                'BOOLEAN_TRUE_IS_BETTER',
                'BOOLEAN_FALSE_IS_BETTER',
                'MATCH_IS_BETTER',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_source_entity
        CHECK (
            source_entity IN (
                'CUSTOMER_FINANCIAL_PROFILE',
                'CUSTOMER_SPENDING_PROFILE',
                'CUSTOMER_SPENDING_CATEGORY',
                'CUSTOMER_PREFERENCE_PROFILE',
                'CUSTOMER_PREFERENCE',
                'CARD',
                'CARD_FEE',
                'CARD_BENEFIT',
                'CARD_ELIGIBILITY',
                'ELIGIBILITY_ASSESSMENT',
                'VALUE_SIMULATION',
                'VALUE_SIMULATION_COMPONENT',
                'REWARD_RULE',
                'REWARD_TARGET',
                'REWARD_REDEMPTION_RATE',
                'CARD_OFFER',
                'CARD_LOUNGE_BENEFIT',
                'CARD_TRAVEL_BENEFIT',
                'CARD_DINING_BENEFIT',
                'CARD_INSURANCE_BENEFIT',
                'CARD_INSTALLMENT_PLAN',
                'CARD_NETWORK_BENEFIT',
                'CALCULATED',
                'CONSTANT',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_source_field
        CHECK (
            source_field IS NULL
            OR length(trim(source_field)) > 0
        ),

    CONSTRAINT chk_recommendation_factor_scores_raw_json
        CHECK (
            raw_json_value IS NULL
            OR jsonb_typeof(raw_json_value) IN (
                'object',
                'array',
                'string',
                'number',
                'boolean',
                'null'
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_single_raw_value
        CHECK (
            (
                raw_numeric_value IS NOT NULL
            )::INTEGER
            +
            (
                raw_text_value IS NOT NULL
            )::INTEGER
            +
            (
                raw_boolean_value IS NOT NULL
            )::INTEGER
            +
            (
                raw_json_value IS NOT NULL
            )::INTEGER
            <= 1
        ),

    CONSTRAINT chk_recommendation_factor_scores_single_normalized_value
        CHECK (
            (
                normalized_numeric_value IS NOT NULL
            )::INTEGER
            +
            (
                normalized_text_value IS NOT NULL
            )::INTEGER
            +
            (
                normalized_boolean_value IS NOT NULL
            )::INTEGER
            <= 1
        ),

    CONSTRAINT chk_recommendation_factor_scores_input_range
        CHECK (
            minimum_input_value IS NULL
            OR maximum_input_value IS NULL
            OR maximum_input_value >= minimum_input_value
        ),

    CONSTRAINT chk_recommendation_factor_scores_target_minimum
        CHECK (
            target_input_value IS NULL
            OR minimum_input_value IS NULL
            OR target_input_value >= minimum_input_value
        ),

    CONSTRAINT chk_recommendation_factor_scores_target_maximum
        CHECK (
            target_input_value IS NULL
            OR maximum_input_value IS NULL
            OR target_input_value <= maximum_input_value
        ),

    CONSTRAINT chk_recommendation_factor_scores_threshold_operator
        CHECK (
            threshold_operator IS NULL
            OR threshold_operator IN (
                'GT',
                'GTE',
                'LT',
                'LTE',
                'EQ',
                'NEQ',
                'IN',
                'NOT_IN',
                'CONTAINS',
                'MATCHES'
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_threshold_definition
        CHECK (
            threshold_value IS NULL
            OR threshold_operator IS NOT NULL
        ),

    CONSTRAINT chk_recommendation_factor_scores_flags
        CHECK (
            NOT (
                factor_applied = TRUE
                AND factor_skipped = TRUE
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_skipped
        CHECK (
            factor_skipped = FALSE
            OR factor_applied = FALSE
        ),

    CONSTRAINT chk_recommendation_factor_scores_failed
        CHECK (
            factor_failed = FALSE
            OR evaluation_status IN (
                'FAILED',
                'PARTIALLY_COMPLETED'
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_hard_requirement
        CHECK (
            hard_requirement_satisfied IS NULL
            OR hard_requirement = TRUE
        ),

    CONSTRAINT chk_recommendation_factor_scores_exclusion_configuration
        CHECK (
            exclusion_if_failed = FALSE
            OR hard_requirement = TRUE
        ),

    CONSTRAINT chk_recommendation_factor_scores_exclusion_trigger
        CHECK (
            exclusion_triggered = FALSE
            OR (
                exclusion_if_failed = TRUE
                AND factor_failed = TRUE
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_exclusion_reason
        CHECK (
            exclusion_reason IS NULL
            OR exclusion_triggered = TRUE
        ),

    CONSTRAINT chk_recommendation_factor_scores_default_values
        CHECK (
            (
                default_numeric_value IS NOT NULL
            )::INTEGER
            +
            (
                default_text_value IS NOT NULL
            )::INTEGER
            +
            (
                default_boolean_value IS NOT NULL
            )::INTEGER
            <= 1
        ),

    CONSTRAINT chk_recommendation_factor_scores_default_applied
        CHECK (
            default_value_applied = FALSE
            OR (
                missing_value = TRUE
                AND (
                    default_numeric_value IS NOT NULL
                    OR default_text_value IS NOT NULL
                    OR default_boolean_value IS NOT NULL
                )
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_missing_strategy
        CHECK (
            missing_value_strategy IS NULL
            OR missing_value_strategy IN (
                'ZERO',
                'NEUTRAL',
                'EXCLUDE_FACTOR',
                'PENALIZE',
                'EXCLUDE_CARD',
                'MANUAL_REVIEW',
                'USE_DEFAULT'
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_normalization
        CHECK (
            normalization_method IS NULL
            OR normalization_method IN (
                'NONE',
                'MIN_MAX',
                'INVERSE_MIN_MAX',
                'BINARY',
                'BOOLEAN',
                'THRESHOLD',
                'BANDS',
                'TARGET_DISTANCE',
                'PERCENTILE',
                'LOGARITHMIC',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_output_range
        CHECK (
            minimum_output_score IS NULL
            OR maximum_output_score IS NULL
            OR maximum_output_score > minimum_output_score
        ),

    CONSTRAINT chk_recommendation_factor_scores_raw_score
        CHECK (
            raw_score IS NULL
            OR minimum_output_score IS NULL
            OR maximum_output_score IS NULL
            OR raw_score BETWEEN minimum_output_score
                AND maximum_output_score
        ),

    CONSTRAINT chk_recommendation_factor_scores_normalized_score
        CHECK (
            normalized_score IS NULL
            OR minimum_output_score IS NULL
            OR maximum_output_score IS NULL
            OR normalized_score BETWEEN minimum_output_score
                AND maximum_output_score
        ),

    CONSTRAINT chk_recommendation_factor_scores_neutral_score
        CHECK (
            neutral_output_score IS NULL
            OR minimum_output_score IS NULL
            OR maximum_output_score IS NULL
            OR neutral_output_score BETWEEN minimum_output_score
                AND maximum_output_score
        ),

    CONSTRAINT chk_recommendation_factor_scores_factor_weight
        CHECK (
            factor_weight BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_factor_scores_category_weight
        CHECK (
            category_weight BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_factor_scores_multipliers
        CHECK (
            segment_weight_multiplier BETWEEN 0 AND 100
            AND confidence_multiplier BETWEEN 0 AND 100
            AND completeness_multiplier BETWEEN 0 AND 100
            AND preference_multiplier BETWEEN 0 AND 100
            AND penalty_multiplier BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_factor_scores_penalty_score
        CHECK (
            penalty_score >= 0
        ),

    CONSTRAINT chk_recommendation_factor_scores_bonus_score
        CHECK (
            bonus_score >= 0
        ),

    CONSTRAINT chk_recommendation_factor_scores_confidence
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_factor_scores_completeness
        CHECK (
            data_completeness_score IS NULL
            OR data_completeness_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_factor_scores_status
        CHECK (
            evaluation_status IN (
                'PENDING',
                'PROCESSING',
                'COMPLETED',
                'PARTIALLY_COMPLETED',
                'SKIPPED',
                'FAILED',
                'CANCELLED'
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_method
        CHECK (
            evaluation_method IN (
                'RULE_BASED',
                'CALCULATED',
                'THRESHOLD',
                'BAND_BASED',
                'FORMULA',
                'MANUAL',
                'AI_ASSISTED',
                'HYBRID',
                'IMPORTED',
                'TEST'
            )
        ),

    CONSTRAINT chk_recommendation_factor_scores_version
        CHECK (
            length(trim(evaluation_version)) > 0
        ),

    CONSTRAINT chk_recommendation_factor_scores_sequence
        CHECK (
            evaluation_sequence IS NULL
            OR evaluation_sequence > 0
        ),

    CONSTRAINT chk_recommendation_factor_scores_execution_duration
        CHECK (
            execution_duration_ms IS NULL
            OR execution_duration_ms >= 0
        ),

    CONSTRAINT chk_recommendation_factor_scores_calculation_details
        CHECK (
            jsonb_typeof(calculation_details) = 'object'
        ),

    CONSTRAINT chk_recommendation_factor_scores_applied_conditions
        CHECK (
            jsonb_typeof(applied_conditions) = 'object'
        ),

    CONSTRAINT chk_recommendation_factor_scores_scoring_band
        CHECK (
            jsonb_typeof(scoring_band) = 'object'
        ),

    CONSTRAINT chk_recommendation_factor_scores_evidence
        CHECK (
            jsonb_typeof(evidence) = 'array'
        ),

    CONSTRAINT chk_recommendation_factor_scores_warnings
        CHECK (
            jsonb_typeof(warnings) = 'array'
        ),

    CONSTRAINT chk_recommendation_factor_scores_errors
        CHECK (
            jsonb_typeof(errors) = 'array'
        ),

    CONSTRAINT chk_recommendation_factor_scores_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE INDEX idx_recommendation_factor_scores_run
ON public.recommendation_factor_scores(recommendation_run_id);

CREATE INDEX idx_recommendation_factor_scores_run_card
ON public.recommendation_factor_scores(recommendation_run_card_id);

CREATE INDEX idx_recommendation_factor_scores_result
ON public.recommendation_factor_scores(recommendation_result_id)
WHERE recommendation_result_id IS NOT NULL;

CREATE INDEX idx_recommendation_factor_scores_model
ON public.recommendation_factor_scores(recommendation_model_id);

CREATE INDEX idx_recommendation_factor_scores_model_factor
ON public.recommendation_factor_scores(
    recommendation_model_factor_id
);

CREATE INDEX idx_recommendation_factor_scores_card
ON public.recommendation_factor_scores(card_id);

CREATE INDEX idx_recommendation_factor_scores_factor_code
ON public.recommendation_factor_scores(
    factor_code,
    factor_category
);

CREATE INDEX idx_recommendation_factor_scores_run_card_category
ON public.recommendation_factor_scores(
    recommendation_run_card_id,
    factor_category,
    evaluation_sequence
);

CREATE INDEX idx_recommendation_factor_scores_run_card_contribution
ON public.recommendation_factor_scores(
    recommendation_run_card_id,
    final_score_contribution DESC
)
WHERE factor_applied = TRUE
  AND factor_skipped = FALSE;

CREATE INDEX idx_recommendation_factor_scores_positive_contribution
ON public.recommendation_factor_scores(
    recommendation_run_card_id,
    final_score_contribution DESC
)
WHERE final_score_contribution > 0
  AND factor_applied = TRUE;

CREATE INDEX idx_recommendation_factor_scores_negative_contribution
ON public.recommendation_factor_scores(
    recommendation_run_card_id,
    final_score_contribution
)
WHERE final_score_contribution < 0
  AND factor_applied = TRUE;

CREATE INDEX idx_recommendation_factor_scores_penalties
ON public.recommendation_factor_scores(
    recommendation_run_card_id,
    penalty_score DESC
)
WHERE penalty_score > 0;

CREATE INDEX idx_recommendation_factor_scores_bonuses
ON public.recommendation_factor_scores(
    recommendation_run_card_id,
    bonus_score DESC
)
WHERE bonus_score > 0;

CREATE INDEX idx_recommendation_factor_scores_hard_requirements
ON public.recommendation_factor_scores(
    recommendation_run_card_id,
    factor_code
)
WHERE hard_requirement = TRUE;

CREATE INDEX idx_recommendation_factor_scores_failed_hard_requirements
ON public.recommendation_factor_scores(
    recommendation_run_card_id,
    factor_code
)
WHERE hard_requirement = TRUE
  AND hard_requirement_satisfied = FALSE;

CREATE INDEX idx_recommendation_factor_scores_exclusions
ON public.recommendation_factor_scores(
    recommendation_run_card_id,
    exclusion_reason
)
WHERE exclusion_triggered = TRUE;

CREATE INDEX idx_recommendation_factor_scores_missing
ON public.recommendation_factor_scores(
    recommendation_run_card_id,
    factor_code
)
WHERE missing_value = TRUE;

CREATE INDEX idx_recommendation_factor_scores_failed
ON public.recommendation_factor_scores(
    recommendation_run_id,
    evaluated_at DESC
)
WHERE factor_failed = TRUE;

CREATE INDEX idx_recommendation_factor_scores_source
ON public.recommendation_factor_scores(
    source_entity,
    source_record_id
)
WHERE source_record_id IS NOT NULL;

CREATE INDEX idx_recommendation_factor_scores_customer_visible
ON public.recommendation_factor_scores(
    recommendation_result_id,
    factor_category,
    evaluation_sequence
)
WHERE is_visible_to_customer = TRUE
  AND recommendation_result_id IS NOT NULL;

CREATE INDEX idx_recommendation_factor_scores_advisor_visible
ON public.recommendation_factor_scores(
    recommendation_result_id,
    factor_category,
    evaluation_sequence
)
WHERE is_visible_to_advisor = TRUE
  AND recommendation_result_id IS NOT NULL;

CREATE INDEX idx_recommendation_factor_scores_evaluated_at
ON public.recommendation_factor_scores(evaluated_at DESC);

CREATE INDEX idx_recommendation_factor_scores_raw_json
ON public.recommendation_factor_scores
USING GIN (raw_json_value)
WHERE raw_json_value IS NOT NULL;

CREATE INDEX idx_recommendation_factor_scores_calculation_details
ON public.recommendation_factor_scores
USING GIN (calculation_details);

CREATE INDEX idx_recommendation_factor_scores_applied_conditions
ON public.recommendation_factor_scores
USING GIN (applied_conditions);

CREATE INDEX idx_recommendation_factor_scores_scoring_band
ON public.recommendation_factor_scores
USING GIN (scoring_band);

CREATE INDEX idx_recommendation_factor_scores_evidence
ON public.recommendation_factor_scores
USING GIN (evidence);

CREATE INDEX idx_recommendation_factor_scores_warnings
ON public.recommendation_factor_scores
USING GIN (warnings);

CREATE INDEX idx_recommendation_factor_scores_errors
ON public.recommendation_factor_scores
USING GIN (errors);

CREATE INDEX idx_recommendation_factor_scores_metadata
ON public.recommendation_factor_scores
USING GIN (metadata);

CREATE TRIGGER trg_recommendation_factor_scores_updated_at
BEFORE UPDATE
ON public.recommendation_factor_scores
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.recommendation_factor_scores IS
'Normalized factor-level scoring records showing how each recommendation model factor contributed to a card recommendation result.';

COMMENT ON COLUMN public.recommendation_factor_scores.recommendation_model_factor_id IS
'Recommendation model factor definition used to evaluate the card.';

COMMENT ON COLUMN public.recommendation_factor_scores.raw_numeric_value IS
'Original numeric value retrieved or calculated before normalization.';

COMMENT ON COLUMN public.recommendation_factor_scores.normalized_numeric_value IS
'Numeric value after applying transformation or normalization rules.';

COMMENT ON COLUMN public.recommendation_factor_scores.raw_score IS
'Initial score generated by the factor before weighting and model adjustments.';

COMMENT ON COLUMN public.recommendation_factor_scores.normalized_score IS
'Factor score normalized to the configured output range.';

COMMENT ON COLUMN public.recommendation_factor_scores.factor_weight IS
'Weight assigned to the individual factor by the recommendation model.';

COMMENT ON COLUMN public.recommendation_factor_scores.category_weight IS
'Weight assigned to the factor business category, such as financial value, rewards, fees, or preferences.';

COMMENT ON COLUMN public.recommendation_factor_scores.segment_weight_multiplier IS
'Weight multiplier applied when the customer matches a recommendation model segment.';

COMMENT ON COLUMN public.recommendation_factor_scores.confidence_multiplier IS
'Multiplier applied according to the confidence level of the factor input data.';

COMMENT ON COLUMN public.recommendation_factor_scores.completeness_multiplier IS
'Multiplier applied according to the completeness of the required input data.';

COMMENT ON COLUMN public.recommendation_factor_scores.preference_multiplier IS
'Multiplier applied when the factor is affected by customer preferences or preference importance.';

COMMENT ON COLUMN public.recommendation_factor_scores.weighted_score IS
'Factor score after applying the configured factor and category weights.';

COMMENT ON COLUMN public.recommendation_factor_scores.adjusted_score IS
'Weighted score after applying confidence, completeness, preference, segment, penalty, and bonus adjustments.';

COMMENT ON COLUMN public.recommendation_factor_scores.final_score_contribution IS
'Final positive or negative contribution of the factor to the card recommendation score.';

COMMENT ON COLUMN public.recommendation_factor_scores.exclusion_triggered IS
'Indicates that failure of this factor caused the card to be excluded from recommendation results.';

COMMENT ON COLUMN public.recommendation_factor_scores.calculation_details IS
'Structured details describing the formulas, intermediate values, multipliers, and calculations used to produce the factor score.';

COMMENT ON COLUMN public.recommendation_factor_scores.evidence IS
'Structured references and values supporting the factor evaluation and score.';

COMMENT ON COLUMN public.recommendation_factor_scores.is_visible_to_customer IS
'Controls whether this detailed factor score may be displayed directly in customer-facing applications.';
