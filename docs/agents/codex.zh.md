# Codex ← Bitcoffer

[English](codex.md) | **简体中文**

配置落点：`~/.codex/config.toml`。目标：会话里出现 **4** 个 bitcoffer 工具。规则写进 `AGENTS.md`。

## 1) MCP —— launcher（推荐）

```bash
mkdir -p ~/.codex
# 若已存在 [mcp_servers.bitcoffer]，先删掉那个表——TOML 不允许同名表出现两次，
# 重复会让整个配置文件静默失效。
cat >> ~/.codex/config.toml <<'EOF'

[mcp_servers.bitcoffer]
command = "/Users/you/.bitcoffer/bitcoffer-launch.sh"
args = []
EOF
```

把路径换成你真实的家目录（TOML 不做 `~` 展开）。

重启 Codex。launcher 在每次连接时解析二进制与库目录。

## 2) MCP —— 显式指定二进制与库（兜底）

```bash
BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"   # 替换
mkdir -p ~/.codex
cat >> ~/.codex/config.toml <<EOF

[mcp_servers.bitcoffer]
command = "${BIN}"
args = ["mcp", "--provider", "bitcoffer"]

[mcp_servers.bitcoffer.env]
BITCOFFER_VAULT_DIR = "${VAULT}"
EOF
```

## 3) 规则

把 [rules.zh.md](rules.zh.md) 追加到项目根目录的 `AGENTS.md`。

## 4) 验收

Codex 会话里应出现 4 个 bitcoffer 工具；或直接跑[通用探针](README.zh.md#通用冒烟测试toolslist--4)。

## 5) 卸载

删掉 `[mcp_servers.bitcoffer]` 表，以及（如果存在）它的 `[mcp_servers.bitcoffer.env]` 子表，再从 `AGENTS.md` 删掉追加的那段。只删两个 TOML 表中的一个会留下孤立的 `env` 表，Codex 会报配置错误。

## 6) 排障

| 症状 | 原因 | 处理 |
| --- | --- | --- |
| 改完 Codex 起不来 | `[mcp_servers.bitcoffer]` 表重复，或路径里写了 `~` | 只留一个表；路径写绝对路径 |
| 服务已注册但没有工具 | launcher 非零退出 | 在终端直接跑 launcher，看它打印的路径清单 |
| `list_secret_names` 返回 `[]` | 库不对，或未开启托管 | 设 `BITCOFFER_VAULT_DIR`，或在 App 里开启 MCP 解锁托管 |
