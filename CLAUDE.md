# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SillyTavern-Termux is a Bash-only project — a TUI menu system for deploying and managing [SillyTavern](https://github.com/SillyTavern/SillyTavern) on Android via Termux. There is no build system, package manager, or test runner. All files are shell scripts targeting `#!/data/data/com.termux/files/usr/bin/bash`.

## Entry Points

**Installation (first time):**
```bash
curl -O https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/start.sh && bash start.sh
```

**Daily use (after installation):**
```bash
bash ~/SillyTavern-Termux/start.sh
```

`Install.sh` is a backward-compat shim only — it redirects to `start.sh`.

## Architecture

### Dual-Mode `start.sh`

`start.sh` detects its own context by checking for `$SCRIPT_DIR/config/base.sh`:

- **Bootstrap mode** (file absent — user just downloaded it): runs a 3-step inline bootstrap (Termux check → git install → clone management repo to `~/SillyTavern-Termux`), then `exec`s the repo's own `start.sh`.
- **Normal mode** (file present — running from inside the cloned repo): sources `config/*.sh`, then `$USER_CONF`, then `lib/*.sh` in alphabetical glob order, detects whether SillyTavern is installed (via `$SILLYTAVERN_DIR/.git`), and calls `main_menu`.

### Configuration Layer (`config/base.sh`)

Single file holding all global state:
- ANSI color/style variables (`RED`, `GREEN`, `CYAN`, `BOLD`, `NC`, …)
- Version numbers (`INSTALL_VERSION`, `MENU_VERSION`) — used by `check_update` to compare against remote
- Default runtime value: `START_MODE=1`
- All remote URLs, social links, Discord download URL
- Path constants: `SILLYTAVERN_DIR`, `FONT_DIR`, `USER_CONF`, `ST_TERMUX_REPO`, …

### User Config (`$HOME/.sillytavern-termux.conf`)

The only mutable per-user file. Currently stores `START_MODE` (1 = standalone, 2 = launch with Gemini-CLI-Termux proxy). Created by `install_step6_env_file()` during first install. `start.sh` sources it after `config/` so it overrides the default `START_MODE=1`.

### Function Library (`lib/*.sh`)

All `lib/*.sh` files are sourced alphabetically at startup. Every file defines functions only — no top-level executable code — so load order does not matter. `$SCRIPT_DIR` is always available (set in `start.sh` before sourcing).

**File → function(s) mapping:**

| File | Exported function(s) |
|---|---|
| `ui.sh` | `get_version`, `press_any_key` |
| `network.sh` | network utility helpers |
| `storage.sh` | storage permission helpers |
| `main_menu.sh` | `main_menu` |
| `tavern_start.sh` | `start_tavern` |
| `tavern_update.sh` | `update_tavern` |
| `tavern_config.sh` | `tavern_config_menu` |
| `lan_config.sh` | `lan_config_menu` |
| `startup_assoc.sh` | `startup_association_menu` |
| `plugin_menu.sh` | `plugin_menu` |
| `plugin_install.sh` | `install_plugin_*` |
| `plugin_uninstall.sh` | `uninstall_plugin_*` |
| `maintenance_menu.sh` | `maintenance_menu` |
| `dependencies.sh` | `show_dependencies`, `fix_dependencies` |
| `backup_export.sh` | `export_tavern_data`, `export_tavern_full` |
| `backup_import.sh` | `import_tavern_data`, `import_tavern_full` |
| `version_tags.sh` | `version_tags_menu` |
| `version_switch.sh` | `version_switch_menu` |
| `script_manage_menu.sh` | `script_manage_menu` |
| `script_update.sh` | `check_update`, `show_update_log` |
| `uninstall.sh` | `uninstall_all` |
| `about.sh` | `about_script_menu` |
| `resources.sh` | `resource_links_menu`, `install_app_menu`, `install_discord_app` |
| `community.sh` | `community_links_menu`, `open_link_menu` |
| `installer.sh` | `install_sillytavern` (orchestrator) |
| `install_env_check.sh` | `install_step1_env_check` |
| `install_pkg_update.sh` | `install_step2_pkg_update` |
| `install_dependencies.sh` | `install_step3_dependencies` |
| `install_font.sh` | `install_step4_font` |
| `install_clone.sh` | `install_step5_clone` |
| `install_env_file.sh` | `install_step6_env_file` (initializes `$USER_CONF`) |
| `install_autostart.sh` | `install_step7_autostart` |
| `install_npm_deps.sh` | `install_step8_npm_deps` |

### Menu Hierarchy

```
main_menu
├── 1 start_tavern            (reads $START_MODE; mode 2 also launches Gemini-CLI-Termux)
├── 2 update_tavern
├── 3 tavern_config_menu
│   ├── 1 lan_config_menu
│   ├── 2 (inline memory limit edit on ~/SillyTavern/start.sh)
│   ├── 3 startup_association_menu   (reads/writes $USER_CONF for START_MODE)
│   ├── 4 (restore start.sh from start.sh.bak)
│   └── 5 (restore config.yaml from config.yaml.bak)
├── 4 plugin_menu
├── 5 maintenance_menu
│   ├── 1-2 show/fix dependencies
│   ├── 3-4 export data/full
│   ├── 5-6 import data/full
│   └── 7 version_switch_menu → version_tags_menu
├── 6 script_manage_menu
│   ├── 1 check_update        (git pull ~/SillyTavern-Termux, version via REMOTE_BASE_URL)
│   ├── 2 show_update_log
│   └── 3 uninstall_all
└── 7 about_script_menu
    └── 4 resource_links_menu → community_links_menu / install_app_menu
```

## Key Conventions

- **`$SCRIPT_DIR`**: Always the directory containing the running `start.sh` (i.e., `~/SillyTavern-Termux`). Use this for any path inside the management repo.
- **`$SILLYTAVERN_DIR`**: `~/SillyTavern` — the SillyTavern app itself (separate repo).
- **`$USER_CONF`**: `~/.sillytavern-termux.conf` — only writable user state. When modifying `START_MODE`, always also update the in-memory variable (e.g., `START_MODE=2`) so the menu reflects it immediately without re-sourcing.
- **Inline colors in bootstrap**: `start.sh`'s bootstrap section cannot source `config/base.sh`, so color variables must be defined inline there.
- **`check_update` version source**: fetches `$REMOTE_BASE_URL` (remote `config/base.sh`), compares `INSTALL_VERSION`/`MENU_VERSION`. Update is performed with `git -C "$SCRIPT_DIR" pull origin main`.
- **`Menu.sh`**: Legacy monolithic file still present in repo root for reference only. All active logic lives in `lib/`.
