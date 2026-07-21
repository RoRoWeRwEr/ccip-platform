# MCC Category Entity

## Document Information

| Field              | Value                                    |
| ------------------ | ---------------------------------------- |
| Project            | Credit Card Intelligence Platform (CCIP) |
| Entity             | MCC Category                             |
| Primary Table      | `mcc_categories`                         |
| Supporting Table   | `spending_categories`                    |
| Version            | 1.0                                      |
| Status             | Draft                                    |
| Architecture Scope | Recommendation Engine MVP                |

---

## 1. Purpose

Merchant Category Codes, commonly known as MCCs, classify merchants according to their primary business activity.

The Credit Card Intelligence Platform uses MCC data to connect:

```text
User Spending
↓
Spending Category
↓
Merchant Category Code
↓
Reward Rule
↓
Estimated Reward Value
```

MCC data is essential because credit card reward rules are often based on merchant categories rather than individual merchant names.

Examples:

* Restaurants
* Grocery stores
* Fuel stations
* Airlines
* Hotels
* Pharmacies
* Government payments
* Telecommunications

---

## 2. Core Modeling Principle

The platform separates two concepts:

### MCC Category

Represents an official or industry-recognized merchant category code.

Example:

```text
MCC 5812
Eating Places and Restaurants
```

### Spending Category

Represents a user-friendly spending group used in:

* Spending profiles
* Reward calculators
* Recommendation inputs
* Search filters
* Reporting

Example:

```text
Dining
```

Multiple MCC records may map to one spending category.

Example:

```text
5812 → Dining
5813 → Dining
5814 → Dining
```

This separation allows the platform to preserve MCC accuracy while presenting simple categories to users.

---

## 3. Tables

The MVP uses two related tables:

```text
spending_categories
mcc_categories
```

Relationship:

```text
spending_categories
1
│
└── many mcc_categories
```

Each MCC category belongs to one primary spending category.

---

# Spending Category Entity

## 4. Purpose

The `spending_categories` table represents the standardized spending groups used by the Recommendation Engine.

Examples:

* Dining
* Groceries
* Fuel
* Travel
* Airlines
* Hotels
* Online Shopping
* Telecommunications
* Utilities
* Healthcare
* Education
* Government Payments
* General Spending

These categories are controlled by the platform and are not intended to exactly reproduce bank terminology.

---

## 5. Spending Category Fields

| Field                | Type      | Required | Unique | Notes                        |
| -------------------- | --------- | -------: | -----: | ---------------------------- |
| `id`                 | UUID      |      Yes |    Yes | Primary key                  |
| `code`               | Text      |      Yes |    Yes | Stable business identifier   |
| `slug`               | Text      |      Yes |    Yes | URL-friendly identifier      |
| `name_en`            | Text      |      Yes |     No | English display name         |
| `name_ar`            | Text      |      Yes |     No | Arabic display name          |
| `description_en`     | Text      |       No |     No | English explanation          |
| `description_ar`     | Text      |       No |     No | Arabic explanation           |
| `parent_category_id` | UUID      |       No |     No | Optional self-reference      |
| `display_order`      | Integer   |      Yes |     No | Controls UI ordering         |
| `icon_key`           | Text      |       No |     No | Frontend icon identifier     |
| `is_active`          | Boolean   |      Yes |     No | Operational status           |
| `is_user_selectable` | Boolean   |      Yes |     No | Visible in spending profiles |
| `created_at`         | Timestamp |      Yes |     No | Record creation timestamp    |
| `updated_at`         | Timestamp |      Yes |     No | Record update timestamp      |

---

## 6. Spending Category Identifiers

Each spending category uses:

| Identifier | Purpose                      | Example  |
| ---------- | ---------------------------- | -------- |
| `id`       | Internal database identifier | UUID     |
| `code`     | Stable business code         | `DINING` |
| `slug`     | Public or UI identifier      | `dining` |

The `code` must remain stable even when display names change.

---

## 7. Spending Category Hierarchy

The optional `parent_category_id` supports category hierarchy.

Example:

```text
Travel
├── Airlines
├── Hotels
├── Car Rental
└── Travel Agencies
```

Example records:

| Code         | Parent   |
| ------------ | -------- |
| `TRAVEL`     | None     |
| `AIRLINES`   | `TRAVEL` |
| `HOTELS`     | `TRAVEL` |
| `CAR_RENTAL` | `TRAVEL` |

The Recommendation Engine may calculate results at either:

* Detailed subcategory level
* Parent category level
* Combined travel level

---

## 8. Recommended MVP Spending Categories

The initial MVP should support the following categories:

| Code              | English Name           | Arabic Name              |
| ----------------- | ---------------------- | ------------------------ |
| `GENERAL`         | General Spending       | الإنفاق العام            |
| `DINING`          | Dining                 | المطاعم                  |
| `GROCERIES`       | Groceries              | البقالة والمواد الغذائية |
| `FUEL`            | Fuel                   | الوقود                   |
| `TRAVEL`          | Travel                 | السفر                    |
| `AIRLINES`        | Airlines               | شركات الطيران            |
| `HOTELS`          | Hotels                 | الفنادق                  |
| `CAR_RENTAL`      | Car Rental             | تأجير السيارات           |
| `ONLINE_SHOPPING` | Online Shopping        | التسوق الإلكتروني        |
| `RETAIL`          | Retail Shopping        | التسوق                   |
| `TELECOM`         | Telecommunications     | الاتصالات                |
| `UTILITIES`       | Utilities              | الخدمات والمرافق         |
| `HEALTHCARE`      | Healthcare             | الرعاية الصحية           |
| `PHARMACY`        | Pharmacy               | الصيدليات                |
| `EDUCATION`       | Education              | التعليم                  |
| `ENTERTAINMENT`   | Entertainment          | الترفيه                  |
| `GOVERNMENT`      | Government Payments    | المدفوعات الحكومية       |
| `TRANSPORTATION`  | Transportation         | النقل                    |
| `INSURANCE`       | Insurance              | التأمين                  |
| `REAL_ESTATE`     | Real Estate            | العقار                   |
| `CHARITY`         | Charity                | التبرعات والجمعيات       |
| `CASH_LIKE`       | Cash-Like Transactions | المعاملات الشبيهة بالنقد |
| `EXCLUDED`        | Excluded Transactions  | المعاملات المستثناة      |

This list may expand during reward-rule data collection.

---

## 9. Recommended Spending Category Defaults

| Field                | Default           |
| -------------------- | ----------------- |
| `display_order`      | `0`               |
| `is_active`          | `true`            |
| `is_user_selectable` | `true`            |
| `created_at`         | Current timestamp |
| `updated_at`         | Current timestamp |

Categories such as `CASH_LIKE` and `EXCLUDED` should normally use:

```text
is_user_selectable = false
```

They are system categories and should not normally appear as user spending inputs.

---

# MCC Category Entity

## 10. Purpose

The `mcc_categories` table stores individual Merchant Category Codes and maps them to platform spending categories.

Each record represents one MCC code.

Example:

```text
5812
Eating Places and Restaurants
Dining
```

---

## 11. MCC Category Fields

| Field                      | Type      | Required | Unique | Notes                                      |
| -------------------------- | --------- | -------: | -----: | ------------------------------------------ |
| `id`                       | UUID      |      Yes |    Yes | Primary key                                |
| `code`                     | Text      |      Yes |    Yes | MCC code, normally four digits             |
| `slug`                     | Text      |      Yes |    Yes | Stable URL-friendly identifier             |
| `spending_category_id`     | UUID      |      Yes |     No | Foreign key to `spending_categories.id`    |
| `name_en`                  | Text      |      Yes |     No | Official or normalized English name        |
| `name_ar`                  | Text      |      Yes |     No | Normalized Arabic name                     |
| `description_en`           | Text      |       No |     No | English explanation                        |
| `description_ar`           | Text      |       No |     No | Arabic explanation                         |
| `network_reference`        | Text      |       No |     No | Source network or classification reference |
| `source_url`               | Text      |       No |     No | Official or trusted source URL             |
| `is_financial_transaction` | Boolean   |      Yes |     No | Identifies financial or cash-like activity |
| `is_cash_like`             | Boolean   |      Yes |     No | Identifies cash-equivalent transactions    |
| `is_government`            | Boolean   |      Yes |     No | Government-related MCC                     |
| `is_commonly_excluded`     | Boolean   |      Yes |     No | Commonly excluded from rewards             |
| `is_active`                | Boolean   |      Yes |     No | Operational status                         |
| `effective_from`           | Date      |       No |     No | Date classification became effective       |
| `last_verified_at`         | Timestamp |       No |     No | Last source verification                   |
| `created_at`               | Timestamp |      Yes |     No | Record creation timestamp                  |
| `updated_at`               | Timestamp |      Yes |     No | Record update timestamp                    |

---

## 12. MCC Code Storage

The MCC code must be stored as text rather than an integer.

Correct:

```text
"0742"
```

Incorrect:

```text
742
```

Reason:

Some MCC codes may contain leading zeros.

Recommended validation:

```text
Exactly four numeric characters
```

Example rule:

```text
^[0-9]{4}$
```

---

## 13. MCC Identifiers

Each MCC record uses:

| Identifier | Purpose                  | Example                          |
| ---------- | ------------------------ | -------------------------------- |
| `id`       | Internal identifier      | UUID                             |
| `code`     | Official MCC code        | `5812`                           |
| `slug`     | Stable public identifier | `5812-eating-places-restaurants` |

The MCC `code` must be globally unique within the platform.

---

## 14. Relationships

### Spending Category

Each MCC belongs to one primary spending category.

Foreign key:

```text
mcc_categories.spending_category_id
→ spending_categories.id
```

Example:

```text
5812 → DINING
5814 → DINING
5411 → GROCERIES
5541 → FUEL
```

### Reward Rules

Reward rules may reference:

* A specific MCC
* A spending category
* A group of categories
* General spending

Future relationship:

```text
mcc_categories
many
│
└── many reward_rules
```

This relationship may be implemented through a junction table.

---

## 15. MCC Mapping Strategy

The platform should use a single primary spending category for every MCC.

Example:

```text
MCC 5812
Primary Category: DINING
```

The same MCC should not be duplicated under multiple primary categories.

When an MCC could logically belong to more than one category, the platform should select the category that best reflects:

* Common card reward treatment
* User understanding
* Recommendation use
* Merchant activity

Future versions may support secondary labels through a tagging table.

---

## 16. General Spending

`GENERAL` is a fallback spending category.

It should be used when:

* No special reward category applies
* A reward rule covers all eligible purchases
* The MCC is unknown
* The bank does not provide detailed category conditions

`GENERAL` must not be treated as an MCC itself.

It is a platform spending category used by the recommendation and reward calculation layers.

---

## 17. Excluded and Cash-Like Transactions

Some transaction categories frequently receive no rewards.

Examples may include:

* Cash withdrawals
* Money transfers
* Quasi-cash transactions
* Wallet loading
* Financial institution transactions
* Card fees
* Government payments
* Certain utility payments

The database must not assume that these transactions are always excluded.

Instead:

```text
mcc_categories.is_commonly_excluded
```

is informational metadata only.

Actual eligibility must be defined in each card’s reward rules.

---

## 18. MCC Source and Verification

Every MCC record should be traceable to a trusted source when possible.

Recommended fields:

```text
network_reference
source_url
effective_from
last_verified_at
```

Potential sources may include:

* Card network MCC documentation
* Acquirer documentation
* Official bank terms
* Official reward-program terms
* Verified industry references

The source used for a specific reward rule should be stored separately in the reward-rule entity.

---

## 19. Recommendation Engine Usage

The Recommendation Engine uses MCC categories as follows:

```text
User enters monthly dining spending
↓
DINING category is identified
↓
MCCs mapped to DINING are retrieved
↓
Relevant card reward rules are matched
↓
Reward value is calculated
↓
Cards are ranked by estimated net value
```

For MVP calculations, the engine may calculate at the spending-category level without requiring the user to enter individual MCC codes.

MCC-level rules provide greater precision when banks define exclusions or special earning rates.

---

## 20. Reward Matching Priority

When several reward rules could match the same transaction, the recommended matching priority is:

```text
1. Exact MCC rule
2. MCC group rule
3. Spending category rule
4. General spending rule
5. No reward
```

A more specific rule should override a broader rule unless the reward-rule document explicitly defines another priority.

---

## 21. Constraints

### Spending Categories

Required constraints:

* `id` must be unique.
* `code` must be unique.
* `slug` must be unique.
* `name_en` must not be empty.
* `name_ar` must not be empty.
* `parent_category_id` must not reference the same record.
* `display_order` must be zero or greater.

### MCC Categories

Required constraints:

* `id` must be unique.
* `code` must be unique.
* `slug` must be unique.
* `code` must contain exactly four numeric characters.
* `spending_category_id` must reference an existing spending category.
* `name_en` must not be empty.
* `name_ar` must not be empty.
* `source_url`, when provided, must be a valid URL.
* `last_verified_at` must not be earlier than `effective_from`.

---

## 22. Recommended Defaults

### MCC Categories

| Field                      | Default           |
| -------------------------- | ----------------- |
| `is_financial_transaction` | `false`           |
| `is_cash_like`             | `false`           |
| `is_government`            | `false`           |
| `is_commonly_excluded`     | `false`           |
| `is_active`                | `true`            |
| `created_at`               | Current timestamp |
| `updated_at`               | Current timestamp |

---

## 23. Example Spending Category Record

```yaml
code: DINING
slug: dining

name_en: Dining
name_ar: المطاعم

parent_category: null
display_order: 20
icon_key: utensils

is_active: true
is_user_selectable: true
```

---

## 24. Example MCC Record

```yaml
code: "5812"
slug: 5812-eating-places-restaurants

spending_category: DINING

name_en: Eating Places and Restaurants
name_ar: المطاعم وأماكن تقديم الطعام

is_financial_transaction: false
is_cash_like: false
is_government: false
is_commonly_excluded: false

effective_from: null
last_verified_at: 2026-07-21
```

---

## 25. Example Mapping

```text
DINING
├── 5812 Eating Places and Restaurants
├── 5813 Drinking Places
└── 5814 Fast Food Restaurants

GROCERIES
├── 5411 Grocery Stores and Supermarkets
└── 5499 Miscellaneous Food Stores

FUEL
├── 5541 Service Stations
└── 5542 Automated Fuel Dispensers

AIRLINES
└── Airline-related MCC records

HOTELS
└── Lodging-related MCC records
```

The complete MCC dataset will be populated separately and should not be manually embedded in application code.

---

## 26. Data Administration Rules

Admin users should be able to:

* Create a spending category
* Edit Arabic and English category names
* Assign parent categories
* Control user visibility
* Add or edit MCC records
* Map an MCC to a spending category
* Mark financial or cash-like MCCs
* Record source URLs
* Record verification dates
* Deactivate obsolete records

Changing an MCC mapping may affect reward calculations and should require review.

---

## 27. MVP Scope

Included in MVP:

* Spending categories
* MCC records
* Primary MCC-to-category mapping
* Arabic and English names
* Reward matching support
* Verification metadata
* Common exclusion metadata

Deferred:

* MCC secondary tags
* Merchant-specific MCC overrides
* Country-specific MCC mappings
* Network-specific MCC variants
* MCC version history
* Automated MCC source ingestion
* Merchant-to-MCC mapping

---

## 28. Architecture Summary

```text
spending_categories
1
│
└── many mcc_categories

cards
1
│
└── many reward_rules

reward_rules
│
├── may apply to spending_categories
└── may apply to mcc_categories
```

This design gives the Recommendation Engine a simple user-facing spending model while preserving the precision needed for future MCC-based reward calculations.
