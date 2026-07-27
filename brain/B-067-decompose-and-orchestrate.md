---
id: B-067
tags: [meta, workflow, prompting, process, code]
scope: any large/fuzzy task across projects
hook: How to dissect a big/fuzzy problem into a decomposed, independently-verifiable solution and run it — solo when small, fanned out across subagents when the work-list is wide
---

# B-067 · Decompose & orchestrate a problem into a verified solution

The recurring move when a task is too big or too uncertain to one-shot (audits, migrations, broad
remaps, multi-subsystem reviews, "do X across the whole codebase"). Effector = a subagent/workflow
fan-out tool; procedure = skill `decompose-and-orchestrate`. Sits on the Gate loop ([[B-002]]).

## The seven steps
1. **Frame + recall** (G0/G1) — one-line goal+why; grep brain INDEX for matching `@tags`, reuse cached facts.
2. **Ground truth** — cache the ONE authoritative reference the whole solution maps onto, locally, so
   every subagent reads the same source (spec/path-list/schema/inventory). Stops N agents inventing N targets.
3. **Scout the work-list INLINE** — `grep -rl` / `ls` / `git diff --name-only` to learn *how many*
   units and *how they group* BEFORE orchestrating. (Scout inline, then pipeline over the result.)
4. **Partition into INDEPENDENT units** — carve so units don't share mutable state (by file/subsystem/
   region/item). Independence = safe parallelism. Split a huge region into ~10–12 tractable slices.
5. **Fan out as a pipeline: discover → map/transform → adversarial VERIFY** — one agent per unit,
   `schema`-structured output, `pipeline()` by default (verify each unit as its map lands; no barrier).
   Verify is grounded + skeptical: "confirm this LITERALLY exists in <ground-truth file>; default
   verified=false unless you can cite the line." Barrier (`parallel`) only when a stage needs ALL prior
   results (dedup / count-zero early-exit).
6. **Synthesize + completeness-critic** — the main loop (not a subagent) folds structured results into
   one artifact; then ask "what's missing — region unscanned, claim unverified, gap unmapped?" Log
   silent caps.
7. **Apply per-partition, then G4 verify** — mechanical transforms can fan out too, but only across the
   same independent partitions (or `isolation:'worktree'` for shared files); prove with the done-when observable.

## Solo vs fan-out
- Solo: one file / known symbol / <~5 units / inherently sequential.
- Fan out: wide independent work-list OR needs independent verification before committing. Needs
  explicit user opt-in ("subagents"/"parallelize"/"workflow").
- Hybrid (usual): scout+ground-truth inline (1–4), then one fan-out per phase (5), reading each result
  before the next phase. Stay in the loop between fan-outs.

## Anti-patterns
Fan out before scouting (no clean partition) · no shared ground-truth file (every agent invents the
target) · discover without adversarial verify (plausible-but-wrong survives) · parallel agents on the
same file (races — partition or worktree-isolate) · barrier where a pipeline fits (wasted wall-clock) ·
auto-applying mass edits the user hasn't reviewed (produce the verified manifest first, gate the writes).

## Worked example (generic shape)
Remap every occurrence of an old API surface onto a new gateway across a codebase: (1) recall relevant
cells; (2) extract the new gateway's `openapi.yaml` → `/tmp/paths.txt` (the ground truth); (3)
`grep -rl` old hosts → the file set; (4) partition by subsystem; (5) fan out
`pipeline(units, discover→map, adversarial-verify)` each route checked vs `/tmp/paths.txt`; (6)
synthesize a REMAP_MANIFEST with surfaceCount/hallucinated/gaps; (7) apply per-partition (independent
files), verify with an endpoint-check script. Related: [[B-002]] prompting, [[B-023]] cached-prefix
economy, [[B-110]] worktree base-branch gate.
