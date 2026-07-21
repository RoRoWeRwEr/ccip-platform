CREATE TABLE public.cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    bank_id UUID NOT NULL
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    card_network_id UUID NOT NULL
        REFERENCES public.card_networks(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    currency_id UUID NOT NULL
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    loyalty_program_id UUID
        REFERENCES public.loyalty_programs(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    slug TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    card_tier TEXT,
    target_user target_user_type NOT NULL DEFAULT 'GENERAL',

    availability_status card_availability_status
        NOT NULL
        DEFAULT 'AVAILABLE',

    annual_fee NUMERIC(12, 2) NOT NULL DEFAULT 0,
    minimum_salary NUMERIC(12, 2),
    credit_limit_min NUMERIC(14, 2),
    credit_limit_max NUMERIC(14, 2),

    purchase_rate NUMERIC(7, 4),
    cash_advance_rate NUMERIC(7, 4),
    foreign_transaction_fee_rate NUMERIC(7, 4),

    image_url TEXT,
    application_url TEXT,
    terms_url TEXT,

    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    published_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),

    CONSTRAINT uq_cards_slug UNIQUE (slug),

    CONSTRAINT chk_cards_slug
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),

    CONSTRAINT chk_cards_annual_fee
        CHECK (annual_fee >= 0),

    CONSTRAINT chk_cards_minimum_salary
        CHECK (
            minimum_salary IS NULL
            OR minimum_salary >= 0
        ),

    CONSTRAINT chk_cards_credit_limit_min
        CHECK (
            credit_limit_min IS NULL
            OR credit_limit_min >= 0
        ),

    CONSTRAINT chk_cards_credit_limit_max
        CHECK (
            credit_limit_max IS NULL
            OR credit_limit_max >= 0
        ),

    CONSTRAINT chk_cards_credit_limit_range
        CHECK (
            credit_limit_min IS NULL
            OR credit_limit_max IS NULL
            OR credit_limit_max >= credit_limit_min
        ),

    CONSTRAINT chk_cards_purchase_rate
        CHECK (
            purchase_rate IS NULL
            OR purchase_rate BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_cards_cash_advance_rate
        CHECK (
            cash_advance_rate IS NULL
            OR cash_advance_rate BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_cards_foreign_transaction_fee_rate
        CHECK (
            foreign_transaction_fee_rate IS NULL
            OR foreign_transaction_fee_rate BETWEEN 0 AND 100
        )
);

CREATE INDEX idx_cards_bank_id
ON public.cards(bank_id);

CREATE INDEX idx_cards_card_network_id
ON public.cards(card_network_id);

CREATE INDEX idx_cards_currency_id
ON public.cards(currency_id);

CREATE INDEX idx_cards_loyalty_program_id
ON public.cards(loyalty_program_id);

CREATE INDEX idx_cards_target_user
ON public.cards(target_user);

CREATE INDEX idx_cards_availability_status
ON public.cards(availability_status);

CREATE INDEX idx_cards_is_active
ON public.cards(is_active);

CREATE INDEX idx_cards_is_featured
ON public.cards(is_featured);

CREATE INDEX idx_cards_bank_active
ON public.cards(bank_id, is_active);

CREATE TRIGGER trg_cards_updated_at
BEFORE UPDATE
ON public.cards
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
