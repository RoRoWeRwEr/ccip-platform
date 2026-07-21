# CCIP Platform — Codex Instructions

## Project

This repository contains the Credit Card Intelligence Platform.

The database is PostgreSQL.

## Migration sequence

Completed migrations are currently 0001 through 0040.

The next migration is:

0041_create_security_and_access_control.sql

Before creating any migration:

1. Inspect all existing migrations.
2. Confirm the exact migrations directory.
3. Follow the repository's established SQL and naming conventions.
4. Preserve compatibility with every previous migration.
5. Never skip, duplicate, rename, reorder, or modify completed migrations.
6. Never invent schemas, tables, columns, enums, functions, or dependencies.
7. Create only one migration per task.
8. Produce complete production-grade PostgreSQL.
9. Do not use placeholders, TODOs, pseudocode, or incomplete SQL.
10. Run all available validation and tests.

## Git workflow

1. Start from the latest main branch.
2. Create a dedicated branch for each migration.
3. Never push directly to main.
4. Review the complete diff.
5. Commit the requested migration.
6. Push the branch and prepare a Pull Request.
7. Stop before starting the next migration.

## Current task

The next migration is:

0041_create_security_and_access_control.sql

Do not create migration 0042 until migration 0041 has been reviewed and merged.
