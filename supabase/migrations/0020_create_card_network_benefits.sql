CREATE TABLE public.card_network_benefits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    slug TEXT NOT NULL,

    network payment_network NOT NULL,

    provider_name TEXT,

    benefit_category TEXT NOT NULL,

    benefit_name_en TEXT NOT NULL,
    benefit_name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    website_url TEXT,

    registration_required BOOLEAN NOT NULL DEFAULT FALSE,

    activation_required BOOLEAN NOT NULL DEFAULT FALSE,

    mobile_app_required BOOLEAN NOT NULL DEFAULT FALSE,

    valid_from DATE,
    valid_to DATE,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_featured BOOLEAN NOT NULL DEFAULT FALSE,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_network_benefits_slug
        UNIQUE(card_id, slug),

    CONSTRAINT chk_card_network_benefits_slug
        CHECK (
            slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_card_network_benefits_category
        CHECK (
            benefit_category IN (
                'AIRPORT',
                'HOTEL',
                'DINING',
                'TRAVEL',
                'SHOPPING',
                'CONCIERGE',
                'INSURANCE',
                'HEALTH',
                'LIFESTYLE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_card_network_benefits_priority
        CHECK (
            priority > 0
        ),

    CONSTRAINT chk_card_network_benefits_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        )
);

CREATE INDEX idx_card_network_benefits_card
ON public.card_network_benefits(card_id);

CREATE INDEX idx_card_network_benefits_network
ON public.card_network_benefits(network);

CREATE INDEX idx_card_network_benefits_category
ON public.card_network_benefits(
    benefit_category,
    priority
);

CREATE INDEX idx_card_network_benefits_active
ON public.card_network_benefits(
    card_id,
    priority
)
WHERE is_active = TRUE;

CREATE INDEX idx_card_network_benefits_featured
ON public.card_network_benefits(
    card_id,
    priority
)
WHERE is_featured = TRUE
  AND is_active = TRUE;

CREATE TRIGGER trg_card_network_benefits_updated_at
BEFORE UPDATE
ON public.card_network_benefits
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
