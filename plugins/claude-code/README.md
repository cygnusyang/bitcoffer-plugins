# Bitcoffer for Claude Code

[Claude Code plugin](https://code.claude.com/docs/en/plugins/overview) that wires your local
[`bitcoffer`](https://github.com/cygnusyang/bitcoffer) secrets gateway into Claude — with **zero per-user
configuration** and the rule *use secrets, never read them*.

- **MCP server**: bitcoffer's stdio server (`list_secret_names` / `list_secrets` /
  `run_with_secret` / `get_secret_metadata`) is declared by the plugin and auto-started by Claude.
- **Zero-config discovery**: a launcher script resolves the App-signed bitcoffer binary and your vault
  directory at connect time — you don't fill in paths or vault UUIDs after installing.
- **Skills**: `bitcoffer-credentials` (how to use secrets via `run_with_secret` env injection, without
  leaking values into context) and `bitcoffer-setup` (diagnose/repair the connection).
- **Login helper**: `bitcoffer-login` on the Bash tool's PATH — a browser-login driver that reads the
  password from an env var injected by `run_with_secret`, so the password never enters Claude's
  context.

Secrets only ever reach a subprocess through its environment; no tool returns a secret value.

## Prerequisites

1. **macOS** with the **Bitcoffer app** installed in `/Applications` (the MCP server must run from the
   app-signed binary — a bare binary fails signature/Keychain checks).
2. Unlock the Bitcoffer app **once** on this machine so the Keychain escrow exists (Settings → MCP /
   Agent 协作 → 启用「MCP 解锁托管」). This is per-machine; redo on every new Mac.
3. *(Only for browser logins via `bitcoffer-login`)*: `npm i -g playwright && npx playwright install chromium`.

## Install

```bash
claude plugin marketplace add cygnusyang/bitcoffer-plugins
claude plugin install bitcoffer@bitcoffer
```

That's it. When enabled, `claude mcp list` shows `bitcoffer: … - ✔ Connected` and the `mcp__bitcoffer__*`
tools are available in every session.

Optional overrides (usually unnecessary — auto-detection handles it): set `BITCOFFER_VAULT_DIR` or
`BITCOFFER_BIN` in your environment to pin a specific vault or binary.

## What you get

| Piece | Purpose |
|---|---|
| `mcpServers.bitcoffer` | Stdio MCP server via `scripts/bitcoffer-launch.sh` (auto-detect binary + vault, then `exec bitcoffer mcp --provider bitcoffer`) |
| `skills/bitcoffer-credentials` | Patterns for `run_with_secret`, browser login, and when to ask the user |
| `skills/bitcoffer-setup` | First-run / repair checklist when the connection is missing or failing |
| `bin/bitcoffer-login` | Browser-login driver (password via env, persistent profile, `--smoke` mode) |
| `bin/bitcoffer-setup` | Fallback: register a standalone user-scope `bitcoffer` server (`claude mcp add`) |

## Security model (read this)

- **The plugin's MCP server process is started automatically by Claude Code, outside the sandbox,
  and is not permission-prompted** (this is how all Claude Code plugin MCP servers work). In this
  case the process is your own local bitcoffer daemon: it serves only read operations and `run_with_secret`
  only ever injects a secret into a command you/Claude explicitly asked to run. It never returns
  secret values over the protocol.
- Claude's **tool calls** to the bitcoffer MCP (`run_with_secret`, `list_*`) still pass through the
  normal permission rules.
- `bin/` commands run through Claude's Bash tool, so they are permission-prompted like any shell
  command.
- The login helper never writes the password to stdout/stderr/logs and never takes it as argv.

Review [Claude Code's plugin security docs](https://code.claude.com/docs/en/plugins/security.md)
before installing any plugin.

## Usage example

```text
# Find a secret
mcp__bitcoffer__list_secret_names {}

# Run a command with the secret injected as env (value never returned)
mcp__bitcoffer__run_with_secret {
  secret: "example-site",
  cmd: "node",
  args: ["bitcoffer-login", "--url", "https://example.com/login", "--email", "me@example.com", "--password-env", "PASSWORD"],
  env_name: "PASSWORD"
}
```

If a secret isn't in bitcoffer, ask the user where it is — never guess values.

## Development

```bash
git clone https://github.com/cygnusyang/bitcoffer-plugins
cd bitcoffer-plugins
claude plugin validate --strict plugins/claude-code   # authoritative gate before release
```

Layout (paths relative to `plugins/claude-code/`; the marketplace manifest lives at the
repo root, `.claude-plugin/marketplace.json`):

```
.claude-plugin/
  plugin.json        # manifest: mcpServers → scripts/bitcoffer-launch.sh
bin/                 # placed on the Bash tool PATH while enabled
  bitcoffer-login       # → scripts/bitcoffer-login.mjs
  bitcoffer-setup       # → scripts/bitcoffer-mcp-setup.sh
scripts/
  bitcoffer-launch.sh   # MCP launcher: resolve binary+vault, exec bitcoffer
  bitcoffer-mcp-setup.sh# standalone registration fallback
  bitcoffer-login.mjs   # env-injected browser login driver
skills/
  bitcoffer-credentials/SKILL.md
  bitcoffer-setup/SKILL.md
```

## License

Proprietary. See [LICENSE.md](../../LICENSE.md) at the repository root. The plugin is provided for
installation and use with the Bitcoffer application; redistribution and derivative distribution are
not permitted.
