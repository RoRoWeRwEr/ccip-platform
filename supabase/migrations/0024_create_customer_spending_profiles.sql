CREATE TABLE public.customer_spending_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    financial_profile_id UUID NOT NULL
        REFERENCES public.customer_financial_profiles(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    profile_name TEXT NOT NULL,

    profile_slug TEXT,

    currency_id UUID NOT NULL
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    spending_period TEXT NOT NULL DEFAULT 'MONTHLY',

    period_start DATE,
    period_end DATE,

    total_card_spend NUMERIC(16, 2),

    domestic_spend NUMERIC(16, 2),

    international_spend NUMERIC(16, 2),

    online_spend NUMERIC(16, 2),

    in_store_spend NUMERIC(16, 2),

    contactless_spend NUMERIC(16, 2),

    recurring_spend NUMERIC(16, 2),

    digital_wallet_spend NUMERIC(16, 2),

    installment_purchase_spend NUMERIC(16, 2),

    cash_advance_amount NUMERIC(16, 2),

    foreign_currency_spend NUMERIC(16, 2),

    average_transaction_amount NUMERIC(14, 2),

    estimated_transaction_count INTEGER,

    estimated_international_transaction_count INTEGER,

    expected_annual_spend_growth_rate NUMERIC(7, 4),

    average_monthly_balance_carried NUMERIC(16, 2),

    estimated_monthly_payment NUMERIC(16, 2),

    pays_statement_balance_in_full BOOLEAN,

    uses_installment_plans BOOLEAN,

    uses_cash_advance BOOLEAN,

    uses_digital_wallet BOOLEAN,

    preferred_digital_wallet TEXT,

    primary_spending_channel TEXT,

    spending_data_completeness NUMERIC(5, 2),

    spending_data_confidence NUMERIC(5, 2),

    data_source TEXT NOT NULL DEFAULT 'USER_PROVIDED',

    last_verified_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_customer_spending_profiles_financial_slug
        UNIQUE (
            financial_profile_id,
            profile_slug
        ),

    CONSTRAINT chk_customer_spending_profiles_name
        CHECK (
            length(trim(profile_name)) > 0
        ),

    CONSTRAINT chk_customer_spending_profiles_slug
        CHECK (
            profile_slug IS NULL
            OR profile_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ),

    CONSTRAINT chk_customer_spending_profiles_period
        CHECK (
            spending_period IN (
                'MONTHLY',
                'QUARTERLY',
                'ANNUAL',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_customer_spending_profiles_period_dates
        CHECK (
            period_start IS NULL
            OR period_end IS NULL
            OR period_end >= period_start
        ),

    CONSTRAINT chk_customer_spending_profiles_custom_period
        CHECK (
            spending_period <> 'CUSTOM'
            OR (
                period_start IS NOT NULL
                AND period_end IS NOT NULL
            )
        ),

    CONSTRAINT chk_customer_spending_profiles_amounts
        CHECK (
            (
                total_card_spend IS NULL
                OR total_card_spend >= 0
            )
            AND
            (
                domestic_spend IS NULL
                OR domestic_spend >= 0
            )
            AND
            (
                international_spend IS NULL
                OR international_spend >= 0
            )
            AND
            (
                online_spend IS NULL
                OR online_spend >= 0
            )
            AND
            (
                in_store_spend IS NULL
                OR in_store_spend >= 0
            )
            AND
            (
                contactless_spend IS NULL
                OR contactless_spend >= 0
            )
            AND
            (
                recurring_spend IS NULL
                OR recurring_spend >= 0
            )
            AND
            (
                digital_wallet_spend IS NULL
                OR digital_wallet_spend >= 0
            )
            AND
            (
                installment_purchase_spend IS NULL
                OR installment_purchase_spend >= 0
            )
            AND
            (
                cash_advance_amount IS NULL
                OR cash_advance_amount >= 0
            )
            AND
            (
                foreign_currency_spend IS NULL
                OR foreign_currency_spend >= 0
            )
            AND
            (
                average_transaction_amount IS NULL
                OR average_transaction_amount >= 0
            )
            AND
            (
                average_monthly_balance_carried IS NULL
                OR average_monthly_balance_carried >= 0
            )
            AND
            (
                estimated_monthly_payment IS NULL
                OR estimated_monthly_payment >= 0
            )
        ),

    CONSTRAINT chk_customer_spending_profiles_transaction_count
        CHECK (
            (
                estimated_transaction_count IS NULL
                OR estimated_transaction_count >= 0
            )
            AND
            (
                estimated_international_transaction_count IS NULL
                OR estimated_international_transaction_count >= 0
            )
        ),

    CONSTRAINT chk_customer_spending_profiles_international_count
        CHECK (
            estimated_transaction_count IS NULL
            OR estimated_international_transaction_count IS NULL
            OR estimated_international_transaction_count
                <= estimated_transaction_count
        ),

    CONSTRAINT chk_customer_spending_profiles_growth_rate
        CHECK (
            expected_annual_spend_growth_rate IS NULL
            OR expected_annual_spend_growth_rate
                BETWEEN -100 AND 1000
        ),

    CONSTRAINT chk_customer_spending_profiles_completeness
        CHECK (
            spending_data_completeness IS NULL
            OR spending_data_completeness BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_customer_spending_profiles_confidence
        CHECK (
            spending_data_confidence IS NULL
            OR spending_data_confidence BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_customer_spending_profiles_data_source
        CHECK (
            data_source IN (
                'USER_PROVIDED',
                'BANK_STATEMENT',
                'OPEN_BANKING',
                'ADVISOR_PROVIDED',
                'IMPORTED',
                'ESTIMATED',
                'CALCULATED',
                'HYBRID',
                'TEST_DATA'
            )
        ),

    CONSTRAINT chk_customer_spending_profiles_digital_wallet
        CHECK (
            uses_digital_wallet IS DISTINCT FROM FALSE
            OR preferred_digital_wallet IS NULL
        ),

    CONSTRAINT chk_customer_spending_profiles_primary_channel
        CHECK (
            primary_spending_channel IS NULL
            OR primary_spending_channel IN (
                'IN_STORE',
                'ONLINE',
                'MOBILE_APP',
                'DIGITAL_WALLET',
                'RECURRING_PAYMENT',
                'MIXED',
                'OTHER'
            )
        ),

    CONSTRAINT chk_customer_spending_profiles_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.customer_spending_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    spending_profile_id UUID NOT NULL
        REFERENCES public.customer_spending_profiles(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    category_code TEXT NOT NULL,

    category_name_en TEXT,
    category_name_ar TEXT,

    spending_amount NUMERIC(16, 2) NOT NULL,

    transaction_count INTEGER,

    domestic_amount NUMERIC(16, 2),

    international_amount NUMERIC(16, 2),

    online_amount NUMERIC(16, 2),

    in_store_amount NUMERIC(16, 2),

    recurring_amount NUMERIC(16, 2),

    foreign_currency_amount NUMERIC(16, 2),

    merchant_category_codes TEXT[],

    notes_en TEXT,
    notes_ar TEXT,

    data_source TEXT NOT NULL DEFAULT 'USER_PROVIDED',

    confidence_score NUMERIC(5, 2),

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_customer_spending_categories_profile_category
        UNIQUE (
            spending_profile_id,
            category_code
        ),

    CONSTRAINT chk_customer_spending_categories_code
        CHECK (
            category_code IN (
                'GENERAL',
                'GROCERIES',
                'SUPERMARKETS',
                'DINING',
                'FAST_FOOD',
                'COFFEE_SHOPS',
                'FUEL',
                'TRANSPORTATION',
                'RIDE_HAILING',
                'TRAVEL',
                'AIRLINES',
                'HOTELS',
                'CAR_RENTAL',
                'PUBLIC_TRANSPORT',
                'ONLINE_SHOPPING',
                'RETAIL',
                'DEPARTMENT_STORES',
                'FASHION',
                'ELECTRONICS',
                'ENTERTAINMENT',
                'STREAMING',
                'TELECOMMUNICATIONS',
                'UTILITIES',
                'GOVERNMENT_PAYMENTS',
                'EDUCATION',
                'HEALTHCARE',
                'PHARMACIES',
                'INSURANCE',
                'REAL_ESTATE',
                'HOME_IMPROVEMENT',
                'CHARITY',
                'BUSINESS_EXPENSES',
                'ADVERTISING',
                'PROFESSIONAL_SERVICES',
                'DIGITAL_SERVICES',
                'GAMING',
                'JEWELRY',
                'LUXURY',
                'DUTY_FREE',
                'FOREIGN_CURRENCY',
                'CASH_ADVANCE',
                'INSTALLMENTS',
                'OTHER'
            )
        ),

    CONSTRAINT chk_customer_spending_categories_name
        CHECK (
            category_name_en IS NULL
            OR length(trim(category_name_en)) > 0
        ),

    CONSTRAINT chk_customer_spending_categories_name_ar
        CHECK (
            category_name_ar IS NULL
            OR length(trim(category_name_ar)) > 0
        ),

    CONSTRAINT chk_customer_spending_categories_amount
        CHECK (
            spending_amount >= 0
        ),

    CONSTRAINT chk_customer_spending_categories_transaction_count
        CHECK (
            transaction_count IS NULL
            OR transaction_count >= 0
        ),

    CONSTRAINT chk_customer_spending_categories_breakdown_amounts
        CHECK (
            (
                domestic_amount IS NULL
                OR domestic_amount >= 0
            )
            AND
            (
                international_amount IS NULL
                OR international_amount >= 0
            )
            AND
            (
                online_amount IS NULL
                OR online_amount >= 0
            )
            AND
            (
                in_store_amount IS NULL
                OR in_store_amount >= 0
            )
            AND
            (
                recurring_amount IS NULL
                OR recurring_amount >= 0
            )
            AND
            (
                foreign_currency_amount IS NULL
                OR foreign_currency_amount >= 0
            )
        ),

    CONSTRAINT chk_customer_spending_categories_domestic_international
        CHECK (
            domestic_amount IS NULL
            OR international_amount IS NULL
            OR domestic_amount + international_amount
                <= spending_amount
        ),

    CONSTRAINT chk_customer_spending_categories_online_store
        CHECK (
            online_amount IS NULL
            OR in_store_amount IS NULL
            OR online_amount + in_store_amount
                <= spending_amount
        ),

    CONSTRAINT chk_customer_spending_categories_recurring
        CHECK (
            recurring_amount IS NULL
            OR recurring_amount <= spending_amount
        ),

    CONSTRAINT chk_customer_spending_categories_foreign_currency
        CHECK (
            foreign_currency_amount IS NULL
            OR foreign_currency_amount <= spending_amount
        ),

    CONSTRAINT chk_customer_spending_categories_mcc
        CHECK (
            merchant_category_codes IS NULL
            OR cardinality(merchant_category_codes) > 0
        ),

    CONSTRAINT chk_customer_spending_categories_data_source
        CHECK (
            data_source IN (
                'USER_PROVIDED',
                'BANK_STATEMENT',
                'OPEN_BANKING',
                'ADVISOR_PROVIDED',
                'IMPORTED',
                'ESTIMATED',
                'CALCULATED',
                'HYBRID',
                'TEST_DATA'
            )
        ),

    CONSTRAINT chk_customer_spending_categories_confidence
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_customer_spending_categories_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE INDEX idx_customer_spending_profiles_financial_profile
ON public.customer_spending_profiles(financial_profile_id);

CREATE INDEX idx_customer_spending_profiles_currency
ON public.customer_spending_profiles(currency_id);

CREATE INDEX idx_customer_spending_profiles_period
ON public.customer_spending_profiles(
    spending_period,
    period_start,
    period_end
);

CREATE INDEX idx_customer_spending_profiles_total_spend
ON public.customer_spending_profiles(total_card_spend)
WHERE total_card_spend IS NOT NULL;

CREATE INDEX idx_customer_spending_profiles_active
ON public.customer_spending_profiles(
    financial_profile_id,
    updated_at DESC
)
WHERE is_active = TRUE;

CREATE UNIQUE INDEX uq_customer_spending_profiles_primary
ON public.customer_spending_profiles(financial_profile_id)
WHERE is_primary = TRUE
  AND is_active = TRUE;

CREATE INDEX idx_customer_spending_profiles_metadata
ON public.customer_spending_profiles
USING GIN (metadata);

CREATE INDEX idx_customer_spending_categories_profile
ON public.customer_spending_categories(spending_profile_id);

CREATE INDEX idx_customer_spending_categories_code
ON public.customer_spending_categories(category_code);

CREATE INDEX idx_customer_spending_categories_amount
ON public.customer_spending_categories(
    spending_profile_id,
    spending_amount DESC
)
WHERE is_active = TRUE;

CREATE INDEX idx_customer_spending_categories_mcc
ON public.customer_spending_categories
USING GIN (merchant_category_codes)
WHERE merchant_category_codes IS NOT NULL;

CREATE INDEX idx_customer_spending_categories_metadata
ON public.customer_spending_categories
USING GIN (metadata);

CREATE TRIGGER trg_customer_spending_profiles_updated_at
BEFORE UPDATE
ON public.customer_spending_profiles
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_customer_spending_categories_updated_at
BEFORE UPDATE
ON public.customer_spending_categories
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.customer_spending_profiles IS
'Summary of customer card spending behavior used to calculate rewards, fees, financial value, and product suitability.';

COMMENT ON TABLE public.customer_spending_categories IS
'Category-level spending distribution used by the decision engine to apply card reward and cashback rules.';

COMMENT ON COLUMN public.customer_spending_profiles.spending_period IS
'Period represented by the spending amounts. Values may be monthly, quarterly, annual, or a custom date range.';

COMMENT ON COLUMN public.customer_spending_profiles.total_card_spend IS
'Total expected or observed card spending during the selected spending period.';

COMMENT ON COLUMN public.customer_spending_profiles.foreign_currency_spend IS
'Spending processed in currencies other than the profile currency.';

COMMENT ON COLUMN public.customer_spending_categories.category_code IS
'Normalized spending category used to match customer spending against card reward rules.';

COMMENT ON COLUMN public.customer_spending_categories.merchant_category_codes IS
'Optional payment-network merchant category codes associated with this spending category.';
