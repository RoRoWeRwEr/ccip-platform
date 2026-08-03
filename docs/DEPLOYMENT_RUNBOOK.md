# Deployment and Rollback Runbook

This is the repository-owned deployment contract for the CCIP Next.js web
application. It prepares Vercel deployment without selecting a paid plan, data
region, domain, or external account. Those choices and credentials remain
owner-controlled.

## Environment separation and contract

Use independent Supabase projects and independently scoped Vercel environments
for preview, staging, and production. Never point preview or staging builds at
production data.

| Variable | Required | Exposure | Contract |
|---|---:|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Yes | Browser-safe | HTTPS Supabase project URL; HTTP is accepted only for localhost development. |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | Yes | Browser-safe | Publishable key for the matching environment; never substitute a service-role key. |
| `APP_VERSION` | Recommended | Health response and server logs | Immutable commit SHA or release identifier, maximum 100 characters. |
| `LOG_LEVEL` | Optional | Server only | `fatal`, `error`, `warn`, `info`, `debug`, `trace`, or `silent`; defaults to `info`. |

The application does not require a service-role key at runtime. Service-role
credentials are restricted to ephemeral local/CI integration tests and
owner-controlled database operations.

## Deployment preparation

1. Confirm the intended commit is on `main`, the working tree is clean, and all
   required GitHub Actions for that commit are green.
2. Run `npm ci`, the complete validation suite, `npm run build`, and
   `npm run verify:bundle` using the target environment's browser-safe Supabase
   values.
3. Confirm all migrations through `0053` exist in the target Supabase project.
   Never edit or reverse an applied migration; correct database behavior with a
   reviewed forward migration.
4. Configure the environment variables above in the matching Vercel
   environment. Do not paste credentials into source, logs, issues, or command
   output.
5. Deploy the exact commit using `vercel.json`. Record the commit, deployment
   identifier, operator, environment, and UTC time.

## Smoke and observability checks

After deployment, verify:

1. `GET /api/health` returns `200`, `cache-control: no-store`, the expected
   `APP_VERSION`, and an `x-request-id`.
2. `GET /api/ready` returns `200` and a bounded Supabase latency. A dependency
   failure must return `503`, `retry-after: 5`, and no secret or stack detail.
3. `/en` and `/ar` render with the correct direction; catalog, comparison,
   calculator, recommendation, authentication, account protection, and
   administrator protection journeys behave as tested.
4. Server logs contain structured `request_error` events with method and route
   template only. They must not contain cookies, authorization headers, query
   strings, credentials, financial-profile values, or personal data.
5. Alert operational responders when readiness fails for five consecutive
   minutes or server-error rate exceeds 2% for five minutes. These are initial
   operational thresholds to refine from staging evidence, not product SLOs.

## Web rollback

1. Identify the last green deployment and its exact commit.
2. Promote or redeploy that immutable web build in Vercel; do not force-push or
   rewrite `main`.
3. Re-run health, readiness, and critical smoke checks, and record the rollback
   evidence.
4. Fix the defect on `main` with a forward-fix commit before promoting again.

Database migrations are never rolled back by editing history. If a deployed
schema change causes an incident, restrict the affected feature when safely
possible and ship a new forward migration. Catalog content rollback uses the
controlled publication workflow from migration `0048`; it does not bypass RLS
or mutate publication history directly.

## P9.2 credential handoff

Staging deployment requires an owner-provisioned Vercel project and staging
Supabase project, their environment-scoped browser-safe values, and deployment
authorization. Hosting/data-region and legal/privacy choices must be resolved
before staging is treated as launch-ready. P9.2 must record the exact missing
owner actions if these inputs are unavailable and must never commit them.
