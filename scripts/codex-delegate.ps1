[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("read", "write")]
    [string]$Mode,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Ticket
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & git -C $WorkingDirectory @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed in $WorkingDirectory`n$output"
    }

    return $output
}

function New-Directory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

$startDirectory = (Get-Location).Path
$gitRootRaw = Invoke-Git -WorkingDirectory $startDirectory -Arguments @("rev-parse", "--show-toplevel")
$gitRoot = (Resolve-Path -LiteralPath (($gitRootRaw | Select-Object -First 1).Trim())).Path

$ticketPath = (Resolve-Path -LiteralPath $Ticket).Path
if (-not (Test-Path -LiteralPath $ticketPath -PathType Leaf)) {
    throw "Ticket is not a file: $Ticket"
}

$model = $env:CODEX_DELEGATE_MODEL
if ([string]::IsNullOrWhiteSpace($model)) {
    $model = "gpt-5.5"
}

$runId = "{0}-{1}" -f (Get-Date -Format "yyyyMMdd-HHmmss"), ([Guid]::NewGuid().ToString("N").Substring(0, 8))
$runRoot = Join-Path $gitRoot ".agent-runs"
$runDir = Join-Path $runRoot $runId
$worktreeRoot = Join-Path $gitRoot ".agent-worktrees"

New-Directory -Path $runRoot
New-Directory -Path $runDir

$summaryPath = Join-Path $runDir "summary.md"
$eventsPath = Join-Path $runDir "events.jsonl"
$stderrPath = Join-Path $runDir "stderr.log"
$promptPath = Join-Path $runDir "prompt.md"
$copiedTicketPath = Join-Path $runDir "ticket.md"

Copy-Item -LiteralPath $ticketPath -Destination $copiedTicketPath

if ($Mode -eq "write") {
    Invoke-Git -WorkingDirectory $gitRoot -Arguments @("rev-parse", "--verify", "HEAD") | Out-Null
    New-Directory -Path $worktreeRoot

    $workDir = Join-Path $worktreeRoot $runId
    if (Test-Path -LiteralPath $workDir) {
        throw "Worktree path already exists: $workDir"
    }

    Invoke-Git -WorkingDirectory $gitRoot -Arguments @("worktree", "add", "--detach", $workDir, "HEAD") | Out-Null
    $sandbox = "workspace-write"
}
else {
    $workDir = $gitRoot
    $sandbox = "read-only"
}

$ticketText = Get-Content -LiteralPath $copiedTicketPath -Raw
$prompt = @"
You are Codex running as a bounded implementation worker inside a local delegation harness.

Mode: $Mode
Working directory: $workDir
Sandbox: $sandbox
Model: $model
Run directory: $runDir

Follow these rules:
- Do exactly the ticket.
- Do not broaden scope.
- Do not commit, merge, push, or stage broad changes.
- Do not touch secrets, credentials, private logs, provider config, or local-only files.
- Do not edit scripts/codex-delegate.ps1 unless the ticket explicitly asks you to debug the harness.
- Stop and report if the ticket is under-specified, contradictory, or unsafe.
- Native Windows shell execution may fail with CreateProcessAsUserW failed: 5.
- If shell or process commands fail with that error, do not repeatedly retry them.
- Continue with patch or file edits only when the ticket can be completed safely from repository contents.
- Report validation commands skipped because shell execution was unavailable.
- Never claim tests or checks passed unless they actually ran and passed.

Final response format:
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

Ticket:
$ticketText
"@

Set-Content -LiteralPath $promptPath -Value $prompt -Encoding UTF8

$codexArgs = @(
    "exec",
    "--cd", $workDir,
    "--model", $model,
    "--sandbox", $sandbox,
    "--json",
    "--output-last-message", $summaryPath,
    (Get-Content -LiteralPath $promptPath -Raw)
)

# Keep stdout and stderr separated. Older Windows PowerShell can turn native
# stderr into error records when streams are merged, which can corrupt the
# JSONL event stream. Codex JSON events stay on stdout, and stderr goes to a
# separate diagnostic log.
& codex @codexArgs 1> $eventsPath 2> $stderrPath
$codexExitCode = $LASTEXITCODE

if ($Mode -eq "write") {
    $statusPath = Join-Path $runDir "status.txt"
    $diffPath = Join-Path $runDir "diff.patch"

    Invoke-Git -WorkingDirectory $workDir -Arguments @("status", "--short") |
        Set-Content -LiteralPath $statusPath -Encoding UTF8

    Invoke-Git -WorkingDirectory $workDir -Arguments @("diff", "--no-ext-diff", "--binary") |
        Set-Content -LiteralPath $diffPath -Encoding UTF8
}

if (-not (Test-Path -LiteralPath $summaryPath -PathType Leaf)) {
    throw "Codex did not produce summary.md. Inspect $eventsPath and $stderrPath."
}

if ($codexExitCode -ne 0) {
    throw "codex exec exited with code $codexExitCode. Inspect $summaryPath, $eventsPath, and $stderrPath."
}

Write-Host "Run directory: $runDir"
Write-Host "Summary: $summaryPath"
if ($Mode -eq "write") {
    Write-Host "Worktree: $workDir"
    Write-Host "Status: $(Join-Path $runDir 'status.txt')"
    Write-Host "Diff: $(Join-Path $runDir 'diff.patch')"
}
