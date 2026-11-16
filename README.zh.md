# Bitcoffer MCP server

[English](README.md) | **简体中文**

面向 AI 编程工具的本地优先、离线**凭据管理服务**。Bitcoffer 把密码、API key 与 token 保存在 Mac 上的加密库里，本仓库封装的是**MCP server**——把这套库接到 Claude Code、Cursor、Codex、WorkBuddy 或任何 MCP 宿主上，全过程密钥不离开本机。

> 本仓库**只**包含 MCP 启动脚本、通用技能和各宿主粘贴包，**不含应用源码**。Bitcoffer 本体是专有软件，请从 <https://ai.cygnusyang.top/bitcoffer/> 下载。

## 它做什么

服务通过 MCP 暴露 **4 个工具**：

| 工具 | 用途 |
| --- | --- |
| `list_secret_names` | 列出已存条目的名称（不含值） |
| `list_secrets` | 列出名称加元数据（不含值） |
| `run_with_secret` | 把一条或多条密钥注入环境变量后执行命令 |
| `get_secret_metadata` | 读取条目元数据（不含值） |

任何工具都**不会返回值**。密钥只在你自己明确要求执行的那条命令里，通过环境变量进入子进程。

## 安装

1. **安装 Bitcoffer 应用**（macOS）：

   ```bash
   brew install --cask cygnusyang/bitcoffer/bitcoffer
   ```

   或从 <https://ai.cygnusyang.top/bitcoffer/> 下载 DMG。（较新的 Homebrew 版本可能需要先执行 `brew trust cygnusyang/bitcoffer`。）

2. **在本机解锁一次**应用，并开启托管，让 MCP server 无需口令即可解锁库：**设置 → MCP / 智能体协作 → 打开「MCP 解锁托管」**。这是按机器生效的，每台新 Mac 都要做一遍。

3. **把宿主的 MCP 命令指向启动脚本**（见下节快速开始）。启动脚本在连接时自动探测 App 签名内的二进制与本机库，不需要手写用户路径或库 UUID。

## 快速开始

先取一次启动脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/cygnusyang/bitcoffer-plugins/main/scripts/bitcoffer-launch.sh -o ~/.bitcoffer/bitcoffer-launch.sh
chmod +x ~/.bitcoffer/bitcoffer-launch.sh
```

注册到 Claude Code：

```bash
claude mcp add --scope user bitcoffer -- ~/.bitcoffer/bitcoffer-launch.sh
```

或写进任意 MCP 客户端的配置（`command` 指向启动脚本，`args` 留空）：

```json
{
  "mcpServers": {
    "bitcoffer": {
      "command": "/Users/you/.bitcoffer/bitcoffer-launch.sh"
    }
  }
}
```

验证：

```bash
claude mcp list
# 预期：bitcoffer Connected；4 tools
```

各宿主的粘贴包（Claude Code、Cursor、Codex、WorkBuddy）和通用的 `tools/list` 探测脚本都在 [`docs/agents/`](docs/agents/)。

## 安全模型

- **本地、离线。** 库是磁盘上的加密文件，没有云端账号，没有遥测，密钥从不上传。
- **永不返回值。** `list_secret_names`、`list_secrets`、`get_secret_metadata` 只返回名称与元数据。`run_with_secret` 把值注入你明确要求执行的那条命令的子进程环境——即「用密钥，不读密钥」：永远不要 `echo` 或 `printenv` 密钥。
- **传输只在本机。** server 用 stdio 讲 MCP，不监听任何 TCP/UDP 端口。
- **以 App 签名为信任锚。** 启动脚本运行的是签名 App 内自带的 `bitcoffer` helper，钥匙串托管才能正常解析。`PATH` 上那个裸 `bitcoffer` 二进制可能因为签名 / 钥匙串上下文失败。

## 仓库内容

| 路径 | 用途 |
| --- | --- |
| `scripts/bitcoffer-launch.sh` | MCP 服务入口——自动探测 App 内签名二进制与本机库，然后 `exec bitcoffer mcp` |
| `scripts/bitcoffer-login` | 浏览器登录驱动（口令经 `run_with_secret` 从环境变量传入，绝不走 argv/stdout） |
| `skills/` | 与宿主无关的技能：`bitcoffer-credentials`（用密钥）与 `bitcoffer-setup`（诊断修复） |
| `docs/agents/` | 各宿主粘贴包与 MCP 配置片段 |

## 多语言

每份文档都有英文与简体中文两个版本。英文文件顶部有「简体中文」链接，中文文件顶部有「English」链接回原文。

| English | 简体中文 |
| --- | --- |
| [README.md](README.md) | [README.zh.md](README.zh.md) |
| [docs/agents/README.md](docs/agents/README.md) | [docs/agents/README.zh.md](docs/agents/README.zh.md) |
| [docs/agents/claude-code.md](docs/agents/claude-code.md) | [docs/agents/claude-code.zh.md](docs/agents/claude-code.zh.md) |
| [docs/agents/codex.md](docs/agents/codex.md) | [docs/agents/codex.zh.md](docs/agents/codex.zh.md) |
| [docs/agents/cursor.md](docs/agents/cursor.md) | [docs/agents/cursor.zh.md](docs/agents/cursor.zh.md) |
| [docs/agents/workbuddy.md](docs/agents/workbuddy.md) | [docs/agents/workbuddy.zh.md](docs/agents/workbuddy.zh.md) |
| [docs/agents/rules.md](docs/agents/rules.md) | [docs/agents/rules.zh.md](docs/agents/rules.zh.md) |
| [skills/README.md](skills/README.md) | [skills/README.zh.md](skills/README.zh.md) |
| [skills/bitcoffer-credentials/SKILL.md](skills/bitcoffer-credentials/SKILL.md) | [SKILL.zh.md](skills/bitcoffer-credentials/SKILL.zh.md) |
| [skills/bitcoffer-setup/SKILL.md](skills/bitcoffer-setup/SKILL.md) | [SKILL.zh.md](skills/bitcoffer-setup/SKILL.zh.md) |

约定：英文版是权威原文，也是智能体实际加载的文件；中文版是完整对照翻译，不是摘要。

## 状态

早期阶段。技能与脚本路径可能随版本变化；如果你依赖某个具体形态，请锁定 tag。

## 许可

[MIT](LICENSE)。只要保留版权声明与许可文本，你可以使用、修改、再分发并销售这份代码。许可仅覆盖本仓库里的技能、脚本与文档——Bitcoffer 应用本体仍是专有软件，适用你安装时接受的那份条款。
