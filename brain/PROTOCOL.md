# The Gate Protocol — full reference

Read on demand. The compact version lives in `CLAUDE.md` and is enough for most tasks.
This file is the spec: the gates, the tag vocabulary, and the write-back discipline.

## Why this exists

Token economy + speed. Two leaks this closes:
1. **Re-derivation** — re-reasoning facts already learned in a past session. → Fixed by G1 RECALL.
2. **Round-trips** — clarification loops that explicit intent would have avoided. → Fixed by G0 INTENT + the intent shorthand.

The brain is a local cache. Hit the cache before doing expensive reasoning or research.

## Neurodynamic framing (the model behind the protocol)

The brain is a three-layer perceptron (Rosenblatt): **S** = `CLAUDE.md` router (loads every session,
holds no facts); **A** = `INDEX.md` (interaction-matrix register, grepped) + `B-NNN` cells (one fact
each, loaded only on tag match — `@tags` are excitatory coupling, `scope` is inhibitory, `[[links]]`
are lateral); **R** = skills (motor programs that *cite* cells, never duplicate them) plus their
effector code. The Gate loop G0–G5 is the reinforcement system: **α** = unbounded write-back (new
cells), **γ** = consolidation/dedup (conserve, don't proliferate), the **D-signal** = decay (stale
markers). Selective recall — load the matched cells, never the whole brain — is what keeps the system
out of **saturation**. Full treatment is a deferred reference: cell [[B-059]] →
`references/neurodynamic-principles.md` (load only when designing brain structure or the protocol itself).

## The Gates

| Gate | Name | What happens | Skip when |
|------|------|--------------|-----------|
| G0 | INTENT | Establish goal + why. Echo a one-line read. Use the user's intent shorthand if given. | ask is terse + unambiguous |
| G1 | RECALL | `grep INDEX.md` for matching `@tags`; load only matched cells; reuse. | nothing in-domain is cached |
| G2 | SCOPE | Fence: touch / don't-touch / branch / done-when. | trivial single-file edit |
| G3 | BUILD | Implement against the G2 fence. | — |
| G4 | VERIFY | Run the done-when observable; report it plainly. | pure read/answer task |
| G5 | LEARN | Write durable patterns back to the brain. | nothing durable emerged |

## Standing principles

- **Model-driven, not glue.** Prefer a lawful projection of a modeled capability over hand-stitched
  integration glue. Begin from the capability + the structure it serves; connection should be a
  projection of a modeled surface, not a one-off script. "Done" (G4) means structurally reusable, not
  "it works once." If a cell encodes a glue/workaround/manual-script pattern, mark it as tactical debt
  and point at the proper fix. *"There is no virtue in being busy at the wrong level of abstraction."*
- **Seeding ≠ runtime.** Provisioning/seeding is one-time and provisioned separately; runtime behavior
  belongs in the runtime app + workflow, auto-triggered on data/upload events. Never make runtime
  behavior depend on a manual seed/operator script — if a script is the only way to make it work,
  you're missing a workflow trigger. Build the trigger, not the script.

## Intent shorthand

`>> <goal> | why: <intent> | touch: <files/layer> | done: <observable>`

Any field omittable. Present fields are a binding contract — don't re-ask.

## Tag vocabulary (regions of the brain)

This is the declared set — the **source of truth for `brain.sh tags --undeclared`**. Rule: **reuse,
don't proliferate** — add a new tag here (and in brain.sh) before using it.

**Core** — `@user` (identity/preferences/working style) · `@prompting` (how to read prompts) ·
`@git` (commit/PR/identity) · `@workflow` (process, multi-session, branching, CI, gates) ·
`@code` (reusable code patterns) · `@infra` (cloud/IaC/k8s/env) · `@gotcha` (traps, silent breakage) ·
`@meta` (about the brain/protocol itself) · `@reference` (a deferred long-doc handle).

**Namespaced** — `@arch:<system>` (architecture of a named system) · `@project:<name>` (project-local;
inhibitory across other projects) · `@api[:<service>]` (external API surface; record method+path+auth+
payload+status/gotcha). *(In this public example brain these namespaced regions are intentionally empty
— all project/customer/API-specific cells were removed.)*

**Domain** (example in-use set) — `@llm @observability @routing @memory @docker @auth @process @cors
@cache @terraform @envoy @nginx @ffmpeg @media`.

A cell may carry several tags; tag generously so recall finds it from multiple angles. `brain.sh tags`
shows current usage; `brain.sh tags --undeclared` flags anything off-vocabulary.

## Write-back discipline (G5)

Write a cell when something is **durable and reusable** — true next week, useful in another task.
Do NOT write conversation-specific trivia, or facts the codebase/git already records.

Procedure:
1. Allocate the id: `brain.sh next-id` (never hand-pick or reuse a retired number).
2. Create `B-NNN-<slug>.md` with frontmatter `id / tags / scope / hook` + the fact. For
   feedback/preference cells, include **Why** and **How to apply**.
3. Add one line to `INDEX.md` in the format `B-NNN | @tags | scope | hook → file`.
4. Link related cells with `[[B-NNN]]`.
5. Promote anything spanning >1 project to the brain (global). Project-local trivia can stay in that
   project's own memory dir, but its durable signal still gets a brain cell.
6. Run `brain.sh doctor` — it must PASS (this is the G4 verify step for brain edits).

Before writing, scan the index for an existing cell on the topic — UPDATE it rather than duplicate.
Delete cells that turn out wrong. Verify a cell's named files/flags still exist before acting on it.
The brain's invariants + cell lifecycle (draft→active→stale→retired/promoted) live in `MANIFEST.md`;
the maintenance tooling is `brain.sh` (cell [[B-022]]).

## Reference / deferred-load discipline

Long documents — specs, RFCs, transcripts, converted DOCX/PDF, big design write-ups — live in
`references/<slug>.md`, **not** in cells. A cell for a reference is only a small recall handle: it
carries `@reference` + a domain tag, the reference path + provenance, and a *when-to-load* line —
never the document body. Pasting a long doc into a B-cell is the A-unit-overload / saturation
anti-pattern. Ingest with the **reference-ingest** skill. Load the full reference only when the task
needs detail.

## D-signal (decay) convention

A cell that names a file/endpoint/flag that no longer exists, or that a stronger/newer cell
contradicts, is **stale**. Mark it with the volatile marker so recall warns before acting on it:

```markdown
> ⚠ POSSIBLY STALE — verify before acting. This cell names <file/endpoint/flag>.
> Confirm it still exists; delete or update this cell if it does not.
```

`brain.sh stale` surfaces these. Resolution: update, mark, merge, or retire (delete file + INDEX line
— a wrong memory is worse than none; don't reuse the id).

## Per-machine boundary (only portable signal syncs) — [[B-054]]

The brain repo (your dotfiles repo) is the cross-machine store, but **only durable, portable signal
rides it** — `B-NNN` cells, `INDEX.md`, `HANDOFF.md`, references, skills. Everything below is
**per-machine local state that must NEVER sync** (raw sync would leak credentials/paths or break the
peer machine):

```
~/.claude/sessions/         conversation state         ~/.claude/telemetry/        analytics
~/.claude/projects/         session metadata           ~/.claude/backups/          local backups
~/.claude/file-history/     edit history               ~/.claude/shell-snapshots/  shell env captures
~/.claude/settings.json     creds/paths/hooks          ~/.claude/ide/              IDE socket state
```

The first three (`sessions`, `projects`, `file-history`) are read **locally, read-only** by a harvest
step and distilled into a host-delimited `AUTO machine-state` block in HANDOFF.md — that distilled
block is the *only* trace of them that travels. The rest never leave the machine.

Enforcement is code, not discipline: both sync effectors carry an identical guard
`BLACKLIST_RE='^claude/(sessions|projects|file-history|telemetry|shell-snapshots|ide|backups|settings\.json)(/|$)'`
— the manual push **aborts** if any such path is staged (a human is watching); the Stop/SessionStart
hook **silently unstages and continues** (must never block session exit). Adding a new per-machine dir
means adding it to *both* guards, not just documenting it here. See [[B-137]] for the storage layout.

## Consolidation (γ) — don't let duplicates accumulate

α-write-back grows the brain; γ-consolidation keeps it convergent. When two cells say the same thing,
merge into ONE authoritative cell (union the tags, record "supersedes [[B-NNN]]" in the survivor,
remove the loser's INDEX line). `brain.sh dups` flags candidates. One authoritative cell always beats
five near-copies — that's how conflict reconciliation stays well-defined.

## Skills + effector code (R-units have arms)

A skill = `SKILL.md` (thin motor program: precise activation description + ordered steps + `[[B-NNN]]`
citations) ↔ the cells it acts on ↔ **effector code** (retained, reusable scripts in `skills/<name>/`
or shared `skills/_lib/`) ↔ an **execution surface** (the shell, an API, MCP). Retain a reusable script
and call it; don't regenerate deterministic code each session (code-level G1 recall). Facts stay in
cells, never in skills or effector bodies. Full anatomy: [[B-060]]; `brain.sh` itself is the canonical
effector (the brain-maintenance skill's arm, [[B-022]]).

### The effector gate (R-units must declare their arms) — [[B-065]]
Without enforcement, "R-units have arms" decays to prose and the R-layer goes *hollow*. So every
`SKILL.md` MUST declare an `effector:` in its frontmatter, in exactly one of three honest states:
- **`effector: <path>`** — retained executable code (resolved relative to the skill dir; `~` expands).
  The path must exist. Target state for any **deterministic/repeatable** procedure.
- **`effector: exempt — <reason>`** — a pure-judgment/policy skill with no separable deterministic core
  (e.g. `prompt-gates` *is* the loop; `infra-guard` is a review checklist). Allowed, must say why.
- **`effector: pending — <plan>`** — a procedural skill whose effector is *owed*; names the file to
  build. Tracked as a WARN, backfilled when the skill is next exercised.
**`brain.sh effectors` enforces this and is wired into `brain.sh doctor`**: a missing declaration or a
declared-but-absent path is a hard FAIL; `pending` warns but passes. **G5 rule:** when you *develop* a
new repeatable procedure, the deliverable is a retained effector + its `effector:` declaration — not
prose alone. "Whatever you develop must be runnable, manageable, improvable code."

> Note: the skills in this public example brain ship with their effector scripts stripped
> (`effector: exempt — generic example` or `pending`) — they demonstrate the shape, not the customer
> automation. Wire your own effectors and update the declarations.
