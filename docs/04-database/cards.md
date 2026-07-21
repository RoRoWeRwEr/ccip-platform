# Card Entity

## Document Information

| Field              | Value                                    |
| ------------------ | ---------------------------------------- |
| Project            | Credit Card Intelligence Platform (CCIP) |
| Entity             | Card                                     |
| Table Name         | `cards`                                  |
| Version            | 1.0                                      |
| Status             | Draft                                    |
| Architecture Scope | Recommendation Engine MVP                |

---

## 1. Purpose

The `cards` table represents a specific issued card variant offered by a financial institution.

Each network or product variant is stored as a separate card record.

Examples:

* Al Rajhi AlFursan Visa Infinite
* Al Rajhi AlFursan Visa Signature
* SNB AlFursan Visa Infinite
* American Express Platinum Credit Card

A card record stores the identity, classification, availability, and verification information of the card.

Fees, reward rules, benefits, and offers are not stored directly inside this table.

---

## 2. Modeling Principles

### Each Variant Is a Separate Card

A separate card record must be created when there is a meaningful difference in:

* Card network
* Card level
* Fees
* Reward rules
* Benefits
* Eligibility
* Product terms

### One Primary Loyalty Program

Each card may be linked to one primary loyalty program.

Future versions may support multiple programs through a junction table such as:

`card_programs`

### Current-State Model

The MVP stores the current approved state of each card.

Historical versions are not stored during the MVP.

The fields `effective_from` and `last_verified_at` are included to support verification and future historical tracking.

---

## 3. Primary Key

`id`

Type:

`UUID`

Purpose:

Internal database identifier.

The UUID must not be used as the public URL identifier.

---

## 4. Public and Business Identifiers

Each card uses three identifiers:

| Identifier | Purpose                      | Example                           |
| ---------- | ---------------------------- | --------------------------------- |
| `id`       | Internal database identifier | UUID                              |
| `code`     | Stable business identifier   | `RJHI_ALFURSAN_VISA_INFINITE`     |
| `slug`     | Public URL identifier        | `al-rajhi-alfursan-visa-infinite` |

---

## 5. Fields

| Field                        | Type      | Required | Unique | Notes                                           |
| ---------------------------- | --------- | -------: | -----: | ----------------------------------------------- |
| `id`                         | UUID      |      Yes |    Yes | Primary key                                     |
| `code`                       | Text      |      Yes |    Yes | Stable business code                            |
| `slug`                       | Text      |      Yes |    Yes | URL-friendly public identifier                  |
| `bank_id`                    | UUID      |      Yes |     No | Foreign key to `banks.id`                       |
| `card_type_id`               | UUID      |      Yes |     No | Foreign key to `card_types.id`                  |
| `card_level_id`              | UUID      |       No |     No | Foreign key to `card_levels.id`                 |
| `card_network_id`            | UUID      |      Yes |     No | Foreign key to `card_networks.id`               |
| `primary_loyalty_program_id` | UUID      |       No |     No | Foreign key to `loyalty_programs.id`            |
| `currency_id`                | UUID      |      Yes |     No | Foreign key to `currencies.id`                  |
| `name_en`                    | Text      |      Yes |     No | Official English card name                      |
| `name_ar`                    | Text      |      Yes |     No | Official Arabic card name                       |
| `short_name_en`              | Text      |       No |     No | Short English display name                      |
| `short_name_ar`              | Text      |       No |     No | Short Arabic display name                       |
| `description_en`             | Text      |       No |     No | English summary                                 |
| `description_ar`             | Text      |       No |     No | Arabic summary                                  |
| `application_url`            | Text      |       No |     No | Official application or product URL             |
| `image_url`                  | Text      |       No |     No | Primary card image                              |
| `target_user_type`           | Text      |       No |     No | Search and display metadata only                |
| `availability_status`        | Text      |      Yes |     No | Product availability state                      |
| `is_active`                  | Boolean   |      Yes |     No | Operational status                              |
| `is_public`                  | Boolean   |      Yes |     No | Whether visible to public users                 |
| `is_recommendation_eligible` | Boolean   |      Yes |     No | Whether recommendation engine may rank the card |
| `effective_from`             | Date      |       No |     No | Date current terms became effective             |
| `last_verified_at`           | Timestamp |       No |     No | Last official data verification                 |
| `created_at`                 | Timestamp |      Yes |     No | Record creation timestamp                       |
| `updated_at`                 | Timestamp |      Yes |     No | Record update timestamp                         |

---

## 6. Relationships

### Bank

Each card belongs to one bank.

```text
banks
1
│
└── many cards
```

Foreign key:

`cards.bank_id → banks.id`

---

### Card Type

Each card belongs to one card type.

Examples:

* Credit
* Charge
* Prepaid
* Debit

Foreign key:

`cards.card_type_id → card_types.id`

---

### Card Level

A card may have one card level.

Examples:

* Infinite
* Signature
* Platinum
* World Elite

Some cards may not have a recognized level.

Foreign key:

`cards.card_level_id → card_levels.id`

---

### Card Network

Each card belongs to one network.

Examples:

* Visa
* Mastercard
* American Express
* mada

Foreign key:

`cards.card_network_id → card_networks.id`

---

### Primary Loyalty Program

A card may have one primary loyalty program.

Examples:

* AlFursan
* Mokafaa
* LAK
* Ajwaa
* Cashback

Foreign key:

`cards.primary_loyalty_program_id → loyalty_programs.id`

The relationship is optional because some cards may not have a loyalty program.

---

### Currency

Each card has one primary currency.

Foreign key:

`cards.currency_id → currencies.id`

Examples:

* SAR
* AED
* USD

---

### Future Relationships

The following relationships will be added in later database documents:

```text
cards
├── reward_rules
├── fees
├── benefits
├── offers
└── card_programs
```

---

## 7. Availability Status

Recommended MVP values:

| Value          | Meaning                            |
| -------------- | ---------------------------------- |
| `AVAILABLE`    | Open for new applications          |
| `UNAVAILABLE`  | Temporarily unavailable            |
| `DISCONTINUED` | No longer issued                   |
| `COMING_SOON`  | Announced but not yet available    |
| `UNKNOWN`      | Availability has not been verified |

The implementation should later use a database enum or validated reference values.

---

## 8. Target User Metadata

The `target_user_type` field is used only for:

* Search
* Filters
* Editorial presentation
* SEO
* Admin classification

Examples:

* `TRAVEL`
* `CASHBACK`
* `PREMIUM`
* `STUDENT`
* `BUSINESS`
* `GENERAL`

The Recommendation Engine must not use this field as the primary basis for ranking.

Recommendations must be calculated from actual reward rules, fees, user preferences, and spending data.

---

## 9. Recommendation Eligibility

A card is eligible for recommendation only when:

```text
is_active = true
AND
is_public = true
AND
is_recommendation_eligible = true
AND
availability_status = AVAILABLE
```

A card may remain visible for reference while being excluded from recommendation results.

Example:

```text
is_public = true
is_recommendation_eligible = false
availability_status = DISCONTINUED
```

This allows discontinued cards to remain searchable without being recommended.

---

## 10. Constraints

The following constraints are required:

* `id` must be unique.
* `code` must be unique.
* `slug` must be unique.
* `bank_id` must reference an existing bank.
* `card_type_id` must reference an existing card type.
* `card_level_id`, when provided, must reference an existing card level.
* `card_network_id` must reference an existing card network.
* `primary_loyalty_program_id`, when provided, must reference an existing loyalty program.
* `currency_id` must reference an existing currency.
* `name_en` must not be empty.
* `name_ar` must not be empty.
* `application_url`, when provided, must be a valid URL.
* `image_url`, when provided, must be a valid URL.
* `last_verified_at` must not be earlier than `effective_from`.
* A card must not be recommendation eligible when `is_active` is false.

---

## 11. Recommended Defaults

| Field                        | Default           |
| ---------------------------- | ----------------- |
| `availability_status`        | `UNKNOWN`         |
| `is_active`                  | `true`            |
| `is_public`                  | `false`           |
| `is_recommendation_eligible` | `false`           |
| `created_at`                 | Current timestamp |
| `updated_at`                 | Current timestamp |

New cards should not become publicly visible or recommendation eligible automatically.

They must first be reviewed and verified.

---

## 12. Example Record

```yaml
code: RJHI_ALFURSAN_VISA_INFINITE
slug: al-rajhi-alfursan-visa-infinite

bank: Al Rajhi Bank
card_type: Credit Card
card_level: Infinite
card_network: Visa
primary_loyalty_program: AlFursan
currency: SAR

name_en: Al Rajhi AlFursan Visa Infinite
name_ar: بطاقة الراجحي الفرسان فيزا إنفينيت

short_name_en: AlFursan Infinite
short_name_ar: الفرسان إنفينيت

target_user_type: TRAVEL
availability_status: AVAILABLE

is_active: true
is_public: true
is_recommendation_eligible: true

effective_from: 2026-01-01
last_verified_at: 2026-07-21
```

---

## 13. Excluded Data

The following information must not be stored directly in the `cards` table:

* Annual fees
* Foreign transaction fees
* Cash withdrawal fees
* Reward earning rates
* Reward caps
* MCC exclusions
* Offers
* Benefits
* Lounge access rules
* Insurance conditions
* Installment conditions

These belong to separate entities to prevent the card table from becoming difficult to maintain.

---

## 14. MVP Usage

For the Recommendation Engine MVP, the `cards` table provides:

* Card identity
* Bank relationship
* Product classification
* Network and level
* Primary loyalty program
* Currency
* Availability
* Public visibility
* Recommendation eligibility
* Verification status

Reward calculations will be handled by the future `reward_rules` table.
