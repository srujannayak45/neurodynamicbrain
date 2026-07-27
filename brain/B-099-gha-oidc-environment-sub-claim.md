---
id: B-099
tags: [workflow, infra, auth, git, gotcha]
scope: any repo using GitHub Actions + cloud IAM OIDC federation
hook: GHA jobs with `environment:` get sub=repo:.../environment:X (NOT ref:refs/heads/...) — trust policies must allow both
---

# GitHub Actions OIDC: `environment:` rewrites the `sub` claim

**Why:** GitHub Actions OIDC tokens carry a `sub` claim that IAM trust policies match against to gate
`sts:AssumeRoleWithWebIdentity`. The claim shape **depends on whether the job declares `environment:`**
— silently, with no warning. A workflow where some jobs run unenvironmented and others bind to an
environment will see the unenvironmented jobs assume the role fine and the environment-bound job get
`Not authorized to perform sts:AssumeRoleWithWebIdentity` against **the same role**. This wastes hours
because "the trust policy clearly allows this branch" looks correct.

| Job stanza | `sub` claim issued |
|---|---|
| no `environment:` | `repo:<org>/<repo>:ref:refs/heads/<branch>` |
| `environment: name: dev` | `repo:<org>/<repo>:environment:dev` |
| `pull_request` triggered | `repo:<org>/<repo>:pull_request` |
| tag push | `repo:<org>/<repo>:ref:refs/tags/<tag>` |

**How to apply:**
- When designing the IAM role trust policy for a GHA workflow that mixes environment-bound and
  unenvironmented jobs, allow BOTH sub forms via `StringLike`:
  ```json
  "StringLike": {
    "token.actions.githubusercontent.com:sub": [
      "repo:<org>/<repo>:ref:refs/heads/<branch>",
      "repo:<org>/<repo>:environment:<env-name>"
    ]
  }
  ```
- When debugging "OIDC works for one job and not another in the same workflow run", the first thing to
  check is `environment:` on the failing job — then `aws iam get-role --role-name <role> --query
  'Role.AssumeRolePolicyDocument'` for the missing sub form.
- The `aud` claim (default `sts.amazonaws.com`) and `iss`
  (`https://token.actions.githubusercontent.com`) DON'T change with `environment:`; only `sub` does.
- Applies to any cloud's OIDC federation (AWS IAM, GCP Workload Identity, Azure AD federated
  credentials) — wherever the subject is matched against a policy. The exact failure shown is the AWS
  one; the principle generalizes.

## Related
- [[B-091]] TF-only — the trust-policy widening MUST go through Terraform, never a manual CLI update.
- [[B-010]] No security shortcuts — DO widen the trust policy correctly (StringLike both patterns), DO
  NOT collapse to `repo:<org>/<repo>:*`.
- [[B-102]] CloudTrail AssumeRoleWithWebIdentity lookups are unreliable when diagnosing these.
