# Development Workflow

The normal delivery path is:

`GitHub Issue → Codex Cloud → dedicated branch → Draft PR → GitHub Actions → Claude review → Codex fixes → human approval → merge`

## Responsibilities

| Participant | Responsibility |
|---|---|
| ChatGPT | Clarify product intent, help define a bounded issue and acceptance criteria, and avoid claiming repository state without verification. |
| Codex | Read repository instructions, start from latest `main`, implement only the issue scope, add tests and documentation, run validation, open a Draft PR, and address review findings. Codex never merges. |
| Claude | Independently review security, PostgreSQL/RLS correctness, performance, compatibility, migrations, tests, naming, and production readiness. Findings are Blocking, Important, or Suggestion. Claude never merges or silently redesigns the database. |
| GitHub Actions | Reproduce deterministic policy, migration, database, syntax, documentation, dependency, and security checks. A green check is necessary but does not grant merge authorization. |
| Repository owner | Own scope and design decisions, configure secrets and branch protection, resolve accepted risk, give final explicit approval, and merge. |

## Working agreement

- Every change begins with a GitHub issue and uses a dedicated branch.
- Database changes use one cohesive migration per issue and PR. Merged migrations remain immutable.
- PRs begin as drafts and include exact validation evidence and risks.
- Blocking Claude findings must be fixed. Important findings must be fixed or explicitly accepted by the owner.
- Required checks and conversations must be resolved before owner review.
- Migrations and security changes are never auto-merged.
- No agent starts the next migration within the current task.

## Emergency and local fallback

Local Terminal is an emergency or outage fallback, not the normal daily workflow. Use it only when Codex Cloud or GitHub Actions is unavailable, when reproducing an environment-specific failure, or for an explicitly authorized recovery. Start from a clean checkout of latest `main`, use the same branch/PR process, capture exact commands and results, never place credentials in shell history or repository files, and return the work to a Draft PR as soon as GitHub is available. Direct pushes to `main` and bypassing required checks remain prohibited during an emergency.

## Claude Code activation

`.github/workflows/claude-review.yml` is intentionally disabled by default. To activate it, the repository owner must:

1. Create the Actions repository secret `ANTHROPIC_API_KEY` with a valid Anthropic API key. Never place the value in a file, issue, log, or PR.
2. Create the Actions repository variable `CLAUDE_CODE_ENABLED` with the exact value `true`.
3. Run **Claude Review** manually against a Draft PR and verify that it posts review-only feedback.
4. Confirm the workflow retains `contents: read` and does not receive write permission before enabling routine `@claude` comments.

Without both the variable and secret, the job remains skipped or cannot authenticate. The workflow limits Claude to PR read/comment commands and does not permit code mutation.

## Security automation scope

Dependency Review checks dependency-manifest changes, and Dependabot maintains GitHub Actions references. Repository Policy validates ordered/immutable migrations, YAML, Markdown links, and obvious hardcoded credential assignments. GitHub secret scanning and push protection should be enabled in repository settings as documented in `docs/BRANCH_PROTECTION.md`. CodeQL is not configured because the repository currently contains SQL, Markdown, YAML, and small validation scripts rather than a supported application codebase; add a language-specific CodeQL matrix when a supported backend or frontend language is introduced.

GitHub reported that Dependency Review is not currently supported because the dependency graph is disabled. To activate the workflow, enable the dependency graph under **Settings → Code security**, then create the repository Actions variable `DEPENDENCY_REVIEW_ENABLED=true`. Until both steps are complete, the job is safely skipped rather than failing every PR.
