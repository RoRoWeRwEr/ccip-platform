# CCIP Professional Testing Plan

**Version:** 1.0

**Prepared:** 2026-08-18

**Environment:** protected private Preview and synthetic-only staging

**Status:** execution-ready plan; not acceptance evidence or Production approval

## Purpose and boundaries

This plan governs professional, moderated acceptance testing of CCIP's Arabic
and English journeys. Testing is limited to fictional identities, synthetic
cards, and invented spending scenarios. Testers must not enter or disclose
real income, card numbers, bank relationships, debts, credentials, documents,
or other personal or financial information. Production, public access, bank
integration, application forwarding, paid placement, referrals, and payments
are outside scope.

The operational package consists of this plan, the
[tester-access workflow](TESTER_ACCESS_WORKFLOW.md),
[NDA requirements checklist](NDA_REQUIREMENTS_CHECKLIST.md),
[consent process](CONSENT_PROCESS.md), and
[feedback template](FEEDBACK_TEMPLATE.md). The moderator script, scoring
formula, and acceptance thresholds remain authoritative in
[`../PHASE_10_USER_RESEARCH.md`](../PHASE_10_USER_RESEARCH.md).

## Objectives

1. Verify that representative testers can discover, compare, calculate, and
   explain recommendations without facilitator correction.
2. Confirm equivalent Arabic/English meaning, trust, provenance, and
   no-guarantee comprehension.
3. Exercise keyboard, screen-reader, focus, zoom, RTL/LTR, responsive, error,
   and recovery behavior through human observation.
4. Detect misleading output, discriminatory ranking, authorization leakage,
   privacy exposure, or unsafe data collection before any release decision.
5. Produce traceable, de-identified findings with owners, severity, resolution,
   and dated retest evidence.

## Governance and roles

| Role | Accountability |
|---|---|
| Owner/product lead | Approves protocol, cohort, incentives/cost, systems, retention, exceptions, and final disposition |
| Test manager | Maintains schedule, codes, access register, checklists, findings, and gate report |
| Privacy/legal reviewer | Approves notice, consent, recording, NDA use, storage, access, transfer, retention, deletion, and withdrawal before recruitment |
| Moderator | Delivers the approved script consistently, avoids coaching during scored tasks, and stops unsafe sessions |
| Native-language reviewer | Confirms Arabic/English equivalence and reviews material wording findings |
| Accessibility specialist | Performs manual assistive-technology tests and classifies accessibility impact |
| Security contact | Receives security/privacy escalations and coordinates containment |
| Analyst | Aggregates only de-identified results and applies approved scoring rules |
| Tester | Follows the scenario, data restrictions, confidentiality terms, and consent choices |

The moderator must not be the sole reviewer of their own material findings.
Security, privacy, discriminatory-ranking, and bilingual-meaning findings need
review by the corresponding accountable role.

## Entry criteria

- [ ] Owner-approved protocol version, sample, languages, incentive, and dates.
- [ ] Qualified privacy/legal approval of notice, consent, recording, NDA,
      restricted storage, retention, deletion, and withdrawal arrangements.
- [ ] Protected Preview uses Vercel Authentication and synthetic-only staging.
- [ ] Health/readiness pass; expected commit and environment are recorded.
- [ ] Synthetic accounts/scenarios contain no real data.
- [ ] Each tester has a random participant code; the identity-to-code key is
      restricted and separate from observations.
- [ ] Least-privilege, time-bounded access and an accountable sponsor are ready.
- [ ] English and Arabic materials have native-language approval.
- [ ] Stop rules, incident contacts, support channel, and revocation owner are
      confirmed.
- [ ] Feedback, accessibility, access, consent, withdrawal, and deletion logs
      are ready in owner-approved restricted systems.

## Cohort and coverage

The minimum directional sample is ten completed participants: at least five
primarily Arabic sessions and five primarily English sessions. Include
first-card, cashback/rewards, and travel-oriented familiarity, plus manual
accessibility coverage. This supports usability direction only, not
population-level or statistical claims.

Use synthetic scenario attributes to cover income bands, banks, networks, and
reward types. Do not collect corresponding real participant financial data or
infer sensitive traits. Collect demographic information only when separately
justified, approved, disclosed, consented to, minimized, and necessary.

## Test matrix

| Area | Required test | Evidence | Pass condition |
|---|---|---|---|
| Discovery | Find a suitable fictional card and identify source/effective date | Task score and observation | Completed without correction |
| Comparison | Compare two cards and state the material tradeoff | Task score and observation | Completed without correction |
| Calculator | Explain reward, fee, net value, and one limitation | Task score and observation | Correct explanation without coaching |
| Recommendation | Explain rank, reasons, context, and no guarantee | Task score and observation | No guaranteed-outcome misunderstanding |
| Correction | Find the correction/stale-data path | Task score and observation | Path and purpose understood |
| Bilingual parity | Compare meaning, labels, number/currency, and order | Native-language review | No material mismatch |
| Accessibility | Keyboard, screen reader, focus, 200% zoom, 320px, RTL/LTR | Manual sheet | No unresolved Blocking finding |
| Privacy/security | Attempt approved negative paths with synthetic data | Redacted observation | No data/authorization leak |
| Resilience | Observe approved empty/error/retry states | Redacted observation | Safe, comprehensible recovery |

## Session procedure

1. Verify eligibility, approved NDA determination, consent version, and access
   readiness without copying identity data into Git.
2. Confirm identity privately, read the approved notice, record participation
   consent, then request recording consent separately.
3. Give the tester a participant code, synthetic scenario, support route,
   prohibited-data reminder, and expiring access instructions.
4. Record environment, build, language, device, browser, and assistive
   technology, then follow the authoritative script.
5. Run scored tasks without correction. Use neutral probes only after fixing
   the score.
6. Record de-identified observations and immediately escalate critical issues.
7. Capture feedback with the standard template and confirm material points.
8. Revoke access at session end or expiry and verify revocation.
9. Aggregate results; triage, remediate, and retest before the gate decision.

## Severity and stop rules

| Severity | Definition | Required action |
|---|---|---|
| Blocking | Privacy/secret exposure, cross-user/cross-bank access, material guaranteed-outcome claim, discriminatory ranking, unsafe publication, consent failure, or critical task/accessibility failure | Stop affected path, preserve restricted evidence, revoke if needed, notify accountable roles, remediate, and retest |
| Important | Material comprehension, parity, workflow, accessibility, reliability, or data-quality defect with a workaround | Assign owner/due date; fix or obtain authorized disposition before closure |
| Minor | Localized friction or cosmetic defect without material impact | Track, prioritize, and verify if fixed |
| Observation | Preference or signal without a demonstrated defect | Aggregate for review; do not treat as pass/fail |

Stop immediately if real personal/financial data is disclosed, the participant
withdraws, access controls fail, recording occurs without consent, or continued
participation may cause harm.

## Exit criteria and deliverables

The gate passes only when the research protocol's sample and per-language
thresholds are met; required task, comprehension, parity, accessibility, and
cohort evidence is complete; all access is revoked; withdrawal/deletion is
reconciled; no Blocking finding remains; Important findings have an approved
resolution; and the owner signs the gate decision. Research does not constitute
legal, regulatory, or Production approval.

Deliver a cohort summary, per-language calculations, accessibility report,
findings/retest ledger, access-revocation reconciliation,
consent/withdrawal/deletion reconciliation, and restricted signed gate record.

## Automation boundary

Automation may generate codes, provision expiring access after approval,
remind, revoke, validate fields, calculate scores, and produce de-identified
dashboards. It must not infer consent, sign an NDA, approve a participant,
interpret legal terms, decide material severity alone, store recordings in an
unapproved system, or mark a gate Pass without human evidence.
