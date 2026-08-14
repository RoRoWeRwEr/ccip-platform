# CCIP AI Handoff

The canonical, complete startup and handoff protocol is
[`AI_AGENT_HANDOFF.md`](AI_AGENT_HANDOFF.md). This short-name governance file
exists for discoverability and compatibility; it does not define a second
execution ledger.

Before doing any work:

1. Fetch and inspect current `main`, `origin/main`, the working tree, recent
   commits, open PRs, and current GitHub Actions.
2. Follow the complete reading order in
   [`AI_AGENT_HANDOFF.md`](AI_AGENT_HANDOFF.md).
3. Treat [`EXECUTION_STATUS.md`](EXECUTION_STATUS.md) as the sole live resume
   point and [`PROJECT_DASHBOARD.md`](PROJECT_DASHBOARD.md) as the program
   baseline. If they lag the repository or GitHub, current evidence wins and
   the stale governance document must be corrected in scope.
4. Never duplicate or overwrite dirty work. Continue an existing task when it
   owns the active changes; use a new task only after the prior atomic delivery
   is clean and recorded.

Exact next execution work must always be copied from the newest verified
`EXECUTION_STATUS.md`, not from this compatibility file.

## Verified current handoff

At `main` commit `420a886`, 27 of 30 roadmap milestones are complete (90%).
Private Vercel/Supabase staging is approved for technical validation with
synthetic/test data only. P9.2 remains blocked until the owner provisions the
separate staging projects, scoped deployment authorization, required
environment values, and an owner-verified staging administrator identity.
After those inputs exist, deploy the exact green `main` commit, record non-
secret evidence, and only then begin P9.3. Production approval and Saudi legal/
regulatory compliance remain explicitly outside this staging decision.

D-010 additionally prohibits production, real personal/financial data,
application forwarding, bank-document collection, commissions, paid referrals,
and bank integrations until applicable requirements are formally resolved.
Treat the regulatory assessment as AI-generated risk analysis, not legal advice
or approval. Consult `docs/DECISION_LOG.md` for verified official-source facts,
assessment hypotheses, and the questions reserved for qualified Saudi counsel
or SAMA.
