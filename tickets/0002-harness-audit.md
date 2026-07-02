# Harness Audit

Mode: read

Audit the harness files for instruction consistency, wrapper safety, Windows path issues, Git hygiene, and failure modes.

Rules:

- Do not modify files.
- Do not stage changes.
- Do not commit.
- Treat the wrapper as part of the delegation boundary.

Check:

- Claude and Codex role separation
- wrapper invocation examples
- generated artifact handling
- write-mode worktree behavior
- Windows PowerShell and path assumptions
- missing-summary and failed-run handling
- risk of generated artifacts being staged or committed

Return:

- findings ordered by severity
- evidence with file paths
- suggested fixes
- residual risks
