# Troubleshooting

## Write Mode Fails Because There Is No HEAD

Symptom:

```text
git rev-parse --verify HEAD failed
```

Cause: the repository has no commits yet.

Fix: make a reviewed initial commit, then rerun write mode.

## Patch Does Not Apply Cleanly

Common causes:

- whitespace drift
- CRLF versus LF line endings
- the target file changed after Codex ran
- untracked files were not included in `diff.patch`

Inspect `status.txt`, `diff.patch`, and the worktree directly. Recreate the accepted change manually when that is safer than applying a patch.

## summary.md Is Missing

Treat the run as failed.

Check:

- `events.jsonl`
- `stderr.log`
- Codex CLI availability
- sandbox errors
- model name configuration

Do not trust write-mode changes from a run that failed to produce a summary.

## Codex Sandbox Cannot Spawn Processes

On native Windows, this may appear as:

```text
CreateProcessAsUserW failed: 5
```

Treat it as a sandbox or environment issue. Do not remove review steps or weaken the wrapper to hide the failure.

## Wrapper Was Accidentally Edited

Stop ordinary delegation and review the wrapper change separately.

Recommended checks:

- compare against the last reviewed version
- confirm it still creates run artifacts
- confirm write mode still uses a worktree
- confirm it still avoids commit, merge, push, and broad staging behavior
- confirm it does not pass unsupported Codex CLI flags

## Generated Artifacts Were Accidentally Staged

Unstage them before commit:

```powershell
git restore --staged .agent-runs .agent-worktrees
```

Then confirm:

```powershell
git status --short
```

Generated artifacts should remain untracked or ignored.
