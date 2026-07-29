# Project Status

**Last verified:** 2026-07-29 against `main` commit `0a48d2280cfe9742d721302c99c971ecc59023a2` (the latest commit before this delivery) and GitHub Actions state.

This dashboard reports observed states only. Repository and GitHub state override prior chat or stale documentation.

## Current milestone

Sprint 0 — AI-powered cloud development infrastructure — is **merged** through PR #5.

Migrations `0001`–`0047` are immutable historical migrations. Migration
`0047_create_merchants.sql` is delivered in this session under the
validated direct-to-main workflow (see `docs/DEVELOPMENT_WORKFLOW.md`);
routine migration delivery does not require a GitHub Issue, dedicated
branch, Draft PR, or manual merge.

## Status by area

| Area | State | Evidence and notes |
|---|---|---|
| Migrations `0001`–`0047` | **Merged** | 47 migrations, 107 tables, 33,530 lines; see `docs/MIGRATION_INDEX.md`. |
| Governance workflow | **Updated** | Replaced the mandatory issue/branch/Draft PR/manual-merge path with a validated direct-to-main workflow across `AGENTS.md`, `CLAUDE.md`, `docs/DEVELOPMENT_WORKFLOW.md`, `docs/BRANCH_PROTECTION.md`, and `docs/AI_AGENT_HANDOFF.md`. |
| Sprint 0 infrastructure | **Merged** | PR #5 added unified instructions, handoff/workflow docs, templates, policy automation, Claude workflow, and branch-protection guidance. |
| Open or draft PRs | **None** | The exceptional PR path (see `docs/DEVELOPMENT_WORKFLOW.md`) was not used for this delivery. |
| Database testing | **Merged but incomplete historically** | pgTAP covers `0042`–`0047`; migrations `0001`–`0041` lack dedicated behavioral suites. Database CI replays the full migration history. |
| Security / RLS | **Merged through `0047`** | RLS covers all 107 merged tables. The first-admin bootstrap procedure still requires manual exercise in a real local/staging project. |
| Catalog source provenance | **Merged (`0046`), extended (`0047`)** | `catalog_source_provenance` records where catalog evidence came from for banks, cards, card fees, card benefits, reward rules, loyalty programs, card eligibility requirements, and (since `0047`) merchants. `CATALOG_MANAGE`-gated RLS, lifecycle/verification state machines, deduplication, and `audit_events` integration. Does not implement catalog publication approval, ingestion, or content storage — see `docs/DATABASE_ROADMAP.md`. |
| Merchant catalog | **Merged (`0047`)** | `merchants`, `merchant_aliases`, `merchant_relationships`, `merchant_category_assignments`, `merchant_market_presence`, and `merchant_domains` establish canonical merchant identities (bilingual names, classification, channel, lifecycle/verification state machines, parent/subsidiary/brand/chain hierarchy, category and country-presence assignments, official domains) for future offers, reward rules, benefits, and transaction-description matching. `CATALOG_MANAGE`-gated RLS, `audit_events` integration. Does not implement offers, publication governance, scraping, transaction ingestion, or automated/fuzzy matching — see `docs/DATABASE_ROADMAP.md`. |
| Backend API | **Not started** | No application service exists. |
| Frontend | **Not started** | No frontend exists. |
| Operational AI/recommendation service | **Not started** | Recommendation schema exists; no running model or API exists. |
| Deployment | **Not started** | CI validates database changes but does not deploy a live environment. |

## Next approved action

None beyond this delivery. Migration `0047` is complete; do not start
migration `0048` until it is separately authorized. The approved next
migration is `0048` (Catalog Publication Governance), followed by
`0049` (Catalog Admin Authorization) — see `docs/DATABASE_ROADMAP.md`.

## Current blockers

- Repository owner must configure branch protection per `docs/BRANCH_PROTECTION.md` for the direct-to-main workflow.
- Claude Code workflow activation requires verification of `ANTHROPIC_API_KEY`; until then it remains manual and gated.
- Dependency Review requires enabling GitHub's dependency graph and setting `DEPENDENCY_REVIEW_ENABLED=true`.
- The first-platform-administrator bootstrap procedure has not been manually exercised against a real local or staging Supabase project.
