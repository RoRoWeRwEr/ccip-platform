# CCIP Platform — Claude Instructions

This file is the persistent entry point for any Claude session (Claude
Code, Cowork, or otherwise) working in this repository. It exists so a
new session does not need the full project history re-explained. Read
this file first, then the specific `docs/` file relevant to your task.

This repository currently contains **only the database layer** of the
Credit Card Intelligence Platform (CCIP) — a Saudi-focused platform for
discovering, comparing, evaluating, and recommending credit cards and
loyalty programs. See `docs/PROJECT_CONTEXT.md` for the product vision
and `docs/01-brd/BRD.md` for the original business requirements. No
application, API, or frontend code exists in this repository yet.

## Where things stand right now

- **Merged into `main`:** migrations `0001` through `0041` — 85 tables
  covering the card/bank/reward catalog, customer financial and
  spending profiles, the recommendation engine, comparisons,
  notifications, bank applications, partnerships/commissions, and a
  full governance/audit/compliance layer, with row-level security and
  least-privilege grants retrofitted across all 85 tables in `0041`.
- **Under review, not merged:** migration `0042`
  (`0042_create_user_profiles_and_platform_roles.sql`), on branch
  `codex/0042-user-profiles-platform-roles`. It adds `user_profiles`
  and a platform RBAC model (`platform_roles`, `platform_permissions`,
  `platform_role_permissions`, `user_platform_role_assignments`),
  scoped to `PLATFORM`-wide authorization only.
- **Not started:** migration `0043` onward. Do not begin it until 0042
  is reviewed, tested, and merged — see `docs/DATABASE_ROADMAP.md` for
  what comes after and why the originally proposed 0043–0050 sequence
  needs adjustment before you build it.
- Full inventory with line counts and tables created per migration:
  `docs/MIGRATION_INDEX.md`.

## Non-negotiable engineering rules

These come directly from what has already been verified true of this
codebase (see `docs/SECURITY_MODEL.md` for the evidence behind each):

1. **Merged migrations are immutable.** `0001`–`0041` are deployed from
   `main` and must never be rewritten, renamed, reordered, or
   retroactively edited. A documented corrective migration is the only
   way to change something a merged migration already did. `0042` is
   the sole exception, and only until it merges.
2. **One migration, one cohesive capability.** Do not bundle unrelated
   platform capabilities into a single migration file.
3. **No placeholders.** No TODOs, no pseudocode, no partially-modeled
   capability (e.g. do not add columns or checks for an authorization
   scope, resource type, or feature that isn't fully designed and
   enforced in the same migration — this is exactly what had to be
   corrected in `0042`; see `docs/DATABASE_ROADMAP.md`).
4. **RLS is mandatory on every table holding user or tenant data**, and
   as of `0041` it is enabled on all 90 (85 merged + 5 pending in
   `0042`) tables in this schema — do not add a table without it.
5. **`SECURITY DEFINER` requires justification and a pinned
   `search_path`.** Every function in this codebase that uses it
   documents why in a `COMMENT ON FUNCTION`, and every function —
   `SECURITY DEFINER` or not — sets `SET search_path = pg_catalog`.
   There are currently only three `SECURITY DEFINER` functions in the
   whole schema; that should stay a short, deliberate list.
6. **Every database change needs tests before it's ready for review** —
   pgTAP under `supabase/tests/database/`, following the pattern in the
   four `0042_*_test.sql` files already there (schema/constraint
   checks, RLS positive and negative paths, function-behavior checks,
   audit-trail checks).
7. **One branch, one PR, per change.** Never commit to `main` directly.
   Never merge without explicit human authorization. Never push without
   explicit authorization either, even after committing locally.

## Working style for any new task

1. Read this file, `AGENTS.md`, and whichever `docs/*.md` file is
   relevant to the task.
2. Fetch and report the actual current state of `main` and any
   relevant branch — do not assume what was true in a previous session
   is still true (branches move; this has already happened once in
   this repository's short history).
3. State your understanding of the task and identify risks before
   editing anything.
4. Create or use a dedicated branch.
5. Implement the smallest complete change that satisfies the task —
   do not expand scope into adjacent redesigns unless explicitly asked.
6. Add or update tests alongside the change, not as an afterthought.
7. Run every validation available in the environment (migration
   apply-from-empty, pgTAP suite, syntax validation) and be explicit
   about what could not be run and why (e.g. no Docker/Supabase Local
   available) rather than silently skipping it.
8. Review the complete diff yourself before presenting it.
9. Report every file changed, every command run and its result, tests
   passed, tests not run and why, and remaining risks — honestly, not
   optimistically.
10. Propose a commit message and PR description; do not commit, push,
    or merge without explicit authorization.

## Where to look for what

| Question | File |
|---|---|
| What is CCIP, who is it for, what's in and out of scope | `docs/PROJECT_CONTEXT.md`, `docs/01-brd/BRD.md` |
| How the schema is organized, dependency order, RLS/role model | `docs/ARCHITECTURE.md` |
| What's merged, what's pending, what's next and why | `docs/DATABASE_ROADMAP.md` |
| RLS coverage, grants, `SECURITY DEFINER` usage, audit design, privilege-escalation posture | `docs/SECURITY_MODEL.md` |
| Every migration, in order, with what it created | `docs/MIGRATION_INDEX.md` |
| How to safely assign the first platform administrator | `docs/BOOTSTRAP_PLATFORM_ADMIN.md` |
| Codex-specific operating rules (same substance as this file) | `AGENTS.md` |

## What this repository does not yet have

No CI (`.github/workflows/` does not exist yet), no `decisions/` ADRs,
no `glossary/`, no application/API/frontend layer, and no confirmed
relationship to any other product effort — do not assume one. If a
task requires information this repository doesn't contain, say so and
ask, rather than inventing it.
