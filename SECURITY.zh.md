# 安全策略

[English](SECURITY.md) | **简体中文**

Bitcoffer 保存密码、API key 和 token。任何让密钥值流到不该到的地方——模型上下文、日志文件、shell 历史、你没要求执行的子进程——都按漏洞处理，不按普通缺陷处理。

## 设计不变量

本仓库声称的保证如下。能打破其中任一条的路径，就是漏洞：

1. **不存在读出通道。** 没有任何工具、开关或环境变量会返回密钥值。`list_secret_names`、`list_secrets`、`get_secret_metadata` 只返回名称与元数据。
2. **值只通过子进程环境变量传递**，且只在你显式通过 `run_with_secret` 要求执行的命令里。
3. **不联网。** MCP server 只讲 stdio 上的 JSON-RPC，不开 TCP/UDP 监听，不发起对外连接。
4. **无云端。** 库是本地加密文件，没有账号、没有同步、没有遥测。

## 报告漏洞

- **首选：** 本仓库的[私密漏洞报告](https://github.com/cygnusyang/bitcoffer-plugins/security/advisories/new)。
- **备选：** 发邮件到 <ruohuyang@163.com>，标题含 `BITCOFFER SECURITY`。
- **不要开公开 issue**，也不要在报告里放真实密钥。做脱敏，只描述形态。

一份有用的报告需要：

| 字段 | 内容 |
| --- | --- |
| 组件 | launcher、登录助手、某个 skill、某个宿主配置片段，或 App 本体 |
| 版本 | 仓库 tag/commit；如相关则附 Bitcoffer App 版本 |
| 环境 | macOS 版本、芯片、MCP 宿主（Claude Code / Cursor / Codex / WorkBuddy / 其他） |
| 复现 | 步骤，或最小脚本（密钥换成占位符） |
| 影响 | 打破了上面哪条不变量，值是否已被泄露 |

## 范围

**在范围内**

- `scripts/bitcoffer-launch.sh` —— 路径解析、环境变量处理、参数透传
- `scripts/bitcoffer-login`、`scripts/bitcoffer-login.mjs` —— 密码如何传入、记录或持久化
- `skills/**` —— 可能诱导 agent 泄露值的指令
- `docs/agents/**` —— 会把密钥写进被回读、被提交或被记录的文件的配置片段
- Bitcoffer App 本体（同一报告渠道）

**不在范围内**

- 宿主应用（Claude Code、Cursor、Codex、WorkBuddy）自身的漏洞——请报给上游
- 已经拿到你的登录用户、完全磁盘访问权限或已解锁钥匙串的攻击者；本设计不防这一层
- 你主动安装的恶意 MCP server
- 对维护者的社工

## 威胁模型（直说）

Bitcoffer 防的是**意外与结构性泄露**：agent 本会把密码 `echo` 进上下文、脚本本会硬编码密钥、配置文件本会被提交。它**不防**已经以你的用户权限运行的代码。信任边界就是这台 Mac。

## 我们会做什么

- **3 个工作日内**确认收到。
- **10 个工作日内**给定性（严重度、影响版本、是否需要修复）。
- 高危问题目标 **30 天内**修复并协调披露。低危文档问题随下个版本发布。
- 除非你要求匿名，安全公告中致谢。

## 支持版本

只有最新 release tag 收到安全修复。本仓库处于 1.0 之前：用 tag 固定版本，升级前先读 [CHANGELOG.zh.md](CHANGELOG.zh.md)。
