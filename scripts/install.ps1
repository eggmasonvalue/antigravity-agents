[CmdletBinding()]
param (
    [switch]$Local
)

$ErrorActionPreference = 'Stop'

$TargetAgentsDir = Join-Path $HOME ".gemini\config\agents"
$TargetSkillsDir = Join-Path $HOME ".gemini\config\skills"
$RepoUrl = "https://raw.githubusercontent.com/eggmasonvalue/antigravity-agents/main"
$Agents = @("better-agy.md", "lean-agy.md")
$Skills = @("agy-subagents")

Write-Host "==> Setting up Antigravity Agents and Skills..." -ForegroundColor Cyan

if (-not (Test-Path $TargetAgentsDir)) {
    New-Item -ItemType Directory -Path $TargetAgentsDir -Force | Out-Null
}
if (-not (Test-Path $TargetSkillsDir)) {
    New-Item -ItemType Directory -Path $TargetSkillsDir -Force | Out-Null
}

if ($Local) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepoRoot = Split-Path -Parent $ScriptDir
    Write-Host "==> Local mode: copying from $RepoRoot..." -ForegroundColor Yellow

    # Install Agents
    foreach ($agent in $Agents) {
        $SourcePath = Join-Path $RepoRoot "agents\$agent"
        $DestPath = Join-Path $TargetAgentsDir $agent
        if (Test-Path $SourcePath) {
            Copy-Item -Path $SourcePath -Destination $DestPath -Force
            Write-Host "  [+] Installed agent: $agent (local)" -ForegroundColor Green
        } else {
            Write-Warning "  [!] Source agent not found: $SourcePath"
        }
    }

    # Install Skills
    foreach ($skill in $Skills) {
        $SourcePath = Join-Path $RepoRoot ".agents\skills\$skill"
        $DestPath = Join-Path $TargetSkillsDir $skill
        if (Test-Path $SourcePath) {
            if (-not (Test-Path $DestPath)) {
                New-Item -ItemType Directory -Path $DestPath -Force | Out-Null
            }
            Copy-Item -Path "$SourcePath\*" -Destination $DestPath -Recurse -Force
            Write-Host "  [+] Installed skill: $skill (local)" -ForegroundColor Green
        } else {
            Write-Warning "  [!] Source skill not found: $SourcePath"
        }
    }
} else {
    Write-Host "==> Remote mode: fetching latest from GitHub..." -ForegroundColor Yellow

    # Install Agents
    foreach ($agent in $Agents) {
        $DownloadUrl = "$RepoUrl/agents/$agent"
        $DestPath = Join-Path $TargetAgentsDir $agent
        Write-Host "  --> Fetching agent $agent..."
        Invoke-RestMethod -Uri $DownloadUrl -OutFile $DestPath
        Write-Host "  [+] Installed agent: $agent" -ForegroundColor Green
    }

    # Install Skills
    foreach ($skill in $Skills) {
        $SkillDir = Join-Path $TargetSkillsDir $skill
        if (-not (Test-Path $SkillDir)) {
            New-Item -ItemType Directory -Path $SkillDir -Force | Out-Null
        }
        $DownloadUrl = "$RepoUrl/.agents/skills/$skill/SKILL.md"
        $DestPath = Join-Path $SkillDir "SKILL.md"
        Write-Host "  --> Fetching skill $skill..."
        Invoke-RestMethod -Uri $DownloadUrl -OutFile $DestPath
        Write-Host "  [+] Installed skill: $skill" -ForegroundColor Green
    }
}

Write-Host "==> Installation complete!" -ForegroundColor Cyan
Write-Host "    Verify agents: agy agents"
Write-Host "    Run Better:    agy --agent better-agy"
Write-Host "    Run Lean:      agy --agent lean-agy"
