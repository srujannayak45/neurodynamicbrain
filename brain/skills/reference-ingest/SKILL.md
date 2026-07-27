---
name: reference-ingest
effector: exempt — generic example
description: >
  Add a LONG document (spec, RFC, transcript, converted DOCX/PDF, architecture doc, a big
  protocol/design write-up) to the brain as a deferred reference. Fires on "add this doc/spec/
  transcript to the brain", "ingest this reference", "remember this whole document". SKIP for
  short facts/conventions/gotchas — those are plain B-cells written directly (PROTOCOL §write-back),
  not references. The point is to keep long text OUT of cells (anti-saturation) while still making
  it recall-addressable through a small handle cell.
---

# reference-ingest — R-unit motor program for the references/ layer

Facts live in the brain (cells cited below); this skill is the procedure. Long documents belong in
`references/<slug>.md`; a B-cell for one is **only a recall handle**, never the text.

## Cells this skill cites (load at G1 before running)
- [[B-059]] — neurodynamic model: references = long-term store, loaded on demand only
- [[B-060]] — skill execution anatomy: this skill's effector is the ingest script (the arm)

## When to use vs. not
- **Use** when the source is long (a whole spec/transcript/doc) and you'd otherwise be tempted to paste
  it into a cell. That paste is the "long docs in B-cells" anti-pattern — a saturation bomb.
- **Skip** when it's a short, durable fact — write a normal cell per PROTOCOL §write-back instead.

## Steps
1. **G1 RECALL:** confirm B-059/B-060 are loaded; check `INDEX.md` for an existing reference on this
   topic (UPDATE it rather than duplicate).
2. **Run the effector** (a retained ingest script — don't hand-roll the copy each time). It should:
   copy the source → `references/<slug>.md` with a provenance header, scaffold the `B-NNN-<slug>.md`
   handle cell, append the INDEX line, and run `brain.sh doctor`. (This example brain ships the skill
   without a bundled effector — wire your own `ingest.sh` and update this `effector:` declaration.)
3. **Refine the handle cell** the effector scaffolded: tighten *When to LOAD*, add real `[[B-NNN]]`
   lateral links, and make the `hook` precise. The cell must NOT contain the document body.
4. **G4 VERIFY:** `brain.sh doctor` → PASS; confirm `references/<slug>.md` exists and the cell points
   to it. Sanity-check the full text is NOT in the cell.
5. **G5 / land:** commit + push via the **session-handoff** skill (`pull --rebase` before push — the
   brain is shared across machines/sessions).

## Notes / gotchas
- One reference = one handle cell. Tag it `@reference` plus its domain tag.
- Re-ingesting the same slug should be refused (the reference already exists) — pick a new slug or remove it.
