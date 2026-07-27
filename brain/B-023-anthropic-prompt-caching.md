---
id: B-023
tags: [code, llm, observability, gotcha]
scope: any service that proxies or directly calls Anthropic /v1/messages
hook: Prompt caching needs both halves — stable system prefix AND granular usage passthrough; either alone gives nothing measurable
---

# B-023 — Anthropic prompt caching: wire shape, observability, gotchas

Anthropic prompt caching is one wire-flag away (`cache_control: ephemeral` on a system block), but
cache hits are invisible without granular `usage` passthrough and a stable-prefix prompt restructure.
Default integrations leave money on the table silently.

## The two halves you cannot skip

A correct integration is BOTH of these. Either alone gives you nothing measurable.

**1. Send the cache marker on a stable prefix.** Anthropic caches a PREFIX of the prompt — system
blocks read left-to-right, up to and including the block tagged `cache_control: ephemeral`. Cache hits
require BYTE-IDENTICAL prefix across calls. So:
- Variable bindings (per-request inputs) go in the **user message**, never the cached system block.
- Output instructions ("Output ONLY the X. No prose.") belong at the END of the user message, AFTER
  the variable bindings — otherwise the model latches onto the binding text as continuation.
- 5-minute TTL on the cache. Two calls within 5 min → 2nd hits cache_read. Sparser cadence → cache
  rewrites every call (worst-of-both: 25% creation premium, never read).
- ~1024-token minimum for caching to engage (≈4 KB English). Smaller prefixes pay overhead with no benefit.

**2. Surface the granular `usage` block end-to-end.** Anthropic's response includes:
```
"usage": {
  "input_tokens":               N,   // NEW input (the user message)
  "output_tokens":              M,   // model output
  "cache_creation_input_tokens": K,  // 25% premium — written this call
  "cache_read_input_tokens":     L   // 10% of base — read from cache
}
```
Many provider abstractions aggregate these into one `TokensUsed = input + output` integer for
"simplicity" and DROP the cache fields — cache hit and cache miss then return identical totals to the
caller. The proxy MUST pass the granular block through. Use snake_case field names that mirror
Anthropic so downstream observability routes on stable identifiers across providers.

## Cost model gotcha

Per-token rates (relative to base input): `input_tokens` 1.0×; `cache_creation_input_tokens` 1.25×
(one-time premium when cache is written); `cache_read_input_tokens` 0.10× (when read within TTL).

**Breakeven is ~2 calls.** A prompt sent once and never repeated within 5 min costs MORE with caching
enabled (the 25% creation premium with no read amortisation). So: cache only stable prefixes used by
frequent/repeated callers. Don't blindly mark every system prompt as cacheable.

## Observability pattern (the metric set that matters)

Emit five metrics per converse call, dimensioned by your routing identifier:
```
TotalTokens          // backwards-compat aggregate; works without granular passthrough
InputTokens          // NEW input only
OutputTokens
CacheCreationTokens  // > 0 on cache write
CacheReadTokens      // > 0 on cache hit — the signal that caching is paying off
```
Watch `CacheReadTokens / (CacheReadTokens + CacheCreationTokens + InputTokens)` over a window. If it
stays at 0 you're caching but never hitting (prefix drift or sparse traffic). If `CacheCreationTokens`
keeps growing without `CacheReadTokens` catching up, the prefix is changing across calls — diff two
consecutive raw system prompts byte-for-byte to find the drift.

## Common drift sources that break the prefix cache silently

1. Variable interpolation accidentally embedded in the system prefix (timestamp, request id, name).
2. JSON-compact vs pretty-printed swaps in middleware — different bytes, no hit.
3. Whitespace re-formatting on prompt edits — even a trailing newline invalidates the cache.
4. Library-side templating that auto-trims/normalises strings between calls. Pin the prefix to a raw
   constant; build the variable part separately.

## When to NOT cache

- Single-shot prompts called once per request lifecycle (no repeat traffic).
- Prompts dominated by per-request variable content (cacheable prefix < 1024 tokens).
- Prompts under heavy churn (changing schema/instructions weekly) — re-tagging takes a deploy each time.

## Links
- [[B-024]] — task-family routing (the model-selection half; cache strategy is orthogonal).
- [[B-009]] — keep the metric namespace + dimension scheme narrow; don't fan out to per-item dimensions.
- [[B-061]] — the same "pay the stable prefix once" economics applied to the agent's own S-prefix.
