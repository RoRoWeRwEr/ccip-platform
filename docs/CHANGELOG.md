# Governance Changelog

This changelog records material governance-document changes. Product and code
delivery history remains in Git commits and `docs/EXECUTION_STATUS.md`.

## Unreleased — 2026-08-18

### Added

- Added `docs/AI_ASSISTANT_PRODUCT_SPEC.md` as the proposed post-v1 contract for
  a bilingual, publication-grounded conversational assistant, including flows,
  financial/privacy/prompt-injection safety, architecture, evaluation gates,
  operations, and a phased roadmap.
- Kept the assistant outside current v1 completion and production approval;
  active Phase 10 acceptance and the D-010 regulatory hold remain unchanged.

## Unreleased — 2026-08-17

### Changed

- Recorded owner approval of the 12-card catalog for private-staging curation
  only, live verification that the UI lacks the required issuer/card targets,
  and the exact independent-review and DRAFT-only entry workbook. No staging
  write, submission, approval, scheduling, or publication occurred.
- Recorded the owner catalog-lead and redacted independent bilingual reviewer
  role codes, plus a proposed 12-card/three-issuer official-source inventory.
  Conservative prospective provenance/effective-date coverage is 6/12 (50%);
  no candidate was staged or accepted and both catalog and Phase 10 gates stay
  open pending owner approval and independent review.
- Added the execution-ready Phase 10 owner acceptance package: official-source
  catalog provenance and scoring, bilingual moderated-research scripts and
  acceptance sheets, qualified Saudi legal/privacy/SAMA evidence questions,
  and protected-Preview alert/rollback rehearsal checklists. All templates
  remain explicitly pending and do not change the 29/30 completion state.
- Completed P9.3 private synthetic operational verification and reconciled
  roadmap reporting to **29/30 milestones (97%)**.
- Recorded the owner-approved administrator bootstrap, revocation test, final
  reassignment, synthetic controlled publication, public/user/admin journeys,
  runtime evidence, and residual alert/rollback limitations without recording
  credentials or personal identifiers.
- Set Phase 10 final completion review as the exact next atomic delivery while
  retaining every production, legal/privacy, real-data, and SAMA boundary.
- Completed the executable Phase 10 technical review and full validation;
  recorded private-staging usability, 29/30 status, and the owner acceptance
  package that prevents unsupported v1 or Production completion claims.

- Completed P9.2 private synthetic staging deployment and reconciled roadmap
  reporting to **28/30 milestones (93%)**.
- Recorded the single Vercel Authentication-protected Preview, `fra1` Function
  placement, exact deployed commit, Preview-scoped variable names,
  health/readiness and bilingual UI evidence, and zero warning/error runtime
  logs without recording secret values.
- Recorded the staging security forward fix from three newly disclosed
  transitive advisories to a zero-vulnerability local/Vercel build, with green
  Application CI and Repository Policy.
- Set P9.3 operational verification as the exact next atomic delivery and kept
  the owner-verified administrator identity, production, legal/privacy, and
  real-data boundaries explicit.

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
