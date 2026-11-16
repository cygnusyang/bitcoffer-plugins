# Cursor ← Bitcoffer

[English](cursor.md) | **简体中文**

配置落点：`~/.cursor/mcp.json`。**只新增或更新 `mcpServers.bitcoffer`，不要整文件覆盖。**

## 1) MCP

**方案 A —— CLI**

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"
cursor --add-mcp "$(python3 -c "import json,os; print(json.dumps({"name":"bitcoffer","command":os.environ["BIN"],"args":["mcp","--provider","bitcoffer"],"env":{"BITCOFFER_VAULT_DIR":os.environ["VAULT"]}}))" )"
```

（先 `export BIN=... VAULT=...`。）

**方案 B —— 合并写入（推荐）**

存为 `/tmp/add-bitcoffer-cursor-mcp.py`，然后运行 `BITCOFFER_VAULT_DIR=... python3 /tmp/add-bitcoffer-cursor-mcp.py`：

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

把 [rules.zh.md](rules.zh.md) 追加到 `AGENTS.md` 或 `.cursor/rules/bitcoffer.mdc`。

## 3) 验收

Cursor 设置 → MCP：`bitcoffer` 已连接（4 个工具）；或运行[通用探测脚本](README.zh.md)。
