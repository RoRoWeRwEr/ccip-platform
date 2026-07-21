# Decision Engine Specification (DES)

## Document Information

| Field | Value |
|---------|---------|
| Project | Credit Card Intelligence Platform (CCIP) |
| Version | 1.0 |
| Status | Draft |
| Owner | Rayan |

---

# Approved Decisions

## DES-001

Recommendation Ranking Method

Approved Option:

Net Value

Formula:

Rewards Value
+ Offers Value
+ Benefits Value
- Annual Fee
= Net Value

---

## DES-002

Reward Comparison Method

Approved Option:

Monetary Value

All reward programs must be converted into estimated SAR value before comparison.

---

## DES-003

Reward Valuation Model

Approved Option:

Fixed Reference Value

Each loyalty program has a reference SAR valuation.

Future versions may support multiple redemption values.

---

## DES-004

Recommendation Input Model

Approved Option:

Spending Profile Based

Users provide monthly spending patterns instead of a single transaction.

---

## DES-005

Current Cards Input

Approved Option:

Optional

Users may optionally provide currently owned cards.

---

## DES-006

User Goal Input

Approved Option:

Required

Supported Goals:

- Miles
- Cashback
- General Value
