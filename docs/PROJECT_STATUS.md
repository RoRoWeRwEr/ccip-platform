# Project Status

**Last verified:** 2026-07-29 against `main` commit `8a304198a44ae532ed0c9ce29b5ab1a88dd79766` (the latest commit before this delivery) and GitHub Actions state.

This dashboard reports observed states only. Repository and GitHub state override prior chat or stale documentation.

## Current milestone

Sprint 0 — AI-powered cloud development infrastructure — is **merged** through PR #5.

Migrations `0001`–`0046` are immutable historical migrations. Migration
`0046_create_catalog_source_provenance.sql` is delivered in this
session under the validated direct-to-main workflow (see
`docs/DEVELOPMENT_WORKFLOW.md`); routine migration delivery does not
require a GitHub Issue, dedicated branch, Draft PR, or manual merge.

## Status by area

| Area | State | Evidence and notes |
|---|---|---|
| Migrations `0001`–`0046` | **Merged** | 46 migrations, 101 tables, 32,458 lines; see `docs/MIGRATION_INDEX.md`. |
| Governance workflow | **Updated** | Replaced the mandatory issue/branch/Draft PR/manual-merge path with a validated direct-to-main workflow across `AGENTS.md`, `CLAUDE.md`, `docs/DEVELOPMENT_WORKFLOW.md`, `docs/BRANCH_PROTECTION.md`, and `docs/AI_AGENT_HANDOFF.md`. |
| Sprint 0 infrastructure | **Merged** | PR #5 added unified instructions, handoff/workflow docs, templates, policy automation, Claude workflow, and branch-protection guidance. |
| Open or draft PRs | **None** | The exceptional PR path (see `docs/DEVELOPMENT_WORKFLOW.md`) was not used for this delivery. |
| Database testing | **Merged but incomplete historically** | pgTAP covers `0042`–`0046`; migrations `0001`–`0041` lack dedicated behavioral suites. Database CI replays the full migration history. |
| Security / RLS | **Merged through `0046`** | RLS covers all 101 merged tables. The first-admin bootstrap procedure still requires manual exercise in a real local/staging project. |
| Catalog source provenance | **Merged (`0046`)** | `catalog_source_provenance` records where catalog evidence came from for banks, cards, card fees, card benefits, reward rules, loyalty programs, and card eligibility requirements. `CATALOG_MANAGE`-gated RLS, lifecycle/verification state machines, deduplication, and `audit_events` integration. Does not implement catalog publication approval, ingestion, or content storage — see `docs/DATABASE_ROADMAP.md`. |
| Backend API | **Not started** | No application service exists. |
| Frontend | **Not started** | No frontend exists. |
| Operational AI/recommendation service | **Not started** | Recommendation schema exists; no running model or API exists. |
| Deployment | **Not started** | CI validates database changes but does not deploy a live environment. |

## Next approved action

None beyond this delivery. Migration `0046` is complete; do not start
migration `0047` until it is separately authorized. The likely first
consumer of `catalog_source_provenance` is a future catalog publication
governance migration (see `docs/DATABASE_ROADMAP.md`), not yet
authorized.

## Current blockers

- Repository owner must configure branch protection per `docs/BRANCH_PROTECTION.md` for the direct-to-main workflow.
- Claude Code workflow activation requires verification of `ANTHROPIC_API_KEY`; until then it remains manual and gated.
- Dependency Review requires enabling GitHub's dependency graph and setting `DEPENDENCY_REVIEW_ENABLED=true`.
- The first-platform-administrator bootstrap procedure has not been manually exercised against a real local or staging Supabase project.
