---
name: diagnose-before-fix
effector: exempt — this skill is a pure-judgment verification gate (the G4 VERIFY gate applied to the diagnosis); it has no separable deterministic core
description: >
  Gate any destructive or hard-to-reverse infra/cloud mutation behind a diagnosis check.
  Fires before "disable the VPC endpoint", "drop the SG rule", "flip the managed-login setting",
  "delete and recreate", "-replace", "force apply", or any proposal to mutate shared infra to fix a
  symptom. Forces verification that the diagnosis is right (actual error string + SDK call path
  + egress/NetworkPolicy) — not merely that the fix is the right shape. Skip for reversible,
  low-blast, single-file changes.
---

# diagnose-before-fix — verify the diagnosis before mutating infra

Facts live in the brain. Cite, don't duplicate: [[B-101]] (diagnosis before mutation — right-shape ≠
right diagnosis), [[B-102]] (CloudTrail AssumeRoleWithWebIdentity lookups are unreliable — don't infer
"call didn't happen" from an empty lookup), [[B-091]] (TF-only — never CLI-mutate state), [[B-010]]
(no security shortcuts).

## When it fires
Someone (you, a subagent, or a teammate) proposes a destructive infra mutation to fix a symptom. The
proposal is often well-shaped infrastructurally but built on a misdiagnosis.

## The gate (run all before applying — [[B-101]])
1. **Read the actual error verbatim** — status, error code, message, request id. Match it to the
   SDK/HTTP call path: what API, what params? (The gap between "the auth call is rejected at the pool"
   and "the login endpoint is down" is where wrong diagnoses hide.)
2. **Walk the call path end-to-end** — client → DNS → endpoint → service → auth → policy/provider-ctx.
   Don't assume the hop nearest the proposed fix is the broken one.
3. **Check egress / NetworkPolicy / SG on the caller side** before changing DNS/endpoint reachability —
   a "fix DNS" that moves traffic outside the allowed CIDR is a regression even if the DNS change works.
4. **Reproduce with the actual call**, not a paraphrase. Beware unreliable observability ([[B-102]]).
5. **Disprove the fix:** what would the world look like if the diagnosis were wrong? If the mutation
   can't be justified under that scenario, gather more evidence first.
6. **Prefer a targeted Terraform apply + a proper managed policy** over CLI mutation ([[B-091]]) and over scope-widening ([[B-010]]).

## Done-when (G4)
You can state the root cause with a cited line of evidence (error string / call-path hop / policy), AND
you have disproven at least one plausible wrong diagnosis, BEFORE any mutation is applied.
