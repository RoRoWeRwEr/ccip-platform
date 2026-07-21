CREATE TABLE public.banks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    country_id UUID NOT NULL
        REFERENCES public.countries(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    slug TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    short_name_en TEXT,
    short_name_ar TEXT,

    website_url TEXT,
    logo_url TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_banks_slug UNIQUE (slug),

    CONSTRAINT chk_banks_slug
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE INDEX idx_banks_country_id
ON public.banks(country_id);

CREATE INDEX idx_banks_is_active
ON public.banks(is_active);

CREATE TRIGGER trg_banks_updated_at
BEFORE UPDATE
ON public.banks
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();


CREATE TABLE public.bank_loyalty_programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    bank_id UUID NOT NULL
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    loyalty_program_id UUID NOT NULL
        REFERENCES public.loyalty_programs(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_bank_loyalty_programs
        UNIQUE (bank_id, loyalty_program_id)
);

CREATE INDEX idx_bank_loyalty_programs_loyalty_program_id
ON public.bank_loyalty_programs(loyalty_program_id);

CREATE UNIQUE INDEX uq_bank_primary_loyalty_program
ON public.bank_loyalty_programs(bank_id)
WHERE is_primary = TRUE;

CREATE TRIGGER trg_bank_loyalty_programs_updated_at
BEFORE UPDATE
ON public.bank_loyalty_programs
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
