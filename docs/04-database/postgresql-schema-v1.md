# PostgreSQL Schema v1

> **⚠ Superseded historical design document.** This schema
> specification is a pre-implementation draft and does not match the
> schema actually built in `supabase/migrations/` (`0001`–`0042`,
> merged). It is kept for historical reference only and is not
> maintained against the implemented schema. For the current,
> implemented database design, see
> [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md) and
> [`docs/MIGRATION_INDEX.md`](../MIGRATION_INDEX.md).

## Document Information

| Field              | Value                                    |
| ------------------ | ---------------------------------------- |
| Project            | Credit Card Intelligence Platform (CCIP) |
| Document           | PostgreSQL Schema Specification          |
| Version            | 1.0                                      |
| Status             | Draft                                    |
| Architecture Scope | Recommendation Engine MVP                |
| Database Target    | PostgreSQL / Supabase                    |

---

# 1. Purpose

This document translates the approved CCIP logical database architecture into an implementable PostgreSQL schema specification.

It defines:

* PostgreSQL extensions
* Enum types
* Tables
* Columns
* Primary keys
* Foreign keys
* Check constraints
* Unique constraints
* Indexes
* Timestamp triggers
* Effective-date rules
* Fee-overlap protection
* Reward-rule validation
* Recommended migration order
* Supabase security boundaries

This document is the primary technical reference for the first database migration set.

---

# 2. Scope

PostgreSQL Schema v1 includes:

```text
countries
currencies
banks
card_types
card_levels
card_networks
loyalty_programs
cards
spending_categories
mcc_categories
reward_rules
reward_rule_targets
reward_rule_exclusions
fees
fee_waiver_rules
```

The schema supports:

```text
Card discovery
Reward calculations
Reward valuation
Annual fee calculations
Fee waivers
Recommendation eligibility
Recommendation ranking
Data verification metadata
```

---

# 3. Implementation Principles

The schema must follow these principles:

* Use UUID primary keys.
* Use stable business codes.
* Use lowercase URL slugs.
* Use explicit foreign keys.
* Use structured enums for controlled values.
* Use decimal numeric types for money and reward rates.
* Use `timestamptz` rather than timezone-naive timestamps.
* Use soft deactivation instead of normal production deletion.
* Never treat missing financial data as zero.
* Keep recommendation behavior deterministic.
* Preserve official source traceability.
* Enforce integrity at the database layer where practical.

---

# 4. PostgreSQL Extensions

The following extension is required:

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

Purpose:

```text
gen_random_uuid()
```

Optional future extensions:

```sql
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS btree_gist;
```

`btree_gist` is recommended if exclusion constraints are used to prevent overlapping effective-date periods.

---

# 5. Naming Conventions

## Tables

Use:

```text
lowercase_snake_case
```

Examples:

```text
reward_rules
fee_waiver_rules
```

---

## Columns

Use:

```text
lowercase_snake_case
```

---

## Primary Keys

Use:

```text
id
```

Type:

```sql
uuid
```

---

## Foreign Keys

Use:

```text
<entity>_id
```

Examples:

```text
bank_id
currency_id
reward_rule_id
```

---

## Constraints

Recommended prefixes:

```text
pk_
fk_
uq_
ck_
ex_
```

Examples:

```text
pk_cards
fk_cards_bank
uq_cards_code
ck_fees_amount_nonnegative
```

---

## Indexes

Recommended prefix:

```text
idx_
```

Example:

```text
idx_cards_recommendation_eligibility
```

---

# 6. Shared Column Standards

Most entities use:

```sql
id uuid PRIMARY KEY DEFAULT gen_random_uuid()
```

Timestamps:

```sql
created_at timestamptz NOT NULL DEFAULT now()
updated_at timestamptz NOT NULL DEFAULT now()
```

Current-state verification metadata:

```sql
effective_from date NOT NULL DEFAULT CURRENT_DATE
last_verified_at timestamptz
```

`last_verified_at` should be required for production-published financial data, but may remain nullable during draft administration workflows.

---

# 7. Enum Strategy

PostgreSQL enums provide strong integrity but require migrations when values change.

For Schema v1, stable controlled values may use PostgreSQL enums.

Highly changeable classifications should use reference tables or text with check constraints.

Approved Schema v1 strategy:

```text
Stable operational values → PostgreSQL enum
Business taxonomies → Reference table
```

---

# 8. Enum Definitions

## Card Availability Status

```sql
CREATE TYPE card_availability_status AS ENUM (
    'DRAFT',
    'AVAILABLE',
    'TEMPORARILY_UNAVAILABLE',
    'DISCONTINUED'
);
```

---

## Target User Type

This is metadata only.

```sql
CREATE TYPE card_target_user_type AS ENUM (
    'GENERAL',
    'TRAVEL',
    'CASHBACK',
    'PREMIUM',
    'STUDENT',
    'BUSINESS',
    'ISLAMIC',
    'OTHER'
);
```

It must not directly determine recommendation eligibility or scoring.

---

## Loyalty Program Type

```sql
CREATE TYPE loyalty_program_type AS ENUM (
    'POINTS',
    'MILES',
    'CASHBACK',
    'OTHER'
);
```

---

## Reward Type

```sql
CREATE TYPE reward_type AS ENUM (
    'POINTS',
    'MILES',
    'CASHBACK'
);
```

---

## Reward Calculation Method

```sql
CREATE TYPE reward_calculation_method AS ENUM (
    'PER_SPEND_UNIT',
    'PERCENTAGE',
    'FIXED_PER_TRANSACTION',
    'TIERED'
);
```

`TIERED` is reserved for future implementation.

A tiered rule must not be published until a tier structure exists.

---

## Reward Cap Period

```sql
CREATE TYPE reward_cap_period AS ENUM (
    'TRANSACTION',
    'DAILY',
    'WEEKLY',
    'MONTHLY',
    'STATEMENT_CYCLE',
    'CALENDAR_YEAR',
    'CARD_MEMBERSHIP_YEAR',
    'CAMPAIGN'
);
```

---

## Minimum Spend Period

```sql
CREATE TYPE minimum_spend_period AS ENUM (
    'TRANSACTION',
    'MONTHLY',
    'STATEMENT_CYCLE',
    'CALENDAR_YEAR',
    'CARD_MEMBERSHIP_YEAR',
    'CAMPAIGN'
);
```

---

## Rounding Method

```sql
CREATE TYPE reward_rounding_method AS ENUM (
    'NONE',
    'FLOOR',
    'CEILING',
    'ROUND_HALF_UP',
    'ROUND_HALF_EVEN'
);
```

---

## Reward Target Type

```sql
CREATE TYPE reward_target_type AS ENUM (
    'GENERAL',
    'SPENDING_CATEGORY',
    'MCC'
);
```

`MCC_GROUP` is deferred until MCC groups are implemented.

---

## Reward Exclusion Type

```sql
CREATE TYPE reward_exclusion_type AS ENUM (
    'SPENDING_CATEGORY',
    'MCC',
    'CASH_LIKE',
    'GOVERNMENT',
    'FEES',
    'REFUNDS',
    'OTHER'
);
```

---

## Fee Type

```sql
CREATE TYPE fee_type AS ENUM (
    'ANNUAL_PRIMARY_CARD',
    'ANNUAL_SUPPLEMENTARY_CARD'
);
```

Future values may be added through migrations.

---

## Billing Period

```sql
CREATE TYPE billing_period AS ENUM (
    'ONE_TIME',
    'MONTHLY',
    'QUARTERLY',
    'ANNUAL'
);
```

---

## Fee Waiver Type

```sql
CREATE TYPE fee_waiver_type AS ENUM (
    'SPEND_THRESHOLD',
    'FIRST_YEAR',
    'FULL_WAIVER',
    'PARTIAL_FIXED',
    'PARTIAL_PERCENTAGE'
);
```

---

## Threshold Period

```sql
CREATE TYPE threshold_period AS ENUM (
    'MONTHLY',
    'STATEMENT_CYCLE',
    'CALENDAR_YEAR',
    'CARD_MEMBERSHIP_YEAR'
);
```

---

# 9. Countries Table

```sql
CREATE TABLE countries (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,
    slug text NOT NULL,

    name_en text NOT NULL,
    name_ar text NOT NULL,

    is_active boolean NOT NULL DEFAULT true,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_countries_code UNIQUE (code),
    CONSTRAINT uq_countries_slug UNIQUE (slug),

    CONSTRAINT ck_countries_code_format
        CHECK (code ~ '^[A-Z]{2}$'),

    CONSTRAINT ck_countries_slug_format
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);
```

Examples:

```text
SA
AE
BH
KW
```

---

# 10. Currencies Table

```sql
CREATE TABLE currencies (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,
    slug text NOT NULL,

    name_en text NOT NULL,
    name_ar text NOT NULL,

    symbol_en text,
    symbol_ar text,

    decimal_places smallint NOT NULL DEFAULT 2,

    is_active boolean NOT NULL DEFAULT true,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_currencies_code UNIQUE (code),
    CONSTRAINT uq_currencies_slug UNIQUE (slug),

    CONSTRAINT ck_currencies_code_format
        CHECK (code ~ '^[A-Z]{3}$'),

    CONSTRAINT ck_currencies_slug_format
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),

    CONSTRAINT ck_currencies_decimal_places
        CHECK (decimal_places BETWEEN 0 AND 6)
);
```

---

# 11. Banks Table

```sql
CREATE TABLE banks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,
    slug text NOT NULL,

    country_id uuid NOT NULL,

    name_en text NOT NULL,
    name_ar text NOT NULL,
    short_name text,

    website_url text,
    customer_service_phone text,
    logo_url text,

    is_active boolean NOT NULL DEFAULT true,

    effective_from date NOT NULL DEFAULT CURRENT_DATE,
    last_verified_at timestamptz,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_banks_code UNIQUE (code),
    CONSTRAINT uq_banks_slug UNIQUE (slug),

    CONSTRAINT fk_banks_country
        FOREIGN KEY (country_id)
        REFERENCES countries(id)
        ON DELETE RESTRICT,

    CONSTRAINT ck_banks_code_format
        CHECK (code ~ '^[A-Z0-9_]+$'),

    CONSTRAINT ck_banks_slug_format
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);
```

Indexes:

```sql
CREATE INDEX idx_banks_country_id
    ON banks(country_id);

CREATE INDEX idx_banks_active
    ON banks(is_active);
```

---

# 12. Card Types Table

```sql
CREATE TABLE card_types (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,
    slug text NOT NULL,

    name_en text NOT NULL,
    name_ar text NOT NULL,

    description_en text,
    description_ar text,

    is_active boolean NOT NULL DEFAULT true,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_types_code UNIQUE (code),
    CONSTRAINT uq_card_types_slug UNIQUE (slug),

    CONSTRAINT ck_card_types_code_format
        CHECK (code ~ '^[A-Z0-9_]+$'),

    CONSTRAINT ck_card_types_slug_format
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);
```

Seed values:

```text
CREDIT
CHARGE
DEBIT
PREPAID
```

---

# 13. Card Levels Table

```sql
CREATE TABLE card_levels (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,
    slug text NOT NULL,

    name_en text NOT NULL,
    name_ar text NOT NULL,

    rank_order integer,

    is_active boolean NOT NULL DEFAULT true,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_levels_code UNIQUE (code),
    CONSTRAINT uq_card_levels_slug UNIQUE (slug),

    CONSTRAINT ck_card_levels_code_format
        CHECK (code ~ '^[A-Z0-9_]+$'),

    CONSTRAINT ck_card_levels_slug_format
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),

    CONSTRAINT ck_card_levels_rank_order
        CHECK (rank_order IS NULL OR rank_order >= 0)
);
```

---

# 14. Card Networks Table

```sql
CREATE TABLE card_networks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,
    slug text NOT NULL,

    name_en text NOT NULL,
    name_ar text NOT NULL,

    website_url text,
    logo_url text,

    is_active boolean NOT NULL DEFAULT true,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_networks_code UNIQUE (code),
    CONSTRAINT uq_card_networks_slug UNIQUE (slug),

    CONSTRAINT ck_card_networks_code_format
        CHECK (code ~ '^[A-Z0-9_]+$'),

    CONSTRAINT ck_card_networks_slug_format
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);
```

---

# 15. Spending Categories Table

```sql
CREATE TABLE spending_categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,
    slug text NOT NULL,

    parent_category_id uuid,

    name_en text NOT NULL,
    name_ar text NOT NULL,

    description_en text,
    description_ar text,

    display_order integer NOT NULL DEFAULT 0,
    icon_key text,

    is_active boolean NOT NULL DEFAULT true,
    is_user_selectable boolean NOT NULL DEFAULT true,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_spending_categories_code UNIQUE (code),
    CONSTRAINT uq_spending_categories_slug UNIQUE (slug),

    CONSTRAINT fk_spending_categories_parent
        FOREIGN KEY (parent_category_id)
        REFERENCES spending_categories(id)
        ON DELETE RESTRICT,

    CONSTRAINT ck_spending_categories_code_format
        CHECK (code ~ '^[A-Z0-9_]+$'),

    CONSTRAINT ck_spending_categories_slug_format
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),

    CONSTRAINT ck_spending_categories_display_order
        CHECK (display_order >= 0),

    CONSTRAINT ck_spending_categories_not_own_parent
        CHECK (parent_category_id IS NULL OR parent_category_id <> id)
);
```

Indexes:

```sql
CREATE INDEX idx_spending_categories_parent
    ON spending_categories(parent_category_id);

CREATE INDEX idx_spending_categories_user_selectable
    ON spending_categories(is_active, is_user_selectable);
```

The database check prevents direct self-reference.

Cycle detection beyond one level must be handled through an administrative validation function or trigger.

---

# 16. Loyalty Programs Table

```sql
CREATE TABLE loyalty_programs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,
    slug text NOT NULL,

    owner_bank_id uuid,
    valuation_currency_id uuid NOT NULL,

    program_type loyalty_program_type NOT NULL,

    name_en text NOT NULL,
    name_ar text NOT NULL,

    reference_unit_value numeric(20, 8) NOT NULL,

    website_url text,

    is_active boolean NOT NULL DEFAULT true,

    effective_from date NOT NULL DEFAULT CURRENT_DATE,
    last_verified_at timestamptz,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_loyalty_programs_code UNIQUE (code),
    CONSTRAINT uq_loyalty_programs_slug UNIQUE (slug),

    CONSTRAINT fk_loyalty_programs_owner_bank
        FOREIGN KEY (owner_bank_id)
        REFERENCES banks(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_loyalty_programs_valuation_currency
        FOREIGN KEY (valuation_currency_id)
        REFERENCES currencies(id)
        ON DELETE RESTRICT,

    CONSTRAINT ck_loyalty_programs_code_format
        CHECK (code ~ '^[A-Z0-9_]+$'),

    CONSTRAINT ck_loyalty_programs_slug_format
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),

    CONSTRAINT ck_loyalty_programs_reference_unit_value
        CHECK (reference_unit_value >= 0)
);
```

Indexes:

```sql
CREATE INDEX idx_loyalty_programs_owner_bank
    ON loyalty_programs(owner_bank_id);

CREATE INDEX idx_loyalty_programs_currency
    ON loyalty_programs(valuation_currency_id);

CREATE INDEX idx_loyalty_programs_active
    ON loyalty_programs(is_active);
```

Important:

```text
reference_unit_value = SAR or other valuation currency value per one reward unit
```

Example:

```text
1 AlFursan mile = 0.05 SAR
```

---

# 17. Cards Table

```sql
CREATE TABLE cards (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,
    slug text NOT NULL,

    bank_id uuid NOT NULL,
    card_type_id uuid NOT NULL,
    card_level_id uuid,
    card_network_id uuid NOT NULL,
    primary_loyalty_program_id uuid,
    currency_id uuid NOT NULL,

    name_en text NOT NULL,
    name_ar text NOT NULL,

    short_name_en text,
    short_name_ar text,

    description_en text,
    description_ar text,

    application_url text,
    image_url text,

    target_user_type card_target_user_type
        NOT NULL DEFAULT 'GENERAL',

    availability_status card_availability_status
        NOT NULL DEFAULT 'DRAFT',

    is_active boolean NOT NULL DEFAULT true,
    is_public boolean NOT NULL DEFAULT false,
    is_recommendation_eligible boolean NOT NULL DEFAULT false,

    effective_from date NOT NULL DEFAULT CURRENT_DATE,
    last_verified_at timestamptz,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_cards_code UNIQUE (code),
    CONSTRAINT uq_cards_slug UNIQUE (slug),

    CONSTRAINT fk_cards_bank
        FOREIGN KEY (bank_id)
        REFERENCES banks(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_cards_card_type
        FOREIGN KEY (card_type_id)
        REFERENCES card_types(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_cards_card_level
        FOREIGN KEY (card_level_id)
        REFERENCES card_levels(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_cards_card_network
        FOREIGN KEY (card_network_id)
        REFERENCES card_networks(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_cards_primary_loyalty_program
        FOREIGN KEY (primary_loyalty_program_id)
        REFERENCES loyalty_programs(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_cards_currency
        FOREIGN KEY (currency_id)
        REFERENCES currencies(id)
        ON DELETE RESTRICT,

    CONSTRAINT ck_cards_code_format
        CHECK (code ~ '^[A-Z0-9_]+$'),

    CONSTRAINT ck_cards_slug_format
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),

    CONSTRAINT ck_cards_recommendation_public
        CHECK (
            is_recommendation_eligible = false
            OR is_public = true
        ),

    CONSTRAINT ck_cards_recommendation_active
        CHECK (
            is_recommendation_eligible = false
            OR is_active = true
        ),

    CONSTRAINT ck_cards_available_if_recommendable
        CHECK (
            is_recommendation_eligible = false
            OR availability_status = 'AVAILABLE'
        )
);
```

Indexes:

```sql
CREATE INDEX idx_cards_bank
    ON cards(bank_id);

CREATE INDEX idx_cards_card_type
    ON cards(card_type_id);

CREATE INDEX idx_cards_card_level
    ON cards(card_level_id);

CREATE INDEX idx_cards_card_network
    ON cards(card_network_id);

CREATE INDEX idx_cards_primary_loyalty_program
    ON cards(primary_loyalty_program_id);

CREATE INDEX idx_cards_currency
    ON cards(currency_id);

CREATE INDEX idx_cards_recommendation_eligibility
    ON cards(
        availability_status,
        is_active,
        is_public,
        is_recommendation_eligible
    );

CREATE INDEX idx_cards_public_available
    ON cards(bank_id, card_level_id)
    WHERE
        is_active = true
        AND is_public = true
        AND availability_status = 'AVAILABLE';
```

---

# 18. MCC Categories Table

```sql
CREATE TABLE mcc_categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,
    slug text NOT NULL,

    spending_category_id uuid NOT NULL,

    name_en text NOT NULL,
    name_ar text NOT NULL,

    description_en text,
    description_ar text,

    network_reference text,
    source_url text,

    is_financial_transaction boolean NOT NULL DEFAULT false,
    is_cash_like boolean NOT NULL DEFAULT false,
    is_government boolean NOT NULL DEFAULT false,
    is_commonly_excluded boolean NOT NULL DEFAULT false,

    is_active boolean NOT NULL DEFAULT true,

    effective_from date NOT NULL DEFAULT CURRENT_DATE,
    last_verified_at timestamptz,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_mcc_categories_code UNIQUE (code),
    CONSTRAINT uq_mcc_categories_slug UNIQUE (slug),

    CONSTRAINT fk_mcc_categories_spending_category
        FOREIGN KEY (spending_category_id)
        REFERENCES spending_categories(id)
        ON DELETE RESTRICT,

    CONSTRAINT ck_mcc_categories_code_format
        CHECK (code ~ '^[0-9]{4}$'),

    CONSTRAINT ck_mcc_categories_slug_format
        CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);
```

Indexes:

```sql
CREATE INDEX idx_mcc_categories_spending_category
    ON mcc_categories(spending_category_id);

CREATE INDEX idx_mcc_categories_active
    ON mcc_categories(is_active);

CREATE INDEX idx_mcc_categories_special_flags
    ON mcc_categories(
        is_cash_like,
        is_government,
        is_commonly_excluded
    );
```

---

# 19. Reward Rules Table

```sql
CREATE TABLE reward_rules (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,

    card_id uuid NOT NULL,
    loyalty_program_id uuid,
    currency_id uuid NOT NULL,

    reward_type reward_type NOT NULL,
    calculation_method reward_calculation_method NOT NULL,

    reward_rate numeric(20, 8) NOT NULL,
    spend_unit numeric(20, 8) NOT NULL DEFAULT 1,

    minimum_transaction_amount numeric(18, 4),
    minimum_period_spend numeric(18, 4),
    minimum_spend_period minimum_spend_period,

    maximum_reward_amount numeric(20, 8),
    maximum_eligible_spend numeric(18, 4),
    cap_period reward_cap_period,

    rounding_method reward_rounding_method
        NOT NULL DEFAULT 'NONE',

    priority integer NOT NULL DEFAULT 100,

    is_base_rule boolean NOT NULL DEFAULT false,
    is_promotional boolean NOT NULL DEFAULT false,
    is_active boolean NOT NULL DEFAULT true,

    effective_from date NOT NULL DEFAULT CURRENT_DATE,
    effective_to date,

    last_verified_at timestamptz,

    source_url text,
    source_reference text,

    notes_en text,
    notes_ar text,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_reward_rules_code UNIQUE (code),

    CONSTRAINT fk_reward_rules_card
        FOREIGN KEY (card_id)
        REFERENCES cards(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reward_rules_loyalty_program
        FOREIGN KEY (loyalty_program_id)
        REFERENCES loyalty_programs(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reward_rules_currency
        FOREIGN KEY (currency_id)
        REFERENCES currencies(id)
        ON DELETE RESTRICT,

    CONSTRAINT ck_reward_rules_code_format
        CHECK (code ~ '^[A-Z0-9_]+$'),

    CONSTRAINT ck_reward_rules_reward_rate
        CHECK (reward_rate >= 0),

    CONSTRAINT ck_reward_rules_spend_unit
        CHECK (spend_unit > 0),

    CONSTRAINT ck_reward_rules_min_transaction
        CHECK (
            minimum_transaction_amount IS NULL
            OR minimum_transaction_amount >= 0
        ),

    CONSTRAINT ck_reward_rules_min_period_spend
        CHECK (
            minimum_period_spend IS NULL
            OR minimum_period_spend >= 0
        ),

    CONSTRAINT ck_reward_rules_max_reward
        CHECK (
            maximum_reward_amount IS NULL
            OR maximum_reward_amount >= 0
        ),

    CONSTRAINT ck_reward_rules_max_spend
        CHECK (
            maximum_eligible_spend IS NULL
            OR maximum_eligible_spend >= 0
        ),

    CONSTRAINT ck_reward_rules_priority
        CHECK (priority >= 0),

    CONSTRAINT ck_reward_rules_effective_dates
        CHECK (
            effective_to IS NULL
            OR effective_to >= effective_from
        ),

    CONSTRAINT ck_reward_rules_minimum_period_pair
        CHECK (
            (
                minimum_period_spend IS NULL
                AND minimum_spend_period IS NULL
            )
            OR
            (
                minimum_period_spend IS NOT NULL
                AND minimum_spend_period IS NOT NULL
            )
        ),

    CONSTRAINT ck_reward_rules_cap_pair
        CHECK (
            (
                maximum_reward_amount IS NULL
                AND maximum_eligible_spend IS NULL
                AND cap_period IS NULL
            )
            OR
            (
                (
                    maximum_reward_amount IS NOT NULL
                    OR maximum_eligible_spend IS NOT NULL
                )
                AND cap_period IS NOT NULL
            )
        ),

    CONSTRAINT ck_reward_rules_loyalty_program
        CHECK (
            reward_type = 'CASHBACK'
            OR loyalty_program_id IS NOT NULL
        ),

    CONSTRAINT ck_reward_rules_cashback_method
        CHECK (
            reward_type <> 'CASHBACK'
            OR calculation_method IN (
                'PERCENTAGE',
                'FIXED_PER_TRANSACTION'
            )
        ),

    CONSTRAINT ck_reward_rules_tiered_not_publishable
        CHECK (
            calculation_method <> 'TIERED'
            OR is_active = false
        )
);
```

Indexes:

```sql
CREATE INDEX idx_reward_rules_card
    ON reward_rules(card_id);

CREATE INDEX idx_reward_rules_loyalty_program
    ON reward_rules(loyalty_program_id);

CREATE INDEX idx_reward_rules_currency
    ON reward_rules(currency_id);

CREATE INDEX idx_reward_rules_card_effective
    ON reward_rules(
        card_id,
        is_active,
        effective_from,
        effective_to
    );

CREATE INDEX idx_reward_rules_priority
    ON reward_rules(card_id, priority);
```

---

# 20. Reward Rule Targets Table

```sql
CREATE TABLE reward_rule_targets (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    reward_rule_id uuid NOT NULL,

    target_type reward_target_type NOT NULL,

    spending_category_id uuid,
    mcc_category_id uuid,

    created_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT fk_reward_rule_targets_rule
        FOREIGN KEY (reward_rule_id)
        REFERENCES reward_rules(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reward_rule_targets_spending_category
        FOREIGN KEY (spending_category_id)
        REFERENCES spending_categories(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reward_rule_targets_mcc
        FOREIGN KEY (mcc_category_id)
        REFERENCES mcc_categories(id)
        ON DELETE RESTRICT,

    CONSTRAINT ck_reward_rule_targets_configuration
        CHECK (
            (
                target_type = 'GENERAL'
                AND spending_category_id IS NULL
                AND mcc_category_id IS NULL
            )
            OR
            (
                target_type = 'SPENDING_CATEGORY'
                AND spending_category_id IS NOT NULL
                AND mcc_category_id IS NULL
            )
            OR
            (
                target_type = 'MCC'
                AND spending_category_id IS NULL
                AND mcc_category_id IS NOT NULL
            )
        )
);
```

Indexes:

```sql
CREATE INDEX idx_reward_rule_targets_rule
    ON reward_rule_targets(reward_rule_id);

CREATE INDEX idx_reward_rule_targets_category
    ON reward_rule_targets(spending_category_id)
    WHERE spending_category_id IS NOT NULL;

CREATE INDEX idx_reward_rule_targets_mcc
    ON reward_rule_targets(mcc_category_id)
    WHERE mcc_category_id IS NOT NULL;
```

Unique indexes:

```sql
CREATE UNIQUE INDEX uq_reward_rule_targets_general
    ON reward_rule_targets(reward_rule_id)
    WHERE target_type = 'GENERAL';

CREATE UNIQUE INDEX uq_reward_rule_targets_category
    ON reward_rule_targets(
        reward_rule_id,
        spending_category_id
    )
    WHERE target_type = 'SPENDING_CATEGORY';

CREATE UNIQUE INDEX uq_reward_rule_targets_mcc
    ON reward_rule_targets(
        reward_rule_id,
        mcc_category_id
    )
    WHERE target_type = 'MCC';
```

A rule may target multiple spending categories or MCCs.

A rule may have only one general target.

---

# 21. Reward Rule Exclusions Table

```sql
CREATE TABLE reward_rule_exclusions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    reward_rule_id uuid NOT NULL,

    exclusion_type reward_exclusion_type NOT NULL,

    spending_category_id uuid,
    mcc_category_id uuid,
    exclusion_code text,

    reason_en text,
    reason_ar text,

    created_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT fk_reward_rule_exclusions_rule
        FOREIGN KEY (reward_rule_id)
        REFERENCES reward_rules(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reward_rule_exclusions_spending_category
        FOREIGN KEY (spending_category_id)
        REFERENCES spending_categories(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reward_rule_exclusions_mcc
        FOREIGN KEY (mcc_category_id)
        REFERENCES mcc_categories(id)
        ON DELETE RESTRICT,

    CONSTRAINT ck_reward_rule_exclusions_configuration
        CHECK (
            (
                exclusion_type = 'SPENDING_CATEGORY'
                AND spending_category_id IS NOT NULL
                AND mcc_category_id IS NULL
                AND exclusion_code IS NULL
            )
            OR
            (
                exclusion_type = 'MCC'
                AND spending_category_id IS NULL
                AND mcc_category_id IS NOT NULL
                AND exclusion_code IS NULL
            )
            OR
            (
                exclusion_type IN (
                    'CASH_LIKE',
                    'GOVERNMENT',
                    'FEES',
                    'REFUNDS'
                )
                AND spending_category_id IS NULL
                AND mcc_category_id IS NULL
            )
            OR
            (
                exclusion_type = 'OTHER'
                AND spending_category_id IS NULL
                AND mcc_category_id IS NULL
                AND exclusion_code IS NOT NULL
            )
        )
);
```

Indexes:

```sql
CREATE INDEX idx_reward_rule_exclusions_rule
    ON reward_rule_exclusions(reward_rule_id);

CREATE INDEX idx_reward_rule_exclusions_category
    ON reward_rule_exclusions(spending_category_id)
    WHERE spending_category_id IS NOT NULL;

CREATE INDEX idx_reward_rule_exclusions_mcc
    ON reward_rule_exclusions(mcc_category_id)
    WHERE mcc_category_id IS NOT NULL;

CREATE INDEX idx_reward_rule_exclusions_type
    ON reward_rule_exclusions(reward_rule_id, exclusion_type);
```

Unique indexes:

```sql
CREATE UNIQUE INDEX uq_reward_rule_exclusions_category
    ON reward_rule_exclusions(
        reward_rule_id,
        spending_category_id
    )
    WHERE exclusion_type = 'SPENDING_CATEGORY';

CREATE UNIQUE INDEX uq_reward_rule_exclusions_mcc
    ON reward_rule_exclusions(
        reward_rule_id,
        mcc_category_id
    )
    WHERE exclusion_type = 'MCC';

CREATE UNIQUE INDEX uq_reward_rule_exclusions_managed
    ON reward_rule_exclusions(
        reward_rule_id,
        exclusion_type
    )
    WHERE exclusion_type IN (
        'CASH_LIKE',
        'GOVERNMENT',
        'FEES',
        'REFUNDS'
    );

CREATE UNIQUE INDEX uq_reward_rule_exclusions_other
    ON reward_rule_exclusions(
        reward_rule_id,
        exclusion_code
    )
    WHERE exclusion_type = 'OTHER';
```

---

# 22. Fees Table

```sql
CREATE TABLE fees (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,

    card_id uuid NOT NULL,
    fee_type fee_type NOT NULL,
    currency_id uuid NOT NULL,

    amount numeric(18, 4) NOT NULL,

    billing_period billing_period
        NOT NULL DEFAULT 'ANNUAL',

    supplementary_sequence integer,

    is_refundable boolean NOT NULL DEFAULT false,
    is_tax_inclusive boolean,

    is_active boolean NOT NULL DEFAULT true,

    effective_from date NOT NULL DEFAULT CURRENT_DATE,
    effective_to date,

    last_verified_at timestamptz,

    source_url text,
    source_reference text,

    notes_en text,
    notes_ar text,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_fees_code UNIQUE (code),

    CONSTRAINT fk_fees_card
        FOREIGN KEY (card_id)
        REFERENCES cards(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_fees_currency
        FOREIGN KEY (currency_id)
        REFERENCES currencies(id)
        ON DELETE RESTRICT,

    CONSTRAINT ck_fees_code_format
        CHECK (code ~ '^[A-Z0-9_]+$'),

    CONSTRAINT ck_fees_amount
        CHECK (amount >= 0),

    CONSTRAINT ck_fees_supplementary_sequence
        CHECK (
            supplementary_sequence IS NULL
            OR supplementary_sequence >= 1
        ),

    CONSTRAINT ck_fees_effective_dates
        CHECK (
            effective_to IS NULL
            OR effective_to >= effective_from
        ),

    CONSTRAINT ck_fees_sequence_matches_type
        CHECK (
            (
                fee_type = 'ANNUAL_PRIMARY_CARD'
                AND supplementary_sequence IS NULL
            )
            OR
            (
                fee_type = 'ANNUAL_SUPPLEMENTARY_CARD'
            )
        )
);
```

`is_tax_inclusive` is intentionally nullable.

Reason:

```text
Unknown tax treatment must not be guessed.
```

Indexes:

```sql
CREATE INDEX idx_fees_card
    ON fees(card_id);

CREATE INDEX idx_fees_currency
    ON fees(currency_id);

CREATE INDEX idx_fees_card_effective
    ON fees(
        card_id,
        fee_type,
        is_active,
        effective_from,
        effective_to
    );
```

Unique expression index:

```sql
CREATE UNIQUE INDEX uq_fees_card_type_sequence_start
    ON fees(
        card_id,
        fee_type,
        COALESCE(supplementary_sequence, 0),
        effective_from
    );
```

---

# 23. Fee Waiver Rules Table

```sql
CREATE TABLE fee_waiver_rules (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL,

    fee_id uuid NOT NULL,

    waiver_type fee_waiver_type NOT NULL,

    threshold_amount numeric(18, 4),
    threshold_currency_id uuid,
    threshold_period threshold_period,

    waiver_amount numeric(18, 4),
    waiver_percentage numeric(7, 4),

    applicable_year_number integer,

    is_automatic boolean NOT NULL DEFAULT true,
    is_active boolean NOT NULL DEFAULT true,

    effective_from date NOT NULL DEFAULT CURRENT_DATE,
    effective_to date,

    last_verified_at timestamptz,

    source_url text,
    source_reference text,

    notes_en text,
    notes_ar text,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_fee_waiver_rules_code UNIQUE (code),

    CONSTRAINT fk_fee_waiver_rules_fee
        FOREIGN KEY (fee_id)
        REFERENCES fees(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_fee_waiver_rules_threshold_currency
        FOREIGN KEY (threshold_currency_id)
        REFERENCES currencies(id)
        ON DELETE RESTRICT,

    CONSTRAINT ck_fee_waiver_rules_code_format
        CHECK (code ~ '^[A-Z0-9_]+$'),

    CONSTRAINT ck_fee_waiver_rules_threshold_amount
        CHECK (
            threshold_amount IS NULL
            OR threshold_amount >= 0
        ),

    CONSTRAINT ck_fee_waiver_rules_waiver_amount
        CHECK (
            waiver_amount IS NULL
            OR waiver_amount >= 0
        ),

    CONSTRAINT ck_fee_waiver_rules_percentage
        CHECK (
            waiver_percentage IS NULL
            OR (
                waiver_percentage > 0
                AND waiver_percentage <= 100
            )
        ),

    CONSTRAINT ck_fee_waiver_rules_year
        CHECK (
            applicable_year_number IS NULL
            OR applicable_year_number >= 1
        ),

    CONSTRAINT ck_fee_waiver_rules_effective_dates
        CHECK (
            effective_to IS NULL
            OR effective_to >= effective_from
        ),

    CONSTRAINT ck_fee_waiver_rules_threshold_pair
        CHECK (
            (
                threshold_amount IS NULL
                AND threshold_currency_id IS NULL
                AND threshold_period IS NULL
            )
            OR
            (
                threshold_amount IS NOT NULL
                AND threshold_currency_id IS NOT NULL
                AND threshold_period IS NOT NULL
            )
        ),

    CONSTRAINT ck_fee_waiver_rules_configuration
        CHECK (
            (
                waiver_type = 'SPEND_THRESHOLD'
                AND threshold_amount IS NOT NULL
                AND threshold_currency_id IS NOT NULL
                AND threshold_period IS NOT NULL
                AND (
                    waiver_amount IS NOT NULL
                    OR waiver_percentage IS NOT NULL
                )
            )
            OR
            (
                waiver_type = 'FIRST_YEAR'
                AND applicable_year_number = 1
                AND threshold_amount IS NULL
                AND waiver_amount IS NULL
                AND (
                    waiver_percentage IS NULL
                    OR waiver_percentage = 100
                )
            )
            OR
            (
                waiver_type = 'FULL_WAIVER'
                AND waiver_amount IS NULL
                AND (
                    waiver_percentage IS NULL
                    OR waiver_percentage = 100
                )
            )
            OR
            (
                waiver_type = 'PARTIAL_FIXED'
                AND waiver_amount IS NOT NULL
                AND waiver_percentage IS NULL
            )
            OR
            (
                waiver_type = 'PARTIAL_PERCENTAGE'
                AND waiver_percentage IS NOT NULL
                AND waiver_amount IS NULL
            )
        )
);
```

Indexes:

```sql
CREATE INDEX idx_fee_waiver_rules_fee
    ON fee_waiver_rules(fee_id);

CREATE INDEX idx_fee_waiver_rules_effective
    ON fee_waiver_rules(
        fee_id,
        is_active,
        effective_from,
        effective_to
    );
```

---

# 24. Updated-At Trigger

Create one shared trigger function:

```sql
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;
```

Apply it to tables containing `updated_at`.

```sql
CREATE TRIGGER trg_countries_updated_at
BEFORE UPDATE ON countries
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_currencies_updated_at
BEFORE UPDATE ON currencies
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_banks_updated_at
BEFORE UPDATE ON banks
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_card_types_updated_at
BEFORE UPDATE ON card_types
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_card_levels_updated_at
BEFORE UPDATE ON card_levels
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_card_networks_updated_at
BEFORE UPDATE ON card_networks
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_spending_categories_updated_at
BEFORE UPDATE ON spending_categories
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_loyalty_programs_updated_at
BEFORE UPDATE ON loyalty_programs
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_cards_updated_at
BEFORE UPDATE ON cards
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_mcc_categories_updated_at
BEFORE UPDATE ON mcc_categories
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_reward_rules_updated_at
BEFORE UPDATE ON reward_rules
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_fees_updated_at
BEFORE UPDATE ON fees
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_fee_waiver_rules_updated_at
BEFORE UPDATE ON fee_waiver_rules
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
```

---

# 25. Preventing Overlapping Primary Annual Fees

A card must not have multiple active primary annual fees for the same effective period.

Recommended implementation uses a PostgreSQL exclusion constraint.

First enable:

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;
```

Then:

```sql
ALTER TABLE fees
ADD CONSTRAINT ex_fees_no_overlapping_active_periods
EXCLUDE USING gist (
    card_id WITH =,
    fee_type WITH =,
    COALESCE(supplementary_sequence, 0) WITH =,
    daterange(
        effective_from,
        COALESCE(effective_to, 'infinity'::date),
        '[]'
    ) WITH &&
)
WHERE (is_active = true);
```

Purpose:

Prevent overlapping active fee periods for the same:

```text
Card
Fee Type
Supplementary Sequence
```

This is especially important for:

```text
ANNUAL_PRIMARY_CARD
```

---

# 26. Preventing Overlapping Reward Rules

Reward rules may legitimately overlap when they target different categories or have different priorities.

Therefore, Schema v1 must not globally block overlapping reward-rule dates.

The following should instead be validated:

* Duplicate rule codes are blocked.
* Duplicate targets are blocked.
* Priority resolves simultaneous matches.
* Admin publishing warns about ambiguous rules.
* Exact MCC rules override category rules.
* Category rules override general rules.

A future publishing-validation function should detect two rules that share:

```text
Same card
Same target
Same effective period
Same priority
```

Such a conflict should be blocked before publication.

---

# 27. Rule Target Requirement

PostgreSQL table checks cannot guarantee that every reward rule has at least one target because targets exist in another table.

Required application-level publishing validation:

```text
A reward rule cannot become publishable unless it has at least one target.
```

Recommended future database function:

```sql
validate_reward_rule_for_publication(reward_rule_id uuid)
```

The function should verify:

* Rule has at least one target.
* Rule has official source information.
* Rule has verification timestamp.
* Points and miles rules have a loyalty program.
* Rule dates are valid.
* No unresolved target conflict exists.

---

# 28. Recommendation Data Completeness

A card should be considered runtime-eligible only when all conditions are met.

Card state:

```sql
cards.is_active = true
AND cards.is_public = true
AND cards.is_recommendation_eligible = true
AND cards.availability_status = 'AVAILABLE'
```

Required related data:

```text
At least one active effective reward rule
Each active rule has at least one target
One active effective primary annual fee
Verified reward valuation where required
Required source and verification metadata
```

Database flags alone do not prove runtime completeness.

The Recommendation Engine must run a completeness check.

---

# 29. Recommended Eligibility View

Create a view for basic card eligibility.

```sql
CREATE VIEW recommendation_candidate_cards AS
SELECT
    c.*
FROM cards c
WHERE
    c.is_active = true
    AND c.is_public = true
    AND c.is_recommendation_eligible = true
    AND c.availability_status = 'AVAILABLE';
```

This view only checks card-level status.

It does not verify reward-rule or fee completeness.

---

# 30. Recommended Effective Fees View

```sql
CREATE VIEW current_primary_annual_fees AS
SELECT
    f.*
FROM fees f
WHERE
    f.fee_type = 'ANNUAL_PRIMARY_CARD'
    AND f.is_active = true
    AND f.effective_from <= CURRENT_DATE
    AND (
        f.effective_to IS NULL
        OR f.effective_to >= CURRENT_DATE
    );
```

---

# 31. Recommended Effective Reward Rules View

```sql
CREATE VIEW current_reward_rules AS
SELECT
    rr.*
FROM reward_rules rr
WHERE
    rr.is_active = true
    AND rr.effective_from <= CURRENT_DATE
    AND (
        rr.effective_to IS NULL
        OR rr.effective_to >= CURRENT_DATE
    );
```

Important:

Views using `CURRENT_DATE` are convenient for live queries.

For reproducible historical calculations, the engine should query using an explicit calculation date instead of relying exclusively on these views.

---

# 32. Reward Calculation Interpretation

## PER_SPEND_UNIT

Formula:

```text
Reward Quantity
=
Eligible Spend
÷ spend_unit
× reward_rate
```

Example:

```text
1 mile per 5 SAR
```

Stored as:

```text
reward_rate = 1
spend_unit = 5
```

---

## PERCENTAGE

Formula:

```text
Reward Quantity
=
Eligible Spend
× reward_rate
÷ 100
```

Example:

```text
5% cashback
```

Stored as:

```text
reward_rate = 5
spend_unit = 1
```

---

## FIXED_PER_TRANSACTION

Formula:

```text
Reward Quantity
=
Eligible Transaction Count
× reward_rate
```

This requires transaction-count input.

The standard category-only Recommendation Engine cannot accurately use this method unless an assumption or transaction profile is provided.

Therefore:

```text
FIXED_PER_TRANSACTION rules should be excluded from standard MVP ranking
unless transaction frequency is available.
```

---

# 33. Annual Fee Normalization

Billing periods convert to annual cost as follows:

```text
ONE_TIME
Not included in ongoing recurring ranking

MONTHLY
amount × 12

QUARTERLY
amount × 4

ANNUAL
amount
```

The Recommendation Engine must use:

```text
Ongoing Annual Fee
```

for its primary ranking.

First-year value should be returned separately when available.

---

# 34. Numeric Precision

Recommended money storage:

```sql
numeric(18, 4)
```

Recommended reward rate and valuation storage:

```sql
numeric(20, 8)
```

Reasons:

* Avoid floating-point inaccuracies.
* Support low-value reward units.
* Support fractional rates.
* Preserve deterministic calculations.

Application code must not use binary floating-point numbers for final financial calculations.

Recommended application types:

```text
Decimal
BigDecimal
Arbitrary-precision numeric
```

---

# 35. Currency Consistency

Schema v1 explicitly stores currencies but does not include exchange rates.

MVP requirement:

```text
Card fee currency
User-spending currency
Reward valuation currency
```

must be compatible for direct comparison.

Saudi MVP expected currency:

```text
SAR
```

If currencies differ and no exchange rate exists:

```text
The engine must not silently compare or add the values.
```

Recommended behavior:

```text
Mark calculation unsupported
or
exclude affected card with explanation
```

---

# 36. Row Level Security Strategy

Supabase exposes tables through its API layer.

Row Level Security must be enabled before production.

Recommended access model:

## Public Read

Public users may read only approved, active, public data.

Examples:

```text
banks
cards
card types
card levels
card networks
spending categories
selected MCC data
```

---

## Restricted Financial Logic

Direct public access should not automatically expose every internal rule field.

Recommended access:

```text
Reward calculations through an API or secured database function
```

rather than unrestricted raw-table access.

---

## Admin Write

Only authenticated users with an authorized admin role may:

* Create records.
* Update records.
* Deactivate records.
* Publish cards.
* Publish reward rules.
* Publish fees.
* Change valuations.

---

# 37. Enable RLS

Example:

```sql
ALTER TABLE countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE currencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE banks ENABLE ROW LEVEL SECURITY;
ALTER TABLE card_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE card_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE card_networks ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE spending_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE mcc_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_rule_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_rule_exclusions ENABLE ROW LEVEL SECURITY;
ALTER TABLE fees ENABLE ROW LEVEL SECURITY;
ALTER TABLE fee_waiver_rules ENABLE ROW LEVEL SECURITY;
```

Enabling RLS without policies blocks normal API access.

Policies should be added in a separate migration after roles and permissions are defined.

---

# 38. Public Card Read Policy Example

Illustrative only:

```sql
CREATE POLICY public_read_available_cards
ON cards
FOR SELECT
TO anon, authenticated
USING (
    is_active = true
    AND is_public = true
    AND availability_status = 'AVAILABLE'
);
```

This does not automatically mean reward rules and internal notes should be public.

---

# 39. Service Role

The backend Recommendation Engine may use:

```text
Supabase service role
```

only on the server.

The service-role key must never be exposed in:

```text
Browser code
Mobile client
Public environment variables
GitHub repository
```

---

# 40. Administrative Draft Workflow

Recommended record lifecycle:

```text
Draft
↓
Data Entry
↓
Validation
↓
Official Source Verification
↓
Admin Review
↓
Publication
↓
Periodic Reverification
↓
Deactivation or Update
```

Cards use:

```text
availability_status = DRAFT
is_public = false
is_recommendation_eligible = false
```

during preparation.

---

# 41. Verification Requirements

Production publication should require:

## Cards

```text
last_verified_at
```

---

## Reward Rules

```text
source_url
last_verified_at
```

---

## Fees

```text
source_url
last_verified_at
```

---

## Loyalty Program Valuation

```text
last_verified_at
reference_unit_value
valuation_currency_id
```

These requirements may be enforced through admin publishing validation rather than `NOT NULL` constraints, allowing drafts to remain incomplete.

---

# 42. Recommended Migration Files

Create migrations in this order:

```text
0001_enable_extensions.sql
0002_create_enums.sql
0003_create_reference_tables.sql
0004_create_banks.sql
0005_create_spending_categories.sql
0006_create_loyalty_programs.sql
0007_create_cards.sql
0008_create_mcc_categories.sql
0009_create_reward_rules.sql
0010_create_reward_rule_targets.sql
0011_create_reward_rule_exclusions.sql
0012_create_fees.sql
0013_create_fee_waiver_rules.sql
0014_create_indexes.sql
0015_create_updated_at_triggers.sql
0016_create_exclusion_constraints.sql
0017_create_views.sql
0018_enable_rls.sql
0019_create_rls_policies.sql
0020_seed_reference_data.sql
```

Migration names may include timestamps when generated by Supabase CLI.

---

# 43. Seed Data

Initial seed data should include:

## Countries

```text
Saudi Arabia
```

---

## Currencies

```text
SAR
```

---

## Card Types

```text
CREDIT
CHARGE
DEBIT
PREPAID
```

---

## Card Networks

```text
VISA
MASTERCARD
AMERICAN_EXPRESS
MADA
```

---

## Card Levels

Examples:

```text
CLASSIC
GOLD
PLATINUM
SIGNATURE
INFINITE
WORLD
WORLD_ELITE
```

---

## Spending Categories

At minimum:

```text
GENERAL
DINING
GROCERIES
FUEL
TRAVEL
AIRLINES
HOTELS
ONLINE_SHOPPING
ENTERTAINMENT
UTILITIES
GOVERNMENT
EDUCATION
HEALTHCARE
OTHER
```

Final category seed values must remain consistent with `mcc-categories.md`.

---

# 44. Test Data

Production migrations should not contain fictional card data.

Use separate test fixtures for:

* Example banks
* Example cards
* Example loyalty programs
* Reward rules
* Fees
* Waiver scenarios

Recommended location:

```text
supabase/tests/fixtures/
```

or:

```text
database/test-fixtures/
```

---

# 45. Required Database Tests

## Reference Data

* Reject invalid country codes.
* Reject invalid currency codes.
* Reject duplicate codes.
* Reject invalid slugs.

---

## Cards

* Reject missing bank.
* Reject missing card type.
* Reject missing network.
* Reject missing currency.
* Reject recommendable but non-public cards.
* Reject recommendable but unavailable cards.

---

## MCC

* Reject non-four-digit MCC code.
* Reject missing spending category.
* Reject duplicate MCC code.

---

## Reward Rules

* Reject zero or negative spend unit.
* Reject invalid date ranges.
* Reject points or miles rule without loyalty program.
* Reject cap without cap period.
* Reject minimum period spend without period.
* Reject active tiered rule in v1.

---

## Reward Targets

* Reject general target with category.
* Reject category target without category.
* Reject MCC target without MCC.
* Reject duplicate target.

---

## Reward Exclusions

* Reject invalid field combinations.
* Reject duplicate exclusions.

---

## Fees

* Reject negative fee amount.
* Reject invalid effective-date range.
* Reject supplementary sequence below one.
* Reject sequence on primary fee.
* Reject overlapping active fee records.

---

## Fee Waivers

* Reject invalid percentages.
* Reject threshold without currency or period.
* Reject partial fixed waiver without amount.
* Reject partial percentage waiver without percentage.
* Reject first-year waiver with a year other than one.

---

# 46. Transaction Boundaries

Administrative publishing should use database transactions.

Example publication operation:

```text
Validate Card
Validate Reward Rules
Validate Rule Targets
Validate Annual Fee
Validate Loyalty Valuation
Set Public
Set Recommendation Eligible
Commit
```

If any validation fails:

```text
Rollback
```

A card must not become publicly recommendable in a partially configured state.

---

# 47. Soft Deactivation

Preferred retirement behavior:

## Card

```sql
UPDATE cards
SET
    availability_status = 'DISCONTINUED',
    is_recommendation_eligible = false,
    is_public = false
WHERE id = :card_id;
```

---

## Reward Rule

```sql
UPDATE reward_rules
SET is_active = false
WHERE id = :reward_rule_id;
```

---

## Fee

```sql
UPDATE fees
SET
    is_active = false,
    effective_to = CURRENT_DATE
WHERE id = :fee_id;
```

Hard deletion should be limited to:

```text
Incorrect drafts
Test records
Dependent targets
Dependent exclusions
Dependent waiver rules
```

---

# 48. Source URL Validation

PostgreSQL v1 will store URLs as text.

The application should validate:

```text
HTTP or HTTPS URL
Reasonable maximum length
Official domain
No unsupported redirect links
```

A strict database URL regex is not recommended because valid URL formats can be complex.

---

# 49. Slug Generation

Slugs should be generated by the administration layer.

Rules:

* Lowercase.
* Latin characters.
* Digits allowed.
* Hyphens only as separators.
* No leading or trailing hyphen.
* Unique per entity.

Arabic display names should not directly become the canonical slug unless deliberate transliteration is implemented.

---

# 50. Business Code Generation

Codes should be deliberately assigned rather than generated from mutable names.

Examples:

```text
BANK_ALRAJHI
CARD_ALRAJHI_ALFURSAN_VISA_INFINITE
RULE_ALRAJHI_ALFURSAN_VI_DINING
FEE_ALRAJHI_ALFURSAN_VI_ANNUAL
```

A code must remain stable when:

* Product display name changes.
* Arabic translation changes.
* Marketing title changes.
* URL slug changes.

---

# 51. Known Limitations

Schema v1 does not implement:

```text
Historical entity versioning
Multiple loyalty programs per card
Tiered reward detail tables
MCC groups
Merchant-specific rewards
Offers
Benefits
Advanced fee types
Foreign-exchange rates
User accounts
Saved spending profiles
Recommendation-run storage
Audit-event logs
Approval workflow tables
Dynamic reward valuations
```

These are deferred deliberately.

---

# 52. Architecture Decisions

## PG-001

Use UUID primary keys generated with `gen_random_uuid()`.

---

## PG-002

Use `timestamptz` for database timestamps.

---

## PG-003

Use `numeric`, not floating-point types, for financial and reward calculations.

---

## PG-004

Use PostgreSQL enums for stable operational classifications.

---

## PG-005

Allow incomplete draft records where administrative workflow requires it, but block incomplete publication through validation.

---

## PG-006

A recommendable card must be active, public, and available.

---

## PG-007

Missing fee data is not equivalent to a zero fee.

---

## PG-008

Confirmed no-fee cards require an explicit zero-value primary annual fee row.

---

## PG-009

Overlapping active fees for the same card and fee type must be blocked.

---

## PG-010

Overlapping reward rules may exist when priority and target specificity resolve them.

---

## PG-011

Tiered reward calculation remains inactive until a tier table is introduced.

---

## PG-012

Row Level Security must be enabled before production API exposure.

---

## PG-013

The Supabase service role may only be used in trusted server-side code.

---

## PG-014

The Recommendation Engine must use an explicit calculation date for reproducible results.

---

# 53. Final Schema Relationship Summary

```text
COUNTRIES
└── BANKS
    ├── CARDS
    │   ├── REWARD_RULES
    │   │   ├── REWARD_RULE_TARGETS
    │   │   └── REWARD_RULE_EXCLUSIONS
    │   │
    │   └── FEES
    │       └── FEE_WAIVER_RULES
    │
    └── LOYALTY_PROGRAMS

CURRENCIES
├── CARDS
├── LOYALTY_PROGRAMS
├── REWARD_RULES
├── FEES
└── FEE_WAIVER_RULES

CARD_TYPES
└── CARDS

CARD_LEVELS
└── CARDS

CARD_NETWORKS
└── CARDS

SPENDING_CATEGORIES
├── CHILD SPENDING CATEGORIES
├── MCC_CATEGORIES
├── REWARD_RULE_TARGETS
└── REWARD_RULE_EXCLUSIONS

MCC_CATEGORIES
├── REWARD_RULE_TARGETS
└── REWARD_RULE_EXCLUSIONS
```

---

# 54. Implementation Readiness

PostgreSQL Schema v1 is ready to be converted into Supabase migration files after:

```text
Architecture review
Enum review
Seed taxonomy review
RLS role decision
Repository implementation structure approval
```

The schema provides a controlled, deterministic, and extensible database foundation for the CCIP Recommendation Engine MVP.
