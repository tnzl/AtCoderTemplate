$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

Write-Host "=== AtCoder setup ===" -ForegroundColor Cyan

Write-Host "`n[1/3] Installing Python tools..." -ForegroundColor Cyan
& pip install -r (Join-Path $Root "requirements.txt")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "`n[2/4] Patching oj for AtCoder KiB/MiB limits..." -ForegroundColor Cyan
& (Join-Path $Root "scripts\patch_oj_atcoder.ps1")

Write-Host "`n[3/4] AC Library (optional)..." -ForegroundColor Cyan
$acl = Join-Path $Root "ac-library"
if (-not (Test-Path $acl)) {
    $answer = Read-Host "Clone AC Library now? (y/N)"
    if ($answer -match '^[yY]') {
        & (Join-Path $Root "setup-acl.ps1")
    }
} else {
    Write-Host "ac-library already present." -ForegroundColor Green
}

Write-Host "`n[4/4] atcoder-cli template (optional)..." -ForegroundColor Cyan
if (Get-Command acc -ErrorAction SilentlyContinue) {
    $accDir = & acc config-dir 2>$null
    if ($accDir) {
        $dest = Join-Path $accDir "msvc"
        if (-not (Test-Path $dest)) {
            Copy-Item -Recurse (Join-Path $Root ".acc-template\msvc") $dest
            & acc config default-template msvc
            Write-Host "Installed acc template 'msvc' and set as default." -ForegroundColor Green
        } else {
            Write-Host "acc template 'msvc' already exists at $dest" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "acc not installed. Optional: npm install -g atcoder-cli" -ForegroundColor Yellow
}

Write-Host @"

Setup complete.

Next (in Developer PowerShell for VS):
  cd $Root
  .\new.ps1 https://atcoder.jp/contests/abc300/tasks/abc300_a
  .\test.ps1
  .\submit.ps1 https://atcoder.jp/contests/abc300/tasks/abc300_a

First-time submit login:

```powershell
.\login.ps1
```
"@ -ForegroundColor Green
