CREATE TABLE public.card_travel_benefits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    slug TEXT NOT NULL,

    benefit_type TEXT NOT NULL,

    provider_name_en TEXT,
    provider_name_ar TEXT,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    benefit_value NUMERIC(14,2),

    currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    complimentary_uses INTEGER,

    usage_period TEXT,

    activation_required BOOLEAN NOT NULL DEFAULT FALSE,

    registration_required BOOLEAN NOT NULL DEFAULT FALSE,

    promo_code TEXT,

    booking_url TEXT,

    source_url TEXT,

    terms_en TEXT,
    terms_ar TEXT,

    valid_from DATE,
    valid_to DATE,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_travel_benefits_card_slug
        UNIQUE(card_id, slug),

    CONSTRAINT chk_card_travel_slug
        CHECK (
            slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_card_travel_type
        CHECK (
            benefit_type IN (
                'FAST_TRACK',
                'MEET_AND_GREET',
                'AIRPORT_TRANSFER',
                'AIRPORT_PARKING',
                'GLOBAL_WIFI',
                'ESIM',
                'SIM_CARD',
                'CONCIERGE',
                'VISA_SERVICE',
                'HOTEL_PRIVILEGE',
                'CAR_RENTAL',
                'CRUISE',
                'AIRLINE_STATUS',
                'OTHER'
            )
        ),

    CONSTRAINT chk_card_travel_value
        CHECK (
            benefit_value IS NULL
            OR benefit_value >= 0
        ),

    CONSTRAINT chk_card_travel_currency
        CHECK (
            (
                benefit_value IS NULL
                AND currency_id IS NULL
            )
            OR
            (
                benefit_value IS NOT NULL
                AND currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_travel_uses
        CHECK (
            complimentary_uses IS NULL
            OR complimentary_uses > 0
        ),

    CONSTRAINT chk_card_travel_usage_period
        CHECK (
            usage_period IS NULL
            OR usage_period IN (
                'PER_TRIP',
                'MONTHLY',
                'QUARTERLY',
                'ANNUAL',
                'CALENDAR_YEAR',
                'CARD_MEMBERSHIP_YEAR'
            )
        ),

    CONSTRAINT chk_card_travel_usage_configuration
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

    CONSTRAINT chk_card_travel_priority
        CHECK (
            priority > 0
        ),

    CONSTRAINT chk_card_travel_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        )
);

CREATE INDEX idx_card_travel_benefits_card
ON public.card_travel_benefits(card_id);

CREATE INDEX idx_card_travel_benefits_type
ON public.card_travel_benefits(
    card_id,
    benefit_type
);

CREATE INDEX idx_card_travel_benefits_currency
ON public.card_travel_benefits(currency_id)
WHERE currency_id IS NOT NULL;

CREATE INDEX idx_card_travel_benefits_provider
ON public.card_travel_benefits(
    lower(provider_name_en)
)
WHERE provider_name_en IS NOT NULL;

CREATE INDEX idx_card_travel_benefits_active
ON public.card_travel_benefits(
    card_id,
    priority
)
WHERE is_active = TRUE;

CREATE INDEX idx_card_travel_benefits_featured
ON public.card_travel_benefits(
    card_id,
    priority
)
WHERE is_featured = TRUE
  AND is_active = TRUE;

CREATE TRIGGER trg_card_travel_benefits_updated_at
BEFORE UPDATE
ON public.card_travel_benefits
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
