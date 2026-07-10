param(
    [string]$Source = "main.cpp",
    [string]$Output = "main.exe",
    [string]$TestDir = "test",
    [switch]$NoCompile
)

. "$PSScriptRoot\scripts\_common.ps1"

if (-not $NoCompile) {
    Invoke-AtCoderCompile -Source $Source -Output $Output
}

Invoke-AtCoderTest -Command ".\$Output" -TestDir $TestDir @args
