# Codex ← Bitcoffer

## 1) MCP → `~/.codex/config.toml`

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"   # replace
mkdir -p ~/.codex
# If [mcp_servers.bitcoffer] already exists, delete the old table first, then append
cat >> ~/.codex/config.toml <<EOF

[mcp_servers.bitcoffer]
command = "${BIN}"
args = ["mcp", "--provider", "bitcoffer"]

[mcp_servers.bitcoffer.env]
BITCOFFER_VAULT_DIR = "${VAULT}"
EOF
```

Restart Codex.

## 2) Rules

Append [rules.md](rules.md) to `AGENTS.md` at the project root.

## 3) Acceptance

The Codex session should show 4 bitcoffer tools; or run the [universal probe](README.md).
