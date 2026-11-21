[CmdletBinding()]
param (
    [switch]$Local
)

$ErrorActionPreference = 'Stop'

$TargetAgentsDir = Join-Path $HOME ".gemini\config\agents"
$TargetSkillsDir = Join-Path $HOME ".gemini\config\skills"
$RepoUrl = "https://raw.githubusercontent.com/eggmasonvalue/antigravity-agents/main"

$CleanFiles = @(
    "agent.md",
    "worker.md",
    "skills/run-workflow/SKILL.md",
    "skills/agy-subagents/SKILL.md"
)

Write-Host "==> Setting up Antigravity Agents (clean & bare)..." -ForegroundColor Cyan

New-Item -ItemType Directory -Path (Join-Path $TargetAgentsDir "clean\skills\run-workflow") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $TargetAgentsDir "clean\skills\agy-subagents") -Force | Out-Null

# Clean up legacy v0.1/v0.2 global installations to avoid duplicate agents or global skill bleed
foreach ($legacyName in @("better-agy.md", "lean-agy.md")) {
    $legacyPath = Join-Path $TargetAgentsDir $legacyName
    if (Test-Path $legacyPath) {
        Remove-Item -Path $legacyPath -Force
        Write-Host "  [~] Removed legacy agent: $legacyName" -ForegroundColor DarkYellow
    }
}
$legacySkillDir = Join-Path $TargetSkillsDir "agy-subagents"
if (Test-Path $legacySkillDir) {
    Remove-Item -Path $legacySkillDir -Recurse -Force
    Write-Host "  [~] Removed legacy global skill: agy-subagents (now scoped privately to clean)" -ForegroundColor DarkYellow
}

if ($Local) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepoRoot = Split-Path -Parent $ScriptDir
    Write-Host "==> Local mode: copying from $RepoRoot..." -ForegroundColor Yellow

    foreach ($rel in $CleanFiles) {
        $relWin = $rel -replace '/', '\'
        $SourcePath = Join-Path $RepoRoot "agents\clean\$relWin"
        $DestPath = Join-Path $TargetAgentsDir "clean\$relWin"
        if (Test-Path $SourcePath) {
            New-Item -ItemType Directory -Path (Split-Path -Parent $DestPath) -Force | Out-Null
            Copy-Item -Path $SourcePath -Destination $DestPath -Force
            Write-Host "  [+] Installed clean/$rel (local)" -ForegroundColor Green
        } else {
            Write-Warning "  [!] Source not found: $SourcePath"
        }
    }

    $BareSource = Join-Path $RepoRoot "agents\bare.md"
    $BareDest = Join-Path $TargetAgentsDir "bare.md"
    if (Test-Path $BareSource) {
        Copy-Item -Path $BareSource -Destination $BareDest -Force
        Write-Host "  [+] Installed bare.md (local)" -ForegroundColor Green
    } else {
        Write-Warning "  [!] Source not found: $BareSource"
    }
} else {
    Write-Host "==> Remote mode: fetching latest from GitHub..." -ForegroundColor Yellow

    foreach ($rel in $CleanFiles) {
        $relWin = $rel -replace '/', '\'
        $DownloadUrl = "$RepoUrl/agents/clean/$rel"
        $DestPath = Join-Path $TargetAgentsDir "clean\$relWin"
        New-Item -ItemType Directory -Path (Split-Path -Parent $DestPath) -Force | Out-Null
        Write-Host "  --> Fetching clean/$rel..."
        Invoke-RestMethod -Uri $DownloadUrl -OutFile $DestPath
        Write-Host "  [+] Installed clean/$rel" -ForegroundColor Green
    }

    Write-Host "  --> Fetching bare.md..."
    Invoke-RestMethod -Uri "$RepoUrl/agents/bare.md" -OutFile (Join-Path $TargetAgentsDir "bare.md")
    Write-Host "  [+] Installed bare.md" -ForegroundColor Green
}

Write-Host "==> Installation complete!" -ForegroundColor Cyan
Write-Host "    Verify agents: agy agents"
Write-Host "    Run Clean:     agy --agent clean"
Write-Host "    Run Bare:      agy --agent bare"
