# CCIP v1 Project Master Plan

## Authority and objective

This document is the authoritative execution roadmap for taking CCIP from its
completed database foundation to a working, deployed v1 product. Repository
state on the latest `main`, `AGENTS.md`, `CLAUDE.md`, and the factual status in
`docs/EXECUTION_STATUS.md` control execution. Product behavior is constrained
by `docs/PRODUCT_REQUIREMENTS.md` and completion by
`docs/DEFINITION_OF_DONE.md`.

The execution lead continues from the next unfinished milestone without
waiting for routine approval. A milestone includes implementation, tests,
documentation, a direct push to `main`, green required CI, and an execution
status update. Stop only for a genuine unresolved business decision, an
unavailable credential or external-account action, or a destructive production
action requiring explicit approval.

Standing technical decision authority and the exact escalation boundary are
defined in `docs/AUTONOMOUS_DECISION_POLICY.md`.

## Delivery principles

- Prefer a usable vertical slice over speculative infrastructure.
- Preserve migrations `0001`–`0051`; never rewrite published history.
- Do not add a migration unless application implementation proves a concrete
  schema gap. Document the gap and migration justification here first.
- Public catalog access remains available without authentication. User and
  administrator features use Supabase Auth and existing RLS.
- Catalog administration must use migration `0049` BANK/GLOBAL authorization
  and migration `0048` controlled publication workflows.
- Use official catalog sources only and surface provenance/publication state.
- Every push is locally validated, monitored in GitHub Actions, and corrected
  by forward-fix commits when necessary.

## Production stack decision

CCIP v1 uses a single TypeScript web application built with Next.js App Router,
React, and Tailwind CSS; Supabase provides PostgreSQL, Auth, and RLS; Zod
validates environment and boundary inputs; structured server logging uses
Pino-compatible JSON; Vitest and Testing Library cover unit/component behavior;
Playwright covers critical browser journeys. Vercel is the preferred web host
because it provides the lowest-operational-overhead deployment path for
Next.js, while Supabase remains the data/auth platform.

This is the best fit for the current repository: the product needs one
mobile-first bilingual web surface, server-side access to a mature Supabase
schema, public SEO-friendly catalog pages, and no independent service that
justifies a second runtime. The application must keep privileged Supabase keys
server-only and use the anonymous/authenticated clients for RLS-enforced paths.

## Milestones

### Phase 1 — Database Foundation — Complete

- Migrations `0001`–`0051`, 111 tables, full RLS coverage.
- Database CI and Repository Policy green for the completion delivery.
- BANK/GLOBAL catalog authorization and controlled publication lifecycle in
  place.
- P3.3 proved that the anonymous RLS surface could not safely expose
  publication snapshots, rewards, eligibility, provenance, and merchant
  relationships together. Migration `0050` was explicitly authorized as a
  bounded execute-only published card-detail interface with no new table or
  core-catalog write grant.
- P3.4 proved that correct reward filtering, sorting, and pagination require a
  result-set read boundary. Migration `0051` adds that bounded execute-only
  published list/search interface without altering `0050` or granting table
  writes.

### Phase 2 — Application Foundation

1. **P2.1 Execution system and application architecture** — create the v1
   roadmap, requirements, architecture, definition of done, status ledger, and
   continuous-delivery governance.
2. **P2.2 Web application scaffold** — create the Next.js TypeScript app,
   package/tooling configuration, Arabic/English routing foundation, base
   design tokens, lint/type/test/build commands, and application CI.
3. **P2.3 Runtime foundation** — validated environment configuration, browser
   and server Supabase clients, auth middleware foundation, health/readiness
   endpoints, structured logging, typed errors, request correlation, and safe
   security headers.
4. **P2.4 Data-access foundation** — generated or checked-in database types,
   typed catalog repositories, publication-aware public queries, pagination,
   and integration-test harness.

### Phase 3 — Public Catalog Experience

1. **P3.1 Shell and homepage** — accessible mobile-first bilingual shell,
   locale switcher, navigation, homepage, and persona entry points.
2. **P3.2 Catalog browsing** — Saudi banks and cards with loading, empty, and
   error states; pagination and stable URLs.
3. **P3.3 Card details** — fees, benefits, reward rules, eligibility, loyalty,
   merchant, provenance, and published-catalog information.
4. **P3.4 Search and filters** — text search and useful bank, network, fee,
   reward, persona, and eligibility filters with shareable state.

### Phase 4 — Comparison and Calculation

1. **P4.1 Multi-card comparison** — select and compare cards with a clear,
   responsive attribute matrix.
2. **P4.2 Spending calculator** — category inputs, annualization, fees, reward
   valuation, assumptions, and explanation output.
3. **P4.3 Numeric hardening** — finite non-negative boundaries, caps, rounding,
   currency precision, edge cases, and property-oriented tests preventing NaN,
   Infinity, overflow, or negative-value corruption.

### Phase 5 — Recommendation Experience

1. **P5.1 Recommendation domain engine** — deterministic spending-profile,
   eligibility, fixed monetary valuation, annual fee, goal alignment, and net
   value ranking consistent with the Decision Engine Specification.
2. **P5.2 Recommendation journey** — persona, required goal, spending inputs,
   optional current cards, constraints, ranked results, confidence, and clear
   reasons/assumptions.
3. **P5.3 Persistence integration** — recommendation runs/history and saved
   results where supported by existing schema and authenticated RLS.

### Phase 6 — Authentication and User Features

1. **P6.1 Authentication journeys** — secure signup, verification, login,
   logout, password recovery, callback handling, and session refresh.
2. **P6.2 Profile and saved items** — user profile, saved cards, and saved
   comparisons with correct ownership isolation.
3. **P6.3 User history** — recommendation history, privacy-aware deletion or
   lifecycle behavior supported by the schema, and RLS integration tests.

### Phase 7 — Catalog Administration

1. **P7.1 Admin authorization shell** — protected administration area showing
   effective GLOBAL/BANK scope without exposing privileged credentials.
2. **P7.2 Provenance and merchant management** — scope-correct controlled
   interfaces, validation, audit feedback, and cross-bank denial tests.
3. **P7.3 Publication workflow** — draft, submit, reviewer/final approval,
   scheduling, publish, unpublish, rollback, and history using migrations
   `0048`–`0049`; never bypass controlled functions.
4. **P7.4 Assignment administration** — platform-administrator-only BANK/GLOBAL
   assignment lifecycle with privilege-escalation tests.

### Phase 8 — Quality and Security

1. **P8.1 Automated quality gate** — comprehensive unit, integration, and E2E
   suites for critical public, user, and administrator paths.
2. **P8.2 Accessibility and responsive review** — automated and manual keyboard,
   semantics, contrast, RTL/LTR, zoom, and mobile viewport checks.
3. **P8.3 Security review** — auth/session boundaries, RLS, authorization,
   secrets, dependency/configuration, headers, input validation, abuse cases,
   and error disclosure.
4. **P8.4 Performance and resilience** — query plans where meaningful, bundle
   and page performance, caching correctness, rate/error behavior, and degraded
   dependency states.

### Phase 9 — Staging and Deployment

1. **P9.1 Deployment readiness** — production build, environment contract,
   deployment configuration, runbooks, observability, and rollback plan.
2. **P9.2 Staging deployment** — deploy automatically if credentials exist;
   otherwise finish all repository work and maintain one exact owner-action
   checklist.
3. **P9.3 Operational verification** — exercise first-platform-administrator
   bootstrap in staging, validate health/readiness and critical journeys, and
   record evidence without committing secrets or personal identifiers.

### Phase 10 — CCIP v1 Completion

1. Final architecture, security, UX, accessibility, performance, and
   documentation reviews.
2. Full automated validation and deployed smoke tests.
3. Confirm clean working tree, local `HEAD` equals `origin/main`, and all
   required GitHub Actions are green.
4. Publish the final v1 completion report and exact residual operational risks.

## Current next milestone

The next unfinished milestone is **P3.4**. Migration `0051` now provides its
publication-aware, read-only card-list/search boundary; the application must
integrate that interface to complete reward filtering, sorting, and pagination.
`docs/EXECUTION_STATUS.md` is the live source for the exact current task.
