# Phase 10 Official-Source Launch Catalog Curation

## Purpose and safe boundary

Prepare a release-acceptance copy of a deliberately small Saudi card catalog
from official issuer sources. Research may use public product information, but
no real customer, applicant, account, transaction, bank-document, or other
personal/financial data may enter staging. The catalog must remain in protected
private staging and must not be represented as live or production-approved.

## Owner decisions required before curation

1. Catalog lead appointed: `OWNER-CATALOG-LEAD`. Independent bilingual reviewer
   appointed by role code: `INDEPENDENT-BILINGUAL-REVIEWER-01`. Personal
   information must not be committed or printed in chat.
2. Approve the initial bank/card inclusion list. The recommended option is the
   smallest useful set whose required fields can be fully verified.
3. Approve a restricted evidence location if source captures or correspondence
   cannot be committed publicly.
4. Decide whether any record below the 95% threshold is removed or explicitly
   risk-accepted. Removal is recommended.

## Allowed official sources

Accept only an issuer's official Saudi website, official current tariff/fee
schedule, official product terms, official rewards-program terms, or a dated
official issuer communication whose authenticity is independently verifiable.
Search results, aggregators, blogs, social media, generated summaries, and
undated screenshots may help discovery but cannot be the provenance authority.

## Per-card curation checklist

Complete one record per card. Use `Not stated by official source` rather than
inferring a missing fact.

| Field | Required evidence |
|---|---|
| Acceptance ID | Non-personal stable identifier for the review dataset |
| Issuer and card names | Arabic and English names exactly as supported by official sources |
| Canonical official URL | Direct product/terms URL, not a search result |
| Source type and title | Product page, fee schedule, terms, or official notice |
| Publisher | Issuing bank or official program operator |
| Retrieved at | ISO-8601 date/time and reviewer timezone |
| Source effective date | Visible effective/publication date; record `missing` if absent |
| Verification state | `verified`, `exception`, or `rejected` |
| Fees | Annual, joining, supplementary, replacement, foreign-use, cash, and other material fees; missing fields labeled |
| Eligibility | Published salary/age/residency or other conditions, without inference or guarantee |
| Rewards | Earn basis, categories, caps, minimums, exclusions, expiry, and valuation source |
| Benefits/offers | Descriptive only unless a verified valuation method exists |
| Application link | Official informational link only; forwarding remains disabled |
| Arabic/English parity | Reviewer confirms equivalent material meaning or records variance |
| Publication context | Snapshot/version, scheduled/effective window, and last verified date |
| Reviewer evidence | Independent reviewer, date, decision, and correction notes |

## Dataset scoring sheet

Use one row per published acceptance record.

| Acceptance ID | Official provenance verified (1/0) | Effective date visible (1/0) | Both gates pass (1/0) | Arabic/English reviewed | Material fee gaps | Decision | Evidence reference |
|---|---:|---:|---:|---|---|---|---|
| Pending | 0 | 0 | 0 | Pending | Pending | Pending | Pending |

Calculate:

- `coverage = 100 × sum(Both gates pass) / published acceptance records`;
- the denominator includes every record published in the acceptance dataset;
- acceptance requires coverage of at least 95%; and
- every failing record must be removed or carry a documented owner risk
  acceptance and visible user-facing exception label.

Also report results by bank and language so a high aggregate score cannot hide
a systematically weak group.

## Provenance verification procedure

1. Catalog lead records the official source and every material fact.
2. Independent reviewer opens the source directly, checks issuer ownership,
   dates, Arabic/English meaning, and the staged projection.
3. Reviewer rejects contradictions, stale terms, broken official URLs, inferred
   values, or mixed effective periods.
4. Catalog lead corrects through the controlled draft/review/publication
   workflow; never edit workflow tables directly.
5. Reviewer rechecks the published private-staging record and records the
   outcome without exposing credentials or personal identifiers.
6. Owner signs the dataset summary only after the formula and exceptions are
   independently checked.

## Acceptance criteria

- At least 95% of published acceptance records have both verified official
  provenance and a visible effective date.
- Every exception is visible, explained, and owner-risk-accepted; no missing
  value is invented.
- Arabic and English material facts are equivalent, with variances recorded.
- Fee, eligibility, rewards, exclusions, caps, assumptions, and last-verified
  context are reviewable.
- The controlled publication and correction trail identifies accountable
  actors without committing their personal identifiers.
- No application forwarding, bank integration, commission, referral, payment,
  or real-data path is enabled.

Catalog completion does not itself authorize Production or establish legal or
regulatory approval.

The current proposed, not-yet-approved research inventory is in
[Phase 10 launch-catalog candidates](PHASE_10_LAUNCH_CATALOG_CANDIDATES.md).
