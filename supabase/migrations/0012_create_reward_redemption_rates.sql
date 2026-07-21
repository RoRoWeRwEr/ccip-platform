CREATE TABLE public.reward_redemption_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    loyalty_program_id UUID NOT NULL
        REFERENCES public.loyalty_programs(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    redemption_type TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    points_required NUMERIC(18, 4) NOT NULL,

    monetary_value NUMERIC(18, 4) NOT NULL,

    currency_id UUID NOT NULL
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    minimum_points NUMERIC(18, 4),

    maximum_points NUMERIC(18, 4),

    redemption_increment NUMERIC(18, 4),

    partner_program_id UUID
        REFERENCES public.loyalty_programs(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    transfer_ratio_from NUMERIC(18, 6),

    transfer_ratio_to NUMERIC(18, 6),

    processing_fee_amount NUMERIC(14, 2),

    processing_fee_percentage NUMERIC(7, 4),

    valid_from DATE,
    valid_to DATE,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_reward_redemption_rates_type
        CHECK (
            redemption_type IN (
                'CASHBACK',
                'STATEMENT_CREDIT',
                'TRAVEL',
                'VOUCHER',
                'MERCHANDISE',
                'BILL_PAYMENT',
                'CHARITY',
                'POINT_TRANSFER',
                'OTHER'
            )
        ),

    CONSTRAINT chk_reward_redemption_rates_points_required
        CHECK (points_required > 0),

    CONSTRAINT chk_reward_redemption_rates_monetary_value
        CHECK (monetary_value > 0),

    CONSTRAINT chk_reward_redemption_rates_minimum_points
        CHECK (
            minimum_points IS NULL
            OR minimum_points > 0
        ),

    CONSTRAINT chk_reward_redemption_rates_maximum_points
        CHECK (
            maximum_points IS NULL
            OR maximum_points > 0
        ),

    CONSTRAINT chk_reward_redemption_rates_points_range
        CHECK (
            minimum_points IS NULL
            OR maximum_points IS NULL
            OR maximum_points >= minimum_points
        ),

    CONSTRAINT chk_reward_redemption_rates_increment
        CHECK (
            redemption_increment IS NULL
            OR redemption_increment > 0
        ),

    CONSTRAINT chk_reward_redemption_rates_processing_fee_amount
        CHECK (
            processing_fee_amount IS NULL
            OR processing_fee_amount >= 0
        ),

    CONSTRAINT chk_reward_redemption_rates_processing_fee_percentage
        CHECK (
            processing_fee_percentage IS NULL
            OR processing_fee_percentage BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_reward_redemption_rates_priority
        CHECK (priority > 0),

    CONSTRAINT chk_reward_redemption_rates_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        ),

    CONSTRAINT chk_reward_redemption_rates_transfer_configuration
        CHECK (
            (
                redemption_type = 'POINT_TRANSFER'
                AND partner_program_id IS NOT NULL
                AND transfer_ratio_from IS NOT NULL
                AND transfer_ratio_to IS NOT NULL
                AND transfer_ratio_from > 0
                AND transfer_ratio_to > 0
            )
            OR
            (
                redemption_type <> 'POINT_TRANSFER'
                AND partner_program_id IS NULL
                AND transfer_ratio_from IS NULL
                AND transfer_ratio_to IS NULL
            )
        ),

    CONSTRAINT chk_reward_redemption_rates_different_partner
        CHECK (
            partner_program_id IS NULL
            OR partner_program_id <> loyalty_program_id
        )
);

CREATE INDEX idx_reward_redemption_rates_program
ON public.reward_redemption_rates(loyalty_program_id);

CREATE INDEX idx_reward_redemption_rates_currency
ON public.reward_redemption_rates(currency_id);

CREATE INDEX idx_reward_redemption_rates_partner_program
ON public.reward_redemption_rates(partner_program_id)
WHERE partner_program_id IS NOT NULL;

CREATE INDEX idx_reward_redemption_rates_program_type
ON public.reward_redemption_rates(
    loyalty_program_id,
    redemption_type,
    priority
);

CREATE INDEX idx_reward_redemption_rates_active
ON public.reward_redemption_rates(
    loyalty_program_id,
    redemption_type,
    priority
)
WHERE is_active = TRUE;

CREATE UNIQUE INDEX uq_reward_redemption_rates_standard
ON public.reward_redemption_rates(
    loyalty_program_id,
    redemption_type,
    currency_id,
    points_required,
    monetary_value
)
WHERE redemption_type <> 'POINT_TRANSFER';

CREATE UNIQUE INDEX uq_reward_redemption_rates_transfer
ON public.reward_redemption_rates(
    loyalty_program_id,
    partner_program_id,
    transfer_ratio_from,
    transfer_ratio_to
)
WHERE redemption_type = 'POINT_TRANSFER';

CREATE TRIGGER trg_reward_redemption_rates_updated_at
BEFORE UPDATE
ON public.reward_redemption_rates
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
