# AI Agent Handoff

This is the canonical entry point for a new ChatGPT, Codex, Claude, or human session. A session resumes from repository evidence, never from previous chat history.

Use this exact startup prompt:

> “Continue the CCIP project from the repository source of truth.”

## Canonical reading order

1. Fetch the latest remote `main`; inspect the current branch, working tree, recent commits, open PRs, and required check results.
2. Read `README.md`.
3. Read `AGENTS.md`.
4. Read `CLAUDE.md`.
5. Read this file, `docs/DEVELOPMENT_WORKFLOW.md`, and `docs/PROJECT_STATUS.md`.
6. Read `docs/PROJECT_MASTER_PLAN.md` and `docs/EXECUTION_STATUS.md`; the
   next unfinished milestone is the active routine task.
7. Read `docs/PROJECT_DASHBOARD.md`, `docs/DECISION_LOG.md`, and
   `docs/RISK_REGISTER.md` for the verified program baseline, assumptions,
   owner decision batch, health assessment, and active risks.
8. Read `docs/PRODUCT_REQUIREMENTS.md`, `docs/TECHNICAL_ARCHITECTURE.md`,
   `docs/DEFINITION_OF_DONE.md`, `docs/PROJECT_CONTEXT.md`,
   `docs/ARCHITECTURE.md`, `docs/SECURITY_MODEL.md`,
   `docs/MIGRATION_INDEX.md`, `docs/DATABASE_ROADMAP.md`, and all other
   authoritative documents relevant to the task.
9. Inspect every workflow in `.github/workflows/`, then inspect the complete files and history affected by the task.

Historical drafts marked superseded are context only; migrations and current authoritative documents control.

## Required pre-work status checks

Record:

- current `main` commit and whether local work is based on it;
- dirty or untracked files and their ownership;
- any open pull requests (exceptional path only — see `docs/DEVELOPMENT_WORKFLOW.md`);
- the delivery record of the most recent migration(s) in `docs/PROJECT_STATUS.md` — commit SHA, local test results, CI conclusion;
- latest merged migration and the next unused migration number;
- required CI checks and their current conclusions;
- task scope, acceptance criteria, dependencies, and blockers;
- whether Docker, Supabase CLI, and other required validators are available.

If repository documentation disagrees with GitHub or the tree, the current repository and GitHub state win. Update stale documentation in scope and do not carry a stale premise forward.

At handoff, report the branch, commit, changed files, validations and exact results, checks not run and why, open findings, activation steps, and the single next approved action.

For the CCIP v1 program, complete and publish each milestone, update
`docs/EXECUTION_STATUS.md`, and continue automatically. A handoff is required
only when an allowed blocker or session boundary prevents continued execution;
it must identify the exact next task and leave no undocumented local changes.

Current verified resume point: P9.3 operational verification passed against the
protected private Preview running
`626ef83668e59c8bd406b3639b34bb410300db93`; 29 of 30 milestones are complete
(97%). The owner-approved administrator bootstrap/revocation/reassignment and
representative synthetic public, authenticated, publication, and admin
journeys passed without recording an identifier. Phase 10 final review is the
next atomic delivery. This staging approval does not extend to production or
Saudi legal/regulatory compliance.

The regulatory boundary in `docs/DECISION_LOG.md` D-010 is mandatory: do not
enable production, real personal/financial data, application forwarding, bank-
document collection, commissions, paid referrals, or bank integrations. The
record is AI-generated risk analysis, not legal advice. Licensing, Sandbox,
PDPL, transfer, consent, retention, contract, and production-region questions
require qualified Saudi counsel or SAMA.

## Duplicate-work prevention

Before editing, compare `git status`, `git log`, `origin/main`, this file, and
`docs/EXECUTION_STATUS.md` again. Another authorized task may have delivered a
milestone while this document was being read. Committed and pushed repository
evidence wins over a stale task prompt. Never reset, overwrite, or recreate a
dirty change whose ownership is unknown; continue in its existing task or
obtain an explicit handoff.

`docs/AI_HANDOFF.md` exists only to satisfy the short governance filename and
points here. This file remains canonical because `AGENTS.md` and `CLAUDE.md`
require it.
