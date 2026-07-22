# Security Model

Everything in this document was verified, not just read. The
verification method: applying `0001`–`0042` sequentially against a
real PostgreSQL 16 instance (roles, an `auth.users` stand-in, and a
session-settable `auth.uid()` mimicking Supabase's contract) and
running adversarial queries against the result, plus the pgTAP suite
under `supabase/tests/database/`. Where something could not be
verified in that environment, it's marked explicitly rather than
asserted.

## RLS coverage

Row-level security is enabled on **every table in the schema** — 85
tables as of `0041` (merged), 90 including the 5 tables `0042` adds
(pending merge). This is enforced in one disciplined pass in `0041` for
everything that existed at that point, and per-table in `0042` for
what it adds. There is no table in this schema, merged or pending,
without RLS enabled. If a future migration adds a table and forgets
RLS, that is a regression from an otherwise perfect record — the
`01_rls_enabled`-style check pgTAP tests should include this as a
standing assertion once CI exists (see `docs/DATABASE_ROADMAP.md`).

## Grants

`0041` starts by revoking blanket schema and table access from `anon`
and `authenticated` (`REVOKE ALL ON SCHEMA public FROM anon,
authenticated`, plus matching revokes on tables, sequences, and
function execution, plus matching `ALTER DEFAULT PRIVILEGES` so future
tables don't inherit open access), then grants back narrowly:
`service_role` gets full CRUD (it carries `BYPASSRLS` and is meant only
for trusted server-side contexts); `anon`/`authenticated` get `SELECT`
only on published catalog data; `authenticated` gets `SELECT`/`INSERT`/
`UPDATE` (never `DELETE`) on customer-owned tables, consistent with a
revoke-not-delete audit pattern. `0042` follows the same discipline,
additionally using **column-level** grants on `user_profiles` — a
customer can `UPDATE` only `display_name`, `preferred_language_code`,
`timezone_name`, and `onboarding_status` on their own row; `account_
status` and the lifecycle timestamp columns are excluded from the
grant entirely, so a write attempt fails at the privilege-check level
before RLS or the protective trigger even runs. Verified directly: an
authenticated owner of a profile gets `permission denied for table
user_profiles` attempting to change `account_status` on their own row,
and succeeds updating `display_name`.

## `SECURITY DEFINER` usage

There are exactly three `SECURITY DEFINER` functions in the entire
codebase, all in `0042`:

- `has_active_platform_role(text)` and `has_active_platform_permission
  (text)` — both `STABLE`, both schema-qualify every reference inside
  the body, both `SET search_path = pg_catalog`, both documented via
  `COMMENT ON FUNCTION` with the specific justification ("avoids RLS
  recursion, exposes no row data") required before using `SECURITY
  DEFINER` at all.
- `audit_platform_authorization_change()` — writes to `audit_events`
  regardless of the caller's own grants on that table, which is the
  correct pattern for an audit trail (the caller shouldn't need write
  access to the audit log to have their actions logged). Also pinned
  `search_path`.

**Every function in the codebase — all 42 migrations, `SECURITY
DEFINER` or not — sets `SET search_path = pg_catalog`.** No exceptions
found. This is an unusually disciplined baseline; keep it that way. Any
new function that omits this should be treated as a defect, not a
style nit.

## Privilege escalation

Tested directly and adversarially, not just inferred from reading the
policies:

- An `authenticated` session with no existing role assignment,
  attempting to `INSERT` itself a `PLATFORM_ADMINISTRATOR` assignment
  **with the target role ID supplied directly** (isolating the INSERT
  policy itself from any read-side RLS on `platform_roles`), receives
  `new row violates row-level security policy for table
  "user_platform_role_assignments"`. No escalation path exists.
- The same session attempting to modify `account_status` on their own
  `user_profiles` row is blocked at the grant level (see above), a
  second independent layer behind the trigger-level protection in
  `manage_user_profile_update()`.
- Both checks are now codified as standing regression tests:
  `supabase/tests/database/0042_rls_policies_test.sql`.

## Cross-tenant data exposure

Verified directly: seeding a `customer_financial_profiles` row for one
user (via `service_role`) and querying as a different authenticated
user returns zero rows; querying as the owning user returns exactly
their own row. RLS isolation holds under an actual adversarial query,
not just by policy inspection.

## Scope model — what is and isn't enforced

`user_platform_role_assignments` supports **`PLATFORM` scope only**,
enforced by `chk_user_platform_role_assignments_scope`. `BANK`,
`COUNTRY`, and `FUNCTIONAL_AREA` values are rejected at the constraint
level (`23514 check_violation`), not silently accepted and ignored.
This was a corrected finding — the original draft of `0042` accepted
those three values in the schema while the authorization functions
never evaluated anything but `PLATFORM` scope, meaning a scoped
assignment was structurally possible but functionally inert (it failed
closed — granted nothing — rather than open, so it was never an
escalation risk, but it was a trap for an administrator who believed
scoping worked). See `docs/DATABASE_ROADMAP.md` for why this was
deferred to a future migration rather than completed now.

## Audit integrity

`audit_platform_authorization_change()` fires on every INSERT/UPDATE/
DELETE against `platform_roles`, `platform_permissions`, `platform_
role_permissions`, and `user_platform_role_assignments`, and correctly
derives `event_action` (`CREATE`/`UPDATE`/`REVOKE`/`DELETE`) matching
`audit_events`' own `chk_audit_events_action` constraint, sets `data_
classification = 'CONFIDENTIAL'`, and flags `contains_personal_data =
TRUE` specifically for `user_platform_role_assignments` changes.
Verified: inserting and then revoking an assignment produces exactly
one `CREATE` and one `REVOKE` row in `audit_events`, with `after_
values` populated and `before_values` null on create (and the reverse
shape implied on delete). Test: `supabase/tests/database/0042_audit_
trigger_test.sql`.

## Bootstrap and first-administrator handling

No default administrator is seeded. `0042` seeds `platform_roles`,
`platform_permissions`, and their mappings, but zero rows into
`user_platform_role_assignments` — by design, so no environment built
from this migration starts with a known, guessable privileged
identity. The only path to the first assignment is a trusted
`service_role` (or equivalent) context; see `docs/BOOTSTRAP_PLATFORM_
ADMIN.md` for the exact procedure, verification, and revocation steps.
This is intentional secure-by-default behavior, not a gap — the gap
that existed (no documented procedure) is what that file closes.

## What has not been verified against real Supabase

Everything above was verified against a hand-built PostgreSQL 16
stand-in for Supabase's platform scaffolding (a minimal `auth` schema,
`anon`/`authenticated`/`service_role` roles, a session-settable
`auth.uid()`), because no Docker daemon was available to run `supabase
start` in the environment where this was done. The one place this
matters: `0042`'s `SECURITY INVOKER` trigger functions (`manage_role_
permission_change`, `manage_user_role_assignment_change`, `manage_
user_profile_update`) call `auth.uid()` directly, which requires
`authenticated` to hold `EXECUTE` on `auth.uid()` and `USAGE` on the
`auth` schema — a grant that Supabase's platform bootstrap provides,
not something any migration in this repository sets up itself. This
was replicated in the stand-in based on documented Supabase behavior
and behaves correctly there, but **a real `supabase start` + `supabase
test db` pass is the recommended final check before `0042` merges** to
close this specific gap. Everything else in this document — schema
structure, constraint logic, RLS policy logic, grant logic — does not
depend on Supabase-specific runtime behavior and carries high
confidence without that additional check.

## Standing rule for future changes

Any new table holding user or tenant data must ship with RLS enabled
in the same migration that creates it — not retrofitted later the way
`0001`–`0040` had to be retrofitted in `0041`. Any new `SECURITY
DEFINER` function must document its justification and pin `search_
path` in the same migration. Any new administrative or sensitive-data
mutation should write to `audit_events` via the same trigger pattern
established in `0042`, not a new parallel mechanism.
