---
id: B-003
tags: [git]
scope: work repos with a dedicated identity
hook: Commit author must be the per-repo work identity, not your global personal identity
---

# Per-repo git identity

Some repos must be committed under a dedicated **work identity** rather than your global personal
identity. Keep the two separate so company work stays associated with the right account.

Placeholders — substitute your own:
- Work identity: `<work-git-name> <work@example.com>`
- Global personal identity: `<personal-git-name> <you@example.com>`

**How to apply:**
- Use `git config --local user.name <work-git-name>` / `user.email <work@example.com>` per repo.
  Never change global config without explicit permission.
- On a fresh clone / new work repo, set this local identity before the first commit.
- Set it inside **each submodule** too, not just the outer repo, and re-set defensively before
  `git commit` — other tooling can unset it.
- If you committed under the wrong identity this session, OFFER to rewrite + force-push — never do it
  silently (it rewrites pushed history; needs explicit confirmation).

Related: [[B-004]] no PR attribution, [[B-007]] no commit co-author trailer.
