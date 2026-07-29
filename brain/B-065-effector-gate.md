---
id: B-065
tags: [meta, workflow, code]
scope: global
hook: The effector gate — every SKILL.md must declare effector:<path|exempt — why|pending — plan>; brain.sh effectors enforces it inside doctor. Stops the R-layer going hollow.
---

# B-065 — The effector gate (R-units must declare their arms)

## Why
The neurodynamic model ([[B-059]], [[B-060]]) names skills as the **R-layer** (motor output): SKILL.md
is the motor program, it cites A-units (cells), and it should drive an **effector** — retained
executable code on an execution surface. But if nothing enforces it, skills become prose-only and the
R-layer goes **hollow** — skills that describe a procedure but can't execute it, forcing re-derivation
of deterministic code every session.

## The rule (enforced)
Every `skills/<name>/SKILL.md` MUST carry an `effector:` frontmatter key in ONE state:
- **`<path>`** — retained code, resolved relative to the skill dir (`~` expands); the file must exist.
  Target state for any deterministic/repeatable procedure.
- **`exempt — <reason>`** — pure-judgment/policy skill, no separable deterministic core
  (e.g. `prompt-gates` is the loop itself; `infra-guard` is a review checklist).
- **`pending — <plan>`** — procedural skill whose effector is owed; names the file to build. WARN, not
  a resting state — backfill when the skill is next exercised.

**Enforcement:** `brain.sh effectors` scans all skills and is wired into `brain.sh doctor`. Missing
declaration OR a declared-but-absent path = **hard FAIL** (doctor won't pass); `pending` warns but
passes. This is the R-layer analogue of the cell-frontmatter check — the gate that keeps motor
programs honest about whether they can actually fire.

## G5 consequence
When you **develop** a new repeatable procedure, the deliverable is a **retained effector + its
`effector:` declaration**, not prose alone — "runnable, manageable, improvable code." Judgment-only
work declares `exempt`. This is the write-back discipline for the R-layer, mirroring α-write-back for
the A-layer.

Related: [[B-060]] (skill-execution anatomy — the S/A/R unit it enforces), [[B-059]] (neurodynamic
model), [[B-062]] (adoption record), [[B-022]] (brain.sh = canonical effector).
