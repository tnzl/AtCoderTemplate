param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Url,

    [string]$Source = "main.cpp",
    [switch]$SkipTest
)

if (-not $SkipTest) {
    & "$PSScriptRoot\test.ps1" -Source $Source
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Local tests failed. Use -SkipTest to submit anyway."
    }
}

if (-not (Get-Command oj -ErrorAction SilentlyContinue)) {
    Write-Error "oj not found. Run: pip install online-judge-tools"
}

& oj submit $Url $Source
exit $LASTEXITCODE
