# CCIP v1 Definition of Done

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
