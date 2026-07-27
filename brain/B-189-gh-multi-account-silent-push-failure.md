---
id: B-189
tags: [git, gotcha, meta, memory]
scope: dotfiles/brain repo — any machine with multiple gh accounts logged in
hook: gh CLI's active account, not the raw keychain token, decides which token git push uses for github.com
---

# gh multi-account drift silently breaks brain auto-push

**What:** when `git config credential.helper` for github.com is a gh-routed helper
(`!<path>/gh auth git-credential`, layered over plain `osxkeychain`), that helper serves the token for
whichever `gh` account is currently **active** (`gh auth switch`), regardless of which account's raw
OAuth token sits in Keychain. When the active account drifts to a personal login that has no access to
the private brain/dotfiles repo, every `git push`/`fetch`/`ls-remote` against it returns the generic
`remote: Repository not found.` GitHub gives that same 404 for "repo doesn't exist" and "repo exists
but you're unauthorized" — so it reads exactly like a renamed/deleted repo.

**Why this goes unnoticed:** the brain auto-sync ([[B-129]]) pushes as
`git push --quiet 2>/dev/null || true` — best-effort by design so a broken brain never blocks session
exit. That also means an auth-drift failure is **completely silent**: no error surfaces anywhere,
commits just accumulate locally until someone runs `brain.sh doctor` (central-store sync check) or
manually pushes.

**How to apply:**
- Diagnosing a "Repository not found" on a repo you know exists: don't assume the repo moved. Check
  `gh auth status` for multiple accounts first — `git ls-remote` alone can't tell you which account
  git actually used.
- Fix: `gh auth switch --hostname github.com --user <work-account>` before any brain/dotfiles push/
  fetch. Pin this defensively inside the auto-sync script itself (both pull and push paths) so it
  self-heals every session — see [[B-129]].
- Standing rule: **always use the work account/identity for brain-repo git operations**, never a
  personal login. Mirrors [[B-003]]'s per-repo identity rule but at the `gh` account layer rather than
  just `user.name`/`user.email`.
- A raw Keychain token being valid (`curl -u user:token .../user` → 200) does NOT mean git will use it
  — if a `gh`-routed credential helper is layered on top, that helper's active-account choice wins.

Related: [[B-129]] brain auto-sync hooks, [[B-179]] gh single-active-account gotcha, [[B-003]] git identity.
