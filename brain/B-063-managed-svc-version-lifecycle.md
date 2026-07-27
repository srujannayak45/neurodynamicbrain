---
id: B-063
tags: [infra, reference, gotcha]
scope: any multi-cloud Terraform estate with version-pinned managed services
hook: managed-service version EOL = a cost lever (EKS/GKE past standard support → extended-support surcharge); audit pinned versions vs endoflife.date, bump tfvars
---

# B-063 · Managed-service version lifecycle & extended-support cost audit

**The cost lever:** a managed service pinned to a **past-standard-support** version keeps running but
bills an **extended-support surcharge** — EKS **+~$0.60/hr (~$432/mo/cluster)**, GKE per-cluster
extended-support fees, AKS forces LTS (Premium tier). So old version pins = silent cost + upgrade debt.
Related: [[B-032]] (EKS surcharge + replace trap).

## Which services are version-pinned (the only ones with EOL/surcharge risk)
- **AWS:** EKS (`eks_cluster_version` + `eks_addon_versions` in lockstep), Lambda `runtime`, Neptune/
  RDS `engine_version`.
- **Azure:** AKS (`kubernetes_version`), Functions runtime version, Synapse Spark `spark_version`.
- **GCP:** GKE (`gke_kubernetes_version` → `min_master_version`/release channel), managed Kafka.
- **Serverless = no version, no surcharge** (ignore): DynamoDB, Kinesis, Redshift Serverless, Bedrock,
  Cosmos DB, Event Hubs, BigQuery, Firestore, Pub/Sub, Spanner, provider-managed Kafka.

## Snapshot (verify dates live — they roll)
K8s standard-support EOL (endoflife.date): 1.30=2025-07-23, 1.31=2025-11-26, 1.32=2026-03-23,
1.33=2026-07-29, 1.34≈2026-11-30. Extended = +12 months. Lambda python3.12 (EOL 2028-10) fine.

## Audit procedure
1. Enumerate version pins: grep tfvars + `.tf` for `*_version`/`runtime`/`engine_version`/
   `kubernetes_version`/`min_master_version` (skip provider `required_version`/`hashicorp/` constraints).
2. Get EOL truth: `WebFetch https://endoflife.date/api/<product>.json` (amazon-eks,
   google-kubernetes-engine, azure-kubernetes-service, python, apache-spark…). Compare each pin's
   standard-support `eol` to today.
3. Flag any pin past standard support → in extended support (surcharge) → bump.
4. **EKS bump = not a one-liner:** bump `eks_addon_versions` in lockstep —
   `aws eks describe-addon-versions --addon-name <a> --kubernetes-version <N>
   --query 'addons[0].addonVersions[?compatibilities[0].defaultVersion==`true`].addonVersion|[0]'`
   for vpc-cni/coredns/kube-proxy/aws-ebs-csi-driver/aws-efs-csi-driver/eks-pod-identity-agent.
5. **Fresh-create vs in-place:** torn-down/never-deployed cluster → jump straight to target version.
   LIVE cluster → one minor at a time only ([[B-032]]); never `-replace` (helm/k8s provider trap).

Procedure lives in skill `managed-svc-eol`.
