---
id: B-032
tags: [infra, gotcha, code]
scope: any Terraform stack using terraform-aws-modules/eks + helm/kubernetes providers
hook: terraform-aws-modules/eks cluster -replace fails as one apply (helm/k8s providers configured from cluster auth); use sequential in-place upgrade
---

# B-032 · EKS cluster recreate via terraform -replace is a one-shot trap

**Applies to:** any Terraform stack using `terraform-aws-modules/eks` where the same root/module also
declares `helm_release` / `kubernetes_*` resources whose provider is configured from the cluster
(endpoint + `data.aws_eks_cluster_auth`).

## Symptom
`terraform apply -replace='module.eks.aws_eks_cluster.this[0]'` (e.g. to jump K8s minors, since EKS
only upgrades one minor in-place) **aborts at plan time**:
```
Error: Kubernetes cluster unreachable: invalid configuration: no configuration
has been provided  (helm_release.<...>, ...)
```
Replacing the cluster cascades to the OIDC provider, all node groups, all addons, and access entries.

## Why
The `helm`/`kubernetes` providers take `host`/`token` from the cluster being replaced. Once the
cluster resource is marked for replacement those attributes are "known after apply", so the provider
can't configure at plan time → every helm_release that provider owns errors out and the apply never starts.

## Fixes (in preference order)
1. **Sequential in-place upgrade** (non-destructive, no outage): bump `cluster_version` ONE minor at a
   time, apply each hop, bump the pinned addon versions in lockstep (get defaults via
   `aws eks describe-addon-versions --addon-name X --kubernetes-version N`). Cluster is never replaced,
   so the helm provider stays connected. This is the right answer ~always.
2. **Scripted multi-phase recreate** (outage; only if a fresh cluster is actually wanted):
   `terraform destroy -target=helm_release.*` → `apply -replace=<cluster> -target=module.eks` →
   `apply` (helm re-created on new cluster) → resync GitOps. Babysit in a maintenance window.
3. NEVER `destroy-all` to "recreate the cluster" — it tears down EVERY layer incl. data stores, the
   identity pool, AND the TF state bucket. Catastrophic.

## Context: why you'd be here
EKS extended-support surcharge. A cluster on a version past *standard* support pays ~$0.60/hr on top
of the control-plane cost. Check with
`aws eks describe-cluster --query cluster.upgradePolicy.supportType` (EXTENDED = paying). Cost
Explorer usage type = `<region>-AmazonEKS-Hours:extendedSupport`.

Related: [[B-009]] (minimalist dev sizing), [[B-063]] (managed-service version EOL as a cost lever).
