# Phase 10 Saudi Legal, Privacy, and SAMA Review Package

## Instructions to the owner and reviewers

This is an evidence request, not legal advice. The owner must select qualified
Saudi legal/privacy professionals and, where needed, obtain written guidance
from SAMA or an authorized liaison. Do not commit privileged advice, personal
identifiers, credentials, contracts, or confidential regulator correspondence.
Store them in an approved restricted system and record a stable reference,
date, scope, reviewer qualification, conclusion, conditions, and expiry/review
date in the Phase 10 evidence register.

Until written decisions resolve the relevant gates, keep Production disabled
and preserve decision D-010's prohibitions.

## Evidence package to provide

1. Current `README.md`, `docs/PRODUCT_REQUIREMENTS.md`,
   `docs/TECHNICAL_ARCHITECTURE.md`, `docs/SECURITY_MODEL.md`,
   `docs/DEFINITION_OF_DONE.md`, `docs/DECISION_LOG.md`, and
   `docs/RISK_REGISTER.md` at an identified commit.
2. Data-flow and deployment description: Next.js/Vercel, Supabase/Auth/RLS,
   proposed regions, subprocessors, environment separation, and every planned
   data transfer.
3. Field-level data inventory for guest, account, recommendation, saved-item,
   administrator, audit, log, research, support, and future prohibited flows.
4. Purpose, lawful-basis hypothesis, controller/processor hypothesis,
   recipients, retention/deletion, access, consent/notice, and security control
   for each data category. Mark hypotheses clearly.
5. Product screenshots and exact Arabic/English disclosures, disclaimers,
   correction paths, recommendation explanations, and any proposed commercial
   labeling.
6. Proposed catalog-source/licensing terms, bank contracts, referral or
   commission concepts, and application/document flows—design evidence only;
   none may be enabled for this review.
7. P9.3 and Phase 10 reports, test/authorization evidence, incident process,
   alert/rollback plan, and unresolved risks.

## Exact questions for qualified Saudi counsel

1. Which present informational, comparison, calculation, recommendation,
   account, and catalog-administration functions are legally permissible, and
   which require a licence, authorization, disclaimer, contract, or design
   change before public availability?
2. Would application forwarding, receiving/processing finance offers,
   collecting bank documents, exchanging customer data with banks, or any bank
   integration constitute regulated aggregation or another regulated activity?
3. Do deterministic personalized rankings create regulated-advice, consumer-
   protection, advertising, or suitability obligations? Are current Arabic
   and English limitations sufficient and equally effective?
4. Do commissions, CPA, paid referrals, sponsored placement, affiliate links,
   or issuer payments alter licensing or conflict-of-interest analysis? What
   enforceable independence, disclosure, audit, and consent controls are
   required, if such models are permissible at all?
5. What permissions or licences are required to reproduce issuer names,
   trademarks, product facts, fee schedules, terms, and deep links? What source
   retention is permitted?
6. What correction, complaint, evidence-retention, audit, accessibility,
   consumer disclosure, and recordkeeping duties apply?
7. What contractual allocation, indemnity, insurance, governance, and named
   accountable roles must exist before any public launch?

## Exact questions for the qualified privacy reviewer

1. For each current or proposed processing purpose, who is controller,
   processor, or joint controller, and what PDPL lawful basis applies?
2. Which fields are personal, sensitive, financial, inferred, or anonymous;
   what is the minimum necessary collection; and which current fields or logs
   must be removed or changed?
3. What Arabic/English notices and consent records are required for accounts,
   recommendations, research, support, cookies/analytics, marketing, and future
   bank/application flows?
4. What retention schedule and deletion/withdrawal workflow is required for
   every data class, backup, audit record, log, research artifact, and vendor?
5. What data-subject access, correction, deletion, objection, portability, and
   complaint processes must be implemented and evidenced?
6. For each proposed Vercel/Supabase region and subprocessor, what transfer
   mechanism, transfer-risk assessment, localization requirement, contract,
   and approval is required? Which production region is legally acceptable?
7. Are the security, breach-response, access-review, audit, encryption,
   secrets, and vendor-management controls sufficient? Identify mandatory
   remediation and notification timelines.
8. May privacy-preserving analytics be used; for what purpose, consent,
   minimization, retention, and opt-out design?

## Exact questions for SAMA or the authorized liaison

1. Does the currently proposed informational comparison and deterministic
   recommendation model fall within a SAMA licensing perimeter? Identify the
   applicable rule and required written authorization.
2. Would any application forwarding, offer receipt/processing, bank-document
   collection, customer-data exchange, or bank integration require an
   aggregation or other licence, and at what point in design/testing?
3. Is any described model eligible for the Regulatory Sandbox when an
   aggregation licensing route exists? What may be tested with dummy data
   before written permission?
4. How do commissions, CPA, referrals, sponsored placement, or issuer payment
   affect licensing, non-preference, disclosure, and conflict controls?
5. What bank agreements, data-sharing approvals, cybersecurity controls,
   hosting/data-location constraints, operational roles, complaints handling,
   and audit/reporting are prerequisites?
6. What exact written evidence would SAMA expect before a Production decision,
   and which authority issues it?

## Required written conclusion matrix

| Capability/decision | Reviewer | Permitted now? | Licence/approval/contract | Mandatory controls | Evidence reference | Review/expiry date | Owner decision |
|---|---|---|---|---|---|---|---|
| Private synthetic staging | Pending | Pending | Pending | Pending | Pending | Pending | Pending |
| Public informational catalog | Pending | Pending | Pending | Pending | Pending | Pending | Pending |
| Accounts/personalization | Pending | Pending | Pending | Pending | Pending | Pending | Pending |
| Production region/transfers | Pending | Pending | Pending | Pending | Pending | Pending | Pending |
| Application/document forwarding | Pending | Pending | Pending | Pending | Pending | Pending | Prohibited pending decision |
| Bank integration/data exchange | Pending | Pending | Pending | Pending | Pending | Pending | Prohibited pending decision |
| Commissions/referrals/paid ranking | Pending | Pending | Pending | Pending | Pending | Pending | Prohibited pending decision |
| Payments | Pending | Pending | Pending | Pending | Pending | Pending | Prohibited pending decision |

An unanswered question, informal conversation, AI analysis, or silence is not
approval. The owner must record whether each mandatory condition is accepted,
rejected, or deferred. Any unresolved production perimeter, privacy transfer,
licence, or contract condition keeps Production prohibited.
