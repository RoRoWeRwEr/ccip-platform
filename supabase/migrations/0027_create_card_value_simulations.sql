CREATE TABLE public.card_value_simulations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    financial_profile_id UUID NOT NULL
        REFERENCES public.customer_financial_profiles(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    spending_profile_id UUID
        REFERENCES public.customer_spending_profiles(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    preference_profile_id UUID
        REFERENCES public.customer_preference_profiles(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    eligibility_assessment_id UUID
        REFERENCES public.eligibility_assessments(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    simulation_name TEXT,

    simulation_period TEXT NOT NULL DEFAULT 'ANNUAL',

    period_start DATE,

    period_end DATE,

    currency_id UUID NOT NULL
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    gross_reward_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    base_reward_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    bonus_reward_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    cashback_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    points_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    miles_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    welcome_bonus_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    lounge_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    travel_benefit_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    dining_benefit_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    insurance_benefit_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    network_benefit_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    merchant_offer_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    installment_benefit_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    other_benefit_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    total_benefit_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    annual_fee_cost NUMERIC(18, 6) NOT NULL DEFAULT 0,

    supplementary_card_fee_cost NUMERIC(18, 6) NOT NULL DEFAULT 0,

    foreign_transaction_fee_cost NUMERIC(18, 6) NOT NULL DEFAULT 0,

    cash_advance_fee_cost NUMERIC(18, 6) NOT NULL DEFAULT 0,

    reward_redemption_cost NUMERIC(18, 6) NOT NULL DEFAULT 0,

    financing_cost NUMERIC(18, 6) NOT NULL DEFAULT 0,

    opportunity_cost NUMERIC(18, 6) NOT NULL DEFAULT 0,

    other_cost_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    total_cost_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    net_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    expected_spend NUMERIC(18, 6),

    eligible_reward_spend NUMERIC(18, 6),

    excluded_reward_spend NUMERIC(18, 6),

    reward_cap_impact NUMERIC(18, 6) NOT NULL DEFAULT 0,

    minimum_spend_shortfall NUMERIC(18, 6) NOT NULL DEFAULT 0,

    break_even_spend NUMERIC(18, 6),

    effective_reward_rate NUMERIC(9, 6),

    effective_net_value_rate NUMERIC(9, 6),

    benefit_utilization_rate NUMERIC(9, 6),

    reward_utilization_rate NUMERIC(9, 6),

    confidence_score NUMERIC(5, 2),

    confidence_level public.recommendation_confidence_level
        NOT NULL DEFAULT 'very_low',

    simulation_status TEXT NOT NULL DEFAULT 'COMPLETED',

    simulation_method TEXT NOT NULL DEFAULT 'RULE_BASED',

    simulation_version TEXT NOT NULL DEFAULT '1.0',

    assumptions JSONB NOT NULL DEFAULT '{}'::JSONB,

    input_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    product_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    warnings JSONB NOT NULL DEFAULT '[]'::JSONB,

    calculated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    expires_at TIMESTAMPTZ,

    is_current BOOLEAN NOT NULL DEFAULT TRUE,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_card_value_simulations_name
        CHECK (
            simulation_name IS NULL
            OR length(trim(simulation_name)) > 0
        ),

    CONSTRAINT chk_card_value_simulations_period
        CHECK (
            simulation_period IN (
                'MONTHLY',
                'QUARTERLY',
                'ANNUAL',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_card_value_simulations_period_dates
        CHECK (
            period_start IS NULL
            OR period_end IS NULL
            OR period_end >= period_start
        ),

    CONSTRAINT chk_card_value_simulations_custom_period
        CHECK (
            simulation_period <> 'CUSTOM'
            OR (
                period_start IS NOT NULL
                AND period_end IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_value_simulations_benefit_values
        CHECK (
            gross_reward_value >= 0
            AND base_reward_value >= 0
            AND bonus_reward_value >= 0
            AND cashback_value >= 0
            AND points_value >= 0
            AND miles_value >= 0
            AND welcome_bonus_value >= 0
            AND lounge_value >= 0
            AND travel_benefit_value >= 0
            AND dining_benefit_value >= 0
            AND insurance_benefit_value >= 0
            AND network_benefit_value >= 0
            AND merchant_offer_value >= 0
            AND installment_benefit_value >= 0
            AND other_benefit_value >= 0
            AND total_benefit_value >= 0
        ),

    CONSTRAINT chk_card_value_simulations_cost_values
        CHECK (
            annual_fee_cost >= 0
            AND supplementary_card_fee_cost >= 0
            AND foreign_transaction_fee_cost >= 0
            AND cash_advance_fee_cost >= 0
            AND reward_redemption_cost >= 0
            AND financing_cost >= 0
            AND opportunity_cost >= 0
            AND other_cost_value >= 0
            AND total_cost_value >= 0
        ),

    CONSTRAINT chk_card_value_simulations_spend_values
        CHECK (
            (
                expected_spend IS NULL
                OR expected_spend >= 0
            )
            AND
            (
                eligible_reward_spend IS NULL
                OR eligible_reward_spend >= 0
            )
            AND
            (
                excluded_reward_spend IS NULL
                OR excluded_reward_spend >= 0
            )
            AND reward_cap_impact >= 0
            AND minimum_spend_shortfall >= 0
            AND
            (
                break_even_spend IS NULL
                OR break_even_spend >= 0
            )
        ),

    CONSTRAINT chk_card_value_simulations_spend_breakdown
        CHECK (
            expected_spend IS NULL
            OR eligible_reward_spend IS NULL
            OR excluded_reward_spend IS NULL
            OR eligible_reward_spend + excluded_reward_spend
                <= expected_spend
        ),

    CONSTRAINT chk_card_value_simulations_effective_reward_rate
        CHECK (
            effective_reward_rate IS NULL
            OR effective_reward_rate BETWEEN -100 AND 1000
        ),

    CONSTRAINT chk_card_value_simulations_effective_net_rate
        CHECK (
            effective_net_value_rate IS NULL
            OR effective_net_value_rate BETWEEN -100 AND 1000
        ),

    CONSTRAINT chk_card_value_simulations_benefit_utilization
        CHECK (
            benefit_utilization_rate IS NULL
            OR benefit_utilization_rate BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_value_simulations_reward_utilization
        CHECK (
            reward_utilization_rate IS NULL
            OR reward_utilization_rate BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_value_simulations_confidence_score
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_value_simulations_status
        CHECK (
            simulation_status IN (
                'PENDING',
                'PROCESSING',
                'COMPLETED',
                'PARTIALLY_COMPLETED',
                'FAILED',
                'CANCELLED',
                'EXPIRED'
            )
        ),

    CONSTRAINT chk_card_value_simulations_method
        CHECK (
            simulation_method IN (
                'RULE_BASED',
                'FINANCIAL_MODEL',
                'MANUAL',
                'HYBRID',
                'IMPORTED',
                'TEST'
            )
        ),

    CONSTRAINT chk_card_value_simulations_version
        CHECK (
            length(trim(simulation_version)) > 0
        ),

    CONSTRAINT chk_card_value_simulations_expiry
        CHECK (
            expires_at IS NULL
            OR expires_at >= calculated_at
        ),

    CONSTRAINT chk_card_value_simulations_assumptions
        CHECK (
            jsonb_typeof(assumptions) = 'object'
        ),

    CONSTRAINT chk_card_value_simulations_input_snapshot
        CHECK (
            jsonb_typeof(input_snapshot) = 'object'
        ),

    CONSTRAINT chk_card_value_simulations_product_snapshot
        CHECK (
            jsonb_typeof(product_snapshot) = 'object'
        ),

    CONSTRAINT chk_card_value_simulations_warnings
        CHECK (
            jsonb_typeof(warnings) = 'array'
        ),

    CONSTRAINT chk_card_value_simulations_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.card_value_simulation_components (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    simulation_id UUID NOT NULL
        REFERENCES public.card_value_simulations(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    component_code TEXT NOT NULL,

    component_type public.value_simulation_component_type NOT NULL,

    direction public.value_component_direction NOT NULL,

    component_name_en TEXT NOT NULL,

    component_name_ar TEXT,

    description_en TEXT,

    description_ar TEXT,

    source_table TEXT,

    source_record_id UUID,

    spending_category_code TEXT,

    spending_amount NUMERIC(18, 6),

    eligible_spending_amount NUMERIC(18, 6),

    excluded_spending_amount NUMERIC(18, 6),

    reward_quantity NUMERIC(18, 6),

    reward_unit TEXT,

    reward_rate NUMERIC(18, 8),

    unit_value NUMERIC(18, 8),

    gross_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    utilization_rate NUMERIC(9, 6),

    adjusted_value NUMERIC(18, 6) NOT NULL DEFAULT 0,

    cap_amount NUMERIC(18, 6),

    cap_impact NUMERIC(18, 6) NOT NULL DEFAULT 0,

    minimum_spend_required NUMERIC(18, 6),

    minimum_spend_achieved BOOLEAN,

    recurring_component BOOLEAN NOT NULL DEFAULT FALSE,

    one_time_component BOOLEAN NOT NULL DEFAULT FALSE,

    estimated_component BOOLEAN NOT NULL DEFAULT FALSE,

    taxable_component BOOLEAN NOT NULL DEFAULT FALSE,

    confidence_score NUMERIC(5, 2),

    calculation_formula TEXT,

    calculation_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    assumptions JSONB NOT NULL DEFAULT '{}'::JSONB,

    warnings JSONB NOT NULL DEFAULT '[]'::JSONB,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_value_simulation_components
        UNIQUE (
            simulation_id,
            component_code
        ),

    CONSTRAINT chk_card_value_simulation_components_code
        CHECK (
            component_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_card_value_simulation_components_name
        CHECK (
            length(trim(component_name_en)) > 0
        ),

    CONSTRAINT chk_card_value_simulation_components_source_table
        CHECK (
            source_table IS NULL
            OR source_table IN (
                'card_fees',
                'card_benefits',
                'reward_rules',
                'reward_targets',
                'reward_exclusions',
                'reward_redemption_rates',
                'card_offers',
                'card_insurance_benefits',
                'card_lounge_benefits',
                'card_travel_benefits',
                'card_dining_benefits',
                'card_installment_plans',
                'card_network_benefits',
                'manual',
                'calculated',
                'other'
            )
        ),

    CONSTRAINT chk_card_value_simulation_components_spend_values
        CHECK (
            (
                spending_amount IS NULL
                OR spending_amount >= 0
            )
            AND
            (
                eligible_spending_amount IS NULL
                OR eligible_spending_amount >= 0
            )
            AND
            (
                excluded_spending_amount IS NULL
                OR excluded_spending_amount >= 0
            )
        ),

    CONSTRAINT chk_card_value_simulation_components_spend_breakdown
        CHECK (
            spending_amount IS NULL
            OR eligible_spending_amount IS NULL
            OR excluded_spending_amount IS NULL
            OR eligible_spending_amount + excluded_spending_amount
                <= spending_amount
        ),

    CONSTRAINT chk_card_value_simulation_components_reward_quantity
        CHECK (
            reward_quantity IS NULL
            OR reward_quantity >= 0
        ),

    CONSTRAINT chk_card_value_simulation_components_reward_rate
        CHECK (
            reward_rate IS NULL
            OR reward_rate >= 0
        ),

    CONSTRAINT chk_card_value_simulation_components_unit_value
        CHECK (
            unit_value IS NULL
            OR unit_value >= 0
        ),

    CONSTRAINT chk_card_value_simulation_components_gross_value
        CHECK (
            gross_value >= 0
        ),

    CONSTRAINT chk_card_value_simulation_components_adjusted_value
        CHECK (
            adjusted_value >= 0
        ),

    CONSTRAINT chk_card_value_simulation_components_utilization_rate
        CHECK (
            utilization_rate IS NULL
            OR utilization_rate BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_value_simulation_components_cap
        CHECK (
            (
                cap_amount IS NULL
                OR cap_amount >= 0
            )
            AND cap_impact >= 0
        ),

    CONSTRAINT chk_card_value_simulation_components_minimum_spend
        CHECK (
            minimum_spend_required IS NULL
            OR minimum_spend_required >= 0
        ),

    CONSTRAINT chk_card_value_simulation_components_component_timing
        CHECK (
            NOT (
                recurring_component = TRUE
                AND one_time_component = TRUE
            )
        ),

    CONSTRAINT chk_card_value_simulation_components_confidence
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_value_simulation_components_priority
        CHECK (
            priority > 0
        ),

    CONSTRAINT chk_card_value_simulation_components_details
        CHECK (
            jsonb_typeof(calculation_details) = 'object'
        ),

    CONSTRAINT chk_card_value_simulation_components_assumptions
        CHECK (
            jsonb_typeof(assumptions) = 'object'
        ),

    CONSTRAINT chk_card_value_simulation_components_warnings
        CHECK (
            jsonb_typeof(warnings) = 'array'
        )
);

CREATE INDEX idx_card_value_simulations_financial_profile
ON public.card_value_simulations(financial_profile_id);

CREATE INDEX idx_card_value_simulations_spending_profile
ON public.card_value_simulations(spending_profile_id)
WHERE spending_profile_id IS NOT NULL;

CREATE INDEX idx_card_value_simulations_preference_profile
ON public.card_value_simulations(preference_profile_id)
WHERE preference_profile_id IS NOT NULL;

CREATE INDEX idx_card_value_simulations_eligibility
ON public.card_value_simulations(eligibility_assessment_id)
WHERE eligibility_assessment_id IS NOT NULL;

CREATE INDEX idx_card_value_simulations_card
ON public.card_value_simulations(card_id);

CREATE INDEX idx_card_value_simulations_currency
ON public.card_value_simulations(currency_id);

CREATE INDEX idx_card_value_simulations_profile_card
ON public.card_value_simulations(
    financial_profile_id,
    card_id,
    calculated_at DESC
);

CREATE INDEX idx_card_value_simulations_net_value
ON public.card_value_simulations(net_value DESC)
WHERE simulation_status = 'COMPLETED';

CREATE INDEX idx_card_value_simulations_total_benefit
ON public.card_value_simulations(total_benefit_value DESC)
WHERE simulation_status = 'COMPLETED';

CREATE INDEX idx_card_value_simulations_total_cost
ON public.card_value_simulations(total_cost_value)
WHERE simulation_status = 'COMPLETED';

CREATE INDEX idx_card_value_simulations_status
ON public.card_value_simulations(
    simulation_status,
    calculated_at DESC
);

CREATE INDEX idx_card_value_simulations_current
ON public.card_value_simulations(
    financial_profile_id,
    card_id,
    calculated_at DESC
)
WHERE is_current = TRUE;

CREATE UNIQUE INDEX uq_card_value_simulations_current_profile_card
ON public.card_value_simulations(
    financial_profile_id,
    card_id
)
WHERE is_current = TRUE;

CREATE INDEX idx_card_value_simulations_assumptions
ON public.card_value_simulations
USING GIN (assumptions);

CREATE INDEX idx_card_value_simulations_input_snapshot
ON public.card_value_simulations
USING GIN (input_snapshot);

CREATE INDEX idx_card_value_simulations_product_snapshot
ON public.card_value_simulations
USING GIN (product_snapshot);

CREATE INDEX idx_card_value_simulations_warnings
ON public.card_value_simulations
USING GIN (warnings);

CREATE INDEX idx_card_value_simulations_metadata
ON public.card_value_simulations
USING GIN (metadata);

CREATE INDEX idx_card_value_simulation_components_simulation
ON public.card_value_simulation_components(simulation_id);

CREATE INDEX idx_card_value_simulation_components_type
ON public.card_value_simulation_components(
    component_type,
    direction
);

CREATE INDEX idx_card_value_simulation_components_source
ON public.card_value_simulation_components(
    source_table,
    source_record_id
)
WHERE source_table IS NOT NULL
  AND source_record_id IS NOT NULL;

CREATE INDEX idx_card_value_simulation_components_category
ON public.card_value_simulation_components(
    spending_category_code
)
WHERE spending_category_code IS NOT NULL;

CREATE INDEX idx_card_value_simulation_components_value
ON public.card_value_simulation_components(
    simulation_id,
    adjusted_value DESC
)
WHERE is_active = TRUE;

CREATE INDEX idx_card_value_simulation_components_benefits
ON public.card_value_simulation_components(
    simulation_id,
    adjusted_value DESC
)
WHERE direction = 'benefit'
  AND is_active = TRUE;

CREATE INDEX idx_card_value_simulation_components_costs
ON public.card_value_simulation_components(
    simulation_id,
    adjusted_value DESC
)
WHERE direction = 'cost'
  AND is_active = TRUE;

CREATE INDEX idx_card_value_simulation_components_details
ON public.card_value_simulation_components
USING GIN (calculation_details);

CREATE INDEX idx_card_value_simulation_components_assumptions
ON public.card_value_simulation_components
USING GIN (assumptions);

CREATE INDEX idx_card_value_simulation_components_warnings
ON public.card_value_simulation_components
USING GIN (warnings);

CREATE TRIGGER trg_card_value_simulations_updated_at
BEFORE UPDATE
ON public.card_value_simulations
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_card_value_simulation_components_updated_at
BEFORE UPDATE
ON public.card_value_simulation_components
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.card_value_simulations IS
'Financial value simulation for a customer profile and card, including expected rewards, benefits, fees, costs, utilization, and net annual value.';

COMMENT ON TABLE public.card_value_simulation_components IS
'Detailed financial benefit and cost components used to calculate a card value simulation.';

COMMENT ON COLUMN public.card_value_simulations.net_value IS
'Expected total benefit value minus total cost value for the selected simulation period.';

COMMENT ON COLUMN public.card_value_simulations.break_even_spend IS
'Estimated spending required for the card benefits and rewards to offset its expected costs.';

COMMENT ON COLUMN public.card_value_simulations.reward_cap_impact IS
'Estimated reward value lost because one or more reward earning caps were reached.';

COMMENT ON COLUMN public.card_value_simulations.minimum_spend_shortfall IS
'Additional spending required to satisfy applicable minimum-spend conditions.';

COMMENT ON COLUMN public.card_value_simulations.assumptions IS
'Structured assumptions used in the financial simulation, including utilization estimates and valuation assumptions.';

COMMENT ON COLUMN public.card_value_simulation_components.direction IS
'Indicates whether the component increases customer value, decreases it, or is informational only.';

COMMENT ON COLUMN public.card_value_simulation_components.gross_value IS
'Financial value before utilization, caps, conditions, confidence adjustments, or other reductions.';

COMMENT ON COLUMN public.card_value_simulation_components.adjusted_value IS
'Final component value included in the simulation after applicable adjustments.';

COMMENT ON COLUMN public.card_value_simulation_components.source_record_id IS
'Optional identifier of the product data record from which the component was calculated.';
