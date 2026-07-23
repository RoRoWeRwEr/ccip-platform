# Credit Card Intelligence Platform (CCIP)

CCIP is a Saudi-focused platform for discovering, comparing, evaluating,
and recommending credit cards and loyalty programs — built to be a
trusted, transparent reference for credit card rewards, offers,
benefits, and personalized recommendation logic. See
[`docs/PROJECT_CONTEXT.md`](docs/PROJECT_CONTEXT.md) and
[`docs/01-brd/BRD.md`](docs/01-brd/BRD.md) for the full product vision
and business requirements.

## Current implementation status: database-first platform foundation

This repository currently contains **only the database layer**.
Migrations `0001`–`0043` are merged into `main`: 91 tables covering the
card/bank/reward catalog, customer financial and spending profiles, the
recommendation engine, comparisons, notifications, bank applications,
partnerships/commissions, a full governance/audit/compliance layer, and
a platform RBAC/identity model — with row-level security enabled on
every table. Migration `0044` has not started and is blocked until Sprint 0 is complete.

**No application, API, or frontend code exists in this repository yet.**
Anything above that sounds like a user-facing feature (recommendations,
comparisons, notifications, bank applications) exists only as a
PostgreSQL schema with RLS policies — there is no service that lets a
person actually use it. See
[`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) for the current,
factual status of every layer of the platform (database, tests, CI,
security, API, frontend, AI/recommendation, deployment).

## Repository structure

```
CLAUDE.md                    Entry point for any Claude session working in this repo
AGENTS.md                    Equivalent operating rules for Codex/other agents
README.md                    This file
docs/
  PROJECT_CONTEXT.md         What CCIP is, who it's for, MVP scope
  ARCHITECTURE.md            How the schema is organized, dependency order, RLS/role model
  DATABASE_ROADMAP.md        What's merged, what's pending, what's next and why
  SECURITY_MODEL.md          RLS coverage, grants, SECURITY DEFINER usage, audit design, CI validation
  MIGRATION_INDEX.md         Every migration, in order, with what it created
  BOOTSTRAP_PLATFORM_ADMIN.md  How to safely assign the first platform administrator
  PROJECT_STATUS.md          Factual project dashboard across every layer
  AI_AGENT_HANDOFF.md        Canonical startup and session-resume protocol
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
  migrations/                43 merged SQL migrations (0001–0043)
  tests/database/            pgTAP test suite (currently covers migrations 0042–0043)
.github/workflows/
  database-ci.yml            Database CI — see below
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
2. Read [`docs/PROJECT_CONTEXT.md`](docs/PROJECT_CONTEXT.md) for what
   CCIP is and its MVP scope.
3. Read [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for how the
   schema is organized, and [`docs/MIGRATION_INDEX.md`](docs/MIGRATION_INDEX.md)
   for the full migration-by-migration inventory.
4. Read [`docs/SECURITY_MODEL.md`](docs/SECURITY_MODEL.md) for the RLS,
   grants, and `SECURITY DEFINER` model, and what CI does and doesn't
   validate.
5. Read [`docs/DATABASE_ROADMAP.md`](docs/DATABASE_ROADMAP.md) for what
   comes after migration `0043` and why.
6. Read [`docs/BOOTSTRAP_PLATFORM_ADMIN.md`](docs/BOOTSTRAP_PLATFORM_ADMIN.md)
   before assigning the first platform administrator in any environment.
7. Read [`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) for a
   current, factual snapshot of every layer of the project.
8. Read [`docs/AI_AGENT_HANDOFF.md`](docs/AI_AGENT_HANDOFF.md),
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

## Single source of truth

This repository — its migrations, tests, CI configuration, and `docs/`
directory — is the single source of truth for the state of this
project. Do not rely on assumptions carried over from a previous
Claude Project, a previous ChatGPT conversation, another repository,
another Supabase project, or model memory unless those assumptions are
explicitly documented inside this repository. If a task requires
information this repository doesn't contain, say so and ask, rather
than inventing it.
