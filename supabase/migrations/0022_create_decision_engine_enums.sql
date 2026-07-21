CREATE TYPE public.eligibility_assessment_status AS ENUM (
    'eligible',
    'likely_eligible',
    'conditionally_eligible',
    'not_eligible',
    'insufficient_information',
    'manual_review_required'
);

CREATE TYPE public.eligibility_requirement_result AS ENUM (
    'passed',
    'failed',
    'conditionally_passed',
    'unknown',
    'not_applicable'
);

CREATE TYPE public.recommendation_model_type AS ENUM (
    'rule_based',
    'weighted',
    'financial_value',
    'hybrid',
    'machine_learning',
    'editorial'
);

CREATE TYPE public.recommendation_run_status AS ENUM (
    'pending',
    'processing',
    'completed',
    'partially_completed',
    'failed',
    'cancelled',
    'expired'
);

CREATE TYPE public.recommendation_result_status AS ENUM (
    'recommended',
    'conditionally_recommended',
    'alternative',
    'not_recommended',
    'excluded'
);

CREATE TYPE public.recommendation_exclusion_reason AS ENUM (
    'eligibility_failed',
    'income_requirement_not_met',
    'salary_transfer_required',
    'customer_segment_required',
    'employment_requirement_not_met',
    'nationality_requirement_not_met',
    'residency_requirement_not_met',
    'age_requirement_not_met',
    'annual_fee_too_high',
    'spending_requirement_not_met',
    'insufficient_customer_data',
    'card_inactive',
    'card_unavailable',
    'user_excluded',
    'model_excluded',
    'other'
);

CREATE TYPE public.value_simulation_component_type AS ENUM (
    'base_rewards',
    'bonus_rewards',
    'welcome_bonus',
    'cashback',
    'miles',
    'points',
    'lounge_access',
    'travel_benefit',
    'dining_benefit',
    'insurance_benefit',
    'network_benefit',
    'merchant_offer',
    'installment_benefit',
    'annual_fee',
    'supplementary_card_fee',
    'foreign_transaction_fee',
    'cash_advance_fee',
    'reward_redemption_cost',
    'opportunity_cost',
    'other_benefit',
    'other_cost'
);

CREATE TYPE public.value_component_direction AS ENUM (
    'benefit',
    'cost',
    'neutral'
);

CREATE TYPE public.customer_preference_importance AS ENUM (
    'not_important',
    'low',
    'medium',
    'high',
    'essential'
);

CREATE TYPE public.recommendation_confidence_level AS ENUM (
    'very_low',
    'low',
    'medium',
    'high',
    'very_high'
);

CREATE TYPE public.explanation_type AS ENUM (
    'eligibility',
    'financial_value',
    'rewards',
    'travel',
    'lounge',
    'dining',
    'shopping',
    'insurance',
    'fees',
    'risk',
    'condition',
    'warning',
    'advantage',
    'disadvantage',
    'alternative',
    'general'
);

COMMENT ON TYPE public.eligibility_assessment_status IS
'Overall eligibility conclusion for a customer and a financial product.';

COMMENT ON TYPE public.eligibility_requirement_result IS
'Result of evaluating one eligibility requirement against a customer profile.';

COMMENT ON TYPE public.recommendation_model_type IS
'Methodology used by a recommendation model.';

COMMENT ON TYPE public.recommendation_run_status IS
'Processing lifecycle status of a recommendation run.';

COMMENT ON TYPE public.recommendation_result_status IS
'Final recommendation classification assigned to a card or product.';

COMMENT ON TYPE public.recommendation_exclusion_reason IS
'Primary reason why a product was excluded from recommendation results.';

COMMENT ON TYPE public.value_simulation_component_type IS
'Financial benefit or cost component used in annual value simulations.';

COMMENT ON TYPE public.value_component_direction IS
'Indicates whether a simulation component increases or decreases customer value.';

COMMENT ON TYPE public.customer_preference_importance IS
'Importance level assigned by the customer to a preference or feature.';

COMMENT ON TYPE public.recommendation_confidence_level IS
'Human-readable confidence classification for recommendation results.';

COMMENT ON TYPE public.explanation_type IS
'Category of an explanation, warning, advantage, or condition presented with a recommendation.';
