# WorkBuddy ← Bitcoffer

**English** | [简体中文](workbuddy.zh.md)

Drop path: `~/.workbuddy/mcp.json`. **Only add or update `mcpServers.bitcoffer`; do not overwrite the whole file.** Goal: after a restart, `bitcoffer` appears with **4** tools.

WorkBuddy requires an explicit trust step for a new MCP server — the config alone is not enough.

## 1) MCP — launcher (preferred)

```bash
python3 - <<'PY'
import json, pathlib
p = pathlib.Path.home() / ".workbuddy" / "mcp.json"
p.parent.mkdir(parents=True, exist_ok=True)
data = json.loads(p.read_text()) if p.exists() else {}
data.setdefault("mcpServers", {})["bitcoffer"] = {
    "command": f"{pathlib.Path.home()}/.bitcoffer/bitcoffer-launch.sh",
}
p.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
print("wrote", p)
PY
```

Then restart WorkBuddy and **click "Trust" on the new server** in the connector management page (top-right entry for custom connectors). Until you trust it, the server stays registered but never starts.

## 2) MCP — explicit binary and vault (fallback)

Same merge, with the binary spelled out:

```json
{
  "mcpServers": {
    "bitcoffer": {
      "type": "stdio",
      "command": "/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer",
      "args": ["mcp", "--provider", "bitcoffer"],
      "env": { "BITCOFFER_VAULT_DIR": "/Users/you/.bitcoffer/vaults/<uuid>" },
      "disabled": false
    }
  }
}
```

## 3) Rules

Append [rules.md](rules.md) to `CODEBUDDY.md` or `AGENTS.md` at the project root.

## 4) Acceptance

After restarting WorkBuddy, `bitcoffer` should appear with 4 tools; or run the [universal probe](README.md#universal-smoke-test-toolslist--4), which bypasses the host entirely.

## 5) Uninstall

```bash
python3 - <<'PY'
import json, pathlib
p = pathlib.Path.home() / ".workbuddy" / "mcp.json"
data = json.loads(p.read_text())
data.get("mcpServers", {}).pop("bitcoffer", None)
p.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
print("removed bitcoffer from", p)
PY
```

Then restart WorkBuddy and remove the appended rule block.

## 6) Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| Server listed, never starts | not trusted yet | click "Trust" on the custom connector entry |
| `bitcoffer` missing after restart | `disabled: true`, or a bad JSON merge | check the file parses (`python3 -m json.tool ~/.workbuddy/mcp.json`) |
| Other connectors vanished | the file was overwritten | restore from backup; merge instead of replace |
| `list_secret_names` returns `[]` | wrong vault, or escrow not enabled | set `BITCOFFER_VAULT_DIR`, or enable MCP unlock escrow in the app |
