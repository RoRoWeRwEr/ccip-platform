# Phase 10 Private-Staging Alert and Rollback Rehearsal

## Safety boundary

This checklist is limited to protected private Vercel Preview deployments and
the separate synthetic-only Supabase staging project. Do not create, promote,
alias, or enable a Production deployment. Do not perform database rollback,
rewrite Git history, expose staging publicly, or introduce real data.

## Human/external decisions required

1. Owner chooses an approved alert receiver and accountable on-call person.
   Record the service, destination owner, retention/access policy, expected
   delivery time, and cost approval; never commit receiver secrets.
2. Owner with Vercel access creates or authorizes a second immutable **Preview**
   deployment from an identified green commit. Confirm its environment is
   Preview, Vercel Authentication is enabled, and its four browser-safe values
   target only synthetic staging.
3. Owner selects a safe rehearsal window and confirms no other staging test is
   in progress.

## Alert-receiver checklist

- [ ] Receiver is a test/private destination with a named human owner.
- [ ] No secret, token, personal identifier, URL query, header, or raw error is
  included in an alert body or committed evidence.
- [ ] Readiness failure for five consecutive minutes triggers one test alert.
- [ ] Server-error rate above 2% for five minutes triggers one test alert.
- [ ] Recovery notification is defined and tested.
- [ ] Deduplication/rate limiting prevents alert storms.
- [ ] Delivery, acknowledgement, escalation, and recovery timestamps are
  recorded with secrets and personal identifiers redacted.
- [ ] A failed notification is recorded as a failed gate, not inferred Pass.

### Alert evidence sheet

| Test | Start | Threshold met | Delivered | Acknowledged | Recovered | Redacted evidence | Result/finding |
|---|---|---|---|---|---|---|---|
| Five-minute readiness failure | Pending | Pending | Pending | Pending | Pending | Pending | Pending |
| >2% server errors for five minutes | Pending | Pending | Pending | Pending | Pending | Pending | Pending |

Induce only a reversible, authorized Preview-level condition. Do not corrupt
the database, disable security, or expose secrets merely to trigger an alert.

## Second-Preview rollback rehearsal

Use Preview A as the current green baseline and Preview B as a second immutable
green commit/deployment. “Promotion” below means changing only a private test
alias or documented operator selection between protected Previews; it must not
create or target Production.

### Preconditions

- [ ] A and B are `READY`, immutable, private, and protected by Vercel
  Authentication.
- [ ] Deployment IDs, commit SHAs, creation times, `fra1` function region, and
  Preview environment are recorded.
- [ ] Both use exactly the approved Preview-scoped runtime variables and the
  synthetic-only staging database; values themselves are not captured.
- [ ] Both `/api/health` and `/api/ready` return 200, exact expected version,
  request ID, and `no-store` with bounded readiness.
- [ ] No database downgrade or migration reversal is involved. Database fixes
  are forward-only.

### Exercise

1. Record the initial private test target and run Arabic/English smoke checks.
2. Select Preview B as the private test target; record time and operator.
3. Verify authentication protection, health/readiness, catalog, comparison,
   recommendation, account protection, admin protection, browser console, and
   runtime logs using synthetic data.
4. Simulate the rollback decision using a documented non-destructive failure
   criterion; select Preview A again.
5. Repeat the same smoke checks and verify the exact A commit/version.
6. Select Preview B again only if the rehearsal plan calls for forward
   restoration and both targets remain green.
7. Record detection, decision, switch, recovery, total duration, findings, and
   final target. Remove any temporary private alias if used.

### Rehearsal evidence sheet

| Field | Evidence |
|---|---|
| Preview A deployment/commit | Pending |
| Preview B deployment/commit | Pending |
| Protection and environment check | Pending |
| Initial target and timestamp | Pending |
| Failure criterion | Pending |
| Detection/decision/switch/recovery times | Pending |
| Arabic/English smoke result | Pending |
| Health/readiness/log result | Pending |
| Final private target | Pending |
| Findings, owner, retest | Pending |

## Acceptance criteria

- Both alert thresholds deliver and recover through the owner-selected
  receiver, with acknowledged, redacted, dated evidence.
- Two immutable protected Previews are exercised without creating Production,
  changing database history, or using real data.
- Rollback selects the exact last-green Preview and verifies its version and
  critical smoke paths within the owner-approved recovery objective.
- Every failure has an owner and successful retest; no unresolved Blocking
  operational finding remains.

Preparing this checklist is automatable documentation. Choosing/configuring an
external receiver, creating the second Preview, receiving alerts, and operating
the rehearsal require a human with the relevant accounts and are not yet done.
