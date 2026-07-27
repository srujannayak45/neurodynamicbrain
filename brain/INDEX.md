# Brain Index — addressable memory map (the hippocampus)

**This is a generic, sanitized EXAMPLE brain** — a public reference projection of a private
agent-memory store. All customer/project/API-specific cells have been removed; what remains is the
reusable core: operator preferences, git/IaC conventions, the brain protocol itself, generic LLM
patterns, and cross-project gotchas. IDs keep their original numbers (gaps are intentional — cells
were dropped, not renumbered).

Grep this file for `@tags` matching the task, then read ONLY the matched `B-NNN` cells.
This index is cheap to scan; the cells are loaded selectively. Do not auto-load all cells.

Format: `B-NNN | @tags | scope | one-line hook → file`

Tag regions: core `@user @prompting @git @workflow @code @infra @reference @gotcha @meta`;
             domain `@llm @observability @routing @memory @docker @auth @process @envoy @nginx @ffmpeg @terraform`.

Meta-subsystem: `PROTOCOL.md` (gate spec) · `MANIFEST.md` (invariants + lifecycle) · `brain.sh`
(doctor/next-id/tags/links/stats/stale/dups) · `references/` (deferred long-docs). Run `brain.sh
doctor` after any write-back — it must PASS.

---

## Self / core preferences

- B-001 | @user @meta | global | Operator profile — terse senior platform eng, dictates, token-economy minded → B-001-user-profile.md
- B-002 | @prompting @user | global | How to interpret a terse, dictated operator's prompts → B-002-prompting-interpretation.md
- B-003 | @git | work repos with a dedicated identity | Commit under the per-repo work identity, not your global personal one → B-003-git-identity.md
- B-004 | @git | work repos | No AI-authorship footer in PR bodies → B-004-no-pr-attribution.md
- B-005 | @workflow @git @gotcha | shared clones (multi-session) | Isolate work in a git worktree or a parallel session clobbers it → B-005-worktree-isolation.md
- B-007 | @git | all repos (overrides harness default) | No AI co-author trailer in commit messages — anywhere → B-007-no-commit-coauthor.md
- B-008 | @git @workflow | all repos | Cut a fresh branch before committing; never commit to integration branches → B-008-branch-hygiene.md
- B-011 | @git @infra @gotcha | all repos | Never stage/commit cloud keys, secrets, tokens, or credential values → B-011-no-secrets-in-git.md
- B-057 | @prompting @user @meta | global | Distill dictated/voice messages to a structured prompt before acting (voice-to-prompt) → B-057-voice-to-prompt-skill.md

## Infra / IaC standing rules

- B-009 | @infra @code | dev environment only (all clouds) | Default every dev cloud service to its smallest viable size/count → B-009-minimalist-dev-sizing.md
- B-010 | @infra @gotcha | all IaC / IAM / security-shaped work | Never widen scope as a shortcut — create the proper resource → B-010-no-security-shortcuts.md
- B-091 | @infra @terraform @gotcha | all cloud infra managed by Terraform | Cloud state changes go through terraform plan→apply, never the CLI/console → B-091-tf-only-no-cli-mutation.md

## Protocol / brain meta

- B-022 | @meta @workflow | global (the brain itself) | Maintain the brain with brain.sh; honor MANIFEST invariants on write-back → B-022-brain-maintenance.md
- B-054 | @memory @infra @reference @process | global | The brain git repo IS the central cross-machine memory — push on stop, pull on restart → B-054-session-handoff-central-memory.md
- B-059 | @reference @meta @workflow | global/reference | Rosenblatt neurodynamic (S/A/R) reframing of the brain protocol — deferred reference handle → B-059-neurodynamic-principles.md
- B-060 | @meta @workflow @code @reference | global/reference | Skill anatomy = SKILL.md ↔ cited cells ↔ effector code ↔ execution surfaces → B-060-skill-execution-anatomy.md
- B-061 | @workflow @meta @reference | global | CLAUDE.md is the cached S-prefix — keep it byte-stable; volatile state in cells/HANDOFF → B-061-protocol-prompt-cache.md
- B-062 | @meta @workflow @reference | global | Decision record: adopted neurodynamic framing as a deferred reference, closed 5 gaps → B-062-neurodynamic-adoption.md
- B-065 | @meta @workflow @code | global | The effector gate — every SKILL.md must declare effector:<path|exempt|pending> → B-065-effector-gate.md
- B-128 | @workflow @process @meta | all sessions | Always validate against the brain before acting — recall first, every task → B-128-validate-with-brain-always.md
- B-129 | @meta @workflow @memory | all devices | Brain auto-syncs itself — SessionStart pulls, Stop pushes; installer bootstraps a device → B-129-brain-auto-sync-hooks.md
- B-137 | @meta @memory @workflow @process @reference | global | Where agent session history lives on disk + how to sync to brain (distill, not bulk) → B-137-claude-code-session-catalog.md
- B-147 | @workflow @memory @process | global | HARD PROTOCOL — idle >20 min ⇒ push the brain; every agent that pulls must push back → B-147-idle-upload-brain-protocol.md

## Orchestration / git workflow

- B-067 | @meta @workflow @prompting @process @code | any large/fuzzy task | Decompose a big/fuzzy problem into independently-verifiable units, solo or fanned out → B-067-decompose-and-orchestrate.md
- B-110 | @workflow @git @gotcha @meta | all repos (agent worktree fan-out) | Agent worktrees default their base to the repo default branch — recall + pin the real base → B-110-worktree-fanout-base-branch.md
- B-143 | @process @git @workflow @gotcha @reference | cross-project | "Unraised PR" sweep: squash-merge makes merged branches look ahead; use merge-tree net-zero → B-143-unraised-pr-squash-merge-detection.md

## Generic LLM patterns

- B-023 | @code @llm @observability @gotcha | any service calling Anthropic /v1/messages | Prompt caching needs both halves — stable system prefix AND granular usage passthrough → B-023-anthropic-prompt-caching.md
- B-024 | @code @llm @routing @observability | any LLM service handling >1 task type | Classify every LLM call into a task family before picking the model; route by table → B-024-task-family-routing.md

## Generic cloud / infra gotchas

- B-032 | @infra @gotcha @code | Terraform stacks with terraform-aws-modules/eks + helm/k8s providers | EKS cluster -replace fails as one apply (helm provider config trap); use sequential in-place upgrade → B-032-eks-replace-helm-provider-trap.md
- B-063 | @infra @reference @gotcha | any multi-cloud Terraform estate | Managed-service version EOL = a cost lever (extended-support surcharge); audit pins vs endoflife.date → B-063-managed-svc-version-lifecycle.md
- B-099 | @workflow @infra @auth @git @gotcha | any repo using GHA + cloud IAM OIDC | GHA jobs with `environment:` rewrite the OIDC `sub` claim — trust policies must allow both forms → B-099-gha-oidc-environment-sub-claim.md
- B-101 | @workflow @gotcha @meta @process @infra | any destructive infra mutation to "fix" a symptom | Right-shape fix ≠ right diagnosis — verify error string + call path + egress before mutating → B-101-diagnosis-before-infra-mutation.md
- B-102 | @infra @auth @gotcha | debugging OIDC federation failures | CloudTrail lookup-events for AssumeRoleWithWebIdentity is unreliable (global us-east-1; pre-assume failures unlogged) → B-102-cloudtrail-assumerole-webidentity-lookup-gotcha.md

## Generic dev / tooling gotchas

- B-154 | @code @reference @gotcha | any spreadsheet extraction | Reconstruct visual tables w/o native Table objects — semantic-header scoring + spacer tolerance → B-154-spreadsheet-table-detection-heuristics.md
- B-155 | @infra @gotcha @config | building the Go toolchain from source | Building Go from source needs GOROOT_BOOTSTRAP at an existing Go — default ~/go1.4 does not exist → B-155-go-source-build-bootstrap.md
- B-172 | @envoy @gateway @gotcha @code | any Envoy static-config gateway | Envoy cookbook — offline validate, shared HCM via YAML anchor, TLS, local_ratelimit, CORS double-header → B-172-envoy-gateway-patterns.md
- B-173 | @docker @gotcha | any docker-compose stack | Config changes need the RIGHT reload — bind-mount vs image-baked vs proxy cache vs 127.0.0.1 admin → B-173-docker-config-reload-gotchas.md
- B-174 | @nginx @cors @gateway @cache @gotcha | any nginx reverse-proxy / HLS edge | Two nginx CORS pitfalls + auth_request pattern to cache token-gated immutable assets across users → B-174-nginx-edge-cors-token-cache.md
- B-175 | @ffmpeg @media @gotcha @code | any FFmpeg ABR HLS/CMAF packager | No single static FFmpeg HLS recipe handles both audio and video-only input — branch maps + var_stream_map → B-175-ffmpeg-abr-hls-cmaf-audio-branching.md
- B-179 | @git @workflow @gotcha @meta | machine with multiple gh CLI accounts | gh CLI has ONE active account; switching breaks git push/pull to the other identity's repos → B-179-gh-cli-single-active-account-gotcha.md
- B-188 | @code @workflow @gotcha @reference | proving real browser interaction of a local web app | puppeteer-core pointed at existing Chrome via executablePath — real scripted verification, no download → B-188-puppeteer-core-existing-chrome-verify.md
- B-189 | @git @gotcha @meta @memory | dotfiles/brain repo on a multi-account machine | gh's active account (not the keychain token) decides which token git push uses → silent 404 → B-189-gh-multi-account-silent-push-failure.md
