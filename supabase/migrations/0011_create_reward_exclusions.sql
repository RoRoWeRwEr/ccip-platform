CREATE TABLE public.reward_exclusions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reward_rule_id UUID NOT NULL
        REFERENCES public.reward_rules(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    exclusion_type TEXT NOT NULL,

    merchant_category_id UUID
        REFERENCES public.merchant_categories(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    category_slug TEXT,

    merchant_name_pattern TEXT,

    country_code CHAR(2),

    transaction_type_slug TEXT,

    reason_en TEXT,
    reason_ar TEXT,

    valid_from DATE,
    valid_to DATE,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_reward_exclusions_type
        CHECK (
            exclusion_type IN (
                'MCC',
                'CATEGORY',
                'MERCHANT',
                'COUNTRY',
                'TRANSACTION_TYPE'
            )
        ),

    CONSTRAINT chk_reward_exclusions_configuration
        CHECK (
            (
                exclusion_type = 'MCC'
                AND merchant_category_id IS NOT NULL
                AND category_slug IS NULL
                AND merchant_name_pattern IS NULL
                AND country_code IS NULL
                AND transaction_type_slug IS NULL
            )
            OR
            (
                exclusion_type = 'CATEGORY'
                AND merchant_category_id IS NULL
                AND category_slug IS NOT NULL
                AND merchant_name_pattern IS NULL
                AND country_code IS NULL
                AND transaction_type_slug IS NULL
            )
            OR
            (
                exclusion_type = 'MERCHANT'
                AND merchant_category_id IS NULL
                AND category_slug IS NULL
                AND merchant_name_pattern IS NOT NULL
                AND country_code IS NULL
                AND transaction_type_slug IS NULL
            )
            OR
            (
                exclusion_type = 'COUNTRY'
                AND merchant_category_id IS NULL
                AND category_slug IS NULL
                AND merchant_name_pattern IS NULL
                AND country_code IS NOT NULL
                AND transaction_type_slug IS NULL
            )
            OR
            (
                exclusion_type = 'TRANSACTION_TYPE'
                AND merchant_category_id IS NULL
                AND category_slug IS NULL
                AND merchant_name_pattern IS NULL
                AND country_code IS NULL
                AND transaction_type_slug IS NOT NULL
            )
        ),

    CONSTRAINT chk_reward_exclusions_category_slug
        CHECK (
            category_slug IS NULL
            OR category_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_reward_exclusions_transaction_type_slug
        CHECK (
            transaction_type_slug IS NULL
            OR transaction_type_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_reward_exclusions_merchant_name_pattern
        CHECK (
            merchant_name_pattern IS NULL
            OR length(trim(merchant_name_pattern)) > 0
        ),

    CONSTRAINT chk_reward_exclusions_country_code
        CHECK (
            country_code IS NULL
            OR country_code ~ '^[A-Z]{2}$'
        ),

    CONSTRAINT chk_reward_exclusions_validity
        CHECK (
            valid_from IS NULL
            OR valid_to IS NULL
            OR valid_to >= valid_from
        )
);

CREATE INDEX idx_reward_exclusions_rule
ON public.reward_exclusions(reward_rule_id);

CREATE INDEX idx_reward_exclusions_rule_active
ON public.reward_exclusions(reward_rule_id)
WHERE is_active = TRUE;

CREATE INDEX idx_reward_exclusions_mcc
ON public.reward_exclusions(merchant_category_id)
WHERE merchant_category_id IS NOT NULL;

CREATE INDEX idx_reward_exclusions_category
ON public.reward_exclusions(category_slug)
WHERE category_slug IS NOT NULL;

CREATE INDEX idx_reward_exclusions_merchant
ON public.reward_exclusions(merchant_name_pattern)
WHERE merchant_name_pattern IS NOT NULL;

CREATE INDEX idx_reward_exclusions_country
ON public.reward_exclusions(country_code)
WHERE country_code IS NOT NULL;

CREATE INDEX idx_reward_exclusions_transaction_type
ON public.reward_exclusions(transaction_type_slug)
WHERE transaction_type_slug IS NOT NULL;

CREATE UNIQUE INDEX uq_reward_exclusions_mcc
ON public.reward_exclusions(
    reward_rule_id,
    merchant_category_id
)
WHERE exclusion_type = 'MCC';

CREATE UNIQUE INDEX uq_reward_exclusions_category
ON public.reward_exclusions(
    reward_rule_id,
    category_slug
)
WHERE exclusion_type = 'CATEGORY';

CREATE UNIQUE INDEX uq_reward_exclusions_merchant
ON public.reward_exclusions(
    reward_rule_id,
    lower(merchant_name_pattern)
)
WHERE exclusion_type = 'MERCHANT';

CREATE UNIQUE INDEX uq_reward_exclusions_country
ON public.reward_exclusions(
    reward_rule_id,
    country_code
)
WHERE exclusion_type = 'COUNTRY';

CREATE UNIQUE INDEX uq_reward_exclusions_transaction_type
ON public.reward_exclusions(
    reward_rule_id,
    transaction_type_slug
)
WHERE exclusion_type = 'TRANSACTION_TYPE';

CREATE TRIGGER trg_reward_exclusions_updated_at
BEFORE UPDATE
ON public.reward_exclusions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
