CREATE TABLE public.card_lounge_benefits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    slug TEXT NOT NULL,

    program_name_en TEXT,
    program_name_ar TEXT,

    provider_name_en TEXT,
    provider_name_ar TEXT,

    access_type TEXT NOT NULL,

    access_scope TEXT NOT NULL DEFAULT 'GLOBAL',

    eligible_cardholder_type TEXT NOT NULL DEFAULT 'PRIMARY',

    complimentary_visits_per_period INTEGER,

    visit_period TEXT,

    guest_access_type TEXT NOT NULL DEFAULT 'NOT_INCLUDED',

    complimentary_guest_visits_per_period INTEGER,

    guest_visit_fee NUMERIC(14, 2),

    additional_visit_fee NUMERIC(14, 2),

    currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    minimum_spend_required NUMERIC(14, 2),

    minimum_spend_period TEXT,

    minimum_spend_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    registration_required BOOLEAN NOT NULL DEFAULT FALSE,

    activation_required BOOLEAN NOT NULL DEFAULT FALSE,

    advance_booking_required BOOLEAN NOT NULL DEFAULT FALSE,

    digital_membership_required BOOLEAN NOT NULL DEFAULT FALSE,

    supported_airports JSONB,

    excluded_airports JSONB,

    supported_countries JSONB,

    terms_en TEXT,
    terms_ar TEXT,

    source_url TEXT,

    valid_from DATE,
    valid_to DATE,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_lounge_benefits_card_slug
        UNIQUE (
            card_id,
            slug
        ),

    CONSTRAINT chk_card_lounge_benefits_slug
        CHECK (
            slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_card_lounge_benefits_access_type
        CHECK (
            access_type IN (
                'UNLIMITED',
                'LIMITED_COMPLIMENTARY',
                'PAID_DISCOUNTED',
                'PAY_PER_VISIT'
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_access_scope
        CHECK (
            access_scope IN (
                'GLOBAL',
                'REGIONAL',
                'DOMESTIC',
                'SPECIFIC_AIRPORTS'
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_cardholder_type
        CHECK (
            eligible_cardholder_type IN (
                'PRIMARY',
                'SUPPLEMENTARY',
                'PRIMARY_AND_SUPPLEMENTARY'
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_visits
        CHECK (
            complimentary_visits_per_period IS NULL
            OR complimentary_visits_per_period > 0
        ),

    CONSTRAINT chk_card_lounge_benefits_visit_period
        CHECK (
            visit_period IS NULL
            OR visit_period IN (
                'MONTHLY',
                'QUARTERLY',
                'SEMI_ANNUAL',
                'ANNUAL',
                'CALENDAR_YEAR',
                'CARD_MEMBERSHIP_YEAR'
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_access_configuration
        CHECK (
            (
                access_type = 'UNLIMITED'
                AND complimentary_visits_per_period IS NULL
                AND visit_period IS NULL
            )
            OR
            (
                access_type = 'LIMITED_COMPLIMENTARY'
                AND complimentary_visits_per_period IS NOT NULL
                AND visit_period IS NOT NULL
            )
            OR
            (
                access_type IN (
                    'PAID_DISCOUNTED',
                    'PAY_PER_VISIT'
                )
                AND complimentary_visits_per_period IS NULL
                AND visit_period IS NULL
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_guest_access_type
        CHECK (
            guest_access_type IN (
                'NOT_INCLUDED',
                'UNLIMITED_COMPLIMENTARY',
                'LIMITED_COMPLIMENTARY',
                'PAID'
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_guest_visits
        CHECK (
            complimentary_guest_visits_per_period IS NULL
            OR complimentary_guest_visits_per_period > 0
        ),

    CONSTRAINT chk_card_lounge_benefits_guest_fee
        CHECK (
            guest_visit_fee IS NULL
            OR guest_visit_fee >= 0
        ),

    CONSTRAINT chk_card_lounge_benefits_guest_configuration
        CHECK (
            (
                guest_access_type = 'NOT_INCLUDED'
                AND complimentary_guest_visits_per_period IS NULL
                AND guest_visit_fee IS NULL
            )
            OR
            (
                guest_access_type = 'UNLIMITED_COMPLIMENTARY'
                AND complimentary_guest_visits_per_period IS NULL
                AND guest_visit_fee IS NULL
            )
            OR
            (
                guest_access_type = 'LIMITED_COMPLIMENTARY'
                AND complimentary_guest_visits_per_period IS NOT NULL
                AND guest_visit_fee IS NULL
                AND visit_period IS NOT NULL
            )
            OR
            (
                guest_access_type = 'PAID'
                AND complimentary_guest_visits_per_period IS NULL
                AND guest_visit_fee IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_additional_visit_fee
        CHECK (
            additional_visit_fee IS NULL
            OR additional_visit_fee >= 0
        ),

    CONSTRAINT chk_card_lounge_benefits_fee_currency
        CHECK (
            (
                guest_visit_fee IS NULL
                AND additional_visit_fee IS NULL
                AND currency_id IS NULL
            )
            OR
            (
                (
                    guest_visit_fee IS NOT NULL
                    OR additional_visit_fee IS NOT NULL
                )
                AND currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_minimum_spend
        CHECK (
            minimum_spend_required IS NULL
            OR minimum_spend_required >= 0
        ),

    CONSTRAINT chk_card_lounge_benefits_minimum_spend_period
        CHECK (
            minimum_spend_period IS NULL
            OR minimum_spend_period IN (
                'PREVIOUS_MONTH',
                'CURRENT_MONTH',
                'ROLLING_30_DAYS',
                'QUARTERLY',
                'ANNUAL',
                'PER_VISIT'
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_spend_configuration
        CHECK (
            (
                minimum_spend_required IS NULL
                AND minimum_spend_period IS NULL
                AND minimum_spend_currency_id IS NULL
            )
            OR
            (
                minimum_spend_required IS NOT NULL
                AND minimum_spend_period IS NOT NULL
                AND minimum_spend_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_supported_airports
        CHECK (
            supported_airports IS NULL
            OR (
                jsonb_typeof(supported_airports) = 'array'
                AND jsonb_array_length(supported_airports) > 0
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_excluded_airports
        CHECK (
            excluded_airports IS NULL
            OR (
                jsonb_typeof(excluded_airports) = 'array'
                AND jsonb_array_length(excluded_airports) > 0
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_supported_countries
        CHECK (
            supported_countries IS NULL
            OR (
                jsonb_typeof(supported_countries) = 'array'
                AND jsonb_array_length(supported_countries) > 0
            )
        ),

    CONSTRAINT chk_card_lounge_benefits_scope_configuration
        CHECK (
            access_scope <> 'SPECIFIC_AIRPORTS'
            OR supported_airports IS NOT NULL
        ),

    CONSTRAINT chk_card_lounge_benefits_priority
        CHECK (
            priority > 0
        ),

    CONSTRAINT chk_card_lounge_benefits_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        )
);

CREATE INDEX idx_card_lounge_benefits_card
ON public.card_lounge_benefits(card_id);

CREATE INDEX idx_card_lounge_benefits_card_access
ON public.card_lounge_benefits(
    card_id,
    access_type
);

CREATE INDEX idx_card_lounge_benefits_provider
ON public.card_lounge_benefits(
    lower(provider_name_en)
)
WHERE provider_name_en IS NOT NULL;

CREATE INDEX idx_card_lounge_benefits_currency
ON public.card_lounge_benefits(currency_id)
WHERE currency_id IS NOT NULL;

CREATE INDEX idx_card_lounge_benefits_spend_currency
ON public.card_lounge_benefits(minimum_spend_currency_id)
WHERE minimum_spend_currency_id IS NOT NULL;

CREATE INDEX idx_card_lounge_benefits_active
ON public.card_lounge_benefits(
    card_id,
    priority
)
WHERE is_active = TRUE;

CREATE INDEX idx_card_lounge_benefits_supported_airports
ON public.card_lounge_benefits
USING GIN (supported_airports)
WHERE supported_airports IS NOT NULL;

CREATE INDEX idx_card_lounge_benefits_supported_countries
ON public.card_lounge_benefits
USING GIN (supported_countries)
WHERE supported_countries IS NOT NULL;

CREATE TRIGGER trg_card_lounge_benefits_updated_at
BEFORE UPDATE
ON public.card_lounge_benefits
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
