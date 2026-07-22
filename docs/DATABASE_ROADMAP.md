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
- `0043` onward: **not started.** See "Prerequisites before 0043
  begins" below.

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
| 0044 | `api_management` | Too broad as stated — could mean partner API keys (fits `0039`'s bank-partnership model), rate limiting, or webhook management for `0039`'s commission/settlement flows. Narrow the scope before writing SQL. |
| 0045 | `background_jobs` | Reasonable, and there's already real demand for it: `data_retention_executions` (`0040`) and `commission_settlements` (`0039`) both look like they're meant to be driven by a scheduler, but nothing currently models a job/worker table. Scope this migration to explicitly serve those two consumers first, not built in the abstract. |
| 0046 | `data_warehouse_views` | Premature — there is no application layer generating real query patterns yet. Defer until there's production traffic, or narrow to materialized views over `recommendation_*`/`bank_application_*` specifically. |
| 0047 | `analytics_and_reporting` | Depends on `0046`; same premature-maturity concern. Note: the `REPORTING_VIEWER` role and `REPORTING_READ` permission already exist in `0042`'s seed data with nothing to gate yet — this is what would finally give that role a purpose. Sequence it here, not earlier. |
| 0048 | `ml_feature_store` | Speculative at the current product stage. `recommendation_models`/`recommendation_model_factors` (`0028`) already model a rules/scoring-based approach, not ML — building a feature store ahead of an actual ML use case invents a dependency nothing currently needs. Defer past `0050` until a concrete ML use case exists. |
| 0049 | `search_and_indexing` | Validate actual query volume/patterns before building backend search infrastructure — the catalog tables (`0004`–`0021`) are on the order of tens to low hundreds of rows per entity type at this product stage, which is well within client-side search territory. |
| 0050 | `platform_finalization` | Not a bounded migration — "finalization" is a milestone label, not a cohesive capability, and contradicts the repository's own rule against combining unrelated capabilities into one migration. Replace with whatever specific hardening tasks remain once `0043`–`0049` (revised) land — likely index tuning, `FORCE ROW LEVEL SECURITY` reconsideration, and connection/role-limit configuration — tracked as their own scoped items, not one catch-all migration. |

## Recommended sequencing

1. `0043` (`feature_flags`) as originally scoped.
2. Narrow `0044` (`api_management`) to a specific consumer before
   building it.
3. `0045` (`background_jobs`), explicitly targeting `data_retention_
   executions` and `commission_settlements` as its first real
   consumers.
4. Hold `0046`–`0049` behind the first real application-layer release.
   Building warehouse, analytics, ML, and search infrastructure against
   a database with no production traffic spends migration-review
   bandwidth on problems that don't exist yet, at the cost of bandwidth
   that scoped-authorization design and CI/test coverage (see
   `docs/SECURITY_MODEL.md`) need first.
5. Drop `0050` as currently framed; replace with specifically scoped
   hardening migrations once there's something concrete to harden.

## Prerequisites before 0043 begins

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
