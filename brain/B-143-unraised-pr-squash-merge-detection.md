---
id: B-143
tags: [process, git, workflow, gotcha, reference]
scope: cross-project — detect already-merged branches despite squash-merge when sweeping for "unraised PRs"
hook: N-commits-ahead ≠ unmerged; squash leaves orig commits unreachable; use merge-tree net-zero + merged-PR head history
---

# B-143 — "unraised PR" sweep: squash-merge makes branches look ahead

When sweeping every branch for genuinely-unraised PRs, `git rev-list --count base..branch > 0`
(commits ahead) is a **false** signal: a **squash-merged** branch keeps its original commits
(unreachable from base) so it looks "ahead" forever. Two reliable tests:

1. **Already had a merged PR?** `gh pr list --state merged --json headRefName` → exclude those head
   branches.
2. **Content already in base?** `git merge-tree --write-tree base branch` then
   `git diff --shortstat base <tree>` — **net-zero diff = fully merged** (content present), regardless
   of how far "ahead" the commit graph says it is.

Applied to a repo with 37 branches that all looked ahead of the integration branch: 28 had merged PRs,
another 9 were net-zero → only **1** was genuinely unraised. Raise PRs only for the survivors — don't
spam one-per-ahead-branch. Procedure = skill `pr-merge-sweep`.

Related: [[B-008]] (per-repo base branches — sweep against the right base).
