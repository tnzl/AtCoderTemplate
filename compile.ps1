param(
    [string]$Source = "main.cpp",
    [string]$Output = "main.exe"
)

. "$PSScriptRoot\scripts\_common.ps1"
Invoke-AtCoderCompile -Source $Source -Output $Output
