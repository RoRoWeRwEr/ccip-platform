# CCIP v1 Definition of Done

## Public-value and responsible-use outcomes

The v1 completion review must record evidence for each outcome below. These
are release gates or measurement targets, not current-performance claims and
not guarantees of savings, approval, eligibility, credit improvement, or any
financial result.

| Outcome | v1 measure and acceptance evidence |
|---|---|
| Trustworthy catalog | At least 95% of published card records in the release acceptance dataset have a visible effective date and a verified official-source provenance reference; every exception is labeled and risk-accepted. |
| Task usefulness | At least 90% of moderated participants complete the critical discovery, comparison, and explanation tasks without facilitator correction; sample, method, and Arabic/English results are recorded separately. |
| Explainability | 100% of recommendation results show material user inputs, catalog/data version or effective context, annual reward estimate, annual fee, net-value method, assumptions, limitations, and deterministic ranking reasons. |
| Reproducibility | Identical accepted inputs and catalog version produce identical calculation and recommendation results in automated tests. |
| Bilingual parity | Every critical journey and material disclaimer is available in Arabic and English with equivalent meaning; no known material untranslated or directionality defect remains. |
| Accessibility | Critical journeys pass automated checks and documented manual keyboard, screen-reader, focus, contrast, 200% zoom, RTL/LTR, and 320px mobile reviews with no unresolved Blocking finding. |
| Data control and privacy | Guest use remains meaningful; personal data collection is purpose-limited and documented; user-owned records pass positive and negative RLS tests; lifecycle/deletion behavior and consent are verified where implemented. |
| Bias and consumer harm | Persona, language, income-band, bank, network, and reward-type test cases are reviewed for unexplained exclusion or systematically degraded results; all material findings are fixed or explicitly accepted by the owner before release. |
| Correction responsiveness | Every validated catalog correction has an owner and audit trail; the staging operational exercise demonstrates intake-to-publication handling, with a target median resolution of five business days or less once production measurement begins. |
| Safety | Release evidence records zero known material privacy breach, secret exposure, cross-user/cross-bank authorization failure, discriminatory ranking defect, or guaranteed-outcome claim. |

CCIP must be described throughout the product as information and decision
support, not a bank, lender, credit bureau, or regulated financial adviser.
Estimates must be conditional on source data, user inputs, and stated
assumptions. Any future use for lending decisions, open-banking data, or
regulated advice requires a new owner-approved scope, legal/privacy assessment,
security review, and Definition of Done update.

## Milestone done

A milestone is complete only when:

- acceptance behavior is implemented without placeholders or hidden TODOs;
- relevant unit, integration, E2E, accessibility, and database tests pass;
- lint, formatting, typecheck, production build, repository policy, Markdown
  links, YAML validation, and `git diff --check` pass where applicable;
- security, privacy, RTL/LTR, mobile, error, empty, loading, and edge-input
  behavior have been reviewed proportionate to the change;
- authoritative documentation and `docs/EXECUTION_STATUS.md` are current;
- assumptions and escalations comply with
  `docs/AUTONOMOUS_DECISION_POLICY.md`;
- the complete diff has no known Blocking issue;
- the cohesive change is committed and pushed directly to `main`;
- all triggered required GitHub Actions are green, with failures corrected by
  forward-fix commits; and
- the working tree is clean and local `HEAD` equals `origin/main` before moving
  to the next milestone.

Passing CI alone does not make a milestone complete.

## Phase done

A phase is complete when every milestone in that phase meets the milestone
definition, cross-milestone integration works, documentation describes actual
behavior, and a phase review records architecture, security, UX/accessibility,
performance, testing, documentation, and technical-debt findings. In-scope
Blocking findings must be fixed before the next phase, using autonomous
forward fixes where authorized by `docs/AUTONOMOUS_DECISION_POLICY.md`.

## CCIP v1 done

CCIP v1 is complete only when all ten phases in
`docs/PROJECT_MASTER_PLAN.md` are complete and:

- public Arabic and English discovery, details, search, comparison,
  calculation, and recommendation journeys work on mobile and desktop;
- authentication and user-owned features enforce RLS correctly;
- BANK/GLOBAL administration and the full controlled publication lifecycle are
  verified, including negative cross-bank and escalation paths;
- calculation output is deterministic, finite, explainable, and protected from
  unsafe numeric behavior;
- critical journeys pass automated E2E and accessibility checks;
- final architecture, security, performance, UX, dependency, configuration,
  documentation, and deployment reviews have no unresolved Blocking issue;
- a staging deployment is verified, or the only remaining blocker is an exact
  owner credential/account checklist after all executable repository work is
  complete;
- required GitHub Actions are green, the working tree is clean, and local
  `HEAD` exactly equals `origin/main`; and
- `docs/EXECUTION_STATUS.md` and the final completion report contain exact
  commits, tests, deployed endpoints, known risks, and remaining owner actions.

## Not acceptable as done

- Mock-only production paths, placeholder data presented as real catalog data,
  tests skipped without a recorded blocker, broad service-role access, direct
  workflow-table mutations, untranslated critical journeys, inaccessible
  custom controls, unmonitored pushes, dirty worktrees, or completion claims
  based on plans rather than observed evidence.
