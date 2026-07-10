param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Url,

    [string]$TestDir = "test"
)

if (-not (Get-Command oj -ErrorAction SilentlyContinue)) {
    Write-Error "oj not found. Run: pip install online-judge-tools"
}

& oj download $Url -d $TestDir
exit $LASTEXITCODE
