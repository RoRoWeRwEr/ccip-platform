# CCIP Tester-Access Workflow

## Control objective

Give an approved tester the minimum private-staging access needed for one
session, then revoke and evidence it. Never grant Production, Supabase
dashboard, Vercel project, repository, administrator, service-role, or shared-
account access to an external tester.

## Access model

- Use an individual, expiring identity protected by the private Preview's
  authentication control. Never share credentials.
- Use an ordinary application account only when an authenticated journey is
  approved. Approved internal personnel perform administrative testing.
- Bind access to participant code, sponsor, purpose, environment, route/role,
  start, expiry, and revocation result.
- Keep identity/contact data in the restricted participant system; use only the
  participant code in de-identified evidence.
- Default window: session start through two hours after scheduled end; absolute
  maximum 24 hours unless owner and security approve an exception.

## End-to-end workflow

1. **Request:** record participant code, sponsor, approved protocol/consent/NDA
   versions, language, session, route class, accommodation, and expiry.
2. **Approve:** confirm eligibility, legal/privacy approvals, and least
   privilege. Separate requester and approver where staffing permits.
3. **Provision:** create an individual test identity using an expiring provider
   invitation. Grant private Preview and only necessary ordinary-user access.
4. **Verify:** check staging label/build, protection, synthetic scenario,
   ordinary-user authorization, admin denial, and absence of cross-user data.
5. **Deliver:** send instructions through the approved channel, stating expiry,
   purpose, no-sharing/no-real-data rules, support, and incident route.
6. **Monitor:** moderator attends; approved minimized logs only. An
   auth/authorization anomaly triggers stop and escalation.
7. **Revoke:** at withdrawal, no-show cutoff, end, incident, or expiry—whichever
   comes first—disable entitlements and invalidate the approved test session.
8. **Reconcile:** from a fresh browser context verify access failure; record
   revocation and independent verification. Reconcile daily and at study close.

## Access register template

Store this in the approved restricted system.

| Request ID | Participant code | Sponsor | Environment | Permission/route | Start/expiry | Approved by/at | Provisioned by/at | Revoked by/at | Verified by/at | Result/exception |
|---|---|---|---|---|---|---|---|---|---|---|
| Pending | Pending | Pending | Private synthetic staging | Pending | Pending | Pending | Pending | Pending | Pending | Pending |

## Exceptions and incidents

- Lost/forwarded invitation: revoke immediately; reissue only after approval.
- Real data entered: stop, isolate access, notify privacy/security, preserve
  minimal evidence, and follow the approved deletion/incident process.
- Excess privilege or cross-user visibility: stop affected testing, revoke,
  preserve restricted evidence, and classify Blocking.
- Revocation failure: treat access as active and keep the gate open until
  independent verification passes.
- More time requested: approve and record an extension; never silently remove
  expiry.

## Automation blueprint

An approved identity workflow may implement `request -> approve -> provision
-> remind -> expire -> verify -> reconcile` with immutable audit events,
single-use invitations, role allowlists, maximum-expiry validation, automatic
revocation, overdue alerts, and a participant-code-only daily report. Human
approval remains mandatory before provisioning or extension.
