# WorkBuddy ← Bitcoffer

[English](workbuddy.md) | **简体中文**

配置落点：`~/.workbuddy/mcp.json`。**只新增或更新 `mcpServers.bitcoffer`，不要整文件覆盖。**

## 1) MCP

存为 `/tmp/add-bitcoffer-workbuddy-mcp.py`，然后运行
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

把 [rules.zh.md](rules.zh.md) 追加到项目根目录的 `CODEBUDDY.md` 或 `AGENTS.md`。

## 3) 验收

重启 WorkBuddy 后应出现 `bitcoffer`（4 个工具）；或运行[通用探测脚本](README.zh.md)。
