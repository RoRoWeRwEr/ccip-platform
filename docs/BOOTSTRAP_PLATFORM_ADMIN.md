# Bootstrapping the First Platform Administrator

## Scope

This document covers one operational task: assigning the first
`PLATFORM_ADMINISTRATOR` role after migration `0042_create_user_profiles_and_platform_roles.sql`
has been applied to an environment. It does not cover application setup,
Supabase project provisioning, or any authorization design beyond what
migration 0042 implements today (PLATFORM-scoped role assignments only —
see the migration's comments on `chk_user_platform_role_assignments_scope`
for why resource-scoped authorization is out of scope).

## Why no default administrator is seeded

Migration 0042 seeds the `platform_roles`, `platform_permissions`, and
`platform_role_permissions` catalog tables (the roles that exist and what
each one can do), but it inserts **zero** rows into
`user_platform_role_assignments`. This is intentional: shipping a
default admin account or a hardcoded admin `auth.users` row would mean
every environment built from this migration starts with a known,
guessable privileged identity. That is not an acceptable default for a
platform that will eventually hold customer financial data.

The consequence is that immediately after 0042 is applied, **no
authenticated user holds any platform role**, including
`PLATFORM_ADMINISTRATOR`. The platform has zero administrators until
someone deliberately creates the first assignment.

## Why normal authenticated users cannot self-assign a role

`user_platform_role_assignments` has row-level security enabled. Its
`INSERT` policy (`identity_administrator_create_user_role_assignments`)
requires the inserting session to already satisfy
`public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE')`.
Because nobody holds that permission before the first assignment exists,
this is a closed loop by design: an ordinary `authenticated` session —
including one belonging to a legitimate future administrator before
their first assignment — cannot grant itself or anyone else a role
through the normal application API. This was verified directly: an
`authenticated` session with no existing role assignment that attempts
to insert its own `PLATFORM_ADMINISTRATOR` assignment has that insert
silently rejected by the `WITH CHECK` clause (zero rows written, no
error raised).

The only role capable of writing to `user_platform_role_assignments`
without satisfying that policy is `service_role`, which carries
`BYPASSRLS` and is meant only for trusted, server-side, non-end-user
contexts (migrations, admin tooling run by a human operator, or a
backend service you control — never a browser or mobile client).

## Bootstrap must happen through a trusted administrative context

"Trusted administrative context" means one of:

- The Supabase Studio **SQL Editor** for the target project, authenticated
  as a project owner/admin.
- A `psql` (or equivalent) session connected with the project's
  **service role** / direct database credentials, run from a secure
  operator machine or CI job — never from application code that a client
  can influence.

It must **not** be performed by calling an application API endpoint,
even an "admin" one, unless that endpoint itself is already gated by a
trusted secret that is not reachable by ordinary users.

## Step 1 — Identify the target `auth.users` UUID

The person being bootstrapped as the first administrator must already
have signed up through Supabase Auth (email/password, OAuth, magic
link — whichever the application uses), so a row for them exists in
`auth.users`. Find their UUID by email, in the same trusted SQL context:

```sql
SELECT id, email, created_at
FROM auth.users
WHERE email = 'the-intended-administrator@example.com';
```

Confirm the row returned is the correct, intended person before
proceeding — this step is why bootstrap cannot be automated blindly.
This document intentionally does not include a real email address or
UUID; substitute your own values when you run this.

## Step 2 — Assign `PLATFORM_ADMINISTRATOR`

Run this as `service_role` (or an equivalent trusted context that
bypasses RLS), substituting the UUID found in Step 1:

```sql
INSERT INTO public.user_platform_role_assignments (user_id, role_id)
SELECT
    '<TARGET_AUTH_USERS_UUID>'::uuid,
    id
FROM public.platform_roles
WHERE role_code = 'PLATFORM_ADMINISTRATOR';
```

This is the minimum statement needed. The migration's trigger
(`manage_user_role_assignment_change`) fills in `assigned_at` and, when
run as `authenticated`, `assigned_by_user_id`; when run as a role other
than `authenticated` (i.e. the trusted bootstrap context described
above), `assigned_by_user_id` is left null, which correctly reflects
that this specific assignment was made outside normal application
authorization rather than by another administrator. `scope_type`
defaults to `PLATFORM` and does not need to be set explicitly — it is
the only value the schema currently accepts.

The insert also fires `audit_platform_authorization_change`, so the
bootstrap action itself is recorded in `public.audit_events` with
`event_category = 'AUTHORIZATION'` and `event_action = 'CREATE'`.

## Step 3 — Verify the assignment

```sql
SELECT
    assignment.id,
    assignment.user_id,
    role.role_code,
    assignment.scope_type,
    assignment.valid_from,
    assignment.valid_until,
    assignment.revoked_at
FROM public.user_platform_role_assignments AS assignment
JOIN public.platform_roles AS role ON role.id = assignment.role_id
WHERE assignment.user_id = '<TARGET_AUTH_USERS_UUID>'::uuid;
```

Confirm exactly one row, `role_code = 'PLATFORM_ADMINISTRATOR'`,
`scope_type = 'PLATFORM'`, `revoked_at IS NULL`, and `valid_until IS NULL`
(or a future timestamp, if you intentionally granted a time-limited
bootstrap window — see Step 4).

You can also verify functionally, as the bootstrapped user (via the
application, once signed in), that:

```sql
SELECT public.has_active_platform_role('PLATFORM_ADMINISTRATOR');
-- expected: true
```

## Step 4 — Revoking or expiring the assignment

Once at least one administrator exists, all further role management —
including correcting or removing the bootstrap assignment itself —
should go through the normal authenticated path (any holder of
`IDENTITY_ACCESS_MANAGE` can do this through the application or SQL
editor), not repeated manual service-role intervention.

To revoke immediately:

```sql
UPDATE public.user_platform_role_assignments
SET revoked_at = now(),
    revocation_reason = 'Describe why this assignment is being revoked.'
WHERE id = '<ASSIGNMENT_ID>'::uuid
  AND revoked_at IS NULL;
```

To grant a time-limited bootstrap window instead of an indefinite
assignment (useful when bootstrapping a temporary operator rather than
a permanent administrator), set `valid_until` at insert time in Step 2:

```sql
INSERT INTO public.user_platform_role_assignments
    (user_id, role_id, valid_until)
SELECT
    '<TARGET_AUTH_USERS_UUID>'::uuid,
    id,
    now() + interval '7 days'
FROM public.platform_roles
WHERE role_code = 'PLATFORM_ADMINISTRATOR';
```

`has_active_platform_role` and `has_active_platform_permission` both
stop treating the assignment as active once `valid_until` passes, with
no further action required.

## Handling credentials

- Never commit a service-role key, database password, connection
  string, or JWT to this repository, to a commit message, or to any
  file — including scratch files — inside `supabase/`.
- Never paste a real `auth.users` UUID, email address, or production
  project URL into an issue, PR description, or this document. The
  examples above use placeholders (`<TARGET_AUTH_USERS_UUID>`,
  `example.com`) intentionally; keep it that way when this document is
  updated.
- Service-role credentials belong in your platform's secret manager or
  the Supabase project's own dashboard access controls, not in
  environment files checked into git.

## Environment order

Perform this bootstrap procedure in a **local or staging** Supabase
project first, and confirm Steps 3 and 4 both behave as expected there,
before performing it against production. Migration 0042 has not yet
been exercised against a real Supabase Local stack from this repository
(see the audit notes for why) — treat the first local/staging bootstrap
as part of validating the migration itself, not just as an operational
formality.
