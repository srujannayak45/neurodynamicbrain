---
id: B-102
tags: [infra, auth, gotcha]
scope: debugging OIDC federation failures (GHA, GCP-WIF-to-AWS, any AssumeRoleWithWebIdentity caller)
hook: CloudTrail lookup-events for AssumeRoleWithWebIdentity is unreliable — STS logs to us-east-1 globally, and pre-assume failures often don't surface at all
---

# CloudTrail `lookup-events` for `AssumeRoleWithWebIdentity` — two traps

**Why:** Operators debugging "the trust policy looks right, why is OIDC failing?" reach for
`aws cloudtrail lookup-events --lookup-attributes
AttributeKey=EventName,AttributeValue=AssumeRoleWithWebIdentity` to see what the federated caller
actually sent. The query often returns 0 events even though the call provably happened — wasting time
chasing "is OIDC even reaching AWS?" when in fact it's reaching AWS and being rejected.

**Two traps that cause the empty-result:**

1. **STS is a global service**, and `AssumeRoleWithWebIdentity` events are recorded in the
   `us-east-1` trail regardless of which region the role lives in or which region you called from. If
   your `lookup-events` query targets `--region <other>`, you'll see nothing. Add `--region us-east-1`
   (or query CloudTrail Lake / Event History in the console with the right region selected).

2. **`AccessDenied` BEFORE role assumption (i.e. the trust policy rejected the token) may not surface
   via `lookup-events`** at all. CloudTrail's management-events stream is best-effort and pre-assume
   failures are inconsistently recorded. Even after the full 15-min propagation window the event can be
   silently absent. Don't infer "the call didn't happen" from "I can't find it in lookup-events".

**How to apply:**
- Always query CloudTrail for `AssumeRoleWithWebIdentity` with `--region us-east-1`.
- If the event isn't there and you're sure the call happened, **don't pivot to "the call must be going
  somewhere else"**. Treat the trust-policy rejection hypothesis as still on the table. Diagnose from
  the caller's error message + the trust-policy contents directly:
  - On GitHub Actions, the runner step output shows the full STS error including the `sub` claim that
    was sent (see [[B-099]] for the sub-claim shape).
  - For GCP Workload Identity Federation → AWS, use the WIF audit log on the GCP side + the failing CLI output.
- For consistent visibility into failed AssumeRole calls, enable **CloudTrail data events** or **IAM
  Access Analyzer's external-access findings** — those cover the gap management-events leave.
- The `aud`/`iss` claims, if needed, come from decoding the OIDC token directly (`jwt.io` offline, or
  `curl https://token.actions.githubusercontent.com/.well-known/openid-configuration`).

## Related
- [[B-099]] GHA OIDC sub-claim rewrite — the most common cause of these failures.
- [[B-091]] TF-only — once you identify the trust-policy fix, drive it through TF.
