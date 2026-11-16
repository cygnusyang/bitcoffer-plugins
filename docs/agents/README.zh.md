# Bitcoffer · 各 AI 宿主粘贴包

[English](README.md) | **简体中文**

四类宿主的「复制即可用」MCP 配置，全部指向同一个 launcher。

> 目标：粘贴 → 连接 → `tools/list` 显示 **4** 个工具：
> `list_secret_names`、`list_secrets`、`run_with_secret`、`get_secret_metadata`。
> 安全口径：用密钥，不读密钥。永远不要把密钥 echo 出来。
> 不在范围内：MCP 市场上架；宿主侧完成回调钩子。

每个配置包都是同样的六节：launcher 配置、显式二进制兜底、规则、验收、卸载、排障。

## 前置条件

1. 在 macOS 上装好 Bitcoffer.app（应用、助手、launcher 都是 macOS 专属）。
2. 在本机**解锁一次**应用，并在 **设置 → MCP / Agent 协作 → MCP 解锁托管**里开启托管。托管按机器、按用户生效；不开它，server 无法在后台解锁库。
3. launcher 已放在 `~/.bitcoffer/bitcoffer-launch.sh`（见 [README](../../README.zh.md#安装)的安装一节）。

你**不需要**知道库的 UUID。launcher 会解析它，`BITCOFFER_VAULT_DIR` 只用于覆盖。

## 各宿主

| 宿主 | 配置落点 | 规则文件 | 说明页 |
| --- | --- | --- | --- |
| Claude Code | `claude mcp add` 或项目内 `.mcp.json` | `CLAUDE.md` | [claude-code.zh.md](claude-code.zh.md) |
| Codex | `~/.codex/config.toml` | `AGENTS.md` | [codex.zh.md](codex.zh.md) |
| Cursor | `~/.cursor/mcp.json` | `AGENTS.md` / `.cursor/rules/` | [cursor.zh.md](cursor.zh.md) |
| WorkBuddy | `~/.workbuddy/mcp.json`（需在界面里点一次信任） | `CODEBUDDY.md` / `AGENTS.md` | [workbuddy.zh.md](workbuddy.zh.md) |

共用规则：[rules.zh.md](rules.zh.md)。共用技能：[`skills/`](../../skills/)。共用 launcher：[`scripts/bitcoffer-launch.sh`](../../scripts/bitcoffer-launch.sh)。

## 标准二进制（兜底配置用）

```
/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer
```

（`~/.bitcoffer/bin/bitcoffer` 通常符号链接到这里。）App Store 与 TestFlight 构建不含内置助手——这类机器先装独立 CLI，改用 `~/.bitcoffer/libexec/bitcoffer.app/Contents/MacOS/bitcoffer`。

## 通用冒烟测试（`tools/list` 应为 4）

完全不经过宿主。存为 `~/.bitcoffer/tools-list-probe.py` 后运行：

```bash
python3 ~/.bitcoffer/tools-list-probe.py
```

```python
#!/usr/bin/env python3
"""连接 bitcoffer MCP server，断言它恰好暴露 4 个工具。"""
import json, os, pathlib, subprocess, sys

launcher = pathlib.Path.home() / ".bitcoffer" / "bitcoffer-launch.sh"
if not launcher.exists():
    sys.exit(f"找不到 launcher：{launcher}")

frames = [
    {"jsonrpc": "2.0", "id": 1, "method": "initialize",
     "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                "clientInfo": {"name": "probe", "version": "0"}}},
    {"jsonrpc": "2.0", "method": "notifications/initialized"},
    {"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}},
]
payload = "".join(json.dumps(f) + "\n" for f in frames)

proc = subprocess.run([str(launcher)], input=payload, text=True,
                      capture_output=True, env=dict(os.environ), timeout=60)

names = []
for line in proc.stdout.splitlines():
    try:
        msg = json.loads(line)
    except json.JSONDecodeError:
        continue
    if msg.get("id") == 2:
        names = [t["name"] for t in msg["result"]["tools"]]

expected = {"list_secret_names", "list_secrets", "run_with_secret", "get_secret_metadata"}
print(f"{len(names)} 个工具：{', '.join(sorted(names)) or '（无）'}")
if set(names) != expected:
    sys.exit(f"失败——期望 {sorted(expected)}\nlauncher stderr：\n{proc.stderr}")
print("OK")
```

预期恰好是上面那 4 个工具。出现别的结果，说明 launcher 没摸到库——它的 stderr 会列出检查过的每一条路径。

想测显式二进制而不是 launcher：运行前在环境里设 `BITCOFFER_BIN` 与 `BITCOFFER_VAULT_DIR`，launcher 会透传这两个变量。
