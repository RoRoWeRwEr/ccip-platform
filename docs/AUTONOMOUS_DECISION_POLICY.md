# CCIP Autonomous Decision Policy

## Purpose and precedence

This policy is the owner's standing authorization for autonomous execution of
the approved CCIP product roadmap. It reduces routine interruptions without
changing product scope or weakening repository safeguards. The latest `main`,
`AGENTS.md`, product requirements, and the project master plan remain
authoritative. Merged migrations remain immutable, database deliveries remain
limited to one cohesive migration, and all required validation and CI gates
still apply.

## Pre-authorized decisions

Codex may decide, implement, validate, commit, and push the following without
asking the owner:

1. Create narrowly scoped, non-destructive forward migrations when an already
   approved product milestone cannot be implemented safely with the existing
   schema.
2. Add read models, views, read-only functions, indexes, constraints, tests,
   documentation, and CI fixes required to satisfy existing acceptance
   criteria.
3. Select routine implementation technologies and libraries consistent with
   the approved architecture.
4. Fix bugs, security findings, RLS gaps, performance issues, accessibility
   issues, failing tests, and CI failures without changing approved product
   scope.
5. Apply forward-fix commits directly to `main` according to repository
   governance.
6. Continue automatically through milestones and phases recorded in
   `docs/PROJECT_MASTER_PLAN.md`.
7. Batch minor uncertainties and record reasonable assumptions rather than
   interrupting execution.
8. Perform automatic architecture, security, performance, testing,
   UX/accessibility, and documentation reviews at the end of every phase.
9. Update `docs/EXECUTION_STATUS.md` after every safe atomic milestone and
   continue to the next unfinished milestone.
10. Start a new Codex chat only when context limits require it, after committing
    and pushing safe work and recording an exact resume point.

This authority includes the least-privilege technical design needed to deliver
approved acceptance criteria. It does not authorize speculative features,
blanket privileges, security bypasses, migration-history rewrites, or scope
expansion.

## Decisions that require the owner

Codex must ask the owner only when a decision involves:

- changing an approved business requirement or removing an accepted user
  capability;
- materially different product outcomes;
- weakening security, privacy, RLS, publication governance, or auditability;
- destructive production operations or irreversible data loss;
- regulatory, legal, financial, or personal-data policy choices;
- external credentials, secrets, domains, paid accounts, contracts, or
  owner-only actions;
- a new recurring service cost above SAR 500 per month or a one-time cost above
  SAR 2,000; or
- a contradiction that cannot be safely resolved from repository evidence.

## Blocker protocol

When owner input is genuinely required, Codex must first continue every other
unblocked task. It then presents one consolidated numbered decision request,
including the recommended option and the consequences of each choice, rather
than asking repeated questions. The blocker and exact resume point must be
recorded in `docs/EXECUTION_STATUS.md`.

Routine uncertainty below these boundaries is resolved using repository
evidence, least privilege, reversible implementation choices, and documented
assumptions.
