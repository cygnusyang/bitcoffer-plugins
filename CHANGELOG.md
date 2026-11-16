# Changelog

**English** | [简体中文](CHANGELOG.zh.md)

All notable changes to this repository are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [Semantic Versioning](https://semver.org/).

This repository versions the **launcher, skills and host configs**. It does not version the Bitcoffer application; an app release does not imply a change here, and vice versa.

## [Unreleased]

### Fixed

- `scripts/bitcoffer-login.mjs` — `--smoke` and `--no-submit` runs now report failure (`fields-missing` / `fill-incomplete`) when the required fields cannot be located or filled, instead of claiming success unconditionally.
- `scripts/bitcoffer-login.mjs` — a login with no success signal now reports `submitted-unconfirmed` instead of a misleading `timeout`; per-operation timeouts are split from the success-poll deadline (`--op-timeout-ms`, `--goto-timeout-ms`).
- `scripts/bitcoffer-login.mjs` — the page's error text is no longer copied into the receipt; `--flag=value` is accepted; `--help` exits 0; `--close` closes the browser after the run.
- `scripts/bitcoffer-launch.sh` — `$BITCOFFER_BIN` is checked for executability and fails loudly, and the `active-vault` pointer rejects path separators/traversal instead of trusting it as a bare name.
- `README.md` — `run_with_secret` injects a single secret value, matching the skill and schema.

### Changed

- `scripts/bitcoffer-login` is now a small `sh` shim that forwards argv to `bitcoffer-login.mjs`; the `.mjs` file is the single source that is syntax-checked.

### Added

- `tests/` — behavioural tests for the launcher's resolution order and fail-closed behaviour, plus unit tests for the login helper's argument parsing and field/password helpers.
- `tests/install.test.sh` + `.github/workflows/install-check.yml` — end-to-end cask install/uninstall check in a throwaway `macos-14` runner. It refuses to run where an install already exists, then asserts the app, zap paths and Caskroom are removed while `~/.bitcoffer/vaults` is preserved.

## [0.1.0] — 2026-11-16

First tagged release. Pre-1.0: paths and skill wording may change between minor versions.

### Added

- `scripts/bitcoffer-launch.sh` — zero-config MCP entry point. Resolves the App-signed binary (`$BITCOFFER_BIN` → bundled app helper → standalone CLI → `PATH`) and the vault (`$BITCOFFER_VAULT_DIR` → `active-vault` pointer → newest vault) at connect time, then `exec bitcoffer mcp`. Fails loudly with every path it checked, and explains the Store-build case where no helper is bundled.
- `scripts/bitcoffer-login` + `scripts/bitcoffer-login.mjs` — browser login driver. The password arrives through the environment (from `run_with_secret`), never through argv or stdout; prints a JSON receipt only.
- `skills/bitcoffer-credentials` — how to use a secret without reading it: look up the name, inject into a subprocess environment, never `echo`/`printenv`.
- `skills/bitcoffer-setup` — ordered diagnosis for a missing or broken connection: app installed, vault exists, Keychain escrow established, launcher overrides.
- `docs/agents/` — paste packs for Claude Code, Cursor, Codex and WorkBuddy, a shared rules snippet, and a universal `tools/list` probe that expects exactly 4 tools.
- Bilingual documentation: every document ships an English original and a full Simplified Chinese counterpart (`*.zh.md`), cross-linked at the top.
- `SECURITY.md` with the four design invariants, a stated threat model and a private reporting channel.
- `CONTRIBUTING.md`, `CHANGELOG.md`, `.gitignore`, issue and pull request templates.

### Changed

- **Relicensed from proprietary to [MIT](LICENSE).** Use, modification, redistribution and resale are permitted provided the copyright notice and licence text are kept. The licence covers this repository only; the application stays proprietary.
- Repository is described and tagged as an MCP server, not as an app mirror.

[Unreleased]: https://github.com/cygnusyang/bitcoffer-plugins/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/cygnusyang/bitcoffer-plugins/releases/tag/v0.1.0
