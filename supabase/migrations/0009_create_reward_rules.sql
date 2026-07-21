CREATE TABLE public.reward_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    reward_category_id UUID
        REFERENCES public.reward_categories(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    reward_type reward_type NOT NULL,

    calculation_method reward_calculation_method NOT NULL,

    reward_value NUMERIC(14,6) NOT NULL,

    reward_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    minimum_spend NUMERIC(14,2),

    minimum_spend_period minimum_spend_period,

    cap_amount NUMERIC(14,2),

    cap_period reward_cap_period NOT NULL DEFAULT 'NONE',

    rounding_method reward_rounding_method
        NOT NULL DEFAULT 'NONE',

    priority SMALLINT NOT NULL DEFAULT 1,

    valid_from DATE,
    valid_to DATE,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_reward_rules_reward_value
        CHECK (reward_value >= 0),

    CONSTRAINT chk_reward_rules_minimum_spend
        CHECK (
            minimum_spend IS NULL
            OR minimum_spend >= 0
        ),

    CONSTRAINT chk_reward_rules_cap_amount
        CHECK (
            cap_amount IS NULL
            OR cap_amount >= 0
        ),

    CONSTRAINT chk_reward_rules_priority
        CHECK (priority > 0),

    CONSTRAINT chk_reward_rules_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        ),

    CONSTRAINT chk_reward_rules_cap
        CHECK (
            (cap_period = 'NONE' AND cap_amount IS NULL)
            OR
            (cap_period <> 'NONE' AND cap_amount IS NOT NULL)
        ),

    CONSTRAINT chk_reward_rules_minimum_spend_period
        CHECK (
            (minimum_spend IS NULL AND minimum_spend_period IS NULL)
            OR
            (minimum_spend IS NOT NULL AND minimum_spend_period IS NOT NULL)
        )
);

CREATE INDEX idx_reward_rules_card_id
ON public.reward_rules(card_id);

CREATE INDEX idx_reward_rules_reward_category
ON public.reward_rules(reward_category_id);

CREATE INDEX idx_reward_rules_reward_type
ON public.reward_rules(reward_type);

CREATE INDEX idx_reward_rules_priority
ON public.reward_rules(card_id, priority);

CREATE INDEX idx_reward_rules_active
ON public.reward_rules(card_id)
WHERE is_active = TRUE;

CREATE TRIGGER trg_reward_rules_updated_at
BEFORE UPDATE
ON public.reward_rules
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
