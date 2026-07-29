---
id: B-010
tags: [infra, gotcha]
scope: all IaC / IAM / security-shaped work
hook: Never widen scope as a shortcut — create the proper resource
---

# No security-shaped shortcuts in IaC

When an apply fails because a referenced principal / IAM role / KMS key / ACM cert / Secrets Manager
entry doesn't exist yet, the response is **always to create that resource correctly** — never to
widen the consumer's scope as a workaround.

**Why:** shortcuts compound — every stub becomes load-bearing, leaks privilege, and blocks env
promotion. (Canonical trigger: a resource policy widened from a specific role ARN to `:root` to make
an apply pass.) This holds even when: it's "just dev" / you're in a hurry / it's gated behind
`var.env=="dev"` / the shortcut is a smaller diff. Stricter than the general "minimal change" preference.

**Do NOT:** inline an admin/wildcard policy; hardcode a secret value; use a self-signed/wildcard cert
for the real one; drop to a provider-managed key when a CMK is intended; switch to public access to
dodge DNS/PrivateLink; reference an existing role via `data.` long-term instead of codifying it.

**Instead:** create the role (proper trust+perms), augment the KMS key policy, seed the secret
(placeholder ok for dev), request+await the cert, add the private DNS record. If a shortcut is
genuinely the only path (e.g. a cloud hard-blocking a public setting on new accounts), say so
explicitly, document it in code + your change log, and flag it as a follow-up to remove. When stuck,
surface it ("this needs a real IAM role; add it or stop here?") — don't silently take the easy path.
