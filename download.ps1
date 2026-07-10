param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Url,

    [string]$TestDir = "test",
    [switch]$Force
)

if (-not (Get-Command oj -ErrorAction SilentlyContinue)) {
    Write-Error "oj not found. Run: pip install -r requirements.txt"
}

if ($Force -and (Test-Path $TestDir)) {
    Write-Host "Removing existing $TestDir/ ..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $TestDir
}

Write-Host "Downloading sample cases to $TestDir/ ..." -ForegroundColor Cyan
& oj download $Url -d $TestDir

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "Done. Run .\test.ps1 to compile and test." -ForegroundColor Green
