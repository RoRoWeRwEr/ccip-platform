# Project Status

**Last verified:** 2026-07-23 against `main` commit `7e05ad09e4964fd907c7bf13d214e66224cb6f39` and GitHub pull-request state.

This dashboard reports observed states only. Repository and GitHub state override prior chat or stale documentation.

## Current milestone

Sprint 0 — AI-powered cloud development infrastructure — is **in progress** on `chore/ai-development-platform`.

Migration `0043_create_feature_flags.sql` is **merged**, not open: PR #4 was merged into `main` at `7e05ad0`. Migrations `0001`–`0043` are therefore immutable historical migrations. There were **no open pull requests** when Sprint 0 began.

## Status by area

| Area | State | Evidence and notes |
|---|---|---|
| Migrations `0001`–`0043` | **Merged** | 43 migrations and 91 tables are on `main`; `0043` merged through PR #4. |
| Migration `0044` | **Blocked / not started** | Must not start until Sprint 0 is merged, a bounded capability is approved in an issue, and a new task is authorized. |
| Sprint 0 infrastructure | **In progress** | Unified instructions, handoff/workflow docs, templates, policy automation, Claude workflow, and branch-protection guidance are being added in the Sprint 0 PR. |
| Open or draft PRs at Sprint 0 start | **None** | GitHub open-PR search returned no results; PR #4 is closed and merged. |
| Database testing | **Merged but incomplete historically** | pgTAP covers `0042` and `0043`; migrations `0001`–`0041` lack dedicated behavioral suites. Database CI replays the full migration history. |
| Security / RLS | **Merged through `0043`** | RLS covers the 91 merged tables. The first-admin bootstrap procedure still requires manual exercise in a real local/staging project. |
| Backend API | **Not started** | No application service exists. |
| Frontend | **Not started** | No frontend exists. |
| Operational AI/recommendation service | **Not started** | Recommendation schema exists; no running model or API exists. |
| Deployment | **Not started** | CI validates database changes but does not deploy a live environment. |

## Next approved action

Complete, validate, independently review, and obtain human approval for the Sprint 0 Draft PR. Do not start migration `0044` in this task.

## Current blockers

- Repository owner must configure branch protection after the Sprint 0 PR lands.
- Claude Code workflow activation requires verification of `ANTHROPIC_API_KEY`; until then it remains manual and gated.
- Dependency Review requires enabling GitHub's dependency graph and setting `DEPENDENCY_REVIEW_ENABLED=true`.
- The first-platform-administrator bootstrap procedure has not been manually exercised against a real local or staging Supabase project.
- Migration `0044` has no approved bounded issue and is explicitly blocked until Sprint 0 is complete.
