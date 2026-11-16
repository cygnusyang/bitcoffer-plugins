# Codex ← Bitcoffer

**English** | [简体中文](codex.zh.md)

Drop path: `~/.codex/config.toml`. Goal: the session lists **4** bitcoffer tools. Rules go in `AGENTS.md`.

## 1) MCP — launcher (preferred)

```bash
mkdir -p ~/.codex
# If [mcp_servers.bitcoffer] already exists, delete that table first — TOML
# does not allow the same table twice, and a duplicate silently breaks the file.
cat >> ~/.codex/config.toml <<'EOF'

[mcp_servers.bitcoffer]
command = "/Users/you/.bitcoffer/bitcoffer-launch.sh"
args = []
EOF
```

Replace the path with your real home directory (TOML has no `~` expansion).

Restart Codex. The launcher resolves the binary and vault on each connect.

## 2) MCP — explicit binary and vault (fallback)

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"   # replace
mkdir -p ~/.codex
cat >> ~/.codex/config.toml <<EOF

[mcp_servers.bitcoffer]
command = "${BIN}"
args = ["mcp", "--provider", "bitcoffer"]

[mcp_servers.bitcoffer.env]
BITCOFFER_VAULT_DIR = "${VAULT}"
EOF
```

## 3) Rules

Append [rules.md](rules.md) to `AGENTS.md` at the project root.

## 4) Acceptance

The Codex session should show 4 bitcoffer tools; or run the [universal probe](README.md#universal-smoke-test-toolslist--4).

## 5) Uninstall

Delete the `[mcp_servers.bitcoffer]` table, its `[mcp_servers.bitcoffer.env]` sub-table if present, and the appended `AGENTS.md` block. Removing only one of the two TOML tables leaves an orphan `env` table and Codex will complain about the config.

## 6) Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| Codex refuses to start after the edit | duplicate `[mcp_servers.bitcoffer]` table, or a `~` in the path | keep one table only; write the absolute path |
| Server registered, no tools | launcher exited non-zero | run the launcher in a terminal and read the path list |
| `list_secret_names` returns `[]` | wrong vault, or escrow not enabled | set `BITCOFFER_VAULT_DIR`, or enable MCP unlock escrow in the app |
