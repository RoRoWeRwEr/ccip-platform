# CCIP Platform — Unified Agent Instructions

These rules apply to every coding agent and human contributor. Repository state on the latest `main` overrides chat history, model memory, copied prompts, and prior session assumptions.

## Mandatory reading order

Before planning or editing:

1. Fetch the latest `main`, inspect the current commit, and check GitHub Actions status; note any open pull requests (exceptional path only — see below).
2. Read `README.md`.
3. Read this file.
4. Read `CLAUDE.md`.
5. Read every authoritative file under `docs/`, beginning with `docs/AI_AGENT_HANDOFF.md`, `docs/DEVELOPMENT_WORKFLOW.md`, and `docs/PROJECT_STATUS.md`.
   For CCIP v1 execution, always read `docs/PROJECT_MASTER_PLAN.md` and
   `docs/EXECUTION_STATUS.md`, determine the next unfinished milestone, and
   treat that milestone as the active routine delivery.
6. Inspect all workflows under `.github/workflows/` and the files relevant to the task.
7. Reconcile documentation with the actual tree and GitHub state; report discrepancies before work.

Standing decision authority and the narrow cases that require owner input are
defined in `docs/AUTONOMOUS_DECISION_POLICY.md`. Apply that policy throughout
planning and delivery.

## Non-negotiable engineering rules

- Merged migrations are historical records. Never rewrite, rename, reorder, or delete them. Correct prior behavior only with a new, documented migration.
- A database PR contains exactly one cohesive migration and its tests and documentation. Never bundle unrelated capabilities.
- Never start a subsequent migration in the same task, even if the current migration is completed.
- New tables containing user or tenant data require RLS in their creating migration. Any `SECURITY DEFINER` function requires a documented justification, schema-qualified references, and a pinned `search_path`.
- Do not invent schemas, objects, requirements, dependencies, or completion claims. No placeholders, TODO SQL, pseudocode, or partially enforced designs.
- Add or update tests with every behavior change. Run every available validation and state exactly what passed, failed, or could not run.
- Keep authoritative documentation synchronized with the implementation and current GitHub state.

## Delivery workflow (direct-to-main)

The repository owner has authorized a validated direct-to-main delivery workflow. A GitHub Issue, dedicated branch, Draft PR, and manual merge are no longer required for routine migration delivery.

1. Start from the latest clean `main`.
2. Handle exactly one cohesive migration per delivery. Never start a second migration in the same delivery.
3. Develop the migration, its tests, and its documentation together.
4. Run every available local validation before pushing (migration replay, pgTAP, lint, repository policy, Markdown links, YAML validation, `git diff --check`) and review the full diff and migration integrity yourself.
5. Push directly to `main` only when every locally available required test passes and there are no known Blocking issues.
6. Let GitHub Actions run immediately after the push. Never skip or bypass a required check.
7. If GitHub Actions fails, stop all subsequent migration work and fix the failure with a forward-fix commit on `main`. Never force-push, rewrite history, or modify a merged migration.
8. Record the delivery: commit SHA, exact files changed, local test results, CI conclusion, known risks, and the single next approved action.
9. After every five successfully delivered migrations, stop and conduct the comprehensive review described in `docs/DEVELOPMENT_WORKFLOW.md` before starting a sixth.
10. End each database delivery after its single authorized migration; begin any
    subsequent migration only as a new atomic delivery. Autonomous application
    execution then continues from the next unfinished roadmap milestone.

A GitHub Issue, branch, or PR may still be opened for a genuinely exceptional case (see `docs/DEVELOPMENT_WORKFLOW.md`), but it is never required and never substitutes for steps 4–9 above.

See `docs/DEVELOPMENT_WORKFLOW.md` for roles and the end-to-end process.

## Autonomous CCIP v1 execution

The owner has authorized continuous execution of the milestones in
`docs/PROJECT_MASTER_PLAN.md`. After each milestone, update
`docs/EXECUTION_STATUS.md`, validate, commit, push directly to `main`, monitor
all triggered GitHub Actions, forward-fix failures, and continue automatically
to the next unfinished milestone. The database-only one-migration rule still
applies whenever a delivery contains a migration; application milestones must
also remain cohesive and reviewable.

Use `docs/AUTONOMOUS_DECISION_POLICY.md` to resolve routine technical choices
without owner interruption and to identify the limited decisions that require
the owner. Record external blockers precisely and continue every other
executable task. Context or session limits are not completion: finish the
current safe atomic operation, commit and push it, update
`docs/EXECUTION_STATUS.md` with the exact resume point, and provide one resume
instruction without leaving undocumented local changes.
