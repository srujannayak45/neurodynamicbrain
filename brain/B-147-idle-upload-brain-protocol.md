---
id: B-147
tags: [workflow, memory, process]
scope: global
hook: HARD PROTOCOL (all agents) — whenever a session has been idle >~20 min, push the brain to the central store; any agent that pulls the brain MUST communicate back (push). brain.sh doctor enforces it.
---

# Protocol: idle >20 min ⇒ upload the brain (all agents communicate back)

## Fact
Standing, non-overridable protocol: **if a session goes idle for more than ~20 minutes, the brain MUST
be uploaded (pushed to the central store) — every time.**

**Universal across agents.** This applies to EVERY agent that touches the brain on a machine — any CLI
agent, editor agent, or automation. All agents share one store: **anybody who downloads (pulls) the
brain has to communicate back — i.e. push their changes upstream.** No agent is exempt.

- "Upload the brain" = push `~/.claude/brain` to its central git remote — the same mechanism the
  [[B-054]] session-handoff skill uses on stop.
- Trigger is the idle gap (>20 min), not session end. Treat a long idle as a checkpoint: commit + push
  so cross-machine state is never stranded.
- **`brain.sh doctor` enforces it**: doctor reports central-store sync and WARNs (loudly) when the
  brain has uncommitted or unpushed changes, so no agent finishes without communicating back. Run
  doctor (must PASS) before pushing.

**Why:** the brain is the transient cross-machine, cross-agent working memory; a >20-min idle is when a
context/machine/agent switch is most likely, so flushing it upstream prevents lost state.

Related: [[B-022]] (brain self-maintenance), [[B-054]] (session-handoff), [[B-129]] (auto-sync hooks).
