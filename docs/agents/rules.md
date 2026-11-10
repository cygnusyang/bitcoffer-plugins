# Bitcoffer 规则片段（粘贴进宿主规则文件）

核心纪律：**Use Secret, not Read Secret**——密钥只经 `run_with_secret` 注入子进程环境，永不进入模型上下文。

```markdown
## Bitcoffer 凭据

- 需要密码 / API key / token 时，先用 `list_secret_names`（或 `list_secrets`）确认准确名字。
- **只用 `run_with_secret`** 把值注入子进程环境（`env_name`）；不要用任何工具「读取」密钥值。
- **禁止**在命令里 echo / printenv 等会把值打到 stdout/stderr 的写法——那会回流进上下文。
- 子进程只输出成功/失败/收据，不输出密钥本身。
- `get_secret_metadata` 只读元数据（可含用户名），不含密钥值。
- 库里没有该凭据时问用户，禁止猜值或编造。
```
