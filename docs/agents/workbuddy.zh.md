# WorkBuddy ← Bitcoffer

[English](workbuddy.md) | **简体中文**

配置落点：`~/.workbuddy/mcp.json`。**只新增或更新 `mcpServers.bitcoffer`，不要整文件覆盖。** 目标：重启后 `bitcoffer` 出现，**4** 个工具。

WorkBuddy 对新 MCP server 需要一次显式信任——只写配置不起作用。

## 1) MCP —— launcher（推荐）

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

然后重启 WorkBuddy，在连接器管理页右上角的「自定义连接器」入口里对新 server 点**信任**。不点信任，server 只是登记着，永远不会启动。

## 2) MCP —— 显式指定二进制与库（兜底）

同样的合并写法，把二进制写死：

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

## 3) 规则

把 [rules.zh.md](rules.zh.md) 追加到项目根目录的 `CODEBUDDY.md` 或 `AGENTS.md`。

## 4) 验收

重启 WorkBuddy 后 `bitcoffer` 应出现且有 4 个工具；或直接跑[通用探针](README.zh.md#通用冒烟测试toolslist--4)，完全绕开宿主。

## 5) 卸载

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

重启 WorkBuddy，并删掉追加的规则段。

## 6) 排障

| 症状 | 原因 | 处理 |
| --- | --- | --- |
| 列表里有，但从不启动 | 还没点信任 | 在自定义连接器入口点「信任」 |
| 重启后 `bitcoffer` 不见了 | `disabled: true`，或 JSON 合并写坏 | 先验文件能解析：`python3 -m json.tool ~/.workbuddy/mcp.json` |
| 其他连接器全没了 | 整文件被覆盖 | 从备份恢复；以后用合并写法 |
| `list_secret_names` 返回 `[]` | 库不对，或未开启托管 | 设 `BITCOFFER_VAULT_DIR`，或在 App 里开启 MCP 解锁托管 |
