CREATE TABLE public.card_comparison_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    profile_slug TEXT NOT NULL,

    profile_name_en TEXT NOT NULL,
    profile_name_ar TEXT NOT NULL,

    description_en TEXT,
    description_ar TEXT,

    travel_score SMALLINT,
    cashback_score SMALLINT,
    rewards_score SMALLINT,
    lounge_score SMALLINT,
    dining_score SMALLINT,
    shopping_score SMALLINT,
    insurance_score SMALLINT,
    lifestyle_score SMALLINT,
    digital_score SMALLINT,
    business_score SMALLINT,

    overall_score NUMERIC(5,2),

    recommended_minimum_salary NUMERIC(14,2),

    currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_default BOOLEAN NOT NULL DEFAULT FALSE,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_comparison_profiles
        UNIQUE(card_id, profile_slug),

    CONSTRAINT chk_card_comparison_profiles_slug
        CHECK (
            profile_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_card_comparison_profiles_scores
        CHECK (
            COALESCE(travel_score,100) BETWEEN 0 AND 100
            AND COALESCE(cashback_score,100) BETWEEN 0 AND 100
            AND COALESCE(rewards_score,100) BETWEEN 0 AND 100
            AND COALESCE(lounge_score,100) BETWEEN 0 AND 100
            AND COALESCE(dining_score,100) BETWEEN 0 AND 100
            AND COALESCE(shopping_score,100) BETWEEN 0 AND 100
            AND COALESCE(insurance_score,100) BETWEEN 0 AND 100
            AND COALESCE(lifestyle_score,100) BETWEEN 0 AND 100
            AND COALESCE(digital_score,100) BETWEEN 0 AND 100
            AND COALESCE(business_score,100) BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_overall
        CHECK (
            overall_score IS NULL
            OR overall_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_salary
        CHECK (
            recommended_minimum_salary IS NULL
            OR recommended_minimum_salary >= 0
        ),

    CONSTRAINT chk_card_comparison_profiles_priority
        CHECK (
            priority > 0
        )
);

CREATE INDEX idx_card_comparison_profiles_card
ON public.card_comparison_profiles(card_id);

CREATE INDEX idx_card_comparison_profiles_active
ON public.card_comparison_profiles(
    card_id,
    priority
)
WHERE is_active = TRUE;

CREATE UNIQUE INDEX uq_card_comparison_profiles_default
ON public.card_comparison_profiles(card_id)
WHERE is_default = TRUE;

CREATE TRIGGER trg_card_comparison_profiles_updated_at
BEFORE UPDATE
ON public.card_comparison_profiles
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
