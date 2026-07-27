---
id: B-059
tags: [reference, meta, workflow]
scope: global/reference — brain architecture & gate protocol
hook: Rosenblatt neurodynamic (S/A/R perceptron) reframing of the brain protocol — long doc lives in references/, load on demand only
---

# B-059 — Neurodynamic principles (deferred reference handle)

@reference @meta @workflow

## Fact
The brain's design rationale has a full long-form treatment that reframes the Brain-of-Brains
protocol through Rosenblatt's *Principles of Neurodynamics* (perceptron S/A/R units). It is
**long-term store, not a cell** — this cell is only the recall handle.

- **Brain reference (load this):** `references/neurodynamic-principles.md`
- **Provenance:** origin = Rosenblatt, *Principles of Neurodynamics* (1961).

## The model in three lines (enough for most tasks — don't load the full doc for this)
- **S-unit** = `CLAUDE.md` router (loads every session; tiny; holds no facts).
- **A-units** = `INDEX.md` (interaction-matrix register, grepped) + `B-NNN` cells (one fact each,
  loaded only on tag match); `@tags` = excitatory coupling, `scope` = inhibitory, `[[links]]` = lateral.
- **R-units** = skills (motor programs that *cite* cells, never duplicate them) + their effector code.
- The **Gate loop G0–G5** is the reinforcement system; **α** = unbounded write-back, **γ** =
  consolidation/dedup; the **D-signal** is decay (stale markers); selective recall (not full-brain
  load) is what avoids **saturation**.

## When to LOAD the full reference
Designing or altering brain structure / the gate protocol; onboarding the model to the S/A/R model;
reasoning about saturation, decay, or the α/γ systems. Otherwise this handle is enough.

Related: [[B-022]] (brain.sh maintenance), [[B-054]] (session handoff), [[B-060]] (skill-execution
anatomy / effector layer), [[B-061]] (prompt-cache discipline).
