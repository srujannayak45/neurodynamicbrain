---
id: B-129
tags: [meta, workflow, memory]
scope: all devices
hook: brain auto-syncs itself — SessionStart pulls, Stop pushes; bootstrap a new device with the hooks installer
---

# B-129 · Brain auto-sync hooks (pull on start, push on stop, all devices)

**What:** The brain can sync itself automatically — no manual `session-handoff` needed for the common
case. Two agent-harness hooks drive it:
- **SessionStart** → `auto-sync.sh pull` — `git pull --rebase --autostash` in the dotfiles checkout so
  every new session starts on the latest brain.
- **Stop** → `auto-sync.sh push` — runs `brain.sh doctor` (skips push if it fails, so a broken brain
  never propagates), then `git add -A` + commit + `pull --rebase` + `push`. All best-effort (`|| true`),
  never blocks session exit.

**Helper scripts (live in the dotfiles repo, so present on every device via the
`~/.claude/brain → <your-dotfiles-repo>/claude/brain` symlink):**
- `auto-sync.sh {pull|push}` — the sync engine the hooks call.
- `brain-hooks-install.sh` — idempotent installer that MERGES the two hooks into a device's local
  agent `settings.json` (preserves existing hooks/permissions; re-run = no-op).

**Bootstrap a NEW device (one-time):** pull the dotfiles repo, then run `brain-hooks-install.sh`.
Thereafter that device auto-pulls on start and auto-pushes on stop like the rest.

**Gotchas:**
- `settings.json` is NOT synced via dotfiles (it holds per-device permissions/creds). Propagation is
  "ship the installer in dotfiles + run once", not "symlink settings.json".
- Push is best-effort: if offline the commit stays local and pushes on the next online Stop. Confirm
  with `git rev-list --left-right --count origin/main...HEAD`.
- Concurrent sessions/machines all push to the same `main`; the `pull --rebase` before push avoids
  clobbering. Complements the explicit [[B-054]] session-handoff path for rich HANDOFF notes.
- If your git host uses a credential helper that pins to one active account, an account drift can make
  pushes fail silently — see [[B-179]].
