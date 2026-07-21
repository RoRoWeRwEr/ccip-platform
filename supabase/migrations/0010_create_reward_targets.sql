CREATE TABLE public.reward_targets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reward_rule_id UUID NOT NULL
        REFERENCES public.reward_rules(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    target_type reward_target_type NOT NULL,

    merchant_category_id UUID
        REFERENCES public.merchant_categories(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    category_slug TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_reward_targets_configuration
        CHECK (
            (
                target_type = 'MCC'
                AND merchant_category_id IS NOT NULL
                AND category_slug IS NULL
            )
            OR
            (
                target_type = 'CATEGORY'
                AND merchant_category_id IS NULL
                AND category_slug IS NOT NULL
            )
        )
);

CREATE INDEX idx_reward_targets_rule
ON public.reward_targets(reward_rule_id);

CREATE INDEX idx_reward_targets_mcc
ON public.reward_targets(merchant_category_id);

CREATE INDEX idx_reward_targets_category
ON public.reward_targets(category_slug);

CREATE UNIQUE INDEX uq_reward_targets
ON public.reward_targets(
    reward_rule_id,
    target_type,
    merchant_category_id,
    category_slug
);

CREATE TRIGGER trg_reward_targets_updated_at
BEFORE UPDATE
ON public.reward_targets
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
