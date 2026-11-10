# Bitcoffer agent skills

Host-agnostic distribution of [Bitcoffer](https://ai.cygnusyang.top/bitcoffer/) skills and MCP launch scripts that wire the local Bitcoffer secrets gateway into AI coding tools.

This repository contains **only** shared skills, host paste packs, and launcher/login scripts. It contains **no application source code**. Bitcoffer itself is proprietary software; download the app from https://ai.cygnusyang.top/bitcoffer/.

## Connect a host

Each host uses the paste packs in [`docs/agents/`](docs/agents/). Point the host's MCP `command` at this repo's [`scripts/bitcoffer-launch.sh`](scripts/bitcoffer-launch.sh) so the App-signed binary and local vault are resolved at connect time — no per-user paths or vault UUIDs after the app is installed and unlocked once.

Shared skills live in [`skills/`](skills/). The browser-login helper is [`scripts/bitcoffer-login`](scripts/bitcoffer-login).

### Prerequisites

1. **macOS** with the Bitcoffer app installed in `/Applications`.
2. Unlock the Bitcoffer app **once** on this machine so the Keychain escrow exists (Settings → MCP / Agent 协作 (*MCP / Agent collaboration*) → enable "MCP 解锁托管" (*MCP unlock escrow*)). This is per-machine; redo on every new Mac.
3. *(Only for browser logins via `bitcoffer-login`)* — `npm i -g playwright && npx playwright install chromium`.

### What's inside

| Path | Purpose |
|---|---|
| `skills/` | Host-agnostic skills: `bitcoffer-credentials` (use secrets) and `bitcoffer-setup` (diagnose/repair) |
| `scripts/bitcoffer-launch.sh` | MCP launcher — auto-detects the App-signed binary + vault, then `exec bitcoffer mcp` |
| `scripts/bitcoffer-login` | Browser-login driver (password via env from `run_with_secret`, never argv/stdout) |
| `docs/agents/` | Per-host paste packs and MCP config snippets |

## Security model

Secrets only ever reach a subprocess through its environment. No MCP tool returns a secret value — `list_secret_names` and `list_secrets` return names and metadata, and `run_with_secret` injects the value into the child process environment of a command you explicitly asked to run. Use Secret, not Read Secret: never `echo` or `printenv` a secret.

The four protocol tools are `list_secret_names`, `list_secrets`, `run_with_secret`, and `get_secret_metadata`. Hosts may add their own prefixes; call tools by the protocol name.

## Status

Early. Skill and script paths may change between releases; pin to a tag if you depend on a specific shape.

## License

Proprietary. See [LICENSE.md](LICENSE.md). The skills and scripts are provided for use with the Bitcoffer application; redistribution and derivative distribution are not permitted.
