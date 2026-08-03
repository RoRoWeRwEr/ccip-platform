# Project Status

**Last verified:** 2026-08-03 against migration commit `191945f`, the local
`0050` validation stack, and the latest observed GitHub Actions state before
delivery.

This dashboard reports observed states only. Repository and GitHub state override prior chat or stale documentation.

## Current milestone

Sprint 0 — AI-powered cloud development infrastructure — is **merged** through PR #5.

The Database Phase is complete and the owner-authorized CCIP v1 application
execution program is active. `docs/PROJECT_MASTER_PLAN.md` is the authoritative
roadmap and `docs/EXECUTION_STATUS.md` is the live milestone ledger.

Migrations `0001`–`0049` are immutable historical migrations. Migration
`0050_create_published_card_detail_interface.sql` completes the revised
Database Phase after P3.3 proved a concrete public-read boundary gap. It is
delivered under the
validated direct-to-main workflow (see `docs/DEVELOPMENT_WORKFLOW.md`);
routine migration delivery does not require a GitHub Issue, dedicated
branch, Draft PR, or manual merge.

## Status by area

| Area | State | Evidence and notes |
|---|---|---|
| Migrations `0001`–`0050` | **Database Phase complete** | 50 migrations, 111 tables, 35,003 lines; see `docs/MIGRATION_INDEX.md`. |
| Governance workflow | **Updated** | Replaced the mandatory issue/branch/Draft PR/manual-merge path with a validated direct-to-main workflow across `AGENTS.md`, `CLAUDE.md`, `docs/DEVELOPMENT_WORKFLOW.md`, `docs/BRANCH_PROTECTION.md`, and `docs/AI_AGENT_HANDOFF.md`. |
| Sprint 0 infrastructure | **Merged** | PR #5 added unified instructions, handoff/workflow docs, templates, policy automation, Claude workflow, and branch-protection guidance. |
| Open or draft PRs | **Four Dependabot PRs** | PRs #7–#9 and #15 update GitHub Actions dependencies; none blocks direct-to-main delivery. |
| Database testing | **Current migrations covered; historical gap remains** | 19 pgTAP files contain 467 assertions covering `0042`–`0050`; migrations `0001`–`0041` lack dedicated behavioral suites. Database CI replays the full migration history. |
| Security / RLS | **Complete through `0050`** | RLS covers all 111 tables. The new public detail boundary is execute-only, snapshot-based, and read-only; it adds no table grant or write path. Catalog scope behavior from `0049` remains unchanged. |
| Catalog source provenance | **Merged (`0046`), extended (`0047`)** | `catalog_source_provenance` records where catalog evidence came from for banks, cards, card fees, card benefits, reward rules, loyalty programs, card eligibility requirements, and (since `0047`) merchants. `CATALOG_MANAGE`-gated RLS, lifecycle/verification state machines, deduplication, and `audit_events` integration. Does not implement catalog publication approval, ingestion, or content storage — see `docs/DATABASE_ROADMAP.md`. |
| Merchant catalog | **Merged (`0047`)** | `merchants`, `merchant_aliases`, `merchant_relationships`, `merchant_category_assignments`, `merchant_market_presence`, and `merchant_domains` establish canonical merchant identities (bilingual names, classification, channel, lifecycle/verification state machines, parent/subsidiary/brand/chain hierarchy, category and country-presence assignments, official domains) for future offers, reward rules, benefits, and transaction-description matching. `CATALOG_MANAGE`-gated RLS, `audit_events` integration. Does not implement offers, publication governance, scraping, transaction ingestion, or automated/fuzzy matching — see `docs/DATABASE_ROADMAP.md`. |
| Catalog publication governance | **Merged (`0048`), scoped (`0049`)** | Typed catalog versions, publication requests linked to the existing generic approval engine, two-person ordered review/final approval, scheduling/effective windows, publication/suspension/archive/rejection transitions, overlap prevention, append-only domain events, central audit integration, and rollback/supersession lineage. Every workflow action now enforces GLOBAL or matching BANK scope. |
| Catalog admin authorization | **Complete (`0049`)** | Audited scope assignments attach GLOBAL/BANK scope to existing CATALOG_ADMINISTRATOR role assignments; bank ownership resolves through typed bank/card relationships across `0046`–`0048`; shared merchants and loyalty programs require GLOBAL scope; reviewers and final approvers must be in scope; no blanket core-catalog write grant was added. |
| Published card detail | **Complete (`0050`)** | `get_published_card_detail(text)` exposes only currently effective PUBLISHED snapshot fields, safe verified provenance, and independently published governed relationships to `anon`/`authenticated`; drafts, workflow records, internal metadata, and unpublished children remain hidden. |
| Application foundation | **Complete** | Next.js/Supabase runtime, typed repositories, health/readiness, bilingual routing, logging, security headers, and application CI are delivered. |
| Frontend | **Phase 3 in progress** | P3.1 homepage and P3.2 catalog browsing are green; P3.3 card details resumes after this migration delivery. |
| Operational AI/recommendation service | **Not started** | Recommendation schema exists; no running model or API exists. |
| Deployment | **Not started** | CI validates database changes but does not deploy a live environment. |

## Next approved action

Execute the next unfinished application milestone recorded in
`docs/EXECUTION_STATUS.md`. The Database Phase roadmap is complete through
`0050`; P3.3 is the next active delivery.

## Current blockers

- Repository owner must configure branch protection per `docs/BRANCH_PROTECTION.md` for the direct-to-main workflow.
- Claude Code workflow activation requires verification of `ANTHROPIC_API_KEY`; until then it remains manual and gated.
- Dependency Review requires enabling GitHub's dependency graph and setting `DEPENDENCY_REVIEW_ENABLED=true`.
- The first-platform-administrator bootstrap procedure has not been manually exercised against a real local or staging Supabase project.

## Migration 0049 delivery record

- **Migration commit:** `0fada5a3d91c8c7e2a76fcd317cdb2f55c41f139`.
- **Changed files:** `README.md`; `docs/ARCHITECTURE.md`;
  `docs/DATABASE_ROADMAP.md`; `docs/MIGRATION_INDEX.md`;
  `docs/PROJECT_STATUS.md`; `docs/SECURITY_MODEL.md`;
  `supabase/migrations/0049_create_catalog_admin_authorization.sql`;
  `supabase/tests/database/0046_audit_and_integrity_test.sql`;
  `supabase/tests/database/0046_rls_test.sql`;
  `supabase/tests/database/0047_lifecycle_and_provenance_test.sql`;
  `supabase/tests/database/0047_rls_test.sql`;
  `supabase/tests/database/0048_catalog_publication_governance_test.sql`;
  `supabase/tests/database/0049_catalog_admin_authorization_test.sql`.
- **Local validation:** clean replay of migrations `0001`–`0049`; 18 pgTAP
  files / 426 assertions passed; warning- and error-level database lint passed;
  repository policy, Markdown relative links, workflow-equivalent YAML lint,
  and `git diff --check` passed. Final live-schema review found 111/111 tables
  with RLS, zero invalid indexes, 35 application `SECURITY DEFINER` functions,
  zero unhardened application functions, and zero such functions executable by
  `PUBLIC`.
- **GitHub Actions:** [Repository Policy run 30519983700](https://github.com/RoRoWeRwEr/ccip-platform/actions/runs/30519983700)
  and [Database CI run 30519983707](https://github.com/RoRoWeRwEr/ccip-platform/actions/runs/30519983707)
  both completed successfully for the migration commit.
- **Known residual risks:** migrations `0001`–`0041` still lack dedicated
  behavioral pgTAP suites; first-platform-administrator bootstrap remains an
  operational procedure that must be exercised in a real local/staging
  project; no application/API or production workload exists yet to supply
  query-plan evidence for future tuning.
- **Single next approved action:** superseded by the explicit P3.3 authorization
  for migration `0050` recorded below.

## Migration 0050 delivery record

- **Migration commit:** `191945f`.
- **Changed files:** `README.md`; `docs/ARCHITECTURE.md`;
  `docs/DATABASE_ROADMAP.md`; `docs/EXECUTION_STATUS.md`;
  `docs/MIGRATION_INDEX.md`; `docs/PROJECT_MASTER_PLAN.md`;
  `docs/PROJECT_STATUS.md`; `docs/SECURITY_MODEL.md`;
  `docs/TECHNICAL_ARCHITECTURE.md`;
  `supabase/migrations/0050_create_published_card_detail_interface.sql`;
  `supabase/tests/database/0050_published_card_detail_interface_test.sql`.
- **Scope:** one read-only `get_published_card_detail(text)` interface, its 41
  pgTAP assertions, synchronized architecture/security/roadmap documentation,
  and no new table or core-catalog write grant.
- **Local validation:** clean replay of migrations `0001`–`0050`; 19 pgTAP
  files / 467 assertions passed; warning- and error-level database lint passed;
  repository policy, Markdown links, workflow-equivalent YAML lint, and
  `git diff --check` passed. Completion review found 111/111 tables with RLS,
  zero invalid indexes, 36 application `SECURITY DEFINER` functions, and zero
  such functions executable by `PUBLIC`.
- **Phase review:** architecture and schema naming remain consistent; migration
  ordering is intact; all governed public payloads come from immutable 0048
  snapshots; grants and RLS remain least-privilege; the existing publication
  target index and overlap exclusion support the access path; no evidence-based
  new index is justified before production-scale data exists.
- **Known residual risks:** migrations `0001`–`0041` still lack dedicated
  behavioral pgTAP suites; first-admin bootstrap remains an operational staging
  exercise; production-scale query-plan evidence remains unavailable.
- **Next action:** resume P3.3 using the new anonymous read interface.
