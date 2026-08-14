# CCIP Project Dashboard

**Baseline verified:** 2026-08-14 against `main` at `420a886`
**Evidence boundary:** committed repository state and GitHub checks for that
commit. Uncommitted governance-document changes are WIP, not completion
evidence.

## Executive baseline

| Item | Status |
|---|---|
| Current phase | Phase 9 — Staging and Deployment |
| Current milestone | P9.2 — Private staging deployment (provider approved; provisioning inputs blocked) |
| Completed | Database Foundation; P2.1–P2.4; P3.1–P3.4; P4.1–P4.3; P5.1–P5.3; P6.1–P6.3; P7.1–P7.4; P8.1–P8.4; P9.1 |
| Overall progress | **27 of 30 milestones complete (90%)**; not an effort-spent measure |
| Work in progress | No implementation milestone is in progress. P9.2 cannot start until the owner supplies the recorded staging inputs. |
| Remaining | P9.2, P9.3, and the Phase 10 completion milestone (3 of 30) |
| Current branch | `main`; `HEAD` and `origin/main` both resolved to `420a886` before this documentation-only WIP |
| Latest commit | `420a8867502253e2967341ddd2e72f86dd188dc6` — `docs(status): complete P9.1 deployment readiness` |
| Verified CI | Repository Policy run 30837249315 passed for `420a886`; P9.1 Application CI run 30836747504 and Repository Policy run 30836749288 passed for `ace16b3` |
| Open PRs | Dependabot #7, #8, #9, and #15; none is a current critical-path blocker |

## Completion accounting

The 30-milestone denominator treats the completed Database Foundation as one
milestone, Phases 2–9 use their numbered milestones, and Phase 10 is one final
completion milestone. Twenty-seven are complete. P9.1 is countable because its
implementation commit `ace16b3` passed Application CI and Repository Policy,
and status reconciliation commit `420a886` passed Repository Policy. A blocked
milestone is not counted as complete.

## Critical path and dependencies

1. Owner provisions separate private staging Supabase and Vercel projects,
   scoped deployment authorization, required environment values, and an
   owner-verified staging administrator.
2. P9.2 deploys the exact green `main` commit with synthetic/test data only and
   records non-secret technical-validation evidence.
3. P9.3 verifies health, readiness, critical journeys, and administrator
   bootstrap in staging.
4. Phase 10 performs final reviews, full validation, deployed smoke tests, and
   the completion report.

The official-source publication model, Supabase Auth/RLS, deterministic
calculation semantics, bilingual content, accessible interaction patterns,
deployment contract, and rollback procedure are complete in the repository.
The external inputs now block the critical path.

## Blockers and constraints

| Type | Item | Impact / disposition |
|---|---|---|
| Resolved staging decision | Vercel + Supabase are approved for private, non-production staging with synthetic/test data only | Enables technical validation only; not production or compliance approval. |
| Regulatory prohibition | Production, real personal/financial data, application forwarding, bank-document collection, commissions, paid referrals, and bank integrations are not authorized | Requires applicable legal, privacy, contractual, and SAMA requirements to be formally resolved. |
| Licensing perimeter | Application forwarding plus CPA materially overlaps SAMA aggregation requirements; Sandbox eligibility is unresolved | Obtain qualified Saudi counsel or SAMA advice before relying on a licence or Sandbox path. |
| Production privacy | Controller/processor roles, lawful bases, transfer mechanism, sensitive-data classification, retention, consent, and production region are unresolved | Qualified Saudi legal/privacy review is a production gate. Frankfurt/Dubai are staging candidates only. |
| Blocking owner setup | Separate private staging Supabase and Vercel projects, scoped deployment authorization, and required environment values are unavailable | P9.2 cannot deploy. Secrets must not be committed or pasted into documentation. |
| Blocking owner setup | An intended staging administrator identity has not been owner-verified | P9.3 cannot safely exercise first-administrator bootstrap. No email or UUID belongs in the repository. |
| Owner setup | Branch protection/ruleset configuration is not evidenced as complete | Governance risk; does not change the P9.2 blocker. |
| Owner setup | Dependency graph and `DEPENDENCY_REVIEW_ENABLED=true` are not evidenced | Dependency Review remains skipped. |
| Optional owner setup | Claude Review secret/variable are not evidenced | Optional review automation remains inactive. |
| Evidence gap | No staging telemetry, deployed latency, cache/CDN behavior, or operational bootstrap evidence exists | Must be gathered in P9.2–P9.3 before Phase 10 completion. |

## Forecast

There is no defensible completion date while P9.2 is blocked. After the owner
provides all required inputs, only P9.2, P9.3, and Phase 10 remain. Reforecast
from the first successful staging deployment; any earlier calendar estimate
would hide the owner-controlled dependency.

## Project health assessment

| Dimension | Score | Evidence-based assessment |
|---|---:|---|
| Architecture | 90 | Modular monolith, typed boundaries, controlled database interfaces, and complete v1 product journeys are implemented; staging evidence remains. |
| Security and privacy | 88 | Full-table RLS, scoped administration, hardened functions, negative tests, browser policy, and secret-free runtime boundaries are green; production legal/privacy review and staging verification remain. |
| Performance | 82 | Bounded data access, readiness timeout, degraded states, production build, and bundle budgets are enforced; deployed latency and production-scale evidence remain unavailable. |
| Maintainability | 84 | Strong conventions, types, tests, and governance are offset by a large schema and overlapping historical delivery records. |
| Technical debt | 72 | Migrations `0001`–`0041` still lack dedicated behavioral pgTAP suites; action upgrades and external repository settings remain. |
| Documentation | 88 | Roadmap, execution ledger, deployment runbook, and governance are comprehensive; this reconciliation removes the stale program baseline. |
| Testing | 91 | P9.1 recorded 73 unit/component, 10 real-Supabase integration, 32 browser, and 538 pgTAP assertions passing, plus build, bundle, and policy gates; deployed tests remain. |
| UX | 86 | Critical public, user, and administrative journeys are bilingual, responsive, and browser-tested; staging research/operational evidence remains. |
| Accessibility | 86 | Automated serious-impact checks plus keyboard, zoom, direction, and mobile coverage are complete; deployed/manual assistive-technology evidence remains a release consideration. |

**Weighted project health score: 86/100.** The implemented and locally/CI-
verified product is strong. The score remains below launch-ready because P9.2
is still blocked on provisioning, no deployed operational evidence exists, and
production legal/privacy, region, first-admin, early-migration coverage, and
repository-setting risks remain.

## Owner decision batch

The exact blocking batch is authoritative in `docs/EXECUTION_STATUS.md`:

1. Provision separate private staging Supabase and Vercel projects through
   migration `0053` with environment-scoped browser-safe values.
2. Supply owner-authenticated Vercel authorization or equivalent scoped token,
   organization ID, and project ID outside the repository.
3. Identify and verify the intended staging administrator in Supabase without
   recording personal identifiers in source or chat.

All staging data must be synthetic/test data. Production hosting/region and
launch approval remain conditional on qualified Saudi legal/privacy review.

The regulatory assessment is AI-generated risk analysis, not legal advice or
SAMA/PDPL approval. D-010 in `docs/DECISION_LOG.md` separates official-source
facts, hypotheses, prohibited capabilities, and questions for counsel/SAMA.

Catalog breadth, research sample, and monetization decisions remain required
before Phase 10 completion but do not independently enable a deployment.

## Exactly one next execution milestone

**P9.2 — staging deployment:** wait for the complete owner-controlled input
batch above; then deploy the exact green `main` commit and record non-secret
deployment evidence. Do not begin P9.3 until staging deployment succeeds.
