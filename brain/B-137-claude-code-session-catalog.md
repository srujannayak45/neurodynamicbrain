---
id: B-137
tags: [meta, memory, workflow, process, reference]
scope: global — where agent session history lives on disk + how to sync to brain
hook: Claude Code transcripts under ~/.claude/projects/<slug>/{sessionId}.jsonl; active PIDs in ~/.claude/sessions/*.json; sync = distill to B-cells + HANDOFF, not bulk JSONL ingest
---

# B-137 · Agent session history — paths and sync procedure

Recall before "sync all sessions to brain", cross-machine handoff, or resuming a parallel lane.
Related: [[B-054]] (handoff push/pull).

## Claude Code — where history lives

| Location | Contents |
|----------|----------|
| `~/.claude/projects/<project-slug>/` | Per-workspace root. Slug = absolute cwd with `/` → `-`. |
| `~/.claude/projects/<slug>/<session-uuid>.jsonl` | **Primary transcript** — one JSONL per session (parent conversation). |
| `~/.claude/projects/<slug>/<session-uuid>/` | Session workspace: `subagents/`, `workflows/`, `tool-results/`. |
| `~/.claude/projects/<slug>/<session-uuid>/subagents/*.jsonl` | Subagent / workflow transcripts. |
| `~/.claude/projects/<slug>/memory/MEMORY.md` | Project-scoped durable memory (auto-memory). |
| `~/.claude/sessions/<pid>.json` | **Active/recent process registry** — maps `pid` → `{sessionId, cwd, startedAt, version, entrypoint}`. NOT the transcript itself. |
| `~/.claude/plans/` | Saved plan files from plan mode. |
| `~/.claude/shell-snapshots/` | Shell state snapshots per session. |
| `~/.claude/file-history/` | File edit history across sessions. |
| `~/.claude/telemetry/` | Usage telemetry (not conversation text). |

**No** `~/.claude/history` or top-level `sessions/*.jsonl` — history is under `projects/`.

## Desktop app (NOT Claude Code)
Electron app data lives under the OS app-support dir; chat history is in **IndexedDB** / Session
Storage (binary LevelDB, not plain JSONL). **Not synced to brain** by default; cloud history lives on
the account server.

## How to sync sessions → brain (do NOT bulk-ingest JSONL)
1. **Distill** — read recent tail of each active lane's `.jsonl` + project `MEMORY.md`; write durable
   facts as `B-NNN` cells; transient lane state in `HANDOFF.md` (one `##` section per lane — append/
   update own section only, never overwrite whole file). See [[B-054]] · `session-handoff` skill.
2. **Catalog** — this cell holds the path layout + active-session index.
3. **Push** — `git add -A && commit && git pull --rebase --autostash && push`.
4. **Resume** — `git pull`, read `HANDOFF.md` + `tail INDEX.md`, verify branches/PRs still exist.

## Cannot sync (limitations)
- Full JSONL bodies (can be 100MB+) — anti-saturation; brain holds summaries only.
- Desktop / cloud threads — proprietary IndexedDB / remote API.
- Sessions on other laptops until that machine runs handoff push.
- `sessions/*.json` entries for dead PIDs may linger until cleanup.
