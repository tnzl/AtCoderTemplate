# AtCoder (MSVC / cl)

Local compile + sample test workflow for [AtCoder](https://atcoder.jp/) using **Developer PowerShell** and `cl.exe`. Submit solutions manually on the AtCoder website.

## Prerequisites

1. **Visual Studio** with C++ desktop development (MSVC)
2. **Developer PowerShell for VS** (so `cl.exe` is on PATH)
3. **Python 3** (for sample download and local testing via `online-judge-tools`)

## One-time setup

Open **Developer PowerShell for VS**, then:

```powershell
cd d:\projects\atCoder
.\setup.ps1
```

This installs `online-judge-tools` (`oj` command) and optionally clones [AC Library](https://github.com/atcoder/ac-library).

Optional — contest scaffolding with atcoder-cli:

```powershell
npm install -g atcoder-cli
.\setup.ps1   # registers the msvc acc template
```

Set this once so acc task folders find includes/ACL:

```powershell
[Environment]::SetEnvironmentVariable("ATCODER_ROOT", "d:\projects\atCoder", "User")
```

## Daily workflow

### Option A — work in this folder (single problem)

```powershell
cd d:\projects\atCoder

# create main.cpp + download samples
.\new.ps1 https://atcoder.jp/contests/abc300/tasks/abc300_a

# edit main.cpp, then:
.\compile.ps1          # cl -> main.exe
.\test.ps1             # compile + run test/*.in against test/*.out

# or manually:
cl /nologo /O2 /EHsc /utf-8 /std:c++17 /MD /I"d:\projects\atCoder\include" main.cpp /Fe:main.exe
oj test -c ".\main.exe"
```

When samples pass, copy `main.cpp` and paste it on the AtCoder submit page in your browser.

### Option B — acc contest folders

```powershell
acc new abc300
cd abc300\a
# samples are in test/
.\test.ps1
```

## Files

| Path | Purpose |
|------|---------|
| `template/main.cpp` | Starting solution |
| `include/bits/stdc++.h` | MSVC-compatible competitive programming headers |
| `compile.ps1` | Build with `cl.exe` (+ ACL if `ac-library/` exists) |
| `test.ps1` | Compile and run `oj test` on `test/` |
| `download.ps1` | Download sample cases: `oj download <url>` |
| `new.ps1` | Scaffold `main.cpp` + download samples |
| `setup-acl.ps1` | Clone AC Library into `ac-library/` |

## AC Library

```powershell
.\setup-acl.ps1
```

Then in `main.cpp`:

```cpp
#include <atcoder/all>
using namespace atcoder;
```

## Compiler flags used

```
/nologo /O2 /EHsc /utf-8 /std:c++17 /MD /W3
/I include/   (+ /I ac-library/ when present)
```

AtCoder's judge uses GCC. Keep `using namespace std;` in your source — AtCoder's `bits/stdc++.h` does not include it.

## Troubleshooting

- **`cl` not found** — use Developer PowerShell for VS, not regular PowerShell. Scripts call `cl.exe` (PowerShell aliases `cl` to `Clear-Content`).
- **No test directory** — run `.\download.ps1 <problem-url>` first.
- **`oj download` parse error** — run `.\scripts\patch_oj_atcoder.ps1` (AtCoder changed MB→MiB; upstream oj not updated yet).
