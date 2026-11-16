# 更新日志

[English](CHANGELOG.md) | **简体中文**

本仓库所有值得记录的改动都写在这里。格式遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循[语义化版本](https://semver.org/lang/zh-CN/)。

本仓库的版本描述的是 **launcher、skill 与宿主配置**。它不跟随 Bitcoffer 应用的版本：App 发版不代表这里有改动，反之亦然。

## [未发布]

### 修复

- `scripts/bitcoffer-login.mjs` —— `--smoke` 与 `--no-submit` 现在在必需字段无法定位/填充时会报告失败（`fields-missing` / `fill-incomplete`），不再无条件宣称成功。
- `scripts/bitcoffer-login.mjs` —— 未提供成功信号时报告 `submitted-unconfirmed` 而非误导性的 `timeout`；单步操作超时与成功轮询截止时间分离（`--op-timeout-ms`、`--goto-timeout-ms`）。
- `scripts/bitcoffer-login.mjs` —— 页面错误文本不再写入回执；支持 `--flag=value`；`--help` 以 0 退出；`--close` 在运行结束后关闭浏览器。
- `scripts/bitcoffer-launch.sh` —— 校验 `$BITCOFFER_BIN` 可执行并在失败时明确报错；`active-vault` 指针拒绝路径分隔符/目录穿越，不再盲目信任。
- `README.md` —— `run_with_secret` 注入单个密钥值，与 skill 及 schema 一致。

### 变更

- `scripts/bitcoffer-login` 改为一小段 `sh` 壳，把 argv 转发给 `bitcoffer-login.mjs`；`.mjs` 是唯一被语法检查的源。

### 新增

- `tests/` —— launcher 解析顺序与 fail-closed 行为的行为测试，以及登录助手参数解析与字段/密码纯函数的单元测试。
- `tests/install.test.sh` + `.github/workflows/install-check.yml` —— 在一次性 `macos-14` runner 里端到端验证 cask 的安装/卸载。已存在安装时拒绝运行；断言 app、zap 路径与 Caskroom 均已清除，而 `~/.bitcoffer/vaults` 按 caveats 保留。

## [0.1.0] — 2026-11-16

首个打 tag 的版本。处于 1.0 之前：路径与 skill 措辞可能在小版本之间变化。

### 新增

- `scripts/bitcoffer-launch.sh` —— 零配置 MCP 入口。连接时解析 App 签名的二进制（`$BITCOFFER_BIN` → App 内置助手 → 独立 CLI → `PATH`）与库目录（`$BITCOFFER_VAULT_DIR` → `active-vault` 指针 → 最新库），然后 `exec bitcoffer mcp`。失败时列出所有检查过的路径，并说明 App Store 构建不含内置助手的情况。
- `scripts/bitcoffer-login` + `scripts/bitcoffer-login.mjs` —— 浏览器登录驱动。密码经环境变量传入（来自 `run_with_secret`），不经 argv 也不经 stdout；只打印 JSON 回执。
- `skills/bitcoffer-credentials` —— 如何用密钥而不读密钥：查名字、注入子进程环境、绝不 `echo`/`printenv`。
- `skills/bitcoffer-setup` —— 连接缺失或损坏时的顺序诊断：App 是否安装、库是否存在、钥匙串托管是否建立、launcher 覆盖项。
- `docs/agents/` —— Claude Code、Cursor、Codex、WorkBuddy 的即贴配置包，共用规则片段，以及一个期望恰好 4 个工具的通用 `tools/list` 探针。
- 双语文档：每篇均为英文原文 + 完整简体中文对照（`*.zh.md`），顶部互链。
- `SECURITY.md`：四条设计不变量、明确的威胁模型、私密报告渠道。
- `CONTRIBUTING.md`、`CHANGELOG.md`、`.gitignore`、issue 与 pull request 模板。

### 变更

- **协议由专有改为 [MIT](LICENSE)。** 允许使用、修改、再分发与销售，条件是保留版权声明与协议正文。协议只覆盖本仓库；应用本体仍为专有。
- 仓库定位与标签改为 MCP server，不再作为应用镜像。

[未发布]: https://github.com/cygnusyang/bitcoffer-plugins/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/cygnusyang/bitcoffer-plugins/releases/tag/v0.1.0
