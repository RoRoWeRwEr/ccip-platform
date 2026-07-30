# Development Workflow

The repository owner has authorized a validated direct-to-main delivery workflow. The previous mandatory path (`GitHub Issue → dedicated branch → Draft PR → GitHub Actions → Claude review → human approval → merge`) is no longer required for routine migration or application-milestone delivery.

For the continuous CCIP v1 program, `docs/PROJECT_MASTER_PLAN.md` defines the
authorized milestones and `docs/EXECUTION_STATUS.md` identifies the next one.
Application deliveries are cohesive milestones with their tests and docs. If a
delivery includes a database migration, every migration-specific rule below
still applies in full.

## Delivery workflow

1. Start from the latest clean `main` (`git fetch origin main`; base all work on `origin/main`).
2. Handle exactly one cohesive migration per delivery — its schema, tests, and documentation together. Never bundle unrelated capabilities.
3. Develop the migration, its pgTAP tests, and its documentation updates.
4. Run every available local validation before pushing: migration replay from empty (`supabase db reset`), the full pgTAP suite (`supabase test db`), `supabase db lint` at `warning` and `error` level, `bash scripts/validate_repository_policy.sh`, `python scripts/check_markdown_links.py`, YAML validation, and `git diff --check`.
5. Push directly to `main` only when every locally available required test passes and there are no known Blocking issues.
6. Let GitHub Actions (Database CI, Repository Policy, Dependency Review where applicable) run immediately after the push. Do not skip or bypass required checks.
7. If GitHub Actions fails, stop all subsequent migration work and fix the failure with a forward-fix commit on `main`. Never force-push, rewrite history, or modify a merged migration to "undo" a failure — correct forward with a new statement or object.
8. Record the delivery — commit SHA, exact files changed, local test results, CI conclusion, known risks, and the single next approved action — and keep `docs/PROJECT_STATUS.md` synchronized with it.
9. After every five successfully delivered migrations, stop and conduct a comprehensive review covering architecture and data model, migration integrity and replay, PostgreSQL correctness, RLS and least privilege, grants and `SECURITY DEFINER` functions, audit behavior, indexes and query performance, naming and consistency, pgTAP coverage, CI and lint results, documentation accuracy, and technical debt/roadmap alignment — before starting a sixth migration.
10. Never force-push, rewrite history, bypass a failed required check, or modify a merged migration, regardless of urgency.

For application milestones, substitute the relevant application validation
matrix—format, lint, typecheck, unit/integration tests, production build, E2E
where available—while retaining repository policy, documentation-link, YAML,
and whitespace checks. After a milestone is green, record it in
`docs/EXECUTION_STATUS.md` and continue to the next unfinished milestone
without waiting for routine confirmation.

## Responsibilities

| Participant | Responsibility |
|---|---|
| ChatGPT | Clarify product intent, help scope a bounded delivery and acceptance criteria, and avoid claiming repository state without verification. |
| Delivering agent (Codex, Claude, or human) | Read repository instructions, start from latest `main`, implement one cohesive migration or application milestone with tests and documentation, run every local validation, push directly to `main`, forward-fix any CI failure, record the delivery, and—for the authorized CCIP v1 program—continue to the next milestone. |
| Independent reviewer (Claude, on request) | Independently review security, PostgreSQL/RLS correctness, performance, compatibility, migrations, tests, naming, and production readiness for a delivered change or for the mandatory five-migration comprehensive review. Findings are Blocking, Important, or Suggestion. A reviewer never merges, never pushes on someone else's behalf, and never silently redesigns the database. |
| GitHub Actions | Reproduce deterministic policy, migration, database, syntax, documentation, dependency, and security checks on every push to `main`. A green check is evidence of correctness; a red check is a forward-fix trigger, not a merge gate, since the push has already landed. |
| Repository owner | Own scope and design decisions, configure secrets and required status checks, resolve accepted risk, and revoke or narrow this authorization at any time. |

## Working agreement

- Each delivery contains one cohesive migration, its tests, and its documentation. Merged migrations remain immutable.
- Every locally available required check must pass before a push to `main`.
- A push happens only when there are no known Blocking issues; Important findings must be fixed or explicitly recorded as an accepted risk.
- A CI failure halts further migration work until fixed by a forward-fix commit.
- No agent starts a subsequent migration within the same delivery.
- Every five successfully delivered migrations trigger a mandatory comprehensive review before the next migration begins.

## Exceptional PR path

A GitHub Issue, dedicated branch, or Pull Request may still be opened for a genuinely exceptional case — for example, a change too large or contested to review through a single direct push, or coordination across multiple agents. This path is optional, never required, and uses `.github/PULL_REQUEST_TEMPLATE.md` and the existing issue templates. When it is used, require at least one explicit human approval before merge; agents and automation must not merge. The exceptional path never substitutes for the local validation and forward-fix discipline above.

## GitHub Actions unavailability

Pushing to `main` depends on GitHub Actions running immediately afterward to validate the delivery. If GitHub Actions is unavailable, do not push — wait for it to recover, or perform local validation only and hold the push until Actions can run. Bypassing a required check is never permitted, regardless of urgency.

## Claude Code activation

`.github/workflows/claude-review.yml` is intentionally disabled by default. To activate it, the repository owner must:

1. Create the Actions repository secret `ANTHROPIC_API_KEY` with a valid Anthropic API key. Never place the value in a file, issue, log, or PR.
2. Create the Actions repository variable `CLAUDE_CODE_ENABLED` with the exact value `true`.
3. Run **Claude Review** manually (`workflow_dispatch`, or an `@claude` PR/issue comment on an exceptional-path PR) and verify that it posts review-only feedback.
4. Confirm the workflow retains `contents: read` and does not receive write permission before enabling routine `@claude` comments.

Without both the variable and secret, the job remains skipped or cannot authenticate. The workflow limits Claude to PR read/comment commands and does not permit code mutation.

## Security automation scope

Dependency Review checks dependency-manifest changes, and Dependabot maintains GitHub Actions references. Repository Policy validates ordered/immutable migrations, YAML, Markdown links, and obvious hardcoded credential assignments. GitHub secret scanning and push protection should be enabled in repository settings as documented in `docs/BRANCH_PROTECTION.md`. CodeQL is not configured because the repository currently contains SQL, Markdown, YAML, and small validation scripts rather than a supported application codebase; add a language-specific CodeQL matrix when a supported backend or frontend language is introduced.

GitHub reported that Dependency Review is not currently supported because the dependency graph is disabled. To activate the workflow, enable the dependency graph under **Settings → Code security**, then create the repository Actions variable `DEPENDENCY_REVIEW_ENABLED=true`. Until both steps are complete, the job is safely skipped rather than failing every PR.
