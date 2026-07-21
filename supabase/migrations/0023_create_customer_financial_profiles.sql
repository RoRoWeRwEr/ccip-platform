CREATE TABLE public.customer_financial_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    profile_name TEXT NOT NULL,

    profile_slug TEXT,

    profile_type TEXT NOT NULL DEFAULT 'PERSONAL',

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    is_scenario BOOLEAN NOT NULL DEFAULT FALSE,

    currency_id UUID NOT NULL
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    nationality_country_code CHAR(2),

    residence_country_code CHAR(2),

    residence_status TEXT,

    date_of_birth DATE,

    employment_status TEXT,

    employment_sector TEXT,

    employer_name TEXT,

    job_title TEXT,

    employment_start_date DATE,

    months_with_current_employer INTEGER,

    gross_monthly_salary NUMERIC(14, 2),

    net_monthly_salary NUMERIC(14, 2),

    monthly_other_income NUMERIC(14, 2),

    monthly_household_income NUMERIC(14, 2),

    monthly_debt_obligations NUMERIC(14, 2),

    monthly_housing_cost NUMERIC(14, 2),

    monthly_fixed_expenses NUMERIC(14, 2),

    estimated_monthly_disposable_income NUMERIC(14, 2),

    annual_income NUMERIC(16, 2),

    total_outstanding_debt NUMERIC(16, 2),

    liquid_assets_value NUMERIC(18, 2),

    total_assets_value NUMERIC(18, 2),

    estimated_net_worth NUMERIC(18, 2),

    salary_transfer_status TEXT NOT NULL DEFAULT 'UNKNOWN',

    salary_transfer_bank_id UUID
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    primary_bank_id UUID
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    current_customer_segment TEXT,

    preferred_customer_segment TEXT,

    existing_credit_card_count SMALLINT,

    total_credit_limit NUMERIC(16, 2),

    average_monthly_card_payment NUMERIC(14, 2),

    pays_balance_in_full BOOLEAN,

    has_recent_payment_defaults BOOLEAN,

    willing_to_transfer_salary BOOLEAN,

    willing_to_open_new_bank_account BOOLEAN,

    maximum_acceptable_annual_fee NUMERIC(14, 2),

    minimum_expected_annual_value NUMERIC(14, 2),

    financial_data_completeness NUMERIC(5, 2),

    data_source TEXT NOT NULL DEFAULT 'USER_PROVIDED',

    consent_for_recommendation BOOLEAN NOT NULL DEFAULT FALSE,

    consent_recorded_at TIMESTAMPTZ,

    consent_version TEXT,

    last_verified_at TIMESTAMPTZ,

    valid_from DATE,

    valid_to DATE,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_customer_financial_profiles_user_slug
        UNIQUE (
            user_id,
            profile_slug
        ),

    CONSTRAINT chk_customer_financial_profiles_name
        CHECK (
            length(trim(profile_name)) > 0
        ),

    CONSTRAINT chk_customer_financial_profiles_slug
        CHECK (
            profile_slug IS NULL
            OR profile_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_customer_financial_profiles_type
        CHECK (
            profile_type IN (
                'PERSONAL',
                'HOUSEHOLD',
                'BUSINESS_OWNER',
                'PRIVATE_BANKING',
                'WEALTH',
                'STUDENT',
                'SCENARIO'
            )
        ),

    CONSTRAINT chk_customer_financial_profiles_scenario_type
        CHECK (
            is_scenario = FALSE
            OR profile_type = 'SCENARIO'
        ),

    CONSTRAINT chk_customer_financial_profiles_nationality_code
        CHECK (
            nationality_country_code IS NULL
            OR nationality_country_code ~ '^[A-Z]{2}$'
        ),

    CONSTRAINT chk_customer_financial_profiles_residence_code
        CHECK (
            residence_country_code IS NULL
            OR residence_country_code ~ '^[A-Z]{2}$'
        ),

    CONSTRAINT chk_customer_financial_profiles_residence_status
        CHECK (
            residence_status IS NULL
            OR residence_status IN (
                'CITIZEN',
                'PERMANENT_RESIDENT',
                'RESIDENT',
                'GCC_RESIDENT',
                'NON_RESIDENT',
                'VISITOR',
                'OTHER',
                'UNKNOWN'
            )
        ),

    CONSTRAINT chk_customer_financial_profiles_date_of_birth
        CHECK (
            date_of_birth IS NULL
            OR (
                date_of_birth <= CURRENT_DATE
                AND date_of_birth >= DATE '1900-01-01'
            )
        ),

    CONSTRAINT chk_customer_financial_profiles_employment_status
        CHECK (
            employment_status IS NULL
            OR employment_status IN (
                'EMPLOYED',
                'SELF_EMPLOYED',
                'BUSINESS_OWNER',
                'RETIRED',
                'STUDENT',
                'UNEMPLOYED',
                'HOMEMAKER',
                'OTHER',
                'UNKNOWN'
            )
        ),

    CONSTRAINT chk_customer_financial_profiles_employment_sector
        CHECK (
            employment_sector IS NULL
            OR employment_sector IN (
                'GOVERNMENT',
                'SEMI_GOVERNMENT',
                'PRIVATE',
                'MILITARY',
                'NON_PROFIT',
                'SELF_EMPLOYED',
                'INTERNATIONAL_ORGANIZATION',
                'OTHER',
                'UNKNOWN'
            )
        ),

    CONSTRAINT chk_customer_financial_profiles_employment_start
        CHECK (
            employment_start_date IS NULL
            OR employment_start_date <= CURRENT_DATE
        ),

    CONSTRAINT chk_customer_financial_profiles_employment_months
        CHECK (
            months_with_current_employer IS NULL
            OR months_with_current_employer >= 0
        ),

    CONSTRAINT chk_customer_financial_profiles_income_values
        CHECK (
            (
                gross_monthly_salary IS NULL
                OR gross_monthly_salary >= 0
            )
            AND
            (
                net_monthly_salary IS NULL
                OR net_monthly_salary >= 0
            )
            AND
            (
                monthly_other_income IS NULL
                OR monthly_other_income >= 0
            )
            AND
            (
                monthly_household_income IS NULL
                OR monthly_household_income >= 0
            )
            AND
            (
                annual_income IS NULL
                OR annual_income >= 0
            )
        ),

    CONSTRAINT chk_customer_financial_profiles_net_salary
        CHECK (
            gross_monthly_salary IS NULL
            OR net_monthly_salary IS NULL
            OR net_monthly_salary <= gross_monthly_salary
        ),

    CONSTRAINT chk_customer_financial_profiles_expense_values
        CHECK (
            (
                monthly_debt_obligations IS NULL
                OR monthly_debt_obligations >= 0
            )
            AND
            (
                monthly_housing_cost IS NULL
                OR monthly_housing_cost >= 0
            )
            AND
            (
                monthly_fixed_expenses IS NULL
                OR monthly_fixed_expenses >= 0
            )
            AND
            (
                average_monthly_card_payment IS NULL
                OR average_monthly_card_payment >= 0
            )
        ),

    CONSTRAINT chk_customer_financial_profiles_disposable_income
        CHECK (
            estimated_monthly_disposable_income IS NULL
            OR estimated_monthly_disposable_income >= 0
        ),

    CONSTRAINT chk_customer_financial_profiles_wealth_values
        CHECK (
            (
                total_outstanding_debt IS NULL
                OR total_outstanding_debt >= 0
            )
            AND
            (
                liquid_assets_value IS NULL
                OR liquid_assets_value >= 0
            )
            AND
            (
                total_assets_value IS NULL
                OR total_assets_value >= 0
            )
        ),

    CONSTRAINT chk_customer_financial_profiles_liquid_assets
        CHECK (
            liquid_assets_value IS NULL
            OR total_assets_value IS NULL
            OR liquid_assets_value <= total_assets_value
        ),

    CONSTRAINT chk_customer_financial_profiles_salary_transfer
        CHECK (
            salary_transfer_status IN (
                'TRANSFERRED',
                'NOT_TRANSFERRED',
                'PARTIALLY_TRANSFERRED',
                'WILLING_TO_TRANSFER',
                'NOT_WILLING_TO_TRANSFER',
                'NOT_APPLICABLE',
                'UNKNOWN'
            )
        ),

    CONSTRAINT chk_customer_financial_profiles_salary_transfer_bank
        CHECK (
            salary_transfer_status <> 'TRANSFERRED'
            OR salary_transfer_bank_id IS NOT NULL
        ),

    CONSTRAINT chk_customer_financial_profiles_existing_cards
        CHECK (
            existing_credit_card_count IS NULL
            OR existing_credit_card_count >= 0
        ),

    CONSTRAINT chk_customer_financial_profiles_credit_limit
        CHECK (
            total_credit_limit IS NULL
            OR total_credit_limit >= 0
        ),

    CONSTRAINT chk_customer_financial_profiles_annual_fee
        CHECK (
            maximum_acceptable_annual_fee IS NULL
            OR maximum_acceptable_annual_fee >= 0
        ),

    CONSTRAINT chk_customer_financial_profiles_expected_value
        CHECK (
            minimum_expected_annual_value IS NULL
            OR minimum_expected_annual_value >= 0
        ),

    CONSTRAINT chk_customer_financial_profiles_completeness
        CHECK (
            financial_data_completeness IS NULL
            OR financial_data_completeness BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_customer_financial_profiles_data_source
        CHECK (
            data_source IN (
                'USER_PROVIDED',
                'ADVISOR_PROVIDED',
                'IMPORTED',
                'CALCULATED',
                'HYBRID',
                'TEST_DATA'
            )
        ),

    CONSTRAINT chk_customer_financial_profiles_consent
        CHECK (
            consent_for_recommendation = FALSE
            OR consent_recorded_at IS NOT NULL
        ),

    CONSTRAINT chk_customer_financial_profiles_consent_version
        CHECK (
            consent_version IS NULL
            OR length(trim(consent_version)) > 0
        ),

    CONSTRAINT chk_customer_financial_profiles_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        ),

    CONSTRAINT chk_customer_financial_profiles_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE INDEX idx_customer_financial_profiles_user
ON public.customer_financial_profiles(user_id)
WHERE user_id IS NOT NULL;

CREATE INDEX idx_customer_financial_profiles_currency
ON public.customer_financial_profiles(currency_id);

CREATE INDEX idx_customer_financial_profiles_primary_bank
ON public.customer_financial_profiles(primary_bank_id)
WHERE primary_bank_id IS NOT NULL;

CREATE INDEX idx_customer_financial_profiles_salary_bank
ON public.customer_financial_profiles(salary_transfer_bank_id)
WHERE salary_transfer_bank_id IS NOT NULL;

CREATE INDEX idx_customer_financial_profiles_employment
ON public.customer_financial_profiles(
    employment_status,
    employment_sector
);

CREATE INDEX idx_customer_financial_profiles_income
ON public.customer_financial_profiles(net_monthly_salary)
WHERE net_monthly_salary IS NOT NULL;

CREATE INDEX idx_customer_financial_profiles_segment
ON public.customer_financial_profiles(current_customer_segment)
WHERE current_customer_segment IS NOT NULL;

CREATE INDEX idx_customer_financial_profiles_active
ON public.customer_financial_profiles(
    user_id,
    updated_at DESC
)
WHERE is_active = TRUE;

CREATE UNIQUE INDEX uq_customer_financial_profiles_primary
ON public.customer_financial_profiles(user_id)
WHERE is_primary = TRUE
  AND is_active = TRUE
  AND user_id IS NOT NULL;

CREATE INDEX idx_customer_financial_profiles_metadata
ON public.customer_financial_profiles
USING GIN (metadata);

CREATE TRIGGER trg_customer_financial_profiles_updated_at
BEFORE UPDATE
ON public.customer_financial_profiles
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.customer_financial_profiles IS
'Financial, employment, residency, banking relationship, and affordability inputs used by the decision intelligence engine.';

COMMENT ON COLUMN public.customer_financial_profiles.user_id IS
'Optional Supabase authenticated user. Null is allowed for controlled scenarios and anonymous recommendation profiles.';

COMMENT ON COLUMN public.customer_financial_profiles.is_scenario IS
'Identifies hypothetical profiles used for simulations, testing, or comparison rather than an actual customer.';

COMMENT ON COLUMN public.customer_financial_profiles.estimated_monthly_disposable_income IS
'Estimated amount remaining after recurring financial obligations and essential fixed expenses.';

COMMENT ON COLUMN public.customer_financial_profiles.financial_data_completeness IS
'Percentage indicating how complete the financial profile is for recommendation purposes.';

COMMENT ON COLUMN public.customer_financial_profiles.consent_for_recommendation IS
'Indicates whether the customer consented to using this profile for personalized recommendations.';
