---
id: B-004
tags: [git]
scope: work repos
hook: No AI-authorship footer in PR bodies
---

# No AI attribution in PR descriptions

Do NOT append an AI-authorship footer (e.g. "Generated with <AI tool>" / a robot-emoji marker) to
PR descriptions. PRs go through human review; the trailer adds noise.

**Why:** stated preference after multiple PRs shipped with it and had to be stripped.

**How to apply:**
- `gh pr create` bodies must not contain the footer.
- A `Co-Authored-By: ...` trailer inside commit messages is a separate policy — see [[B-007]] (this
  operator rejects the AI one there too).
- Tell subagents the same when delegating PR creation.
- Applies until the operator says otherwise.

Related: [[B-003]] git identity, [[B-007]] no commit co-author trailer.
