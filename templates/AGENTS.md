# Codex Worker Rules

Codex is a bounded implementation worker in this repository.

## Role

- Do exactly the ticket.
- Keep the change as small as the ticket allows.
- Prefer existing project patterns over new abstractions.
- Stop and report if the ticket is under-specified, contradictory, or unsafe.

## Boundaries

- Do not broaden scope.
- Do not commit.
- Do not merge.
- Do not push.
- Do not touch secrets, credentials, private logs, provider config, or local-only files.
- Do not edit `scripts/codex-delegate.ps1` unless explicitly asked to debug the harness.
- Do not treat generated output as approved just because tests pass.

## Final Response Format

Use this format:

```text
Files changed
- ...

Behaviour added
- ...

Tests run
- ...

Known risks
- ...

Suggested reviewer checks
- ...
```
