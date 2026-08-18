# Credit Card Intelligence Platform (CCIP)

CCIP is a Saudi-focused platform for discovering, comparing, evaluating,
and recommending credit cards and loyalty programs — built to be a
trusted, transparent reference for credit card rewards, offers,
benefits, and personalized recommendation logic. See
[`docs/PROJECT_CONTEXT.md`](docs/PROJECT_CONTEXT.md) and
[`docs/01-brd/BRD.md`](docs/01-brd/BRD.md) for the full product vision
and business requirements.

## Project Objective and Public Value

CCIP helps people understand, compare, and manage credit-card products through
clear, trustworthy, and personalized intelligence. It serves Saudi consumers,
including people new to cards, cashback and rewards users, travelers, and
loyalty-program members. The implemented bilingual experience provides public
discovery and publication-governed card details, comparison and calculation,
deterministic recommendations, authentication and account features, and
scope-governed administration. Private synthetic staging deployment and P9.3
operational verification are complete; Phase 10 and production approval remain
unfinished and must not be presented as complete.

CCIP is decision support, not a bank, lender, credit bureau, or financial
adviser. It does not guarantee savings, eligibility, approval, credit-score
improvement, or any other financial outcome. Product information should come
from official sources, carry provenance and effective-publication context, and
make assumptions, uncertainty, missing data, and recommendation reasons clear.
Personalization must be data-minimizing, consent-aware, secure, and subject to
user control; sensitive data must never be sold or used to make lending
decisions without a separately approved legal, product, and security basis.

The long-term public-value ambition is an accessible Arabic/English service
that helps people compare costs and benefits consistently, understand why an
option may suit their stated needs, and notice when product information has
changed. Progress is measured by verified catalog freshness and provenance,
task completion and comprehension, accessible journey pass rates, explanation
coverage, correction speed, bilingual parity, user trust, and the absence of
material privacy, security, bias, or misleading-outcome incidents. Detailed
strategy and safeguards are in
[`docs/PROJECT_MASTER_PLAN.md`](docs/PROJECT_MASTER_PLAN.md),
[`docs/DEFINITION_OF_DONE.md`](docs/DEFINITION_OF_DONE.md), and
[`docs/RISK_REGISTER.md`](docs/RISK_REGISTER.md).

## Current implementation status: private staging deployed

Migrations `0001`–`0053` complete the current database roadmap: 53 migrations,
111 tables, 22 pgTAP files, and 538 assertions covering the card/bank/reward
catalog, customer financial and spending profiles, the recommendation engine,
comparisons, notifications, bank applications, partnerships/commissions, a
full governance/audit/compliance layer, a platform RBAC/identity model, feature
flags, API-management metadata, background jobs, a catalog source-provenance
layer, a canonical merchant catalog, catalog publication governance, and
explicit BANK/GLOBAL catalog administrator authorization — with row-level
security enabled on every table.

The CCIP v1 application foundation is a Next.js TypeScript web application.
It provides Arabic/English locale routes, RTL/LTR document direction,
responsive design tokens, typed browser/server Supabase clients, checked-in
database types, publication-aware catalog repositories, bounded pagination,
unit and local-Supabase integration tests, production build validation, and
Application CI. The bilingual application includes public catalog discovery
and detail, comparison and calculation, deterministic recommendations,
authentication and user features, and scope-governed administration. Automated
unit, integration, browser, accessibility, security, production-build, and
bundle-budget gates are in place. Deployment readiness and P9.2 private
staging deployment are complete. The protected Vercel Preview runs commit
`626ef83668e59c8bd406b3639b34bb410300db93` in `fra1` against the separate
Frankfurt Supabase staging project using Preview-scoped browser-safe values.
P9.3 verified the owner-approved administrator bootstrap/revocation/reassignment
lifecycle and representative public, user, and administrator journeys. Staging
is limited to synthetic/test data and is not production or compliance approval.
See
[`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) for the current,
factual status of every layer of the platform (database, tests, CI,
security, API, frontend, AI/recommendation, deployment).

Public catalog browsing supports shareable localized-name, bank, network,
annual-fee, persona, minimum-salary, reward-type, and minimum-reward filters,
plus stable list sorting and pagination through migration `0051`'s bounded
publication-aware list/search interface. Migration `0050` remains the
single-card detail interface.

CCIP v1 is **29 of 30 roadmap milestones complete (97%)**. The Phase 10
technical review is complete, but curated catalog, moderated research, and
qualified legal/privacy/SAMA acceptance gates remain. See
[`docs/EXECUTION_STATUS.md`](docs/EXECUTION_STATUS.md) for the authoritative
resume point.

The current regulatory assessment is AI-generated risk analysis, not legal
advice or approval. Private staging is synthetic/test only. Production, real
personal/financial data, application forwarding, bank-document collection,
commissions, paid referrals, and bank integrations remain prohibited pending
formal resolution of applicable legal, privacy, contractual, and SAMA
requirements. See [`docs/DECISION_LOG.md`](docs/DECISION_LOG.md) D-010.

## Repository structure

```
CLAUDE.md                    Entry point for any Claude session working in this repo
AGENTS.md                    Equivalent operating rules for Codex/other agents
README.md                    This file
docs/
  PROJECT_CONTEXT.md         What CCIP is, who it's for, MVP scope
  PROJECT_MASTER_PLAN.md     Authoritative CCIP v1 phases and milestones
  PRODUCT_REQUIREMENTS.md    Testable v1 product requirements and exclusions
  TECHNICAL_ARCHITECTURE.md  Application stack, boundaries, and operations
  DEFINITION_OF_DONE.md      Milestone, phase, and v1 completion gates
  EXECUTION_STATUS.md        Live autonomous-execution ledger and resume point
  ARCHITECTURE.md            How the schema is organized, dependency order, RLS/role model
  DATABASE_ROADMAP.md        What's merged, what's pending, what's next and why
  SECURITY_MODEL.md          RLS coverage, grants, SECURITY DEFINER usage, audit design, CI validation
  MIGRATION_INDEX.md         Every migration, in order, with what it created
  BOOTSTRAP_PLATFORM_ADMIN.md  How to safely assign the first platform administrator
  PROJECT_STATUS.md          Factual project dashboard across every layer
  PROJECT_DASHBOARD.md       Program baseline, health score, critical path, forecast
  DECISION_LOG.md            Verified decisions, assumptions, and owner decision batch
  RISK_REGISTER.md           Active product, delivery, security, and public-value risks
  AI_HANDOFF.md              Governance compatibility entry and no-duplicate-work notice
  AI_AGENT_HANDOFF.md        Canonical startup and session-resume protocol
  CHANGELOG.md               Governance-document change history
  DEVELOPMENT_WORKFLOW.md    Cloud-first issue-to-merge workflow
  BRANCH_PROTECTION.md       Recommended main-branch ruleset
  01-brd/BRD.md              Original business requirements
  03-des/                    Decision-engine specification documents
  04-database/               Historical pre-implementation design drafts (superseded — see below)
  00-overview/, 02-frs/, 05-ui-ux/, 06-admin/, 07-api/, 08-testing/, 09-roadmap/
                             Reserved for future work; currently empty placeholders
decisions/                  Reserved for architecture decision records; currently empty
glossary/                   Reserved for a project glossary; currently empty
supabase/
  migrations/                53 SQL migrations (0001–0053)
  tests/database/            22 pgTAP files / 538 assertions (covers migrations 0042–0053)
src/
  app/                       Next.js App Router and bilingual route foundation
  features/catalog/data/     Typed, RLS-aware public catalog repositories
  lib/                       Shared application modules
  types/database.ts          Generated types for the complete public schema
tests/integration/           Local-Supabase application integration tests
.github/workflows/
  database-ci.yml            Database CI — see below
  application-ci.yml         Application format, lint, types, tests, and build
```

`docs/04-database/ERD-v1.md` and `docs/04-database/postgresql-schema-v1.md`
are historical pre-implementation design drafts. They predate and do not
match the schema actually built in `supabase/migrations/`; each now
carries a banner pointing to `docs/ARCHITECTURE.md` and
`docs/MIGRATION_INDEX.md` for the current, implemented design.

## How to start reading this project

1. Read this file, then [`CLAUDE.md`](CLAUDE.md) (or
   [`AGENTS.md`](AGENTS.md) if you're working as Codex) — both are
   session entry points describing engineering rules and current state.
2. Read [`docs/PROJECT_MASTER_PLAN.md`](docs/PROJECT_MASTER_PLAN.md) and
   [`docs/EXECUTION_STATUS.md`](docs/EXECUTION_STATUS.md) for the active v1
   roadmap and exact next unfinished milestone.
3. Read [`docs/PRODUCT_REQUIREMENTS.md`](docs/PRODUCT_REQUIREMENTS.md),
   [`docs/TECHNICAL_ARCHITECTURE.md`](docs/TECHNICAL_ARCHITECTURE.md), and
   [`docs/DEFINITION_OF_DONE.md`](docs/DEFINITION_OF_DONE.md).
4. Read [`docs/PROJECT_CONTEXT.md`](docs/PROJECT_CONTEXT.md) for what
   CCIP is and its MVP scope.
5. Read [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for how the
   schema is organized, and [`docs/MIGRATION_INDEX.md`](docs/MIGRATION_INDEX.md)
   for the full migration-by-migration inventory.
6. Read [`docs/SECURITY_MODEL.md`](docs/SECURITY_MODEL.md) for the RLS,
   grants, and `SECURITY DEFINER` model, and what CI does and doesn't
   validate.
7. Read [`docs/DATABASE_ROADMAP.md`](docs/DATABASE_ROADMAP.md) for the
   completed Database Phase and explicitly deferred, unscheduled ideas.
8. Read [`docs/BOOTSTRAP_PLATFORM_ADMIN.md`](docs/BOOTSTRAP_PLATFORM_ADMIN.md)
   before assigning the first platform administrator in any environment.
9. Read [`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) for a
   current, factual snapshot of every layer of the project.
10. Read [`docs/AI_AGENT_HANDOFF.md`](docs/AI_AGENT_HANDOFF.md),
   [`docs/DEVELOPMENT_WORKFLOW.md`](docs/DEVELOPMENT_WORKFLOW.md), and
   [`docs/BRANCH_PROTECTION.md`](docs/BRANCH_PROTECTION.md) before
   beginning or publishing a change.

## Database validation

Every PR touching `supabase/migrations/**` or `supabase/tests/**`, and
every push to `main` touching `supabase/migrations/**`, runs
**Database CI** (`.github/workflows/database-ci.yml`), which:

- starts a real Supabase local stack (`supabase start`) against the
  `supabase/postgres` image;
- applies every migration from empty (`supabase db reset`);
- runs the full pgTAP suite (`supabase test db`);
- runs `supabase db lint` at both `warning` and `error` level.

To run the same checks locally (requires Docker and the
[Supabase CLI](https://supabase.com/docs/guides/cli)):

```bash
supabase start
supabase db reset
supabase test db
supabase db lint --level warning
supabase db lint --level error
```

## Application development

The application requires Node.js 22 or newer. Copy `.env.example` to an
untracked `.env.local` and provide the public URL and publishable key for the
target Supabase project. Never expose a service-role key through a
`NEXT_PUBLIC_*` variable.

```bash
npm ci
npm run dev
```

Runtime probes are available at `/api/health` (process health) and `/api/ready`
(validated, time-bounded Supabase readiness). The complete local application
gate is:

```bash
npm run format
npm run lint
npm run typecheck
npm test
npm run test:integration
npm run build
npm audit --audit-level=high
```

`npm run test:integration` requires the local Supabase stack and the URL,
anonymous key, and service-role key emitted by `supabase status -o env`. The
service-role key is test setup/cleanup infrastructure only; repository reads
under test use the anonymous client so public RLS is exercised. Application CI
starts and resets Supabase, supplies those values ephemerally, and runs this
suite on every relevant change.

## Single source of truth

This repository — its migrations, tests, CI configuration, and `docs/`
directory — is the single source of truth for the state of this
project. Do not rely on assumptions carried over from a previous
Claude Project, a previous ChatGPT conversation, another repository,
another Supabase project, or model memory unless those assumptions are
explicitly documented inside this repository. If a task requires
information this repository doesn't contain, say so and ask, rather
than inventing it.
