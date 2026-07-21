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

    overall_score NUMERIC(5, 2),

    score_confidence NUMERIC(5, 2),

    scoring_method TEXT NOT NULL DEFAULT 'EDITORIAL',

    scoring_version TEXT NOT NULL DEFAULT '1.0',

    recommended_minimum_salary NUMERIC(14, 2),

    currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    methodology_notes_en TEXT,
    methodology_notes_ar TEXT,

    source_url TEXT,

    valid_from DATE,
    valid_to DATE,

    priority SMALLINT NOT NULL DEFAULT 1,

    is_default BOOLEAN NOT NULL DEFAULT FALSE,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_comparison_profiles
        UNIQUE (
            card_id,
            profile_slug
        ),

    CONSTRAINT chk_card_comparison_profiles_slug
        CHECK (
            profile_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_card_comparison_profiles_travel_score
        CHECK (
            travel_score IS NULL
            OR travel_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_cashback_score
        CHECK (
            cashback_score IS NULL
            OR cashback_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_rewards_score
        CHECK (
            rewards_score IS NULL
            OR rewards_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_lounge_score
        CHECK (
            lounge_score IS NULL
            OR lounge_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_dining_score
        CHECK (
            dining_score IS NULL
            OR dining_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_shopping_score
        CHECK (
            shopping_score IS NULL
            OR shopping_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_insurance_score
        CHECK (
            insurance_score IS NULL
            OR insurance_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_lifestyle_score
        CHECK (
            lifestyle_score IS NULL
            OR lifestyle_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_digital_score
        CHECK (
            digital_score IS NULL
            OR digital_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_business_score
        CHECK (
            business_score IS NULL
            OR business_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_overall_score
        CHECK (
            overall_score IS NULL
            OR overall_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_score_confidence
        CHECK (
            score_confidence IS NULL
            OR score_confidence BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_profiles_scoring_method
        CHECK (
            scoring_method IN (
                'EDITORIAL',
                'RULE_BASED',
                'WEIGHTED_MODEL',
                'HYBRID',
                'MACHINE_LEARNING'
            )
        ),

    CONSTRAINT chk_card_comparison_profiles_scoring_version
        CHECK (
            length(trim(scoring_version)) > 0
        ),

    CONSTRAINT chk_card_comparison_profiles_salary
        CHECK (
            recommended_minimum_salary IS NULL
            OR recommended_minimum_salary >= 0
        ),

    CONSTRAINT chk_card_comparison_profiles_salary_currency
        CHECK (
            (
                recommended_minimum_salary IS NULL
                AND currency_id IS NULL
            )
            OR
            (
                recommended_minimum_salary IS NOT NULL
                AND currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_comparison_profiles_priority
        CHECK (
            priority > 0
        ),

    CONSTRAINT chk_card_comparison_profiles_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        )
);

CREATE INDEX idx_card_comparison_profiles_card
ON public.card_comparison_profiles(card_id);

CREATE INDEX idx_card_comparison_profiles_currency
ON public.card_comparison_profiles(currency_id)
WHERE currency_id IS NOT NULL;

CREATE INDEX idx_card_comparison_profiles_profile_slug
ON public.card_comparison_profiles(profile_slug);

CREATE INDEX idx_card_comparison_profiles_scoring_method
ON public.card_comparison_profiles(scoring_method);

CREATE INDEX idx_card_comparison_profiles_overall_score
ON public.card_comparison_profiles(overall_score DESC)
WHERE overall_score IS NOT NULL
  AND is_active = TRUE;

CREATE INDEX idx_card_comparison_profiles_active
ON public.card_comparison_profiles(
    card_id,
    priority
)
WHERE is_active = TRUE;

CREATE UNIQUE INDEX uq_card_comparison_profiles_default
ON public.card_comparison_profiles(card_id)
WHERE is_default = TRUE
  AND is_active = TRUE;

CREATE TRIGGER trg_card_comparison_profiles_updated_at
BEFORE UPDATE
ON public.card_comparison_profiles
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
