# Cursor ← Bitcoffer

[English](cursor.md) | **简体中文**

配置落点：`~/.cursor/mcp.json`。**只新增或更新 `mcpServers.bitcoffer`，不要整文件覆盖。** 目标：Cursor 设置 → MCP 里 `bitcoffer` 已连接，**4** 个工具。

## 1) MCP —— launcher（推荐）

手写这段最稳（绝不碰你其他的 server），然后重启 Cursor：

```json
{
  "mcpServers": {
    "bitcoffer": {
      "command": "/Users/you/.bitcoffer/bitcoffer-launch.sh"
    }
  }
}
```

如果文件里已有别的 server，把 `bitcoffer` 这个键**并进**现有的 `mcpServers` 对象，不要替换。

或者让脚本做合并：

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

## 2) MCP —— 显式指定二进制与库（兜底）

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

## 3) 规则

把 [rules.zh.md](rules.zh.md) 追加到项目根目录的 `AGENTS.md`，或存成 `.cursor/rules/bitcoffer.mdc` 作为 Cursor 原生规则。

## 4) 验收

Cursor 设置 → MCP：`bitcoffer` 已连接（4 个工具）；或直接跑[通用探针](README.zh.md#通用冒烟测试toolslist--4)。

## 5) 卸载

从 `~/.cursor/mcp.json` 的 `mcpServers` 里删掉 `bitcoffer` 键（或在设置 → MCP 里关掉），重启 Cursor。若建过 `.cursor/rules/bitcoffer.mdc` 一并删除。

## 6) 排障

| 症状 | 原因 | 处理 |
| --- | --- | --- |
| 设置里 `bitcoffer` 飘红/失败 | launcher 没有执行权限，或路径写了 `~` | `chmod +x` launcher；改用绝对路径 |
| 其他 MCP server 全不见了 | 整文件被覆盖而不是合并 | 从 Cursor 备份或 git 历史恢复；以后用合并写法 |
| 已连接但 0 个工具 | launcher 非零退出 | 在终端直接跑 launcher，看它打印的路径清单 |
| `list_secret_names` 返回 `[]` | 库不对，或未开启托管 | 设 `BITCOFFER_VAULT_DIR`，或在 App 里开启 MCP 解锁托管 |
