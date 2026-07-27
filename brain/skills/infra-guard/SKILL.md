---
name: infra-guard
effector: exempt — judgment review checklist; no separable deterministic core
description: >
  Review a Terraform / IaC change before commit or apply. Use when editing or reviewing `.tf`/`.tfvars`,
  Helm, or k8s manifests for a dev environment, or before `terraform apply`. Enforces three standing
  rules: minimalist dev sizing, no security-shaped shortcuts (create the proper IAM/KMS/cert/secret
  resource — never widen scope), and no secret values in the diff.
---

# Infra change guard (pre-commit / pre-apply IaC review)

Facts + rationale in brain `B-009` (sizing), `B-010` (no shortcuts), `B-011` (secrets). This skill is
the checklist to run over a diff.

## Checklist

1. **Minimalist dev sizing ([[B-009]]).** For every `dev` service in the diff, is it the smallest
   viable value (set in the TF SOURCE, not just live)? Flag anything above the cloud minimum — Redshift
   8 RPU, Kinesis 1 shard, EKS `desired=0` non-essential / `1` system, DynamoDB on-demand, Lambda
   128–256MB, NAT ×1. Any above-minimum value needs a justifying comment, else ask. Dev only.

2. **No security-shaped shortcuts ([[B-010]]).** Scan for scope-widening workarounds and REJECT them:
   `:root` principals, `*` wildcards in policies, provider-managed keys where a CMK is intended,
   self-signed certs, public access to dodge DNS/PrivateLink, inline admin policies, long-term `data.`
   refs instead of codified resources. If a referenced role/key/cert/secret is missing → create it
   properly. If a shortcut is genuinely the only path, document it in code + your change log and flag a
   follow-up to remove.

3. **No secrets in the diff ([[B-011]]).**
   `git diff --cached | grep -E '(AKIA|ASIA|eyJ|aws_secret_access_key\s*=\s*[A-Za-z0-9])'` must be
   empty. No `.tfstate`/`.tfstate.backup`/`.tfplan` staged (verify `.gitignore`). Declarations and TF
   interpolations (`aws_iam_access_key.x.secret`) are fine — literal values are not.

Report findings as a short list. If anything fails, surface it and ask before proceeding — don't
silently fix-and-apply.
