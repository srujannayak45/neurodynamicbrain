---
id: B-008
tags: [git, workflow]
scope: all repos
hook: Cut a fresh branch before committing; never commit to integration branches
---

# Branch hygiene — never commit to integration branches

Always cut a new feature/chore/fix branch before committing a scoped change. Never commit directly to
shared integration branches (`main`, `dev`, release branches, etc.).

**Why:** integration branches are shared workspaces; direct commits clobber/interleave with other
in-flight work, and PR review is the established gate.

**Per-repo base branch.** Different repos integrate on different branches (not always `main`). Record
the true base branch for each repo you work in as a project-local note, and cut task branches FROM
that base — never assume `main`/`master` is the working branch. Getting this wrong is a common source
of PRs that need a full rebase (see [[B-110]]).

**How to apply:** `git checkout <base> && git pull`, then `git checkout -b <named-branch>` (e.g.
`fix/lifecycle-deploy-driver`) before staging. Confirm with `git branch --show-current`. Don't push
unless asked. Stage explicit paths, not `git add -A` ([[B-005]]).
