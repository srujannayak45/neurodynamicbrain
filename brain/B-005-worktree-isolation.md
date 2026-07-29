---
id: B-005
tags: [workflow, git, gotcha]
scope: shared clones (multi-session)
hook: Isolate work in a git worktree or a parallel session clobbers it
---

# Worktree isolation for multi-session clones

Multiple agent sessions can run against the SAME clone simultaneously. The shared working tree
gets reset / branch-switched out from under you by the other session — this can silently wipe
uncommitted work (e.g. HEAD jumps to a different branch mid-task).

**Why:** one clone has one checked-out branch; another session's `git checkout`/`reset` discards your
uncommitted + untracked files.

**How to apply:**
1. Commit early and often; never leave substantial work uncommitted in the shared tree.
2. Work in an isolated worktree on your own sub-branch:
   `git worktree add .worktrees/<name> <branch>` (checking out in a worktree LOCKS the branch),
   then move the session in. Edit/commit/push there.
3. Stage with explicit paths (`git add app/...`), never `git add -A`/`.` — don't capture the other
   session's in-flight files.

Related: [[B-003]] identity, [[B-004]] no attribution.
