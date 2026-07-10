$script:AtCoderRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$script:IncludeDir = Join-Path $AtCoderRoot "include"
$script:AclDir = Join-Path $AtCoderRoot "ac-library"
$script:DefaultSource = "main.cpp"
$script:DefaultOutput = "main.exe"
$script:DefaultTestDir = "test"

function Assert-ClAvailable {
    if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
        Write-Error @"
cl.exe not found. Open **Developer PowerShell for VS** (or x64 Native Tools Command Prompt), then run again.
"@
    }
}

function Invoke-AtCoderCompile {
    param(
        [string]$Source = $DefaultSource,
        [string]$Output = $DefaultOutput
    )

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
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    Remove-Item -ErrorAction SilentlyContinue "$([System.IO.Path]::GetFileNameWithoutExtension($Source)).obj"
    Write-Host "Built $Output" -ForegroundColor Green
}

function Invoke-AtCoderTest {
    param(
        [string]$Command = ".\$DefaultOutput",
        [string]$TestDir = $DefaultTestDir,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$OjArgs
    )

    if (-not (Get-Command oj -ErrorAction SilentlyContinue)) {
        Write-Error "oj not found. Run: pip install -r requirements.txt"
    }

    if (-not (Test-Path $TestDir)) {
        Write-Error "Test directory not found: $TestDir`nDownload samples first: .\download.ps1 <problem-url>"
    }

    & oj test -c $Command -d $TestDir @OjArgs
    exit $LASTEXITCODE
}
