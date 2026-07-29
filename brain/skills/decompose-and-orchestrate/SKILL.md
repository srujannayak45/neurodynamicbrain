---
name: decompose-and-orchestrate
effector: exempt — this skill IS the decomposition method; its effector is the subagent/workflow fan-out tool + per-partition agents
description: >
  Dissect a large or fuzzy problem into a decomposed, independently-verifiable solution, then run it —
  solo when small, fanned out across subagents when the work-list is wide. Use for any task that is too
  big for one pass, sweeps many files/surfaces/items, or needs independent verification before
  committing (audits, migrations, broad remaps, multi-subsystem reviews, "do X across the whole
  codebase"). Fires on "break this down", "divide into tasks", "trigger multiple subagents", "accelerate
  with parallelism". SKIP for a single-file edit, a one-fact lookup, or a terse unambiguous ask.
---

# Decompose & Orchestrate — turn a big/fuzzy problem into a verified, parallel solution

The procedure for the recurring move: *a problem too large or too uncertain to one-shot.* It sits on
top of the Gate loop (G0→G5, PROTOCOL.md) and a subagent/workflow fan-out tool. The core discipline:
**never fan out before you know the shape of the work; never trust a fanned-out finding before it's verified.**

## The seven steps

1. **G0/G1 — Frame + recall.** State the goal and the *why* in one line. Grep the brain INDEX for the
   `@tags` that match; reuse cached facts instead of re-deriving them.
2. **Establish ground truth.** Find the ONE authoritative reference the whole solution maps onto and
   cache it locally so every subagent reads the same source (a spec file, an API path list, a schema,
   an inventory). This is what stops N agents from each hallucinating a different target.
3. **Scout the work-list INLINE.** Before any orchestration, discover the actual units of work cheaply
   yourself: `grep -rl` the surfaces, `ls` the modules, `git diff --name-only` the changes. Know *how
   many* things and *how they group* before you fan out.
4. **Partition into INDEPENDENT units.** Carve the work-list so units don't share mutable state — by
   file, subsystem, region, item. Independence is what makes parallelism safe. Split a huge region into
   ~10–12 tractable slices.
5. **Fan out as a pipeline: discover → map/transform → VERIFY.** One agent per unit. Default to
   `pipeline()` so each unit verifies as soon as its map completes (no barrier). Force `schema`-structured
   output so results compose without parsing. The verify stage is ADVERSARIAL and grounded: "confirm
   this LITERALLY exists in <ground-truth file>; default verified=false unless you can cite the line."
   Use a barrier (`parallel`) only when a later stage needs ALL prior results (dedup, count-zero early-exit).
6. **Synthesize + completeness-critic.** The main loop (not a subagent) collects the structured results
   into one artifact. Then ask: what's missing — a region not scanned, a claim unverified, a gap
   unmapped? Log silent caps; never let truncation read as "covered everything."
7. **Apply per-partition, then G4 verify the observable.** Mechanical transforms can themselves fan out
   — but ONLY across the same independent partitions; use `isolation:'worktree'` if they must touch
   shared files. Prove the result with the done-when observable.

## When solo, when fanned out
- **Solo:** one file, a known symbol, < ~5 units, or work that's inherently sequential.
- **Fan out:** wide work-list, independent units, or a task that benefits from independent verification
  before committing. REQUIRES explicit user opt-in ("subagents"/"parallelize"/"workflow").
- **The hybrid is usually right:** scout + ground-truth inline (steps 1–4), then one fan-out per phase
  (step 5), reading each result before launching the next phase.

## Anti-patterns
- Fanning out before scouting → no clean partition.
- No shared ground-truth file → every agent invents its own version of the target.
- Discover without an adversarial verify → plausible-but-wrong mappings survive.
- Parallel agents editing the same file → races (partition by file, or worktree-isolate — see [[B-110]]).
- A barrier where a pipeline would do → wasted wall-clock.
- Auto-applying mass edits the user hasn't seen → produce the verified manifest first, gate the writes.

## Pointers
- Gate loop: PROTOCOL.md / [[B-002]]. Cached-prefix economy: [[B-023]]. Cell [[B-067]].
- Worktree base-branch gate before fan-out: [[B-110]].
