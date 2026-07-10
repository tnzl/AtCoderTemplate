param(
    [string]$Tag = "v1.5.1"
)

$Root = $PSScriptRoot
$AclDir = Join-Path $Root "ac-library"

if (Test-Path $AclDir) {
    Write-Host "ac-library already exists at $AclDir" -ForegroundColor Yellow
    exit 0
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git is required. Install Git, or download https://github.com/atcoder/ac-library and extract to ac-library/"
}

Write-Host "Cloning AC Library ($Tag) ..." -ForegroundColor Cyan
& git clone --depth 1 --branch $Tag https://github.com/atcoder/ac-library.git $AclDir

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "AC Library installed. Use #include <atcoder/all> in main.cpp" -ForegroundColor Green
