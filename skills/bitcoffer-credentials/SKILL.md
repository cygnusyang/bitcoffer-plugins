---
name: bitcoffer-credentials
description: Use centrally-managed secrets (passwords/API keys) via the Bitcoffer MCP server without ever reading secret values into the model context
---

# Bitcoffer Credentials — 用密码，不读密码

Bitcoffer 是集中管理密码/密钥的本地网关（数据不出本机）。本 skill 说明如何通过本机 Bitcoffer App 提供的 MCP 工具取用这些凭据——**核心纪律是「Use Secret, not Read Secret」**：凭据值只注入到子进程环境里使用，永远不进入模型上下文。

官网下载：https://ai.cygnusyang.top/bitcoffer/

## When to Use

当任务需要密码、token、API key 时使用（登录网页、认证 API、解密文件、执行需要凭据的命令等）。先在这里查，再考虑问用户。

## 关键事实

- MCP 工具名以**协议名**为准（`list_secret_names` / `list_secrets` / `run_with_secret` / `get_secret_metadata`）。不同宿主可能给工具加上自己的前缀，调用时用协议名，不要假设某一种前缀。
- 连接本机 Bitcoffer MCP 时，推荐用仓库共享启动脚本 `scripts/bitcoffer-launch.sh`：连接时自动探测 App 签名二进制与本机 vault。可用 `BITCOFFER_VAULT_DIR` / `BITCOFFER_BIN` 覆盖自动探测。
- 若工具不可用或连接失败：先按 `bitcoffer-setup` skill 排查（App 是否安装、是否解锁过一次、vault 是否可探测）。
- 解锁方式：**Keychain 托管（escrow）自动解锁**，无需在配置里写入密码。但 escrow 是**每机每用户**的——新机器须先用 Bitcoffer App 手动解锁一次。bitcoffer 必须从 App 内路径运行（bare 二进制会因签名/Keychain 上下文失败）。
- 若 PATH 上有登录助手（仓库 `scripts/bitcoffer-login`）可用，可用它做浏览器自动登录。新机器需装好 playwright：`npm i -g playwright && npx playwright install chromium`（脚本会自动解析）。

## 可用工具（精确 schema）

| 工具 | 参数 | 返回 |
|---|---|---|
| `list_secret_names` | `{ vault? }` | 所有 secret 的名字（**值永不返回**） |
| `list_secrets` | `{ vault? }` | secret 元数据（name, id, category, updated_at；**值永不返回**） |
| `run_with_secret` | `{ secret(必填), cmd(必填), args[], cwd?, env_name? }` | 把 secret 注入子进程环境运行命令；**值永不返回** |
| `get_secret_metadata` | `{ secret(必填) }` | 只读元数据；**含登录用户名**（若 bitcoffer 条目存了） |

## 工作流

### 1. 查（确认 secret 存在、记下准确名字）

```
list_secret_names {}
```

名字可能与你以为的不同（中文名、带域名后缀等），**以返回名为准**。

### 2. 用（值注入子进程，永不进入上下文）

```
run_with_secret {
  secret: "<步骤1查到的名字>",
  cmd: "<可执行文件>",
  args: ["...", "--password-env", "ENV_NAME"],
  env_name: "ENV_NAME"   // 默认=secret 名；显式给一个短名更稳
}
```

子进程从 `process.env.ENV_NAME`（shell 里 `$ENV_NAME`）读值。**不要**把值 `echo`/`cat`/`printenv` 到 stdout——那样会回流进模型上下文。子进程只输出结果（成功/失败/收据），不输出值本身。

### 3. 网页登录（浏览器自动化）

若 PATH 上有 `bitcoffer-login` 助手（仓库 `scripts/bitcoffer-login`）可用，由 `run_with_secret` 以 `node` 为 cmd 拉起，密码经 env 注入，自动填表并复用持久化 profile：

```
run_with_secret {
  secret: "<密码条目名>",
  cmd: "node",
  args: ["bitcoffer-login",
         "--url", "https://<site>/<login>",
         "--email", "<用户名>",
         "--password-env", "PASSWORD",
         "--smoke"],                       // 先 --smoke 冒烟验证字段能定位，再真登录
  env_name: "PASSWORD"
}
```

登录成功后会话 cookie 存在持久化 profile（默认 `~/.cache/bitcoffer-login/<site-slug>/`），后续同类任务可复用。脚本只输出 JSON 收据，不打印密码。运行前确认本机 playwright 已装。

### 4. 用户名从哪来

`get_secret_metadata` 常含登录用户名（bitcoffer 条目存了就用它），否则问用户。

### 5. secret 不在 bitcoffer 时 → 问用户

`list_secret_names` 查不到该凭据时，**不要猜值、不要编造**。问用户「这个凭据在哪？」（可能在别处、可能是手动的一次性流程）。

## Anti-patterns（禁止）

- ❌ 试图「读出」secret 值（bitcoffer 设计上无 reveal 工具；不要用 `run_with_secret` 跑 `echo $VAR` / `printenv` 之类把值打出来）
- ❌ 把密码硬编码进脚本/配置
- ❌ 让用户在聊天里粘贴密码（口令应以 env 注入方式直达子进程）
- ❌ 用 bare `bitcoffer` 二进制或错误的容器路径（会导致 AMFI/解锁失败）

## 附录：宿主配置

各宿主的 MCP 配置、粘贴步骤与工具命名前缀不同，以仓库 [`docs/agents/`](../../docs/agents/) 为准，不要在本 skill 里写死某一宿主的安装命令。
