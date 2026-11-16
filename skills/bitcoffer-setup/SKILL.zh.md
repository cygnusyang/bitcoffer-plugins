# Bitcoffer 装机 —— 诊断与修复 bitcoffer MCP 连接

[English](SKILL.md) | **简体中文**

> 本文件是 `SKILL.md` 的中文对照译文，供人阅读。智能体加载的是英文 `SKILL.md`；两者冲突以英文为准。

Bitcoffer MCP 工具不见了、服务连不上、或在一台新机器上第一次用 bitcoffer 时，用本技能。按顺序过检查项，这是最快命中根因的顺序。

下载：<https://ai.cygnusyang.top/bitcoffer/>

## 诊断顺序

### 1. 三项前置

**a. Bitcoffer App 已安装（必须有内置 helper）**：

```
test -x /Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer && echo OK || echo MISSING
```

缺失 → 告诉用户从 <https://ai.cygnusyang.top/bitcoffer/> 安装 Bitcoffer App，装完再回来。

**b. 库已存在**：

文档约定的库目录是 `~/.bitcoffer/vaults/`（下面是 UUID 子目录）：

```
ls "$HOME/.bitcoffer/vaults/"
```

为空 → 告诉用户打开 Bitcoffer App，创建或解锁一次库。要覆盖探测，把 `BITCOFFER_VAULT_DIR` 指向具体库目录（`~/.bitcoffer/vaults/<uuid>`）。

**c. 钥匙串托管已存在（本机解锁过一次）**：

托管是按机器、按用户的。最直接的检查：用共用启动脚本 `scripts/bitcoffer-launch.sh` 连一次，看日志里有没有 `vault unlocked via MCP keychain escrow`。若报未开启 MCP 解锁托管 → 告诉用户：App 设置 → MCP / 智能体协作 → 打开「MCP 解锁托管」，并解锁一次。

### 2. 启动脚本与覆盖项

优先把宿主的 MCP `command` 指向共用脚本 `scripts/bitcoffer-launch.sh`（连接时自动探测 App 内签名二进制与本机库）。通常不需要手写路径；需要时用环境变量覆盖：

- `BITCOFFER_BIN` —— 指定 bitcoffer 二进制
- `BITCOFFER_VAULT_DIR` —— 指定具体库目录

bitcoffer 必须从 App 内路径运行；`PATH` 上的裸二进制可能因签名 / 钥匙串上下文失败。

## 症状 → 先查什么

多数反馈都能归到下面某一行。先直接跳到对得上的那行，再回到上面的顺序检查。

| 症状 | 最可能的原因 | 先查 |
| --- | --- | --- |
| 宿主里根本没有 `bitcoffer` 工具 | server 从未注册，或宿主需要重启 / 点信任 | 宿主配置文件里有这个条目吗？宿主重启过吗？ |
| 列表里显示失败、立即退出 | launcher 找不到二进制 | 手工跑一次 launcher，它会打印检查过的每条路径 |
| 连上了但 0 个工具 | launcher 在 `exec` 之前就退了 | launcher 的 stderr——通常是库的问题，不是二进制的问题 |
| 明知库里有东西，`list_secret_names` 却返回 `[]` | 托管未开启，或挑错了库 | App 设置 → MCP / Agent 协作；再 `ls ~/.bitcoffer/vaults/` |
| `keychain` / `-25308` / AMFI 报错 | 用了 `PATH` 上的裸 `bitcoffer`，或二进制与库不在同一个容器 | 把 `command` 指向 launcher 或 App 内助手 |
| 昨天好好的，今天坏了 | App 更新或被替换，托管条目对不上了 | 再解锁一次 App，然后重连 |
| 终端里能用，宿主里不行 | 宿主是从 GUI 上下文启动的，拿不到钥匙串 | 在桌面会话里解锁 App，然后重启宿主 |

## 完成判据

- 宿主里 bitcoffer MCP 服务已连接，协议工具可用：`list_secret_names` / `list_secrets` / `run_with_secret` / `get_secret_metadata`（共 4 个；**值仍然绝不返回**）。
- `list_secret_names` 能返回名称列表。

以上全通过仍连不上，就把宿主的 MCP 连接状态与启动日志交给用户 / 上报。

## 附录：宿主配置

各宿主如何注册 MCP、如何看连接状态，写在本仓库的 [`docs/agents/`](../../docs/agents/README.zh.md)。不要在本技能里硬编码某个宿主的 CLI 命令。
