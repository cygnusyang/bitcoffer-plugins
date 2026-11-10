# Bitcoffer rules snippet (paste into the host's rules file)

Core rule: **Use Secret, not Read Secret** — secrets are injected into a subprocess environment only via `run_with_secret`, and must never enter the model context.

```markdown
## Bitcoffer credentials

- When you need a password / API key / token, first use `list_secret_names` (or `list_secrets`) to confirm the exact name.
- **Only use `run_with_secret`** to inject the value into the subprocess environment (`env_name`); do not use any tool to "read" a secret value.
- **Do not** echo / printenv (or any other form that prints the value to stdout/stderr) in the command — that would flow back into the context.
- The subprocess should only print success / failure / a receipt, never the secret itself.
- `get_secret_metadata` returns read-only metadata (it may include a username) and does not include the secret value.
- If the vault does not have that credential, ask the user; do not guess or invent a value.
```
