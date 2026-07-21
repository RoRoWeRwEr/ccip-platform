CREATE TABLE public.customer_preference_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    financial_profile_id UUID NOT NULL
        REFERENCES public.customer_financial_profiles(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    profile_name TEXT NOT NULL,

    profile_slug TEXT,

    preference_strategy TEXT NOT NULL DEFAULT 'BALANCED',

    preferred_reward_type TEXT,

    preferred_payment_network payment_network,

    preferred_bank_id UUID
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    excluded_bank_ids UUID[],

    preferred_card_ids UUID[],

    excluded_card_ids UUID[],

    preferred_airline_programs TEXT[],

    preferred_hotel_programs TEXT[],

    preferred_digital_wallets TEXT[],

    preferred_lounge_programs TEXT[],

    preferred_languages TEXT[],

    wants_shariah_compliant_products BOOLEAN,

    wants_salary_transfer_products BOOLEAN,

    willing_to_pay_annual_fee BOOLEAN,

    prefers_fee_waiver BOOLEAN,

    prefers_simple_rewards BOOLEAN,

    prefers_automatic_redemption BOOLEAN,

    prefers_transferable_points BOOLEAN,

    prefers_cashback BOOLEAN,

    prefers_airline_miles BOOLEAN,

    prefers_lounge_access BOOLEAN,

    prefers_travel_insurance BOOLEAN,

    prefers_dining_benefits BOOLEAN,

    prefers_installment_plans BOOLEAN,

    prefers_welcome_bonus BOOLEAN,

    prefers_no_foreign_transaction_fee BOOLEAN,

    accepts_spending_conditions BOOLEAN,

    accepts_temporary_offers BOOLEAN,

    maximum_acceptable_annual_fee NUMERIC(14, 2),

    minimum_required_net_annual_value NUMERIC(14, 2),

    minimum_required_reward_rate NUMERIC(9, 6),

    maximum_acceptable_foreign_transaction_fee NUMERIC(7, 4),

    maximum_acceptable_minimum_spend NUMERIC(16, 2),

    desired_supplementary_card_count SMALLINT,

    desired_annual_lounge_visits SMALLINT,

    desired_annual_airport_transfers SMALLINT,

    desired_annual_golf_rounds SMALLINT,

    desired_annual_concierge_requests SMALLINT,

    preference_data_completeness NUMERIC(5, 2),

    preference_data_confidence NUMERIC(5, 2),

    data_source TEXT NOT NULL DEFAULT 'USER_PROVIDED',

    last_verified_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_customer_preference_profiles_financial_slug
        UNIQUE (
            financial_profile_id,
            profile_slug
        ),

    CONSTRAINT chk_customer_preference_profiles_name
        CHECK (
            length(trim(profile_name)) > 0
        ),

    CONSTRAINT chk_customer_preference_profiles_slug
        CHECK (
            profile_slug IS NULL
            OR profile_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_customer_preference_profiles_strategy
        CHECK (
            preference_strategy IN (
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

    CONSTRAINT chk_customer_preference_profiles_reward_type
        CHECK (
            preferred_reward_type IS NULL
            OR preferred_reward_type IN (
                'CASHBACK',
                'POINTS',
                'AIRLINE_MILES',
                'HOTEL_POINTS',
                'TRANSFERABLE_POINTS',
                'MERCHANT_CREDIT',
                'NO_PREFERENCE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_customer_preference_profiles_excluded_banks
        CHECK (
            excluded_bank_ids IS NULL
            OR cardinality(excluded_bank_ids) > 0
        ),

    CONSTRAINT chk_customer_preference_profiles_preferred_cards
        CHECK (
            preferred_card_ids IS NULL
            OR cardinality(preferred_card_ids) > 0
        ),

    CONSTRAINT chk_customer_preference_profiles_excluded_cards
        CHECK (
            excluded_card_ids IS NULL
            OR cardinality(excluded_card_ids) > 0
        ),

    CONSTRAINT chk_customer_preference_profiles_airline_programs
        CHECK (
            preferred_airline_programs IS NULL
            OR cardinality(preferred_airline_programs) > 0
        ),

    CONSTRAINT chk_customer_preference_profiles_hotel_programs
        CHECK (
            preferred_hotel_programs IS NULL
            OR cardinality(preferred_hotel_programs) > 0
        ),

    CONSTRAINT chk_customer_preference_profiles_digital_wallets
        CHECK (
            preferred_digital_wallets IS NULL
            OR cardinality(preferred_digital_wallets) > 0
        ),

    CONSTRAINT chk_customer_preference_profiles_lounge_programs
        CHECK (
            preferred_lounge_programs IS NULL
            OR cardinality(preferred_lounge_programs) > 0
        ),

    CONSTRAINT chk_customer_preference_profiles_languages
        CHECK (
            preferred_languages IS NULL
            OR cardinality(preferred_languages) > 0
        ),

    CONSTRAINT chk_customer_preference_profiles_bank_conflict
        CHECK (
            preferred_bank_id IS NULL
            OR excluded_bank_ids IS NULL
            OR NOT preferred_bank_id = ANY(excluded_bank_ids)
        ),

    CONSTRAINT chk_customer_preference_profiles_card_conflict
        CHECK (
            preferred_card_ids IS NULL
            OR excluded_card_ids IS NULL
            OR NOT preferred_card_ids && excluded_card_ids
        ),

    CONSTRAINT chk_customer_preference_profiles_annual_fee
        CHECK (
            maximum_acceptable_annual_fee IS NULL
            OR maximum_acceptable_annual_fee >= 0
        ),

    CONSTRAINT chk_customer_preference_profiles_annual_fee_willingness
        CHECK (
            willing_to_pay_annual_fee IS DISTINCT FROM FALSE
            OR maximum_acceptable_annual_fee IS NULL
            OR maximum_acceptable_annual_fee = 0
        ),

    CONSTRAINT chk_customer_preference_profiles_net_value
        CHECK (
            minimum_required_net_annual_value IS NULL
            OR minimum_required_net_annual_value >= 0
        ),

    CONSTRAINT chk_customer_preference_profiles_reward_rate
        CHECK (
            minimum_required_reward_rate IS NULL
            OR minimum_required_reward_rate BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_customer_preference_profiles_foreign_fee
        CHECK (
            maximum_acceptable_foreign_transaction_fee IS NULL
            OR maximum_acceptable_foreign_transaction_fee
                BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_customer_preference_profiles_minimum_spend
        CHECK (
            maximum_acceptable_minimum_spend IS NULL
            OR maximum_acceptable_minimum_spend >= 0
        ),

    CONSTRAINT chk_customer_preference_profiles_usage_counts
        CHECK (
            (
                desired_supplementary_card_count IS NULL
                OR desired_supplementary_card_count >= 0
            )
            AND
            (
                desired_annual_lounge_visits IS NULL
                OR desired_annual_lounge_visits >= 0
            )
            AND
            (
                desired_annual_airport_transfers IS NULL
                OR desired_annual_airport_transfers >= 0
            )
            AND
            (
                desired_annual_golf_rounds IS NULL
                OR desired_annual_golf_rounds >= 0
            )
            AND
            (
                desired_annual_concierge_requests IS NULL
                OR desired_annual_concierge_requests >= 0
            )
        ),

    CONSTRAINT chk_customer_preference_profiles_completeness
        CHECK (
            preference_data_completeness IS NULL
            OR preference_data_completeness BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_customer_preference_profiles_confidence
        CHECK (
            preference_data_confidence IS NULL
            OR preference_data_confidence BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_customer_preference_profiles_data_source
        CHECK (
            data_source IN (
                'USER_PROVIDED',
                'ADVISOR_PROVIDED',
                'IMPORTED',
                'INFERRED',
                'CALCULATED',
                'HYBRID',
                'TEST_DATA'
            )
        ),

    CONSTRAINT chk_customer_preference_profiles_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.customer_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    preference_profile_id UUID NOT NULL
        REFERENCES public.customer_preference_profiles(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    preference_code TEXT NOT NULL,

    preference_category TEXT NOT NULL,

    importance customer_preference_importance
        NOT NULL DEFAULT 'medium',

    weight NUMERIC(7, 4) NOT NULL DEFAULT 1.0000,

    target_value NUMERIC(18, 6),

    minimum_value NUMERIC(18, 6),

    maximum_value NUMERIC(18, 6),

    preferred_value_text TEXT,

    preferred_values JSONB,

    hard_requirement BOOLEAN NOT NULL DEFAULT FALSE,

    exclusion_if_unmet BOOLEAN NOT NULL DEFAULT FALSE,

    notes_en TEXT,

    notes_ar TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_customer_preferences_profile_code
        UNIQUE (
            preference_profile_id,
            preference_code
        ),

    CONSTRAINT chk_customer_preferences_code
        CHECK (
            preference_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_customer_preferences_category
        CHECK (
            preference_category IN (
                'REWARDS',
                'CASHBACK',
                'TRAVEL',
                'LOUNGE',
                'DINING',
                'SHOPPING',
                'FUEL',
                'GROCERIES',
                'ONLINE_SPENDING',
                'INTERNATIONAL_SPENDING',
                'DIGITAL_WALLET',
                'INSTALLMENTS',
                'INSURANCE',
                'WELCOME_BONUS',
                'FEES',
                'BANK_RELATIONSHIP',
                'CUSTOMER_SEGMENT',
                'PAYMENT_NETWORK',
                'SUPPLEMENTARY_CARDS',
                'LIFESTYLE',
                'BUSINESS',
                'SHARIAH_COMPLIANCE',
                'SIMPLICITY',
                'OTHER'
            )
        ),

    CONSTRAINT chk_customer_preferences_weight
        CHECK (
            weight BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_customer_preferences_value_range
        CHECK (
            minimum_value IS NULL
            OR maximum_value IS NULL
            OR maximum_value >= minimum_value
        ),

    CONSTRAINT chk_customer_preferences_target_minimum
        CHECK (
            target_value IS NULL
            OR minimum_value IS NULL
            OR target_value >= minimum_value
        ),

    CONSTRAINT chk_customer_preferences_target_maximum
        CHECK (
            target_value IS NULL
            OR maximum_value IS NULL
            OR target_value <= maximum_value
        ),

    CONSTRAINT chk_customer_preferences_text
        CHECK (
            preferred_value_text IS NULL
            OR length(trim(preferred_value_text)) > 0
        ),

    CONSTRAINT chk_customer_preferences_values
        CHECK (
            preferred_values IS NULL
            OR jsonb_typeof(preferred_values) IN (
                'array',
                'object',
                'string',
                'number',
                'boolean'
            )
        ),

    CONSTRAINT chk_customer_preferences_exclusion
        CHECK (
            exclusion_if_unmet = FALSE
            OR hard_requirement = TRUE
        ),

    CONSTRAINT chk_customer_preferences_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE INDEX idx_customer_preference_profiles_financial
ON public.customer_preference_profiles(financial_profile_id);

CREATE INDEX idx_customer_preference_profiles_preferred_bank
ON public.customer_preference_profiles(preferred_bank_id)
WHERE preferred_bank_id IS NOT NULL;

CREATE INDEX idx_customer_preference_profiles_strategy
ON public.customer_preference_profiles(preference_strategy);

CREATE INDEX idx_customer_preference_profiles_reward_type
ON public.customer_preference_profiles(preferred_reward_type)
WHERE preferred_reward_type IS NOT NULL;

CREATE INDEX idx_customer_preference_profiles_active
ON public.customer_preference_profiles(
    financial_profile_id,
    updated_at DESC
)
WHERE is_active = TRUE;

CREATE UNIQUE INDEX uq_customer_preference_profiles_primary
ON public.customer_preference_profiles(financial_profile_id)
WHERE is_primary = TRUE
  AND is_active = TRUE;

CREATE INDEX idx_customer_preference_profiles_excluded_banks
ON public.customer_preference_profiles
USING GIN (excluded_bank_ids)
WHERE excluded_bank_ids IS NOT NULL;

CREATE INDEX idx_customer_preference_profiles_preferred_cards
ON public.customer_preference_profiles
USING GIN (preferred_card_ids)
WHERE preferred_card_ids IS NOT NULL;

CREATE INDEX idx_customer_preference_profiles_excluded_cards
ON public.customer_preference_profiles
USING GIN (excluded_card_ids)
WHERE excluded_card_ids IS NOT NULL;

CREATE INDEX idx_customer_preference_profiles_metadata
ON public.customer_preference_profiles
USING GIN (metadata);

CREATE INDEX idx_customer_preferences_profile
ON public.customer_preferences(preference_profile_id);

CREATE INDEX idx_customer_preferences_category
ON public.customer_preferences(
    preference_category,
    importance
);

CREATE INDEX idx_customer_preferences_active
ON public.customer_preferences(
    preference_profile_id,
    weight DESC
)
WHERE is_active = TRUE;

CREATE INDEX idx_customer_preferences_hard_requirements
ON public.customer_preferences(
    preference_profile_id,
    preference_code
)
WHERE hard_requirement = TRUE
  AND is_active = TRUE;

CREATE INDEX idx_customer_preferences_exclusions
ON public.customer_preferences(
    preference_profile_id,
    preference_code
)
WHERE exclusion_if_unmet = TRUE
  AND is_active = TRUE;

CREATE INDEX idx_customer_preferences_values
ON public.customer_preferences
USING GIN (preferred_values)
WHERE preferred_values IS NOT NULL;

CREATE INDEX idx_customer_preferences_metadata
ON public.customer_preferences
USING GIN (metadata);

CREATE TRIGGER trg_customer_preference_profiles_updated_at
BEFORE UPDATE
ON public.customer_preference_profiles
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_customer_preferences_updated_at
BEFORE UPDATE
ON public.customer_preferences
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.customer_preference_profiles IS
'High-level customer priorities, exclusions, preferred institutions, reward choices, fee tolerance, and desired card benefits used by the recommendation engine.';

COMMENT ON TABLE public.customer_preferences IS
'Normalized and weighted customer preference inputs used to score, filter, and explain financial product recommendations.';

COMMENT ON COLUMN public.customer_preference_profiles.preference_strategy IS
'Primary decision strategy selected by the customer, such as maximizing financial value, minimizing fees, or prioritizing travel benefits.';

COMMENT ON COLUMN public.customer_preference_profiles.excluded_bank_ids IS
'Bank identifiers that must not be included in recommendation results.';

COMMENT ON COLUMN public.customer_preference_profiles.preferred_card_ids IS
'Cards the customer wants included or prioritized during recommendation processing.';

COMMENT ON COLUMN public.customer_preferences.weight IS
'Relative preference weight used by recommendation models. A value of zero means the preference does not affect scoring.';

COMMENT ON COLUMN public.customer_preferences.hard_requirement IS
'Indicates that the preference is a mandatory condition rather than a scoring preference.';

COMMENT ON COLUMN public.customer_preferences.exclusion_if_unmet IS
'Indicates that a product must be excluded when the associated hard requirement is not met.';
