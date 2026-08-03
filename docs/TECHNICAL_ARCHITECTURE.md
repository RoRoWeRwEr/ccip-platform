# CCIP v1 Technical Architecture

## System shape

CCIP v1 is a modular monolith: one Next.js TypeScript application provides
server-rendered public pages, interactive client components, route handlers,
authentication callbacks, and privileged server-only orchestration. Supabase
provides PostgreSQL, Auth, RLS, and the controlled database functions already
implemented by migrations `0001`–`0051`.

```text
Browser
  -> Next.js public/user/admin routes
      -> RLS-aware Supabase client (anon or authenticated session)
      -> server-only orchestration where required
          -> controlled PostgreSQL functions and policies
  -> structured application logs and health/readiness endpoints
```

No separate API service, queue, search cluster, or ML service is introduced for
v1 without measured need. Existing database background-job metadata is not a
reason to deploy an idle worker.

## Repository layout target

```text
src/app/                 App Router pages, layouts, route handlers
src/components/          Reusable accessible UI
src/features/            Catalog, comparison, recommendation, auth, admin
src/lib/config/          Validated environment and runtime configuration
src/lib/supabase/        Browser, server, middleware, and privileged clients
src/lib/logging/         Structured logger and request correlation
src/lib/errors/          Typed errors and response mapping
src/lib/validation/      Shared Zod schemas and numeric boundaries
src/types/               Database and application types
tests/                   Unit, integration, fixtures, accessibility
e2e/                     Playwright journeys
supabase/                Immutable database history and pgTAP tests
```

Feature modules expose domain-oriented functions; UI code does not issue ad hoc
queries. Server/client boundaries are explicit. Shared code must not import a
server-only secret or privileged client into browser bundles.

## Data-access model

- Public catalog reads use the Supabase anonymous role and existing public RLS.
- Card-detail reads use migration `0050`'s
  `get_published_card_detail(text)` function. It projects only approved fields
  from currently effective `PUBLISHED` snapshots and never requires a public
  service-role client or direct governance-table access.
- Card-list search, filtering, sorting, and pagination use migration `0051`'s
  `search_published_cards(...)` execute-only snapshot boundary. Reward filters
  run in the database before pagination and never require a service-role client.
- `src/types/database.ts` is the checked-in generated contract for the full
  schema. Supabase browser, server, proxy, readiness, and repository clients
  use that contract instead of untyped queries.
- Public catalog repositories apply explicit active, availability, and
  publication-time filters in addition to RLS, return application-owned DTOs,
  and cap page sizes at 50. The duplicate filtering is intentional defense in
  depth and prevents accidental reliance on privileged-client behavior.
- Application integration tests seed through a local-only service-role client
  and assert reads through an anonymous client against the replayed schema and
  real RLS policies. No service-role credential is available to browser code.
- Authenticated user reads/writes use the user's session so RLS remains the
  primary ownership boundary.
- Catalog administration uses the administrator session and scope-aware RLS or
  controlled functions. Service-role use is limited to narrowly justified,
  server-only operational boundaries that cannot be expressed safely through
  the user session.
- Published-catalog semantics are applied consistently in repository methods;
  previews are available only to authorized administrators.
- Queries select explicit columns, use deterministic ordering and bounded
  pagination, and avoid transferring entire governance/audit records to public
  clients.
- Checked-in generated database types must be regenerated and reviewed when a
  future migration is explicitly approved.

## Authentication and authorization

- Supabase Auth session cookies are managed using the current SSR integration.
- Middleware refreshes sessions but does not serve as the sole authorization
  boundary; server handlers and database RLS recheck access.
- Redirect targets are allowlisted to same-origin application paths.
- `SUPABASE_SERVICE_ROLE_KEY` is never exposed through `NEXT_PUBLIC_*`, browser
  code, logs, tests, or rendered responses.
- BANK/GLOBAL catalog scope is evaluated by migration `0049`; the application
  does not recreate authorization logic with client-supplied bank IDs.
- Publication commands invoke migration `0048` workflow functions and surface
  safe domain errors; they do not update workflow tables directly.

## Internationalization and UI

- Locale-prefixed routes use `ar` and `en`; Arabic is the default product
  locale unless deployment requirements say otherwise.
- Messages are typed and kept in repository-controlled catalogs. Direction,
  number/currency formatting, focus order, and icon orientation respond to
  locale.
- Server rendering supplies useful content without JavaScript where practical.
- Semantic HTML and native controls are preferred; custom interactions include
  keyboard behavior, visible focus, labels, descriptions, and live-region
  handling where necessary.

## Calculation and recommendation boundaries

- Monetary calculations use integer halalas or an explicit decimal library;
  binary floating-point is not used for persisted or user-visible money.
- Inputs are finite, non-negative, bounded, and normalized before evaluation.
- The recommendation engine is a pure deterministic domain module separated
  from database loading and presentation.
- Calculation traces provide assumptions and explanation data. Tests cover
  caps, exclusions, minimum spend, missing data, ties, rounding, and extreme
  boundaries.

## Operations

- `/api/health` proves the application process is responsive without leaking
  configuration. `/api/ready` may perform a bounded dependency check.
- Logs are JSON in deployed environments and include correlation ID, route,
  status, duration, and safe error code; tokens, cookies, credentials,
  financial-profile values, and personal data are redacted.
- Environment validation fails fast for required server values and validates
  public values separately.
- Vercel preview/production deployments use environment-scoped secrets;
  Supabase local/staging/production projects remain separated.
- GitHub Actions run policy, database checks when relevant, application lint,
  typecheck, unit/integration tests, and production build. E2E runs against a
  controlled test environment once its credentials are available.

## Security and failure model

- Default-deny authorization, safe error envelopes, CSP/security headers,
  dependency review, no secret logging, and no trust in client-provided IDs.
- Network/database failures produce bounded timeouts and actionable generic
  user states, not stack traces.
- Cache only public data and include locale/query identity in cache keys; never
  share authenticated responses across users.
- Rate limiting is required before exposing abuse-sensitive authentication,
  recommendation, or administrator mutation endpoints publicly.

## Architecture decision triggers

Create an ADR before introducing a separate backend runtime, privileged worker,
external search/index, paid monitoring vendor, state-management framework,
native app, or a database design that materially changes the approved
architecture. Routine bounded forward migrations authorized by
`docs/AUTONOMOUS_DECISION_POLICY.md` require synchronized roadmap and status
documentation but not a separate ADR. An ADR must show the measured problem,
alternatives, security/operational effects, and rollback path.
