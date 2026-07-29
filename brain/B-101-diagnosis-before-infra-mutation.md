---
id: B-101
tags: [workflow, gotcha, meta, process, infra]
scope: any time someone proposes a destructive cloud/infra mutation to "fix" a symptom
hook: A proposed fix being the right shape doesn't make the diagnosis right — verify the SDK call path, the actual error string, AND egress/NetworkPolicy constraints BEFORE mutating infra
---

# Diagnosis before mutation: verify the call path before destructive infra changes

**Why:** Engineers (including subagents and human teammates) regularly propose "obvious" infra
mutations to fix a symptom — "disable Private DNS on the endpoint", "drop the security group rule",
"disable the NetworkPolicy", "flip the managed-login setting". The proposal is often well-shaped
infrastructurally (it WOULD change the system) but built on a **misdiagnosis** of what the error
actually is. Apply it and one of two bad outcomes:

1. The symptom doesn't go away (because the diagnosis was wrong), and now you've also introduced a
   regression elsewhere because the mutation had collateral effects you didn't model.
2. The mutation silently breaks something the diagnosis didn't even consider — classically,
   **NetworkPolicy / egress constraints** that depend on the very DNS or endpoint you just disabled
   (e.g. pods restricted to a private CIDR :443 get black-holed when you disable a VPC endpoint's
   private DNS and force resolution to public IPs outside the allowed CIDR).

**Failure pattern (illustration, generic shape):**
- Symptom: `/auth/login` returns 4xx/5xx.
- Proposed fix: disable Private DNS on the auth-service VPC endpoint so the call uses public DNS.
- Real root cause (found by reading the actual error + the SDK call path): the user pool's only app
  clients are `client_credentials`-only, so the SDK call `USER_PASSWORD_AUTH` is **structurally
  rejected at the pool level** — DNS resolution had nothing to do with it.
- Collateral the proposal didn't model: even if the diagnosis HAD been right, the caller pod's
  NetworkPolicy restricts egress to the in-VPC CIDR `:443`, so forcing public DNS would have
  black-holed every other call too.

**How to apply (verification protocol before any destructive infra mutation):**
1. **Read the actual error string**, not the symptom. Capture the SDK/HTTP error verbatim (status,
   error code, message, request id). Match it to the SDK call path — what API, what params?
2. **Walk the call path end-to-end** — client → DNS → endpoint → service → auth → policy. The failure
   could be at any hop. Don't assume the hop nearest the proposed fix is the one that's broken.
3. **Check NetworkPolicy / egress / SG constraints** on the caller side before changing DNS resolution
   or endpoint reachability. A "fix DNS" mutation that moves traffic outside the allowed egress CIDR is
   a regression even if the DNS change itself works.
4. **Reproduce the failure with the actual call**, not a paraphrased version.
5. **Disprove the proposed fix before applying it** — what would the world look like if the diagnosis
   were wrong? Can the mutation still be justified under that scenario? If not, gather more evidence.
6. **The right-shape rule**: "this proposal is the kind of thing that would fix that kind of problem"
   is not evidence the diagnosis is correct. It's evidence the proposer has a vocabulary, not that
   they've understood the failure.

**The G4 link:** This is the VERIFY gate applied to diagnoses, not just to fixes. Verify the diagnosis
before building the fix. Procedure = skill `diagnose-before-fix`.

## Related
- [[B-010]] No security shortcuts — widening scope is a wrong-shape mutation.
- [[B-091]] TF-only — destructive infra mutations via CLI compound the risk.
- [[B-102]] CloudTrail lookups are unreliable — don't infer "the call didn't happen" from empty results.
