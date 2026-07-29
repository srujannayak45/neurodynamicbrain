---
id: B-024
tags: [code, llm, routing, observability]
scope: any LLM-driven service that handles >1 task type
hook: Classify every LLM call into a task family BEFORE picking the model; route by family table, override by caller tier
---

# B-024 — Task-family routing for LLM calls

The naive default is to pin every LLM call to one "good" model. That works exactly once — until the
bill arrives. The next move is a task-family classifier that picks the cheapest model meeting the
per-task quality bar, with a caller override for hot-path or premium work. Observability follows the
same shape — every metric carries the family as a dimension so the cost dashboard partitions cleanly.

## A canonical family set

Every LLM call falls into one of these. New event types default to F1.

| ID | Family | When it fires | Default model |
|---|---|---|---|
| F1 | reason | open-ended decomposition, planning | Sonnet |
| F2 | code-gen | author source code | Sonnet |
| F3 | summarise | narration, hero blocks | Haiku |
| F4 | classify | label-set lookup, severity grading | Haiku |
| F5 | extract | pull structured fields from prose | Sonnet |
| F6 | structured | strict JSON output | Sonnet |
| F7 | vision | multimodal (image + text) | Sonnet |
| F8 | embed | vector embeddings (non-converse) | a dedicated embed model |
| F9 | tool-use | agentic tool selection | Sonnet |
| F10 | chat | conversational turns | Haiku |

## The routing table — flat, pure, lookup-only

Rules in code, not a config file. The hot path is a dict lookup:

```python
_FAMILY_RULES = {
    "F1": {"model": SONNET, "async": "sync",  "cache": "full"},          # reason
    "F2": {"model": SONNET, "async": "batch", "cache": "full"},          # code-gen
    "F3": {"model": HAIKU,  "async": "sync",  "cache": "none"},          # summarise
    "F4": {"model": HAIKU,  "async": "sync",  "cache": "prefix-only"},   # classify
    "F5": {"model": SONNET, "async": "sync",  "cache": "prefix-only"},   # extract
    "F6": {"model": SONNET, "async": "sync",  "cache": "full"},          # structured
    "F7": {"model": SONNET, "async": "sync",  "cache": "none"},          # vision
    "F9": {"model": SONNET, "async": "sync",  "cache": "full"},          # tool-use
    "F10":{"model": HAIKU,  "async": "sync",  "cache": "prefix-only"},   # chat
}
```
Map your own event/request types to families in a parallel lookup table; new types route to F1 by default.

## Caller tier override — one rung up or down

The caller can pass `tier = "deep"` or `"cheap"` to shift the family default one model rung within a
single provider:
- `deep`:  Haiku → Sonnet → Opus (ceiling at Opus)
- `cheap`: Opus → Sonnet → Haiku (floor at Haiku)
- `standard` (default): no shift

Intentionally narrow. Two-rung jumps require either a new family classification or an explicit model
override — deliberately hard, because it bypasses the cost discipline.

## Replay-attempt downgrade — a special-case rule that overrides family

If a request is on its Nth retry (`attempt >= 3`), return `{family: F4, model: Haiku}` regardless of
original type. The flake is in the source, not the model — stop spending the expensive model on it.

## Metric shape — two dimension cuts, not one

For every converse call, emit each metric twice — once with `{Route}` (the operational slice) and once
with `{Family, Model}` (the cost-attribution slice). That second cut lets the dashboard answer "how
much did F3 cost this week?" without re-aggregating from logs. Watch the **model alias** (`sonnet` /
`haiku` / `opus`), not the full dated model id — the full id blows up the unique-dimension-value count
without adding signal.

## Common drift sources

1. **Hardcoded model ids** outside the table — if anywhere says `claude-sonnet-4-5` literally, the
   table isn't the source of truth anymore. Hunt with `grep -rn 'claude-'`.
2. **Caller passes an explicit model** thinking it overrides the family — decide deliberately whether
   that escape hatch exists; if not, only `tier` shifts the model.
3. **New types added without a family entry** — they route to F1 silently. Alert on F1 volume growth.

## Links
- [[B-023]] — Anthropic prompt caching (the cache-strategy half; ships together, separately tunable).
- [[B-009]] — don't over-provision the GPU node group when self-hosting small models for F3/F4/F8.
