# 参与贡献

[English](CONTRIBUTING.md) | **简体中文**

谢谢花时间。本仓库刻意做小：一个 launcher、一个登录助手、两个 skill、几套宿主配置包。能保持它小的改动最容易合。

## 这个仓库是什么（不是什么）

| 是本仓库 | 不是本仓库 |
| --- | --- |
| MCP launcher、浏览器登录助手 | Bitcoffer 应用源码（专有，不在此） |
| 与宿主无关的 skill | 某个宿主的插件市场上架物 |
| Claude Code / Cursor / Codex / WorkBuddy 的即贴配置 | 封装 SDK 或客户端库 |

如果一项改动必须改 App 才能生效，那它属于上游，不属于这里。

## 能帮什么

- **某个宿主配置有 bug** —— 开 issue，附宿主名、版本、你粘贴的原文片段。
- **支持新宿主** —— 见下方清单。
- **文档 / 译文漂移** —— 英文文件与 `简体中文` 对照不一致就是 bug，报上来。
- **skill 措辞** —— 如果 agent 读了 skill 仍然泄露了值、或找不到库，这是最有价值的报告。附上对话记录，密钥脱敏。

## 语言规则

英文是原文，也是模型加载的那份。每篇文档同时提供完整简体中文译文，不是摘要：

- `X.md` → `X.zh.md`，同目录、同结构、同标题层级。
- 两侧**必须在同一个 pull request 里**一起改。只改一侧会被退回。
- 每篇顶部有语言切换行：`**English** | [简体中文](X.zh.md)` 及其镜像。
- `SKILL.zh.md` **不带 YAML frontmatter**。带上会让技能加载器把同一目录当成两个同名技能；中文那份是给人读的。

## 改 launcher 或登录助手

无构建步骤，launcher 无依赖（POSIX `sh`）。提 pull request 前跑：

```bash
shellcheck -s sh scripts/bitcoffer-launch.sh
node --check scripts/bitcoffer-login.mjs
cp scripts/bitcoffer-login /tmp/bitcoffer-login-shim.mjs && node --check /tmp/bitcoffer-login-shim.mjs
```

最后一行不是笔误：`scripts/bitcoffer-login` 是一个没有扩展名的 Node ESM 壳（它必须能以 `bitcoffer-login` 的名字出现在 `PATH` 上供调用），所以 `node --check` 会按 CommonJS 解析，撞上里面的 `import` 报错。复制成 `.mjs` 再检查是最省事的做法。

然后手工把解析顺序走一遍——实践中出问题的都是最无聊的几种情况：

| 场景 | 期望 |
| --- | --- |
| App 已装、库存在 | 能连上，`tools/list` 返回 4 个 |
| `BITCOFFER_BIN` 指向错误路径 | 明确报错，不静默回退到别的二进制 |
| `BITCOFFER_VAULT_DIR` 指向过期库 | 就用它，不悄悄换另一个 |
| 没装 App、`PATH` 上也没有 CLI | 打印检查过的每一条路径，非零退出 |
| App Store 构建（不含内置助手） | 说明 CLI 需单独安装 |

用 [`docs/agents/README.md`](docs/agents/README.zh.md) 里的探针端到端验一遍 MCP 表面——应恰好 **4** 个工具。

## 新增宿主

1. `docs/agents/<host>.md` + `docs/agents/<host>.zh.md`。
2. 照现有配置包的骨架写：前置条件 → 配置落点（具体文件、具体片段）→ 怎么验证 → 怎么卸载。
3. 在 `docs/agents/README.md` 与 `docs/agents/README.zh.md` 的宿主表里各加一行。
4. 在 `README.md` 与 `README.zh.md` 的语言索引里各加一对。
5. 禁止硬编码机器路径。用 `/Users/you/...` 或 `$HOME/...`。

## 会被直接拒的改动

- diff 里出现任何密钥值、真实 token、库路径或授权码。
- 机器相关的绝对路径（`/Users/<name>/...`）、内网主机名、内部仓库地址。
- 把某个宿主的安装命令写进 **skill**。skill 与宿主无关；宿主命令只放 `docs/agents/`。
- 文档承诺 App 并不存在的功能。没发布就不写。

## 提交信息

[Conventional Commits](https://www.conventionalcommits.org/zh-hans/)，一次提交一件事：

```
feat(launcher): resolve standalone CLI paths
fix(skill): stop suggesting printenv for debugging
docs(cursor): correct the config drop path
chore: relicense under MIT
```

## 授权

贡献按 [MIT 协议](LICENSE)接收。提交 pull request 即表示你确认有权按该条款提交这些代码。
