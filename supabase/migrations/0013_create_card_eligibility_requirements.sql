CREATE TABLE public.card_eligibility_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    requirement_type TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    minimum_amount NUMERIC(14, 2),
    maximum_amount NUMERIC(14, 2),

    currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    minimum_age SMALLINT,
    maximum_age SMALLINT,

    minimum_employment_months SMALLINT,

    required_boolean_value BOOLEAN,

    allowed_values JSONB,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    valid_from DATE,
    valid_to DATE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_card_eligibility_requirement_type
        CHECK (
            requirement_type IN (
                'MINIMUM_SALARY',
                'MINIMUM_INCOME',
                'AGE',
                'NATIONALITY',
                'RESIDENCY_STATUS',
                'CUSTOMER_SEGMENT',
                'EMPLOYMENT_TYPE',
                'EMPLOYER_CATEGORY',
                'SALARY_TRANSFER',
                'MINIMUM_EMPLOYMENT_PERIOD',
                'EXISTING_BANK_CUSTOMER',
                'CREDIT_SCORE',
                'DOCUMENTATION',
                'OTHER'
            )
        ),

    CONSTRAINT chk_card_eligibility_amounts
        CHECK (
            (minimum_amount IS NULL OR minimum_amount >= 0)
            AND
            (maximum_amount IS NULL OR maximum_amount >= 0)
        ),

    CONSTRAINT chk_card_eligibility_amount_range
        CHECK (
            minimum_amount IS NULL
            OR maximum_amount IS NULL
            OR maximum_amount >= minimum_amount
        ),

    CONSTRAINT chk_card_eligibility_currency_configuration
        CHECK (
            (
                minimum_amount IS NULL
                AND maximum_amount IS NULL
                AND currency_id IS NULL
            )
            OR
            (
                (
                    minimum_amount IS NOT NULL
                    OR maximum_amount IS NOT NULL
                )
                AND currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_eligibility_minimum_age
        CHECK (
            minimum_age IS NULL
            OR minimum_age BETWEEN 0 AND 120
        ),

    CONSTRAINT chk_card_eligibility_maximum_age
        CHECK (
            maximum_age IS NULL
            OR maximum_age BETWEEN 0 AND 120
        ),

    CONSTRAINT chk_card_eligibility_age_range
        CHECK (
            minimum_age IS NULL
            OR maximum_age IS NULL
            OR maximum_age >= minimum_age
        ),

    CONSTRAINT chk_card_eligibility_employment_months
        CHECK (
            minimum_employment_months IS NULL
            OR minimum_employment_months >= 0
        ),

    CONSTRAINT chk_card_eligibility_priority
        CHECK (priority > 0),

    CONSTRAINT chk_card_eligibility_allowed_values
        CHECK (
            allowed_values IS NULL
            OR jsonb_typeof(allowed_values) = 'array'
        ),

    CONSTRAINT chk_card_eligibility_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        ),

    CONSTRAINT chk_card_eligibility_type_configuration
        CHECK (
            (
                requirement_type IN (
                    'MINIMUM_SALARY',
                    'MINIMUM_INCOME',
                    'CREDIT_SCORE'
                )
                AND minimum_amount IS NOT NULL
                AND minimum_age IS NULL
                AND maximum_age IS NULL
                AND minimum_employment_months IS NULL
                AND required_boolean_value IS NULL
                AND allowed_values IS NULL
            )
            OR
            (
                requirement_type = 'AGE'
                AND (
                    minimum_age IS NOT NULL
                    OR maximum_age IS NOT NULL
                )
                AND minimum_amount IS NULL
                AND maximum_amount IS NULL
                AND currency_id IS NULL
                AND minimum_employment_months IS NULL
                AND required_boolean_value IS NULL
                AND allowed_values IS NULL
            )
            OR
            (
                requirement_type = 'MINIMUM_EMPLOYMENT_PERIOD'
                AND minimum_employment_months IS NOT NULL
                AND minimum_amount IS NULL
                AND maximum_amount IS NULL
                AND currency_id IS NULL
                AND minimum_age IS NULL
                AND maximum_age IS NULL
                AND required_boolean_value IS NULL
                AND allowed_values IS NULL
            )
            OR
            (
                requirement_type IN (
                    'SALARY_TRANSFER',
                    'EXISTING_BANK_CUSTOMER'
                )
                AND required_boolean_value IS NOT NULL
                AND minimum_amount IS NULL
                AND maximum_amount IS NULL
                AND currency_id IS NULL
                AND minimum_age IS NULL
                AND maximum_age IS NULL
                AND minimum_employment_months IS NULL
                AND allowed_values IS NULL
            )
            OR
            (
                requirement_type IN (
                    'NATIONALITY',
                    'RESIDENCY_STATUS',
                    'CUSTOMER_SEGMENT',
                    'EMPLOYMENT_TYPE',
                    'EMPLOYER_CATEGORY',
                    'DOCUMENTATION'
                )
                AND allowed_values IS NOT NULL
                AND jsonb_array_length(allowed_values) > 0
                AND minimum_amount IS NULL
                AND maximum_amount IS NULL
                AND currency_id IS NULL
                AND minimum_age IS NULL
                AND maximum_age IS NULL
                AND minimum_employment_months IS NULL
                AND required_boolean_value IS NULL
            )
            OR
            (
                requirement_type = 'OTHER'
                AND minimum_amount IS NULL
                AND maximum_amount IS NULL
                AND currency_id IS NULL
                AND minimum_age IS NULL
                AND maximum_age IS NULL
                AND minimum_employment_months IS NULL
                AND required_boolean_value IS NULL
                AND allowed_values IS NULL
            )
        )
);

CREATE INDEX idx_card_eligibility_requirements_card
ON public.card_eligibility_requirements(card_id);

CREATE INDEX idx_card_eligibility_requirements_card_type
ON public.card_eligibility_requirements(
    card_id,
    requirement_type
);

CREATE INDEX idx_card_eligibility_requirements_currency
ON public.card_eligibility_requirements(currency_id)
WHERE currency_id IS NOT NULL;

CREATE INDEX idx_card_eligibility_requirements_active
ON public.card_eligibility_requirements(
    card_id,
    priority
)
WHERE is_active = TRUE;

CREATE UNIQUE INDEX uq_card_eligibility_requirements_active_type
ON public.card_eligibility_requirements(
    card_id,
    requirement_type
)
WHERE is_active = TRUE
  AND requirement_type <> 'OTHER';

CREATE TRIGGER trg_card_eligibility_requirements_updated_at
BEFORE UPDATE
ON public.card_eligibility_requirements
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
