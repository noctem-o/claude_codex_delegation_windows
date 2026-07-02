# Windows Notes

## PowerShell Invocation

Run the wrapper with `powershell.exe -ExecutionPolicy Bypass -File`:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\codex-delegate.ps1 read .\tickets\0000-readonly-repo-survey.md
```

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\codex-delegate.ps1 write .\tickets\0001-readme-dev-workflow.md
```

`ExecutionPolicy Bypass` affects this process invocation. It is useful when local policy blocks unsigned scripts.

## Line Endings

The template includes `.gitattributes` so common text files use LF endings. This reduces noisy patches when agents or humans work across Windows and Unix-like systems.

Keep generated artifacts out of Git. They may contain host-specific paths and tool output.

## Native Sandbox Error

Native Windows Codex sandboxing may fail with:

```text
CreateProcessAsUserW failed: 5
```

Treat this as a Codex sandbox or host environment issue. Do not silently bypass review, merge unreviewed work, or edit the wrapper to remove safety boundaries just to make a run complete.

Useful checks:

- confirm the Codex CLI works outside the wrapper
- retry read mode with a small ticket
- inspect `.agent-runs/<run-id>/stderr.log`
- record the failure as an environment issue if the sandbox cannot spawn processes

## Why Write Mode Needs An Initial Commit

Write mode creates an isolated Git worktree from `HEAD`. A repository with no commits has no `HEAD`, so Git cannot create the worktree.

Create and review the initial template commit before using write mode.
