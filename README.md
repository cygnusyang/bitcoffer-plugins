# Bitcoffer plugins

Distribution repository for [Bitcoffer](https://github.com/cygnusyang/bitcoffer-releases) plugins that wire the
local **bitcoffer** secrets gateway into AI coding tools.

This repository contains **only** plugin manifests, skills, and launcher scripts. It contains no
application source code. Bitcoffer itself is proprietary software; download the app from
[bitcoffer-releases](https://github.com/cygnusyang/bitcoffer-releases).

## Claude Code plugin

```bash
claude plugin marketplace add cygnusyang/bitcoffer-plugins
claude plugin install bitcoffer@bitcoffer
```

When enabled, `claude mcp list` shows `bitcoffer: … - ✔ Connected` and the `mcp__bitcoffer__*` tools
become available in every session.

Zero per-user configuration: the launcher resolves the App-signed bitcoffer binary and your vault
directory at connect time, so you never fill in paths or vault UUIDs after installing.

### Prerequisites

1. **macOS** with the Bitcoffer app installed in `/Applications`.
2. Unlock the Bitcoffer app **once** on this machine so the Keychain escrow exists
   (Settings → MCP / Agent 协作 → enable "MCP 解锁托管"). This is per-machine; redo on every new Mac.
3. *(Only for browser logins via `bitcoffer-login`)* — `npm i -g playwright && npx playwright install chromium`.

### What's inside

| Path | Purpose |
|---|---|
| `.claude-plugin/marketplace.json` | Marketplace manifest (points at `plugins/claude-code`) |
| `plugins/claude-code/.claude-plugin/plugin.json` | Plugin manifest: declares the stdio MCP server |
| `plugins/claude-code/scripts/bitcoffer-launch.sh` | MCP launcher — auto-detects binary + vault, then `exec bitcoffer mcp` |
| `plugins/claude-code/scripts/bitcoffer-login.mjs` | Browser-login driver (password via env, never argv/stdout) |
| `plugins/claude-code/scripts/bitcoffer-mcp-setup.sh` | Standalone registration fallback (`claude mcp add`) |
| `plugins/claude-code/skills/*/SKILL.md` | `bitcoffer-credentials` (how to use secrets) and `bitcoffer-setup` (diagnose/repair) |
| `plugins/claude-code/bin/` | Commands placed on the Bash tool PATH while the plugin is enabled |

## Security model

Secrets only ever reach a subprocess through its environment. No MCP tool returns a secret value —
`list_secret_names` and `list_secrets` return names and metadata, and `run_with_secret` injects the
value into the child process environment of a command you explicitly asked to run.

The plugin's MCP server process is started automatically by the host tool and is not
permission-prompted, which is how all plugin MCP servers behave. In this case that process is your
own local bitcoffer daemon, serving read operations plus `run_with_secret`. Tool calls still pass
through the host's normal permission rules, and `bin/` commands run through the Bash tool so they are
prompted like any shell command.

## Status

Early (plugin version 0.1.0). Manifests may change between releases; pin to a tag if you depend on a
specific shape.

## License

Proprietary. See [LICENSE.md](LICENSE.md). The plugin is provided for installation and use with the
Bitcoffer application; redistribution and derivative distribution are not permitted.
