# Operating Protocol — read once per session

This is the **S-layer router** — the small, always-loaded file that tells you how to USE the brain.
It holds no facts. The knowledge lives in the cells (`brain/B-NNN-*.md`), not here. Keep this file
tiny and byte-stable within a session ([[B-061]]) — the prompt cache depends on it.

## The Brain (unified cross-project memory)

- Master index: `INDEX.md` — one addressable line per memory cell, tagged with `@tags`.
- Cells: `B-NNN-*.md` — one fact/pattern each. Load a cell ONLY when its tag matches the task.
- **Recall rule (do this before generating code, planning, or researching):**
  `grep` INDEX.md for the `@tags` relevant to the task → read only the matched cells.
  If the brain already answers it, REUSE it. Do not re-derive what's cached — that's the token leak
  this exists to stop. (This is non-negotiable — see [[B-128]].)
- **Write-back rule (do this after solving something non-obvious):**
  allocate the id with `brain.sh next-id`, append the `B-NNN` cell + one INDEX line, tag it, link
  related cells with `[[B-NNN]]`, then run `brain.sh doctor` (must PASS). Promote anything reusable
  across >1 project.
- Self-maintenance: `brain.sh` (doctor/next-id/tags/links/stats) + `MANIFEST.md` (invariants, lifecycle).
  Cell [[B-022]].
- Full gate detail + tag vocabulary: `PROTOCOL.md` (read on demand, not every session).
- Long docs live in `references/` as deferred handles ([[B-059]]), never inlined here.

## The Gate Loop — run every non-trivial task through these gates

- **G0 · INTENT** — Know the goal + the *why* before acting. Echo your one-line read, then proceed.
- **G1 · RECALL** — Consult the brain (recall rule above). Reuse cached patterns.
- **G2 · SCOPE** — Fence the work: what to touch / not touch / which branch / done-when observable.
- **G3 · BUILD** — Implement.
- **G4 · VERIFY** — Prove it with the done-when observable. Report the result plainly.
- **G5 · LEARN** — If a durable pattern emerged, write it back (write-back rule).

Skip gates for trivial/terse asks ("raise the PR", "proceed"). Use the full loop for ambiguous,
high-blast-radius, or design work.

## Intent shorthand (users type this to save round-trips)

`>> <goal> | why: <intent> | touch: <files/layer> | done: <observable>`

Any field may be omitted. When present, treat it as the G0/G2 contract and skip clarification.

## Skills (procedures over the facts)

Facts live in cells; the `skills/<name>/SKILL.md` skills are the invokable procedures. Each is thin and
points back to its cells. Generic examples included: **prompt-gates** (run the gate loop),
**decompose-and-orchestrate** (fan a big task across subagents), **reference-ingest** (add a long doc
as a deferred reference), **voice-to-prompt** (distill dictation to a structured prompt),
**diagnose-before-fix** (gate destructive infra mutations behind a diagnosis check),
**async-claim-poll** (claim+202+poll for >30s endpoints), **pr-merge-sweep** (squash-aware unraised-PR
detection), **infra-guard** (pre-apply IaC review), **managed-svc-eol** (version-EOL cost audit),
**session-handoff** (push/pull the brain across machines — demonstrates the per-machine boundary).

When you add a durable procedure (G5), consider whether it belongs as a new skill as well as a cell.
