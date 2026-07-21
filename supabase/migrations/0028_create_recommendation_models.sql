CREATE TABLE public.recommendation_models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    model_code TEXT NOT NULL,

    model_name_en TEXT NOT NULL,

    model_name_ar TEXT,

    description_en TEXT,

    description_ar TEXT,

    model_type public.recommendation_model_type NOT NULL,

    model_version TEXT NOT NULL DEFAULT '1.0',

    model_status TEXT NOT NULL DEFAULT 'DRAFT',

    scoring_scale_min NUMERIC(9, 4) NOT NULL DEFAULT 0,

    scoring_scale_max NUMERIC(9, 4) NOT NULL DEFAULT 100,

    minimum_recommendation_score NUMERIC(9, 4),

    minimum_confidence_score NUMERIC(5, 2),

    maximum_results INTEGER NOT NULL DEFAULT 10,

    eligibility_weight NUMERIC(9, 6) NOT NULL DEFAULT 0,

    financial_value_weight NUMERIC(9, 6) NOT NULL DEFAULT 0,

    rewards_weight NUMERIC(9, 6) NOT NULL DEFAULT 0,

    fees_weight NUMERIC(9, 6) NOT NULL DEFAULT 0,

    preference_weight NUMERIC(9, 6) NOT NULL DEFAULT 0,

    travel_weight NUMERIC(9, 6) NOT NULL DEFAULT 0,

    lifestyle_weight NUMERIC(9, 6) NOT NULL DEFAULT 0,

    simplicity_weight NUMERIC(9, 6) NOT NULL DEFAULT 0,

    bank_relationship_weight NUMERIC(9, 6) NOT NULL DEFAULT 0,

    confidence_weight NUMERIC(9, 6) NOT NULL DEFAULT 0,

    enforce_hard_eligibility BOOLEAN NOT NULL DEFAULT TRUE,

    exclude_ineligible_cards BOOLEAN NOT NULL DEFAULT TRUE,

    exclude_unknown_eligibility BOOLEAN NOT NULL DEFAULT FALSE,

    exclude_expired_products BOOLEAN NOT NULL DEFAULT TRUE,

    exclude_inactive_products BOOLEAN NOT NULL DEFAULT TRUE,

    exclude_preference_conflicts BOOLEAN NOT NULL DEFAULT TRUE,

    require_value_simulation BOOLEAN NOT NULL DEFAULT TRUE,

    require_spending_profile BOOLEAN NOT NULL DEFAULT FALSE,

    require_preference_profile BOOLEAN NOT NULL DEFAULT FALSE,

    allow_manual_review_results BOOLEAN NOT NULL DEFAULT TRUE,

    allow_conditionally_eligible_results BOOLEAN NOT NULL DEFAULT TRUE,

    apply_confidence_adjustment BOOLEAN NOT NULL DEFAULT TRUE,

    apply_data_completeness_adjustment BOOLEAN NOT NULL DEFAULT TRUE,

    apply_benefit_utilization_adjustment BOOLEAN NOT NULL DEFAULT TRUE,

    apply_reward_utilization_adjustment BOOLEAN NOT NULL DEFAULT TRUE,

    rank_by TEXT NOT NULL DEFAULT 'FINAL_SCORE',

    tie_breaker_strategy TEXT NOT NULL DEFAULT 'NET_VALUE',

    score_normalization_method TEXT NOT NULL DEFAULT 'MIN_MAX',

    missing_value_strategy TEXT NOT NULL DEFAULT 'NEUTRAL',

    negative_value_strategy TEXT NOT NULL DEFAULT 'ALLOW',

    configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    scoring_formula JSONB NOT NULL DEFAULT '{}'::JSONB,

    eligibility_rules JSONB NOT NULL DEFAULT '{}'::JSONB,

    exclusion_rules JSONB NOT NULL DEFAULT '{}'::JSONB,

    confidence_rules JSONB NOT NULL DEFAULT '{}'::JSONB,

    explanation_rules JSONB NOT NULL DEFAULT '{}'::JSONB,

    methodology_notes_en TEXT,

    methodology_notes_ar TEXT,

    effective_from TIMESTAMPTZ,

    effective_to TIMESTAMPTZ,

    published_at TIMESTAMPTZ,

    retired_at TIMESTAMPTZ,

    created_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    approved_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    approved_at TIMESTAMPTZ,

    is_default BOOLEAN NOT NULL DEFAULT FALSE,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_recommendation_models_code_version
        UNIQUE (
            model_code,
            model_version
        ),

    CONSTRAINT chk_recommendation_models_code
        CHECK (
            model_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_models_name_en
        CHECK (
            length(trim(model_name_en)) > 0
        ),

    CONSTRAINT chk_recommendation_models_name_ar
        CHECK (
            model_name_ar IS NULL
            OR length(trim(model_name_ar)) > 0
        ),

    CONSTRAINT chk_recommendation_models_version
        CHECK (
            length(trim(model_version)) > 0
        ),

    CONSTRAINT chk_recommendation_models_status
        CHECK (
            model_status IN (
                'DRAFT',
                'TESTING',
                'ACTIVE',
                'SUSPENDED',
                'RETIRED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_recommendation_models_scoring_scale
        CHECK (
            scoring_scale_max > scoring_scale_min
        ),

    CONSTRAINT chk_recommendation_models_minimum_score
        CHECK (
            minimum_recommendation_score IS NULL
            OR minimum_recommendation_score
                BETWEEN scoring_scale_min AND scoring_scale_max
        ),

    CONSTRAINT chk_recommendation_models_minimum_confidence
        CHECK (
            minimum_confidence_score IS NULL
            OR minimum_confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_models_maximum_results
        CHECK (
            maximum_results > 0
            AND maximum_results <= 1000
        ),

    CONSTRAINT chk_recommendation_models_weights
        CHECK (
            eligibility_weight BETWEEN 0 AND 100
            AND financial_value_weight BETWEEN 0 AND 100
            AND rewards_weight BETWEEN 0 AND 100
            AND fees_weight BETWEEN 0 AND 100
            AND preference_weight BETWEEN 0 AND 100
            AND travel_weight BETWEEN 0 AND 100
            AND lifestyle_weight BETWEEN 0 AND 100
            AND simplicity_weight BETWEEN 0 AND 100
            AND bank_relationship_weight BETWEEN 0 AND 100
            AND confidence_weight BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_models_weight_total
        CHECK (
            eligibility_weight
            + financial_value_weight
            + rewards_weight
            + fees_weight
            + preference_weight
            + travel_weight
            + lifestyle_weight
            + simplicity_weight
            + bank_relationship_weight
            + confidence_weight
            > 0
        ),

    CONSTRAINT chk_recommendation_models_rank_by
        CHECK (
            rank_by IN (
                'FINAL_SCORE',
                'NET_VALUE',
                'ELIGIBILITY_SCORE',
                'REWARD_VALUE',
                'PREFERENCE_SCORE',
                'CONFIDENCE_SCORE',
                'HYBRID'
            )
        ),

    CONSTRAINT chk_recommendation_models_tie_breaker
        CHECK (
            tie_breaker_strategy IN (
                'NET_VALUE',
                'LOWEST_ANNUAL_FEE',
                'HIGHEST_CONFIDENCE',
                'HIGHEST_ELIGIBILITY',
                'HIGHEST_REWARD_VALUE',
                'HIGHEST_PREFERENCE_MATCH',
                'CARD_NAME'
            )
        ),

    CONSTRAINT chk_recommendation_models_normalization
        CHECK (
            score_normalization_method IN (
                'NONE',
                'MIN_MAX',
                'Z_SCORE',
                'PERCENTILE',
                'ABSOLUTE_SCALE',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_recommendation_models_missing_value
        CHECK (
            missing_value_strategy IN (
                'ZERO',
                'NEUTRAL',
                'EXCLUDE_FACTOR',
                'PENALIZE',
                'EXCLUDE_CARD',
                'MANUAL_REVIEW'
            )
        ),

    CONSTRAINT chk_recommendation_models_negative_value
        CHECK (
            negative_value_strategy IN (
                'ALLOW',
                'FLOOR_AT_ZERO',
                'PENALIZE',
                'EXCLUDE_CARD'
            )
        ),

    CONSTRAINT chk_recommendation_models_effective_dates
        CHECK (
            effective_from IS NULL
            OR effective_to IS NULL
            OR effective_to >= effective_from
        ),

    CONSTRAINT chk_recommendation_models_published
        CHECK (
            published_at IS NULL
            OR model_status IN (
                'ACTIVE',
                'SUSPENDED',
                'RETIRED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_recommendation_models_retired
        CHECK (
            retired_at IS NULL
            OR model_status IN (
                'RETIRED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_recommendation_models_approval
        CHECK (
            approved_at IS NULL
            OR approved_by IS NOT NULL
        ),

    CONSTRAINT chk_recommendation_models_configuration
        CHECK (
            jsonb_typeof(configuration) = 'object'
        ),

    CONSTRAINT chk_recommendation_models_scoring_formula
        CHECK (
            jsonb_typeof(scoring_formula) = 'object'
        ),

    CONSTRAINT chk_recommendation_models_eligibility_rules
        CHECK (
            jsonb_typeof(eligibility_rules) = 'object'
        ),

    CONSTRAINT chk_recommendation_models_exclusion_rules
        CHECK (
            jsonb_typeof(exclusion_rules) = 'object'
        ),

    CONSTRAINT chk_recommendation_models_confidence_rules
        CHECK (
            jsonb_typeof(confidence_rules) = 'object'
        ),

    CONSTRAINT chk_recommendation_models_explanation_rules
        CHECK (
            jsonb_typeof(explanation_rules) = 'object'
        ),

    CONSTRAINT chk_recommendation_models_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.recommendation_model_factors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    recommendation_model_id UUID NOT NULL
        REFERENCES public.recommendation_models(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    factor_code TEXT NOT NULL,

    factor_name_en TEXT NOT NULL,

    factor_name_ar TEXT,

    description_en TEXT,

    description_ar TEXT,

    factor_category TEXT NOT NULL,

    source_entity TEXT NOT NULL,

    source_field TEXT,

    source_expression TEXT,

    factor_value_type TEXT NOT NULL DEFAULT 'NUMERIC',

    factor_direction TEXT NOT NULL DEFAULT 'HIGHER_IS_BETTER',

    weight NUMERIC(9, 6) NOT NULL DEFAULT 1,

    minimum_input_value NUMERIC(18, 6),

    maximum_input_value NUMERIC(18, 6),

    target_input_value NUMERIC(18, 6),

    minimum_output_score NUMERIC(9, 4) NOT NULL DEFAULT 0,

    maximum_output_score NUMERIC(9, 4) NOT NULL DEFAULT 100,

    neutral_output_score NUMERIC(9, 4),

    normalization_method TEXT NOT NULL DEFAULT 'MIN_MAX',

    missing_value_strategy TEXT NOT NULL DEFAULT 'NEUTRAL',

    missing_value_score NUMERIC(9, 4),

    threshold_value NUMERIC(18, 6),

    threshold_operator TEXT,

    threshold_score NUMERIC(9, 4),

    hard_requirement BOOLEAN NOT NULL DEFAULT FALSE,

    exclusion_if_failed BOOLEAN NOT NULL DEFAULT FALSE,

    confidence_sensitive BOOLEAN NOT NULL DEFAULT TRUE,

    completeness_sensitive BOOLEAN NOT NULL DEFAULT TRUE,

    preference_sensitive BOOLEAN NOT NULL DEFAULT FALSE,

    apply_only_when JSONB NOT NULL DEFAULT '{}'::JSONB,

    scoring_parameters JSONB NOT NULL DEFAULT '{}'::JSONB,

    scoring_bands JSONB NOT NULL DEFAULT '[]'::JSONB,

    explanation_template_en TEXT,

    explanation_template_ar TEXT,

    failure_explanation_en TEXT,

    failure_explanation_ar TEXT,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_recommendation_model_factors_model_code
        UNIQUE (
            recommendation_model_id,
            factor_code
        ),

    CONSTRAINT chk_recommendation_model_factors_code
        CHECK (
            factor_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_model_factors_name_en
        CHECK (
            length(trim(factor_name_en)) > 0
        ),

    CONSTRAINT chk_recommendation_model_factors_name_ar
        CHECK (
            factor_name_ar IS NULL
            OR length(trim(factor_name_ar)) > 0
        ),

    CONSTRAINT chk_recommendation_model_factors_category
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

    CONSTRAINT chk_recommendation_model_factors_source_entity
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

    CONSTRAINT chk_recommendation_model_factors_source_field
        CHECK (
            source_field IS NULL
            OR length(trim(source_field)) > 0
        ),

    CONSTRAINT chk_recommendation_model_factors_source_expression
        CHECK (
            source_expression IS NULL
            OR length(trim(source_expression)) > 0
        ),

    CONSTRAINT chk_recommendation_model_factors_value_type
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

    CONSTRAINT chk_recommendation_model_factors_direction
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

    CONSTRAINT chk_recommendation_model_factors_weight
        CHECK (
            weight BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_model_factors_input_range
        CHECK (
            minimum_input_value IS NULL
            OR maximum_input_value IS NULL
            OR maximum_input_value >= minimum_input_value
        ),

    CONSTRAINT chk_recommendation_model_factors_target_minimum
        CHECK (
            target_input_value IS NULL
            OR minimum_input_value IS NULL
            OR target_input_value >= minimum_input_value
        ),

    CONSTRAINT chk_recommendation_model_factors_target_maximum
        CHECK (
            target_input_value IS NULL
            OR maximum_input_value IS NULL
            OR target_input_value <= maximum_input_value
        ),

    CONSTRAINT chk_recommendation_model_factors_output_range
        CHECK (
            maximum_output_score > minimum_output_score
        ),

    CONSTRAINT chk_recommendation_model_factors_neutral_score
        CHECK (
            neutral_output_score IS NULL
            OR neutral_output_score
                BETWEEN minimum_output_score AND maximum_output_score
        ),

    CONSTRAINT chk_recommendation_model_factors_normalization
        CHECK (
            normalization_method IN (
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

    CONSTRAINT chk_recommendation_model_factors_missing_strategy
        CHECK (
            missing_value_strategy IN (
                'ZERO',
                'NEUTRAL',
                'EXCLUDE_FACTOR',
                'PENALIZE',
                'EXCLUDE_CARD',
                'MANUAL_REVIEW',
                'USE_DEFAULT'
            )
        ),

    CONSTRAINT chk_recommendation_model_factors_missing_score
        CHECK (
            missing_value_score IS NULL
            OR missing_value_score
                BETWEEN minimum_output_score AND maximum_output_score
        ),

    CONSTRAINT chk_recommendation_model_factors_threshold_operator
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

    CONSTRAINT chk_recommendation_model_factors_threshold_definition
        CHECK (
            threshold_value IS NULL
            OR threshold_operator IS NOT NULL
        ),

    CONSTRAINT chk_recommendation_model_factors_threshold_score
        CHECK (
            threshold_score IS NULL
            OR threshold_score
                BETWEEN minimum_output_score AND maximum_output_score
        ),

    CONSTRAINT chk_recommendation_model_factors_exclusion
        CHECK (
            exclusion_if_failed = FALSE
            OR hard_requirement = TRUE
        ),

    CONSTRAINT chk_recommendation_model_factors_priority
        CHECK (
            priority > 0
        ),

    CONSTRAINT chk_recommendation_model_factors_apply_only_when
        CHECK (
            jsonb_typeof(apply_only_when) = 'object'
        ),

    CONSTRAINT chk_recommendation_model_factors_scoring_parameters
        CHECK (
            jsonb_typeof(scoring_parameters) = 'object'
        ),

    CONSTRAINT chk_recommendation_model_factors_scoring_bands
        CHECK (
            jsonb_typeof(scoring_bands) = 'array'
        ),

    CONSTRAINT chk_recommendation_model_factors_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.recommendation_model_segments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    recommendation_model_id UUID NOT NULL
        REFERENCES public.recommendation_models(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    segment_code TEXT NOT NULL,

    segment_name_en TEXT NOT NULL,

    segment_name_ar TEXT,

    description_en TEXT,

    description_ar TEXT,

    customer_segment TEXT,

    minimum_monthly_income NUMERIC(14, 2),

    maximum_monthly_income NUMERIC(14, 2),

    income_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    minimum_annual_spend NUMERIC(16, 2),

    maximum_annual_spend NUMERIC(16, 2),

    spend_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    preference_strategy TEXT,

    employment_statuses TEXT[],

    employment_sectors TEXT[],

    nationality_country_codes TEXT[],

    residence_country_codes TEXT[],

    required_conditions JSONB NOT NULL DEFAULT '{}'::JSONB,

    weight_overrides JSONB NOT NULL DEFAULT '{}'::JSONB,

    configuration_overrides JSONB NOT NULL DEFAULT '{}'::JSONB,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_recommendation_model_segments_model_code
        UNIQUE (
            recommendation_model_id,
            segment_code
        ),

    CONSTRAINT chk_recommendation_model_segments_code
        CHECK (
            segment_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_model_segments_name_en
        CHECK (
            length(trim(segment_name_en)) > 0
        ),

    CONSTRAINT chk_recommendation_model_segments_income_range
        CHECK (
            (
                minimum_monthly_income IS NULL
                OR minimum_monthly_income >= 0
            )
            AND
            (
                maximum_monthly_income IS NULL
                OR maximum_monthly_income >= 0
            )
            AND
            (
                minimum_monthly_income IS NULL
                OR maximum_monthly_income IS NULL
                OR maximum_monthly_income >= minimum_monthly_income
            )
        ),

    CONSTRAINT chk_recommendation_model_segments_income_currency
        CHECK (
            (
                minimum_monthly_income IS NULL
                AND maximum_monthly_income IS NULL
                AND income_currency_id IS NULL
            )
            OR
            (
                income_currency_id IS NOT NULL
                AND (
                    minimum_monthly_income IS NOT NULL
                    OR maximum_monthly_income IS NOT NULL
                )
            )
        ),

    CONSTRAINT chk_recommendation_model_segments_spend_range
        CHECK (
            (
                minimum_annual_spend IS NULL
                OR minimum_annual_spend >= 0
            )
            AND
            (
                maximum_annual_spend IS NULL
                OR maximum_annual_spend >= 0
            )
            AND
            (
                minimum_annual_spend IS NULL
                OR maximum_annual_spend IS NULL
                OR maximum_annual_spend >= minimum_annual_spend
            )
        ),

    CONSTRAINT chk_recommendation_model_segments_spend_currency
        CHECK (
            (
                minimum_annual_spend IS NULL
                AND maximum_annual_spend IS NULL
                AND spend_currency_id IS NULL
            )
            OR
            (
                spend_currency_id IS NOT NULL
                AND (
                    minimum_annual_spend IS NOT NULL
                    OR maximum_annual_spend IS NOT NULL
                )
            )
        ),

    CONSTRAINT chk_recommendation_model_segments_strategy
        CHECK (
            preference_strategy IS NULL
            OR preference_strategy IN (
                'BALANCED',
                'MAXIMIZE_NET_VALUE',
                'MAXIMIZE_REWARDS',
                'MAXIMIZE_CASHBACK',
                'MAXIMIZE_TRAVEL_VALUE',
                'MINIMIZE_FEES',
                'PREMIUM_LIFESTYLE',
                'BUSINESS_SPENDING',
                'SIMPLE_USAGE',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_recommendation_model_segments_employment_statuses
        CHECK (
            employment_statuses IS NULL
            OR cardinality(employment_statuses) > 0
        ),

    CONSTRAINT chk_recommendation_model_segments_employment_sectors
        CHECK (
            employment_sectors IS NULL
            OR cardinality(employment_sectors) > 0
        ),

    CONSTRAINT chk_recommendation_model_segments_nationalities
        CHECK (
            nationality_country_codes IS NULL
            OR cardinality(nationality_country_codes) > 0
        ),

    CONSTRAINT chk_recommendation_model_segments_residences
        CHECK (
            residence_country_codes IS NULL
            OR cardinality(residence_country_codes) > 0
        ),

    CONSTRAINT chk_recommendation_model_segments_priority
        CHECK (
            priority > 0
        ),

    CONSTRAINT chk_recommendation_model_segments_conditions
        CHECK (
            jsonb_typeof(required_conditions) = 'object'
        ),

    CONSTRAINT chk_recommendation_model_segments_weights
        CHECK (
            jsonb_typeof(weight_overrides) = 'object'
        ),

    CONSTRAINT chk_recommendation_model_segments_configuration
        CHECK (
            jsonb_typeof(configuration_overrides) = 'object'
        ),

    CONSTRAINT chk_recommendation_model_segments_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE INDEX idx_recommendation_models_type
ON public.recommendation_models(model_type);

CREATE INDEX idx_recommendation_models_status
ON public.recommendation_models(
    model_status,
    is_active
);

CREATE INDEX idx_recommendation_models_effective
ON public.recommendation_models(
    effective_from,
    effective_to
)
WHERE is_active = TRUE;

CREATE INDEX idx_recommendation_models_default
ON public.recommendation_models(
    model_type,
    model_version
)
WHERE is_default = TRUE
  AND is_active = TRUE;

CREATE UNIQUE INDEX uq_recommendation_models_default_type
ON public.recommendation_models(model_type)
WHERE is_default = TRUE
  AND is_active = TRUE
  AND model_status = 'ACTIVE';

CREATE INDEX idx_recommendation_models_created_by
ON public.recommendation_models(created_by)
WHERE created_by IS NOT NULL;

CREATE INDEX idx_recommendation_models_approved_by
ON public.recommendation_models(approved_by)
WHERE approved_by IS NOT NULL;

CREATE INDEX idx_recommendation_models_configuration
ON public.recommendation_models
USING GIN (configuration);

CREATE INDEX idx_recommendation_models_scoring_formula
ON public.recommendation_models
USING GIN (scoring_formula);

CREATE INDEX idx_recommendation_models_eligibility_rules
ON public.recommendation_models
USING GIN (eligibility_rules);

CREATE INDEX idx_recommendation_models_exclusion_rules
ON public.recommendation_models
USING GIN (exclusion_rules);

CREATE INDEX idx_recommendation_models_confidence_rules
ON public.recommendation_models
USING GIN (confidence_rules);

CREATE INDEX idx_recommendation_models_explanation_rules
ON public.recommendation_models
USING GIN (explanation_rules);

CREATE INDEX idx_recommendation_models_metadata
ON public.recommendation_models
USING GIN (metadata);

CREATE INDEX idx_recommendation_model_factors_model
ON public.recommendation_model_factors(recommendation_model_id);

CREATE INDEX idx_recommendation_model_factors_category
ON public.recommendation_model_factors(
    recommendation_model_id,
    factor_category,
    priority
);

CREATE INDEX idx_recommendation_model_factors_source
ON public.recommendation_model_factors(
    source_entity,
    source_field
);

CREATE INDEX idx_recommendation_model_factors_active
ON public.recommendation_model_factors(
    recommendation_model_id,
    priority,
    factor_code
)
WHERE is_active = TRUE;

CREATE INDEX idx_recommendation_model_factors_hard
ON public.recommendation_model_factors(
    recommendation_model_id,
    factor_code
)
WHERE hard_requirement = TRUE
  AND is_active = TRUE;

CREATE INDEX idx_recommendation_model_factors_exclusion
ON public.recommendation_model_factors(
    recommendation_model_id,
    factor_code
)
WHERE exclusion_if_failed = TRUE
  AND is_active = TRUE;

CREATE INDEX idx_recommendation_model_factors_conditions
ON public.recommendation_model_factors
USING GIN (apply_only_when);

CREATE INDEX idx_recommendation_model_factors_parameters
ON public.recommendation_model_factors
USING GIN (scoring_parameters);

CREATE INDEX idx_recommendation_model_factors_bands
ON public.recommendation_model_factors
USING GIN (scoring_bands);

CREATE INDEX idx_recommendation_model_factors_metadata
ON public.recommendation_model_factors
USING GIN (metadata);

CREATE INDEX idx_recommendation_model_segments_model
ON public.recommendation_model_segments(recommendation_model_id);

CREATE INDEX idx_recommendation_model_segments_customer_segment
ON public.recommendation_model_segments(customer_segment)
WHERE customer_segment IS NOT NULL;

CREATE INDEX idx_recommendation_model_segments_strategy
ON public.recommendation_model_segments(preference_strategy)
WHERE preference_strategy IS NOT NULL;

CREATE INDEX idx_recommendation_model_segments_active
ON public.recommendation_model_segments(
    recommendation_model_id,
    priority,
    segment_code
)
WHERE is_active = TRUE;

CREATE INDEX idx_recommendation_model_segments_conditions
ON public.recommendation_model_segments
USING GIN (required_conditions);

CREATE INDEX idx_recommendation_model_segments_weights
ON public.recommendation_model_segments
USING GIN (weight_overrides);

CREATE INDEX idx_recommendation_model_segments_configuration
ON public.recommendation_model_segments
USING GIN (configuration_overrides);

CREATE INDEX idx_recommendation_model_segments_metadata
ON public.recommendation_model_segments
USING GIN (metadata);

CREATE TRIGGER trg_recommendation_models_updated_at
BEFORE UPDATE
ON public.recommendation_models
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_recommendation_model_factors_updated_at
BEFORE UPDATE
ON public.recommendation_model_factors
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_recommendation_model_segments_updated_at
BEFORE UPDATE
ON public.recommendation_model_segments
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.recommendation_models IS
'Versioned recommendation model definitions containing scoring weights, filtering behavior, ranking strategies, confidence handling, and explanation configuration.';

COMMENT ON TABLE public.recommendation_model_factors IS
'Individual measurable factors used by a recommendation model to score, penalize, filter, or explain card recommendations.';

COMMENT ON TABLE public.recommendation_model_segments IS
'Optional customer segments that override recommendation model weights or configuration for specific financial and behavioral profiles.';

COMMENT ON COLUMN public.recommendation_models.model_type IS
'Classification of the recommendation model, such as rule-based, weighted scoring, financial value, preference matching, or hybrid.';

COMMENT ON COLUMN public.recommendation_models.is_default IS
'Identifies the active default model for its model type. Only one active default model is permitted per type.';

COMMENT ON COLUMN public.recommendation_models.minimum_recommendation_score IS
'Minimum normalized score required for a card to be included as a positive recommendation.';

COMMENT ON COLUMN public.recommendation_models.apply_confidence_adjustment IS
'Indicates whether recommendation scores should be adjusted based on the confidence of customer and product data.';

COMMENT ON COLUMN public.recommendation_models.scoring_formula IS
'Structured configuration describing how component scores are combined into the final recommendation score.';

COMMENT ON COLUMN public.recommendation_model_factors.weight IS
'Relative contribution of the factor within the recommendation model before normalization and adjustments.';

COMMENT ON COLUMN public.recommendation_model_factors.factor_direction IS
'Defines whether higher, lower, target-matching, boolean, or custom values produce better recommendation scores.';

COMMENT ON COLUMN public.recommendation_model_factors.apply_only_when IS
'Structured conditions controlling when the factor applies to a customer, card, segment, or recommendation strategy.';

COMMENT ON COLUMN public.recommendation_model_factors.scoring_bands IS
'Ordered score bands used for threshold-based or band-based factor scoring.';

COMMENT ON COLUMN public.recommendation_model_segments.weight_overrides IS
'Overrides applied to model or factor weights when a customer matches the segment.';

COMMENT ON COLUMN public.recommendation_model_segments.configuration_overrides IS
'Overrides applied to the recommendation model configuration when a customer matches the segment.';
