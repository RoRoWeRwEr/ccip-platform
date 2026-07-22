# Project Status

**Last updated:** 2026-07-22

This is a factual dashboard, generated from direct inspection of this
repository's migrations, tests, CI configuration, merged pull requests,
and `docs/` files — not from memory or assumption. Where a status
below is a plan or estimate rather than an observed fact, it is labeled
as such. See `docs/DATABASE_ROADMAP.md` for the reasoning behind
sequencing decisions and `docs/SECURITY_MODEL.md` for the security
detail behind the security/RLS status line.

## Current milestone

Migration `0042` (`create_user_profiles_and_platform_roles`) merged
into `main` via PR #2, with Database CI passing on the merge commit.
This closes the post-`0042` documentation-sync milestone; the next
milestone is deciding and scoping migration `0043` (see
`docs/DATABASE_ROADMAP.md`).

## Current branch baseline

`main`, at the merge of PR #2 plus one follow-up documentation commit
("docs: reflect migration 0042 merged to main").

## Latest completed migration

`0042_create_user_profiles_and_platform_roles.sql` — merged, tested,
CI-validated.

## Next planned migration

None started. `0043` onward is **not started** — see
`docs/DATABASE_ROADMAP.md` for the prerequisites and the assessed
0043–0050 candidate sequence (which requires revision before use).

## Status by area

| Area | Status | Notes |
|---|---|---|
| Database migrations | **Complete** (through `0042`) | 42 migrations, 90 tables, merged into `main`. Zero destructive operations (`DROP TABLE`/`DROP COLUMN`/`TRUNCATE`) in the entire history. |
| Documentation | **In progress** | Core reference docs (`ARCHITECTURE.md`, `SECURITY_MODEL.md`, `MIGRATION_INDEX.md`, `DATABASE_ROADMAP.md`, `PROJECT_CONTEXT.md`, `BOOTSTRAP_PLATFORM_ADMIN.md`) exist and are current as of this sync. Several `docs/` subdirectories (`00-overview/`, `02-frs/`, `05-ui-ux/`, `06-admin/`, `07-api/`, `08-testing/`, `09-roadmap/`) are placeholders (`.gitkeep` only). `decisions/` (ADRs) and `glossary/` are also placeholders. |
| Testing (pgTAP) | **Needs improvement** | 4 test files / 23 assertions exist, covering migration `0042` only (schema/constraint checks, RLS positive/negative paths, function-behavior checks, audit-trail checks). Migrations `0001`–`0041` have no dedicated pgTAP coverage of their own — CI's `supabase db reset` step does prove they apply cleanly, but that is not the same as behavioral test coverage. |
| CI/CD | **Complete** (for its current scope) | `.github/workflows/database-ci.yml` (Database CI) runs on every PR touching `supabase/migrations/**` or `supabase/tests/**`, and on every push to `main` touching `supabase/migrations/**`. It performs a real Supabase local-stack startup, full migration replay from empty, the full pgTAP suite, and database linting at `warning` and `error` level. Latest run on `main` (the `0042` merge commit): **success**. Scope is database-only — there is no application build/deploy pipeline, because there is no application yet. |
| Security / RLS | **Complete** (for what's built) | RLS enabled on all 90 tables, no exceptions. Blanket `anon`/`authenticated` grants revoked in `0041`; access granted back narrowly by policy, including column-level grants in `0042`. Exactly 3 `SECURITY DEFINER` functions in the codebase, each justified and pinned to `search_path = pg_catalog`. Privilege-escalation and cross-tenant-exposure paths tested adversarially, not just by policy inspection. Scoped (non-`PLATFORM`) authorization is **deferred**, not built — see `docs/DATABASE_ROADMAP.md`. The first-platform-administrator bootstrap procedure (`docs/BOOTSTRAP_PLATFORM_ADMIN.md`) is documented but has **not yet been manually exercised** end-to-end against a live Supabase project. |
| Backend API | **Not started** | No API/service code exists anywhere in this repository. |
| Frontend | **Not started** | No frontend/UI code exists anywhere in this repository. |
| AI / recommendation implementation | **Not started (as an operational service); database structures exist** | Migrations `0022`–`0034` (13 migrations) model a rules/scoring-based recommendation engine at the schema level: financial/spending profiles, preferences, eligibility assessments, value simulations, recommendation models/factors/segments, runs, results, explanations, factor scores, feedback, and outcomes. This is schema only — there is no running recommendation service, model, or API that produces a recommendation today. `recommendation_models` models a rules/scoring approach, not machine learning; an ML feature store or model-serving layer is explicitly deferred in `docs/DATABASE_ROADMAP.md` (`0048`, "speculative at the current product stage"). |
| Deployment | **Not started** | No deployment configuration, hosting target, or environment-provisioning code exists in this repository. Database changes are validated by CI but not deployed by it — this repository does not manage a live Supabase project. |

## Current blockers

- No blocker to further database work: `0042` is merged, tested, and
  CI-validated.
- Migration `0043`'s scope is not yet decided — the originally proposed
  `0043`–`0050` sequence needs revision before any of it is built (see
  `docs/DATABASE_ROADMAP.md`).
- The first-platform-administrator bootstrap procedure has not been
  manually exercised against a live Supabase project; this should
  happen before any environment built from this schema is expected to
  have a working administrator.
- pgTAP coverage does not yet extend to migrations `0001`–`0041`.

## Recommended improvements

- Extend pgTAP coverage backward to `0001`–`0041`, not just `0042`,
  so CI's regression guarantee covers the whole schema, not only the
  newest migration.
- Manually exercise the bootstrap procedure in a local/staging Supabase
  project and record the result, per `docs/BOOTSTRAP_PLATFORM_ADMIN.md`.
- Resolve the single-schema-vs-multi-schema question flagged in
  `docs/ARCHITECTURE.md` before analytics/warehouse work makes it more
  expensive to change.
- Decide and scope migration `0043` deliberately rather than defaulting
  to the originally proposed sequence as-is (see
  `docs/DATABASE_ROADMAP.md` for the per-item assessment).

## Next three actions

1. Manually exercise the first-platform-administrator bootstrap
   procedure against a local or staging Supabase project and confirm
   the result, closing the one remaining manual-verification gap noted
   in `docs/SECURITY_MODEL.md`.
2. Decide the scope of migration `0043` using
   `docs/DATABASE_ROADMAP.md`'s assessment as the starting point, then
   open a dedicated branch and PR for it, with pgTAP tests in the same
   PR.
3. Add pgTAP coverage for migrations `0001`–`0041` so CI's regression
   guarantee is not limited to `0042`.
