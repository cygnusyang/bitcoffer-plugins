# Claude Code ← Bitcoffer

**English** | [简体中文](claude-code.zh.md)

Goal: `claude mcp list` shows `bitcoffer` connected with **4** tools. Rules go in `CLAUDE.md`, shared skills live under [`skills/`](../../skills/).

## 1) MCP — launcher (preferred)

The launcher resolves the App-signed binary and the vault on every connect, so nothing machine-specific enters the config:

```bash
claude mcp add --scope user bitcoffer -- ~/.bitcoffer/bitcoffer-launch.sh
```

Use `--scope project` instead of `user` to commit this to `.mcp.json` for a repository. If you work from a clone rather than the README install step, point at `scripts/bitcoffer-launch.sh` in the clone.

Project-level `.mcp.json` equivalent:

```json
{
  "mcpServers": {
    "bitcoffer": {
      "command": "/Users/you/.bitcoffer/bitcoffer-launch.sh"
    }
  }
}
```

## 2) MCP — explicit binary and vault (fallback)

Register the helper directly and pass the vault yourself. Use this when auto-detection picks the wrong vault, or when you keep several vaults:

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"   # replace

claude mcp add --scope user bitcoffer \
  --env "BITCOFFER_VAULT_DIR=${VAULT}" \
  -- "$BIN" mcp --provider bitcoffer
```

App Store and TestFlight builds bundle no helper under `Contents/Helpers`; on those, install the standalone CLI and use `~/.bitcoffer/libexec/bitcoffer.app/Contents/MacOS/bitcoffer` instead.

## 3) Rules

Append [rules.md](rules.md) to `CLAUDE.md` at the project root. This is what stops Claude from trying to `echo` a secret "just to check".

## 4) Acceptance

```bash
claude mcp list
# expect: bitcoffer Connected; 4 tools
```

Or run the [universal probe](README.md#universal-smoke-test-toolslist--4), which needs no host at all.

## 5) Uninstall

```bash
claude mcp remove bitcoffer --scope user
```

Also remove the appended block from `CLAUDE.md`. The launcher script and the app are independent of this registration — leaving them is fine.

## 6) Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `bitcoffer` listed but no tools | launcher exited non-zero during connect | run `~/.bitcoffer/bitcoffer-launch.sh` in a terminal and read the path list it prints |
| Connected, `list_secret_names` returns `[]` | escrow not enabled, or the wrong vault | Settings → MCP / Agent collaboration → enable MCP unlock escrow; or set `BITCOFFER_VAULT_DIR` |
| Unlock error mentioning the keychain | a bare `bitcoffer` from `PATH` was used | remove the PATH binary from the config; use the launcher |
| Works in terminal, fails in Claude Code | GUI launch context lacks the keychain item | unlock the app once while logged into the desktop session, then reconnect |
