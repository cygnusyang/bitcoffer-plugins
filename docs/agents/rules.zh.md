# Bitcoffer 规则片段（粘贴进宿主的规则文件）

[English](rules.md) | **简体中文**

核心规则：**用密钥，不读密钥** —— 密钥只能经 `run_with_secret` 注入子进程环境，绝不允许进入模型上下文。

```markdown
## Bitcoffer 凭据

- 需要密码 / API key / token 时，先用 `list_secret_names`（或 `list_secrets`）确认准确名称。
- **只用 `run_with_secret`** 把值注入子进程环境（`env_name`），不要用任何工具去"读"密钥值。
- **不要**在命令里 echo / printenv（或任何把值打到 stdout/stderr 的写法）——那会回流进上下文。
- 子进程只应输出成功 / 失败 / 回执，绝不能输出密钥本身。
- `get_secret_metadata` 返回只读元数据（可能含用户名），不包含密钥值。
- 如果库里没有这条凭据，问用户；不要猜测或编造值。
```
