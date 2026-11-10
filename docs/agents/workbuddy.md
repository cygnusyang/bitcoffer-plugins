# WorkBuddy ← Bitcoffer

Drop path: `~/.workbuddy/mcp.json`. **Only add or update `mcpServers.bitcoffer`; do not overwrite the whole file.**

## 1) MCP

Save the following as `/tmp/add-bitcoffer-workbuddy-mcp.py`, then run
`BITCOFFER_VAULT_DIR=$HOME/.bitcoffer/vaults/<uuid> python3 /tmp/add-bitcoffer-workbuddy-mcp.py`:

```python
import json, pathlib, os
path = pathlib.Path.home() / ".workbuddy" / "mcp.json"
bin_path = "/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
vault = os.environ["BITCOFFER_VAULT_DIR"]
path.parent.mkdir(parents=True, exist_ok=True)
data = json.loads(path.read_text()) if path.exists() else {}
servers = data.setdefault("mcpServers", {})
servers["bitcoffer"] = {
    "type": "stdio",
    "command": bin_path,
    "args": ["mcp", "--provider", "bitcoffer"],
    "env": {"BITCOFFER_VAULT_DIR": vault},
    "disabled": False,
}
path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + chr(10))
print("wrote", path)
```

## 2) Rules

Append [rules.md](rules.md) to `CODEBUDDY.md` or `AGENTS.md` at the project root.

## 3) Acceptance

After restarting WorkBuddy, `bitcoffer` should appear (4 tools); or run the [universal probe](README.md).
