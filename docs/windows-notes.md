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

## CreateProcessAsUserW failed: 5

Native Windows Codex sandboxing may fail with:

```text
CreateProcessAsUserW failed: 5
```

At a practical level, this means Codex could not spawn a process inside the native Windows sandbox. It may block shell commands such as `git`, `pwsh`, test runners, archive tools, or language-specific commands.

This does not necessarily mean Codex cannot edit files. A ticket may still be safe to complete with bounded patch or file-edit operations when the repository contents are enough to make the change.

Treat this as a Codex sandbox or host environment issue. Do not silently bypass review, merge unreviewed work, edit the wrapper to remove safety boundaries, or switch casually to `danger-full-access` just to make a run complete.

If Codex returns after this error, run validation outside Codex from a normal trusted shell. Suggested local manual checks:

- inspect `.agent-runs/<run-id>/summary.md`
- inspect `.agent-runs/<run-id>/stderr.log`
- for write mode, inspect `.agent-runs/<run-id>/status.txt`
- for write mode, inspect `.agent-runs/<run-id>/diff.patch`
- run the validation commands Codex listed as skipped
- run the repository's normal lint, test, or build commands before accepting changes

## Why Write Mode Needs An Initial Commit

Write mode creates an isolated Git worktree from `HEAD`. A repository with no commits has no `HEAD`, so Git cannot create the worktree.

Create and review the initial template commit before using write mode.
