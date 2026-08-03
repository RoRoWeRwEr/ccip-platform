# CCIP v1 Execution Status

**Last verified:** 2026-08-03 at P7.1 commit `33c72ae`.
Repository Policy run 30827126415 and Application CI run 30827126503 passed.

**Program progress:** 19 of 30 roadmap milestones complete = **63%**.

This is the authoritative live ledger for autonomous CCIP v1 execution. Update
it after every completed milestone and before any session handoff. Do not mark a
milestone complete until `docs/DEFINITION_OF_DONE.md` is satisfied.

## Current state

| Phase | State | Evidence |
|---|---|---|
| 1 — Database Foundation | Complete | 53 migrations, 111 RLS-enabled tables, 22 pgTAP files / 538 assertions. Migration 0053 adds the minimal internal P6.2 user-profile bootstrap. |
| 2 — Application Foundation | Complete | P2.1–P2.4 and the phase review are complete and green. |
| 3 — Public Catalog | Complete | P3.1–P3.4 and the phase review are complete; Application CI run 30810879333 and Repository Policy run 30810879203 passed for `1c269bf`. |
| 4 — Comparison and Calculation | Complete | P4.1–P4.3 and the phase review are complete; Application CI run 30815813577 and Repository Policy run 30815813897 passed for `8e723b5`. |
| 5 — Recommendation | Complete | P5.1 engine, P5.2 bilingual recommendation journey, P5.3 ownership-scoped persistence boundary, and the phase review are complete and green. |
| 6 — Authentication and User Features | Complete | P6.1–P6.3 and the phase review are complete and green. |
| 7 — Catalog Administration | In progress | P7.1 protected GLOBAL/BANK authorization shell is complete and green; P7.2 is next. |
| 8 — Quality and Security | Not started | Database validation exists; application gates do not. |
| 9 — Staging and Deployment | Not started | No application deployment configuration or credentials observed. |
| 10 — CCIP v1 Completion | Not started | Depends on phases 1–9. |

## Current task

Execute **P7.2 Provenance and Merchant Management** as the next unfinished milestone.

## Exact next task

Implement scope-correct controlled provenance and merchant management
interfaces with input validation, audit feedback, and cross-bank denial tests.

## Current validation and CI

- P7.1 delivery: the protected bilingual admin route evaluates platform and
  catalog access through migration `0049`'s scope-aware database functions,
  displays effective GLOBAL or BANK access, denies users without active scope,
  and uses neither privileged credentials nor browser-provided authorization
  claims. Assignment history remains visible only to platform administrators.
- P7.1 local validation: formatting, lint, strict typecheck, 58/58 unit and
  component tests, 10/10 real-Supabase integration tests, production build,
  repository policy, and whitespace checks passed.
- P7.1 commit: `33c72ae`; Application CI run 30827126503 and Repository Policy
  run 30827126415 passed.

- P3.4 commit: `1c269bf`; Application CI run 30810879333 and Repository Policy
  run 30810879203 passed.
- P4.1 local validation: formatting, lint, strict typecheck, 25/25 unit and
  component tests, 6/6 real-Supabase integration tests, production build, and
  offline zero-vulnerability npm audit passed. The bilingual comparison route
  bounds selection to three unique valid slugs and reads selected cards only
  through migration `0050`'s publication-safe detail interface.
- P4.1 commit: `6e89fcb`; Application CI run 30811325652 and Repository Policy
  run 30811325643 passed.
- P4.2 delivery: `/{locale}/calculator` uses publication-safe card details,
  shareable bounded monthly category inputs, fixed valuation assumptions,
  category/general published rules, minimums, caps, annual fees, and an
  explicit bilingual calculation trace. Offers and benefits remain excluded.
- P4.2 local validation: formatting, lint, strict typecheck, 30/30 unit and
  component tests, 6/6 real-Supabase integration tests, production build,
  offline zero-vulnerability npm audit, repository policy, Markdown links,
  YAML lint, and whitespace checks passed.
- P4.2 commit: `65a3c72`; Application CI run 30815068208 and Repository Policy
  run 30815068138 passed.
- P4.3 delivery: calculator arithmetic uses bounded BigInt fixed-point units,
  halala half-up monetary rounding, published reward rounding and shared caps,
  period-aware minimums, fail-closed unsupported tier/transaction cases, and a
  fully bilingual limitation trace. Extreme input combinations remain finite,
  bounded, non-negative where required, and deterministic.
- P4.3 local validation: formatting, lint, strict typecheck, 33/33 unit and
  component tests, 6/6 real-Supabase integration tests, production build,
  offline zero-vulnerability npm audit, repository policy, Markdown links,
  YAML lint, and whitespace checks passed.
- P4.3 commit: `8e723b5`; Application CI run 30815813577 and Repository Policy
  run 30815813897 passed.
- P5.1 delivery: a pure deterministic engine filters explicit published,
  available, recommendation-eligible candidates; applies salary, bank, and fee
  constraints; uses fixed per-reward valuations and hardened annual value; and
  ranks by net value, reward value, lower fee, goal score, then stable name/ID.
  Results include rank, confidence, top categories, reasons, assumptions, and
  publication context.
- P5.1 local validation: formatting, lint, strict typecheck, 36/36 unit and
  component tests, 6/6 real-Supabase integration tests, production build,
  offline zero-vulnerability npm audit, repository policy, Markdown links,
  YAML lint, and whitespace checks passed.
- P5.1 commit: `b2adc3e`; Application CI run 30816437847 and Repository Policy
  run 30816437457 passed.
- P5.2 prerequisite migration `0052` adds a default-false core eligibility flag
  and bounded read-only candidate RPC. It requires an explicit true value in
  the effective published CARD snapshot and returns only migration `0050`
  detail projections; direct grants and write paths remain unchanged.
- Migration `0052` local validation: clean replay of all 52 migrations; 21
  pgTAP files / 523 assertions; warning/error database lint; regenerated typed
  schema contract; repository policy; Markdown links; YAML; and whitespace
  checks passed.
- Migration `0052` commit: `075c531`; Database CI run 30817298193,
  Application CI run 30817297971, and Repository Policy run 30817297958
  passed.
- P5.2 delivery: the bilingual server-rendered guest journey captures a required
  goal, bounded monthly category spending, optional salary/fee constraints, and
  explicit fixed points/miles valuations. It reads only migration `0052`
  candidates and renders deterministic ranks, confidence, top categories,
  reward/fee/net values, reasons, assumptions, publication context, safe empty
  states, and detail links.
- P5.2 local validation: formatting, lint, strict typecheck, 38/38 unit and
  component tests, 7/7 real-Supabase integration tests, production build,
  offline zero-vulnerability npm audit, repository policy, Markdown links,
  YAML lint, and whitespace checks passed.
- P5.2 commit: `1aa0855`; Application CI run 30817868298 and Repository Policy
  run 30817864232 passed.
- P5.3 delivery: authenticated clients can read only their RLS-visible
  recommendation runs and visible results and can save an owned result through
  `user_saved_cards`; guests remain ephemeral and no service-role or direct
  privileged browser write path was introduced.
- P5.3 local validation: formatting, lint, strict typecheck, 42/42 unit and
  component tests, 7/7 real-Supabase integration tests, production build,
  offline zero-vulnerability npm audit, repository policy, Markdown links,
  workflow YAML, and whitespace checks passed. The first sandboxed build was
  denied an internal Turbopack worker port; the identical authorized build
  passed.
- P5.3 commit: `71a1b01`; Application CI run 30822898794 and Repository Policy
  run 30822900731 passed.
- P6.1 delivery: bilingual no-index identity pages provide signup, email
  verification callbacks, login, logout, password recovery/update, session
  validation/refresh, safe same-origin continuation paths, and generic
  non-enumerating error states through the typed Supabase SSR/browser clients.
- P6.1 local validation: formatting, lint, strict typecheck, 50/50 unit and
  component tests, 9/9 real-Supabase integration tests, production build,
  offline zero-vulnerability npm audit, repository policy, Markdown links,
  workflow YAML, and whitespace checks passed. The first sandboxed build was
  denied an internal Turbopack worker port; the identical authorized build
  passed.
- P6.1 commit: `42acb5c`; Application CI run 30823715981 and Repository Policy
  run 30823716128 passed.
- P6.2 prerequisite migration `0053` backfills and provisions exactly one
  minimal default `user_profiles` row for each auth user through a hardened
  internal trigger. It copies no auth metadata, grants no runtime execution or
  profile insert privilege, and preserves owner RLS/protected fields.
- Migration `0053` local validation: clean replay of all 53 migrations; 22
  pgTAP files / 538 assertions; warning/error database lint; repository policy;
  Markdown links; workflow YAML; and whitespace checks passed.
- Migration `0053` commit: `f1d4531`; Database CI run 30824648050 and
  Repository Policy run 30824648182 passed.
- P6.2 delivery: a protected bilingual no-index account route provides profile
  updates, collection creation, saved-card listing/removal, and read-only
  engine-owned comparison history. Published card detail can save or restore a
  minimal allowlisted snapshot to Favorites through the authenticated session;
  no service-role client or comparison-engine write was added.
- P6.2 local validation: formatting, lint, strict typecheck, 53/53 unit and
  component tests, 10/10 real-Supabase integration tests, production build,
  offline zero-vulnerability npm audit, repository policy, Markdown links,
  workflow YAML, and whitespace checks passed. The first sandboxed build was
  denied an internal Turbopack worker port; the identical authorized build
  passed.
- P6.2 commit: `a0df930`; Application CI run 30825461049 and Repository Policy
  run 30825461124 passed.
- P6.3 delivery: the protected account route exposes bounded, visible,
  owner-RLS recommendation history and bilingual lifecycle disclosure. Saved
  item removal remains an active-item lifecycle; engine/audit history remains
  read-only under governed backend retention, and the UI does not claim an
  unavailable deletion-request workflow.
- P6.3 local validation: formatting, lint, strict typecheck, 53/53 unit and
  component tests, 10/10 real-Supabase integration tests, production build,
  offline zero-vulnerability npm audit, repository policy, Markdown links,
  workflow YAML, and whitespace checks passed.
- P6.3 commit: `fd0a61b`; Application CI run 30826150480 and Repository Policy
  run 30826150439 passed.
- Database completion commit: `ed2b6c5` (migration `0051`).
- Migration `0050` Database CI: success, run 30801523652.
- Migration `0050` Repository Policy: success, run 30801523667.
- Migration `0051` Database CI: success, run 30809941780.
- Migration `0051` Repository Policy: success, run 30809941903.
- Migration `0051` local validation: clean replay of all 51 migrations; 20
  pgTAP files / 506 assertions; warning/error database lint; repository policy;
  Markdown links; workflow YAML; and whitespace checks passed. Its 39 new
  assertions cover grants/function hardening, anonymous/authenticated reads,
  effective/future/expired/scheduled windows, drafts/rejection, reward filters,
  sorting, pagination, RLS isolation, suspension, rollback, and archival.
- Open PRs: Dependabot #7–#9 and #15; none blocks direct-to-main execution.

## Phase 6 completion review

- **Architecture and schema:** Supabase SSR/browser clients remain the single
  identity boundary. Migration `0053` closes the profile bootstrap gap with no
  new table, while account data uses typed repositories over existing owner
  RLS. Engine-owned recommendations/comparisons remain read-only.
- **Security and privacy:** callbacks accept only local continuation paths;
  private pages are server-authenticated and no-indexed; errors do not enumerate
  accounts; runtime clients never receive service-role credentials. Profile,
  collection, saved-card, comparison, and recommendation reads are owner
  isolated. Minimal saved snapshots contain only public fields.
- **Performance and resilience:** account reads run in bounded parallel queries
  (100 saved cards, 50 comparisons, 50 recommendation runs). Empty states avoid
  dependent result queries, and failures use generic non-sensitive messages.
- **UX and accessibility:** signup, login, recovery, profile, saved items, and
  history are bilingual and RTL/LTR capable, use semantic native controls,
  explicit labels/status regions, keyboard focus styles, and honest empty and
  lifecycle states.
- **Testing and documentation:** 53 unit/component and 10 real-Supabase
  integration tests pass, plus 538 database assertions. Auth session lifecycle,
  recovery non-enumeration, profile provisioning, cross-user isolation, saved
  item wiring, safe redirects, and history presentation are covered.
- **Technical debt:** no Blocking Phase 6 issue remains. User-facing deletion
  requests and engine-run creation are not authorized by the present schema;
  the UI states that limitation rather than adding unsafe writes. A governed
  deletion-request workflow requires a future approved requirement and policy.

## Phase 5 completion review

- **Architecture and schema:** the deterministic recommendation engine remains
  application-domain code over migration `0052`'s bounded publication-safe
  candidate RPC. P5.3 reuses existing typed RLS tables and adds no migration,
  privileged browser client, duplicated publication logic, or blanket grant.
- **Security and privacy:** guest inputs and results remain ephemeral.
  Authenticated history is ownership-filtered by RLS, requests only visible
  results and explicit columns, and caps run retrieval at 50. Saves use the
  signed-in user identity and the existing collection/result ownership checks;
  service-role credentials remain test/backend-only.
- **Performance and resilience:** candidate retrieval, result ranking, and
  history reads are bounded. Deterministic fixed-point value calculations and
  safe dependency errors remain unchanged, while empty guest/authenticated
  states avoid unnecessary dependent queries.
- **UX and accessibility:** the public recommendation journey remains fully
  bilingual, RTL/LTR responsive, keyboard-native, and transparent about
  reasons, assumptions, confidence, publication context, and limitations.
  Authenticated history/save presentation is intentionally deferred to the
  Phase 6 identity shell rather than exposing an incomplete sign-in path.
- **Testing and documentation:** 42 unit/component and 7 real-Supabase
  integration tests pass. Persistence tests cover guest ephemerality,
  authenticated mapping, bounded visible-result reads, authentication denial,
  and ownership-protected save payloads; existing database tests retain the
  cross-user RLS evidence.
- **Technical debt:** no Blocking Phase 5 debt remains. Recommendation-run
  creation is still a trusted backend responsibility by schema design; the
  browser does not receive an unsafe substitute. Phase 6 owns identity UI,
  saved-item presentation, and user lifecycle behavior.

## Phase 4 completion review

- **Architecture and schema:** comparison and calculation remain pure
  application features over migration `0050`'s publication-safe detail RPC;
  no migration, direct table access, privileged client, or duplicated
  publication logic was introduced.
- **Security and privacy:** guest calculations use shareable bounded query
  inputs and store no spending profile or personal data. Existing RLS and
  grants are unchanged, and malformed numeric or slug inputs fail closed.
- **Performance and numeric correctness:** selection is bounded to one detail
  lookup and 50 options. BigInt fixed-point arithmetic prevents binary-float
  money corruption; category splitting cannot multiply a shared rule cap, and
  every public numeric result is finite and bounded.
- **UX and accessibility:** comparison and calculator journeys are bilingual,
  RTL/LTR responsive, server-rendered, keyboard-native, shareable, and expose
  formulas, publication context, assumptions, exclusions from value, empty
  states, and partial-rule limitations.
- **Testing and documentation:** 33 unit/component and 6 real-Supabase
  integration tests pass. Edge-oriented combinations cover NaN, infinities,
  negatives, maxima, determinism, caps, rounding, minima, and halala precision;
  authoritative status documents match the delivered behavior.
- **Technical debt:** no Blocking Phase 4 debt remains. Published tier details
  and transaction/day evidence are unavailable through the current safe read
  interface, so those cases correctly return zero with disclosure rather than
  inventing value. Production-scale usability evidence remains a later phase
  gate.
- Migration 0050 local validation: clean replay of all 50 migrations; 19 pgTAP
  files / 467 assertions; warning/error database lint; repository policy;
  Markdown links; workflow-equivalent YAML lint; and whitespace checks passed.
  The 41 new assertions cover anonymous/authenticated reads, draft and
  unpublished rejection, effective windows, suspension, republish, rollback,
  archival, RLS isolation, grants, and `SECURITY DEFINER` safety.
- P2.1: repository policy, Markdown links, workflow-equivalent YAML lint, and
  whitespace checks passed locally; Repository Policy run 30522625364 passed.
- P2.2 local validation: format, lint, strict typecheck, 2/2 unit assertions,
  production build, zero-vulnerability npm audit, repository policy, Markdown
  links, YAML lint, and whitespace checks passed. Arabic/English routes,
  RTL/LTR document metadata, locale switching, 390px no-overflow behavior, and
  clean browser console were verified locally.
- P2.2 CI: Application CI run 30523741008 and Repository Policy runs
  30523740892 / 30523779594 passed. The GitHub connector published the complete
  tree atomically after the HTTPS OAuth token rejected workflow-file creation;
  local and remote histories were reconciled without rewriting either side.
- P2.3 local validation: format, lint, strict typecheck, 11/11 unit assertions,
  production build, zero-vulnerability npm audit, repository policy, Markdown
  links, YAML lint, and whitespace checks passed. Production-mode smoke tests
  returned health 200, unconfigured readiness 503, propagated correlation IDs,
  no-store responses, and the configured security headers.
- P2.3 CI: Application CI run 30524273922 and Repository Policy run
  30524273965 passed at `b48eb61`.
- P2.4 local validation: formatting, lint, strict typecheck, 14/14 unit tests,
  4/4 local-Supabase integration tests, production build, zero-vulnerability
  npm audit, repository policy, Markdown links, YAML lint, and whitespace
  checks passed. The integration suite replays the real schema, seeds with a
  local-only service-role client, and verifies publication filtering and RLS
  through the anonymous role.
- P2.4 delivery: checked-in types cover the complete database contract; all
  Supabase runtime clients are typed; public bank/card repositories expose
  application DTOs with bounded pagination and explicit active/availability/
  publication filters. Application CI run 30525251432 exposed generated
  `supabase/.temp` files to ESLint; forward-fix `7890526` excluded that runtime
  directory from formatting/lint. Application CI run 30525606887 and
  Repository Policy run 30525606736 then passed.
- P3.1 delivery: bilingual semantic navigation, localized metadata and
  alternates, skip link, responsive homepage, working locale links, three
  persona entry URLs per locale, trust principles, and the product disclaimer
  are implemented. Development CSP permits `unsafe-eval` only for the Next.js
  debugger; the production CSP was smoke-tested without it.
- P3.1 validation: formatting, lint, strict typecheck, 16/16 unit tests, 4/4
  local-Supabase integration tests, production build, zero-vulnerability npm
  audit, repository policy, Markdown links, YAML lint, and whitespace checks
  passed locally. Production HTML confirmed English/LTR and Arabic/RTL with
  request/security headers. A 390px in-app browser audit confirmed landmarks,
  stable persona links, localized SEO metadata, and no horizontal overflow.
  The browser safety policy blocked the post-restart 320px repeat; 320px remains
  covered by mobile-first CSS review and the production build, not claimed as a
  second observed browser run. Application CI run 30527138679 and Repository
  Policy run 30527138619 passed.
- P3.2 delivery: the shared bilingual shell now wraps every localized route;
  `/ar/cards` and `/en/cards` render anonymous-RLS-visible banks and published
  cards through the typed repository. Bank and page state use reversible query
  URLs, pages are capped at 12 cards, invalid page input fails to page 1, and
  localized loading, honest empty, and non-sensitive retry states are present.
- P3.2 validation: formatting, lint, strict typecheck, 20/20 unit tests, 4/4
  local-Supabase integration tests, production build, zero-vulnerability npm
  audit, policy, Markdown links, YAML lint, and whitespace checks passed. Live
  production routes against local Supabase returned English/LTR and Arabic/RTL
  empty states under anonymous RLS, including safe invalid query handling.
  Application CI run 30527811656 and Repository Policy run 30527811581 passed.
- P3.3 delivery: `/{locale}/cards/{slug}` reads only migration `0050`'s
  snapshot-based RPC and validates the JSON boundary with Zod. The bilingual,
  responsive detail view covers fees, benefits, reward targets, eligibility,
  loyalty, related published merchants, verified provenance, publication
  version/effective date, official application/terms links, partial-data
  states, localized metadata, and invalid/unpublished 404 behavior. Unsafe URL
  schemes are never rendered as links.
- P3.3 local validation: formatting, lint, strict typecheck, 22/22 unit and
  component tests, 4/4 real-Supabase integration tests, production build,
  zero-vulnerability npm audit, repository policy, Markdown links, YAML lint,
  and whitespace checks passed. The first sandboxed build was denied an
  internal Turbopack worker port; the authorized identical rerun passed.
- P3.3 CI: Application CI run 30802355076 and Repository Policy run
  30802355180 passed at `53b39f9`.
- P3.4 delivery: card lists now use only migration `0051`'s snapshot-based RPC.
  Localized search and bank, network, fee, persona, salary, reward-type, and
  minimum-reward filters plus five stable sorts use bounded validated inputs
  and reversible GET URLs. The regenerated database contract and Zod boundary
  reject malformed RPC output.
- P3.4 local validation: formatting, lint, strict typecheck, 23/23 unit and
  component tests, 6/6 real-Supabase integration tests, production build,
  offline zero-vulnerability npm audit, repository policy, Markdown links,
  YAML lint, and whitespace checks passed. English and Arabic URLs restored
  selected reward/sort state; a 390x844 Arabic browser review confirmed RTL,
  localized labels, no horizontal overflow, and no console errors.

## Phase 3 completion review

- **Architecture:** public list and detail repositories use separate bounded
  migration `0051` and `0050` snapshot interfaces. UI code remains isolated
  from database naming through typed application DTOs; no service-role client
  enters runtime code.
- **Security and privacy:** anonymous execution exposes explicit published
  allowlists only. Drafts, governance/audit data, unpublished rewards, and
  internal snapshot keys remain inaccessible; direct RLS/table grants are
  unchanged and inputs are bounded.
- **Performance:** filters and counts execute before pagination, page size is
  capped at 50, ordering has a stable UUID tie-breaker, and the effective
  publication partial index supports the primary list path. Production-scale
  query-plan tuning remains evidence-driven.
- **UX and accessibility:** Arabic/English labels, RTL/LTR direction, semantic
  forms/landmarks, keyboard-native controls, loading/empty/error states,
  reversible URLs, and mobile no-overflow behavior are present. No Blocking
  Phase 3 accessibility issue was found.
- **Testing and documentation:** 23 unit/component and 6 database-backed
  integration tests cover public catalog behavior; migration coverage is 506
  pgTAP assertions. README, architecture, roadmap, status, and generated types
  match the implementation.
- **Technical debt:** no Blocking Phase 3 debt remains. Production-scale query
  plans and staging catalog-content quality remain later operational evidence,
  not reasons to expand Phase 3 scope.

## Phase 2 completion review

- **Architecture and schema consistency:** browser, server, proxy, readiness,
  and catalog repository clients share the generated schema contract. Public
  data is mapped to stable application DTOs; database naming remains isolated
  at the repository boundary. No schema or migration change was introduced.
- **Security:** no privileged key enters application code or browser bundles.
  Public reads use the anonymous role and real RLS, with explicit publication
  checks as defense in depth. The service-role key exists only as ephemeral
  local/CI test setup state. Security headers, safe errors, request IDs, and
  redacted structured logging remain intact.
- **Performance:** catalog reads select explicit columns, use indexed schema
  predicates, deterministic ordering, exact counts, and a maximum page size of
  50. No unbounded application query was found. Query-plan tuning remains
  evidence-driven work once production-scale catalog data exists.
- **UX and accessibility:** the foundation preserves semantic bilingual routes,
  RTL/LTR direction, responsive tokens, locale switching, and a no-overflow
  mobile baseline. Feature-level accessibility and loading/empty/error UI are
  correctly owned by Phase 3 rather than claimed here.
- **Testing and operations:** 14 unit and 4 database-backed integration tests
  pass locally and in Application CI; the production build and repository
  policy pass. Health/readiness behavior was verified in P2.3. Integration CI
  now exercises all 51 migrations and anonymous public RLS before application
  tests.
- **Documentation and technical debt:** README and technical architecture match
  the implemented runtime. No Blocking Phase 2 debt remains. Non-blocking
  runner warnings report Node 20-based action internals being forced onto Node
  24; track upstream action releases and update without expanding P3 scope.

## Blockers and owner-only actions

- The P3.4 reward-filter blocker is resolved and delivered through migration
  `0051`; no owner action remains for Phase 3.
- The P3.3 public-detail authorization blocker is resolved by the explicit
  migration `0050` decision. The application must use
  `get_published_card_detail(text)` and must not introduce a public service-role
  client or direct governance-table reads.
- The HTTPS OAuth credential still lacks GitHub `workflow` scope, but the
  installed GitHub connector is an authorized publishing path for workflow
  changes. No immediate owner action is required for P2.3.
- Deployment credentials, production/staging Supabase project selection,
  domain configuration, and first-admin identity are not present. These become
  owner actions only when Phase 9 needs them; all repository work continues in
  the meantime.
- Existing repository-settings actions remain: branch protection, dependency
  graph/Dependency Review enablement, and optional Claude Review credentials.

## Resume protocol

1. Fetch `origin/main`; verify branch, tree, SHA, CI, and open PRs.
2. Read `AGENTS.md`, `CLAUDE.md`, `docs/PROJECT_MASTER_PLAN.md`, and this file.
3. Validate the recorded state against repository and GitHub evidence.
4. Execute the exact next unfinished milestone without waiting for routine
   confirmation; update this file after delivery.
