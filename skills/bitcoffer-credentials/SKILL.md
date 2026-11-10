---
name: bitcoffer-credentials
description: Use centrally-managed secrets (passwords/API keys) via the Bitcoffer MCP server without ever reading secret values into the model context
---

# Bitcoffer Credentials — Use secrets, don't read them

Bitcoffer is a local gateway for centrally managed passwords and keys (data never leaves this machine). This skill explains how to use those credentials through the MCP tools provided by the local Bitcoffer App — the **core rule is "Use Secret, not Read Secret"**: credential values are injected only into a subprocess environment and must never enter the model context.

Download: https://ai.cygnusyang.top/bitcoffer/

## When to Use

Use this when a task needs a password, token, or API key (signing into a site, authenticating an API, decrypting a file, running a command that requires credentials, and so on). Look here first, before asking the user.

## Key facts

- MCP tool names follow the **protocol names** (`list_secret_names` / `list_secrets` / `run_with_secret` / `get_secret_metadata`). Different hosts may add their own prefixes; call tools by the protocol name and do not assume any particular prefix.
- To connect to the local Bitcoffer MCP server, prefer the shared launch script in this repo, `scripts/bitcoffer-launch.sh`: on connect it auto-detects the App-signed binary and the local vault. Override auto-detection with `BITCOFFER_VAULT_DIR` / `BITCOFFER_BIN`.
- If tools are unavailable or the connection fails: start with the `bitcoffer-setup` skill (is the App installed, has it been unlocked once, can the vault be detected).
- Unlock path: **Keychain escrow auto-unlock** — no password in the config. Escrow is **per machine, per user** — on a new machine you must first unlock once by hand in the Bitcoffer App. bitcoffer must run from the in-App path (a bare binary will fail because of signing / Keychain context).
- If a login helper is on PATH (this repo's `scripts/bitcoffer-login`), you can use it for automated browser logins. On a new machine install playwright first: `npm i -g playwright && npx playwright install chromium` (the script resolves it automatically).

## Available tools (exact schema)

| Tool | Parameters | Returns |
|---|---|---|
| `list_secret_names` | `{ vault? }` | Names of all secrets (**values are never returned**) |
| `list_secrets` | `{ vault? }` | Secret metadata (name, id, category, updated_at; **values are never returned**) |
| `run_with_secret` | `{ secret(required), cmd(required), args[], cwd?, env_name? }` | Inject the secret into the subprocess environment and run the command; **the value is never returned** |
| `get_secret_metadata` | `{ secret(required) }` | Read-only metadata; **includes the login username** (if the bitcoffer item stores one) |

## Workflow

### 1. Look up (confirm the secret exists and note the exact name)

```
list_secret_names {}
```

The name may not be what you expect (Chinese names, domain suffixes, and so on). **Use the name that is returned.**

### 2. Use (inject the value into a subprocess; it must never enter the context)

```
run_with_secret {
  secret: "<name from step 1>",
  cmd: "<executable>",
  args: ["...", "--password-env", "ENV_NAME"],
  env_name: "ENV_NAME"   // default = the secret name; an explicit short name is more reliable
}
```

The subprocess reads the value from `process.env.ENV_NAME` (`$ENV_NAME` in a shell). **Do not** `echo` / `cat` / `printenv` the value to stdout — that would flow back into the model context. The subprocess should only print a result (success / failure / a receipt), never the value itself.

### 3. Web login (browser automation)

If `bitcoffer-login` is on PATH (this repo's `scripts/bitcoffer-login`), launch it via `run_with_secret` with `node` as cmd. The password is injected through the environment; the helper fills the form and reuses a persistent profile:

```
run_with_secret {
  secret: "<password item name>",
  cmd: "node",
  args: ["bitcoffer-login",
         "--url", "https://<site>/<login>",
         "--email", "<username>",
         "--password-env", "PASSWORD",
         "--smoke"],                       // start with --smoke to verify fields can be located, then do a real login
  env_name: "PASSWORD"
}
```

After a successful login, session cookies live in the persistent profile (default `~/.cache/bitcoffer-login/<site-slug>/`) and can be reused for later tasks of the same kind. The script only prints a JSON receipt, never the password. Confirm playwright is installed on this machine before running.

### 4. Where the username comes from

`get_secret_metadata` often includes the login username (use it if the bitcoffer item stores one); otherwise ask the user.

### 5. If the secret is not in bitcoffer → ask the user

If `list_secret_names` does not find the credential, **do not guess the value and do not invent one**. Ask the user where this credential lives (it may be elsewhere, or it may be a one-off manual flow).

## Anti-patterns (forbidden)

- ❌ Trying to "read out" a secret value (bitcoffer has no reveal tool by design; do not use `run_with_secret` to run `echo $VAR` / `printenv` or similar to print the value)
- ❌ Hard-coding passwords into scripts or config
- ❌ Asking the user to paste a password in chat (the secret should reach the subprocess only via env injection)
- ❌ Using a bare `bitcoffer` binary or the wrong container path (this causes AMFI / unlock failures)

## Appendix: host configuration

MCP config, paste steps, and tool-name prefixes differ by host. Follow [`docs/agents/`](../../docs/agents/) in this repo; do not hard-code any one host's install command in this skill.
