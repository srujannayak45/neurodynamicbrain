---
name: pr-merge-sweep
effector: exempt — generic example
description: >
  Find the branches that genuinely still need a PR raised, in a repo with many stale branches. Fires
  when asked to "sweep for unraised PRs", "which branches still need merging", "find unmerged work", or
  before bulk-raising PRs. Squash-aware: does NOT treat "N commits ahead of base" as "unmerged"
  (squash-merge leaves original commits unreachable, so a merged branch looks ahead forever). Skip for
  a single known branch.
---

# pr-merge-sweep — squash-aware unraised-PR detection

Facts live in the brain — this skill is the procedure. Cite, don't duplicate: [[B-143]] (squash-merge
makes branches look ahead; merge-tree net-zero = merged), [[B-008]] (per-repo base branches — never
sweep against the wrong base).

## When it fires
A repo has many branches and someone wants to know which ones still need a PR raised before merging —
and you must not spam one PR per "ahead" branch.

## Steps
1. **G1 recall** the repo's true base branch ([[B-008]]) — sweep against that, not `main` by reflex.
2. Apply the two reliable tests from [[B-143]] (a small `sweep.sh <base-branch>` is the generic
   effector — wire your own and update this `effector:` declaration):
   - exclude any branch that already had a **merged PR** (`gh pr list --state merged --json headRefName`);
   - for the rest, compute `git merge-tree --write-tree base branch` then
     `git diff --shortstat base <tree>` — **net-zero diff = content already in base = merged.**
3. The survivors are the *genuinely* unraised branches. Raise PRs only for those.

## Done-when (G4)
You have a `GENUINELY UNRAISED` list. Spot-check one survivor: confirm its content is truly absent from
base (`git diff base <branch> --shortstat` is non-zero AND no merged PR exists).
