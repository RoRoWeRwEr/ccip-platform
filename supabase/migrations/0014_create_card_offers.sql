CREATE TABLE public.card_offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    slug TEXT NOT NULL,

    offer_type TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    merchant_name_en TEXT,
    merchant_name_ar TEXT,

    merchant_website_url TEXT,

    percentage_value NUMERIC(7, 4),

    fixed_amount NUMERIC(14, 2),

    currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    bonus_points NUMERIC(18, 4),

    installment_months SMALLINT,

    minimum_spend NUMERIC(14, 2),

    maximum_discount_amount NUMERIC(14, 2),

    promo_code TEXT,

    applicable_channels JSONB,

    applicable_days SMALLINT[],

    valid_from TIMESTAMPTZ,
    valid_to TIMESTAMPTZ,

    terms_en TEXT,
    terms_ar TEXT,

    source_url TEXT,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_offers_card_slug
        UNIQUE (card_id, slug),

    CONSTRAINT chk_card_offers_slug
        CHECK (
            slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_card_offers_type
        CHECK (
            offer_type IN (
                'DISCOUNT_PERCENTAGE',
                'DISCOUNT_FIXED',
                'CASHBACK_PERCENTAGE',
                'CASHBACK_FIXED',
                'BONUS_POINTS',
                'INSTALLMENT',
                'BUY_ONE_GET_ONE',
                'FREE_SERVICE',
                'UPGRADE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_card_offers_percentage_value
        CHECK (
            percentage_value IS NULL
            OR percentage_value BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_offers_fixed_amount
        CHECK (
            fixed_amount IS NULL
            OR fixed_amount >= 0
        ),

    CONSTRAINT chk_card_offers_bonus_points
        CHECK (
            bonus_points IS NULL
            OR bonus_points > 0
        ),

    CONSTRAINT chk_card_offers_installment_months
        CHECK (
            installment_months IS NULL
            OR installment_months > 0
        ),

    CONSTRAINT chk_card_offers_minimum_spend
        CHECK (
            minimum_spend IS NULL
            OR minimum_spend >= 0
        ),

    CONSTRAINT chk_card_offers_maximum_discount
        CHECK (
            maximum_discount_amount IS NULL
            OR maximum_discount_amount >= 0
        ),

    CONSTRAINT chk_card_offers_priority
        CHECK (
            priority > 0
        ),

    CONSTRAINT chk_card_offers_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        ),

    CONSTRAINT chk_card_offers_applicable_channels
        CHECK (
            applicable_channels IS NULL
            OR (
                jsonb_typeof(applicable_channels) = 'array'
                AND jsonb_array_length(applicable_channels) > 0
            )
        ),

    CONSTRAINT chk_card_offers_applicable_days
        CHECK (
            applicable_days IS NULL
            OR (
                cardinality(applicable_days) > 0
                AND applicable_days <@ ARRAY[1, 2, 3, 4, 5, 6, 7]::SMALLINT[]
            )
        ),

    CONSTRAINT chk_card_offers_currency_configuration
        CHECK (
            (
                fixed_amount IS NULL
                AND minimum_spend IS NULL
                AND maximum_discount_amount IS NULL
                AND currency_id IS NULL
            )
            OR
            (
                (
                    fixed_amount IS NOT NULL
                    OR minimum_spend IS NOT NULL
                    OR maximum_discount_amount IS NOT NULL
                )
                AND currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_offers_type_configuration
        CHECK (
            (
                offer_type IN (
                    'DISCOUNT_PERCENTAGE',
                    'CASHBACK_PERCENTAGE'
                )
                AND percentage_value IS NOT NULL
                AND fixed_amount IS NULL
                AND bonus_points IS NULL
                AND installment_months IS NULL
            )
            OR
            (
                offer_type IN (
                    'DISCOUNT_FIXED',
                    'CASHBACK_FIXED'
                )
                AND fixed_amount IS NOT NULL
                AND currency_id IS NOT NULL
                AND percentage_value IS NULL
                AND bonus_points IS NULL
                AND installment_months IS NULL
            )
            OR
            (
                offer_type = 'BONUS_POINTS'
                AND bonus_points IS NOT NULL
                AND percentage_value IS NULL
                AND fixed_amount IS NULL
                AND installment_months IS NULL
            )
            OR
            (
                offer_type = 'INSTALLMENT'
                AND installment_months IS NOT NULL
                AND percentage_value IS NULL
                AND fixed_amount IS NULL
                AND bonus_points IS NULL
            )
            OR
            (
                offer_type IN (
                    'BUY_ONE_GET_ONE',
                    'FREE_SERVICE',
                    'UPGRADE',
                    'OTHER'
                )
                AND percentage_value IS NULL
                AND fixed_amount IS NULL
                AND bonus_points IS NULL
                AND installment_months IS NULL
            )
        )
);

CREATE INDEX idx_card_offers_card
ON public.card_offers(card_id);

CREATE INDEX idx_card_offers_card_type
ON public.card_offers(
    card_id,
    offer_type
);

CREATE INDEX idx_card_offers_currency
ON public.card_offers(currency_id)
WHERE currency_id IS NOT NULL;

CREATE INDEX idx_card_offers_validity
ON public.card_offers(
    valid_from,
    valid_to
);

CREATE INDEX idx_card_offers_active
ON public.card_offers(
    card_id,
    priority
)
WHERE is_active = TRUE;

CREATE INDEX idx_card_offers_featured_active
ON public.card_offers(
    card_id,
    priority
)
WHERE is_featured = TRUE
  AND is_active = TRUE;

CREATE INDEX idx_card_offers_merchant_name
ON public.card_offers(
    lower(merchant_name_en)
)
WHERE merchant_name_en IS NOT NULL;

CREATE TRIGGER trg_card_offers_updated_at
BEFORE UPDATE
ON public.card_offers
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
