# Project Status

**Last updated:** 2026-07-23

This is a factual dashboard, generated from direct inspection of this
repository's migrations, tests, CI configuration, merged pull requests,
and `docs/` files — not from memory or assumption. Where a status
below is a plan or estimate rather than an observed fact, it is labeled
as such. See `docs/DATABASE_ROADMAP.md` for the reasoning behind
sequencing decisions and `docs/SECURITY_MODEL.md` for the security
detail behind the security/RLS status line.

## Current milestone

Migration `0042` (`create_user_profiles_and_platform_roles`) is the
latest migration merged into `main`. Migration `0043`
(`create_feature_flags`) is committed on branch
`codex/0043-feature-flags` and published for independent review in
Draft PR #4. It is not merged; Database CI for the latest review-fix
update is pending.

## Current branch baseline

The development branch is `codex/0043-feature-flags`, based on current
`main`. Draft PR #4 targets `main` and remains unmerged.

## Latest completed migration

`0042_create_user_profiles_and_platform_roles.sql` — merged, tested,
CI-validated.

## Next planned migration

`0043_create_feature_flags.sql` is **committed and in Draft PR #4**. It adds one
PLATFORM-wide administrative feature flag table, a boolean runtime
evaluation function, RLS, least-privilege grants, and audit integration.
No narrower targeting scope is included. `0044` onward is not started.

## Status by area

| Area | Status | Notes |
|---|---|---|
| Database migrations | **Merged through `0042`; `0043` in Draft PR #4** | 42 migrations and 90 tables are merged into `main`. The committed, unmerged `0043` branch adds one table. Zero destructive operations (`DROP TABLE`/`DROP COLUMN`/`TRUNCATE`) exist in the migration history or the `0043` draft. |
| Documentation | **In progress** | Core reference docs (`ARCHITECTURE.md`, `SECURITY_MODEL.md`, `MIGRATION_INDEX.md`, `DATABASE_ROADMAP.md`, `PROJECT_CONTEXT.md`, `BOOTSTRAP_PLATFORM_ADMIN.md`) exist and are current as of this sync. Several `docs/` subdirectories (`00-overview/`, `02-frs/`, `05-ui-ux/`, `06-admin/`, `07-api/`, `08-testing/`, `09-roadmap/`) are placeholders (`.gitkeep` only). `decisions/` (ADRs) and `glossary/` are also placeholders. |
| Testing (pgTAP) | **Needs improvement** | The merged suite has 4 files / 23 assertions covering `0042`; the `0043` branch adds focused constraint, RLS, evaluation, and audit tests. Migrations `0001`–`0041` still have no dedicated pgTAP coverage of their own. |
| CI/CD | **Pending for latest PR #4 update** | Database CI performs a real Supabase local-stack startup, full migration replay from empty, the pgTAP suite, and database linting at `warning` and `error` level. The previous PR #4 run passed; a new run for the latest review-fix commit is pending. Scope remains database-only. |
| Security / RLS | **Complete through `0042`; extended by `0043` draft** | RLS is enabled on all 90 merged tables and on the draft's one new table. The merged schema has 3 `SECURITY DEFINER` functions; `0043` adds 2 narrowly justified, pinned functions for boolean-only evaluation and audit writes. Feature-flag management requires an active `PLATFORM_ADMINISTRATOR`; narrower authorization remains deferred. The first-platform-administrator bootstrap procedure is documented but has not been manually exercised against a live project. |
| Backend API | **Not started** | No API/service code exists anywhere in this repository. |
| Frontend | **Not started** | No frontend/UI code exists anywhere in this repository. |
| AI / recommendation implementation | **Not started (as an operational service); database structures exist** | Migrations `0022`–`0034` (13 migrations) model a rules/scoring-based recommendation engine at the schema level: financial/spending profiles, preferences, eligibility assessments, value simulations, recommendation models/factors/segments, runs, results, explanations, factor scores, feedback, and outcomes. This is schema only — there is no running recommendation service, model, or API that produces a recommendation today. `recommendation_models` models a rules/scoring approach, not machine learning; an ML feature store or model-serving layer is explicitly deferred in `docs/DATABASE_ROADMAP.md` (`0048`, "speculative at the current product stage"). |
| Deployment | **Not started** | No deployment configuration, hosting target, or environment-provisioning code exists in this repository. Database changes are validated by CI but not deployed by it — this repository does not manage a live Supabase project. |

## Current blockers

- No blocker to further database work: `0042` is merged, tested, and
  CI-validated.
- Migration `0043` requires local/CI validation and human review before
  merge. Its scope is now decided as PLATFORM-only feature flags.
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
- Complete independent review and Database CI for Draft PR #4 before
  considering migration `0043` ready to merge.

## Next three actions

1. Manually exercise the first-platform-administrator bootstrap
   procedure against a local or staging Supabase project and confirm
   the result, closing the one remaining manual-verification gap noted
   in `docs/SECURITY_MODEL.md`.
2. Complete review and Database CI for migration `0043` in Draft PR #4;
   keep it unmerged until explicitly authorized.
3. Add pgTAP coverage for migrations `0001`–`0041` so CI's regression
   guarantee is not limited to `0042`.
