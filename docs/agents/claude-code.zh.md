# Claude Code ← Bitcoffer

[English](claude-code.md) | **简体中文**

目标：`claude mcp list` 显示 `bitcoffer` 已连接，且有 **4** 个工具。规则写进 `CLAUDE.md`；共用 skill 在 [`skills/`](../../skills/)。

## 1) MCP —— launcher（推荐）

launcher 每次连接都会重新解析 App 签名的二进制与库目录，所以配置里不会落进任何机器相关信息：

```bash
claude mcp add --scope user bitcoffer -- ~/.bitcoffer/bitcoffer-launch.sh
```

想把它提交进仓库的 `.mcp.json`，把 `--scope user` 换成 `--scope project`。如果你是从克隆目录直接跑，指向克隆里的 `scripts/bitcoffer-launch.sh`。

等价的项目级 `.mcp.json`：

```json
{
  "mcpServers": {
    "bitcoffer": {
      "command": "/Users/you/.bitcoffer/bitcoffer-launch.sh"
    }
  }
}
```

## 2) MCP —— 显式指定二进制与库（兜底）

直接注册助手并自己传库目录。用于自动识别挑错库、或你需要同时用多个库的情况：

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"   # 替换

claude mcp add --scope user bitcoffer \
  --env "BITCOFFER_VAULT_DIR=${VAULT}" \
  -- "$BIN" mcp --provider bitcoffer
```

App Store 与 TestFlight 构建在 `Contents/Helpers` 下不含助手；这类机器先装独立 CLI，改用 `~/.bitcoffer/libexec/bitcoffer.app/Contents/MacOS/bitcoffer`。

## 3) 规则

把 [rules.zh.md](rules.zh.md) 追加到项目根目录的 `CLAUDE.md`。这段规则是用来拦住 Claude 试图 `echo` 密钥"验证一下"的。

## 4) 验收

```bash
claude mcp list
# 期望：bitcoffer Connected；4 tools
```

或直接跑[通用探针](README.zh.md#通用冒烟测试toolslist--4)，完全不经过宿主。

## 5) 卸载

```bash
claude mcp remove bitcoffer --scope user
```

同时从 `CLAUDE.md` 删掉追加的那段。launcher 脚本与 App 不受这条注册影响，留着无妨。

## 6) 排障

| 症状 | 原因 | 处理 |
| --- | --- | --- |
| 列表里有 `bitcoffer` 但没工具 | launcher 在连接时非零退出 | 在终端直接跑 `~/.bitcoffer/bitcoffer-launch.sh`，看它打印的路径清单 |
| 已连接，`list_secret_names` 返回 `[]` | 未开启托管，或库不对 | 设置 → MCP / Agent 协作 → 开启 MCP 解锁托管；或设 `BITCOFFER_VAULT_DIR` |
| 解锁报钥匙串相关错误 | 用了 `PATH` 上的裸 `bitcoffer` | 把 PATH 二进制从配置里去掉，改用 launcher |
| 终端能跑、Claude Code 里不行 | GUI 启动的上下文拿不到钥匙串条目 | 在桌面会话里解锁一次 App，再重连 |
