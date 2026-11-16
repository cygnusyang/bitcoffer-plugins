# Codex ← Bitcoffer

[English](codex.md) | **简体中文**

## 1) MCP → `~/.codex/config.toml`

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"   # 换成你的
mkdir -p ~/.codex
# 如果 [mcp_servers.bitcoffer] 已存在，先删掉旧表再追加
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

把 [rules.zh.md](rules.zh.md) 追加到项目根目录的 `AGENTS.md`。

## 3) 验收

Codex 会话里应能看到 4 个 bitcoffer 工具；或运行[通用探测脚本](README.zh.md)。
