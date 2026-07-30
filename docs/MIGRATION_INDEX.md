# Migration Index

Every migration in `supabase/migrations/`, in order, with what it
creates and its current status. Line counts and table lists were
generated directly from the files in this repository, not recalled
from memory — regenerate this table (`wc -l` + a `CREATE TABLE` grep
per file) whenever a migration is added, rather than hand-editing it
out of sync with reality.

| # | File | Lines | Status | Tables created |
|---|---|---|---|---|
| 0001 | `enable_extensions` | 2 | merged | — (`pgcrypto`, `btree_gist`) |
| 0002 | `create_enums` | 99 | merged | — (11 enum types) |
| 0003 | `create_timestamp_function` | 11 | merged | — (`set_updated_at()`) |
| 0004 | `create_reference_tables` | 219 | merged | countries, currencies, merchant_categories, reward_categories, card_networks, loyalty_programs |
| 0005 | `create_banks_and_programs` | 77 | merged | banks, bank_loyalty_programs |
| 0006 | `create_cards` | 146 | merged | cards |
| 0007 | `create_card_fees` | 97 | merged | card_fees |
| 0008 | `create_card_benefits` | 75 | merged | card_benefits |
| 0009 | `create_reward_rules` | 106 | merged | reward_rules |
| 0010 | `create_reward_targets` | 72 | merged | reward_targets |
| 0011 | `create_reward_exclusions` | 192 | merged | reward_exclusions |
| 0012 | `create_reward_redemption_rates` | 230 | merged | reward_redemption_rates |
| 0013 | `create_card_eligibility_requirements` | 335 | merged | card_eligibility_requirements |
| 0014 | `create_card_offers` | 272 | merged | card_offers |
| 0015 | `create_card_insurance_benefits` | 175 | merged | card_insurance_benefits |
| 0016 | `create_card_lounge_benefits` | 358 | merged | card_lounge_benefits |
| 0017 | `create_card_travel_benefits` | 187 | merged | card_travel_benefits |
| 0018 | `create_card_dining_benefits` | 325 | merged | card_dining_benefits |
| 0019 | `create_card_installment_plans` | 383 | merged | card_installment_plans |
| 0020 | `create_card_network_benefits` | 111 | merged | card_network_benefits |
| 0021 | `create_card_comparison_profiles` | 225 | merged | card_comparison_profiles |
| 0022 | `create_decision_engine_enums` | 160 | merged | — (enums) |
| 0023 | `create_customer_financial_profiles` | 487 | merged | customer_financial_profiles |
| 0024 | `create_customer_spending_profiles` | 588 | merged | customer_spending_profiles, customer_spending_categories |
| 0025 | `create_customer_preferences` | 579 | merged | customer_preference_profiles, customer_preferences |
| 0026 | `create_eligibility_assessments` | 637 | merged | eligibility_assessments, eligibility_requirement_assessments |
| 0027 | `create_card_value_simulations` | 750 | merged | card_value_simulations, card_value_simulation_components |
| 0028 | `create_recommendation_models` | 1136 | merged | recommendation_models, recommendation_model_factors, recommendation_model_segments |
| 0029 | `create_recommendation_runs` | 253 | merged | recommendation_runs, recommendation_run_cards |
| 0030 | `create_recommendation_results` | 726 | merged | recommendation_results |
| 0031 | `create_recommendation_explanations` | 686 | merged | recommendation_explanations |
| 0032 | `create_recommendation_factor_scores` | 888 | merged | recommendation_factor_scores |
| 0033 | `create_recommendation_feedback` | 1201 | merged | recommendation_interactions, recommendation_feedback |
| 0034 | `create_recommendation_outcomes` | 1200 | merged | recommendation_outcomes |
| 0035 | `create_saved_cards` | 814 | merged | user_card_collections, user_saved_cards |
| 0036 | `create_card_comparisons` | 1779 | merged | card_comparisons, card_comparison_items, card_comparison_criteria, card_comparison_item_scores |
| 0037 | `create_notification_alert_engine` | 2420 | merged | notification_templates, user_notification_preferences, notification_subscriptions, alert_events, notifications, notification_deliveries |
| 0038 | `create_bank_applications` | 3200 | merged | bank_applications, bank_application_documents, bank_application_events, bank_application_tasks, bank_application_decisions, bank_application_integrations |
| 0039 | `create_bank_partnerships_and_referrals` | 2853 | merged | bank_partnerships, bank_partner_products, referral_links, referral_attributions, commission_rules, commission_accruals, commission_settlements, commission_settlement_items |
| 0040 | `create_audit_governance_and_compliance` | 4250 | merged | governance_controls, governance_control_assessments, audit_events, approval_requests, approval_decisions, consent_records, data_classification_rules, data_retention_policies, data_retention_executions, legal_holds, legal_hold_items, data_access_logs, data_export_requests, compliance_cases, compliance_case_events |
| 0041 | `create_security_and_access_control` | 961 | merged | — (0 new tables; enables RLS + grants across all 85 prior tables) |
| 0042 | `create_user_profiles_and_platform_roles` | 921 | merged | user_profiles, platform_roles, platform_permissions, platform_role_permissions, user_platform_role_assignments |
| 0043 | `create_feature_flags` | 275 | merged (PR #4) | feature_flags |
| 0044 | `create_api_management` | 373 | merged (PR #12) | api_clients, api_keys, api_scopes, api_client_scope_assignments, api_rate_limit_policies, api_client_rate_limit_assignments |
| 0045 | `create_background_jobs` | 1036 | merged (PR #14) | background_job_definitions, background_job_schedules, background_job_executions |
| 0046 | `create_catalog_source_provenance` | 588 | merged | catalog_source_provenance |
| 0047 | `create_merchants` | 1072 | merged | merchants, merchant_aliases, merchant_relationships, merchant_category_assignments, merchant_market_presence, merchant_domains |
| 0048 | `create_catalog_publication_governance` | 379 | merged | catalog_publication_versions, catalog_publication_requests, catalog_publication_events |
| 0049 | `create_catalog_admin_authorization` | 720 | merged | catalog_administrator_scope_assignments |

**Database Phase total:** 49 migrations, 111 tables, 34,629 lines.

## `0042` revision note

The version of `0042` merged into `main` (PR #2) was corrected from its
original draft: `user_platform_role_assignments.scope_type` accepts
`PLATFORM` only (enforced by `chk_user_platform_role_assignments_scope`),
where the original draft also accepted `COUNTRY`/`BANK`/
`FUNCTIONAL_AREA` values that the authorization functions never
evaluated. See `docs/DATABASE_ROADMAP.md` for why, and
`docs/SECURITY_MODEL.md` for the verification. `0042` also ships with
test coverage (`supabase/tests/database/0042_*_test.sql`, 23 pgTAP
assertions) and an operational runbook
(`docs/BOOTSTRAP_PLATFORM_ADMIN.md`) — neither existed when the
migration was first drafted.

## Dependency notes for future migrations

- Every migration through `0041` applies cleanly and in strict numeric
  order against an empty database — verified by live execution, not
  just static review.
- `0041` depends on all 85 prior tables existing (it enables RLS and
  grants against every one of them by name) — it cannot be reordered
  earlier.
- `0042` depends on `auth.users` (Supabase-provided, not created by any
  migration in this repository) and on `audit_events` (`0040`) for its
  audit trigger.
- No migration in `0001`–`0044` uses `DROP TABLE`, `DROP COLUMN`, or
  `TRUNCATE`. If a future corrective migration needs to remove
  something, that would be the first destructive operation in this
  repository's history — treat it with proportionate caution and
  document the decision.
- `0043` depends on `0042`'s `PLATFORM_ADMINISTRATOR` role and
  `has_active_platform_role(text)` authorization function, and on
  `0040`'s `audit_events` table. It adds PLATFORM-wide feature flags
  only; no narrower targeting scope is represented.
- `0044` depends on the same administrator authorization function,
  `0040`'s `audit_events`, `auth.users`, and the `btree_gist` extension
  enabled by `0001`. It stores only API-key SHA-256 digests and excludes
  webhook and gateway implementation concerns.
- `0045` depends on `data_retention_executions` (`0040`),
  `commission_settlements` (`0039`), `audit_events` (`0040`), and
  `0042`'s platform-administrator predicate. Worker lifecycle functions
  are granted only to `service_role`; authenticated administrators use
  a narrow cancellation helper and cannot directly mutate executions.
- `0046` depends on `banks` (`0005`), `cards` (`0006`), `card_fees`
  (`0007`), `card_benefits` (`0008`), `reward_rules` (`0009`),
  `loyalty_programs` (`0004`), and `card_eligibility_requirements`
  (`0013`) as the seven eligible provenance target tables, on
  `audit_events` (`0040`) for its audit trigger, and on `0042`'s
  `has_active_platform_permission('CATALOG_MANAGE')` predicate (held by
  both `CATALOG_ADMINISTRATOR` and `PLATFORM_ADMINISTRATOR`) for its RLS
  policies. It adds one table, no new roles, and does not implement
  catalog publication approval.
- `0047` depends on `countries` (`0004`) and `merchant_categories`
  (`0004`, reused rather than duplicated), `auth.users`, `audit_events`
  (`0040`) for its audit trigger, and `0042`'s
  `has_active_platform_permission('CATALOG_MANAGE')` predicate for its
  RLS policies. It also extends `catalog_source_provenance` (`0046`)
  forward-compatibly, purely via `ALTER TABLE`/new triggers — adding a
  `merchant_id` column, widening the `target_entity_type` and
  `target_match` CHECK constraints to accept `'MERCHANT'`, and converting
  `target_entity_id` from a `GENERATED ALWAYS AS (...) STORED` column to
  one maintained by a new trigger — without editing the immutable `0046`
  migration file or any of its existing rows, indexes, or behavior for
  its seven original entity types. It adds six tables and no new roles,
  and does not implement offers, publication governance, scraping,
  transaction ingestion, or automated/fuzzy merchant matching.
- `0048` depends on all eight typed catalog targets supported by `0046`/`0047`,
  the generic `approval_requests` and `approval_decisions` tables and
  `audit_events` from `0040`, `auth.users`, `btree_gist`, and `0042`'s
  `CATALOG_MANAGE` predicate. It reuses the generic approval engine, adds
  three RLS-enabled publication-governance tables, and deliberately does not
  add roles, permissions, or resource-scoped administrator assignments; those
  remain migration `0049` scope.
- `0049` depends on `0042`'s platform roles, permissions, and role assignments;
  `0046`'s typed provenance targets; `0047`'s GLOBAL merchant catalog; and
  `0048`'s publication tables and controlled workflow functions. It adds an
  explicit GLOBAL/BANK scope assignment linked to a CATALOG_ADMINISTRATOR role
  assignment, keeps PLATFORM_ADMINISTRATOR global, makes legacy unscoped
  catalog assignments fail closed, and replaces the interim authorization
  policies/functions across `0046`–`0048`. It adds no direct write grant to
  the earlier core catalog tables.
