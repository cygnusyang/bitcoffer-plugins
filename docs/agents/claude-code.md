# Claude Code ← Bitcoffer

与其它宿主相同：MCP 配置指向共享启动脚本 [`scripts/bitcoffer-launch.sh`](../../scripts/bitcoffer-launch.sh)，规则走 [rules.md](rules.md)。共享技能见仓库根 [`skills/`](../../skills/)。

## 1) MCP

`scripts/bitcoffer-launch.sh` 在连接时自动解析 App 签名二进制与本机 vault（可用 `BITCOFFER_VAULT_DIR` / `BITCOFFER_BIN` 覆盖）。把路径换成你本机克隆或拷贝后的脚本位置：

```bash
claude mcp add --scope user bitcoffer -- /path/to/bitcoffer/scripts/bitcoffer-launch.sh
```

或项目级 `.mcp.json`（把路径换成真实值）：

```json
{
  "mcpServers": {
    "bitcoffer": {
      "command": "/path/to/bitcoffer/scripts/bitcoffer-launch.sh"
    }
  }
}
```

也可以直接登记 helper 二进制并显式传入 vault 目录：

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"   # replace

claude mcp add --scope user bitcoffer \
  --env "BITCOFFER_VAULT_DIR=${VAULT}" \
  -- "$BIN" mcp --provider bitcoffer
```

## 2) 规则

项目根 `CLAUDE.md` 追加 [rules.md](rules.md)。

## 3) 验收

```bash
claude mcp list
# 期望：bitcoffer Connected；4 tools
```

或跑 [通用 probe](README.md)。
