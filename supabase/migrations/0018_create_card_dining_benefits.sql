CREATE TABLE public.card_dining_benefits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    slug TEXT NOT NULL,

    benefit_type TEXT NOT NULL,

    provider_name_en TEXT,
    provider_name_ar TEXT,

    merchant_name_en TEXT,
    merchant_name_ar TEXT,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    discount_percentage NUMERIC(7, 4),

    fixed_discount_amount NUMERIC(14, 2),

    currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    complimentary_items INTEGER,

    minimum_spend NUMERIC(14, 2),

    maximum_discount_amount NUMERIC(14, 2),

    complimentary_uses INTEGER,

    usage_period TEXT,

    eligible_cardholder_type TEXT NOT NULL DEFAULT 'PRIMARY',

    applicable_channels JSONB,

    applicable_days SMALLINT[],

    reservation_required BOOLEAN NOT NULL DEFAULT FALSE,

    activation_required BOOLEAN NOT NULL DEFAULT FALSE,

    registration_required BOOLEAN NOT NULL DEFAULT FALSE,

    promo_code TEXT,

    booking_url TEXT,

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

    CONSTRAINT uq_card_dining_benefits_card_slug
        UNIQUE (
            card_id,
            slug
        ),

    CONSTRAINT chk_card_dining_benefits_slug
        CHECK (
            slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_card_dining_benefits_type
        CHECK (
            benefit_type IN (
                'DISCOUNT_PERCENTAGE',
                'DISCOUNT_FIXED',
                'BUY_ONE_GET_ONE',
                'COMPLIMENTARY_ITEM',
                'COMPLIMENTARY_MEAL',
                'DINING_CREDIT',
                'PRIORITY_RESERVATION',
                'EXCLUSIVE_MENU',
                'MEMBERSHIP',
                'OTHER'
            )
        ),

    CONSTRAINT chk_card_dining_benefits_discount_percentage
        CHECK (
            discount_percentage IS NULL
            OR discount_percentage BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_dining_benefits_fixed_discount
        CHECK (
            fixed_discount_amount IS NULL
            OR fixed_discount_amount >= 0
        ),

    CONSTRAINT chk_card_dining_benefits_complimentary_items
        CHECK (
            complimentary_items IS NULL
            OR complimentary_items > 0
        ),

    CONSTRAINT chk_card_dining_benefits_minimum_spend
        CHECK (
            minimum_spend IS NULL
            OR minimum_spend >= 0
        ),

    CONSTRAINT chk_card_dining_benefits_maximum_discount
        CHECK (
            maximum_discount_amount IS NULL
            OR maximum_discount_amount >= 0
        ),

    CONSTRAINT chk_card_dining_benefits_complimentary_uses
        CHECK (
            complimentary_uses IS NULL
            OR complimentary_uses > 0
        ),

    CONSTRAINT chk_card_dining_benefits_usage_period
        CHECK (
            usage_period IS NULL
            OR usage_period IN (
                'PER_TRANSACTION',
                'DAILY',
                'WEEKLY',
                'MONTHLY',
                'QUARTERLY',
                'SEMI_ANNUAL',
                'ANNUAL',
                'CALENDAR_YEAR',
                'CARD_MEMBERSHIP_YEAR'
            )
        ),

    CONSTRAINT chk_card_dining_benefits_usage_configuration
        CHECK (
            (
                complimentary_uses IS NULL
                AND usage_period IS NULL
            )
            OR
            (
                complimentary_uses IS NOT NULL
                AND usage_period IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_dining_benefits_cardholder_type
        CHECK (
            eligible_cardholder_type IN (
                'PRIMARY',
                'SUPPLEMENTARY',
                'PRIMARY_AND_SUPPLEMENTARY'
            )
        ),

    CONSTRAINT chk_card_dining_benefits_applicable_channels
        CHECK (
            applicable_channels IS NULL
            OR (
                jsonb_typeof(applicable_channels) = 'array'
                AND jsonb_array_length(applicable_channels) > 0
            )
        ),

    CONSTRAINT chk_card_dining_benefits_applicable_days
        CHECK (
            applicable_days IS NULL
            OR (
                cardinality(applicable_days) > 0
                AND applicable_days <@ ARRAY[1, 2, 3, 4, 5, 6, 7]::SMALLINT[]
            )
        ),

    CONSTRAINT chk_card_dining_benefits_currency_configuration
        CHECK (
            (
                fixed_discount_amount IS NULL
                AND minimum_spend IS NULL
                AND maximum_discount_amount IS NULL
                AND currency_id IS NULL
            )
            OR
            (
                (
                    fixed_discount_amount IS NOT NULL
                    OR minimum_spend IS NOT NULL
                    OR maximum_discount_amount IS NOT NULL
                )
                AND currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_dining_benefits_type_configuration
        CHECK (
            (
                benefit_type = 'DISCOUNT_PERCENTAGE'
                AND discount_percentage IS NOT NULL
                AND fixed_discount_amount IS NULL
                AND complimentary_items IS NULL
            )
            OR
            (
                benefit_type IN (
                    'DISCOUNT_FIXED',
                    'DINING_CREDIT'
                )
                AND fixed_discount_amount IS NOT NULL
                AND currency_id IS NOT NULL
                AND discount_percentage IS NULL
                AND complimentary_items IS NULL
            )
            OR
            (
                benefit_type = 'BUY_ONE_GET_ONE'
                AND discount_percentage IS NULL
                AND fixed_discount_amount IS NULL
            )
            OR
            (
                benefit_type IN (
                    'COMPLIMENTARY_ITEM',
                    'COMPLIMENTARY_MEAL'
                )
                AND complimentary_items IS NOT NULL
                AND discount_percentage IS NULL
                AND fixed_discount_amount IS NULL
            )
            OR
            (
                benefit_type IN (
                    'PRIORITY_RESERVATION',
                    'EXCLUSIVE_MENU',
                    'MEMBERSHIP',
                    'OTHER'
                )
                AND discount_percentage IS NULL
                AND fixed_discount_amount IS NULL
                AND complimentary_items IS NULL
            )
        ),

    CONSTRAINT chk_card_dining_benefits_priority
        CHECK (
            priority > 0
        ),

    CONSTRAINT chk_card_dining_benefits_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        )
);

CREATE INDEX idx_card_dining_benefits_card
ON public.card_dining_benefits(card_id);

CREATE INDEX idx_card_dining_benefits_card_type
ON public.card_dining_benefits(
    card_id,
    benefit_type
);

CREATE INDEX idx_card_dining_benefits_currency
ON public.card_dining_benefits(currency_id)
WHERE currency_id IS NOT NULL;

CREATE INDEX idx_card_dining_benefits_provider
ON public.card_dining_benefits(
    lower(provider_name_en)
)
WHERE provider_name_en IS NOT NULL;

CREATE INDEX idx_card_dining_benefits_merchant
ON public.card_dining_benefits(
    lower(merchant_name_en)
)
WHERE merchant_name_en IS NOT NULL;

CREATE INDEX idx_card_dining_benefits_active
ON public.card_dining_benefits(
    card_id,
    priority
)
WHERE is_active = TRUE;

CREATE INDEX idx_card_dining_benefits_featured
ON public.card_dining_benefits(
    card_id,
    priority
)
WHERE is_featured = TRUE
  AND is_active = TRUE;

CREATE INDEX idx_card_dining_benefits_applicable_channels
ON public.card_dining_benefits
USING GIN (applicable_channels)
WHERE applicable_channels IS NOT NULL;

CREATE TRIGGER trg_card_dining_benefits_updated_at
BEFORE UPDATE
ON public.card_dining_benefits
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
