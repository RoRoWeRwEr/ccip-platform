# P9.3 Operational Verification Record

**Date:** 2026-08-18  
**Environment:** private Vercel Preview and separate Frankfurt Supabase staging  
**Deployed application commit:** `626ef83668e59c8bd406b3639b34bb410300db93`  
**Deployment:** `dpl_EBSvYAnmRR3EJjatNLK38CCLCsEv` (`READY`, Preview,
Vercel Authentication, `fra1`)  
**Data boundary:** synthetic/test data only

This record closes the executable P9.3 verification scope. It is technical
staging evidence, not production approval, legal advice, SAMA approval, or a
claim that the synthetic catalog represents real Saudi card products.

## Observed results

| Area | Result | Evidence |
|---|---|---|
| Administrator bootstrap | Pass | The owner approved the staging-only procedure. Against the sole owner-created staging identity, the `PLATFORM_ADMINISTRATOR` assignment was created, verified, revoked, verified absent, reassigned, and verified as the only active final assignment. No identifier or credential was recorded. |
| Administrator access | Pass | Before bootstrap, `/en/admin` concealed access with a localized 404. After final reassignment, the signed-in account reached the GLOBAL administration interface. |
| Database | Pass | Clean migration replay succeeded. All 22 pgTAP files and 538/538 assertions passed after the isolated VM clock stabilized. The staging lifecycle recorded one verified revocation and one final active platform-administrator assignment. |
| Synthetic publication | Pass with limitation | Two synthetic banks and cards, bilingual snapshots, fees, benefits, rewards, and controlled publication records were loaded. Ten fixture publication records reached `PUBLISHED`; two cards became public and recommendation-eligible. Full two-person UI publication cannot be demonstrated with only one owner-created auth identity; database workflow and negative BANK/GLOBAL paths remain covered by pgTAP. |
| Public catalog | Pass | English LTR and Arabic RTL catalog, search/list, detail, compare, calculator, and recommendation routes rendered on desktop/mobile. Two published synthetic cards are visible. |
| Recommendation | Pass | With synthetic spending and salary inputs, both eligible cards ranked deterministically. The result exposed annual reward, fee, net annual value, catalog version, assumptions, limitations, and ranking reasons. |
| Authenticated user | Pass | Sign-in, account protection, card saving, account persistence, and recommendation-history persistence worked for the owner-created staging account. |
| Negative access | Pass | Unauthenticated account/admin requests redirected safely to localized authentication. Pre-bootstrap administration was concealed. Automated integration, E2E, security, and pgTAP suites cover cross-user and BANK/GLOBAL negative paths. |
| Health/readiness | Pass | `/api/health` and `/api/ready` returned 200 with request IDs, `no-store`, secret-safe bodies, exact application version, and bounded Supabase latency; the recorded P9.3 readiness probe was 832 ms. |
| Browser/UI | Pass | Ten representative English/Arabic routes were checked at desktop and mobile sizes with correct LTR/RTL direction, no horizontal overflow, broken images, framework overlays, or browser-console errors after fixture stabilization. |
| Runtime behavior | Pass with recorded setup event | Vercel showed 392 `200`, 156 `304`, three `500`, one `307`, and one `404` responses in the two-hour setup window. The three 500s were one transient VM-clock/JWT failure and two invalid synthetic-enum fixture failures. The fixture was corrected without application changes; the final two-minute verification window contained 70 `200` and 55 `304` responses and no 5xx response. |
| Secrets/privacy | Pass | No service-role key is required by the deployed application. No credential, auth identifier, real personal/financial data, or production data was committed to this record or the screenshots. |
| Rollback | Procedure verified; exercise constrained | The immutable deployment and exact last-green commit were identified, and the repository runbook forbids history rewrites and migration rollback. The project had only one immutable Preview, so there was no second deployment target to promote or roll back between. This is an Important operational limitation for any later launch rehearsal, not authority to create Production. |
| Alerting | Threshold verified; delivery integration absent | The runbook threshold is readiness failure for five consecutive minutes or server-error rate above 2% for five minutes. Runtime log grouping supports detection, but no owner-selected paging/alert destination is configured. This is an Important production-readiness gap and does not block private staging use. |

## Validation evidence

- Unit/component: 73/73 passed.
- Local-Supabase integration: 10/10 passed.
- Desktop/mobile Playwright E2E: 32/32 passed.
- Database: 22 files, 538/538 pgTAP assertions passed after clean replay.
- Format, lint, strict typecheck, production build, bundle budgets, repository
  policy, Markdown links, YAML validation, and whitespace checks passed in the
  recorded P9.3 validation run.
- `npm audit` reported zero vulnerabilities.
- Application CI run 32034124290 and Repository Policy run 32034124293 passed
  for the deployed code commit.

## Representative interface evidence

The screenshots contain synthetic data only and are committed as QA evidence:

- [English desktop](evidence/p9-3/en-desktop.png)
- [Arabic desktop](evidence/p9-3/ar-desktop.png)
- [English catalog mobile](evidence/p9-3/en-cards-mobile.png)
- [Arabic recommendation mobile](evidence/p9-3/ar-recommendation-mobile.png)

## P9.3 conclusion

P9.3 is complete for the approved private synthetic staging boundary. No known
Blocking technical finding prevents continued owner evaluation as a normal
staging user. The alert destination, a second immutable rollback target,
representative-scale catalog evidence, and moderated user research remain
Important Phase 10/launch-gate evidence. Production and all real-data or
regulated capabilities remain prohibited under decision D-010.

**Exactly one next action:** execute the Phase 10 CCIP v1 completion review and
report every unmet Definition-of-Done gate without representing the platform as
production-ready.
