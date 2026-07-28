---
id: B-179
tags: [git, workflow, gotcha, meta]
scope: any machine with multiple gh CLI accounts in the keyring
hook: gh CLI has ONE active account at a time; switching for one repo's push silently breaks git push/pull to every repo under the other identity until switched back
---

# gh CLI single-active-account gotcha

When a machine's `gh` keyring holds two accounts — e.g. `<personal-account>` (personal repos) and
`<work-account>` (the brain/dotfiles repo) — only ONE is "active" at a time (`gh auth status` shows
`Active account: true/false`), and git's credential helper (osxkeychain, or a gh-routed helper)
resolves through whichever account is currently active. There is no per-repo auth selection.

**The failure mode:** after `gh auth switch -u <personal-account>` (required to push a personal repo),
any subsequent `git pull`/`push` to a repo owned by `<work-account>` fails with a misleading
`remote: Repository not found` / `fatal: repository ... not found` — NOT a missing-repo error, but the
active account lacking access to the other account's private repo.

**Fix:** `gh auth switch -u <work-account>` before any operation on that account's repos (pull/push/
doctor's central-store sync). Symmetric in the other direction.

**How to apply:** treat "which gh account is active" as a piece of state you must check/set before
EVERY cross-repo git operation in a session that touches both a personal project repo and the brain —
don't assume the account from three tool-calls ago is still right. If a pull/push/doctor-sync 404s
unexpectedly, check `gh auth status` first before suspecting the repo itself is broken.

**The silent/automated variant:** the same drift can hit an unattended sync hook, not just an
interactive session. If that hook's push is best-effort (`git push ... || true`, so a broken sync
never blocks other work), the 404 from an inactive account is swallowed with **zero visible error** —
commits can pile up locally across many runs before anyone notices. A raw stored credential being
valid does not mean git will use it, if a CLI-routed credential helper is layered on top — that
helper's active-account choice wins over whatever else is cached. Durable fix: pin the account
defensively (`gh auth switch --hostname <host> --user <work-account>`) at the top of the sync script
itself, before every pull/push, not just as a rule a human remembers.

*(This was briefly split into its own cell before the duplication was caught on recall and folded
back in here — a live example of the brain's own anti-duplication discipline applied to itself:
extend an existing gotcha cell with a new variant rather than minting a near-duplicate.)*

Related: [[B-054]] (brain central store), [[B-003]] (per-repo identity).
