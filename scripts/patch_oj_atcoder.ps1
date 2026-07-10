# Patch online-judge-api-client for AtCoder KiB/MiB memory limits (ABC408+).
# Re-run after: pip install -U online-judge-tools online-judge-api-client

$ErrorActionPreference = "Stop"

function Find-OjAtcoderPy {
    $candidates = @()
    foreach ($cmd in @("python", "python3")) {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) { continue }
        $path = & $cmd -c "import onlinejudge.service.atcoder as m; print(m.__file__)" 2>$null
        if ($path -and (Test-Path $path)) { return $path }
    }
    throw "Could not locate onlinejudge/service/atcoder.py. Is online-judge-tools installed?"
}

$target = Find-OjAtcoderPy
$content = Get-Content $target -Raw

$replacements = @(
    @{
        Old = @'
        if tds[3].text.endswith(' KB'):
            memory_limit_byte = int(float(utils.remove_suffix(tds[3].text, ' KB')) * 1000)
        elif tds[3].text.endswith(' MB'):
            memory_limit_byte = int(float(utils.remove_suffix(tds[3].text, ' MB')) * 1000 * 1000)  # TODO: confirm this is MB truly, not MiB
        else:
            assert False
'@
        New = @'
        if tds[3].text.endswith(' KB'):
            memory_limit_byte = int(float(utils.remove_suffix(tds[3].text, ' KB')) * 1000)
        elif tds[3].text.endswith(' KiB'):
            memory_limit_byte = int(float(utils.remove_suffix(tds[3].text, ' KiB')) * 1024)
        elif tds[3].text.endswith(' MB'):
            memory_limit_byte = int(float(utils.remove_suffix(tds[3].text, ' MB')) * 1000 * 1000)  # TODO: confirm this is MB truly, not MiB
        elif tds[3].text.endswith(' MiB'):
            memory_limit_byte = int(float(utils.remove_suffix(tds[3].text, ' MiB')) * 1024 * 1024)
        else:
            assert False
'@
    },
    @{
        Old = @'
        parsed_memory_limit = re.search(r'^(メモリ制限|Memory Limit): ([0-9.]+) (KB|MB)', memory_limit)
        assert parsed_memory_limit

        memory_limit_value = parsed_memory_limit.group(2)
        memory_limit_unit = parsed_memory_limit.group(3)
        if memory_limit_unit == 'KB':
            memory_limit_byte = int(float(memory_limit_value) * 1000)
        elif memory_limit_unit == 'MB':
            memory_limit_byte = int(float(memory_limit_value) * 1000 * 1000)
        else:
            assert False
'@
        New = @'
        parsed_memory_limit = re.search(r'^(メモリ制限|Memory Limit): ([0-9.]+) (KiB|MiB|KB|MB)', memory_limit)
        assert parsed_memory_limit

        memory_limit_value = parsed_memory_limit.group(2)
        memory_limit_unit = parsed_memory_limit.group(3)
        if memory_limit_unit == 'KB':
            memory_limit_byte = int(float(memory_limit_value) * 1000)
        elif memory_limit_unit == 'KiB':
            memory_limit_byte = int(float(memory_limit_value) * 1024)
        elif memory_limit_unit == 'MB':
            memory_limit_byte = int(float(memory_limit_value) * 1000 * 1000)
        elif memory_limit_unit == 'MiB':
            memory_limit_byte = int(float(memory_limit_value) * 1024 * 1024)
        else:
            assert False
'@
    }
)

$changed = $false
foreach ($r in $replacements) {
    if ($content.Contains($r.New)) {
        continue
    }
    if (-not $content.Contains($r.Old)) {
        Write-Warning "Expected block not found in $target (maybe already partially patched or version changed)."
        continue
    }
    $content = $content.Replace($r.Old, $r.New)
    $changed = $true
}

if (-not $changed) {
    Write-Host "Patch already applied: $target" -ForegroundColor Green
    exit 0
}

Set-Content -Path $target -Value $content -NoNewline -Encoding utf8
Write-Host "Patched: $target" -ForegroundColor Green
