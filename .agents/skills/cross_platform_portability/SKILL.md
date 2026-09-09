---
name: cross_platform_portability
description: Guidelines for cross-platform file, directory, and script portability across Windows (NTFS/FAT), macOS (APFS), and Linux (ext4/btrfs).
---

# Cross-Platform Portability & Filesystem Standards Engine

This skill guides engineering and automation practices to guarantee flawless Git clones, checkouts, container mounts, and test execution across all major operating systems: **Windows** (NTFS, FAT32/exFAT, WSL2), **macOS** (APFS), and **Linux** (ext4, btrfs, tmpfs).

---

## 1. 🎯 When to Use & Negative Routing

### Positive Triggers (Activate Immediately):
- Creating new files, directories, scripts, or documentation paths in the repository
- Resolving Git clone/checkout errors on Windows (`Invalid argument`, `checkout-index collision`)
- Running or debugging `./tests/unit/test-filename-portability.sh` (Rule 13)
- Enforcing LF line endings (`.gitattributes`) and casing discipline

### Negative Routing (Redirect to Specialized Skills):
| If the task is primarily about... | DO NOT handle here. Route immediately to: |
|:---|:---|
| Windows corporate proxy, WSL2 mirrored network, or WDAC policies | `windows_enterprise_devops` |
| Authoring unit tests or running full CI suites | `testing_and_ci_framework` |
| Bash/Zsh compatibility and SQLcl binary resolution | `vscode_sql_developer` |
| Repository directory tree overview | `repo_codebase_navigator` |

---

## 2. Operating System Filesystem Compatibility Matrix

| Restriction Area | Windows (NTFS / FAT) | macOS (APFS) | Linux (ext4 / btrfs) | Platform Standard |
| :--- | :--- | :--- | :--- | :--- |
| **Forbidden Characters** | `< > : " / \ \| ? *` | `/` and `:` (colon translates to `/` in HFS+) | `/` and `\0` (NUL byte) | **Strictly prohibited:** `< > : " / \ \| ? *` |
| **Trailing Dots / Spaces** | Automatically stripped or causes checkout failure | Permitted but discouraged | Permitted | **Strictly forbidden:** No trailing `.` or space |
| **Reserved Device Names** | `CON`, `PRN`, `AUX`, `NUL`, `COM1-9`, `LPT1-9` (even with ext) | None | None | **Strictly forbidden:** Never use reserved DOS device names |
| **Case Sensitivity** | Case-insensitive, case-preserving | Default case-insensitive, case-preserving | Default case-sensitive | **Strictly lowercase kebab-case;** zero case collisions |
| **Max Path Length** | 260 chars (`MAX_PATH`) without long paths flag | 1,024 chars | 4,096 chars | **Keep relative paths $< 180$ characters** |
| **Line Endings** | CRLF (`\r\n`) default | LF (`\n`) | LF (`\n`) | **Enforce LF (`\n`) via `.gitattributes`** |

---

## 2. Windows NTFS / FAT Specific Hazards

### A. Illegal Characters (`< > : " / \ | ? *`)
Windows NTFS and FAT filesystems prohibit the following 9 characters in file and directory names:
- `<` (less than)
- `>` (greater than)
- `:` (colon) — frequently causes clone failures when files are named like `task: summary.txt` or `build:log.txt`
- `"` (double quote)
- `/` (forward slash)
- `\` (backslash)
- `|` (vertical bar / pipe)
- `?` (question mark)
- `*` (asterisk)

> [!CAUTION]
> If any file or folder containing these characters is pushed to a Git repository, **`git clone` or `git checkout` on Windows will abort with fatal errors** (e.g. `fatal: cannot create directory at ...: Invalid argument`).

### B. Trailing Spaces and Dots
Windows Win32 APIs automatically strip trailing dots and trailing whitespace from paths during normalization. If Git attempts to write `my-file. ` or `folder./file`, the underlying Win32 subsystem rejects the call or writes to a mangled name, causing silent corruption or clone failure.

### C. Reserved Device Names (Case-Insensitive)
The following 22 names were reserved in MS-DOS and remain hardcoded in Windows Win32 subsystems:
- `CON`, `PRN`, `AUX`, `NUL`
- `COM1`, `COM2`, `COM3`, `COM4`, `COM5`, `COM6`, `COM7`, `COM8`, `COM9`
- `LPT1`, `LPT2`, `LPT3`, `LPT4`, `LPT5`, `LPT6`, `LPT7`, `LPT8`, `LPT9`

These names are reserved **regardless of extension**. For example, `aux.h`, `nul.json`, `con.txt`, `prn.log`, or `COM1.sh` are **illegal** on Windows.

---

## 3. Case-Sensitivity & Collision Prevention

1. **Case-Preserving vs. Case-Sensitive:**
   - On Linux, `config.yaml` and `Config.yaml` are two completely different files.
   - On Windows and macOS (default APFS), creating both files in the same directory results in the second file overwriting the first or an ambiguous Git checkout collision (`checkout-index: unable to check out file`).
2. **Standard Rule:**
   - All repository filenames, paths, and extensions must use pure **lowercase kebab-case** (`a-z0-9-._`).
   - Never introduce case variations of the same name in any directory.

---

## 4. Repository Naming Convention

All filenames, scripts, configurations, and directory names in this platform must strictly satisfy:

```text
Regex: ^[a-z0-9_.-]+$
```

- Allowed characters: lowercase letters (`a-z`), digits (`0-9`), period (`.`), hyphen (`-`), and underscore (`_`).
- Prohibited characters: spaces, tabs, uppercase letters in daily assets, accented letters/umlauts (`ä`, `ö`, `õ`, `ü`, `š`, `ž`), and punctuation symbols.
- Exception: Standard documentation root conventions (`README.md`, `LICENSE`, `CHANGELOG.md`) are permitted uppercase letters.

---

## 5. Git Configuration Best Practices for Cross-Platform Teams

### Recommended Global Git Config on Windows:
```bash
# Prevent checking out or committing paths illegal on NTFS
git config --global core.protectNTFS true

# Allow paths longer than legacy MAX_PATH (260 characters)
git config --global core.longpaths true

# Ensure consistent LF line endings
git config --global core.autocrlf input
```

### Git Repository Protection (`.gitattributes`):
Ensure `.gitattributes` enforces standard checkout behaviors:
```gitattributes
* text=auto eol=lf
*.bat text eol=crlf
*.cmd text eol=crlf
*.ps1 text eol=crlf
*.sh text eol=lf
*.sql text eol=lf
*.yaml text eol=lf
*.yml text eol=lf
*.json text eol=lf
*.md text eol=lf
```

---

## 6. Automated Validation in CI

The test suite includes an automated filename portability linter:
- Script: `tests/unit/test-filename-portability.sh`
- Checks:
  1. Inspects all Git-tracked files via `git ls-files -z` (zero-delimited for exact path safety).
  2. Detects Windows forbidden characters (`< > : " \ | ? *`).
  3. Detects trailing spaces or trailing periods.
  4. Detects Windows DOS reserved device names (`CON`, `PRN`, `AUX`, `NUL`, `COM1-9`, `LPT1-9`).
  5. Flags unescaped whitespace and non-ASCII diacritics in pathnames.
  6. Enforces relative path lengths $< 180$ characters.

---

## 7. 🩺 Diagnostic Signatures & 1-Line Remedies

| Symptom / Error | Root Cause | 1-Line Remedy |
|:---|:---|:---|
| `fatal: cannot create directory ... Invalid argument` | Path contains Windows-forbidden char (`:`, `*`, `?`, `<`) | Rename file to standard kebab-case ASCII: `tr '[:upper:]' '[:lower:]'`. |
| `warning: LF will be replaced by CRLF` | Git `core.autocrlf` converting line endings on Windows | Run `git config --global core.autocrlf input` and verify `.gitattributes`. |
| `error: unable to create file ... Filename too long` | Path exceeds Windows legacy 260-char `MAX_PATH` | Run `git config --global core.longpaths true` or shorten directory path. |
| `checkout-index: unable to check out file` | Two files in the same dir differ only by letter casing | Rename one of the colliding files to a distinct name (e.g. `Setup.sh` vs `setup.sh`). |
| Script execution fails with `^M: bad interpreter` | Shell script has Windows CRLF (`\r\n`) line endings | Convert to Unix LF with `dos2unix <script.sh>` or `sed -i '' 's/\r$//' <script.sh>`. |
