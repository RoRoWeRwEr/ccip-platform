# Governance Changelog

This changelog records material governance-document changes. Product and code
delivery history remains in Git commits and `docs/EXECUTION_STATUS.md`.

## Unreleased — 2026-08-14

### Added

- Public-facing and strategic Project Objective and Public Value definitions.
- Measurable trust, usefulness, explainability, bilingual, accessibility,
  privacy, fairness, correction, and safety outcomes.
- Program dashboard with milestone accounting, health scoring, dependencies,
  critical path, forecast assumptions, blockers, and owner decisions.
- Decision log separating accepted decisions, assumptions, and owner choices.
- Risk register covering privacy, bias, explainability, security, consumer
  harm, regulatory position, accessibility, performance, operations, and
  delivery coordination.
- Short-name `AI_HANDOFF.md` compatibility entry while retaining
  `AI_AGENT_HANDOFF.md` as the canonical protocol.

### Changed

- Clarified that CCIP is decision support and does not guarantee savings,
  eligibility, approval, credit improvement, or other financial outcomes.
- Expanded handoff controls to prevent duplicate work across concurrent AI
  tasks and to require re-reconciliation of repository/GitHub state.
- Reconciled roadmap reporting to **27/30 milestones (90%)**, with P9.2 blocked
  on owner-controlled staging inputs.
- Updated dashboard, decision, risk, CI, handoff, and next-action information
  against `main` at `420a886`.
- Recorded the 2026-08-12 owner approval of Vercel and Supabase for private,
  non-production staging with synthetic/test data only, while preserving
  qualified Saudi legal/privacy review as a production-launch gate.
- Added D-010's regulatory-risk boundary, official SAMA/SDAIA source facts,
  assessment hypotheses, prohibited production capabilities, and questions for
  qualified Saudi counsel or SAMA.
- Added risks for the aggregation licensing perimeter, Sandbox ineligibility,
  cross-border transfer, real-data leakage into staging, ranking/CPA conflicts,
  and reliance on AI-generated legal analysis.

### Evidence notes

- The verified baseline is `420a8867502253e2967341ddd2e72f86dd188dc6` on
  local and remote `main`. Repository Policy run 30837249315 passed for that
  commit. P9.1 implementation commit `ace16b3` passed Application CI run
  30836747504 and Repository Policy run 30836749288.
- Phases 1–8 and P9.1 are complete. P9.2, P9.3, and Phase 10 remain.
- No tag or GitHub release existed at the verification time.
- These governance changes were not intentionally committed, pushed, or
  released by the governance audit task.
