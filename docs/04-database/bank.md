# Bank Entity

## Purpose

Represents a financial institution that issues one or more credit cards.

Examples:

- Saudi National Bank (SNB)
- Al Rajhi Bank
- Alinma Bank
- ANB
- SAIB

---

# Table Name

banks

---

# Primary Key

id (UUID)

---

# Fields

| Field | Type | Required | Notes |
|---------|---------|---------|---------|
| id | UUID | Yes | Primary Key |
| code | Text | Yes | Unique business code |
| slug | Text | Yes | URL-friendly identifier |
| country_code | Text | Yes | ISO country code |
| name_en | Text | Yes | English name |
| name_ar | Text | Yes | Arabic name |
| short_name | Text | Yes | Display name |
| website_url | Text | No | Official website |
| customer_service_phone | Text | No | Contact number |
| logo_url | Text | No | Logo image |
| is_active | Boolean | Yes | Active/Hidden |
| created_at | Timestamp | Yes | Audit |
| updated_at | Timestamp | Yes | Audit |

---

# Constraints

- code must be unique
- slug must be unique
- name_en should be unique within country
- country_code follows ISO standard

---

# Relationships

Bank

1 → Many Cards

---

# Example Record

code: SNB

slug: saudi-national-bank

country_code: SA

name_en: Saudi National Bank

name_ar: البنك الأهلي السعودي

short_name: SNB
