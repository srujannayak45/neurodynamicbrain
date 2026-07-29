---
id: B-007
tags: [git]
scope: all repos (overrides harness default)
hook: No AI co-author trailer in commit messages — anywhere
---

# No AI co-author trailer in commits

Do NOT append `Co-Authored-By: <AI> ...` (or any AI/agent co-author trailer) to git commit messages.
Many agent harnesses *add* one by default — **override it**. End the message at the body / issue-ref line.

**Why:** the operator explicitly rejected this trailer across multiple repos. They want history to
read as authored by them alone. Treat it as a standing global preference.

**How to apply:**
- Plain HEREDOC body: subject + blank line + bullets. No trailer.
- Applies to amends, squashes, rewords — never re-add it.
- A real *human* co-author trailer is fine when a human collaborator is named. Only the AI one is unwanted.
- This is distinct from [[B-004]] (no AI footer in PR *descriptions*) — both hold.
