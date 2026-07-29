---
name: async-claim-poll
effector: exempt — generic example
description: >
  Convert any request handler whose work can exceed ~30s into the claim+202+detached-worker+poll
  pattern, so it stops hitting the CDN/edge ~30s 504. Fires when designing or fixing a long-running
  endpoint (batch submit, bulk job, fan-out), or when diagnosing a "504 / gateway timeout" that is
  really the handler blocking past the edge limit. Also provides the client-side poll loop for callers
  of such endpoints. Skip for sub-second handlers.
---

# async-claim-poll — claim + 202 + poll for >30s endpoints

The pattern for any handler that does work which can exceed the edge timeout (~30s on a typical CDN),
so the proxy 504s before the handler responds — a 504 that looks like an outage but is just a
synchronous long job.

## Server-side pattern
1. **Claim + 202:** persist a claim row `processing_status=in_progress`, create-only
   (`attribute_not_exists(SK)` / equivalent), return `202 {job_id}` immediately.
2. **Detached worker:** run the work on a context that survives the response but keeps creds/config
   (Go: `context.WithTimeout(context.WithoutCancel(ctx), 30m)` — a plain request-context is canceled
   at 202). Flip the row to `ended`/`errored` at the end.
3. **Linearise:** write derived rows (history/usage) BEFORE flipping the row to `ended`, so a poller
   that sees `ended` can trust them durable.
4. **Dispatch seam for tests:** `dispatch func(func())`; prod sets `go f()`, a nil dispatch runs
   synchronously → existing tests stay deterministic, zero test changes.
5. **Bounded concurrency:** fan out with a bounded worker pool (e.g. `errgroup.SetLimit(8)`,
   env-overridable), write results BY INDEX (no mutex, order preserved, siblings survive a per-item error).
6. Reuse the EXISTING poll/fetch/result routes — add no new API.

## Client-side
Submit, capture the job id, then poll the status route until `ended`/`errored`. A small
`curl + jq` poll loop is the generic effector — this example brain ships the skill without a bundled
script; wire your own `poll.sh <submit-url> <poll-url-template>` and update this `effector:` declaration.

## Done-when (G4)
The submit call returns 202 in well under the edge timeout; the poll loop observes `ended` with
derived rows already present; under load, wall-clock is ≈⌈N/limit⌉× not N×.
