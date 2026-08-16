[CmdletBinding()]
param (
    [switch]$Local
)

$ErrorActionPreference = 'Stop'

$TargetDir = Join-Path $HOME ".gemini\config\agents"
$RepoUrl = "https://raw.githubusercontent.com/eggmasonvalue/antigravity-agents/main"
$Agents = @("better-agy.md")

Write-Host "==> Setting up Antigravity Agents ($TargetDir)..." -ForegroundColor Cyan

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

if ($Local) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepoRoot = Split-Path -Parent $ScriptDir
    Write-Host "==> Local mode: copying agents from $RepoRoot\agents\..." -ForegroundColor Yellow

    foreach ($agent in $Agents) {
        $SourcePath = Join-Path $RepoRoot "agents\$agent"
        $DestPath = Join-Path $TargetDir $agent
        if (Test-Path $SourcePath) {
            Copy-Item -Path $SourcePath -Destination $DestPath -Force
            Write-Host "  [✓] Installed $agent (local)" -ForegroundColor Green
        } else {
            Write-Warning "  [!] Source agent not found: $SourcePath"
        }
    }
} else {
    Write-Host "==> Remote mode: fetching latest agents from GitHub..." -ForegroundColor Yellow

    foreach ($agent in $Agents) {
        $DownloadUrl = "$RepoUrl/agents/$agent"
        $DestPath = Join-Path $TargetDir $agent
        Write-Host "  --> Fetching $agent..."
        Invoke-RestMethod -Uri $DownloadUrl -OutFile $DestPath
        Write-Host "  [✓] Installed $agent" -ForegroundColor Green
    }
}

Write-Host "==> Installation complete!" -ForegroundColor Cyan
Write-Host "    Verify with: agy agents"
Write-Host "    Run with:    agy --agent better-agy"
