CREATE TYPE card_availability_status AS ENUM (
    'AVAILABLE',
    'COMING_SOON',
    'DISCONTINUED'
);

CREATE TYPE target_user_type AS ENUM (
    'GENERAL',
    'STUDENT',
    'SALARY',
    'PRIVATE_BANKING',
    'BUSINESS'
);

CREATE TYPE loyalty_program_type AS ENUM (
    'AIRLINE',
    'HOTEL',
    'BANK_POINTS',
    'CASHBACK',
    'RETAIL',
    'OTHER'
);

CREATE TYPE reward_type AS ENUM (
    'CASHBACK',
    'POINTS',
    'MILES',
    'DISCOUNT',
    'VOUCHER'
);

CREATE TYPE reward_calculation_method AS ENUM (
    'FIXED',
    'PERCENTAGE',
    'TIERED'
);

CREATE TYPE reward_cap_period AS ENUM (
    'NONE',
    'MONTH',
    'QUARTER',
    'YEAR',
    'LIFETIME'
);

CREATE TYPE minimum_spend_period AS ENUM (
    'TRANSACTION',
    'DAY',
    'MONTH',
    'YEAR'
);

CREATE TYPE reward_rounding_method AS ENUM (
    'NONE',
    'UP',
    'DOWN',
    'NEAREST'
);

CREATE TYPE reward_target_type AS ENUM (
    'MCC',
    'CATEGORY'
);

CREATE TYPE reward_exclusion_type AS ENUM (
    'MCC',
    'CATEGORY'
);

CREATE TYPE fee_type AS ENUM (
    'ANNUAL',
    'ISSUANCE',
    'REPLACEMENT',
    'LATE_PAYMENT',
    'FOREIGN_TRANSACTION',
    'CASH_ADVANCE',
    'OTHER'
);

CREATE TYPE billing_period AS ENUM (
    'MONTHLY',
    'QUARTERLY',
    'YEARLY',
    'ONE_TIME'
);

CREATE TYPE fee_waiver_type AS ENUM (
    'NONE',
    'FIRST_YEAR',
    'SPEND_THRESHOLD',
    'SALARY_TRANSFER',
    'LIFETIME'
);

CREATE TYPE threshold_period AS ENUM (
    'MONTH',
    'QUARTER',
    'YEAR'
);
