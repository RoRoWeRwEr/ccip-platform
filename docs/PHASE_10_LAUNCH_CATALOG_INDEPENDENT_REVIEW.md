# Phase 10 Launch-Catalog Independent Review Workbook

**Prepared:** 2026-08-18

**Catalog lead:** `OWNER-CATALOG-LEAD`

**Reviewer role:** `INDEPENDENT-BILINGUAL-REVIEWER-01`

**Environment:** protected private staging; public official-source facts only

**Workflow ceiling:** `DRAFT` only; do not submit, approve, schedule, or publish

This workbook is the exact review contract for the owner-approved 12-card
candidate list in `PHASE_10_LAUNCH_CATALOG_CANDIDATES.md`. It contains no
personal information. Reviewer identity, credentials, communications, and
private evidence remain outside the repository. Completing this workbook does
not itself close the catalog gate or Phase 10.

## Staging-preparation result

The authenticated protected-staging administrator interface was inspected on
2026-08-18. Provenance and publication draft forms require an existing catalog
target. Only the P9.3 synthetic banks/cards were offered; none of the approved
Al Rajhi, Riyad Bank, or SNB targets exists. No draft was created because
attaching official facts to a synthetic target would falsify provenance.

Before staging drafts can be created, a controlled operator must create the
three issuer and twelve card target rows through an existing schema-authorized
path, using no personal data and without publication. The current application
UI does not expose that operation. This is a staging-preparation dependency,
not permission to bypass RLS, use a service-role key in the browser, mutate
workflow tables directly, or add a speculative migration.

## Reviewer operating procedure

For each card, the reviewer must perform every step in order:

1. Open the Arabic and English product URLs directly from the official issuer
   domain. Record access as `PASS`, `INACCESSIBLE`, or `REDIRECTED`, including
   UTC time and final official URL.
2. Confirm that the issuer currently lists the card as offered. An application
   button alone is not proof if the page says issuance is stopped.
3. Copy only short factual field values into the review record; do not archive
   or reproduce pages, images, trademarks, or long terms text.
4. Verify the exact Arabic and English names. Record issuer wording rather
   than translating or normalizing it silently.
5. Open the current official fee schedule and terms. Verify visible
   effective/publication dates; retrieval date, URL year, and search metadata
   do not qualify.
6. Verify issuance, annual, supplementary, replacement, foreign-transaction,
   cash/transfer, late/reactivation, dispute, monthly-rate, APR, minimum-payment,
   and VAT facts. Mark every absent field `NOT_STATED`.
7. Verify eligibility only as the issuer states it: account relationship, age,
   segment, salary, residency/identity documents, SIMAH/credit assessment, and
   loyalty-membership dependency. Never imply eligibility or approval.
8. Verify rewards: unit, earn rate, local/international/category treatment,
   thresholds, caps, minimums, exclusions, expiry, reversal behavior, and
   valuation source. Mark promotions with start/end dates.
9. Verify benefits and limitations: lounge visits/guests, insurance,
   protection, instalments, concierge, discounts, network conditions, and any
   enrollment/spend requirement. Do not assign monetary value.
10. Compare Arabic and English material meaning field by field. Record
    `MATCH`, `MATERIAL_VARIANCE`, or `MISSING_LANGUAGE`.
11. Recalculate provenance/date scoring. A record passes the combined gate
    only when an official source and exact visible effective date both pass.
12. Record one decision: `REVIEW_PASS`, `REVIEW_EXCEPTION`, or `REJECT`.
    Include only the reviewer role code, review date, redacted evidence
    reference, and remediation. Do not enter a personal name.
13. After the target exists, compare the intended draft snapshot with this
    reviewed record before any staging write. Keep workflow state `DRAFT`.
14. Stop and notify `OWNER-CATALOG-LEAD` if any fact is conflicting,
    inaccessible, materially different between languages, unsupported, or
    below the date gate. Never resolve it by inference.

## Per-card review matrix

Every cell begins `PENDING`. The independent reviewer—not the catalog lead—must
replace it with observed evidence.

| ID | Current offer | AR source/name | EN source/name | Exact date | Fees/APR/VAT | Eligibility | Rewards/caps/exclusions | Benefits/limits | Bilingual parity | Combined gate | Reviewer decision |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ARB-01 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| ARB-02 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| ARB-03 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| ARB-04 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| RB-01 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| RB-02 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| RB-03 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| RB-04 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| SNB-01 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| SNB-02 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| SNB-03 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |
| SNB-04 | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING | PENDING |

## Required exception resolution

The reviewer must explicitly resolve or reject these known issues:

| ID(s) | Required resolution |
|---|---|
| ARB-01–03 | Locate the permanent annual fee after the temporary 2026-07-01–2026-09-30 waiver, or retain `NOT_STATED`; verify VAT and promotion eligibility. |
| ARB-02 | Confirm Arabic/English SELECTIVE name and whether any gender/segment condition is an eligibility rule or marketing position. |
| ARB-04 | Confirm English/Arabic fee parity, VAT treatment, full-monthly-settlement wording, and exclusion of the stopped Qسط variant. |
| RB-01 | Verify that activation/spend bonuses remain available and reconcile the Arabic/English lounge count. |
| RB-02 | Locate an exact current pricing effective date and validate the 2025-09-29 rewards change against the live product. |
| RB-03 | Resolve 12 lounge visits versus “unlimited”/guest wording and confirm the exact applicable network benefit. |
| RB-04 | Locate an exact terms/pricing effective date and activation-mile campaign duration; verify AlFursan membership conditions. |
| SNB-01–04 | Obtain an official document whose body displays an exact effective date; a `2026` URL filename is insufficient. |
| SNB-01 | Reconcile age, salary-band pricing, APR, and Arabic/English eligibility wording. |
| SNB-02 | Resolve whether cash advance is included in “purchase value” while cash withdrawal is excluded from eligible cashback. |
| SNB-03 | Confirm that “unlimited” cashback remains bounded by card limit, category rules, exclusions, and the current fee schedule. |
| SNB-04 | Confirm current AlFursan membership, mile-crediting, lounge, insurance, and exclusion terms. |

## Draft-entry checklist after target creation

For each approved target, a staging operator and the reviewer must verify:

- [ ] Environment banner/URL is the protected private Preview, never Production.
- [ ] Target issuer/card ID and bilingual names match the reviewed record.
- [ ] Source owner, title, official URL, retrieval date, effective date, and
  verification state match official evidence.
- [ ] Missing facts are explicitly `NOT_STATED`; conflicts are not normalized.
- [ ] Snapshot contains only supported public product facts and no copied page,
  application data, customer data, credentials, or personal identifiers.
- [ ] Change summary begins `P10 acceptance DRAFT` and names only the stable
  acceptance ID.
- [ ] Workflow state is observed as `DRAFT` after creation.
- [ ] Reviewer/final-approver fields remain empty.
- [ ] No Submit, Record decision, Publish, Schedule, Rollback, or assignment
  action is executed.
- [ ] Redacted evidence records target/version ID, timestamp, `DRAFT` state,
  operator role code, reviewer state, and exceptions without identifiers.

## Stop conditions

Stop immediately before any submission, approval, scheduling, or publication;
if the target selector is wrong; if Production appears; if a privileged key or
personal identifier would be exposed; if a source is not official; or if the
snapshot contains unsupported facts. The safe recovery is to leave the record
absent or `DRAFT` and report the blocker—never weaken controls.
