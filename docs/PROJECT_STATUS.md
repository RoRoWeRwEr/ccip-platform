# Project Status

**Last verified:** 2026-07-23 against `main` commit `3e198bc` and GitHub pull-request state.

This dashboard reports observed states only. Repository and GitHub state override prior chat or stale documentation.

## Current milestone

Sprint 0 — AI-powered cloud development infrastructure — is **merged** through PR #5.

Migrations `0001`–`0044` are immutable historical migrations. Migration
`0044_create_api_management.sql` merged through PR #12. No pull request
was open when work on Issue #13 began.

## Status by area

| Area | State | Evidence and notes |
|---|---|---|
| Migrations `0001`–`0044` | **Merged** | 44 migrations and 97 tables are on `main`; `0044` merged through PR #12. |
| Migration `0045` | **In development** | Issue #13 approves a bounded background-jobs foundation for retention executions and commission settlements. |
| Sprint 0 infrastructure | **Merged** | PR #5 added unified instructions, handoff/workflow docs, templates, policy automation, Claude workflow, and branch-protection guidance. |
| Open or draft PRs at Sprint 0 start | **None** | GitHub open-PR search returned no results; PR #4 is closed and merged. |
| Database testing | **Merged but incomplete historically** | pgTAP covers `0042`–`0044`; migrations `0001`–`0041` lack dedicated behavioral suites. Database CI replays the full migration history. |
| Security / RLS | **Merged through `0044`** | RLS covers the 97 merged tables. The first-admin bootstrap procedure still requires manual exercise in a real local/staging project. |
| Backend API | **Not started** | No application service exists. |
| Frontend | **Not started** | No frontend exists. |
| Operational AI/recommendation service | **Not started** | Recommendation schema exists; no running model or API exists. |
| Deployment | **Not started** | CI validates database changes but does not deploy a live environment. |

## Next approved action

Complete, validate, independently review, and obtain human approval for the
Migration 0045 Draft PR under Issue #13. Do not start migration 0046.

## Current blockers

- Repository owner must configure branch protection after the Sprint 0 PR lands.
- Claude Code workflow activation requires verification of `ANTHROPIC_API_KEY`; until then it remains manual and gated.
- Dependency Review requires enabling GitHub's dependency graph and setting `DEPENDENCY_REVIEW_ENABLED=true`.
- The first-platform-administrator bootstrap procedure has not been manually exercised against a real local or staging Supabase project.
