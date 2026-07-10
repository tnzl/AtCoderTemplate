# AtCoder (MSVC / cl)

Local compile + sample test workflow for [AtCoder](https://atcoder.jp/) using **Developer PowerShell** and `cl.exe`.

## Prerequisites

1. **Visual Studio** with C++ desktop development (MSVC)
2. **Developer PowerShell for VS** (so `cl` is on PATH)
3. **Python 3** (for sample download / test / submit tools)

## One-time setup

Open **Developer PowerShell for VS**, then:

```powershell
cd d:\projects\atCoder
.\setup.ps1
```

This installs `online-judge-tools` (`oj` command). Optionally clones [AC Library](https://github.com/atcoder/ac-library).

Optional — contest scaffolding with atcoder-cli:

```powershell
npm install -g atcoder-cli
.\setup.ps1   # registers the msvc acc template
acc login
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

# submit (runs tests first; browser required for Turnstile)
.\submit-browser.ps1 https://atcoder.jp/contests/abc300/tasks/abc300_a
# or try CLI (often blocked by Cloudflare Turnstile):
# .\submit.ps1 https://atcoder.jp/contests/abc300/tasks/abc300_a
```

First submit requires login (browser cookie — `oj login` password flow is broken):

```powershell
.\login.ps1
```

Log in at https://atcoder.jp/ in your browser, then F12 → Application → Cookies → atcoder.jp → copy `REVEL_SESSION` value.

```powershell
.\login.ps1
# Option 1: copy cookie in browser, press Enter (reads clipboard)
# Option 3: paste into Notepad if Ctrl+V fails in terminal
```

### Option B — acc contest folders

```powershell
acc new abc300
cd abc300\a
# samples are in test/
.\test.ps1
.\submit.ps1 https://atcoder.jp/contests/abc300/tasks/abc300_a
```

## Files

| Path | Purpose |
|------|---------|
| `template/main.cpp` | Starting solution |
| `include/bits/stdc++.h` | MSVC-compatible competitive programming headers |
| `compile.ps1` | Build with `cl` (+ ACL if `ac-library/` exists) |
| `test.ps1` | Compile and run `oj test` on `test/` |
| `download.ps1` | Download sample cases: `oj download <url>` |
| `submit-browser.ps1` | Test locally, copy code, open submit page in browser |
| `submit.ps1` | Try `oj submit` (often blocked by Turnstile; use `-Browser` or `submit-browser.ps1`) |
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

AtCoder's judge uses GCC, but local MSVC testing is fine for logic checks before submit.

## Troubleshooting

- **`cl` not found** — use Developer PowerShell for VS, not regular PowerShell. Scripts call `cl.exe` (PowerShell aliases `cl` to `Clear-Content`).
- **No test directory** — run `.\download.ps1 <problem-url>` first.
- **Submit fails with `× Error`** — AtCoder requires **Cloudflare Turnstile** on submit. Use `.\submit-browser.ps1 <url>` (paste code in browser). Virtual contests work in the browser, not via `oj`.
- **Login issues** — run `.\login.ps1` (browser cookie).
- **Submit `AssertionError` / `parsed_memory_limit`** — run `.\scripts\patch_oj_atcoder.ps1` (AtCoder changed MB→MiB; upstream oj not updated yet).
