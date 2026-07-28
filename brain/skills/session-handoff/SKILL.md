---
name: session-handoff
effector: exempt — generic example
description: >
  Hand a stopping session's working memory to the central store (the brain git repo) and resume it on
  another machine. Use when the user says they're closing the laptop / switching machines / "hand
  over" / "save the session", OR at the start of a session to recover where the last one left off. The
  brain (~/.claude/brain → <your-dotfiles-repo>/claude/brain) IS the transient cross-machine memory;
  this skill pushes it on stop and pulls + summarizes it on restart so no session state is lost.
---

# Session Handoff — central, cross-machine transient memory

The "central server" is the **brain git repo**: `~/.claude/brain` is a symlink to a checkout inside
your dotfiles repo (`<your-dotfiles-repo>/claude/brain`, branch `main`). All sessions on all machines
read/write the same brain; the git remote is where the memory is gathered. Handing over =
commit+push; resuming = pull+read. Identity for these commits: your own git identity for that repo
(see [[B-003]]).

## Per-machine state (harvested, never synced)

These `~/.claude` dirs are **local to each machine** and must NOT ride the brain repo:
`sessions/` (proc↔cwd state) · `projects/` (per-machine transcripts) · `file-history/` (edit
snapshots) · `telemetry/` · `shell-snapshots/` · `backups/` · `ide/` (sockets) · `settings.json`
(may carry creds/paths). Syncing them would leak credentials or break the other machine.

So `push` **harvests** the portable signal — a `harvest` step reads `sessions/`, `projects/`, and
`file-history/` LOCALLY and distills them into one auto-managed, host-delimited block in `HANDOFF.md`
(`<!-- AUTO machine-state: <host> -->`): per recent cwd → branch, last-active time, files-edited count,
last ask/summary. The raw dirs never leave the machine; only that distilled text syncs. A guard in the
push effector aborts the push if any
`claude/{sessions,projects,file-history,telemetry,shell-snapshots,ide,backups,settings.json}` path is
ever staged in the dotfiles repo. The auto-block is additive — it never overwrites the hand-written
`## <date> · <machine>` lane sections below. (This example brain ships the skill without a bundled
effector — wire your own `handoff.sh` + `harvest.py` and update this `effector:` declaration.)

## HAND OVER (session stopping / closing the laptop / "save")

1. **Refresh the handoff note** — `HANDOFF.md` is SHARED across concurrent sessions/machines and is
   organised into one `## <date> · <machine> — <lane>` section per lane. **APPEND or UPDATE only YOUR
   lane's section; NEVER overwrite the whole file** — a full overwrite wipes other live lanes'
   sections. Your section carries:
   - `## <ISO date> · <machine: $(hostname)>`
   - **Working on** — the active task(s) in one or two lines.
   - **Repos/branches touched** — repo + branch + base.
   - **Shipped this session** — merged PRs (numbers + one-line each).
   - **Open threads / blockers** — what's unfinished + what's gating it.
   - **Resume from here** — the first thing the next session should do.
   - **Other live sessions** — note any concurrent session's lane so we don't clobber.
2. **Capture durable patterns as brain cells** first (G5 write-back) — anything reusable goes in a
   `B-NNN` cell via `brain.sh next-id`, not only in HANDOFF.md (which is transient state).
3. **Verify the brain is consistent:** `brain.sh doctor` must PASS (don't push a broken brain — a
   half-written cell or dangling `[[link]]` would propagate to every machine).
4. **Gather + push ALL memory** (every session's cells, not just this one's):
   ```bash
   cd <your-dotfiles-repo>
   git add -A
   git commit -q -m "brain: session handoff <date> (<machine>)"
   git pull --rebase --autostash && git push     # pull first — other machines/sessions push too
   ```

## RESUME (new session / other machine / start of day)

1. **Pull the gathered memory:** `cd <your-dotfiles-repo> && git pull --rebase --autostash`.
2. **Read the handoff:** `cat ~/.claude/brain/HANDOFF.md` + skim the newest `INDEX.md` lines.
3. **Summarize to the user in 3–5 lines:** what was in flight, what's blocking, the resume step — then
   continue. Recalled cells/HANDOFF reflect what was true *when written*; verify any named file/branch/
   PR still exists before acting.

## Notes / gotchas
- The brain is SHARED across concurrent sessions. Always `pull --rebase` before push; never force-push
  `main`.
- HANDOFF.md is latest-state per lane — append/UPDATE your own section, never overwrite the file; the
  durable, additive memory is the `B-NNN` cells.
- Best-effort cross-machine sync, not a transaction — if push fails (offline), the note is still
  committed locally and pushes on the next handoff.
- To AUTOMATE on session stop, a `Stop` hook can run the push — see [[B-129]] (auto-sync hooks). If your
  git host uses a per-account credential helper, watch for the silent auth-drift failure in [[B-179]].

Related cells: [[B-054]] (central-memory fact + per-machine boundary), [[B-129]] (auto-sync hooks),
[[B-137]] (session storage locations), [[B-003]] (git identity).
