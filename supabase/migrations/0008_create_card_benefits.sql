CREATE TABLE public.card_benefits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    slug TEXT NOT NULL,

    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    benefit_value NUMERIC(14, 4),
    benefit_unit TEXT,

    terms_en TEXT,
    terms_ar TEXT,

    valid_from DATE,
    valid_to DATE,

    display_order INTEGER NOT NULL DEFAULT 0,

    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_benefits_card_slug
        UNIQUE (card_id, slug),

    CONSTRAINT chk_card_benefits_slug
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),

    CONSTRAINT chk_card_benefits_value
        CHECK (
            benefit_value IS NULL
            OR benefit_value >= 0
        ),

    CONSTRAINT chk_card_benefits_display_order
        CHECK (display_order >= 0),

    CONSTRAINT chk_card_benefits_validity_range
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        )
);

CREATE INDEX idx_card_benefits_card_id
ON public.card_benefits(card_id);

CREATE INDEX idx_card_benefits_card_active
ON public.card_benefits(card_id, is_active);

CREATE INDEX idx_card_benefits_display_order
ON public.card_benefits(card_id, display_order);

CREATE INDEX idx_card_benefits_featured_active
ON public.card_benefits(card_id, display_order)
WHERE is_featured = TRUE
  AND is_active = TRUE;

CREATE TRIGGER trg_card_benefits_updated_at
BEFORE UPDATE
ON public.card_benefits
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
