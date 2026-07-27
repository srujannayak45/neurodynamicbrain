---
id: B-009
tags: [infra, code]
scope: dev environment only (all clouds)
hook: Default every dev cloud service to its smallest viable size/count
---

# Minimalist sizing for all dev cloud services

In the `dev` environment, every service config (Terraform vars / module defaults) defaults to the
**smallest viable** size. Set it in the TF SOURCE (`env/dev.tfvars`), not just live — else the next
apply restores bloat.

| Service | Minimalist dev default |
|---|---|
| Redshift Serverless | `base_capacity = 8` RPU (AWS minimum) |
| Kinesis | 1 shard, PROVISIONED |
| EKS nodegroups | `desired=0` for non-essential (gpu/solver); `desired=1` system+general; `min=0,max=1` |
| ECS services | `desired_count = 0` unless actively in use |
| Lambda | 128–256 MB, default timeout, no provisioned concurrency |
| DynamoDB | `PAY_PER_REQUEST` (on-demand) |
| Glue Jobs | 2 workers, `G.1X` |
| SageMaker notebooks | `ml.t3.medium` |
| EC2 | `t3.micro` / `t3.small` |
| NAT Gateways | 1 (single AZ) |
| VPC endpoints | only ones with proven traffic |

**Why:** dev spend comes straight off a small budget with aggressive cost-pause cycles. Any default
above the cloud minimum becomes surprise spend on the next `apply`.

**How to apply:** new service → smallest value, not the "recommended for dev" from docs. Justify any
above-minimum value in a comment. Auditing → flag anything above minimum and ask before downsizing.
Dev only — staging/prod size themselves.
