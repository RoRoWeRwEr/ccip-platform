# Database Roadmap

This reflects the state of the migration sequence as of this writing
and a validation of the originally proposed `0043`–`0050` sequence
against what has actually been built. Nothing in this document is a
commitment to build any of it on any timeline — it is a starting point
for the next planning decision, not a backlog.

## Current status

- `0001`–`0042`: merged into `main`. `0042`
  (`create_user_profiles_and_platform_roles`) merged via PR #2.
  Originally drafted with `PLATFORM`/`COUNTRY`/`BANK`/
  `FUNCTIONAL_AREA` scope values on `user_platform_role_assignments`,
  but the authorization functions (`has_active_platform_role`,
  `has_active_platform_permission`) only ever evaluated `PLATFORM`
  scope — meaning a `COUNTRY`/`BANK`/`FUNCTIONAL_AREA`-scoped
  assignment was accepted by the schema but silently granted nothing.
  This was corrected before merge: the migration enforces `PLATFORM`
  scope only at the constraint level (`chk_user_platform_role_assignments_
  scope`), and the removed scope values are explicitly deferred to a
  future migration rather than left half-modeled.
- `0043` (`create_feature_flags`): **merged into `main` via PR #4**. Its scope is intentionally limited
  to PLATFORM-wide flag definitions and evaluation, using the existing
  `PLATFORM_ADMINISTRATOR` role for management. It does not introduce
  bank, country, tenant, customer, organization, or functional-area
  targeting.
- `0044` (`create_api_management`): **merged through PR #12.** Its
  scope is limited to API clients, hashed-key lifecycle metadata,
  scopes, and rate-limit assignments.
- `0045` (`create_background_jobs`): **merged into `main` via PR #14.**
  Its bounded scope is durable PostgreSQL scheduling, execution,
  retry, leasing, heartbeat, cancellation, result, and failure metadata
  for retention executions and commission settlements.
- `0046` (`create_catalog_source_provenance`): **merged.** Adds one
  table, `catalog_source_provenance`, recording where catalog evidence
  came from (official bank/product/terms/fee/rewards/loyalty/regulatory
  sources or approved manual entry) for exactly one of `banks`, `cards`,
  `card_fees`, `card_benefits`, `reward_rules`, `loyalty_programs`, or
  `card_eligibility_requirements`, with lifecycle and verification state
  machines, deduplication, and `CATALOG_MANAGE`-gated RLS. This departs
  from the originally proposed `0046` (`data_warehouse_views`, see
  below) at explicit task direction; that proposal remains deferred and
  unscheduled. It is a foundation for future catalog publication
  governance and deliberately does not implement publication approval,
  ingestion, or content storage.
- `0047` (`create_merchants`): **merged.** Adds six tables — `merchants`
  (canonical merchant identity: bilingual display and optional bilingual
  legal names, classification, channel type, headquarters country,
  lifecycle and verification state machines, supersession/consolidation),
  `merchant_aliases` (alternate names/spellings, globally unique while
  active), `merchant_relationships` (typed PARENT_SUBSIDIARY/BRAND_OF/
  CHAIN_MEMBER_OF edges, cycle-rejecting), `merchant_category_assignments`
  (reuses the existing `merchant_categories` table from `0004` rather than
  duplicating it), `merchant_market_presence` (reuses `countries`), and
  `merchant_domains` (official websites/app links/storefronts, globally
  unique while active). Extends `catalog_source_provenance` (`0046`)
  forward-compatibly via `ALTER TABLE` only — adding a `merchant_id`
  column, widening its `target_entity_type`/`target_match` CHECK
  constraints, and converting `target_entity_id` from a generated column
  to a trigger-maintained one — without editing the immutable `0046`
  migration file. `CATALOG_MANAGE`-gated RLS (with public read of active
  merchants, matching the existing catalog-read pattern), `audit_events`
  integration. Does not implement offers, publication governance,
  scraping, transaction ingestion, or automated/fuzzy merchant matching.
- `0048` (`create_catalog_publication_governance`): **merged.** Adds typed
  catalog content versions, publication requests linked to `0040`'s generic
  approval engine, ordered reviewer/final-approver decisions with requester
  separation, scheduled/effective publication windows, exclusion-backed
  overlap prevention, controlled transitions, append-only publication events,
  central audit integration, and atomic rollback/supersession lineage. It uses
  the existing platform-wide `CATALOG_MANAGE` permission and intentionally
  does not implement resource-scoped catalog administration.
- `0049` (`create_catalog_admin_authorization`): **merged.** Adds explicit,
  audited GLOBAL/BANK scope assignments linked to existing
  `CATALOG_ADMINISTRATOR` role assignments; scope-aware target helpers; and
  scoped RLS/workflow enforcement across provenance (`0046`), merchants
  (`0047`), and publication governance (`0048`). PLATFORM_ADMINISTRATOR remains
  explicitly global, legacy unscoped catalog assignments fail closed, assigned
  reviewers/final approvers must hold matching scope, and no write access is
  added to earlier core catalog tables.
- `0050` (`create_published_card_detail_interface`): **authorized during P3.3
  and merged.** Application implementation proved that anonymous reads could
  not safely combine publication snapshots, reward rules, eligibility,
  provenance, and related merchant data without privileged credentials. The
  migration adds one read-only, allowlisted function over currently effective
  `PUBLISHED` snapshots. It adds no table, write grant, or unrelated feature.
- `0051` (`create_published_card_search_interface`): **authorized during P3.4.**
  Correct reward filtering before pagination could not use the direct anonymous
  RLS surface or `0050`'s single-card function. This migration adds one bounded,
  allowlisted list/search function and a partial publication lookup index. It
  exposes only effective published card, bank, and independently published
  reward snapshots and adds no table or write grant.
- `0052` (`create_published_recommendation_candidates`): **autonomously
  authorized during P5.2.** The existing public read boundaries did not expose
  the approved `is_recommendation_eligible` gate. It adds a fail-closed core
  flag and one bounded, execute-only candidate function requiring both the
  core flag and an explicit true value in the effective published snapshot.
  It adds no table, blanket read grant, write interface, or unrelated feature.
- **The current Database Phase roadmap is complete through `0052`.** No
  migration after `0052` is approved or scheduled by this roadmap.

## Why scoped authorization was deferred, not half-built

A resource-scoped authorization model (e.g. "this user is an
`OPERATIONS_ANALYST` for Bank X only") needs, at minimum: a decision
on what the scoping resource actually is (a `banks.id`? a country
code? something else?), whether scopes nest or inherit, how a
`SECURITY DEFINER` permission check evaluates a scoped grant
efficiently without an unbounded join, and how RLS policies on
scope-relevant tables (e.g. `bank_applications`) would actually consume
that scope. None of that was designed in `0042` — only three enum-like
string values existed, unused by anything. Shipping unused columns
that imply a capability which doesn't work is worse than not shipping
them: it invites an administrator to scope a grant and get a false
sense of restriction. When scoped authorization is actually needed, it
should be its own migration, designed against a concrete use case (the
first candidate is very likely `CATALOG_ADMINISTRATOR` scoped to a
single bank, given how much of `0005`–`0021` is bank-rooted), not
retrofitted onto the current placeholder columns.

## Validation of the proposed 0043–0050 sequence

The original proposed sequence (`feature_flags`, `api_management`,
`background_jobs`, `data_warehouse_views`, `analytics_and_reporting`,
`ml_feature_store`, `search_and_indexing`, `platform_finalization`) has
no grounding in any file in this repository — `docs/09-roadmap/`
contains only a placeholder. Validated against what's actually built:

| # | Proposed | Assessment |
|---|---|---|
| 0043 | `feature_flags` | No dependency conflicts with anything merged or pending. Reasonable to build as scoped. |
| 0044 | `api_management` | Narrowed and approved by Issue #11: client/key lifecycle, scopes, and rate-limit metadata only; webhooks and gateway behavior are excluded. |
| 0045 | `background_jobs` | Reasonable, and there's already real demand for it: `data_retention_executions` (`0040`) and `commission_settlements` (`0039`) both look like they're meant to be driven by a scheduler, but nothing currently models a job/worker table. Scope this migration to explicitly serve those two consumers first, not built in the abstract. |
| 0046 | `data_warehouse_views` | Premature — there is no application layer generating real query patterns yet. Defer until there's production traffic, or narrow to materialized views over `recommendation_*`/`bank_application_*` specifically. **Superseded in practice:** the actual `0046` delivered was `create_catalog_source_provenance`, a bounded, explicitly directed capability unrelated to warehousing. `data_warehouse_views` remains unbuilt and unscheduled; renumber it into a future slot if it is still wanted. |
| 0047 | `analytics_and_reporting` | Depends on `0046`; same premature-maturity concern. Note: the `REPORTING_VIEWER` role and `REPORTING_READ` permission already exist in `0042`'s seed data with nothing to gate yet — this is what would finally give that role a purpose. Sequence it here, not earlier. **Superseded in practice:** the actual `0047` delivered was `create_merchants`, a bounded canonical-merchant-identity foundation, at explicit task direction; `analytics_and_reporting` remains unbuilt and unscheduled — renumber it into a future slot if it is still wanted. |
| 0048 | `ml_feature_store` | Speculative at the current product stage. `recommendation_models`/`recommendation_model_factors` (`0028`) already model a rules/scoring-based approach, not ML. **Superseded in practice:** the actual `0048` delivered catalog publication governance; an ML feature store remains unbuilt and unscheduled. |
| 0049 | `search_and_indexing` | Search infrastructure was premature without production query volume. **Superseded in practice:** the actual `0049` delivered scoped catalog-administrator authorization and completed this roadmap; search remains unbuilt and unscheduled. |
| 0050 | `platform_finalization` | The catch-all proposal remained rejected. The number was instead used, after an explicit P3.3 application-proven decision, for the bounded `create_published_card_detail_interface` migration. |

## Completed sequencing

1. `0043`–`0045` delivered feature flags, API management, and background
   jobs as bounded capabilities.
2. `0046`–`0048` delivered source provenance, canonical merchants, and
   publication governance under an interim platform-wide catalog gate.
3. `0049` replaced that interim gate with the approved explicit GLOBAL/BANK
   authorization model.
4. `0050` closed the P3.3 read-boundary gap with a snapshot-based, read-only
   published card-detail function.
5. `0051` closed the P3.4 result-set reward-filter gap with a snapshot-based,
   read-only list/search function and completed the revised Database Phase.
6. Warehouse, analytics, ML, and catch-all "platform finalization"
   remain explicitly deferred and unscheduled. Any future database work needs
   a new bounded roadmap decision based on application-layer demand.

## Established prerequisites for every future migration

- `0042` reviewed, tested, and merged — **done** (PR #2). CI
  (`.github/workflows/database-ci.yml`) now runs the full migration
  sequence and pgTAP suite against the real `supabase/postgres` image
  on every PR touching `supabase/migrations/**` or
  `supabase/tests/**`, and on every push to `main` touching
  `supabase/migrations/**`.
- The `supabase/tests/database/` convention established in `0042`'s
  remediation should extend as the default going forward — every
  migration from `0043` onward should ship with tests in the same PR,
  not retrofitted later the way RLS had to be retrofitted in `0041`.
