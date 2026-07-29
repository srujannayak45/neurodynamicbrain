---
id: B-011
tags: [git, infra, gotcha]
scope: all repos
hook: Never stage/commit cloud keys, secrets, tokens, or credential values
---

# No secrets or keys in git

Never put cloud access key IDs (`AKIA*`/`ASIA*`), secret access keys, session tokens, JWTs (`eyJ…`),
HMAC secrets, passwords, OAuth client secrets, or any live credential value into a committed file,
comment, commit message, PR description, tfvars, or any artifact that lands in git.

**Why:** git history is forever even after deletion; scanners (e.g. TruffleHog) flag it and force a
full rotation.

**How to apply:**
- Reference credentials by **file path** (`/tmp/service.jwt`) or **env var name** (`SERVICE_JWT`) —
  never the value.
- Source files (`.tf`, `.ts`, `.py`, `.yaml`, `.tfvars`) are fine when they only DECLARE resources /
  outputs — Terraform interpolations like `aws_iam_access_key.x.secret` are references, not values.
- Before `git add`, grep the staged diff:
  `git diff --cached | grep -E '(AKIA|ASIA|eyJ|aws_secret_access_key\s*=\s*[A-Za-z0-9])'`.
- Never commit `.tfstate` / `.tfstate.backup` / `.tfplan` (they serialize secrets) — verify
  `.gitignore` covers them per module.
- Real values live in TF state (S3+KMS), Secrets Manager, Key Vault, or a password manager — not in files.
