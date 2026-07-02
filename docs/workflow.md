# Delegation Workflow

This harness supports a maker/checker loop for agent-assisted development.

## Roles

Claude Code is the planner and reviewer. It turns goals into bounded tickets, checks whether a ticket is clear enough to delegate, and reviews Codex output after the run.

Codex is the bounded implementation worker. It follows the ticket, changes only what the ticket allows, and reports what it did.

The wrapper records the run and creates isolation for write-mode work. It is part of the boundary and should not be edited during ordinary delegated work.

The human remains merge authority. No agent output is merged just because it exists.

## Loop

1. Human describes a goal.
2. Claude Code writes or refines a ticket.
3. Claude Code checks that the ticket has a narrow scope, allowed files, forbidden files, tests, and stop conditions.
4. Claude Code invokes the wrapper in read or write mode.
5. Codex runs inside the requested sandbox.
6. The wrapper stores artifacts under `.agent-runs/<run-id>/`.
7. For write mode, the wrapper stores the implementation in `.agent-worktrees/<run-id>/`.
8. Claude Code reviews the summary, status, diff, and worktree.
9. Human decides whether to apply, revise, reject, or commit the work.

## Read Mode

Read mode is for surveys, audits, design reviews, and planning support. It uses the current repository and a read-only sandbox.

Use read mode when the correct output is advice, findings, or a bounded implementation plan.

## Write Mode

Write mode is for narrow implementation tickets. It requires an existing Git `HEAD` because Git needs a commit to create a worktree.

Use write mode when the ticket names the files Codex may edit and the checks it should run.

On native Windows, shell execution inside the Codex sandbox may fail with `CreateProcessAsUserW failed: 5`. Write tickets so bounded file edits can still be completed safely when possible, and list validation commands for the human reviewer to run if Codex cannot run them.

## Reviewing A Run

Start with:

- `summary.md`
- `events.jsonl`
- `stderr.log`

For write mode, also inspect:

- `status.txt`
- `diff.patch`
- `.agent-worktrees/<run-id>/`

If the summary and diff disagree, trust neither until the worktree has been inspected.
