# Claude Code ← Bitcoffer

[English](claude-code.md) | **简体中文**

与其他宿主一致：把 MCP 配置指向共用启动脚本 [`scripts/bitcoffer-launch.sh`](../../scripts/bitcoffer-launch.sh)，规则用 [rules.zh.md](rules.zh.md)。共用技能放在仓库根目录的 [`skills/`](../../skills/) 下。

## 1) MCP

`scripts/bitcoffer-launch.sh` 在连接时解析 App 内签名二进制与本机库（可用 `BITCOFFER_VAULT_DIR` / `BITCOFFER_BIN` 覆盖）。克隆或复制本仓库后，把路径换成脚本实际位置：

```bash
claude mcp add --scope user bitcoffer -- /path/to/bitcoffer/scripts/bitcoffer-launch.sh
```

或写项目级 `.mcp.json`（路径换成本机真实值）：

```json
{
  "mcpServers": {
    "bitcoffer": {
      "command": "/path/to/bitcoffer/scripts/bitcoffer-launch.sh"
    }
  }
}
```

也可以直接注册 helper 二进制并显式传库目录：

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"   # 换成你的

claude mcp add --scope user bitcoffer \
  --env "BITCOFFER_VAULT_DIR=${VAULT}" \
  -- "$BIN" mcp --provider bitcoffer
```

## 2) 规则

把 [rules.zh.md](rules.zh.md) 追加到项目根目录的 `CLAUDE.md`。

## 3) 验收

```bash
claude mcp list
# 预期：bitcoffer Connected；4 tools
```

或运行[通用探测脚本](README.zh.md)。
