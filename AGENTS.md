# CCIP Platform — Unified Agent Instructions

These rules apply to every coding agent and human contributor. Repository state on the latest `main` overrides chat history, model memory, copied prompts, and prior session assumptions.

## Mandatory reading order

Before planning or editing:

1. Fetch the latest `main` and inspect open pull requests and checks.
2. Read `README.md`.
3. Read this file.
4. Read `CLAUDE.md`.
5. Read every authoritative file under `docs/`, beginning with `docs/AI_AGENT_HANDOFF.md` and `docs/PROJECT_STATUS.md`.
6. Inspect all workflows under `.github/workflows/` and the files relevant to the task.
7. Reconcile documentation with the actual tree and GitHub state; report discrepancies before work.

## Non-negotiable engineering rules

- Merged migrations are historical records. Never rewrite, rename, reorder, or delete them. Correct prior behavior only with a new, documented migration.
- A database PR contains exactly one cohesive migration and its tests and documentation. Never bundle unrelated capabilities.
- Never start a subsequent migration in the same task, even if the current migration is completed.
- New tables containing user or tenant data require RLS in their creating migration. Any `SECURITY DEFINER` function requires a documented justification, schema-qualified references, and a pinned `search_path`.
- Do not invent schemas, objects, requirements, dependencies, or completion claims. No placeholders, TODO SQL, pseudocode, or partially enforced designs.
- Add or update tests with every behavior change. Run every available validation and state exactly what passed, failed, or could not run.
- Keep authoritative documentation synchronized with the implementation and current GitHub state.

## Git and review workflow

1. Start from the latest `main` on a dedicated branch linked to an issue.
2. Never commit or push directly to `main`.
3. Review the full diff and migration integrity before committing.
4. Open a Draft PR and allow required GitHub Actions checks to complete.
5. Obtain independent Claude review and address blocking and important findings.
6. Require explicit human approval before merge. Agents, automation, and reviewers must not merge.
7. Stop after the authorized task. Do not begin the next migration or adjacent feature.

See `docs/DEVELOPMENT_WORKFLOW.md` for roles and the end-to-end process.
