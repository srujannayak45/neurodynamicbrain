---
name: prompt-gates
effector: exempt — this skill IS the gate loop; the procedure has no separable effector
description: >
  Run a task through the Gate loop (G0 INTENT → G1 RECALL → G2 SCOPE → G3 BUILD → G4 VERIFY → G5 LEARN),
  consulting the brain first. Use for any ambiguous, high-blast-radius, or design-shaped task —
  especially deploy/fire/apply/merge work — to avoid re-derivation and clarification round-trips. Skip
  for terse, unambiguous, low-risk asks.
---

# Prompt Gates — the token-economical task loop

Full spec in `PROTOCOL.md`; interpretation rules in `B-002`. This skill runs the loop.

## The gates

- **G0 · INTENT** — Establish goal + why. If the user gave intent (or the shorthand
  `>> goal | why: | touch: | done:`), echo it in one line and treat it as a binding contract. If not,
  infer it, state your one-line read, proceed — don't stall on questions the brain or code can answer.
- **G1 · RECALL** — `grep INDEX.md` for the `@tags` matching this task; read ONLY the matched cells;
  reuse cached patterns. Do not re-derive what's already known (this is the token leak).
- **G2 · SCOPE** — Fence it: what to touch / not touch / which branch / the done-when observable.
- **G3 · BUILD** — Implement against the fence.
- **G4 · VERIFY** — Run the done-when observable (run it, check the row, hit the endpoint); report plainly.
  Mandatory for deploy / fire / `terraform apply` / merge — the user under-asks for this; do it anyway.
- **G5 · LEARN** — If a durable, reusable pattern emerged, write it back: new `B-NNN` cell + INDEX line,
  tagged, `[[B-NNN]]`-linked (procedure in PROTOCOL.md). Promote anything spanning >1 project.

## Tag map for G1 recall
`@user @prompting @git @workflow @infra @code @reference @gotcha @meta @llm @docker @auth`
