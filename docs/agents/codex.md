# Codex ← Bitcoffer

## 1) MCP → `~/.codex/config.toml`

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"   # replace
mkdir -p ~/.codex
# 若已有 [mcp_servers.bitcoffer] 先删旧表再追加
cat >> ~/.codex/config.toml <<EOF

[mcp_servers.bitcoffer]
command = "${BIN}"
args = ["mcp", "--provider", "bitcoffer"]

[mcp_servers.bitcoffer.env]
BITCOFFER_VAULT_DIR = "${VAULT}"
EOF
```

重启 Codex。

## 2) 规则

项目根 `AGENTS.md` 追加 [rules.md](rules.md)。

## 3) 验收

Codex 会话出现 4 个 bitcoffer 工具；或跑 [通用 probe](README.md)。
