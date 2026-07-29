---
name: managed-svc-eol
effector: pending — skills/managed-svc-eol/scan.sh (version-pin EOL scanner)
description: >
  Audit managed-service versions across a multi-cloud Terraform estate for end-of-life /
  past-standard-support pins that incur extended-support surcharges (EKS +$0.60/hr, GKE fees), and bump
  them. Use when asked about managed-service lifecycle, support expiry, version EOL, "old versions we
  shouldn't use", or cost-saving upgrades. Facts cached in brain B-063.
---

# Managed-service version-lifecycle & extended-support cost audit

Facts + current snapshot live in brain **[[B-063]]**. Related: [[B-032]] (EKS extended-support
surcharge + `-replace` trap), skill `infra-guard`.

## The cost lever
A managed service pinned to a **past-standard-support** version keeps running but bills an
**extended-support surcharge** — EKS **+$0.60/hr (~$432/mo/cluster)**, GKE per-cluster extended-support
fees, AKS forces LTS (Premium tier). Old version pins = silent cost + upgrade debt. Only
**version-pinned** services carry this risk; serverless (DynamoDB, Kinesis, BigQuery, Spanner, Pub/Sub,
Cosmos, Event Hubs, provider-managed Kafka) do not.

## Procedure
1. **Find pins** (skip provider `required_version`/`hashicorp/` constraints):
   ```bash
   grep -rhnE 'eks_cluster_version|kubernetes_version|gke_kubernetes_version|min_master_version|engine_version|database_version|spark_version|runtime\s*=|function_python_version' <tf-root> --include='*.tf' --include='*.tfvars' \
     | grep -vE '#|required_version|hashicorp|>=|~>'
   ```
2. **Get EOL truth** — `WebFetch https://endoflife.date/api/<product>.json` for amazon-eks,
   google-kubernetes-engine, azure-kubernetes-service, python, apache-spark. Compare each pin's
   standard-support `eol` to **today**. Past `eol` → in extended support → flag.
3. **Bump the tfvars** to a version still in standard support (pick one with runway, not the one that
   expires next month).
4. **EKS is not a one-liner** — bump `eks_addon_versions` in lockstep:
   ```bash
   aws eks describe-addon-versions --addon-name <a> --kubernetes-version <N> \
     --query 'addons[0].addonVersions[?compatibilities[0].defaultVersion==`true`].addonVersion|[0]' --output text
   # a ∈ vpc-cni coredns kube-proxy aws-ebs-csi-driver aws-efs-csi-driver eks-pod-identity-agent
   ```
5. **Fresh-create vs in-place** — torn-down/never-deployed cluster → jump straight to target. LIVE
   cluster → one minor at a time only, never `-replace` ([[B-032]] helm/k8s-provider trap).

## Keep updating
Living skill. Refresh B-063's snapshot when versions move; re-run the audit each cost review.
