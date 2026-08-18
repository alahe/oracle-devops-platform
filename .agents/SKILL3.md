---
name: windows-enterprise-constraints
description: Windows host + corporate-network/endpoint-security constraints encountered while developing this repo from WSL2 (VPN split-tunneling, PowerShell Constrained Language Mode, NTLM/Kerberos proxy auth, internal CA trust) and how each was solved or worked around. Use before debugging network/proxy/cert/PowerShell failures on a Windows+WSL2 dev machine, or before adding a script that shells out to Windows tooling.
---

# Windows host + enterprise-network constraints

This repo is developed on Windows machines that sit behind corporate VPN/proxy/endpoint-security
software, with most script execution actually happening inside WSL2. That combination causes a
recurring class of failures that have nothing to do with this repo's own logic. Read the relevant
section before spending time debugging one of these symptoms again.

## 1. Corporate VPN does not extend into WSL2's network

**Symptom:** DNS resolves internal hostnames fine inside WSL2, but TCP connects to those IPs (even
the corporate proxy IP itself) time out — while the exact same URL works instantly in the Windows
host's own browser.

**Root cause:** WSL2's own virtual network does not inherit the Windows host's VPN split-tunnel
routes by default. Enabling WSL2 "mirrored" networking mode (`networkingMode=mirrored` in
`%USERPROFILE%\.wslconfig`, requires `wsl --shutdown` to apply) fixes this for *some* VPN clients by
sharing the host's routes directly.

**Confirmed dead end for NDIS-filter-driver-style VPN clients** (Check Point Endpoint, and
similarly Cisco AnyConnect/Zscaler): even with mirrored networking **and** the VPN adapter's own DNS
server manually configured in `/etc/resolv.conf`, and even connecting to a raw IP via
`curl --resolve` (bypassing DNS entirely), the direct TCP connect from WSL2 still times out. The
VPN client's NDIS filter driver simply does not forward traffic for WSL2's virtual adapter, in
either NAT or mirrored mode — there is no WSL-side config fix. If you hit this, stop tweaking
`.wslconfig`/`resolv.conf`/proxy env vars; instead do the network-dependent step from the Windows
side (PowerShell/browser) and hand the result to WSL2, from the office network, or ask IT for a
WSL-compatible VPN mode.

**How this repo works around it:** `scripts/adb/start.sh`'s ADB Free seed-PDB download pre-fetches
the file via `powershell.exe` from inside the WSL2 script when running under WSL (see
`command -v powershell.exe` check around line 109) — Windows-native HTTP clients transparently use
the Windows system/PAC proxy and VPN routing that WSL2 itself cannot reach.

## 2. NTLM/Kerberos-authenticating corporate proxy

**Symptom:** `Invoke-WebRequest -UseDefaultCredentials` still returns `407 Proxy Authentication
Required` even though the same request works in a browser.

**Root cause:** `-UseDefaultCredentials` only authenticates to the *target server*, not to the
proxy in front of it. You must also pass `-Proxy '<url>' -ProxyUseDefaultCredentials` to
authenticate to the proxy itself.

**Also confirmed:** PowerShell Constrained Language Mode (see §3) blocks dynamic proxy discovery
via `.NET` methods (e.g. `[System.Net.WebRequest]::GetSystemWebProxy()`), so the proxy URL can't be
auto-detected in that mode — it must be supplied explicitly.

**How this repo handles it:** `scripts/adb/start.sh`'s `fetch_via_windows_powershell` (around line
180) always tries a direct, no-proxy request first, then falls back to trying each proxy listed in
`COMPANY_PROXY_HOSTS` (`./company-registry.conf`, copy from `company-registry.conf.example`) with
`-Proxy $p -ProxyUseDefaultCredentials`. If your network needs an explicit proxy, set
`COMPANY_PROXY_HOSTS="proxy1.example.com:3128,proxy2.example.com:3128"` there rather than patching
the script.

## 3. PowerShell Constrained Language Mode

Many corporate-managed Windows machines run PowerShell in Constrained Language Mode (via
AppLocker/WDAC policy), which blocks a lot of "normal" scripting:

- `New-Object` for arbitrary .NET types (e.g. generic lists, `pscustomobject`, and specifically
  `System.Security.Cryptography.X509Certificates.X509Store`/`X509Certificate2`) fails with
  "Cannot create type. Only core types are supported." Avoid relying on these when writing
  PowerShell for this repo's Windows-side helpers — prefer plain text output and core cmdlets.
- Dynamic proxy discovery via `.NET` methods is blocked (see §2).
- `[Console]::OutputEncoding = ...` property sets fail with
  `PropertySetterNotSupportedInConstrainedLanguage` — seen harmlessly during `wsl --install`'s own
  internal setup; the install still completes fine despite the printed errors.
- Variable names are case-insensitive, so a locally-parsed flag name that differs from a parameter
  name only by case (e.g. `DiffAutoOpenEnabled` vs a param `diffAutoOpenEnabled`) silently collides —
  use visually distinct names.
- Interpolated strings where a variable is immediately followed by `:` (e.g. `"-${Name}: ..."`) need
  the `${...}` form, not bare `$Name:`, or PowerShell's parser throws
  `InvalidVariableReferenceWithDrive`.

There is no way to escalate out of Constrained Language Mode from within a script — don't try to
work around it with cleverer .NET calls; redesign to use only core cmdlets/types, or move the step
to a plain batch/cmd invocation, or ask the user to run it themselves in an unrestricted shell.

## 4. Trusting a local/internal self-signed certificate on Windows

Needed for this repo's own local HTTPS (ORDS' self-signed cert, see `scripts/create-self-signed-certificates.sh`)
and for a company-internal registry/artifact CA (`scripts/install-registry-ca.sh`,
`COMPANY_REGISTRY_HOST` in `company-registry.conf.example`).

- `Import-Certificate -CertStoreLocation Cert:\CurrentUser\Root -NonInteractive` fails with "UI is
  not allowed in this operation" — Windows requires an interactive confirmation dialog to trust a
  new *root* CA; this cannot be scripted headlessly, Constrained Language Mode or not.
- `certutil -addstore Root <file>` fails with "Cannot add a non-root certificate to the root store"
  if the certificate lacks `CA:true` in its basic constraints (true for a plain leaf/server cert,
  e.g. this repo's generated `ssl/cert.crt`).
- **Working non-interactive fallback:** `certutil -user -addstore TrustedPeople <file>` — adds the
  cert as an explicitly-trusted end-entity certificate (Windows' standard mechanism for trusting a
  specific self-signed dev cert without making it a full root CA). Note this trusts *that one
  certificate*, not a CA that can issue others.
- A VS Code-integrated/Playwright-driven browser tool may still show `ERR_CERT_AUTHORITY_INVALID`
  even after a successful `TrustedPeople` install, because it runs a separate browser
  profile/process from the user's real installed browser. If automated browser cert trust seems
  blocked, verify manually in the user's actual Edge/Chrome instead of continuing to fight the
  automation.
- Podman Desktop's own WSL2 VM (`podman-machine-default`, distinct from a general-purpose Ubuntu
  distro — check with `wsl -l -v`) needs the registry CA installed *inside that specific machine*
  for image pulls from an internal registry to work — see `scripts/install-registry-ca.sh`'s
  `podman.exe machine ssh` based install path.

## 5. Never hardcode internal infrastructure details

This repo is structured so that real internal hostnames, registry URLs, proxy hosts, and
credentials never need to be committed:

- `company-registry.conf` / `company-registry.conf.example` — internal image registry + optional
  proxy list, read by `setup.sh`, `scripts/switch-image-source.sh`, `scripts/adb/start.sh`,
  `scripts/install-registry-ca.sh`.
- `docs/src/content/docs/getting-started/enterprise-mirror-template.md` — a template a company can
  fork/fill in privately, kept generic in this repo.
- `.env`/`lis-app.conf`/`post-install.conf` follow the same `*.conf.example` → local, gitignored
  copy pattern.

When adding a new script that needs a company-specific value, add it to one of these `.conf.example`
files with a placeholder rather than inlining a real value anywhere, even temporarily.

## 6. WSL2 interop with Windows .exe can break mid-session

Invoking any Windows `.exe` (git.exe, powershell.exe, podman.exe) from a WSL shell can start failing
with `WSL ... ERROR: UtilGetPpid: Failed to parse: /proc/<pid>/stat` partway through a session —
seen both after a nested "genie" systemd namespace was auto-entered on a fresh shell, and
independently after other WSL state got corrupted. There is no in-session fix; open a fresh WSL
terminal (or `wsl --shutdown` + reopen). If a distro's banner mentions entering a nested process
namespace, run `exit` once first to drop back to the parent shell before calling any Windows `.exe`.
