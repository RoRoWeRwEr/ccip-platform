CREATE TABLE public.card_installment_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    slug TEXT NOT NULL,

    plan_type TEXT NOT NULL,

    provider_name_en TEXT,
    provider_name_ar TEXT,

    merchant_name_en TEXT,
    merchant_name_ar TEXT,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    minimum_transaction_amount NUMERIC(14, 2),

    maximum_transaction_amount NUMERIC(14, 2),

    currency_id UUID NOT NULL
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    available_tenures SMALLINT[] NOT NULL,

    annual_percentage_rate NUMERIC(9, 6),

    flat_profit_rate NUMERIC(9, 6),

    monthly_profit_rate NUMERIC(9, 6),

    processing_fee_amount NUMERIC(14, 2),

    processing_fee_percentage NUMERIC(7, 4),

    minimum_processing_fee NUMERIC(14, 2),

    maximum_processing_fee NUMERIC(14, 2),

    early_settlement_fee_amount NUMERIC(14, 2),

    early_settlement_fee_percentage NUMERIC(7, 4),

    late_payment_fee_amount NUMERIC(14, 2),

    interest_free BOOLEAN NOT NULL DEFAULT FALSE,

    merchant_restricted BOOLEAN NOT NULL DEFAULT FALSE,

    eligible_transaction_channels JSONB,

    eligible_merchant_categories JSONB,

    excluded_merchant_categories JSONB,

    activation_method TEXT,

    activation_deadline_days SMALLINT,

    minimum_installments_paid_before_settlement SMALLINT,

    source_url TEXT,

    terms_en TEXT,
    terms_ar TEXT,

    valid_from TIMESTAMPTZ,
    valid_to TIMESTAMPTZ,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_installment_plans_card_slug
        UNIQUE (
            card_id,
            slug
        ),

    CONSTRAINT chk_card_installment_plans_slug
        CHECK (
            slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_card_installment_plans_type
        CHECK (
            plan_type IN (
                'PURCHASE_CONVERSION',
                'BALANCE_CONVERSION',
                'BALANCE_TRANSFER',
                'MERCHANT_INSTALLMENT',
                'EDUCATION',
                'MEDICAL',
                'TRAVEL',
                'CASH_ADVANCE_CONVERSION',
                'OTHER'
            )
        ),

    CONSTRAINT chk_card_installment_plans_minimum_amount
        CHECK (
            minimum_transaction_amount IS NULL
            OR minimum_transaction_amount >= 0
        ),

    CONSTRAINT chk_card_installment_plans_maximum_amount
        CHECK (
            maximum_transaction_amount IS NULL
            OR maximum_transaction_amount >= 0
        ),

    CONSTRAINT chk_card_installment_plans_amount_range
        CHECK (
            minimum_transaction_amount IS NULL
            OR maximum_transaction_amount IS NULL
            OR maximum_transaction_amount >= minimum_transaction_amount
        ),

    CONSTRAINT chk_card_installment_plans_available_tenures
        CHECK (
            cardinality(available_tenures) > 0
            AND 0 < ALL (available_tenures)
        ),

    CONSTRAINT chk_card_installment_plans_annual_percentage_rate
        CHECK (
            annual_percentage_rate IS NULL
            OR annual_percentage_rate BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_installment_plans_flat_profit_rate
        CHECK (
            flat_profit_rate IS NULL
            OR flat_profit_rate BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_installment_plans_monthly_profit_rate
        CHECK (
            monthly_profit_rate IS NULL
            OR monthly_profit_rate BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_installment_plans_profit_rate_method
        CHECK (
            num_nonnulls(
                annual_percentage_rate,
                flat_profit_rate,
                monthly_profit_rate
            ) <= 1
        ),

    CONSTRAINT chk_card_installment_plans_interest_free
        CHECK (
            interest_free = FALSE
            OR (
                COALESCE(annual_percentage_rate, 0) = 0
                AND COALESCE(flat_profit_rate, 0) = 0
                AND COALESCE(monthly_profit_rate, 0) = 0
            )
        ),

    CONSTRAINT chk_card_installment_plans_processing_fee_amount
        CHECK (
            processing_fee_amount IS NULL
            OR processing_fee_amount >= 0
        ),

    CONSTRAINT chk_card_installment_plans_processing_fee_percentage
        CHECK (
            processing_fee_percentage IS NULL
            OR processing_fee_percentage BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_installment_plans_minimum_processing_fee
        CHECK (
            minimum_processing_fee IS NULL
            OR minimum_processing_fee >= 0
        ),

    CONSTRAINT chk_card_installment_plans_maximum_processing_fee
        CHECK (
            maximum_processing_fee IS NULL
            OR maximum_processing_fee >= 0
        ),

    CONSTRAINT chk_card_installment_plans_processing_fee_range
        CHECK (
            minimum_processing_fee IS NULL
            OR maximum_processing_fee IS NULL
            OR maximum_processing_fee >= minimum_processing_fee
        ),

    CONSTRAINT chk_card_installment_plans_processing_fee_configuration
        CHECK (
            processing_fee_percentage IS NOT NULL
            OR (
                minimum_processing_fee IS NULL
                AND maximum_processing_fee IS NULL
            )
        ),

    CONSTRAINT chk_card_installment_plans_early_settlement_fee_amount
        CHECK (
            early_settlement_fee_amount IS NULL
            OR early_settlement_fee_amount >= 0
        ),

    CONSTRAINT chk_card_installment_plans_early_settlement_fee_percentage
        CHECK (
            early_settlement_fee_percentage IS NULL
            OR early_settlement_fee_percentage BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_installment_plans_early_settlement_fee_method
        CHECK (
            num_nonnulls(
                early_settlement_fee_amount,
                early_settlement_fee_percentage
            ) <= 1
        ),

    CONSTRAINT chk_card_installment_plans_late_payment_fee
        CHECK (
            late_payment_fee_amount IS NULL
            OR late_payment_fee_amount >= 0
        ),

    CONSTRAINT chk_card_installment_plans_merchant_configuration
        CHECK (
            merchant_restricted = FALSE
            OR (
                merchant_name_en IS NOT NULL
                OR merchant_name_ar IS NOT NULL
                OR eligible_merchant_categories IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_installment_plans_eligible_channels
        CHECK (
            eligible_transaction_channels IS NULL
            OR (
                jsonb_typeof(eligible_transaction_channels) = 'array'
                AND jsonb_array_length(eligible_transaction_channels) > 0
            )
        ),

    CONSTRAINT chk_card_installment_plans_eligible_categories
        CHECK (
            eligible_merchant_categories IS NULL
            OR (
                jsonb_typeof(eligible_merchant_categories) = 'array'
                AND jsonb_array_length(eligible_merchant_categories) > 0
            )
        ),

    CONSTRAINT chk_card_installment_plans_excluded_categories
        CHECK (
            excluded_merchant_categories IS NULL
            OR (
                jsonb_typeof(excluded_merchant_categories) = 'array'
                AND jsonb_array_length(excluded_merchant_categories) > 0
            )
        ),

    CONSTRAINT chk_card_installment_plans_activation_method
        CHECK (
            activation_method IS NULL
            OR activation_method IN (
                'AUTOMATIC',
                'MOBILE_APP',
                'ONLINE_BANKING',
                'PHONE_BANKING',
                'SMS',
                'BRANCH',
                'MERCHANT_POS',
                'CUSTOMER_SERVICE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_card_installment_plans_activation_deadline
        CHECK (
            activation_deadline_days IS NULL
            OR activation_deadline_days >= 0
        ),

    CONSTRAINT chk_card_installment_plans_settlement_installments
        CHECK (
            minimum_installments_paid_before_settlement IS NULL
            OR minimum_installments_paid_before_settlement >= 0
        ),

    CONSTRAINT chk_card_installment_plans_priority
        CHECK (
            priority > 0
        ),

    CONSTRAINT chk_card_installment_plans_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        )
);

CREATE INDEX idx_card_installment_plans_card
ON public.card_installment_plans(card_id);

CREATE INDEX idx_card_installment_plans_card_type
ON public.card_installment_plans(
    card_id,
    plan_type
);

CREATE INDEX idx_card_installment_plans_currency
ON public.card_installment_plans(currency_id);

CREATE INDEX idx_card_installment_plans_provider
ON public.card_installment_plans(
    lower(provider_name_en)
)
WHERE provider_name_en IS NOT NULL;

CREATE INDEX idx_card_installment_plans_merchant
ON public.card_installment_plans(
    lower(merchant_name_en)
)
WHERE merchant_name_en IS NOT NULL;

CREATE INDEX idx_card_installment_plans_amount_range
ON public.card_installment_plans(
    minimum_transaction_amount,
    maximum_transaction_amount
);

CREATE INDEX idx_card_installment_plans_active
ON public.card_installment_plans(
    card_id,
    priority
)
WHERE is_active = TRUE;

CREATE INDEX idx_card_installment_plans_featured
ON public.card_installment_plans(
    card_id,
    priority
)
WHERE is_featured = TRUE
  AND is_active = TRUE;

CREATE INDEX idx_card_installment_plans_tenures
ON public.card_installment_plans
USING GIN (available_tenures);

CREATE INDEX idx_card_installment_plans_eligible_channels
ON public.card_installment_plans
USING GIN (eligible_transaction_channels)
WHERE eligible_transaction_channels IS NOT NULL;

CREATE INDEX idx_card_installment_plans_eligible_categories
ON public.card_installment_plans
USING GIN (eligible_merchant_categories)
WHERE eligible_merchant_categories IS NOT NULL;

CREATE TRIGGER trg_card_installment_plans_updated_at
BEFORE UPDATE
ON public.card_installment_plans
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
