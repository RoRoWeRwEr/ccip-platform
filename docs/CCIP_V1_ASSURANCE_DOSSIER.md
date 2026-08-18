# CCIP v1 Assurance Dossier

> **Point-in-time review notice (updated 2026-08-18):** This dossier preserves
> the independent repository-only assessment made before a staging environment
> existed. P9.2 subsequently completed at deployed commit
> `626ef83668e59c8bd406b3639b34bb410300db93`; the protected Preview,
> health/readiness, bilingual UI, `fra1`, runtime logs, and zero-vulnerability
> build were verified. P9.3 subsequently passed; current progress is 29/30
> (97%), and Phase 10 is next. Use
> `docs/EXECUTION_STATUS.md` for the authoritative live state; unchecked and
> blocking statements below describe the original assurance snapshot unless
> explicitly updated.

**Independent review date:** 2026-08-14  
**Assurance baseline:** `65a5d1d1503f0045c48373f7860e904145eda03e` (`main`, `origin/main`, and local `HEAD`)  
**Review posture:** repository, local synthetic/test execution, and GitHub evidence only; no implementation change, production data, production system, legal opinion, or regulatory approval

## 1. Purpose and evidence boundary

This dossier independently assesses the Credit Card Intelligence Platform
(CCIP) v1 for its owner and prospective technical, security, privacy, legal,
regulatory, banking, and investment reviewers. It separates observed facts,
repository decisions, assumptions, and legal questions. Findings use:

- **Blocking:** prevents staging approval, production use, or the claimed gate.
- **Important:** material risk or evidence gap requiring planned resolution.
- **Suggestion:** beneficial improvement that does not block the current private
  synthetic staging boundary.

The review did not modify migrations, source, configuration, tests,
dependencies, or workflows. No staging or production environment was available.
The local Docker daemon was unavailable, so a fresh migration replay, pgTAP,
database lint, real-Supabase integration suite, and fully data-backed browser
journeys could not be executed. Historical green CI is cited as historical
evidence, not silently substituted for fresh local execution.

## 2. Executive summary

CCIP has a substantial, coherent v1 implementation: bilingual public discovery,
comparison, calculation, deterministic recommendations, authentication/user
features, and scope-governed administration are represented in code and tests.
The architecture is a maintainable typed Next.js modular monolith over Supabase,
with strong database authorization boundaries and unusually detailed governance.

The repository's **27/30 (90%)** statement is justified only as a transparent
milestone-count metric: Database Foundation counts as one milestone, P2.1–P9.1
account for 26 more, and P9.2, P9.3, and Phase 10 remain. It is not a measure of
effort, public value, launch readiness, regulatory compliance, or production
operability. P9.1 has green application and policy CI evidence. P9.2 has not
started because owner-controlled staging inputs do not exist.

**Assurance conclusion:** suitable to proceed to a private, access-controlled,
synthetic/test-only staging deployment after the exact P9.2 input checklist is
satisfied. It is not approved for production or real personal/financial data.
There is no evidence of SAMA approval, a completed Saudi legal/privacy review,
production-region approval, bank contractual approval, deployed observability,
administrator bootstrap, or production-scale behavior.

### Highest-priority findings

| Class | Finding | Assurance consequence |
|---|---|---|
| Blocking | No provisioned private Vercel/Supabase staging environment, scoped deployment authorization, environment values, or verified staging administrator | P9.2/P9.3 cannot be completed or independently verified |
| Blocking | Production legal, privacy, contractual, licensing, data-region, and transfer questions are unresolved | Production and real-data processing remain prohibited |
| Blocking | Application forwarding, document collection, commissions, paid referrals, and bank integrations overlap regulated-adjacent plans without a resolved SAMA perimeter | These capabilities must remain disabled |
| Important | Migrations `0001`–`0041` have no dedicated behavioral pgTAP files | Replay proves syntax/order, but early behavior and negative authorization paths have materially weaker regression evidence |
| Important | A fresh local database/integration/browser pass was environment-blocked; the isolated E2E run was 20/32 because data-dependent pages had no database | Current machine evidence cannot independently reproduce the historical 10 integration + 32 E2E + 538 pgTAP green suite |
| Important | Current governance documents still contain stale `420a886` baseline references after governance commit `65a5d1d` | Readers may misidentify the reviewed delivery, although Git and GitHub state are unambiguous |
| Important | Dependency audit could not reach the npm advisory endpoint; Dependency Review is not evidenced enabled | Current dependency vulnerability status was not freshly established |
| Suggestion | Four open Dependabot Actions PRs (#7–#9, #15) remain | Review and merge separately after normal validation; they do not block synthetic staging today |

## 3. Current phase, progress, and critical path

| Item | Verified assessment |
|---|---|
| Current phase | Phase 9 — Staging and Deployment |
| Current milestone | P9.2 — private staging deployment, not started |
| Completed roadmap count | 27 of 30 milestones |
| Percentage | 90% by milestone count only (`27 / 30`) |
| Remaining | P9.2 deployment; P9.3 operational verification; Phase 10 completion review/report |
| Critical path | Owner provisions isolated staging → deploy exact green commit → health/readiness, critical journeys, admin bootstrap, telemetry and rollback exercise → final Phase 10 review |

The public-value outcomes in the Definition of Done—95% provenance coverage,
90% moderated task completion, bilingual parity, explanation coverage, and
correction responsiveness—are release targets, not achieved outcome evidence.

## 4. Repository and delivery history

- The expected governance commit exists and is the exact reconciled baseline:
  `65a5d1d1503f0045c48373f7860e904145eda03e`.
- `main`, `origin/main`, and local `HEAD` matched after `git fetch origin main
  --prune`; the initial tree was clean.
- The review created only this dossier. Generated `.next` and `test-results`
  content is ignored runtime output, not a proposed repository change.
- Open PRs are Dependabot #7, #8, #9, and #15.
- Latest baseline GitHub evidence: Repository Policy run
  `31812147048` passed for `65a5d1d`.
- P9.1 implementation evidence: `ace16b3`; Application CI run `30836747504`
  and Repository Policy run `30836749288` passed.
- Delivery history is incremental and traceable. Migrations are preserved as
  immutable history; later application-enabling interfaces were added by
  forward migrations `0050`–`0053`.

## 5. Architecture and technology inventory

| Layer | Verified inventory | Assessment |
|---|---|---|
| Web | Next.js 16.2.12 App Router, React 19, TypeScript | Cohesive modular monolith; appropriate for current scale |
| UI/i18n | Locale-prefixed `ar`/`en`, RTL/LTR layout, responsive CSS, semantic components | Strong baseline; staging/manual assistive-technology evidence remains |
| Data/Auth | Supabase PostgreSQL/Auth/RLS, browser and SSR clients, checked-in database types | Database remains the primary trust boundary |
| Validation | Zod environment/input boundaries; bounded catalog pagination | Good fail-fast and abuse-resistant design |
| Calculation | Deterministic domain functions with finite/bounded numeric tests | Appropriate explainable v1 model; not financial advice |
| Observability | Request IDs, structured logger, `/api/health`, bounded `/api/ready` | Repository contract exists; no deployed telemetry evidence |
| Testing | Vitest, Testing Library, local-Supabase integration tests, Playwright/Axe, pgTAP | Broad test taxonomy; historical database coverage is uneven |
| Delivery | Vercel contract, Supabase staging target, GitHub Actions, forward-fix policy | Ready for synthetic staging provisioning, not production |

Maintainability is helped by feature-oriented modules, typed repositories,
pure calculation/recommendation functions, explicit server/browser boundaries,
and immutable migrations. Complexity is concentrated in 35,310 lines of SQL,
111 tables, overlapping governance records, and a long execution ledger.

## 6. Database and migration inventory

| Measure | Independently counted |
|---|---:|
| Migration files | 53 (`0001`–`0053`) |
| SQL lines | 35,310 |
| Tables created | 111 |
| pgTAP files | 22 |
| Planned pgTAP assertions | 538 |
| Dedicated migration test files | `0042`–`0053` only |

The 106 textual `ENABLE ROW LEVEL SECURITY` statements are not a reliable
table count because migration `0041` uses generated iteration for earlier
tables. The stronger evidence is the documented/database-tested assertion that
all 111 tables have RLS after full replay; this review could not freshly replay
that assertion locally.

Observed controls include owner-scoped RLS, BANK/GLOBAL catalog scope,
platform-admin-only scope lifecycle, controlled publication functions,
append-only events/audit integration, execute-only public read functions,
explicit grants, pinned `search_path`, and schema-qualified references in
security-definer boundaries. Migration `0053` revokes caller execution on its
internal bootstrap function. No migration history was changed.

**Important historical gap:** migrations `0001`–`0041` lack dedicated
behavioral suites. Full replay catches ordering and DDL failure but is not equal
to positive/negative tests for every early constraint, grant, policy, audit
path, controlled function, and lifecycle transition.

## 7. Feature and user-journey completion matrix

| Journey | Implementation evidence | Automated evidence | Assurance state |
|---|---|---|---|
| Arabic/English public shell | `/ar`, `/en`, locale layout and messages | Unit + E2E; live desktop/mobile inspection | Implemented; correct observed `rtl/ar` and `ltr/en` |
| Public catalog | cards route, publication-aware repository | component, integration, E2E | Implemented; fresh data-backed local execution blocked |
| Search/filter | migration `0051`, stable URL filters, bounded pagination | repository/unit/integration | Implemented |
| Card detail | migration `0050` allowlisted projection | component/integration/pgTAP | Implemented |
| Comparison | comparison domain/page and migration-backed DTOs | unit/component/E2E | Implemented |
| Spending calculator | finite bounded calculations, annual net value | unit/component/E2E | Implemented; benefits/offers intentionally unvalued |
| Recommendation | migration `0052`, pure deterministic ranker, bilingual reasons | unit/component/integration/E2E | Implemented; live candidate data unavailable in this review |
| Authentication | auth, callback, recovery, safe redirects, session proxy | unit/integration/E2E security | Implemented |
| Profile/saved/history | account data/actions, migration `0053` bootstrap | unit/integration/RLS evidence | Implemented |
| Catalog administration | authorization shell, provenance/merchant management | unit and database tests | Implemented |
| Publication workflow | controlled submit/review/publish/unpublish/rollback | unit + `0048`/`0049` pgTAP | Implemented |
| Negative access paths | cross-bank/global denial, owner isolation, safe redirects | authorization/RLS/integration/E2E security | Strong evidence, not freshly database-replayed |

No real official-source launch catalog was assessed. UI content observed in
the local shell is product copy and illustrative value content, not evidence
that a launch dataset meets provenance or freshness targets.

## 8. Test and CI evidence matrix

| Gate | Fresh result | Historical trusted evidence | Interpretation |
|---|---|---|---|
| Prettier (pre-dossier tree) | Pass | Application CI green | Fresh pass |
| ESLint | Pass, zero warnings | Application CI green | Fresh pass |
| TypeScript | Pass | Application CI green | Fresh pass |
| Unit/component | 73/73 pass in 29 files | P9.1 73/73 | Fresh pass; initial sandbox-only bind failure was rerun successfully |
| Production build | Pass; 20 routes generated | Application CI green | Fresh pass |
| Bundle budget | Pass: total 1,240,052; largest JS 535,142; CSS 28,094 bytes | P9.1 green | Within 1,750,000 / 650,000 / 100,000 limits |
| Browser/E2E | 20/32 pass; 12 data-dependent failures | P9.1 32/32 green | Fresh run limited by absent Supabase; not a product pass or proof of regression |
| Integration | Not run | P9.1 10/10 green | Docker/Supabase unavailable |
| pgTAP | Not run | P9.1 538/538 green | Docker/Supabase unavailable |
| DB lint/replay | Not run | P9.1 recorded pass | Docker/Supabase unavailable |
| npm audit | Inconclusive; registry DNS unavailable | P8.3 recorded zero vulnerabilities | Must refresh with network before staging approval |
| GitHub Actions | Baseline Repository Policy green | P9.1 Application CI + Policy green | Docs-only baseline did not rerun Application CI by path design |

The 12 E2E failures were missing `#main-content`/headings on catalog,
comparison, calculator, recommendation, and zoom checks after the configured
Supabase endpoint was unavailable. Shell, locale direction, authentication
redirect, health, security headers, hostile redirect, and credential-disclosure
tests passed on desktop/mobile. Development mode displayed internal stack
details in its developer overlay; user copy beneath was generic. Production
error-disclosure evidence comes from automated production-oriented tests, not
that development overlay.

## 9. Security and privacy assessment

### Verified controls

- RLS and authenticated user context are the principal authorization boundary.
- Public catalog access uses execute-only, allowlisted publication functions;
  browser code has no service-role credential.
- BANK/GLOBAL administration is database-scoped; legacy unscoped assignments
  fail closed; platform privilege escalation has negative tests.
- Public input, pagination, numeric, redirect, and environment values are
  bounded and validated.
- Security headers, same-origin redirect policy, no-store operational routes,
  safe request IDs, structured redacted logs, and generic production errors
  are implemented and tested.
- The staging runtime contract requires only browser-safe Supabase values; the
  service-role key is confined to ephemeral test/owner operations.

### Residual security/privacy risks

| Class | Risk |
|---|---|
| Blocking | No external penetration test, deployed authorization exercise, secret-scanning/ruleset evidence, or production privacy design approval exists |
| Blocking | Real personal/financial data has no approved controller/processor model, lawful basis, retention schedule, consent model, transfer mechanism, or production region |
| Important | Rate limiting is represented in schema/architecture but no deployed edge/gateway enforcement evidence was reviewed |
| Important | Early migration behavioral coverage is incomplete |
| Important | Dependency graph/Dependency Review enablement and a fresh advisory audit are not evidenced |
| Suggestion | Conduct independent threat modeling and penetration testing after staging is stable and before any production decision |

No secret value was observed in tracked files or browser-visible responses.
This was not a substitute for platform secret scanning or credential rotation.

## 10. UX and accessibility assessment

The English desktop home rendered clearly with meaningful hierarchy, direct
calls to discovery/calculation, and prominent decision-support disclaimers.
The Arabic 390×844 view rendered `lang="ar"`, `dir="rtl"`, localized navigation,
stacked mobile actions, and equivalent core meaning. English used `lang="en"`
and `dir="ltr"`. Skip links and semantic landmarks were visible in the DOM.

Strengths include plain-language positioning, guest-first navigation, visible
assumptions/disclaimers, localized content, large mobile targets, and native
control patterns. Automated evidence covers serious Axe impact, overflow,
keyboard skip navigation, 200% zoom, and both viewport classes.

**Important evidence limits:** no manual screen-reader session, contrast-meter
retest, moderated comprehension research, low-bandwidth device test, or
data-backed Arabic/English journey completion was possible. At 390 px the
header wraps into two rows; it remains usable but deserves real-device review.
The first full-page mobile screenshot was blank while a viewport screenshot and
DOM confirmed content; this appears to be a browser capture limitation, not a
rendering failure.

## 11. Performance, resilience, and operational readiness

Bounded database functions, explicit page-size limits, stable ordering,
publication indexes, readiness timeout, generic degraded states, structured
logging, and enforced static-asset budgets are sound controls. The fresh build
and exact bundle figures match repository claims.

There is no evidence yet for deployed latency, cold starts, CDN/cache behavior,
regional Supabase latency, concurrency, capacity, alert delivery, backup/restore,
disaster recovery, or incident response. `/api/health` behavior passed local
E2E; readiness could not be successful without Supabase. The runbook specifies
web redeployment rollback and database forward fixes, but neither has been
exercised in staging.

## 12. Regulatory facts and unresolved legal questions

### Verified official-source facts recorded by the repository

The repository cites SAMA's in-force Instructions for Practicing Aggregation
Activity as requiring applicable licensed aggregation activity to be licensed,
and as addressing financier information exchange, offers/applications,
conflicts, fees, and commissions. It cites SAMA's Regulatory Sandbox FAQ as
limiting pre-permission bank/financial-institution testing to development with
dummy data and indicating that existing licensing paths affect Sandbox
eligibility. It cites SDAIA's PDPL knowledge center for controller/processor,
purpose-linked retention, implementing rules, and cross-border-transfer rules.
Those source summaries were not independently converted into a legal opinion.

### Repository decisions

- D-009 permits private Vercel/Supabase staging with synthetic/test data only.
- D-010 prohibits production, real personal/financial data, application
  forwarding, bank-document collection, commissions, paid referrals, and bank
  integrations until formal resolution.
- CCIP describes itself as information and decision support, not a bank,
  lender, credit bureau, or financial adviser.

### AI-generated hypotheses—not verified legal conclusions

- Application forwarding plus CPA may create a material aggregation-licensing
  risk.
- Paid ranking/referrals may create actual or perceived conflicts.
- Frankfurt/Dubai processing of real data may be a cross-border transfer
  requiring an approved basis and safeguards.
- Sandbox eligibility may be unavailable if SAMA determines an existing
  licensing route applies.

### Questions reserved for qualified Saudi counsel or SAMA

1. Which CCIP features fall within aggregation, finance support, advertising,
   brokerage/referral, or another regulated perimeter?
2. What licence, written SAMA position, Sandbox route, and bank contracts are
   required before application forwarding or integration?
3. How do CPA, commissions, paid placement, and ranking affect conflict and
   disclosure duties?
4. For each data purpose, who is controller/processor, what lawful basis and
   consent apply, and what minimization, retention, deletion, and data-subject
   rights are mandatory?
5. Which data is sensitive, what production region/transfer mechanism is
   lawful, and what risk assessment/contract safeguards are required?

## 13. Staging approval boundary and production prohibitions

### Conditionally allowed

Private, non-production Vercel/Supabase staging of the exact green commit,
access-controlled and populated only with synthetic/test data, for technical
validation. This requires completion of the checklist below.

### Prohibited

- Production launch or claims of production readiness.
- Real personal, financial, application, bank-document, or transaction data.
- Application forwarding, payment initiation, document collection, bank
  integrations, commissions, paid referrals, or paid ranking.
- Claims of SAMA, PDPL, legal, privacy, bank, or investor approval.
- Treating Frankfurt Supabase or Dubai Vercel as an approved production region.

## 14. Risk register summary

| Severity | Risk | Owner/closure evidence |
|---|---|---|
| Blocking | Staging resources/access absent | Owner provisions exact P9.2 batch |
| Blocking | Regulatory/licensing perimeter unresolved | Qualified Saudi counsel/SAMA written advice |
| Blocking | Production privacy/region/transfers unresolved | Approved privacy assessment, contracts, region, controls |
| Blocking | No staging operational evidence | P9.2/P9.3 deployment, smoke, admin bootstrap, rollback evidence |
| Important | `0001`–`0041` dedicated behavioral test gap | Risk-prioritized forward test program without rewriting migrations |
| Important | Fresh full-stack validation incomplete | Green replay, pgTAP, lint, integration, and 32/32 E2E in isolated environment |
| Important | Dependency and repository-setting evidence incomplete | Enable graph/review/scanning/ruleset and retain screenshots/exported settings evidence |
| Important | No launch catalog/provenance outcome evidence | Curated official-source acceptance dataset meeting declared thresholds |
| Important | No moderated bilingual usefulness research | Approved method and separately reported Arabic/English outcomes |
| Suggestion | Open Actions dependency upgrades | Separate reviewed maintenance delivery |

## 15. Known technical debt

- Behavioral pgTAP coverage begins at migration `0042`.
- Large schema and long status ledger increase review cost.
- Four GitHub Actions dependency updates are open.
- Repository settings—branch protection, dependency graph/review, secret
  scanning/push protection—are documented but not evidenced from settings.
- No deployed performance baseline, operational SLO, or exercised recovery
  record exists.
- No real catalog/data-quality acceptance corpus or external accessibility,
  security, privacy, or legal assessment is present.

## 16. Owner-controlled actions

1. Provision the exact P9.2 private staging batch without placing secrets or
   personal identifiers in source or chat.
2. Preserve the synthetic/test-only and regulated-capability prohibitions.
3. Enable/evidence branch protection, dependency graph/review, secret scanning,
   and push protection.
4. Commission qualified Saudi legal/privacy/SAMA review before production.
5. Decide launch catalog breadth, bilingual research sample, and monetization
   boundary before Phase 10 completion.

## 17. Reviewer questions

### Technical/architecture

- Can the team reproduce all database, integration, browser, build, bundle, and
  policy gates from an empty environment?
- What measured catalog volume and concurrency justify the present indexes and
  two-second recommendation target?

### Security

- Are repository rulesets, secret scanning, deployment RBAC, MFA, audit export,
  rate limiting, backup access, and incident escalation actually enabled?
- Has an independent tester attempted cross-user, cross-bank, workflow bypass,
  session fixation, OAuth redirect, and error-disclosure attacks in staging?

### Privacy

- What exact fields and purposes enter v1, where do they flow, how long are they
  retained, and how are access/deletion/consent withdrawals enforced?

### Legal/SAMA

- Which planned functions require licensing, approval, Sandbox participation,
  disclosures, consent, data-localization/transfer controls, or contracts?

### Bank partner

- Who owns product-data accuracy, correction SLAs, approved logos/content,
  application handoff, liability, security incidents, and audit evidence?

### Commercial/investor

- Can monetization remain visibly independent from rankings and explanations?
- What evidence supports acquisition, retention, catalog freshness, correction
  speed, bilingual trust, and unit economics without regulated-adjacent scope?

## 18. Exact P9.2 staging checklist

Do not begin deployment until all items are satisfied:

- [ ] Separate private **staging Supabase** project exists and migrations
  `0001`–`0053` have been applied from the immutable history.
- [ ] Separate private **staging Vercel** project exists and cannot point to
  production data.
- [ ] Environment-scoped `NEXT_PUBLIC_SUPABASE_URL` is supplied outside the
  repository.
- [ ] Environment-scoped `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` is supplied
  outside the repository; no service-role key is exposed to the browser.
- [ ] `APP_VERSION` is the exact deployment commit identifier.
- [ ] `LOG_LEVEL` is explicitly selected for staging.
- [ ] Owner-authenticated Vercel link/deployment authorization exists, or an
  equivalently scoped token, organization ID, and project ID are supplied
  securely outside source/chat.
- [ ] Staging contains synthetic/test data only; fixtures, uploads, logs,
  backups, analytics, and admin inputs contain no real personal/financial data.
- [ ] Application forwarding, bank-document collection, commissions, paid
  referrals, paid ranking, and bank integrations are disabled.
- [ ] All local gates pass against the staging schema: reset/replay, 538 pgTAP,
  database lint warning/error, 10 integration, 32 E2E, format, lint, typecheck,
  73 unit/component, build, bundle, npm audit, repository policy, links, YAML,
  and whitespace.
- [ ] All triggered GitHub Actions for the exact commit are green.
- [ ] An intended staging administrator account is created and independently
  owner-verified in Supabase; its email/UUID is not committed or recorded in
  chat.
- [ ] Deployment record captures commit, deployment ID, operator, environment,
  UTC time, exact non-secret variables, and CI run URLs.
- [ ] P9.2 stops after successful deployment evidence; P9.3 separately verifies
  health, readiness, all critical journeys, logs/alerts, admin bootstrap, and
  rollback without real data.

## 19. Final readiness score

**68/100 for entry into private synthetic staging; 0/100 for production
authorization.**

| Dimension | Weight | Score | Basis |
|---|---:|---:|---|
| Product/journeys | 20 | 16 | Broad implementation; launch catalog and outcome evidence absent |
| Architecture/maintainability | 15 | 13 | Strong typed modular boundaries; schema/governance complexity |
| Database/security | 20 | 15 | Strong RLS/functions; early test gap and no fresh replay |
| Testing/quality | 15 | 11 | Broad historical green suite; fresh full-stack run incomplete |
| UX/accessibility | 10 | 8 | Strong bilingual responsive evidence; manual/user research gaps |
| Operations/deployment | 10 | 4 | Contract/runbook exist; no deployment or operational exercise |
| Privacy/regulatory governance | 10 | 1 | Clear prohibitions, but substantive production questions unresolved |

The score measures assurance evidence for the next technical stage. It is not a
legal/compliance rating, valuation, or prediction of product success.

## 20. Recommendation and exactly one next action

**Recommendation:** maintain the production and real-data prohibition. Approve
only a private synthetic/test staging exercise once the complete checklist is
available; do not mark P9.2, P9.3, Phase 10, or CCIP v1 complete before their
observed evidence exists.

**Next action:** the owner provisions and securely supplies the complete P9.2
private Vercel/Supabase staging input batch listed in Section 18.

## Appendix A — Evidence register

### Commits and CI

| Evidence | Identifier/result |
|---|---|
| Assurance baseline | `65a5d1d1503f0045c48373f7860e904145eda03e` |
| Baseline Repository Policy | run `31812147048`, success |
| P9.1 implementation | `ace16b3e7cbc45f2be3b31ee6a3079848c50b2fe` |
| P9.1 Application CI | run `30836747504`, success |
| P9.1 Repository Policy | run `30836749288`, success |
| P8.4 implementation | `566c818`; CI runs `30835970031`/`30835970048`, success |
| P8.3 security implementation | `13dba91`; CI runs `30835116115`/`30835115999`, success |
| P8.2 accessibility implementation | `aeccb4a`; CI runs `30834225028`/`30834225757`, success |

### Documents reviewed

`README.md`, `AGENTS.md`, `CLAUDE.md`, all authoritative Markdown under
`docs/` including handoff, workflow, status, master plan, execution ledger,
requirements, architecture, database, security, deployment, decisions, risks,
bootstrap, Definition of Done, BRD/design materials, and all workflows under
`.github/workflows/`.

### Fresh validation record

| Validation | Exact result |
|---|---|
| Git reconciliation | clean initial tree; local/remote/HEAD all `65a5d1d` |
| Format before dossier | pass |
| ESLint | pass, zero warnings |
| Typecheck | pass |
| Unit/component | 29 files, 73 tests passed |
| Build | pass; 20 routes reported |
| Bundle | 1,240,052 total; JS 535,142; CSS 28,094 bytes—pass |
| E2E | 20 passed, 12 failed due absent local Supabase/data-dependent routes |
| Docker | unavailable: Colima socket absent |
| Integration/pgTAP/DB lint | not run due Docker/Supabase limitation |
| npm audit | inconclusive: npm advisory endpoint DNS unavailable |
| In-app browser | English desktop LTR and Arabic 390×844 RTL shell observed; no console warnings on English home; safe generic dependency error observed on unavailable recommendation data |

### Evidence limitations

No production/staging endpoints, real users, real catalog, personal data,
credentials, contracts, repository-settings export, SAMA correspondence, legal
opinion, privacy impact assessment, penetration test, load test, or bank-partner
attestation was available. Accordingly, this dossier makes no compliance,
approval, production-readiness, or full milestone-completion claim.
