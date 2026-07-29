---
id: B-060
tags: [meta, workflow, code, reference]
scope: global/reference — how skills (R-units) execute and where their effector code lives
hook: Skill anatomy = SKILL.md (motor program) ↔ cited B-cells (facts) ↔ effector code (the arms/legs) ↔ execution surfaces; retain reusable scripts, don't regenerate them
---

# B-060 — Skill execution anatomy: the arms and legs of an R-unit

@meta @workflow @code @reference

## Fact
A skill (R-unit, [[B-059]]) is not just prose. It has four parts that interconnect; keeping them
separate is what keeps the brain non-duplicative and cheap:

1. **SKILL.md — the motor program.** Thin. Activation `description` (the A→skill coupling — name
   exactly WHEN it fires and when it does NOT), an ordered step list, and citations to the cells it
   acts on. Holds no facts and no long code bodies.
2. **Cited cells — the facts (A-units).** `[[B-NNN]]` links. The skill reads weights from here; when
   a cell changes the skill still works. Never copy a fact from a cell into a skill.
3. **Effector code — the arms/legs.** The retained scripts a skill runs: `skills/<name>/*.sh|*.py|*.mjs`
   (skill-private) or `skills/_lib/*` (shared across skills). This is code-level G1 recall: a
   deterministic procedure is written ONCE, kept, and re-run — not regenerated from scratch each session.
4. **Execution surfaces — where the limbs act.** the shell (filesystem, git, `brain.sh`), any API or
   MCP tool the skill drives. The effector targets a surface; the surface is the world the R-unit emits into.

## How they interconnect (one task)
```
S: prompt ─G0→ G1 grep INDEX ─→ load cited cells (facts)
                         │
SKILL.md (steps) ────────┼──→ run effector script (skills/<name>/ or skills/_lib/)
                         │            │
                  reads facts         └──→ acts on an execution surface (shell/API/MCP)
                         │
                    G4 verify ─→ G5: if the effector itself generalized, RETAIN it (don't re-author next time)
```

## Rules (the discipline)
- **Retain, don't regenerate.** If a non-trivial reusable script gets written while running a skill,
  save it as an effector under the skill (or `_lib/` if >1 skill needs it) and have SKILL.md call it.
  Regenerating deterministic code every session is the code-level form of the re-derivation leak.
- **Effectors are deterministic + idempotent + flag-gated.** They take args/env, do one job, exit
  nonzero on failure (so the skill's G4 can read it). No embedded secrets — reference by path/env
  ([[B-011]]). `brain.sh` is the canonical example: the effector of the brain-maintenance skill ([[B-022]]).
- **`skills/_lib/`** = shared effectors. Skill-private code stays in the skill's own dir.
- **Code is not a fact.** Effector code lives with the R-unit (skills), NOT in B-cells. A cell may
  *point to* an effector path, but pasting code bodies into cells is the A-unit-overload anti-pattern.

Related: [[B-059]] (neurodynamic model), [[B-022]] (brain.sh = the brain's own effector), [[B-011]]
(no secrets in retained code), [[B-065]] (the effector gate).
