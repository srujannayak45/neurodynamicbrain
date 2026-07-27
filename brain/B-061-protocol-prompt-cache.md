---
id: B-061
tags: [workflow, meta, reference]
scope: global — token economy of the brain protocol
hook: CLAUDE.md is the cached S-prefix — keep it byte-stable within a session; volatile state goes in cells/HANDOFF, never the protocol; recalled cells append AFTER the cached prefix
---

# B-061 — Prompt-cache discipline: keep the S-prefix byte-stable

@workflow @meta @reference

## Fact
Agent harnesses prompt-cache the stable system/instruction prefix (the always-loaded `CLAUDE.md`
router + tool defs) within a session. That cache is the native form of the brain's "load the protocol
once per session, not per task" economics ([[B-059]]). The win is **free if the prefix is byte-stable**,
and lost the moment the prefix mutates.

Rules:
- **Never mutate `CLAUDE.md` mid-session.** Any edit to the S-prefix invalidates the cache → the whole
  prefix is re-billed uncached on the next turn. Treat CLAUDE.md as read-only during work.
- **Volatile state never goes in the protocol.** Per-task/session state lives in `B-NNN` cells or
  `HANDOFF.md`, which load *after* the cached prefix — so they cost per-task tokens but never bust the cache.
- **Recalled cells are additive.** G1 loads matched cells as a suffix to the cached prefix; that suffix
  is the (intended) marginal cost of a task. Loading the *whole* brain would be the saturation anti-pattern.
- **CLAUDE.md stays tiny + pure** (router only, no facts). Same constraint from two directions: the
  neurodynamic S-layer rule ([[B-059]]) and the cache rule.

## How to apply
When tempted to "just add this to CLAUDE.md": don't. Write a cell (durable fact) or a HANDOFF section
(session state) instead. The only edits to CLAUDE.md are deliberate, between-session protocol changes.

**Why:** re-billing a stable ~1–2k-token prefix every turn is pure waste; the brain's whole point is to
pay the protocol cost once and the per-task cost selectively.

Related: [[B-059]] (neurodynamic token economics), [[B-023]] (Anthropic prompt caching).
