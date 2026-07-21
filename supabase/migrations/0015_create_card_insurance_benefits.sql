CREATE TABLE public.card_insurance_benefits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    insurance_type TEXT NOT NULL,

    provider_name_en TEXT,
    provider_name_ar TEXT,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    coverage_amount NUMERIC(14,2),

    currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    deductible_amount NUMERIC(14,2),

    claim_limit INTEGER,

    coverage_period_days INTEGER,

    minimum_trip_duration_days INTEGER,

    maximum_trip_duration_days INTEGER,

    activation_required BOOLEAN NOT NULL DEFAULT FALSE,

    terms_en TEXT,
    terms_ar TEXT,

    valid_from DATE,
    valid_to DATE,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_card_insurance_type
        CHECK (
            insurance_type IN (
                'TRAVEL',
                'MEDICAL',
                'TRIP_CANCELLATION',
                'TRIP_DELAY',
                'FLIGHT_DELAY',
                'LOST_BAGGAGE',
                'BAGGAGE_DELAY',
                'RENTAL_CAR',
                'PURCHASE_PROTECTION',
                'EXTENDED_WARRANTY',
                'PRICE_PROTECTION',
                'MOBILE_PROTECTION',
                'ACCIDENT',
                'LIFE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_card_insurance_coverage_amount
        CHECK (
            coverage_amount IS NULL
            OR coverage_amount >= 0
        ),

    CONSTRAINT chk_card_insurance_deductible
        CHECK (
            deductible_amount IS NULL
            OR deductible_amount >= 0
        ),

    CONSTRAINT chk_card_insurance_claim_limit
        CHECK (
            claim_limit IS NULL
            OR claim_limit > 0
        ),

    CONSTRAINT chk_card_insurance_trip_days
        CHECK (
            minimum_trip_duration_days IS NULL
            OR minimum_trip_duration_days >= 0
        ),

    CONSTRAINT chk_card_insurance_trip_days_max
        CHECK (
            maximum_trip_duration_days IS NULL
            OR maximum_trip_duration_days >= 0
        ),

    CONSTRAINT chk_card_insurance_trip_range
        CHECK (
            minimum_trip_duration_days IS NULL
            OR maximum_trip_duration_days IS NULL
            OR maximum_trip_duration_days >= minimum_trip_duration_days
        ),

    CONSTRAINT chk_card_insurance_coverage_period
        CHECK (
            coverage_period_days IS NULL
            OR coverage_period_days > 0
        ),

    CONSTRAINT chk_card_insurance_currency
        CHECK (
            (
                coverage_amount IS NULL
                AND deductible_amount IS NULL
                AND currency_id IS NULL
            )
            OR
            (
                (
                    coverage_amount IS NOT NULL
                    OR deductible_amount IS NOT NULL
                )
                AND currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_insurance_priority
        CHECK (priority > 0),

    CONSTRAINT chk_card_insurance_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        )
);

CREATE INDEX idx_card_insurance_card
ON public.card_insurance_benefits(card_id);

CREATE INDEX idx_card_insurance_type
ON public.card_insurance_benefits(
    card_id,
    insurance_type
);

CREATE INDEX idx_card_insurance_currency
ON public.card_insurance_benefits(currency_id)
WHERE currency_id IS NOT NULL;

CREATE INDEX idx_card_insurance_active
ON public.card_insurance_benefits(
    card_id,
    priority
)
WHERE is_active = TRUE;

CREATE UNIQUE INDEX uq_card_insurance_type
ON public.card_insurance_benefits(
    card_id,
    insurance_type,
    priority
);

CREATE TRIGGER trg_card_insurance_benefits_updated_at
BEFORE UPDATE
ON public.card_insurance_benefits
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
