$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
$CookieScript = Join-Path $Root "scripts\save_oj_cookie.py"
$PasteFile = Join-Path $Root ".session-paste.txt"

function Read-SessionFromClipboard {
    Add-Type -AssemblyName System.Windows.Forms
    $text = [System.Windows.Forms.Clipboard]::GetText()
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $null
    }
    return $text.Trim()
}

function Read-SessionFromPrompt {
    Write-Host ""
    Write-Host "Paste REVEL_SESSION here, then press Enter:" -ForegroundColor Yellow
    Write-Host "(Ctrl+V, or right-click to paste in this terminal)" -ForegroundColor DarkGray
    return (Read-Host).Trim()
}

function Read-SessionFromFile {
    if (-not (Test-Path $PasteFile)) {
        New-Item -ItemType File -Path $PasteFile -Force | Out-Null
    }
    Write-Host ""
    Write-Host "Opening $PasteFile in Notepad." -ForegroundColor Yellow
    Write-Host "1. Paste REVEL_SESSION into Notepad" -ForegroundColor Yellow
    Write-Host "2. Save (Ctrl+S) and close Notepad" -ForegroundColor Yellow
    Write-Host "3. Press Enter here to continue" -ForegroundColor Yellow
    Start-Process notepad.exe $PasteFile -Wait
    Read-Host "Press Enter after saving Notepad"
    if (-not (Test-Path $PasteFile)) {
        return $null
    }
    $text = (Get-Content $PasteFile -Raw).Trim()
    Remove-Item $PasteFile -Force -ErrorAction SilentlyContinue
    return $text
}

Write-Host @"
AtCoder login for oj
====================

1. Log in at https://atcoder.jp/ in your browser
2. F12 -> Application -> Cookies -> https://atcoder.jp
3. Copy the full Value of REVEL_SESSION

Then choose how to paste:
"@ -ForegroundColor Cyan

Write-Host "  [1] Clipboard (recommended) - copy in browser, press Enter here" -ForegroundColor White
Write-Host "  [2] Paste directly into this terminal" -ForegroundColor White
Write-Host "  [3] Paste into Notepad (if Ctrl+V does not work)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Choice (1/2/3, default 1)"
if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }

$session = switch ($choice) {
    "1" {
        Write-Host "Copy REVEL_SESSION in the browser, then press Enter..." -ForegroundColor Yellow
        [void](Read-Host)
        Read-SessionFromClipboard
    }
    "2" { Read-SessionFromPrompt }
    "3" { Read-SessionFromFile }
    default {
        Write-Error "Invalid choice: $choice"
    }
}

if ([string]::IsNullOrWhiteSpace($session)) {
    Write-Error "No REVEL_SESSION received. Copy the cookie from the browser and try again."
}

if ($session.Length -lt 20) {
    Write-Warning "That value looks too short. Make sure you copied the full REVEL_SESSION Value."
}

Write-Host "Saving cookie..." -ForegroundColor Cyan
& python $CookieScript $session
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Verifying oj login..." -ForegroundColor Cyan
& oj login https://atcoder.jp/ --check
if ($LASTEXITCODE -eq 0) {
    Write-Host "Login OK. You can use .\submit.ps1 now." -ForegroundColor Green
} else {
    Write-Host "Still not signed in. Get a fresh REVEL_SESSION while logged in and run .\login.ps1 again." -ForegroundColor Yellow
    exit 1
}
