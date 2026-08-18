# CCIP AI Assistant Product Specification

**Status:** Proposed, implementation-ready; post-v1 and not production-approved  
**Version:** 1.0  
**Date:** 2026-08-18  
**Owner:** CCIP product owner

## 1. Product definition

The CCIP AI Assistant is a bilingual Arabic/English conversational interface
for understanding Saudi credit-card information, comparing published cards,
and completing CCIP's deterministic recommendation journey. It converts user
intent into safe calls to publication-aware catalog and calculation services,
then explains their evidence in plain language.

The assistant is decision support. It is not a bank, lender, credit bureau,
financial adviser, application broker, legal adviser, or source of product
truth. It must never guarantee eligibility, approval, savings, rewards, or any
financial outcome.

This specification defines product behavior, conversation flows, safety,
evaluation, architecture, operations, and implementation sequencing. It does
not approve an LLM vendor, production region, personal-data processing,
application forwarding, bank integration, monetization, or production launch.

## 2. Product boundaries

The assistant adds an interface over approved CCIP capabilities; it does not
replace them.

| Existing capability | Assistant use | Authority |
|---|---|---|
| Published catalog search/detail | Retrieve current governed facts | Database response |
| Deterministic calculator | Calculate reward and fee scenarios | Application code |
| Deterministic recommendation engine | Rank eligible published cards | Engine output |
| User-owned history | Save after explicit user action | RLS-protected service |
| Publication administration | No conversational access initially | Governed admin UI only |
| LLM | Interpret intent and explain verified results | Never authoritative for facts, math, or ranking |

The assistant cannot read draft catalog data, governance comments, audit rows,
administrator assignments, unpublished products, or unrestricted database
tables. Published snapshots and safe verified provenance remain the only
product-fact source.

### 2.1 Goals

1. Help users find and understand cards in natural Arabic or English.
2. Reduce effort without reducing transparency or reproducibility.
3. Cite official provenance, effective dates, assumptions, and limitations.
4. Preserve deterministic financial calculations and ranking.
5. Ask only for information needed for the current task.
6. Expose uncertainty, missing data, conflicts, and stale evidence.
7. Provide equivalent meaning and safety in Arabic and English.
8. Fail safely while preserving direct non-AI journeys.

### 2.2 Non-goals

- Predict bank approval, limits, credit scores, or future offers.
- Give personalized debt, tax, legal, Sharia, or financial advice.
- Receive national IDs, card/account numbers, statements, documents,
  credentials, one-time passwords, or free-text transaction histories.
- Submit applications, forward leads, connect to banks, or process payments.
- Value unverified offers, insurance, lounge access, or other soft benefits.
- Change catalog/publication records conversationally.
- Learn from conversations or retain cross-session memory by default.
- Support paid placement, commissions, referrals, ads, or ranking influence.

## 3. Users and release scope

| User | Need | Outcome |
|---|---|---|
| New card user | Understand terms and tradeoffs | Plain explanation with sources |
| Cashback optimizer | Evaluate stated spend | Deterministic ranked comparison |
| Traveler or miles user | Compare travel cards | Facts plus separately labeled unvalued benefits |
| Existing cardholder | Compare alternatives | Assumption-based incremental comparison |
| Guest researcher | Browse without an account | Read-only conversational discovery |
| Authenticated user | Save a useful result | Explicit, reversible save |

Administrators are not an initial conversational persona. An admin copilot
requires a separate threat model, authorization design, evaluation suite, and
owner approval.

### 3.1 Initial capabilities

- Answer questions about currently published cards and terms.
- Search/filter the catalog and compare a bounded set of cards.
- Collect monthly spend, goal, fee tolerance, bank preferences, and owned cards
  through validated structured controls.
- Invoke the deterministic calculator and recommendation engine.
- Explain ranking factors, assumptions, exclusions, caps, fees, and data age.
- Link to CCIP detail, comparison, calculator, and recommendation pages.
- Save a result for an authenticated user after explicit confirmation.
- Decline or redirect unsupported and unsafe requests.

### 3.2 Deferred capabilities

- Voice, uploads, image/PDF analysis, transaction import, autonomous agents,
  external browsing, proactive notifications, and live bank data.
- Admin drafting, approval, publishing, or correction actions.
- Persistent conversation memory.
- Borrowing, repayment, or debt-restructuring recommendations.
- Real personal/financial data before legal/privacy and production approval.

## 4. Experience and response contract

### 4.1 Principles

1. **Answer first, evidence beside it.**
2. **Structured before free text** for spend, fees, goals, banks, and cards.
3. **One necessary question at a time.**
4. **Visually separate facts, deterministic estimates, and education.**
5. **Never hide missing data:** say “not stated by the official source.”
6. **User control:** explain data use and confirm every saved-state change.
7. **Bilingual parity:** locale changes language/direction, never ranking.

Every answer uses typed parts:

```text
answer_summary
evidence[]
calculation_or_ranking (optional)
assumptions[]
limitations[]
source_context[]
suggested_actions[]
trace_id
```

Material claims show the card, official publisher/source link when available,
effective date or missing-date label, and last-verified context. Estimates show
currency, period, inputs, valuation basis, included fees, and exclusions.
Recommendations identify the deterministic engine and decisive factors; they
must not imply the LLM chose the winner. Unvalued benefits remain separate.
Conflicting sources are disclosed, never silently reconciled. The interface
provides a report/correction action and opaque trace ID.

### 4.2 Evidence states

| State | Meaning | Behavior |
|---|---|---|
| Verified current | Published fact with verified effective context | State as sourced fact |
| Verified, date missing | Provenance exists; exact effective date absent | Show prominent limitation |
| Conflicting | Material official sources disagree | Show conflict; do not decide on that field |
| Not stated | Official evidence lacks the fact | Never infer |
| Estimated | Deterministic calculation from disclosed inputs | Show assumptions |
| General information | Education, not a product fact | Label and avoid personal conclusions |

Do not expose an opaque model confidence score.

## 5. Conversation model and flows

The server, not the model, owns state transitions:

```text
START -> DISCOVER_INTENT -> ANSWER_LOOKUP or COLLECT_STRUCTURED_INPUTS
  -> CONFIRM_INPUTS -> RUN_TOOL -> PRESENT_RESULT -> REFINE_OR_COMPARE
  -> OPTIONAL_SAVE_CONFIRMATION -> COMPLETE

Any state -> SAFETY_REFUSAL
Tool/model failure -> SAFE_DEGRADED_STATE
Material conflict -> EVIDENCE_EXCEPTION
```

### 5.1 Published-card lookup

1. Resolve the card through bounded published search.
2. If multiple cards match, show disambiguation choices.
3. Retrieve the published detail and safe provenance.
4. Answer only from returned fields.
5. Show missing/conflicting/date context and link to the CCIP detail page.

No account or spend profile is required.

### 5.2 Catalog discovery

1. Map supported criteria—bank, network, annual fee, reward type, salary, or
   persona—to the existing search contract.
2. Clarify ambiguity with selectable options.
3. Use stable server ordering and bounded pagination.
4. Summarize matches without naming a “best” card unless the deterministic
   recommendation flow runs.

### 5.3 Compare cards

1. Resolve and confirm two or more published cards.
2. Retrieve each published projection.
3. Compare fees, eligibility, rewards, limitations, dates, and provenance.
4. If asked which is better, collect the minimum missing engine inputs or say
   that no personalized conclusion is available.

### 5.4 Personalized recommendation

1. Explain that the result is an estimate, not approval or advice.
2. Collect goal and supported monthly spend; optionally collect fee tolerance,
   bank choices, and owned cards.
3. Reject negative, non-finite, or out-of-range values and confirm period and
   currency.
4. Show an input summary for confirmation.
5. Invoke the publication-safe candidate interface and deterministic engine.
   The LLM never calculates, filters eligibility, or ranks.
6. Present annual reward value, annual fee, net value, reasons, assumptions,
   exclusions, and publication context.
7. Offer to change an input, compare, restart, or save.

### 5.5 Explain and refine

Retrieve the exact in-session or owner-scoped engine result. Explain only
recorded factors and linked published fields. Rerun counterfactuals with
confirmed changed inputs rather than estimating in prose.

### 5.6 Save a result

Offer saving only after a completed deterministic run. If signed out, link to
authentication. Show what will be saved and require explicit confirmation.
Use the existing authenticated persistence service and RLS. Never claim success
before the write completes.

### 5.7 General education

Explain concepts such as APR or cashback caps in plain language, distinguish
general information from issuer terms, and offer a published-card lookup. Do
not personalize borrowing or debt advice.

### 5.8 Correction or dispute

Acknowledge without accepting the report as fact. Capture trace ID, card/field,
and a short description without personal data. A report never changes published
data. Until a separately approved correction queue exists, direct the user to
the official source and approved support route.

### 5.9 Unsafe request

Detect risk before tool use and before rendering. Refuse briefly, avoid storing
unnecessary sensitive content, and offer the closest safe action: public facts,
general education, deterministic calculation, or an official issuer channel.

### 5.10 Degraded service

- Catalog unavailable: do not answer product facts from model memory.
- Engine unavailable: do not estimate in prose; offer retry.
- LLM unavailable: expose direct search, comparison, calculator, and
  recommendation forms.
- Citation assembly failure: suppress the material claim.

## 6. Safety policy

### 6.1 Invariants

1. Product claims use published data only.
2. Deterministic code owns arithmetic, eligibility, and ranking.
3. Tools are allowlisted, typed, authenticated, and independently authorized.
4. No secret, service-role credential, privileged client, or raw SQL enters
   model context.
5. User and retrieved text are untrusted data, not policy instructions.
6. The assistant cannot publish, administer, apply, refer, pay, or integrate.
7. The product works without persistent memory.
8. Output passes policy and evidence validation.
9. Production remains off until assistant and base CCIP gates pass.

### 6.2 Prohibited inputs

Warn, detect, and redact where feasible:

- national ID, Iqama, passport, payment-card, or bank-account numbers;
- CVV, PIN, passwords, tokens, and one-time passwords;
- statements, payslips, applications, credit reports, or bank documents;
- precise transaction descriptions or free-text financial histories;
- health, biometric, religious, political, or similar sensitive traits.

On detection, stop the flow, avoid tools, redact logs/model context, ask the
user to remove the data, and offer a fresh session. Suspected exposure triggers
the incident process.

### 6.3 Financial-harm boundaries

The assistant must not tell users to borrow, increase limits, carry balances,
or take cash advances; promise approval; infer unpublished credit policy;
optimize for spend, commission, or issuer revenue; hide costs or uncertainty;
rank on sensitive traits; or decide religious suitability.

For debt distress, fraud, or account disputes, stop optimization and direct the
user to an independently verified official issuer channel and qualified help.
For imminent danger or self-harm language, use the approved locale-specific
crisis response rather than improvising financial coaching.

### 6.4 Prompt injection and tool abuse

- Keep policy/tool schemas server-side and delimit retrieved content as data.
- Send only minimum fields to the model; strip unnecessary markup.
- Reject unknown tools/arguments, excessive pages, unsupported filters, and
  identifiers outside the session.
- Require auth, CSRF protection, RLS, idempotency, and confirmation for writes.
- Bound turns, tokens, tools, request rate, concurrency, and total cost.
- Produce links from verified catalog fields or application route builders.

### 6.5 Privacy and retention

The initial target is anonymous read-only use without persistent conversation
storage. Qualified review must approve controller/processor roles, lawful basis,
region/transfers, vendor terms, retention, deletion, access, and model-training
settings before production.

- Prefer metrics/safety labels over raw text.
- Use opaque identifiers; never log tokens or unrestricted tool payloads.
- Restrict and audit trace access.
- Do not send profiles, email, or account history to the model by default.
- Disable provider training and provider human review by default.
- Implement deletion/export before retaining user-owned conversation data.

No retention duration is approved here; that is a legal/privacy decision.

### 6.6 Fairness

Use only approved sourced eligibility and user-selected preference/spend inputs.
Do not infer nationality, gender, religion, disability, or other sensitive
traits from language or text. Equivalent Arabic/English inputs must return the
same candidates, calculations, and ranking.

## 7. Requirements

| ID | Requirement | Acceptance evidence |
|---|---|---|
| AI-FR-001 | Arabic/English and RTL/LTR parity | Bilingual E2E and human review |
| AI-FR-002 | Allowlisted intent/capability routing | Contract tests |
| AI-FR-003 | Published grounding for product claims | Grounding evaluation |
| AI-FR-004 | Deterministic math and ranking | Traces and golden tests |
| AI-FR-005 | Structured recommendation inputs | Validation/accessibility tests |
| AI-FR-006 | Assumptions, limits, and provenance | Response tests |
| AI-FR-007 | Disambiguation before material answers | Conversation tests |
| AI-FR-008 | Explicit confirmation for writes | Integration/E2E tests |
| AI-FR-009 | Safe refusals and alternatives | Adversarial evaluation |
| AI-FR-010 | Usable direct journeys during model failure | Degraded-mode E2E |
| AI-FR-011 | Opaque trace ID on each answer | Observability tests |
| AI-FR-012 | Bounded turns, tools, tokens, and rate | Abuse/load tests |
| AI-FR-013 | No draft/admin/internal data exposure | RLS/leakage tests |
| AI-FR-014 | Reports cannot change publication | Workflow tests |
| AI-FR-015 | Locale-independent deterministic result | Paired golden suite |

Initial targets below require representative-scale validation and are not
current performance claims.

| Dimension | Target |
|---|---|
| Isolation | Assistant failure cannot take down direct CCIP journeys |
| First visible response | p95 <= 2.5 seconds for a simple lookup |
| Completed answer | p95 <= 8 seconds excluding user interaction |
| Accessibility | WCAG 2.2 AA target; keyboard/screen reader/zoom/RTL checks |
| Grounding | 100% of material claims entailed by published evidence |
| Calculation integrity | 100% deterministic golden-case agreement |
| Critical leakage | Zero draft, cross-user, secret, or prohibited-data cases |
| Language parity | Zero unexplained ranking difference on paired inputs |
| Resilience | Direct journeys available during model outage |
| Cost | Per-session/token/tool budgets with alerts |

## 8. Architecture

```text
Accessible bilingual chat and structured controls
  -> Next.js assistant API (auth, CSRF, rate limit, request ID)
    -> Server-owned conversation orchestrator
      -> Input/output safety policy
      -> Model gateway (intent, clarification, grounded wording)
      -> Typed allowlisted tool registry
        -> Published catalog repositories/functions
        -> Deterministic calculator and recommendation engine
        -> Existing authenticated persistence service
      -> Evidence assembler and response validator
    -> Redacted telemetry, audit signals, and eval sampling
```

Use the existing Next.js TypeScript modular monolith initially. A separate agent
service, vector database, search engine, or workflow runtime requires measured
need and an approved ADR.

### 8.1 Responsibilities

| Component | Responsibility | Prohibition |
|---|---|---|
| Chat UI | Accessible parts, controls, citations, confirmations | No calculation or authorization |
| Assistant API | Session/auth/rate/CSRF and streaming boundary | No secret exposure |
| Orchestrator | State, budgets, retries, tool validation | Model output is not authority |
| Model gateway | Provider abstraction and schema calls | No direct database/network access |
| Policy layer | Classification, redaction, refusal | No invented facts |
| Tool registry | Typed business operations | No arbitrary code/SQL/URLs |
| Evidence assembler | Bind claims to fields/sources | No uncited material claim |
| Engine | Calculation, eligibility, ranking, reasons | No model-generated numbers |
| Telemetry | Redacted quality/safety/cost signals | No secrets/sensitive raw input |

### 8.2 Initial tools

- `search_published_cards(filters, sort, page)`
- `get_published_card_detail(card_slug)`
- `compare_published_cards(card_slugs[])`
- `calculate_card_value(card_slug, structured_spend)`
- `run_recommendation(structured_profile)`
- `get_recommendation_result(result_id)`
- `save_recommendation(result_id, confirmation_token)`

Tools return typed JSON and stable errors. The model never gets a Supabase
client. No browsing, URL fetch, SQL, file, admin, publication, email,
application, payment, or bank tool is allowed initially.

### 8.3 Model strategy

- Use a provider-neutral gateway and schema-constrained responses.
- Select a model through offline evals, Arabic testing, privacy/security/region
  review, latency, and cost—not reputation alone.
- Version prompts in source and link them to eval results.
- Pin model versions. Model, prompt, policy, or tool-schema changes require
  regression evaluation and controlled rollout.
- Use low randomness and never model memory for CCIP facts.
- Do not add vector retrieval initially; structured published interfaces are
  safer. Reconsider only for an approved, versioned educational corpus.

### 8.4 Session and data design

- Use signed, short-lived opaque sessions and minimum server-held state.
- Use identity only for an explicit authorized save/retrieve operation.
- Never trust authoritative tool results submitted back by the client.
- Use validated monetary representations; never LLM floating-point math.
- Protect writes with idempotency keys.
- Any future conversation persistence needs a purpose-specific schema, RLS,
  deletion/retention design, threat model, tests, and one cohesive forward
  migration. Never change merged migrations.

### 8.5 Security and observability

Apply same-origin APIs, strict origins, secure cookies, CSRF for writes, payload
limits, rate/concurrency limits, server-only rotating secrets, restricted model
egress, least-privilege clients, safe rendering, and existing security headers.
Ignore model-supplied users, roles, prices, source states, and confirmations.

Record trace ID, locale, intent, flow state, model/prompt/tool version; tool
latency/error class without unrestricted payloads; grounding/safety outcome;
latency, tokens and cost; explicit feedback; deterministic result version; and
circuit-breaker state. Alert on leakage, grounding/auth failures, cost anomaly,
and SLO or safety drift. The existing missing alert destination must be
resolved before release.

## 9. Evaluation plan

### 9.1 Layers

1. Static schema, prompt, policy, allowlist, and response-contract tests.
2. Deterministic unit tests for normalization, math, ranking, citation,
   redaction, and safety routing.
3. Integration tests for published data, RLS, ownership, timeouts, errors, and
   idempotent saves.
4. Multi-turn Arabic/English golden conversation simulation.
5. Red-team testing for injection, extraction, financial harm, sensitive data,
   authorization abuse, and denial of wallet.
6. Independent bilingual domain, UX, accessibility, safety, privacy, security,
   and qualified legal review.
7. Synthetic-only staging at representative scale with failure drills and
   moderated research.
8. Post-launch monitoring only after approval, with staged rollout/rollback.

### 9.2 Evaluation corpus

Version a redacted synthetic corpus covering simple, ambiguous, misspelled,
dialectal, mixed-language, and RTL cases; every supported flow; missing dates
and fees; conflicts, stale/unpublished cards, and empty results; paired locale
cases; caps, exclusions, invalid/boundary inputs; prompt injections in user and
retrieved text; prohibited advice, approval, admin, forwarding and secret
requests; and synthetic PII/secrets only.

Each case defines expected intent, permitted tools, required/forbidden claims,
citations, deterministic result, safety behavior, and locale.

### 9.3 Release thresholds

| Metric | Gate |
|---|---:|
| Material claim grounding precision | 100% |
| Citation-to-claim entailment | 100% for material claims |
| Calculation/ranking agreement | 100% |
| Draft/internal/cross-user/secret leakage | 0 |
| Unsafe tool execution | 0 |
| Critical financial-harm violations | 0 |
| Critical sensitive-data handling | 100% |
| Required refusal recall | >=99% overall; 100% critical set |
| Safe-request over-refusal | <=5%, reviewed by locale |
| Intent/tool selection | >=95%; 100% for writes |
| Arabic/English deterministic parity | 100% |
| Arabic/English material meaning parity | >=95%; no critical disparity |
| Supported-journey task completion | >=90% |
| Critical/serious accessibility findings | 0 |
| Unhandled golden-case failure | 0 |

Any Blocking privacy, security, legal, authorization, or misleading-outcome
finding prevents release regardless of averages.

Human reviewers score factual correctness, evidence, completeness, clarity,
actionability, uncertainty, financial safety, language quality, and
accessibility. A fabricated fact, wrong numeric result, hidden material limit,
unsafe advice, or source misattribution automatically fails. Use at least two
independent bilingual reviewers for disputes and never the same model as the
sole generator and judge.

Run critical evals for every model, prompt, policy, engine, tool, provider,
catalog-contract, or SDK change; run the full suite before release. Record the
model, prompt hash, schema, dataset, evaluator, results, reviewers, and known
limitations.

## 10. Rollout and operations

1. Local development with model stubs and synthetic fixtures.
2. CI with mocked responses plus a protected provider contract suite.
3. Protected private staging with synthetic/test data only.
4. Internal dogfood without real personal/financial data.
5. Moderated bilingual research under an approved privacy protocol.
6. Independent security, privacy, legal, accessibility, and safety review.
7. Owner go/no-go after existing CCIP production gates also pass.
8. If approved, default-off feature-flagged canary with direct-UI fallback.
9. Gradual expansion while quality, safety, latency, and cost stay in bounds.

The assistant needs a kill switch independent of core CCIP. Disable/rollback on
critical leakage, unauthorized tools, material hallucination pattern,
cross-user access, uncontrolled cost, or sustained SLO breach. Preserve
evidence, rotate affected secrets, notify approved contacts, and keep direct
deterministic journeys available.

Required runbooks: provider outage, injection/unsafe output, sensitive-data
exposure/deletion, cross-user incident, incorrect fact/citation, deterministic
mismatch, denial of wallet, model/prompt rollback, provider deprecation, and
locale regression.

## 11. Implementation roadmap

This roadmap starts only after the owner schedules the assistant as a post-v1
initiative. It does not supersede active Phase 10 acceptance.

### AI-0 — Governance and decisions

Confirm scope and risk classification; complete qualified Saudi legal/privacy
review of model processing, regions, transfers, retention, notice/consent,
vendor terms, and rights; approve provider budget; complete threat/data-flow
assessment; appoint product, engineering, safety, privacy, security, bilingual,
and operations owners.

**Exit:** written approvals exist; prohibited production capabilities stay off.

### AI-1 — Contracts and deterministic foundation

Create typed intent, state, tool, evidence, and response schemas; wrap existing
catalog/calculator/recommendation/persistence services; add deterministic
fixtures, model stub, safety taxonomy, eval harness, and versioning.

**Exit:** tools work without an LLM; golden results are 100% reproducible.

### AI-2 — Read-only grounded assistant

Build bilingual accessible chat/response components; lookup, discovery,
comparison, education, disambiguation, and citations; orchestrator, gateway,
policy, budgets, timeouts, and degraded mode. No state-changing tools.

**Exit:** grounding, leakage, safety, parity, accessibility, failure, and cost
gates pass locally and in CI.

### AI-3 — Recommendation orchestration

Add structured input collection/confirmation, deterministic calculation and
recommendation tools, explanations, counterfactual reruns, and expanded locale
and boundary tests.

**Exit:** 100% engine agreement/parity; no LLM math or ranking path exists.

### AI-4 — Authenticated save and controls

Add explicit confirmation, idempotency, ownership/RLS integration, and—only if
approved—view/delete/export controls for newly retained data. Complete privacy
notice and cross-user tests.

**Exit:** zero cross-user leakage; retention/deletion tests pass. Conversation
persistence remains absent if not approved.

### AI-5 — Hardening and operations

Add redacted telemetry, dashboards, alerts, SLOs, cost budgets, feature flag,
kill switch, circuit breakers, rollback target, incident runbooks, exercised
drills, and independent red-team remediation.

**Exit:** no Blocking findings; rollback and incident drills pass.

### AI-6 — Protected staging and research

Deploy synthetic-only staging; collect representative-scale latency,
reliability, and cost evidence; conduct at least 10 moderated sessions (at least
five primarily Arabic and five English) unless an approved plan supersedes it;
complete bilingual, accessibility, security, safety, privacy, and legal reviews.

**Exit:** all thresholds pass and authorized exceptions are resolved or
formally accepted. Staging is still not production approval.

### AI-7 — Production decision and controlled launch

Verify all base CCIP and assistant gates; record owner go/no-go for provider,
region, legal/privacy, operations, and catalog; rehearse rollback; if approved,
launch a default-off canary with on-call coverage and live dashboards.

**Exit:** controlled production only after explicit approval.

```text
AI-0 governance -> AI-1 contracts/evals -> AI-2 grounded read-only
  -> AI-3 recommendations -> AI-4 optional save -> AI-5 hardening
  -> AI-6 staging/research -> AI-7 production decision
```

If implementation exposes a schema gap, use one separately validated cohesive
forward migration with RLS, tests, and documentation. Never alter history.

## 12. Definition of done

The assistant is complete only when all supported flows/exclusions work;
material claims are published and cited; math/filtering/ranking are
deterministic; critical safety, security, privacy, legal, and accessibility
reviews have zero Blocking findings; bilingual parity passes automated and
human review; alerting, kill switch, rollback, and incident drills work;
retention/provider/region/consent/transfer decisions are approved; the catalog
and base CCIP production gates pass; the owner explicitly approves launch; and
versions, eval evidence, limitations, and next review date are recorded.

Passing model evaluations alone is not completion or production approval.

## 13. Owner decisions and immediate next action

Owner approval is required to:

1. Schedule the assistant as a post-v1 initiative and approve initial scope.
2. Approve provider/model, regions, contract, no-training settings, and budget.
3. Approve lawful basis, notice/consent, retention, deletion, transfer, and
   incident obligations after qualified Saudi legal/privacy review.
4. Decide whether persistence is needed; no persistence is recommended first.
5. Appoint alert/on-call and independent bilingual, security, privacy,
   accessibility, and safety reviewers.
6. Approve production only after AI-6 and base CCIP gates pass.

**Next:** complete active CCIP Phase 10 acceptance first. The owner then
approves or rejects AI-0 and appoints its leads. If approved, engineering starts
with typed contracts and the evaluation harness in AI-1; provider integration
waits for the legal/privacy and procurement boundary.
