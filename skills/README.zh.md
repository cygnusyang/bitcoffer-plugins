# Bitcoffer 共用技能

[English](README.md) | **简体中文**

本目录是与宿主无关的 Bitcoffer 技能的**唯一来源**（也是技能市场打包时应取的目录树）。不要按宿主各自 fork 一份正文。

| 技能 | 用途 |
| --- | --- |
| [bitcoffer-credentials](bitcoffer-credentials/SKILL.zh.md) | 通过 MCP（`run_with_secret`）使用密钥，且不把值读进模型上下文 |
| [bitcoffer-setup](bitcoffer-setup/SKILL.zh.md) | 诊断 / 修复本机 Bitcoffer MCP 连接 |

各宿主的 MCP 配置与粘贴步骤放在 [`docs/agents/`](../docs/agents/README.zh.md)。技能正文与附录都指向那个目录，不在技能里硬编码宿主名称。

这些技能配套的共用工具：

- [`scripts/bitcoffer-launch.sh`](../scripts/bitcoffer-launch.sh) —— 解析 App 内签名二进制与本机库，然后启动 MCP 服务
- [`scripts/bitcoffer-login`](../scripts/bitcoffer-login) —— 浏览器登录驱动；口令只经 `run_with_secret` 以环境变量传入

下载 Bitcoffer 应用：https://ai.cygnusyang.top/bitcoffer/
