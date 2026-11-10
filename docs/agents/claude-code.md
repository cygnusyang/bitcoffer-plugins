# Claude Code ← Bitcoffer

Same as the other hosts: point MCP config at the shared launch script [`scripts/bitcoffer-launch.sh`](../../scripts/bitcoffer-launch.sh), and use the rules in [rules.md](rules.md). Shared skills live at the repo root under [`skills/`](../../skills/).

## 1) MCP

`scripts/bitcoffer-launch.sh` resolves the App-signed binary and the local vault on connect (override with `BITCOFFER_VAULT_DIR` / `BITCOFFER_BIN`). Replace the path with the script location after you clone or copy this repo:

```bash
claude mcp add --scope user bitcoffer -- /path/to/bitcoffer/scripts/bitcoffer-launch.sh
```

Or a project-level `.mcp.json` (replace the path with a real value):

```json
{
  "mcpServers": {
    "bitcoffer": {
      "command": "/path/to/bitcoffer/scripts/bitcoffer-launch.sh"
    }
  }
}
```

You can also register the helper binary directly and pass the vault directory explicitly:

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"   # replace

claude mcp add --scope user bitcoffer \
  --env "BITCOFFER_VAULT_DIR=${VAULT}" \
  -- "$BIN" mcp --provider bitcoffer
```

## 2) Rules

Append [rules.md](rules.md) to `CLAUDE.md` at the project root.

## 3) Acceptance

```bash
claude mcp list
# expect: bitcoffer Connected; 4 tools
```

Or run the [universal probe](README.md).
