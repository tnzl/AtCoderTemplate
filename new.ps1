param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Url,

    [string]$Dir = ".",
    [switch]$KeepTests,
    [switch]$ResetMain
)

$Root = $PSScriptRoot
$TargetDir = if ($Dir -eq ".") { $Root } else { Join-Path $Root $Dir }

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}

$mainPath = Join-Path $TargetDir "main.cpp"
if ($ResetMain -or -not (Test-Path $mainPath)) {
    Copy-Item (Join-Path $Root "template\main.cpp") $mainPath -Force
    Write-Host "Created $mainPath" -ForegroundColor Green
} else {
    Write-Host "Keeping existing $mainPath (use -ResetMain for a fresh template)" -ForegroundColor Yellow
}

Push-Location $TargetDir
try {
    $downloadArgs = @{ Url = $Url }
    if (-not $KeepTests) {
        $downloadArgs.Force = $true
    }
    & "$Root\download.ps1" @downloadArgs
} finally {
    Pop-Location
}

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host @"

Ready. From $(if ($Dir -eq '.') { 'this directory' } else { $TargetDir }):
  .\compile.ps1
  .\test.ps1
  .\submit.ps1 $Url
"@ -ForegroundColor Cyan
