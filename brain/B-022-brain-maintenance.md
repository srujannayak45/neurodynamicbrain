---
id: B-022
tags: [meta, workflow]
scope: global (the brain itself)
hook: Maintain the brain with brain.sh; honor MANIFEST invariants on every write-back
---

# Brain self-maintenance

The brain has a meta-structure that manages itself: `MANIFEST.md` (self-description + invariants) is
to the brain what a repo's README is to the repo; `brain.sh` is to the brain what an installer is to
the repo.

**How to apply — during G5 write-back (and any time you touch the brain):**
1. Allocate IDs with `brain.sh next-id` — never hand-pick or reuse a retired number.
2. After adding/editing/deleting a cell, run `brain.sh doctor`. It must end **PASS**: every cell has
   an INDEX line, every INDEX entry + every `[[link]]` resolves, IDs unique, frontmatter complete.
   Fix any FAIL before considering the task done (a G4 verify step for brain edits).
3. Honor the **MANIFEST invariants** and the **cell lifecycle** (draft → active → stale → retired /
   promoted). Delete wrong cells (file + INDEX line); mark time-sensitive ones "(maybe stale — verify)".
4. Keep `CLAUDE.md` small — it routes, cells store. New top-level rule → cell + INDEX line; only add a
   `CLAUDE.md` pointer if it's broad enough to matter on most sessions.

**Other `brain.sh` commands:** `tags` (region usage), `links` (cell→[[link]] graph), `stats` (size,
counts, next id). **Why:** without a self-check the index and cells silently drift (orphans, broken
links) — `doctor` makes integrity a one-command check. See `MANIFEST.md`.
