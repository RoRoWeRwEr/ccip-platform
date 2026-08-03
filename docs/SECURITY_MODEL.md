# Security Model

Everything in this document was verified, not just read. The original
verification method: applying `0001`–`0042` sequentially against a
real PostgreSQL 16 instance (roles, an `auth.users` stand-in, and a
session-settable `auth.uid()` mimicking Supabase's contract) and
running adversarial queries against the result, plus the pgTAP suite
under `supabase/tests/database/`. Since `0042` merged, `.github/
workflows/database-ci.yml` (Database CI) additionally re-verifies
migration replay, the pgTAP suite, and database linting against the
real `supabase/postgres` image on every PR touching `supabase/
migrations/**` or `supabase/tests/**`, and on every push to `main`
touching `supabase/migrations/**`. Where something could not be
verified in either environment, it's marked explicitly rather than
asserted — see "What CI validates vs. what remains a manual procedure"
below.

## RLS coverage

Row-level security is enabled on **every merged table in the schema** —
111 tables total: 85 as of `0041`, plus the 5 tables `0042` adds, the
one table added by `0043`, the 6 tables added by `0044`, the 3 tables
added by `0045`, the 1 table added by `0046`, the 6 tables added by
`0047`, the 3 tables added by `0048`, and the 1 table added by `0049`.
Migration `0043` enables RLS on its
`feature_flags` table in the same migration. This is enforced in one
disciplined pass in `0041`
for everything that existed at that point, and per-table in `0042` for
what it adds. There is no table in this schema without RLS enabled. If
a future migration adds a table and forgets RLS, that is a regression
from an otherwise perfect record — the `01_rls_enabled`-style check
pgTAP tests should include this as a standing assertion in the pgTAP
suite that Database CI now runs on every relevant PR and push to
`main` (see `docs/DATABASE_ROADMAP.md`).

Migration `0045` adds three RLS-enabled background-job tables.
Authenticated platform administrators can manage definitions and
schedules and read executions, but receive no direct execution
mutation grant. Enqueueing, scheduling materialization, leasing,
heartbeats, completion, failure, cancellation acknowledgement, and
lease reaping remain service-role-only. The sole authenticated
execution mutation surface is a `SECURITY DEFINER` cancellation helper
that independently verifies the active administrator role.

Migration `0046` adds one RLS-enabled table,
`catalog_source_provenance`. Only authenticated callers holding the
existing `CATALOG_MANAGE` permission (held by both `CATALOG_
ADMINISTRATOR` and `PLATFORM_ADMINISTRATOR` since `0042`) may `SELECT`,
`INSERT`, or `UPDATE`; no authenticated caller receives `DELETE`, and
`anon` receives no grant on the table at all. `service_role` retains
full CRUD for corrective actions and future ingestion processes. Target
validation is enforced by real foreign keys and a `CHECK` constraint —
not by RLS or application code — so it holds even for `service_role`
writes.

Migration `0047` adds six RLS-enabled tables (`merchants`,
`merchant_aliases`, `merchant_relationships`,
`merchant_category_assignments`, `merchant_market_presence`,
`merchant_domains`). Writes on all six require the same `CATALOG_MANAGE`
permission as `0046`. Unlike `0046`, all six also grant `anon` and
`authenticated` `SELECT` — merchants are public catalog data like banks
and cards, not internal provenance evidence — scoped to `lifecycle_
status = 'ACTIVE'` merchants (and, for the five child tables, to rows
whose parent merchant is `ACTIVE`, plus the child row's own `is_active`
flag where present), matching the `catalog_read_active_*` pattern
established in `0041`. No authenticated caller receives `DELETE` on any
of the six tables; `service_role` retains full CRUD. Migration `0047`
also extends `catalog_source_provenance` (`0046`) with a `merchant_id`
column and widened `CHECK` constraints — purely additive `ALTER TABLE`
statements against an existing table, not a new table, so it does not
change the table or RLS-policy count attributed to `0046` above.

Migration `0048` adds three RLS-enabled publication-governance tables.
Authenticated callers with `CATALOG_MANAGE` may create and edit draft
version content and read workflow/history data, but lifecycle changes are
forced through narrowly scoped `SECURITY DEFINER` functions. Anonymous and
unprivileged authenticated callers receive no governance visibility. Domain
history is append-only to authenticated callers, while `service_role` retains
trusted scheduling and corrective access.

Migration `0049` adds one RLS-enabled authorization table,
`catalog_administrator_scope_assignments`. Only active platform
administrators may read, create, or revoke BANK/GLOBAL scopes; ordinary
catalog administrators cannot inspect assignments or grant themselves scope.
Scope-aware policies replace the interim platform-wide management policies on
provenance, merchants, and publication governance. BANK administrators see and
mutate only targets resolved to their bank, while GLOBAL and platform
administrators cover shared resources and every bank. Earlier core catalog
tables receive no new write grant.

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

There are 37 `SECURITY DEFINER` functions in the merged schema through
`0051`: 3 from `0042`, 2 from `0043`, 4 from `0044`, 11 from `0045`,
1 from `0046`, 1 from `0047`, 6 from `0048`, 7 from `0049`, 1 from `0050`,
and 1 from `0051`. The three introduced
by `0042` are:

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

Migration `0043` adds two narrowly scoped
`SECURITY DEFINER` functions: `is_feature_enabled(text, text)` exposes
only a boolean decision to runtime callers while RLS hides flag
administrative metadata, and `audit_feature_flag_change()` writes to
`audit_events` without granting administrators direct audit-log writes.
Both schema-qualify references, pin `search_path = pg_catalog`, and
document their justification. Its management trigger remains
`SECURITY INVOKER`.

Migration `0044` adds four `SECURITY DEFINER` functions: three expose
narrow API-key, scope, and rate-limit decisions without exposing protected
metadata, while `audit_api_management_change()` writes redacted changes to
the central audit log. Migration `0045` adds 11 tightly allowlisted worker,
scheduler, cancellation, lease-reaping, and audit functions; worker lifecycle
entry points are executable only by `service_role`, while authenticated users
receive only the independently authorized cancellation entry point. All 15
functions schema-qualify references, pin `search_path = pg_catalog`, and have
documented justifications.

Migration `0046` adds exactly one `SECURITY DEFINER` function,
`audit_catalog_source_provenance_change()`, which writes to
`audit_events` without granting authenticated administrators direct
audit-log writes — the same justification pattern as every prior audit
trigger. Its companion `manage_catalog_source_provenance_change()`
trigger (identity/target-field protection, lifecycle and verification
transition validation, actor/timestamp stamping) remains `SECURITY
INVOKER`, consistent with every other management trigger in the
schema. Both schema-qualify references and pin `search_path =
pg_catalog`.

Migration `0047` adds exactly one `SECURITY DEFINER` function,
`audit_merchant_catalog_change()`, shared by `merchants` and its five
child tables (deriving `entity_type` from `TG_TABLE_NAME` and linking
child-table events to their parent merchant via `audit_events`'
`parent_entity_type`/`parent_entity_id` columns, the same generalization
pattern `0042`'s `audit_platform_authorization_change()` already uses
across four tables) — the same audit-without-direct-write justification
as every prior audit trigger. Its three companion `SECURITY INVOKER`
triggers — `manage_merchant_change()` (identity protection, lifecycle/
verification transitions, actor stamping, mirroring `0046`'s pattern but
with a freely-reversible ACTIVE/INACTIVE toggle), `manage_merchant_
child_change()` (identity protection and actor stamping shared by all
five child tables, plus hierarchy-cycle rejection specifically for
`merchant_relationships`), and `sync_catalog_source_provenance_target_
entity_id()` (maintains `catalog_source_provenance.target_entity_id`
now that it is a plain, trigger-maintained column rather than a
`GENERATED ALWAYS AS (...) STORED` one) — all schema-qualify references
and pin `search_path = pg_catalog`.

Migration `0048` adds six narrowly scoped `SECURITY DEFINER` functions:
`record_catalog_publication_event()` appends publication history and central
audit events; `submit_catalog_publication(...)`,
`decide_catalog_publication(...)`, `publish_catalog_version(uuid)`,
`unpublish_catalog_version(uuid, boolean, text)`, and
`rollback_catalog_version(uuid, uuid, text)` provide the row-locked workflow
boundaries. Each schema-qualifies references, pins `search_path = pg_catalog`,
documents its justification, and has an explicit execute allowlist.

Migration `0049` adds seven `SECURITY DEFINER` functions: one central-audit
trigger plus six scope/target evaluators. Public helpers expose booleans only;
the user-specific and target-resolution helpers needed by publication
assignment validation are internal and not executable by authenticated users.
All seven schema-qualify references, pin `search_path = pg_catalog`, document
their justification, and have explicit execute allowlists.

Migration `0050` adds one stable, read-only `SECURITY DEFINER` function,
`get_published_card_detail(text)`. Definer rights are required only to inspect
0048 publication snapshots and safe verified provenance without granting
callers access to administrative tables. The function pins `search_path` to
`pg_catalog`, schema-qualifies every relation, revokes `PUBLIC`, grants execute
only to `anon`, `authenticated`, and `service_role`, and returns an explicit
public field allowlist. It performs no writes and preserves every existing RLS
policy and table grant.

Migration `0051` adds one stable, read-only `SECURITY DEFINER` function,
`search_published_cards(...)`. It uses the same pinned, schema-qualified,
execute-only boundary as `0050`, but exposes only an allowlisted list payload.
Filters and ordering use effective publication snapshots, reward predicates
require independently published rules, and pagination occurs after filtering.
`PUBLIC` execute and direct catalog/governance table access remain revoked;
there is no write path or RLS change.

Migration `0052` adds `get_published_recommendation_candidates()`, a stable,
read-only `SECURITY DEFINER` function with the same pinned and schema-qualified
hardening. `PUBLIC` is revoked and only `anon`, `authenticated`, and
`service_role` receive execute. It returns at most 50 migration `0050` detail
projections and requires active/available/public core state plus a default-false
core eligibility flag and an explicit true value in the effective published
CARD snapshot. It adds no direct table grant or write path.

**Every application-defined function in the codebase — all 52 migrations,
`SECURITY DEFINER` or not — sets
`SET search_path = pg_catalog`.** No exceptions
found. This is an unusually disciplined baseline; keep it that way. Any
new function that omits this should be treated as a defect, not a
style nit.

## Feature flag administration (0043 merged)

The `feature_flags` table is PLATFORM-only. Authenticated callers
must hold an active `PLATFORM_ADMINISTRATOR` assignment to read, insert,
or update definitions; expired and revoked assignments fail the same
existing role predicate. `anon` receives no table privileges and no
authenticated caller receives `DELETE`. Runtime callers receive only
execute access to the boolean evaluator. Creation identity and
timestamps are protected and stamped by the database, while every
administrative mutation is written to `audit_events`.

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

## What CI validates vs. what remains a manual procedure

Everything above was originally verified against a hand-built
PostgreSQL 16 stand-in for Supabase's platform scaffolding (a minimal
`auth` schema, `anon`/`authenticated`/`service_role` roles, a
session-settable `auth.uid()`), because no Docker daemon was available
in the environment where the pre-merge review was done. The one place
this mattered: `0042`'s `SECURITY INVOKER` trigger functions
(`manage_role_permission_change`, `manage_user_role_assignment_change`,
`manage_user_profile_update`) call `auth.uid()` directly, which
requires `authenticated` to hold `EXECUTE` on `auth.uid()` and `USAGE`
on the `auth` schema — a grant that Supabase's platform bootstrap
provides, not something any migration in this repository sets up
itself.

**This gap is now closed.** `.github/workflows/database-ci.yml`
(Database CI) runs on every PR touching `supabase/migrations/**` or
`supabase/tests/**`, and on every push to `main` touching `supabase/
migrations/**`. It starts the real `supabase/postgres` image
(`supabase start`), replays every migration from empty (`supabase db
reset`), runs the full pgTAP suite (`supabase test db`), and runs
`supabase db lint` at `warning` and `error` level. The CI run against
the `0042` merge commit passed all four steps — migration replay,
pgTAP assertions, and both lint levels — against the real Supabase
local stack, not the hand-built stand-in.

**What CI does not cover, because it is an operational procedure
rather than a schema or test assertion:** the first-platform-
administrator bootstrap procedure documented in
`docs/BOOTSTRAP_PLATFORM_ADMIN.md` has not been manually exercised
end-to-end against a live Supabase project (local, staging, or
production). CI proves the schema, RLS policies, and trigger functions
behave correctly against a real Supabase instance in the abstract; it
does not substitute for a human actually running the bootstrap SQL
against a real project and confirming the result — `docs/
BOOTSTRAP_PLATFORM_ADMIN.md` still recommends doing that in a
local/staging environment before production.

## Standing rule for future changes

Any new table holding user or tenant data must ship with RLS enabled
in the same migration that creates it — not retrofitted later the way
`0001`–`0040` had to be retrofitted in `0041`. Any new `SECURITY
DEFINER` function must document its justification and pin `search_
path` in the same migration. Any new administrative or sensitive-data
mutation should write to `audit_events` via the same trigger pattern
established in `0042`, not a new parallel mechanism.
