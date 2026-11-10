---
name: bitcoffer-setup
description: Diagnose and repair the Bitcoffer MCP connection — run when Bitcoffer tools are missing, the server fails to connect, or on a brand-new machine/first run
---

# Bitcoffer Setup — 诊断与修复 bitcoffer MCP 连接

当 Bitcoffer MCP 工具缺失、服务器连接失败，或第一次在新机器上使用 bitcoffer 时使用本 skill。按顺序排查，最快命中根因。

官网下载：https://ai.cygnusyang.top/bitcoffer/

## 诊断顺序

### 1. 前置三要素

**a. Bitcoffer App 已安装（必须有内嵌 helper）**：

```
test -x /Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer && echo OK || echo MISSING
```

缺失 → 提示用户从 https://ai.cygnusyang.top/bitcoffer/ 安装 Bitcoffer App，装好后再来。

**b. vault 已存在**：

文档口径中的本机库目录是 `~/.bitcoffer/vaults/`（其下为 UUID 子目录）：

```
ls "$HOME/.bitcoffer/vaults/"
```

为空 → 提示用户先打开 Bitcoffer App 创建/解锁一次 vault。覆盖探测时可设 `BITCOFFER_VAULT_DIR` 指向某一座库的目录（`~/.bitcoffer/vaults/<uuid>`）。

**c. Keychain escrow 已建立（本机解锁过一次）**：

escrow 是每机每用户的。最直接的验证：用共享启动脚本 `scripts/bitcoffer-launch.sh` 试连，看日志是否出现 `vault unlocked via MCP keychain escrow`。若报未启用 MCP 解锁托管 → 提示用户：App 设置 → MCP / Agent 协作 → 启用「MCP 解锁托管」，并解锁一次。

### 2. 启动脚本与覆盖

推荐让宿主的 MCP `command` 指向仓库共享脚本 `scripts/bitcoffer-launch.sh`（连接时自动探测 App 签名二进制与本机 vault）。一般不需要手写路径；必要时用环境变量覆盖：

- `BITCOFFER_BIN` — 指定 bitcoffer 二进制
- `BITCOFFER_VAULT_DIR` — 指定某一座库的目录

bitcoffer 必须从 App 内路径运行；PATH 上的 bare 二进制可能因签名/Keychain 上下文失败。

## 完成标准

- 宿主里 bitcoffer MCP 已连接，且协议工具可用：`list_secret_names` / `list_secrets` / `run_with_secret` / `get_secret_metadata`（共 4 个；**值仍不会返回**）。
- `list_secret_names` 能返回名字列表。

若以上都通过仍连不上，把宿主的 MCP 连接状态和 launch 日志交给用户/上报。

## 附录：宿主配置

各宿主如何登记 MCP、检查连接状态，以仓库 [`docs/agents/`](../../docs/agents/) 为准，不要在本 skill 里写死某一宿主的 CLI 命令。
