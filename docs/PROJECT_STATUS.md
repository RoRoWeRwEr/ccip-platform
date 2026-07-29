# Project Status

**Last verified:** 2026-07-29 against `main` commit `2ba88df` and GitHub Actions state.

This dashboard reports observed states only. Repository and GitHub state override prior chat or stale documentation.

## Current milestone

Sprint 0 — AI-powered cloud development infrastructure — is **merged** through PR #5.

Migrations `0001`–`0045` are immutable historical migrations. Migration
`0045_create_background_jobs.sql` merged through PR #14. The repository
governance was updated to a validated direct-to-main delivery workflow
(see `docs/DEVELOPMENT_WORKFLOW.md`); routine migration delivery no
longer requires a GitHub Issue, dedicated branch, Draft PR, or manual
merge.

## Status by area

| Area | State | Evidence and notes |
|---|---|---|
| Migrations `0001`–`0045` | **Merged** | 45 migrations are on `main`; `0045` merged through PR #14. |
| Governance workflow | **Updated** | Replaced the mandatory issue/branch/Draft PR/manual-merge path with a validated direct-to-main workflow across `AGENTS.md`, `CLAUDE.md`, `docs/DEVELOPMENT_WORKFLOW.md`, `docs/BRANCH_PROTECTION.md`, and `docs/AI_AGENT_HANDOFF.md`. |
| Sprint 0 infrastructure | **Merged** | PR #5 added unified instructions, handoff/workflow docs, templates, policy automation, Claude workflow, and branch-protection guidance. |
| Open or draft PRs | **None** | The exceptional PR path (see `docs/DEVELOPMENT_WORKFLOW.md`) was not used for this delivery. |
| Database testing | **Merged but incomplete historically** | pgTAP covers `0042`–`0044`; migrations `0001`–`0041` lack dedicated behavioral suites. Database CI replays the full migration history. |
| Security / RLS | **Merged through `0044`** | RLS covers the 97 merged tables. The first-admin bootstrap procedure still requires manual exercise in a real local/staging project. |
| Backend API | **Not started** | No application service exists. |
| Frontend | **Not started** | No frontend exists. |
| Operational AI/recommendation service | **Not started** | Recommendation schema exists; no running model or API exists. |
| Deployment | **Not started** | CI validates database changes but does not deploy a live environment. |

## Next approved action

None. Governance was updated to the direct-to-main workflow in this
delivery; do not start migration `0046` until it is separately
authorized.

## Current blockers

- Repository owner must configure branch protection per `docs/BRANCH_PROTECTION.md` for the direct-to-main workflow.
- Claude Code workflow activation requires verification of `ANTHROPIC_API_KEY`; until then it remains manual and gated.
- Dependency Review requires enabling GitHub's dependency graph and setting `DEPENDENCY_REVIEW_ENABLED=true`.
- The first-platform-administrator bootstrap procedure has not been manually exercised against a real local or staging Supabase project.
