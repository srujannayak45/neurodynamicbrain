---
id: B-054
tags: [memory, infra, reference, process]
scope: global
hook: The brain git repo IS the central cross-machine transient memory — push on stop, pull on restart; the session-handoff skill + HANDOFF.md drive it
---

# B-054 — Session handoff to central cross-machine memory

@memory @infra @reference @process

## Fact
There is no separate "memory server" — the **brain git repo is the central store**.
`~/.claude/brain` → symlink → a git repo (e.g. `<your-dotfiles-repo>`, branch `main`). Every session
on every machine (home laptop, office, CI) reads/writes the same brain; **the git remote is where the
memory of all sessions is gathered**. So "hand over memory when the laptop closes and resume
elsewhere" = commit+push the brain on stop, pull+read on restart. There is nothing else to wire.

## How (the `session-handoff` skill owns the procedure)
- **Stop / "hand over" / closing laptop:** refresh `HANDOFF.md` (latest-state only — working-on /
  branches / shipped / blockers / resume-step / other live sessions), write durable patterns as
  `B-NNN` cells, `brain.sh doctor` PASS, then `cd <dotfiles> && git add -A && commit && git pull
  --rebase --autostash && push`.
- **Resume / start of session:** `git pull --rebase --autostash`, `cat HANDOFF.md` + tail INDEX,
  summarize "where we left off" in 3–5 lines, then continue.

## Machine-state harvest (portable signal, never raw sync)
On `push`, the effector distills the per-machine dirs (`~/.claude/{sessions,projects,file-history}`)
— read **locally, read-only** — into one auto-managed, host-delimited block in HANDOFF.md: per recent
cwd → branch, last-active time, files-edited count, last ask/summary. The block is idempotent (splice
replaces it in place) and never touches the hand-written lane sections.
- **Never synced** (local to each machine; raw sync would leak creds or break the peer):
  `settings.json` (creds/paths), `ide/` (sockets), `telemetry/`, `shell-snapshots/`, `backups/`,
  plus the raw `sessions/projects/file-history` dirs themselves. A blacklist guard in the effectors
  enforces this — the manual push **aborts** if such a path is staged; the auto Stop-hook **silently
  unstages and continues** (must never block session exit).

## Gotchas
- **Shared across concurrent sessions/machines** → always `pull --rebase` before push; never
  force-push `main`. A second agent may be mid-edit (its uncommitted cells get gathered too — intended).
- `HANDOFF.md` is transient latest-state (overwrite each handoff); the durable additive memory is the
  `B-NNN` cells. Don't put long-lived facts only in HANDOFF.
- Best-effort, not transactional: if offline, the note still commits locally and pushes next handoff.

Related: [[B-022]] (brain self-maintenance / brain.sh), [[B-007]] (commit identity), [[B-129]]
(auto-sync hooks), [[B-137]] (session storage locations).
