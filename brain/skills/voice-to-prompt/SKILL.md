---
name: voice-to-prompt
effector: exempt — generic example
description: >
  Convert a dictated/transcribed voice message into a tight, personalized, structured prompt BEFORE
  acting on it. Use whenever the incoming message reads like speech — filler words (um/uh/basically),
  run-on clauses, self-corrections, "I mean…", no punctuation, rambling preamble before the real ask.
  Classifies sender + intent + tone, strips to the lead verb, emits the brain's `>> goal | why | touch |
  done` shorthand, then routes it through the Gate loop. Skip for already-tight typed prompts and for
  slash-command invocations.
---

# Voice → Prompt — distill dictation into a structured, cached, personalized prompt

A voice message is high-signal but noisy: the real ask is usually ONE clause buried in warm-up,
self-correction, and filler. This skill turns it into the minimal structured prompt the model needs,
so the work runs on intent — not on re-parsing speech every turn. The brain is the source of WHO is
asking and HOW they prompt; this skill is the procedure over it.

## The cached prefix (load once, reuse every message)
Stable across messages → treat as the prompt-cache prefix ([[B-023]]), never re-derive:
- **WHO** — `B-001` (sender profile). Default sender = the brain owner unless the transcript names someone else.
- **HOW they prompt** — `B-002` (lead-verb extraction, resolve referents, honor the fence, verify-by-default).
- **The loop** — `PROTOCOL.md` (G0 INTENT → G5 LEARN) + the `@tag` map for recall.
Grep INDEX.md for these once at session start; they rarely change.

## Procedure (per voice message)

1. **CLASSIFY (one pass, cheap).** Tag on two axes:
   - **Type:** `command` · `question` · `correction` · `status` · `decision` · `handoff` · `meta`.
   - **Tone:** directive · exploratory · frustrated/urgent · casual. Tone sets *how much to confirm*,
     not *what* to do.
2. **DISTILL (B-002).** Drop greetings/"okay"/"um"/"basically"/"I mean". Take the imperative clause.
   Apply self-corrections (the LAST stated intent wins). Resolve every "it / this / that / the whole
   thing" to a concrete file/branch/run/PR; if truly ambiguous, pick the best and say so.
3. **PERSONALIZE.** Apply the sender's standing contracts from the brain automatically (per-repo git
   identity, no AI footer, branch off base, isolated worktrees, "don't clobber other lanes",
   verify-on-deploy). A correction ("only touch X") is a HARD fence.
4. **EMIT the structured prompt** — the brain shorthand, as tight as the ask allows:
   ```
   >> <goal, one clause> | why: <inferred intent> | touch: <files/branch/scope> | done: <observable>
   ```
   This line IS the G0/G2 contract. Show it back in ONE line so it can be corrected cheaply (B-002
   rule 5) — then proceed; don't stall on questions the brain or code answers.
5. **ROUTE through the gates (PROTOCOL).** terse + unambiguous + low-risk → just do it. ambiguous /
   high-blast / design → run the full loop. deploy / fire / apply / merge → VERIFY the observable.

## Talking to the model efficiently
- **Minimal tokens:** send the distilled `>>` line + only the cells G1-recall matched — not the raw
  transcript, not the whole brain.
- **Cache ([[B-023]]):** keep the stable prefix (WHO/HOW/loop + any large rubric) as a cached system
  block so message #2..N read from cache.
- **Batch:** when one voice message expands into N independent units, fan them into ONE batch sharing
  the cached prefix rather than N serial calls.

## Notes
- This skill PREPROCESSES; it never replaces the user's fence. If distilled intent and a literal
  instruction conflict, the literal instruction wins (B-002 rule 3).
- Don't over-formalize trivial asks ("y", "merge it", "handoff") — act.
- Cells move; verify a named file/branch/PR still exists before acting.
