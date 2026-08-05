# Browser Installation Scripts

Automated installer for popular web browsers on Debian-based systems, plus a Firefox hardening tool.

> **Note:** These scripts install browsers from their official sources rather than potentially outdated Debian repositories.

## Scripts

- **install_browsers.sh** — interactive installer for 7 alternative browsers
- **harden_firefox.sh** — applies a privacy-hardened profile to Firefox / Firefox ESR. Fetches Betterfox at a pinned tag and appends Butterbian additions inline.
- **policies.json** — enterprise policies deployed by the hardening script

> Firefox ESR is installed by Butterbian's WM-setup scripts, not by this menu. Use this script for *additional* browsers.

## Features

- **Smart Detection** - Checks if browsers are already installed
- **Repository Management** - Properly configures APT repositories and GPG keys
- **Conflict Resolution** - Handles Firefox/Firefox ESR conflicts intelligently
- **Clean Installation** - Removes old repository files before installing
- **ButterRepo Integration** - Helium and Zen Browser via JustAGuyLinux's ButterRepo
- **Error Handling** - Graceful failure handling with informative messages

## Requirements

- Debian-based operating system
- sudo privileges
- Internet connection
- Basic dependencies: `wget`, `curl`, `apt-transport-https`, `gnupg`

## Usage

```bash
cd butterscripts/browsers
./install_browsers.sh
```

The script presents a menu to:
- Select individual browsers by number
- Install multiple browsers (e.g., "1 3 5")
- Install all browsers with option 8

## Menu Options

| # | Option | Description |
|---|--------|-------------|
| 1 | **Helium Browser** | Modern Chromium-based browser via ButterRepo |
| 2 | **Firefox Latest** | Latest Firefox from Mozilla repository |
| 3 | **LibreWolf** | Privacy-focused Firefox fork |
| 4 | **Brave** | Privacy-focused browser with built-in ad blocking |
| 5 | **Floorp** | Customizable Firefox-based browser |
| 6 | **Zen Browser** | Minimalist Firefox-based browser via ButterRepo |
| 7 | **Chromium** | Open-source Chrome alternative |
| 8 | **All Browsers** | Install all browsers (1-7) |

## Installation Details

### Helium Browser
- Installs from ButterRepo (`apt.justaguy.dev`)
- Proper .deb package with automatic updates via APT

### Zen Browser
- Installs from ButterRepo (`apt.justaguy.dev`)
- Proper .deb package with automatic updates via APT

### Firefox Latest
- Adds Mozilla APT repository
- Configures package priorities
- Handles coexistence with Firefox ESR

### LibreWolf
- Uses extrepo for repository management
- Automatically enables official LibreWolf repository

### Brave
- Downloads official GPG key
- Adds Brave browser APT repository

### Floorp
- Adds Ablaze repository
- Installs latest Floorp release

### Chromium
- Installs from Debian repositories
- No additional repositories needed

## Security

- All GPG keys are verified before repository addition
- Uses signed repositories where available
- Follows best practices for APT repository management

## Troubleshooting

If installation fails:
1. Check internet connection
2. Verify sudo privileges
3. Update system: `sudo apt update && sudo apt upgrade`
4. Check available disk space

For browser-specific issues, the script provides detailed error messages.

---

## Firefox Hardening (`harden_firefox.sh`)

Applies a privacy-focused profile to an existing Firefox or Firefox ESR installation. Concept inspired by [tonarchy](https://github.com/tonybanters/tonarchy).

### Usage

```bash
cd butterscripts/browsers
./harden_firefox.sh
```

The script detects which Firefox variants are installed and offers a menu (Firefox, Firefox ESR, or Both).

### What It Does

- **Fetches Betterfox at a pinned tag** (`BETTERFOX_TAG` near the top of the script — bump there to update)
- **Appends Butterbian additions** to the fetched Betterfox: click-to-fill saved passwords, geoclue blocked, PDF page-width zoom, Firefox View tour dismissed
- **Caches the merged user.js** at `~/.local/share/butterscripts/firefox/user.js`
- **Creates a hardened profile** at `~/.mozilla/firefox/` (`default-release` or `default-esr`) and installs the cached user.js
- **Installs enterprise policies** (`policies.json`) to the system distribution directory:
  - `/usr/lib/firefox/distribution` (Firefox)
  - `/usr/lib/firefox-esr/distribution` (Firefox ESR)
- **Privacy-focused search engines**: `:sp` Startpage, `:sx` Searx, `:b` Brave, `:d` DuckDuckGo, `:gw`/`:gi`/`:gn`/`:gm` Google scopes
- **Auto-installs uBlock Origin** on first run
- **Replaces the system `.desktop` file** so launchers use the hardened profile
- **Installs a wrapper script** to `~/.local/bin/firefox` (or `firefox-esr`) that re-copies the cached user.js on every launch — covers CLI, sxhkd, WM keybinds, and rofi. Re-running `harden_firefox.sh` refreshes the cache from upstream.

### Requirements

- Firefox or Firefox ESR already installed (use `install_browsers.sh` first)
- `~/.local/bin` in your `PATH` (the script warns if not)
- sudo privileges (for `/usr/lib/` policies and system `.desktop` file)

### Files

| File | Purpose |
|------|---------|
| `harden_firefox.sh` | The hardening script. Fetches Betterfox + appends additions on each run. |
| `policies.json` | Enterprise policies (extensions, search engines, settings lockdown) |

The merged `user.js` is generated at runtime and cached at `~/.local/share/butterscripts/firefox/user.js`.

---

Part of the [ButterScripts](https://justaguy.dev/drew/butterscripts) collection by [JustAGuyLinux](https://www.youtube.com/@justaguylinux).
