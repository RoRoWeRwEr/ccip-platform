CREATE TABLE public.card_fees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    fee_type fee_type NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    amount NUMERIC(12, 2),
    percentage NUMERIC(7, 4),

    billing_period billing_period NOT NULL DEFAULT 'ONE_TIME',

    waiver_type fee_waiver_type NOT NULL DEFAULT 'NONE',

    waiver_threshold_amount NUMERIC(14, 2),
    waiver_threshold_period threshold_period,

    currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_card_fees_amount
        CHECK (
            amount IS NULL
            OR amount >= 0
        ),

    CONSTRAINT chk_card_fees_percentage
        CHECK (
            percentage IS NULL
            OR percentage BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_fees_value_present
        CHECK (
            amount IS NOT NULL
            OR percentage IS NOT NULL
        ),

    CONSTRAINT chk_card_fees_waiver_threshold_amount
        CHECK (
            waiver_threshold_amount IS NULL
            OR waiver_threshold_amount >= 0
        ),

    CONSTRAINT chk_card_fees_waiver_configuration
        CHECK (
            (
                waiver_type = 'SPEND_THRESHOLD'
                AND waiver_threshold_amount IS NOT NULL
                AND waiver_threshold_period IS NOT NULL
            )
            OR
            (
                waiver_type <> 'SPEND_THRESHOLD'
                AND waiver_threshold_amount IS NULL
                AND waiver_threshold_period IS NULL
            )
        )
);

CREATE INDEX idx_card_fees_card_id
ON public.card_fees(card_id);

CREATE INDEX idx_card_fees_fee_type
ON public.card_fees(fee_type);

CREATE INDEX idx_card_fees_currency_id
ON public.card_fees(currency_id);

CREATE INDEX idx_card_fees_card_active
ON public.card_fees(card_id, is_active);

CREATE UNIQUE INDEX uq_card_fees_card_fee_type_active
ON public.card_fees(card_id, fee_type)
WHERE is_active = TRUE;

CREATE TRIGGER trg_card_fees_updated_at
BEFORE UPDATE
ON public.card_fees
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
