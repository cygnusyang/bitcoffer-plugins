# WorkBuddy ← Bitcoffer

落点：`~/.workbuddy/mcp.json`。**只增改 `mcpServers.bitcoffer`，不要整文件覆盖。**

## 1) MCP

把下面保存为 `/tmp/add-bitcoffer-workbuddy-mcp.py` 后执行
`BITCOFFER_VAULT_DIR=$HOME/.bitcoffer/vaults/<uuid> python3 /tmp/add-bitcoffer-workbuddy-mcp.py`：

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

## 2) 规则

项目根 `CODEBUDDY.md` 或 `AGENTS.md` 追加 [rules.md](rules.md)。

## 3) 验收

重启 WorkBuddy 后见 `bitcoffer`（4 tools）；或跑 [通用 probe](README.md)。
