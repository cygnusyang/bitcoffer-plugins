# Cursor ← Bitcoffer

Drop path: `~/.cursor/mcp.json`. **Only add or update `mcpServers.bitcoffer`; do not overwrite the whole file.**

## 1) MCP

**Option A — CLI**

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"
cursor --add-mcp "$(python3 -c "import json,os; print(json.dumps({"name":"bitcoffer","command":os.environ["BIN"],"args":["mcp","--provider","bitcoffer"],"env":{"BITCOFFER_VAULT_DIR":os.environ["VAULT"]}}))" )"
```

(First `export BIN=... VAULT=...`.)

**Option B — merge write (recommended)**

Save the following as `/tmp/add-bitcoffer-cursor-mcp.py`, then run `BITCOFFER_VAULT_DIR=... python3 /tmp/add-bitcoffer-cursor-mcp.py`:

```python
import json, pathlib, os
path = pathlib.Path.home() / ".cursor" / "mcp.json"
bin_path = "/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
vault = os.environ["BITCOFFER_VAULT_DIR"]
path.parent.mkdir(parents=True, exist_ok=True)
data = json.loads(path.read_text()) if path.exists() else {}
servers = data.setdefault("mcpServers", {})
servers["bitcoffer"] = {
    "command": bin_path,
    "args": ["mcp", "--provider", "bitcoffer"],
    "env": {"BITCOFFER_VAULT_DIR": vault},
}
path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + chr(10))
print("wrote", path)
```

## 2) Rules

Append [rules.md](rules.md) to `AGENTS.md` or `.cursor/rules/bitcoffer.mdc`.

## 3) Acceptance

Cursor Settings → MCP: `bitcoffer` is connected (4 tools); or run the [universal probe](README.md).
