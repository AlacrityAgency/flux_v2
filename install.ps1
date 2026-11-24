$ErrorActionPreference = "Stop"

$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = Join-Path $HOME ".gemini\config\skills\flux_v2"

New-Item -ItemType Directory -Force -Path (Join-Path $TargetDir "references") | Out-Null
Copy-Item -Force (Join-Path $SourceDir "SKILL.md") (Join-Path $TargetDir "SKILL.md")
Copy-Item -Force (Join-Path $SourceDir "references\prompt-templates.md") (Join-Path $TargetDir "references\prompt-templates.md")

Write-Host "Installed flux_v2 skill to: $TargetDir" -ForegroundColor Green
