# Cursor ← Bitcoffer

落点：`~/.cursor/mcp.json`。**只增改 `mcpServers.bitcoffer`，不要整文件覆盖。**

## 1) MCP

**方式 A — CLI**

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"
cursor --add-mcp "$(python3 -c "import json,os; print(json.dumps({"name":"bitcoffer","command":os.environ["BIN"],"args":["mcp","--provider","bitcoffer"],"env":{"BITCOFFER_VAULT_DIR":os.environ["VAULT"]}}))" )"
```

（先 `export BIN=... VAULT=...`。）

**方式 B — 合并写入（推荐）**

把下面保存为 `/tmp/add-bitcoffer-cursor-mcp.py` 后执行 `BITCOFFER_VAULT_DIR=... python3 /tmp/add-bitcoffer-cursor-mcp.py`：

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

## 2) 规则

`AGENTS.md` 或 `.cursor/rules/bitcoffer.mdc` 追加 [rules.md](rules.md)。

## 3) 验收

Cursor Settings → MCP：`bitcoffer` 已连接（4 tools）；或跑 [通用 probe](README.md)。
