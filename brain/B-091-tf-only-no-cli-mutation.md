---
id: B-091
tags: [infra, terraform, gotcha]
scope: all cloud infra managed by Terraform
hook: Cloud state changes go through terraform plan→apply, never the CLI/console
---

# Cloud state changes go through Terraform plan→apply, never the CLI

**Rule (gating).** When deploying/changing anything in a cloud managed by Terraform, you MUST drive it
through Terraform: edit the `.tf`/module → `terraform plan` → review → `terraform apply`. NEVER use the
cloud CLI (or console) to create/modify/delete cloud resources. If you change any module or `.tf`,
running `plan` first and then `apply` is mandatory — the change must show up in the plan, not be
applied out-of-band.

**Why.** CLI/console mutations cause state drift: Terraform no longer matches reality, the next `apply`
fights the manual change or errors ("already exists"), and the change is invisible in review/history.
Terraform is the single source of truth.

**Boundary (allowed).** Read-only CLI for *inspection* is fine (`describe-*`, `get-*`, `list-*`,
`sts get-caller-identity`) — used to verify state, not change it.

**The one sanctioned out-of-band write:** secret *values*. The pattern is TF owns the
`aws_secretsmanager_secret` *container* (so the ARN is managed) but the VALUE is populated via
`aws secretsmanager put-secret-value` so the raw key never lands in TF state/git. A deliberate
exception, not a license to mutate other resources by CLI.

Pair with [[B-009]] [[B-010]] [[B-011]] (the infra-guard skill).
