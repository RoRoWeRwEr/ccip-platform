CREATE TABLE public.countries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    code VARCHAR(2) NOT NULL,
    slug TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_countries_code UNIQUE (code),
    CONSTRAINT uq_countries_slug UNIQUE (slug),

    CONSTRAINT chk_countries_code
        CHECK (code ~ '^[A-Z]{2}$'),

    CONSTRAINT chk_countries_slug
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE INDEX idx_countries_is_active
ON public.countries(is_active);

CREATE TRIGGER trg_countries_updated_at
BEFORE UPDATE
ON public.countries
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();


CREATE TABLE public.currencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    code VARCHAR(3) NOT NULL,
    slug TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    symbol TEXT,
    decimal_places SMALLINT NOT NULL DEFAULT 2,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_currencies_code UNIQUE (code),
    CONSTRAINT uq_currencies_slug UNIQUE (slug),

    CONSTRAINT chk_currencies_code
        CHECK (code ~ '^[A-Z]{3}$'),

    CONSTRAINT chk_currencies_slug
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),

    CONSTRAINT chk_currencies_decimal_places
        CHECK (decimal_places BETWEEN 0 AND 4)
);

CREATE INDEX idx_currencies_is_active
ON public.currencies(is_active);

CREATE TRIGGER trg_currencies_updated_at
BEFORE UPDATE
ON public.currencies
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();


CREATE TABLE public.merchant_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    code VARCHAR(4) NOT NULL,
    slug TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_merchant_categories_code UNIQUE (code),
    CONSTRAINT uq_merchant_categories_slug UNIQUE (slug),

    CONSTRAINT chk_merchant_categories_code
        CHECK (code ~ '^[0-9]{4}$'),

    CONSTRAINT chk_merchant_categories_slug
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE INDEX idx_merchant_categories_is_active
ON public.merchant_categories(is_active);

CREATE TRIGGER trg_merchant_categories_updated_at
BEFORE UPDATE
ON public.merchant_categories
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();


CREATE TABLE public.reward_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    slug TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    icon_name TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_reward_categories_slug UNIQUE (slug),

    CONSTRAINT chk_reward_categories_slug
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE INDEX idx_reward_categories_is_active
ON public.reward_categories(is_active);

CREATE TRIGGER trg_reward_categories_updated_at
BEFORE UPDATE
ON public.reward_categories
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();


CREATE TYPE public.payment_network AS ENUM (
    'VISA',
    'MASTERCARD',
    'AMERICAN_EXPRESS',
    'MADA'
);


CREATE TABLE public.card_networks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    slug TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    logo_url TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_networks_slug UNIQUE (slug),

    CONSTRAINT chk_card_networks_slug
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE INDEX idx_card_networks_is_active
ON public.card_networks(is_active);

CREATE TRIGGER trg_card_networks_updated_at
BEFORE UPDATE
ON public.card_networks
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();


CREATE TABLE public.loyalty_programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    slug TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    type loyalty_program_type NOT NULL,

    website_url TEXT,
    logo_url TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_loyalty_programs_slug UNIQUE (slug),

    CONSTRAINT chk_loyalty_programs_slug
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE INDEX idx_loyalty_programs_type
ON public.loyalty_programs(type);

CREATE INDEX idx_loyalty_programs_is_active
ON public.loyalty_programs(is_active);

CREATE TRIGGER trg_loyalty_programs_updated_at
BEFORE UPDATE
ON public.loyalty_programs
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
