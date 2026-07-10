param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Url,

    [string]$Source = "main.cpp",
    [switch]$SkipTest
)

. "$PSScriptRoot\scripts\_common.ps1"

if (-not $SkipTest) {
    Write-Host "Running local tests before submit..." -ForegroundColor Cyan
    & "$PSScriptRoot\test.ps1" -Source $Source
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Local tests failed. Fix your solution or use -SkipTest."
    }
}

if (-not (Test-Path $Source)) {
    Write-Error "Source file not found: $Source"
}

$submitPage = if ($Url -match '/tasks/([^/?#]+)$') {
    $task = $Matches[1]
    if ($Url -match '/contests/([^/]+)/') {
        $contest = $Matches[1]
        "https://atcoder.jp/contests/$contest/submit?taskScreenName=$task"
    } else {
        $Url
    }
} else {
    $Url
}

Get-Content $Source -Raw | Set-Clipboard
Write-Host "Copied $Source to clipboard." -ForegroundColor Green
Write-Host "Opening submit page in browser..." -ForegroundColor Cyan
Write-Host $submitPage -ForegroundColor DarkGray
Write-Host @"

In the browser:
  1. Complete the Cloudflare check (Turnstile) if shown
  2. Paste your code (Ctrl+V) into the editor
  3. Choose C++ (GCC), then click Submit

oj submit cannot bypass Turnstile — browser submit is required.
"@ -ForegroundColor Yellow

Start-Process $submitPage
