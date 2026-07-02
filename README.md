# Claude Code + Codex Delegation Harness

This repository is a project-agnostic template for delegating bounded work from Claude Code to Codex while preserving human review and merge control.

Claude plans and reviews. Codex implements bounded tickets. The wrapper records artifacts. The human merges.

## What This Harness Is

The harness is a small local workflow for maker/checker development:

- Claude Code acts as planner, architect, ticket writer, and reviewer.
- Codex acts as a bounded implementation worker.
- `scripts/codex-delegate.ps1` creates run artifacts and, for write mode, an isolated Git worktree.
- The human remains the only merge authority.

The wrapper is part of the delegation boundary. Agents should not casually edit it during ordinary project work.

## Why Maker/Checker Helps

Separating planning from implementation makes agent work easier to review:

- tickets can be scoped before code changes begin
- implementation happens in a bounded workspace
- run outputs, summaries, status, and diffs are preserved
- review is explicit instead of being blended into generation
- merge authority stays with a human

This does not make agent output inherently safe. It makes the handoff and review surface easier to inspect.

## Workflow

1. Copy the template files into a project repository.
2. Add project-specific guidance to the copied `CLAUDE.md` and `AGENTS.md`.
3. Keep private machine-specific notes in `CLAUDE.local.md`.
4. Write a bounded ticket under `tickets/`.
5. Ask Claude Code to review the ticket before delegation.
6. Run Codex through the wrapper in read or write mode.
7. Review the run directory, summary, status, and diff.
8. Apply or recreate accepted changes manually.
9. Commit only after human review.

Read-only delegation:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\codex-delegate.ps1 read .\tickets\0000-readonly-repo-survey.md
```

Write delegation:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\codex-delegate.ps1 write .\tickets\0001-readme-dev-workflow.md
```

## Install Steps

1. Install Git.
2. Install Claude Code and Codex CLI using the official instructions for your environment.
3. Copy this repository's template files into the target project.
4. Commit the template files, but not generated run artifacts.
5. Create an initial commit before using write mode.

Optional model override:

```powershell
$env:CODEX_DELEGATE_MODEL = "gpt-5.5"
```

If unset, the wrapper defaults to `gpt-5.5`.

## Windows Usage

Use `powershell.exe -ExecutionPolicy Bypass -File` when invoking the wrapper from Claude Code or another shell:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\codex-delegate.ps1 read .\tickets\0000-readonly-repo-survey.md
```

The repository uses `.gitattributes` to keep common text files on LF endings. This reduces patch churn when work moves between Windows and Unix-like environments.

Native Windows Codex sandboxing may fail with:

```text
CreateProcessAsUserW failed: 5
```

Treat that as a sandbox or local environment issue, not as a reason to silently bypass review, skip the wrapper, or merge unreviewed changes.

## Safety Model

The harness depends on clear role boundaries:

- Claude Code writes or reviews bounded tickets.
- Codex follows the ticket and reports what changed.
- The wrapper records artifacts and isolates write-mode work.
- The human reviews all changes before merge.

The wrapper does not commit, merge, push, or approve work. It also does not prove that Codex output is correct, secure, complete, or ready to merge.

## What To Commit

Commit template and project guidance files:

- `README.md`
- `.gitattributes`
- `.gitignore`
- `templates/`
- `scripts/codex-delegate.ps1`
- `tickets/`
- `docs/`

Do not commit private or generated files:

- `CLAUDE.local.md`
- `.agent-runs/`
- `.agent-worktrees/`
- logs, transcripts, secrets, API keys, or provider config
- project-specific private doctrine

## Known Limitations

- Write mode requires an existing Git `HEAD` so Git can create a worktree.
- The wrapper preserves artifacts but does not apply patches for you.
- `diff.patch` captures tracked-file diffs; check `status.txt` for untracked files.
- Codex sandbox behavior depends on the installed CLI version and host OS.
- Failed or missing summaries must be investigated before any changes are trusted.
