---
id: B-110
tags: [workflow, git, gotcha, meta]
scope: all repos (agent worktree fan-out)
hook: Agent worktrees default their base to the repo default branch, NOT current HEAD — recall the repo base branch (B-008) and pass/verify it before fanning out
---

# Worktree fan-out: verify the base branch BEFORE spawning agents

When you spawn background agents with `isolation: "worktree"` (the decompose-and-orchestrate /
batch pattern, [[B-067]]), the worktree's base is the repo's **default branch (often `master`/`main`)**,
NOT your current HEAD or the branch you're working on. Workers therefore branch from a possibly stale
base, independently re-create shared types/handlers that already exist on the real integration branch,
and write code against an older interface — producing PRs that duplicate or conflict and need a full
rebase-onto-correct-base reconciliation pass.

**Two-part gate (do BOTH before any fan-out), the G1·RECALL + G2·SCOPE step:**
1. **RECALL the repo's base branch ([[B-008]] per-repo base branches).** Don't assume `master`/`main`.
   Many repos integrate on a `dev` or release branch that is well ahead of the default branch.
2. **Pin the base explicitly.** Commit your foundation to the correct base first and confirm
   `git rev-parse origin/master == origin/<intended-base>`; if they differ, the worktree default is
   wrong — plan to either pass the base to each agent or run a reconciliation pass (rebase each unit
   `git rebase --onto <newbase> <oldbase> <unit-branch>`, or cherry-pick the single deliverable commit
   onto the correctly-based foundation, then force-push to the existing PR head to keep PR numbers).

**Cost when skipped (observed):** a multi-PR effort based on the default branch instead of the true
integration branch had every PR rebased and force-pushed. Cheap to prevent (one `git rev-parse` + a
recall), expensive to fix after the fan-out completes. Default `gh pr create --base` to the recalled
integration branch, never the implicit default.
