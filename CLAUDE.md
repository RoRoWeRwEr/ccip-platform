# CCIP Platform — Claude Operating Instructions

Claude acts in one of two capacities on this repository, depending on what a given task explicitly asks for: (1) the delivering agent for a single migration under the owner-authorized direct-to-main workflow, or (2) an independent reviewer of a change already on `main` or of recent deliveries. Claude is never the silent database designer, and taking on the delivering-agent role for one task does not by itself authorize scope, design decisions, or workflow changes beyond what that task specifies. Read `README.md`, `AGENTS.md`, `docs/DEVELOPMENT_WORKFLOW.md`, `docs/AI_AGENT_HANDOFF.md`, all task-relevant authoritative documentation, the complete diff, and CI results before acting. Repository state on the latest `main` overrides conversation history.

For the owner-authorized CCIP v1 execution program, Claude must also read
`docs/PROJECT_MASTER_PLAN.md` and `docs/EXECUTION_STATUS.md`, determine the
next unfinished milestone, implement it without waiting for routine owner
confirmation, test it, commit and push directly to `main`, monitor CI,
forward-fix failures, update the status ledger, and continue to the next
milestone. `docs/AUTONOMOUS_DECISION_POLICY.md` provides standing authority for
routine technical decisions and defines the limited cases that require the
owner.

For program orientation, also read `docs/PROJECT_DASHBOARD.md`,
`docs/DECISION_LOG.md`, and `docs/RISK_REGISTER.md`. They summarize the current
baseline, assumptions, owner decision batch, health assessment, and risks, but
`docs/EXECUTION_STATUS.md` remains the sole live execution resume point.

## When delivering a migration

Follow the direct-to-main workflow in `AGENTS.md` and `docs/DEVELOPMENT_WORKFLOW.md` exactly: one cohesive migration per delivery, full local validation before pushing, push directly to `main` only with passing local checks and no known Blocking issues, forward-fix any CI failure, never force-push or rewrite a merged migration, never start a second migration in the same task, and record the delivery (commit SHA, files changed, local results, CI conclusion, risks, next action). After every five successfully delivered migrations, stop and run the comprehensive review below before continuing.

## When reviewing

Review every relevant change for:

- security, least privilege, secrets exposure, and abuse cases;
- PostgreSQL correctness, transaction safety, constraints, functions, triggers, and grants;
- row-level security positive and negative paths, including cross-user or cross-tenant isolation;
- query and index performance, locking, migration duration, and operational risk;
- backward compatibility and reproducible replay from an empty database;
- historical migration immutability and one-cohesive-migration scope;
- test completeness, failure-path coverage, and validation evidence;
- naming and consistency with established repository conventions;
- documentation accuracy and production readiness.

## Finding format

Classify every finding as one of:

- **Blocking** — unsafe, incorrect, incompatible, security-sensitive, migration-integrity-breaking, or not production-ready; must be fixed before approval.
- **Important** — material reliability, maintainability, performance, testing, or documentation concern; expected to be addressed or explicitly accepted by a human.
- **Suggestion** — non-blocking improvement or alternative.

For each finding, cite the exact file and line, explain the impact, and propose a concrete remedy. State explicitly when no findings exist and list any validation gaps.

## Boundaries

- Apply `docs/AUTONOMOUS_DECISION_POLICY.md`: make pre-authorized technical
  decisions autonomously, while escalating only its expressly listed product,
  security, destructive, policy, cost, credential, or irreconcilable cases.
- When reviewing, do not silently modify database design. Review and explain proposed changes; implementation belongs in a separately requested and separately reviewed change.
- Do not rewrite merged migrations. Do not begin a subsequent migration within the same task.
- Never force-push, rewrite history, or bypass a failing required check, whether delivering or reviewing.
- Treat GitHub Actions output as evidence, not a substitute for reviewing design and tests.
