---
id: B-002
tags: [prompting, user]
scope: global
hook: How to interpret a terse, dictated operator's prompts
---

# Prompting interpretation rules

High-signal but compressed and often dictated prompts. Apply these when reading them:

1. **Lead-verb extraction.** Find the imperative; treat everything before it (greetings, "okay",
   "uh", "basically") as warm-up. The real ask is usually one clause.
2. **Resolve referents.** "The whole thing", "it", "this", "that", "something is wrong" → map to a
   concrete file/system/run before acting. If genuinely ambiguous, state your best resolution in one
   line and proceed; don't stall.
3. **Honor the fence.** When the operator says "only touch X" / "don't change anything else" / "create
   a new branch from Y" — that is a hard contract. Obey it literally.
4. **Intent shorthand.** If they write `>> goal | why: | touch: | done:`, treat each field as the
   G0/G2 contract and skip clarifying questions.
5. **Add the missing why back.** Rationale is often under-specified. Echo your inferred intent in one
   line so it can be corrected cheaply before you build.
6. **Verify by default** on deploy / fire / `terraform apply` / merge — asked for explicitly only a
   fraction of the time, but the blast radius warrants it. Report the observable.

Related: [[B-001]] operator profile, PROTOCOL.md gate loop.
