# Cursor ← Bitcoffer

**English** | [简体中文](cursor.zh.md)

Drop path: `~/.cursor/mcp.json`. **Only add or update `mcpServers.bitcoffer`; do not overwrite the whole file.** Goal: Cursor Settings → MCP shows `bitcoffer` with **4** tools.

## 1) MCP — launcher (preferred)

Add the block by hand (safest — it never touches your other servers), then restart Cursor:

```json
{
  "mcpServers": {
    "bitcoffer": {
      "command": "/Users/you/.bitcoffer/bitcoffer-launch.sh"
    }
  }
}
```

If your file already has other servers, merge the `bitcoffer` key into the existing `mcpServers` object rather than replacing it.

Or let a script do the merge:

```bash
python3 - <<'PY'
import json, pathlib
p = pathlib.Path.home() / ".cursor" / "mcp.json"
p.parent.mkdir(parents=True, exist_ok=True)
data = json.loads(p.read_text()) if p.exists() else {}
data.setdefault("mcpServers", {})["bitcoffer"] = {
    "command": f"{pathlib.Path.home()}/.bitcoffer/bitcoffer-launch.sh"
}
p.write_text(json.dumps(data, indent=2) + "\n")
print("wrote", p)
PY
```

## 2) MCP — explicit binary and vault (fallback)

```json
{
  "mcpServers": {
    "bitcoffer": {
      "command": "/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer",
      "args": ["mcp", "--provider", "bitcoffer"],
      "env": { "BITCOFFER_VAULT_DIR": "/Users/you/.bitcoffer/vaults/<uuid>" }
    }
  }
}
```

## 3) Rules

Append [rules.md](rules.md) to `AGENTS.md` at the project root, or save it as `.cursor/rules/bitcoffer.mdc` for a Cursor-native rule.

## 4) Acceptance

Cursor Settings → MCP: `bitcoffer` is connected (4 tools); or run the [universal probe](README.md#universal-smoke-test-toolslist--4).

## 5) Uninstall

Delete the `bitcoffer` key from `mcpServers` in `~/.cursor/mcp.json` (or toggle it off in Settings → MCP), then restart Cursor. Remove `.cursor/rules/bitcoffer.mdc` if you created it.

## 6) Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `bitcoffer` red / failed in Settings | launcher not executable, or the path has `~` | `chmod +x` the launcher; use an absolute path |
| Other MCP servers disappeared | the file was overwritten instead of merged | restore from Cursor's backup or your git history; merge instead |
| Connected, 0 tools | launcher exited non-zero | run the launcher in a terminal and read the path list it prints |
| `list_secret_names` returns `[]` | wrong vault, or escrow not enabled | set `BITCOFFER_VAULT_DIR`, or enable MCP unlock escrow in the app |
