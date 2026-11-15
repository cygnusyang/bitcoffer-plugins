# Bitcoffer MCP server

A local-first, offline **secrets manager** for AI coding tools. Bitcoffer keeps your passwords, API keys and tokens in an encrypted vault on your Mac, and this repository packages the **MCP server** that wires that vault into Claude Code, Cursor, Codex, WorkBuddy, or any MCP host — without a secret ever leaving your machine.

> This repository contains **only** the MCP launcher, shared skills, and host paste packs. It contains **no application source code**. Bitcoffer itself is proprietary software; download the app from <https://ai.cygnusyang.top/bitcoffer/>.

## What it does

The server exposes **4 tools** over MCP:

| Tool | Purpose |
| --- | --- |
| `list_secret_names` | List the names of stored secrets (no values) |
| `list_secrets` | List secret names + metadata (no values) |
| `run_with_secret` | Run a command with one or more secret values injected into its environment |
| `get_secret_metadata` | Read a secret's metadata (no values) |

Values are **never returned** by any tool. A secret reaches a subprocess only through its environment, and only for a command you explicitly asked to run.

## Install

1. **Install the Bitcoffer app** (macOS):

   ```bash
   brew install --cask cygnusyang/bitcoffer/bitcoffer
   ```

   Or download the DMG from <https://ai.cygnusyang.top/bitcoffer/>. (Recent Homebrew versions may require `brew trust cygnusyang/bitcoffer` first.)

2. **Unlock the app once** on this Mac, and enable the escrow so the MCP server can unlock the vault without a password: **Settings → MCP / Agent collaboration → enable "MCP unlock escrow"**. This is per-machine; redo it on every new Mac.

3. **Point your host's MCP command at the launcher** (see Quickstart). The launcher auto-detects the App-signed binary and the local vault at connect time — no per-user paths or vault UUIDs needed.

## Quickstart

Fetch the launcher once:

```bash
curl -fsSL https://raw.githubusercontent.com/cygnusyang/bitcoffer-plugins/main/scripts/bitcoffer-launch.sh -o ~/.bitcoffer/bitcoffer-launch.sh
chmod +x ~/.bitcoffer/bitcoffer-launch.sh
```

Register with Claude Code:

```bash
claude mcp add --scope user bitcoffer -- ~/.bitcoffer/bitcoffer-launch.sh
```

Or add it to any MCP client's config (`command` = the launcher, `args` empty):

```json
{
  "mcpServers": {
    "bitcoffer": {
      "command": "/Users/you/.bitcoffer/bitcoffer-launch.sh"
    }
  }
}
```

Verify:

```bash
claude mcp list
# expect: bitcoffer Connected; 4 tools
```

Per-host paste packs (Claude Code, Cursor, Codex, WorkBuddy) and a universal `tools/list` probe live in [`docs/agents/`](docs/agents/).

## Security model

- **Local and offline.** The vault is an encrypted file on disk. There is no cloud account and no telemetry; secrets are never uploaded.
- **Values are never returned.** `list_secret_names`, `list_secrets` and `get_secret_metadata` return names and metadata only. `run_with_secret` injects the value into the child process environment of a command you explicitly asked to run — use Secret, not Read Secret: never `echo` or `printenv` a secret.
- **Transport is local.** The server speaks MCP over stdio; there is no TCP/UDP listener.
- **App-signed trust anchor.** The launcher runs the `bitcoffer` helper bundled inside the signed app, so the Keychain escrow resolves correctly. A bare `bitcoffer` binary on `PATH` may fail because of signing / Keychain context.

## What's inside

| Path | Purpose |
| --- | --- |
| `scripts/bitcoffer-launch.sh` | MCP server entry — auto-detects the App-signed binary + vault, then `exec bitcoffer mcp` |
| `scripts/bitcoffer-login` | Browser-login driver (password via env from `run_with_secret`, never argv/stdout) |
| `skills/` | Host-agnostic skills: `bitcoffer-credentials` (use secrets) and `bitcoffer-setup` (diagnose/repair) |
| `docs/agents/` | Per-host paste packs and MCP config snippets |

## Status

Early. Skill and script paths may change between releases; pin to a tag if you depend on a specific shape.

## License

Proprietary. See [LICENSE.md](LICENSE.md). The skills and scripts are provided for use with the Bitcoffer application; redistribution and derivative distribution are not permitted.
