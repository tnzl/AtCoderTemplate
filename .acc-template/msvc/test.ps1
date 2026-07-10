param(
    [string]$Source = "main.cpp",
    [string]$Output = "main.exe",
    [string]$TestDir = "test",
    [switch]$NoCompile
)

if (-not $NoCompile) {
    & "$PSScriptRoot\compile.ps1" -Source $Source -Output $Output
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

if (-not (Get-Command oj -ErrorAction SilentlyContinue)) {
    Write-Error "oj not found. Run: pip install online-judge-tools"
}

if (-not (Test-Path $TestDir)) {
    Write-Error "Test directory not found: $TestDir"
}

& oj test -c ".\$Output" -d $TestDir @args
exit $LASTEXITCODE
