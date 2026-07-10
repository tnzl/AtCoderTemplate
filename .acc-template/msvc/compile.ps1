function Get-AtCoderRoot {
    if ($env:ATCODER_ROOT) {
        return (Resolve-Path $env:ATCODER_ROOT).Path
    }

    $dir = $PSScriptRoot
    while ($dir) {
        if (Test-Path (Join-Path $dir "include\bits\stdc++.h")) {
            return (Resolve-Path $dir).Path
        }
        $parent = Split-Path $dir -Parent
        if ($parent -eq $dir) { break }
        $dir = $parent
    }

    Write-Error "Could not find atCoder root. Set `$env:ATCODER_ROOT to your atCoder folder."
}

function Assert-ClAvailable {
    if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
        Write-Error "cl.exe not found. Open Developer PowerShell for VS first."
    }
}

param(
    [string]$Source = "main.cpp",
    [string]$Output = "main.exe"
)

$Root = Get-AtCoderRoot
$IncludeDir = Join-Path $Root "include"
$AclDir = Join-Path $Root "ac-library"

Assert-ClAvailable

if (-not (Test-Path $Source)) {
    Write-Error "Source file not found: $Source"
}

$include = "/I`"$IncludeDir`""
if (Test-Path $AclDir) {
    $include += " /I`"$AclDir`""
}

$cmd = "cl.exe /nologo /O2 /EHsc /utf-8 /std:c++17 /MD /W3 $include `"$Source`" /Fe:`"$Output`""
Write-Host $cmd -ForegroundColor DarkGray

cmd /c $cmd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item -ErrorAction SilentlyContinue "$([System.IO.Path]::GetFileNameWithoutExtension($Source)).obj"
Write-Host "Built $Output" -ForegroundColor Green
