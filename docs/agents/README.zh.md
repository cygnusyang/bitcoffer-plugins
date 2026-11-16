# Bitcoffer · 各 AI 宿主粘贴包

[English](README.md) | **简体中文**

四类宿主的「复制即可用」配置与规则。

> 目标：粘贴 → 连接 → `tools/list` 显示 **4** 个工具：
> `list_secret_names`、`list_secrets`、`run_with_secret`、`get_secret_metadata`。
> 安全口径：用密钥，不读密钥。永远不要把密钥 echo 出来。
> 不在范围内：MCP 市场上架；宿主侧完成回调钩子。

## 前置条件

1. Bitcoffer.app 已装在 `/Applications` 下。
2. 在本机**解锁一次**应用（设置 → MCP → 打开「MCP 解锁托管」），让钥匙串里存在托管条目。
3. 知道自己的库目录：`~/.bitcoffer/vaults/<uuid>`。

标准 MCP 二进制（App 内 Helper，带签名与钥匙串上下文）：

```
/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer
```

（`~/.bitcoffer/bin/bitcoffer` 通常符号链接到这里。）

## 各宿主

| 宿主 | 配置落点 | 规则文件 | 说明页 |
| --- | --- | --- | --- |
| Claude Code | `claude mcp add` 或项目内 `.mcp.json` | `CLAUDE.md` | [claude-code.zh.md](claude-code.zh.md) |
| Codex | `~/.codex/config.toml` | `AGENTS.md` | [codex.zh.md](codex.zh.md) |
| Cursor | `~/.cursor/mcp.json` | `AGENTS.md` / `.cursor/rules/` | [cursor.zh.md](cursor.zh.md) |
| WorkBuddy | `~/.workbuddy/mcp.json` | `CODEBUDDY.md` / `AGENTS.md` | [workbuddy.zh.md](workbuddy.zh.md) |

共用规则：[rules.zh.md](rules.zh.md)。共用技能：[`skills/`](../../skills/)。共用 MCP 启动脚本：[`scripts/bitcoffer-launch.sh`](../../scripts/bitcoffer-launch.sh)（连接时自动解析 App 内签名二进制与本机库）。

## 通用连通性自检（`tools/list` 应为 4）

存为 `/tmp/bitcoffer-tools-list-probe.py` 后运行：

```bash
export BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
export VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"  # 换成你的
python3 /tmp/bitcoffer-tools-list-probe.py
```

探测脚本：

```python
import json, os, subprocess
bin_path = os.environ["BIN"]
vault = os.environ["VAULT"]
frames = [
    {"jsonrpc": "2.0", "id": 1, "method": "initialize",
     "params": {"protocolVersion": "2024-11-05", "capabilities": {},
               "clientInfo": {"name": "probe", "version": "0"}}},
    {"jsonrpc": "2.0", "method": "notifications/initialized"},
    {"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}},
]
payload = "".join(json.dumps(f) + chr(10) for f in frames)
env = {**os.environ, "BITCOFFER_VAULT_DIR": vault}
proc = subprocess.run([bin_path, "mcp", "--provider", "bitcoffer"],
                      input=payload, text=True, capture_output=True, env=env)
for line in proc.stdout.splitlines():
    line = line.strip()
    if not line:
        continue
    try:
        o = json.loads(line)
    except json.JSONDecodeError:
        continue
    if o.get("id") == 2:
        names = [t["name"] for t in o["result"]["tools"]]
        print(len(names), ", ".join(names))
```

预期输出上面列出的 **4** 个工具。
