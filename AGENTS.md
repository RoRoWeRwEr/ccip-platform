# CCIP Platform — Codex Instructions

## Project

This repository contains the Credit Card Intelligence Platform.

The database is PostgreSQL.

## Migration sequence

Migrations 0001 through 0042 are merged into `main`.

**Migration 0043 must not be started until the prerequisites in
`docs/DATABASE_ROADMAP.md` are met.**

### Historical migrations are immutable once merged

Migrations 0001–0041 are already merged into `main` and deployed from
it. They must never be rewritten, renamed, reordered, or retroactively
edited to fix a problem discovered later — a documented corrective
migration is the only allowed way to change something a merged
migration already did. This rule protects reproducibility: anyone
re-running the migration history from empty must get the same result
every time.

Migration 0042 has merged into `main` and is now subject to the same
immutability rule as 0001–0041.

Before creating any new migration:

1. Inspect all existing migrations.
2. Confirm the exact migrations directory.
3. Follow the repository's established SQL and naming conventions.
4. Preserve compatibility with every previous migration.
5. Never skip, duplicate, rename, reorder, or modify completed
   (merged) migrations.
6. Never invent schemas, tables, columns, enums, functions, or
   dependencies.
7. Create only one migration per task, scoped to a single cohesive
   capability — do not bundle unrelated platform capabilities into one
   migration.
8. Produce complete production-grade PostgreSQL.
9. Do not use placeholders, TODOs, pseudocode, or incomplete SQL.
10. Do not add speculative or partially-implemented logic for
    capabilities (e.g. authorization scopes, resource types) that are
    not yet fully designed — ship only what the migration actually
    implements and enforces.
11. Run all available validation and tests.

## Testing requirement

All future database changes require test coverage before merge —
schema-integrity checks, RLS policy tests, and function-behavior tests
as applicable (pgTAP under `supabase/tests/` is the preferred format).
A migration without accompanying tests is not ready for review.

## Git workflow

1. Start from the latest `main` branch.
2. Create a dedicated branch for each migration or corrective change.
3. Never push directly to `main`.
4. Every database change goes through its own dedicated pull request —
   no direct commits to `main`, no bundling unrelated changes into one
   PR.
5. Review the complete diff before committing.
6. Commit the requested migration (and its tests).
7. Push the branch and prepare a Pull Request.
8. Do not merge without explicit human authorization.
9. Stop before starting the next migration.

## Current task

Migration 0042 is merged into `main`. Migration 0043 has not started —
see `docs/DATABASE_ROADMAP.md` for prerequisites and the validated
0043 onward sequence.
