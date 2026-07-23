# Database Architecture

This describes the actual, current state of `supabase/migrations/` —
merged through `0044`. It is derived directly from reading
every migration file and from live-executing the full migration sequence
against PostgreSQL 16 (and, since `0042` merged, against a real
Supabase local stack via Database CI); it is not aspirational.
See `docs/MIGRATION_INDEX.md` for the file-by-file inventory and
`docs/SECURITY_MODEL.md` for the security-specific detail.

## Ground rules this schema follows

- **Single schema.** Every object lives in `public`. There is no
  schema separation between catalog, customer, recommendation, or
  governance data. This is a defensible simplification for a
  single-bounded system and for Supabase's PostgREST exposure model,
  but it is not written down anywhere as a decision — see the note in
  `docs/DATABASE_ROADMAP.md` about resolving this before analytics/
  warehouse work (`0046`+) makes it more expensive to change.
- **Two extensions:** `pgcrypto` (native UUID generation via
  `gen_random_uuid()`) and `btree_gist` (required for the `EXCLUDE
  USING gist` time-range-overlap constraints used throughout the
  recommendation and RBAC tables), both enabled in `0001`.
- **Naming conventions:** `CHECK` constraints use a `chk_` prefix (over
  1,600 across `0001`–`0042`), `UNIQUE` constraints use `uq_` (over
  100), `EXCLUDE` constraints use `ex_` (2, both in `0042`), indexes
  use `idx_`. Foreign keys do **not** use an explicit prefix —
  they rely on PostgreSQL's default `<table>_<column>_fkey` naming.
  This is a real inconsistency worth being deliberate about (pick one
  and follow it) but not a defect.
- **Timestamps:** every table has `created_at`/`updated_at` maintained
  by the shared `public.set_updated_at()` trigger function (defined in
  `0003`, `SECURITY INVOKER`, pinned `search_path`). Lifecycle
  "soft delete" is inconsistent: most tables use an `is_active BOOLEAN`
  visibility flag (25+ tables); a minority (`user_saved_cards`,
  `card_comparisons`, `bank_applications`) use an actual
  `deleted_at TIMESTAMPTZ`. These are semantically different
  (`is_active` toggles catalog visibility; `deleted_at` marks
  user-initiated removal) — pick the one that matches the table's
  actual semantics, don't default to whichever is more familiar.
- **No destructive operations exist anywhere in the migration history**
  — no `DROP TABLE`, `DROP COLUMN`, or `TRUNCATE` in any of the 42
  migration files. Keep it that way; corrective migrations add or
  constrain, they don't erase history.

## Schema layout by capability

```
Foundational
  0001 extensions → 0002 enums → 0003 set_updated_at() → 0004 reference tables
  (countries, currencies, merchant_categories, reward_categories,
   card_networks, loyalty_programs)

Catalog (public read via 0041's catalog_read_* policies)
  0005 banks/programs → 0006 cards → 0007–0021
  (fees, benefits, reward rules/targets/exclusions/redemption rates,
   eligibility requirements, offers, insurance/lounge/travel/dining/
   installment/network benefits, comparison profiles)
  — all FK-rooted in banks → cards.

Decision / recommendation engine (the platform's core differentiator
per docs/PROJECT_CONTEXT.md)
  0022 decision enums → 0023 customer_financial_profiles
    → 0024 spending profiles/categories → 0025 preferences
    → 0026 eligibility assessments → 0027 value simulations
    → 0028 recommendation_models (+ factors, segments)
    → 0029 recommendation_runs (+ run_cards)
    → 0030–0034 results, explanations, factor_scores,
      interactions/feedback, outcomes
  — all rooted in customer_financial_profiles → recommendation_runs.

Customer-facing utility
  0035 saved cards (user_card_collections, user_saved_cards)
  0036 card comparisons (comparisons, items, criteria, item_scores)
  0037 notifications/alerts (templates, preferences, subscriptions,
       alert_events, notifications, deliveries)

Bank integration & monetization
  0038 bank_applications (+ documents, events, tasks, decisions,
       integrations)
  0039 bank partnerships & referrals (partnerships, partner_products,
       referral_links/attributions, commission rules/accruals/
       settlements/settlement_items)

Governance, audit, compliance
  0040 governance_controls (+ assessments), audit_events,
       approval_requests/decisions, consent_records,
       data_classification_rules, data_retention_policies/executions,
       legal_holds/items, data_access_logs, data_export_requests,
       compliance_cases/events
  — the append-oriented audit_events table here is the sink every
    later audit trigger (including 0042's) writes to.

Security retrofit (no new tables)
  0041 — enables RLS on all 85 prior tables in one migration, revokes
  blanket anon/authenticated schema access, grants back narrowly by
  policy. See docs/SECURITY_MODEL.md for the full model.

Identity & platform RBAC (0042 — merged via PR #2)
  user_profiles, platform_roles, platform_permissions,
  platform_role_permissions, user_platform_role_assignments
  — PLATFORM-scoped only as of the current revision; see
    docs/DATABASE_ROADMAP.md for why resource-scoped authorization
    (originally drafted as COUNTRY/BANK/FUNCTIONAL_AREA) was removed
    rather than half-implemented.

Platform feature flags (0043 — merged via PR #4)
  feature_flags — PLATFORM-wide definitions with lifecycle and schedule
  controls, optional deterministic percentage rollout, administrator-only
  RLS management, boolean-only runtime evaluation, and audit_events
  integration. No resource or customer targeting is represented.

API management (0044 — merged via PR #12)
  API clients, hashed API-key lifecycle metadata, scopes, scope
  assignments, and rate-limit policy assignments. Plaintext API
  secrets, webhooks, and gateway execution remain outside PostgreSQL.

Background jobs (0045 — in development under Issue #13)
  job definitions, one-time/interval schedules, and durable executions
  for data_retention_executions and commission_settlements, with
  service-role-only enqueueing and worker lifecycle functions, atomic
  SKIP LOCKED leasing, fencing tokens, heartbeats, retries,
  cancellation, result/failure metadata, audit events, and
  administrator-readable RLS.
```

## The RLS and authorization model

Two distinct, layered authorization mechanisms exist, and it matters
which one governs a given table:

1. **Customer self-service isolation** (established in `0041`,
   extended by `0042`'s `user_profiles`): a table with a `user_id`
   column, or one reachable from such a table via `EXISTS` joins, is
   gated by `user_id = (SELECT auth.uid())` — directly or transitively.
   Examples: `customer_financial_profiles` directly; `customer_
   spending_categories` transitively, through two joins back to
   `customer_financial_profiles`. This is how a customer sees only
   their own data, with no role or permission system involved at all.

2. **Platform administration** (`0042`, merged via PR #2): a small,
   internal RBAC layer — `platform_roles` → `platform_permissions` via
   `platform_role_permissions`, assigned to Supabase auth users via
   `user_platform_role_assignments`. Two `SECURITY DEFINER` functions,
   `has_active_platform_role(code)` and `has_active_platform_permission
   (code)`, are the only way policies check this layer (avoiding RLS
   self-recursion on `user_platform_role_assignments`). As of the
   current revision, this system is **PLATFORM-scoped only** — there is
   no per-bank, per-country, or per-functional-area restriction. Do
   not build application logic that assumes scoped administration
   exists; it does not yet, by design (see
   `docs/DATABASE_ROADMAP.md`).

Six seeded roles exist: `PLATFORM_ADMINISTRATOR`, `CATALOG_
ADMINISTRATOR`, `COMPLIANCE_REVIEWER`, `OPERATIONS_ANALYST`,
`SUPPORT_OPERATOR`, `REPORTING_VIEWER`, each mapped to exactly one of
six seeded permissions (`IDENTITY_ACCESS_MANAGE`, `CATALOG_MANAGE`,
`COMPLIANCE_REVIEW`, `OPERATIONS_MANAGE`, `SUPPORT_READ`, `REPORTING_
READ`). No user holds any of these roles by default — see
`docs/BOOTSTRAP_PLATFORM_ADMIN.md` for how the first administrator is
assigned.

## The audit trail

`audit_events` (`0040`) is the single append-oriented sink for
administrative and authorization changes. `0042`'s `audit_platform_
authorization_change()` trigger (`SECURITY DEFINER`, pinned
`search_path`) writes to it on every INSERT/UPDATE/DELETE against
`platform_roles`, `platform_permissions`, `platform_role_permissions`,
and `user_platform_role_assignments`, correctly respecting every CHECK
constraint `audit_events` itself enforces (verified by executing the
full migration sequence and the accompanying test in `supabase/tests/
database/0042_audit_trigger_test.sql`). Any future migration that adds
administrative or sensitive-data mutation should write to this same
table via the same pattern rather than inventing a parallel audit
mechanism.
Migration `0043` follows that same design through
`audit_feature_flag_change()`, recording each definition mutation as an
`ADMINISTRATION` event.

## Reproducibility

The full sequence `0001`→`0043` has been verified to apply cleanly,
in order, against an empty database with zero errors and zero
warnings — both in the hand-built PostgreSQL 16 stand-in used for the
original pre-merge review (no Docker available in that environment),
and now automatically via **Database CI**
(`.github/workflows/database-ci.yml`), which runs a real `supabase
start` + `supabase db reset` + `supabase test db` + `supabase db lint`
pass against the actual `supabase/postgres` image on every PR touching
`supabase/migrations/**` or `supabase/tests/**`, and on every push to
`main` touching `supabase/migrations/**`. This closes the gap
previously flagged here around `auth.uid()` grant behavior for `0042`'s
`SECURITY INVOKER` trigger functions — see `docs/SECURITY_MODEL.md`
for exactly what CI validates and what remains a manual procedure.
