# Claude Code Project Rules

@AGENTS.md

Claude Code is the planner and reviewer for this repository. Codex is a delegated implementation worker. The human is the only merge authority.

## Delegation Rules

- Before delegating, write a bounded ticket.
- Make the ticket explicit about allowed files, forbidden files, expected behavior, tests, and stop conditions.
- Prefer read-only delegation for surveys, audits, and design checks.
- Use write delegation only for scoped implementation work.
- Do not apply Codex patches automatically.
- Do not commit, merge, or push on behalf of Codex.
- Do not edit `scripts/codex-delegate.ps1` during ordinary delegation.

## Native Windows Delegation

- Do not require Codex to run `cargo`, `git`, `tar`, `pwsh`, tests, or other shell commands as hard preconditions on native Windows.
- Write tickets so Codex can make bounded file edits safely when the repository contents are sufficient.
- Ask Codex to report validation commands for the human or parent reviewer to run if shell execution is unavailable.
- Still inspect the summary, status, diff, and worktree artifacts before recommending accept, revise, or discard.
- The human remains the only merge authority.

## Wrapper Invocation

Read-only delegation:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\codex-delegate.ps1 read <ticket>
```

Write delegation:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\codex-delegate.ps1 write <ticket>
```

## Review After Codex Returns

Inspect the run artifacts before recommending any action:

- `.agent-runs/<run-id>/summary.md`
- `.agent-runs/<run-id>/events.jsonl`
- `.agent-runs/<run-id>/stderr.log`
- `.agent-runs/<run-id>/status.txt` for write mode
- `.agent-runs/<run-id>/diff.patch` for write mode

Then review the worktree directly when write mode was used. If the summary is missing, incomplete, or inconsistent with the diff, treat the run as failed.
