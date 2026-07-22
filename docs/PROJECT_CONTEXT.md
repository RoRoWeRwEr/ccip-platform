# Project Context

Source of truth for this document: `docs/01-brd/BRD.md` (the repository's
own Business Requirements Document, v1.0, Draft, owner Rayan) and the
current state of `supabase/migrations/` as of this writing. This file
summarizes and orients; `docs/01-brd/BRD.md` is the primary requirements
document and should be read directly for anything this summary omits.

## What CCIP is

The Credit Card Intelligence Platform (CCIP) is a Saudi-focused
platform that helps users discover, compare, evaluate, and maximize
credit card rewards and loyalty programs. It aims to be a trusted
reference for credit cards, rewards programs, offers, benefits, and
recommendation logic — not a bank, not a lender, and not (yet, or
without further explicit scoping) an aggregator of a user's actual
bank accounts or transaction history.

**Primary goal (BRD §2):** provide the most accurate and transparent
credit card intelligence platform in Saudi Arabia.

**No regulatory approval is claimed.** CCIP is designed with an eye
toward eventual operation under Saudi financial regulatory expectations
(see `docs/SECURITY_MODEL.md` for what has actually been built —
audit trails, consent records, data classification, retention policies,
legal holds — and what that does and does not imply about compliance
status). Nothing in this repository or its documentation should be
read as asserting SAMA, PDPL, or any other regulatory sign-off has been
obtained.

## Target users (BRD §3)

General consumers, credit card users, rewards enthusiasts, cashback
users, frequent travelers, and loyalty program members.

## Core value proposition (BRD §4)

Users can explore credit cards, compare cards, calculate rewards,
discover offers, and receive personalized recommendations.

## MVP scope (BRD §5)

**In scope:** credit card database, loyalty program database, reward
rules engine, offer engine, reward calculator, recommendation engine,
merchant database, MCC-based classification. Migrations `0001`–`0021`
build exactly this catalog layer; `0022`–`0034` build the decision/
recommendation engine on top of it.

**Explicitly out of scope for MVP:** budget tracking, personal finance
management, open banking integrations, bank account aggregation,
expense categorization, transaction history storage. No migration in
this repository implements any of these, and none should be added
without a documented decision to expand scope.

## Authentication strategy (BRD §6)

Authentication is optional for MVP; guest users can access the
platform, and registered users may receive additional functionality in
future releases. This is consistent with what's been built at the
database layer: catalog tables (`0004`–`0021`) are readable by `anon`
without authentication (`0041`'s `catalog_read_*` policies), while
anything user-specific (financial profiles, saved cards, applications,
and — pending merge — role-based platform administration in `0042`)
requires an authenticated Supabase user and is isolated per-user by row
-level security.

## Revenue model (BRD §7)

Phase 1: free platform, advertising revenue. Phase 2: premium
subscription ("Pro"). Nothing in the current schema implements billing,
subscriptions, or entitlements — this is a stated future phase, not a
built capability.

## Official data sources (BRD §8)

Only official sources are permitted as input to the catalog: bank
websites, official card terms and conditions, official loyalty
programs, official promotional offers. This is a product/data-
governance rule, not something the database schema enforces
mechanically — `card_offers`, `card_fees`, and related tables have no
`source_ref`-style provenance column as of `0041`/`0042`. If source
provenance needs to be queryable (not just a process rule followed by
whoever enters data), that is a gap for a future migration to close
deliberately, not to retrofit silently.

## Core differentiator (BRD §9)

The recommendation engine — analyzing spending patterns, reward rules,
MCC mappings, loyalty programs, and active offers to identify the most
suitable card for each user. This is the largest single concentration
of schema in the repository: migrations `0022` through `0034` (13
migrations, roughly 9,700 lines) build the decision engine, its models,
runs, results, explanations, factor scores, feedback, and outcomes.
`docs/ARCHITECTURE.md` covers how these tables relate.

## Stated future expansion (BRD §10)

Premium analytics, advanced recommendation models, user profiles,
saved cards, saved calculations, mobile applications, an AI-powered
card advisor. Of these, "user profiles" and "saved cards" are already
substantially built: `user_card_collections` / `user_saved_cards`
(`0035`) and, pending merge, `user_profiles` (`0042`). The rest are not
yet reflected in any migration or roadmap item — see
`docs/DATABASE_ROADMAP.md` before assuming any of them are scheduled.

## What exists today vs. what's aspirational

This repository is, as of this writing, **database-only.** There is no
application, API, admin panel, or frontend code here. Every capability
described above that sounds like a user-facing feature (recommendations,
comparisons, notifications, applications, referrals) exists only as a
PostgreSQL schema with RLS policies — the application layer that would
actually let a person use any of it does not exist in this repository.
Do not describe this project as having a working product surface
without qualifying that clearly.

## Longer-term direction

The BRD's future-expansion list, combined with what's already been
built beyond MVP scope (bank applications, partnerships/referrals/
commissions in `0038`–`0039`, and a full governance/compliance layer in
`0040`), indicates CCIP's ambitions extend past a comparison tool
toward a broader decision-intelligence and bank-partnership platform.
That is a real signal from the schema itself, not speculation — but it
has not been written down as a revised BRD or vision document. If the
product direction has materially expanded beyond BRD v1.0, that
deserves an explicit BRD revision or an ADR in `decisions/`, not just
schema that quietly implies it.
