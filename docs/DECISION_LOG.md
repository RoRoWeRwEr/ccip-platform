# CCIP Decision Log

This log records program-level decisions and separates verified decisions from
planning assumptions. Database design history remains in immutable migrations
and architecture documents. New decisions that change product, legal/privacy,
security, cost, or architecture boundaries require the authority defined in
`docs/AUTONOMOUS_DECISION_POLICY.md`.

## Accepted decisions

| ID | Date | Decision | Basis and consequence | Status |
|---|---|---|---|---|
| D-001 | 2026-08-03 | CCIP v1 is a bilingual Saudi credit-card information and decision-support product, not a bank, lender, credit bureau, or regulated financial adviser. | Product requirements and repository governance. No guaranteed-outcome claims; explanations and limitations are mandatory. | Accepted |
| D-002 | 2026-08-03 | Use a Next.js TypeScript modular monolith with Supabase PostgreSQL/Auth/RLS; Vercel is the preferred web host. | Lowest operational complexity for the existing repository. A separate service/search/ML runtime requires an ADR and evidence. | Accepted |
| D-003 | 2026-08-03 | Preserve anonymous public catalog usefulness; authenticate only user-owned and administrative features. | BRD, product requirements, and implemented RLS model. | Accepted |
| D-004 | 2026-08-03 | Catalog facts use official sources and publication-governed snapshots; missing or uncertain data is never invented. | Product trust objective and migrations `0046`–`0051`. | Accepted |
| D-005 | 2026-08-03 | Recommendations are deterministic and explainable; v1 net value is annual reward value minus annual fee. Offers/benefits are not monetized without a verified method. | Product requirements and Decision Engine Specification. | Accepted |
| D-006 | 2026-08-03 | Routine validated delivery is direct to `main`; merged migrations are immutable and any database delivery contains one cohesive migration. | `AGENTS.md` and `docs/DEVELOPMENT_WORKFLOW.md`. | Accepted |
| D-007 | 2026-08-09 | Progress is reported as completed roadmap milestones: 27/30 = 90%. WIP and blocked milestones do not count. | P9.1 is countable after `ace16b3` passed required CI and `420a886` reconciled the live ledger. | Accepted for governance reporting |
| D-008 | 2026-08-03 | The existing P3.4 execution task owned and delivered the previously dirty worktree. | Prevented duplicate work; `1c269bf` superseded the audit's earlier WIP snapshot. | Completed coordination decision |
| D-009 | 2026-08-12 | Approve Vercel and Supabase for a private, non-production staging environment using synthetic/test data only. | Authorizes P9.2 technical validation after provisioning. It is not production approval and makes no claim of Saudi legal or regulatory compliance; production launch remains conditional on qualified Saudi legal/privacy review. | Accepted for staging only |
| D-010 | 2026-08-14 | Preserve a regulatory hold on production and regulated-adjacent capabilities while treating current findings as AI-generated risk analysis. | Production, real personal/financial data, application forwarding, bank-document collection, commissions, paid referrals, and bank integrations remain prohibited until applicable legal, privacy, contractual, and SAMA requirements are formally resolved. | Accepted risk boundary |

## Planning assumptions

| ID | Assumption | Validation trigger |
|---|---|---|
| A-001 | The three remaining milestones can be forecast only after owner-controlled staging inputs are complete. | Reforecast after the first successful staging deployment. |
| A-002 | Existing schema supports v1 unless implementation reveals a concrete gap. | Each milestone's design/test work; any gap uses a narrow forward migration. |
| A-003 | Owner will provision the approved private staging accounts, scoped credentials/environment values, and verified administrator identity needed for P9.2/P9.3. | Validate against the checklist in `docs/EXECUTION_STATUS.md`. |
| A-004 | A curated launch catalog is preferable to broad but weakly sourced coverage. | Owner decision and catalog readiness assessment before Phase 10 completion. |
| A-005 | Public-value targets can be measured in staging with moderated research and acceptance fixtures. | Approve and execute the research method/sample before Phase 10 completion. |

Assumptions are not verified facts and must not be used as completion evidence.

## Batched owner decisions

| ID | Decision needed | Recommended option | Tradeoff / consequence | Needed by |
|---|---|---|---|---|
| O-001 | Launch catalog breadth | Curated set with complete official provenance | Smaller initial catalog; materially stronger trust and testability | Before Phase 10 completion |
| O-002 | v1 research sample | Minimum 10 moderated participants: at least 5 primarily Arabic and 5 English, mixed experience | Directional rather than statistically representative; feasible for v1 | Before Phase 10 completion |
| O-003 | Saudi legal/privacy assessment | Complete before production launch approval | Adds cost/time; reduces PDPL, disclosure, consent, and advice-boundary risk | Before production launch |
| O-004 | Private technical-validation staging provider | Vercel + Supabase with synthetic/test data only | Enables P9.2 without selecting or approving production hosting, data region, or compliance posture | Resolved by D-009 |
| O-005 | v1 monetization | No ads, referrals, or paid placement in v1 until conflict/labeling/ranking controls are approved | Delays revenue; protects trust and recommendation independence | Before monetized content enters scope |

## Regulatory assessment record — 2026-08-14

This record is an AI-generated risk analysis based on the repository and the
official sources linked below. It is not legal advice, a definitive perimeter
classification, a SAMA determination, or regulatory approval.

### Approved synthetic staging

- Private, non-production staging on Vercel and Supabase is owner-approved for
  technical validation with synthetic/test data only.
- Frankfurt Supabase and Dubai Vercel are technical staging candidates only.
  Neither location is approved here as a lawful production region or transfer
  mechanism.

### Prohibited production capabilities

Until their applicable legal, privacy, contractual, and SAMA requirements are
formally resolved, do not enable production, real personal or financial data,
application forwarding, bank-document collection, commissions, paid referrals,
or bank integrations. Do not represent staging, provider selection, or this
assessment as SAMA, PDPL, legal, privacy, or production approval.

### Verified regulatory facts

- SAMA's in-force
  [Instructions for Practicing Aggregation Activity](https://rulebook.sama.gov.sa/en/instructions-practicing-aggregation-activity)
  define a platform to include websites and applications, apply to SAMA-
  licensed aggregation entities, and state that aggregation activity may not
  be carried out without a SAMA licence under the applicable licensing rules.
  The instructions contemplate exchanging information with financiers and
  receiving and processing finance offers and applications. They also require
  conflict controls and disclosure of fees and commissions.
- SAMA's in-force
  [Regulatory Sandbox FAQ](https://rulebook.sama.gov.sa/en/regulatory-sandbox-faq)
  states that the Sandbox is for models not regulated or covered by existing
  rules and that applications are not accepted where an existing licensing
  path exists. Before SAMA permission, testing with banks or financial
  institutions is limited to development environments with dummy data; live
  data and production testing are not permitted.
- SDAIA's official
  [PDPL knowledge center](https://dgp.sdaia.gov.sa/wps/portal/pdp/knowledgecenter)
  identifies controller and processor roles, purpose-linked retention, the
  PDPL Implementing Regulations, and a separate regulation and risk-assessment
  guidance for transfers outside the Kingdom.

### Assessment hypotheses

- The planned application-forwarding plus cost-per-acquisition model presents
  a **material SAMA finance-aggregation licensing risk** because its intended
  functions overlap several activities described in SAMA's aggregation
  instructions. This is a risk inference, not a legal classification.
- Sandbox eligibility is unresolved. If SAMA determines that the model has an
  existing aggregation-licensing route, the FAQ indicates that it may be
  ineligible; only SAMA or qualified Saudi counsel can resolve that question.
- Paid ranking, referrals, commissions, or CPA incentives could create actual
  or perceived conflicts with neutral recommendations and SAMA's aggregation
  conflict and non-preference expectations.
- Using Frankfurt Supabase or Dubai Vercel with real data could constitute a
  cross-border transfer requiring a valid PDPL basis and safeguards. Their use
  for synthetic staging does not establish production legality.

### Questions requiring qualified counsel or SAMA

1. Does CCIP's planned forwarding of applications, collection of bank
   documents, or bank integration constitute regulated aggregation or another
   finance-support activity, and what licence/approval/contract is required?
2. Does a CPA, commission, paid-referral, or paid-ranking model change that
   perimeter or conflict analysis?
3. Is any CCIP model eligible for the SAMA Sandbox despite the existing
   aggregation licensing route, and what written SAMA confirmation is needed?
4. For every planned processing purpose, who is controller or processor, what
   PDPL lawful basis applies, which data is sensitive, what consent is needed,
   and what retention period is lawful and necessary?
5. What transfer mechanism, risk assessment, contractual safeguards, and
   production region are permitted for personal or financial data outside the
   Kingdom?
6. What SAMA, bank, and data-sharing contracts or approvals are required before
   any production integration or exchange of customer/application data?

## Current decision boundary

Routine repository work through P9.1 is complete. D-009 resolves the staging-
provider and permitted-data decision. P9.2 still cannot proceed until the owner
provisions the external staging accounts, scoped credentials/environment
values, and staging administrator identity. Production hosting/region and
legal/privacy approval remain unresolved production gates.
`docs/EXECUTION_STATUS.md` contains the exact resume checklist.
