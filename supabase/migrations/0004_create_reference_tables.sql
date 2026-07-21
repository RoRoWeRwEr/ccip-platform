CREATE TABLE public.countries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    code VARCHAR(2) NOT NULL,
    slug TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),

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
