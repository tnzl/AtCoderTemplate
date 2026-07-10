param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Url,

    [string]$Source = "main.cpp",
    [switch]$SkipTest,
    [switch]$Browser
)

if ($Browser) {
    & "$PSScriptRoot\submit-browser.ps1" -Url $Url -Source $Source -SkipTest:$SkipTest
    exit $LASTEXITCODE
}

. "$PSScriptRoot\scripts\_common.ps1"

if (-not (Get-Command oj -ErrorAction SilentlyContinue)) {
    Write-Error "oj not found. Run: pip install -r requirements.txt"
}

if (-not $SkipTest) {
    Write-Host "Running local tests before submit..." -ForegroundColor Cyan
    & "$PSScriptRoot\test.ps1" -Source $Source
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Local tests failed. Fix your solution or use -SkipTest to submit anyway."
    }
}

Write-Host "Submitting $Source via oj ..." -ForegroundColor Cyan
& oj submit $Url $Source -y
if ($LASTEXITCODE -ne 0) {
    Write-Host @"

Submit failed. AtCoder now requires Cloudflare Turnstile on the submit page.
CLI tools (oj) cannot pass this check — use browser submit instead:

  .\submit-browser.ps1 $Url

Or:

  .\submit.ps1 $Url -Browser

Other causes if browser also fails:
  - Virtual contest not started yet / already over (check /contests/<id>/virtual)
  - Session expired — run .\login.ps1
  - oj MiB parse bug — run .\scripts\patch_oj_atcoder.ps1
"@ -ForegroundColor Yellow
    exit $LASTEXITCODE
}
exit 0
