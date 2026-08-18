# CCIP Professional Testing Feedback Template

Use one restricted record per session or finding. Do not include a tester's
name, contact, employer, credentials, real finances, raw recording, secret, or
private URL. Use participant codes and restricted evidence references only.

## Session record

| Field | Value |
|---|---|
| Session ID / participant code | |
| Date/time and moderator | |
| Protocol, notice, consent, and NDA status/version | |
| Environment and build/commit | Protected private synthetic staging / |
| Primary language | Arabic / English |
| Synthetic persona/scenario ID | |
| Device, browser, viewport | |
| Assistive technology/input | |
| Recording choice | None / audio / video / screen / approved other |
| Access provisioned/revoked/verified | |
| Disposition | Completed / stopped / withdrawn / no-show |

## Critical-task scoring

Score `1` only when completed without facilitator correction; otherwise `0`.

| Task | Score | Time/attempts | Observed path | Understanding/expectation | Finding IDs |
|---|---:|---|---|---|---|
| Discover a suitable fictional card | | | | | |
| Identify source and effective date | | | | | |
| Compare two cards and explain tradeoff | | | | | |
| Explain calculator reward, fee, net value, limitation | | | | | |
| Explain recommendation rank/reasons/context | | | | | |
| State that eligibility/savings are not guaranteed | | | | | |
| Find correction/stale-data path | | | | | |

Use the authoritative Phase 10 definitions for the critical-task calculation.

## Experience ratings

Use `1 = strongly disagree` through `5 = strongly agree`, plus `N/A`.

| Statement | Rating | Why? |
|---|---:|---|
| This was clearly decision support, not a bank or financial advice. | | |
| I understood the source and effective date. | | |
| I understood important costs and tradeoffs. | | |
| I understood why the first recommendation ranked first. | | |
| Assumptions and limitations were clear. | | |
| Language and number/currency presentation were clear. | | |
| I could complete the journey with my device/assistive technology. | | |
| I trusted the correction/stale-data process. | | |

## Open feedback

1. What was most useful?
2. What was confusing, missing, or less trustworthy?
3. What did you expect where expectation and behavior differed?
4. Which statement, number, source, date, or interaction caused that reaction?
5. What is the single most important improvement before release?
6. Did anything imply guaranteed approval, eligibility, savings, or advice?
7. Did anything feel unfair or different due to language or the scenario?
8. Was there an accessibility barrier? State task, technology, and impact.

## Finding record

| Field | Value |
|---|---|
| Finding ID / session ID | |
| Title | |
| Area | Functionality / content / bilingual / accessibility / privacy / security / data quality / fairness / performance |
| Severity | Blocking / Important / Minor / Observation |
| Environment/build/language | |
| Synthetic scenario/preconditions | |
| Steps to reproduce | 1.  2.  3. |
| Expected result | |
| Actual result | |
| User impact/frequency | |
| Redacted evidence reference | |
| Related requirement/risk | |
| Owner/target date | |
| Disposition | Open / fix / duplicate / not reproducible / authorized risk disposition |
| Fix reference | |
| Retest date/reviewer/result/evidence | |

## Session closeout

- [ ] Material feedback confirmed with the tester.
- [ ] Notes/attachments contain no real personal/financial data.
- [ ] Recording matches the consent choice.
- [ ] Access revoked and independently verified.
- [ ] Stop, withdrawal, incident, and deletion actions recorded if applicable.
- [ ] Every defect has one ID, severity, owner, and evidence reference.
- [ ] Tester received approved contact and withdrawal instructions.
- [ ] Record stored only in the approved restricted system.

## Aggregate report

| Metric | Overall | Arabic | English | Threshold/result |
|---|---:|---:|---:|---|
| Participants completed | | | | At least 10; at least 5/language |
| Critical-task pass rate | | | | At least 90% overall and per language |
| Provenance/date comprehension | | | | No material unresolved issue |
| No-guarantee comprehension | | | | No material misunderstanding |
| Manual accessibility | | | | No unresolved Blocking finding |
| Blocking / Important / Minor findings | | | | 0 unresolved Blocking |
| Access revocation verified | | | | 100% |
| Consent/withdrawal/deletion reconciled | | | | 100% or approved lawful exception |

Final recommendation: `Pass / Pass with authorized conditions / Fail and
retest`. Record owner, date, conditions, risks, and Phase 10 evidence references.
