# Bitcoffer 凭据 —— 用密钥，不读密钥

[English](SKILL.md) | **简体中文**

> 本文件是 `SKILL.md` 的中文对照译文，供人阅读。智能体加载的是英文 `SKILL.md`；两者冲突以英文为准。

Bitcoffer 是集中托管密码与密钥的本地网关（数据不离开本机）。本技能说明如何通过这些由本机 Bitcoffer App 提供的 MCP 工具使用凭据——**核心规则是「用密钥，不读密钥」**：凭据值只注入子进程环境，绝不进入模型上下文。

下载：https://ai.cygnusyang.top/bitcoffer/

## 何时使用

任务需要密码、token 或 API key 时使用（登录站点、调用需要鉴权的 API、解密文件、执行需要凭据的命令等）。先来这里找，再问用户。

## 关键事实

- MCP 工具名遵循**协议名**（`list_secret_names` / `list_secrets` / `run_with_secret` / `get_secret_metadata`）。不同宿主可能加自己的前缀；按协议名调用工具，不要假设任何特定前缀。
- 连接本机 Bitcoffer MCP 服务，优先用本仓库的共用启动脚本 `scripts/bitcoffer-launch.sh`：连接时自动探测 App 内签名二进制与本机库。可用 `BITCOFFER_VAULT_DIR` / `BITCOFFER_BIN` 覆盖自动探测。
- 工具不可用或连接失败时：先走 `bitcoffer-setup` 技能（App 装了没、是否手动解锁过一次、库能否被探测到）。
- 解锁路径：**钥匙串托管自动解锁**——配置里没有口令。托管是**按机器、按用户**的，换新机器必须在 Bitcoffer App 里先手动解锁一次。bitcoffer 必须从 App 内路径运行（裸二进制会因签名 / 钥匙串上下文失败）。
- 若登录工具在 PATH 上（本仓库的 `scripts/bitcoffer-login`），可以用它做自动浏览器登录。新机器先装 playwright：`npm i -g playwright && npx playwright install chromium`（脚本会自动解析它）。

## 可用工具（精确 schema）

| 工具 | 参数 | 返回 |
|---|---|---|
| `list_secret_names` | `{ vault? }` | 全部密钥名称（**绝不返回值**） |
| `list_secrets` | `{ vault? }` | 密钥元数据（name、id、category、updated_at；**绝不返回值**） |
| `run_with_secret` | `{ secret(必填), cmd(必填), args[], cwd?, env_name? }` | 把密钥注入子进程环境并执行命令；**绝不返回值** |
| `get_secret_metadata` | `{ secret(必填) }` | 只读元数据；**含登录用户名**（若该 bitcoffer 条目存了） |

## 工作流

### 1. 查（确认密钥存在并记下准确名称）

```
list_secret_names {}
```

名称可能和你想的不一样（中文名、带域名后缀等）。**用返回的那个名字。**

### 2. 用（把值注入子进程，绝不进上下文）

```
run_with_secret {
  secret: "<步骤 1 得到的名字>",
  cmd: "<可执行文件>",
  args: ["...", "--password-env", "ENV_NAME"],
  env_name: "ENV_NAME"   // 默认等于密钥名；显式给个短名更可靠
}
```

子进程从 `process.env.ENV_NAME`（shell 里是 `$ENV_NAME`）读取该值。**不要**把它 `echo` / `cat` / `printenv` 到 stdout——那会回流进模型上下文。子进程只输出结果（成功 / 失败 / 回执），绝不输出值本身。

### 3. 网页登录（浏览器自动化）

如果 `bitcoffer-login` 在 PATH 上（本仓库的 `scripts/bitcoffer-login`），用 `run_with_secret` 以 `node` 为 cmd 启动它。口令通过环境变量注入；helper 填表并复用持久化 profile：

```
run_with_secret {
  secret: "<口令条目名>",
  cmd: "node",
  args: ["bitcoffer-login",
         "--url", "https://<site>/<login>",
         "--email", "<username>",
         "--password-env", "PASSWORD",
         "--smoke"],                       // 先用 --smoke 验证字段能定位，再做真实登录
  env_name: "PASSWORD"
}
```

登录成功后会话 cookie 存在持久化 profile 里（默认 `~/.cache/bitcoffer-login/<site-slug>/`），同类任务后续可复用。脚本只打印 JSON 回执，不打印口令。运行前确认本机装了 playwright。

### 4. 用户名从哪来

`get_secret_metadata` 常含登录用户名（若该 bitcoffer 条目存了就用它）；否则问用户。

### 5. 库里没有这条密钥 → 问用户

`list_secret_names` 找不到该凭据时，**不要猜值、不要编造**。问用户这条凭据在哪（可能在别处，也可能是一次性人工流程）。

## 反模式（禁止）

- ❌ 试图"读出"密钥值（bitcoffer 按设计没有 reveal 工具；也不要用 `run_with_secret` 跑 `echo $VAR` / `printenv` 之类把值打出来）
- ❌ 把口令硬编码进脚本或配置
- ❌ 让用户在聊天里贴口令（密钥只应通过环境变量注入到达子进程）
- ❌ 使用裸 `bitcoffer` 二进制或错误的容器路径（会导致 AMFI / 解锁失败）

## 附录：宿主配置

MCP 配置、粘贴步骤与工具名前缀因宿主而异。按本仓库的 [`docs/agents/`](../../docs/agents/README.zh.md) 走；不要在本技能里硬编码某个宿主的安装命令。
