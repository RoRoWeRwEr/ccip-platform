CREATE TABLE public.recommendation_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

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

    eligibility_assessment_id UUID
        REFERENCES public.eligibility_assessments(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    value_simulation_id UUID
        REFERENCES public.card_value_simulations(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_status public.recommendation_result_status NOT NULL,

    exclusion_reason public.recommendation_exclusion_reason,

    recommendation_rank INTEGER,

    final_score NUMERIC(9, 4),

    raw_score NUMERIC(9, 4),

    normalized_score NUMERIC(9, 4),

    confidence_adjusted_score NUMERIC(9, 4),

    eligibility_score NUMERIC(9, 4),

    financial_value_score NUMERIC(9, 4),

    rewards_score NUMERIC(9, 4),

    fees_score NUMERIC(9, 4),

    preference_score NUMERIC(9, 4),

    travel_score NUMERIC(9, 4),

    lifestyle_score NUMERIC(9, 4),

    simplicity_score NUMERIC(9, 4),

    bank_relationship_score NUMERIC(9, 4),

    data_quality_score NUMERIC(9, 4),

    confidence_score NUMERIC(5, 2),

    confidence_level public.recommendation_confidence_level,

    expected_net_value NUMERIC(18, 6),

    expected_total_benefit NUMERIC(18, 6),

    expected_total_cost NUMERIC(18, 6),

    expected_reward_value NUMERIC(18, 6),

    expected_annual_fee NUMERIC(18, 6),

    break_even_spend NUMERIC(18, 6),

    value_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    eligibility_status public.eligibility_assessment_status,

    hard_requirements_satisfied BOOLEAN,

    manual_review_required BOOLEAN NOT NULL DEFAULT FALSE,

    matched_preference_count INTEGER NOT NULL DEFAULT 0,

    unmet_preference_count INTEGER NOT NULL DEFAULT 0,

    hard_preference_conflict_count INTEGER NOT NULL DEFAULT 0,

    primary_reason_code TEXT,

    secondary_reason_codes TEXT[],

    warning_codes TEXT[],

    badge_codes TEXT[],

    result_title_en TEXT,

    result_title_ar TEXT,

    result_summary_en TEXT,

    result_summary_ar TEXT,

    primary_reason_en TEXT,

    primary_reason_ar TEXT,

    value_summary_en TEXT,

    value_summary_ar TEXT,

    eligibility_summary_en TEXT,

    eligibility_summary_ar TEXT,

    preference_summary_en TEXT,

    preference_summary_ar TEXT,

    disclaimer_en TEXT,

    disclaimer_ar TEXT,

    call_to_action_code TEXT,

    call_to_action_label_en TEXT,

    call_to_action_label_ar TEXT,

    call_to_action_url TEXT,

    display_priority SMALLINT NOT NULL DEFAULT 1,

    display_variant TEXT NOT NULL DEFAULT 'STANDARD',

    is_top_recommendation BOOLEAN NOT NULL DEFAULT FALSE,

    is_featured BOOLEAN NOT NULL DEFAULT FALSE,

    is_visible BOOLEAN NOT NULL DEFAULT TRUE,

    is_current BOOLEAN NOT NULL DEFAULT TRUE,

    is_customer_actionable BOOLEAN NOT NULL DEFAULT TRUE,

    scoring_breakdown JSONB NOT NULL DEFAULT '{}'::JSONB,

    preference_matches JSONB NOT NULL DEFAULT '[]'::JSONB,

    preference_conflicts JSONB NOT NULL DEFAULT '[]'::JSONB,

    key_benefits JSONB NOT NULL DEFAULT '[]'::JSONB,

    key_costs JSONB NOT NULL DEFAULT '[]'::JSONB,

    key_tradeoffs JSONB NOT NULL DEFAULT '[]'::JSONB,

    warnings JSONB NOT NULL DEFAULT '[]'::JSONB,

    result_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    presentation_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    published_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_recommendation_results_run_card
        UNIQUE (
            recommendation_run_card_id
        ),

    CONSTRAINT uq_recommendation_results_run_card_product
        UNIQUE (
            recommendation_run_id,
            card_id
        ),

    CONSTRAINT chk_recommendation_results_rank
        CHECK (
            recommendation_rank IS NULL
            OR recommendation_rank > 0
        ),

    CONSTRAINT chk_recommendation_results_raw_score
        CHECK (
            raw_score IS NULL
            OR raw_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_results_normalized_score
        CHECK (
            normalized_score IS NULL
            OR normalized_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_results_adjusted_score
        CHECK (
            confidence_adjusted_score IS NULL
            OR confidence_adjusted_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_results_final_score
        CHECK (
            final_score IS NULL
            OR final_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_results_component_scores
        CHECK (
            (
                eligibility_score IS NULL
                OR eligibility_score BETWEEN 0 AND 100
            )
            AND
            (
                financial_value_score IS NULL
                OR financial_value_score BETWEEN 0 AND 100
            )
            AND
            (
                rewards_score IS NULL
                OR rewards_score BETWEEN 0 AND 100
            )
            AND
            (
                fees_score IS NULL
                OR fees_score BETWEEN 0 AND 100
            )
            AND
            (
                preference_score IS NULL
                OR preference_score BETWEEN 0 AND 100
            )
            AND
            (
                travel_score IS NULL
                OR travel_score BETWEEN 0 AND 100
            )
            AND
            (
                lifestyle_score IS NULL
                OR lifestyle_score BETWEEN 0 AND 100
            )
            AND
            (
                simplicity_score IS NULL
                OR simplicity_score BETWEEN 0 AND 100
            )
            AND
            (
                bank_relationship_score IS NULL
                OR bank_relationship_score BETWEEN 0 AND 100
            )
            AND
            (
                data_quality_score IS NULL
                OR data_quality_score BETWEEN 0 AND 100
            )
        ),

    CONSTRAINT chk_recommendation_results_confidence
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_results_value_amounts
        CHECK (
            (
                expected_total_benefit IS NULL
                OR expected_total_benefit >= 0
            )
            AND
            (
                expected_total_cost IS NULL
                OR expected_total_cost >= 0
            )
            AND
            (
                expected_reward_value IS NULL
                OR expected_reward_value >= 0
            )
            AND
            (
                expected_annual_fee IS NULL
                OR expected_annual_fee >= 0
            )
            AND
            (
                break_even_spend IS NULL
                OR break_even_spend >= 0
            )
        ),

    CONSTRAINT chk_recommendation_results_value_currency
        CHECK (
            (
                expected_net_value IS NULL
                AND expected_total_benefit IS NULL
                AND expected_total_cost IS NULL
                AND expected_reward_value IS NULL
                AND expected_annual_fee IS NULL
                AND break_even_spend IS NULL
                AND value_currency_id IS NULL
            )
            OR
            (
                value_currency_id IS NOT NULL
                AND (
                    expected_net_value IS NOT NULL
                    OR expected_total_benefit IS NOT NULL
                    OR expected_total_cost IS NOT NULL
                    OR expected_reward_value IS NOT NULL
                    OR expected_annual_fee IS NOT NULL
                    OR break_even_spend IS NOT NULL
                )
            )
        ),

    CONSTRAINT chk_recommendation_results_preference_counts
        CHECK (
            matched_preference_count >= 0
            AND unmet_preference_count >= 0
            AND hard_preference_conflict_count >= 0
        ),

    CONSTRAINT chk_recommendation_results_primary_reason_code
        CHECK (
            primary_reason_code IS NULL
            OR primary_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_results_secondary_reason_codes
        CHECK (
            secondary_reason_codes IS NULL
            OR cardinality(secondary_reason_codes) > 0
        ),

    CONSTRAINT chk_recommendation_results_warning_codes
        CHECK (
            warning_codes IS NULL
            OR cardinality(warning_codes) > 0
        ),

    CONSTRAINT chk_recommendation_results_badge_codes
        CHECK (
            badge_codes IS NULL
            OR cardinality(badge_codes) > 0
        ),

    CONSTRAINT chk_recommendation_results_title_en
        CHECK (
            result_title_en IS NULL
            OR length(trim(result_title_en)) > 0
        ),

    CONSTRAINT chk_recommendation_results_title_ar
        CHECK (
            result_title_ar IS NULL
            OR length(trim(result_title_ar)) > 0
        ),

    CONSTRAINT chk_recommendation_results_call_to_action_code
        CHECK (
            call_to_action_code IS NULL
            OR call_to_action_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_recommendation_results_call_to_action_url
        CHECK (
            call_to_action_url IS NULL
            OR length(trim(call_to_action_url)) > 0
        ),

    CONSTRAINT chk_recommendation_results_display_priority
        CHECK (
            display_priority > 0
        ),

    CONSTRAINT chk_recommendation_results_display_variant
        CHECK (
            display_variant IN (
                'STANDARD',
                'COMPACT',
                'DETAILED',
                'COMPARISON',
                'FEATURED',
                'ADVISOR',
                'ADMIN',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_recommendation_results_top_rank
        CHECK (
            is_top_recommendation = FALSE
            OR recommendation_rank = 1
        ),

    CONSTRAINT chk_recommendation_results_top_visible
        CHECK (
            is_top_recommendation = FALSE
            OR is_visible = TRUE
        ),

    CONSTRAINT chk_recommendation_results_actionable_visible
        CHECK (
            is_customer_actionable = FALSE
            OR is_visible = TRUE
        ),

    CONSTRAINT chk_recommendation_results_published
        CHECK (
            published_at IS NULL
            OR published_at >= generated_at
        ),

    CONSTRAINT chk_recommendation_results_expiry
        CHECK (
            expires_at IS NULL
            OR expires_at >= generated_at
        ),

    CONSTRAINT chk_recommendation_results_publish_before_expiry
        CHECK (
            published_at IS NULL
            OR expires_at IS NULL
            OR expires_at >= published_at
        ),

    CONSTRAINT chk_recommendation_results_scoring_breakdown
        CHECK (
            jsonb_typeof(scoring_breakdown) = 'object'
        ),

    CONSTRAINT chk_recommendation_results_preference_matches
        CHECK (
            jsonb_typeof(preference_matches) = 'array'
        ),

    CONSTRAINT chk_recommendation_results_preference_conflicts
        CHECK (
            jsonb_typeof(preference_conflicts) = 'array'
        ),

    CONSTRAINT chk_recommendation_results_key_benefits
        CHECK (
            jsonb_typeof(key_benefits) = 'array'
        ),

    CONSTRAINT chk_recommendation_results_key_costs
        CHECK (
            jsonb_typeof(key_costs) = 'array'
        ),

    CONSTRAINT chk_recommendation_results_key_tradeoffs
        CHECK (
            jsonb_typeof(key_tradeoffs) = 'array'
        ),

    CONSTRAINT chk_recommendation_results_warnings
        CHECK (
            jsonb_typeof(warnings) = 'array'
        ),

    CONSTRAINT chk_recommendation_results_snapshot
        CHECK (
            jsonb_typeof(result_snapshot) = 'object'
        ),

    CONSTRAINT chk_recommendation_results_presentation
        CHECK (
            jsonb_typeof(presentation_configuration) = 'object'
        ),

    CONSTRAINT chk_recommendation_results_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE INDEX idx_recommendation_results_run
ON public.recommendation_results(recommendation_run_id);

CREATE INDEX idx_recommendation_results_run_card
ON public.recommendation_results(recommendation_run_card_id);

CREATE INDEX idx_recommendation_results_card
ON public.recommendation_results(card_id);

CREATE INDEX idx_recommendation_results_eligibility
ON public.recommendation_results(eligibility_assessment_id)
WHERE eligibility_assessment_id IS NOT NULL;

CREATE INDEX idx_recommendation_results_value_simulation
ON public.recommendation_results(value_simulation_id)
WHERE value_simulation_id IS NOT NULL;

CREATE INDEX idx_recommendation_results_status
ON public.recommendation_results(
    recommendation_status,
    generated_at DESC
);

CREATE INDEX idx_recommendation_results_run_rank
ON public.recommendation_results(
    recommendation_run_id,
    recommendation_rank
)
WHERE recommendation_rank IS NOT NULL;

CREATE UNIQUE INDEX uq_recommendation_results_visible_rank
ON public.recommendation_results(
    recommendation_run_id,
    recommendation_rank
)
WHERE recommendation_rank IS NOT NULL
  AND is_visible = TRUE
  AND is_current = TRUE;

CREATE INDEX idx_recommendation_results_run_score
ON public.recommendation_results(
    recommendation_run_id,
    final_score DESC
)
WHERE final_score IS NOT NULL;

CREATE INDEX idx_recommendation_results_net_value
ON public.recommendation_results(
    recommendation_run_id,
    expected_net_value DESC
)
WHERE expected_net_value IS NOT NULL;

CREATE INDEX idx_recommendation_results_confidence
ON public.recommendation_results(
    recommendation_run_id,
    confidence_score DESC
)
WHERE confidence_score IS NOT NULL;

CREATE INDEX idx_recommendation_results_visible
ON public.recommendation_results(
    recommendation_run_id,
    display_priority,
    recommendation_rank
)
WHERE is_visible = TRUE
  AND is_current = TRUE;

CREATE INDEX idx_recommendation_results_actionable
ON public.recommendation_results(
    recommendation_run_id,
    recommendation_rank
)
WHERE is_customer_actionable = TRUE
  AND is_visible = TRUE
  AND is_current = TRUE;

CREATE UNIQUE INDEX uq_recommendation_results_top_per_run
ON public.recommendation_results(recommendation_run_id)
WHERE is_top_recommendation = TRUE
  AND is_current = TRUE;

CREATE INDEX idx_recommendation_results_featured
ON public.recommendation_results(
    recommendation_run_id,
    display_priority
)
WHERE is_featured = TRUE
  AND is_visible = TRUE
  AND is_current = TRUE;

CREATE INDEX idx_recommendation_results_current_card
ON public.recommendation_results(
    card_id,
    generated_at DESC
)
WHERE is_current = TRUE;

CREATE INDEX idx_recommendation_results_published
ON public.recommendation_results(
    published_at DESC
)
WHERE published_at IS NOT NULL
  AND is_visible = TRUE
  AND is_current = TRUE;

CREATE INDEX idx_recommendation_results_expiry
ON public.recommendation_results(expires_at)
WHERE expires_at IS NOT NULL
  AND is_current = TRUE;

CREATE INDEX idx_recommendation_results_secondary_reasons
ON public.recommendation_results
USING GIN (secondary_reason_codes);

CREATE INDEX idx_recommendation_results_warning_codes
ON public.recommendation_results
USING GIN (warning_codes);

CREATE INDEX idx_recommendation_results_badge_codes
ON public.recommendation_results
USING GIN (badge_codes);

CREATE INDEX idx_recommendation_results_scoring_breakdown
ON public.recommendation_results
USING GIN (scoring_breakdown);

CREATE INDEX idx_recommendation_results_preference_matches
ON public.recommendation_results
USING GIN (preference_matches);

CREATE INDEX idx_recommendation_results_preference_conflicts
ON public.recommendation_results
USING GIN (preference_conflicts);

CREATE INDEX idx_recommendation_results_key_benefits
ON public.recommendation_results
USING GIN (key_benefits);

CREATE INDEX idx_recommendation_results_key_costs
ON public.recommendation_results
USING GIN (key_costs);

CREATE INDEX idx_recommendation_results_key_tradeoffs
ON public.recommendation_results
USING GIN (key_tradeoffs);

CREATE INDEX idx_recommendation_results_warnings
ON public.recommendation_results
USING GIN (warnings);

CREATE INDEX idx_recommendation_results_snapshot
ON public.recommendation_results
USING GIN (result_snapshot);

CREATE INDEX idx_recommendation_results_presentation
ON public.recommendation_results
USING GIN (presentation_configuration);

CREATE INDEX idx_recommendation_results_metadata
ON public.recommendation_results
USING GIN (metadata);

CREATE TRIGGER trg_recommendation_results_updated_at
BEFORE UPDATE
ON public.recommendation_results
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.recommendation_results IS
'Customer-facing recommendation results generated from internal recommendation run card evaluations.';

COMMENT ON COLUMN public.recommendation_results.recommendation_run_card_id IS
'Links the customer-facing result to the internal card evaluation performed during the recommendation run.';

COMMENT ON COLUMN public.recommendation_results.final_score IS
'Final recommendation score after normalization, weighting, confidence adjustments, exclusions, and applicable model rules.';

COMMENT ON COLUMN public.recommendation_results.raw_score IS
'Recommendation score before normalization and confidence adjustments.';

COMMENT ON COLUMN public.recommendation_results.normalized_score IS
'Score transformed to the recommendation model output scale.';

COMMENT ON COLUMN public.recommendation_results.confidence_adjusted_score IS
'Normalized score after applying confidence and data-completeness adjustments.';

COMMENT ON COLUMN public.recommendation_results.expected_net_value IS
'Expected financial value of the card after subtracting estimated fees and other costs from rewards and benefits.';

COMMENT ON COLUMN public.recommendation_results.primary_reason_code IS
'Primary standardized reason explaining why the card received its recommendation result.';

COMMENT ON COLUMN public.recommendation_results.secondary_reason_codes IS
'Additional standardized reasons supporting the recommendation result.';

COMMENT ON COLUMN public.recommendation_results.badge_codes IS
'Presentation badges such as BEST_VALUE, BEST_TRAVEL, LOWEST_FEE, or BEST_CASHBACK.';

COMMENT ON COLUMN public.recommendation_results.scoring_breakdown IS
'Structured breakdown of the model factors and weighted component scores contributing to the final score.';

COMMENT ON COLUMN public.recommendation_results.preference_matches IS
'Structured list of customer preferences satisfied by the card.';

COMMENT ON COLUMN public.recommendation_results.preference_conflicts IS
'Structured list of customer preferences or hard requirements not satisfied by the card.';

COMMENT ON COLUMN public.recommendation_results.key_benefits IS
'Customer-facing summary of the most important benefits contributing to the recommendation.';

COMMENT ON COLUMN public.recommendation_results.key_costs IS
'Customer-facing summary of the most important fees and financial costs associated with the card.';

COMMENT ON COLUMN public.recommendation_results.key_tradeoffs IS
'Customer-facing summary of compromises, limitations, conditions, and disadvantages associated with the recommendation.';

COMMENT ON COLUMN public.recommendation_results.is_top_recommendation IS
'Identifies the single highest-ranked current recommendation within a recommendation run.';

COMMENT ON COLUMN public.recommendation_results.is_customer_actionable IS
'Indicates whether the customer may proceed to compare, save, apply for, or otherwise act on this result.';

COMMENT ON COLUMN public.recommendation_results.result_snapshot IS
'Immutable snapshot of the key recommendation output used for audit, historical display, and reproducibility.';
