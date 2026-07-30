# Project Status

**Last verified:** 2026-07-30 against `main` commit `d7d0da1cb7f96ff860f7fa6a3a316f51f37ba0d9` (the latest commit before this delivery), the local 0049 validation stack, and GitHub Actions state.

This dashboard reports observed states only. Repository and GitHub state override prior chat or stale documentation.

## Current milestone

Sprint 0 — AI-powered cloud development infrastructure — is **merged** through PR #5.

Migrations `0001`–`0048` are immutable historical migrations. Migration
`0049_create_catalog_admin_authorization.sql` completes the current Database
Phase in this session under the
validated direct-to-main workflow (see `docs/DEVELOPMENT_WORKFLOW.md`);
routine migration delivery does not require a GitHub Issue, dedicated
branch, Draft PR, or manual merge.

## Status by area

| Area | State | Evidence and notes |
|---|---|---|
| Migrations `0001`–`0049` | **Database Phase complete** | 49 migrations, 111 tables, 34,629 lines; see `docs/MIGRATION_INDEX.md`. |
| Governance workflow | **Updated** | Replaced the mandatory issue/branch/Draft PR/manual-merge path with a validated direct-to-main workflow across `AGENTS.md`, `CLAUDE.md`, `docs/DEVELOPMENT_WORKFLOW.md`, `docs/BRANCH_PROTECTION.md`, and `docs/AI_AGENT_HANDOFF.md`. |
| Sprint 0 infrastructure | **Merged** | PR #5 added unified instructions, handoff/workflow docs, templates, policy automation, Claude workflow, and branch-protection guidance. |
| Open or draft PRs | **Three Dependabot PRs** | PRs #7–#9 update GitHub Actions dependencies; the exceptional PR path (see `docs/DEVELOPMENT_WORKFLOW.md`) was not used for this delivery. |
| Database testing | **Current migrations covered; historical gap remains** | 18 pgTAP files contain 426 assertions covering `0042`–`0049`; migrations `0001`–`0041` lack dedicated behavioral suites. Database CI replays the full migration history. |
| Security / RLS | **Complete through `0049`** | RLS covers all 111 tables. Catalog administrators use explicit GLOBAL/BANK scopes, legacy unscoped assignments fail closed, and platform administrators remain global. The first-admin bootstrap procedure still requires manual exercise in a real local/staging project. |
| Catalog source provenance | **Merged (`0046`), extended (`0047`)** | `catalog_source_provenance` records where catalog evidence came from for banks, cards, card fees, card benefits, reward rules, loyalty programs, card eligibility requirements, and (since `0047`) merchants. `CATALOG_MANAGE`-gated RLS, lifecycle/verification state machines, deduplication, and `audit_events` integration. Does not implement catalog publication approval, ingestion, or content storage — see `docs/DATABASE_ROADMAP.md`. |
| Merchant catalog | **Merged (`0047`)** | `merchants`, `merchant_aliases`, `merchant_relationships`, `merchant_category_assignments`, `merchant_market_presence`, and `merchant_domains` establish canonical merchant identities (bilingual names, classification, channel, lifecycle/verification state machines, parent/subsidiary/brand/chain hierarchy, category and country-presence assignments, official domains) for future offers, reward rules, benefits, and transaction-description matching. `CATALOG_MANAGE`-gated RLS, `audit_events` integration. Does not implement offers, publication governance, scraping, transaction ingestion, or automated/fuzzy matching — see `docs/DATABASE_ROADMAP.md`. |
| Catalog publication governance | **Merged (`0048`), scoped (`0049`)** | Typed catalog versions, publication requests linked to the existing generic approval engine, two-person ordered review/final approval, scheduling/effective windows, publication/suspension/archive/rejection transitions, overlap prevention, append-only domain events, central audit integration, and rollback/supersession lineage. Every workflow action now enforces GLOBAL or matching BANK scope. |
| Catalog admin authorization | **Complete (`0049`)** | Audited scope assignments attach GLOBAL/BANK scope to existing CATALOG_ADMINISTRATOR role assignments; bank ownership resolves through typed bank/card relationships across `0046`–`0048`; shared merchants and loyalty programs require GLOBAL scope; reviewers and final approvers must be in scope; no blanket core-catalog write grant was added. |
| Backend API | **Not started** | No application service exists. |
| Frontend | **Not started** | No frontend exists. |
| Operational AI/recommendation service | **Not started** | Recommendation schema exists; no running model or API exists. |
| Deployment | **Not started** | CI validates database changes but does not deploy a live environment. |

## Next approved action

None. The current Database Phase roadmap is complete through `0049`. Do not
invent or begin migration `0050`; the next work belongs to the application/API
phase unless the owner separately approves a new bounded database roadmap.

## Current blockers

- Repository owner must configure branch protection per `docs/BRANCH_PROTECTION.md` for the direct-to-main workflow.
- Claude Code workflow activation requires verification of `ANTHROPIC_API_KEY`; until then it remains manual and gated.
- Dependency Review requires enabling GitHub's dependency graph and setting `DEPENDENCY_REVIEW_ENABLED=true`.
- The first-platform-administrator bootstrap procedure has not been manually exercised against a real local or staging Supabase project.
