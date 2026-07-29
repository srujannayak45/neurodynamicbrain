---
id: B-062
tags: [meta, workflow, reference]
scope: global — decision record for the brain's neurodynamic adoption
hook: Adopted Rosenblatt neurodynamic framing as a DEFERRED REFERENCE (not in CLAUDE.md); closed gaps — references/ layer + reference-ingest skill, brain.sh hygiene, tag-vocabulary reconcile, prompt-cache discipline, effector-code layer
---

# B-062 — Neurodynamic adoption (G5 decision record)

@meta @workflow @reference

## Fact
The Rosenblatt-neurodynamic reframing of the brain protocol was adopted as a **deferred reference,
not as CLAUDE.md content** — because inlining a ~6k-token doc into the always-loaded S-prefix is
exactly the saturation / S-layer-bloat anti-pattern the doc itself warns against ([[B-059]]). The
brain already implemented most of the model (S/A/R layers, gate loop, recall-before-reason,
write-back, skills-cite-cells); adoption = distil the deltas + close the gaps.

## What changed (the closed gaps)
1. **references/ layer** — `references/<slug>.md` for long docs; handle cell [[B-059]]; the
   `reference-ingest` skill + its `ingest.sh` effector scaffold/verify the ingest.
2. **brain.sh hygiene** — read-only reports: `stale` (D-signal), `dups` (γ-consolidation candidates),
   `saturation` (ceiling + aging), `tags --undeclared` (vocabulary governance). `doctor` stays
   authoritative + mutation-free.
3. **Tag-vocabulary reconcile** — PROTOCOL §Tag vocabulary lists the actual in-use set;
   `brain.sh tags --undeclared` validates against it.
4. **Prompt-cache discipline** — [[B-061]]: keep the CLAUDE.md S-prefix byte-stable; volatile state in
   cells/HANDOFF, never the protocol.
5. **Effector-code layer** — [[B-060]]: skills retain reusable scripts (`skills/<name>/` or shared
   `skills/_lib/`) as the R-unit's arms/legs. Code-level G1 recall.

## Invariants kept
CLAUDE.md left **byte-unchanged** (cache + S-layer purity); `brain.sh doctor` green throughout;
landed via session-handoff (`pull --rebase` before push — brain is shared).

**Why:** record so the adoption rationale (reference-not-inline) doesn't get re-litigated.

Related: [[B-059]] (the model + reference), [[B-060]] (effector layer), [[B-061]] (prompt cache),
[[B-022]] (brain.sh), [[B-065]] (effector gate).
