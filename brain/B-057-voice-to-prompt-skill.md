---
id: B-057
tags: [prompting, user, meta]
scope: global
hook: Dictated/voice messages must be distilled to a structured prompt before acting — the voice-to-prompt skill does it (classify sender+intent+tone → strip to lead verb → emit >> shorthand → gate-route)
---

# Voice → Prompt translation (skill `voice-to-prompt`)

Operator messages are frequently DICTATED — filler ("um/uh/basically"), run-ons, self-corrections
("do A… I mean B"), rambling preamble, no punctuation. Don't act on the raw transcript; distill it first.

The procedure is the **`voice-to-prompt`** skill. It:
1. Loads the stable CACHED prefix once — WHO ([[B-001]]), HOW they prompt ([[B-002]]), the gate loop
   (PROTOCOL.md). These rarely change → prompt-cache them ([[B-023]]), never re-derive.
2. CLASSIFIES the message — **type** (command/question/correction/status/decision/handoff/meta) +
   **tone** (directive/exploratory/frustrated/casual). Tone sets how much to confirm, not what to do.
3. DISTILLS per [[B-002]] — lead-verb extraction, last-stated-intent-wins on self-corrections, resolve
   every it/this/that to a concrete file/branch/run/PR, honor any fence literally.
4. EMITS the brain shorthand `>> goal | why: | touch: | done:` (the G0/G2 contract), shown back in one
   line, then proceeds — applying the sender's standing contracts automatically (git identity, no AI
   footer, isolated worktrees, verify-on-deploy).
5. ROUTES through the gates; talks to the model with MINIMAL tokens (distilled line + only G1-matched
   cells), and uses CACHING + BATCHING when a message fans out — stable prefix cached, N independent
   units in ONE batch.

Trigger: message reads like speech. Skip: already-tight typed prompts, slash-commands, and trivial asks
("y", "merge it", "handoff" — act directly). Literal instruction always beats distilled intent ([[B-002]] r3).
