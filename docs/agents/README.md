# Bitcoffer · AI host paste packs

Paste-ready MCP + rules for four hosts.

> Goal: copy → connect → `tools/list` shows **4** tools:
> `list_secret_names`, `list_secrets`, `run_with_secret`, `get_secret_metadata`.
> Security: Use Secret, not Read Secret. Never echo secrets.
> Not in scope: MCP marketplace listing; host completion hooks.

## Prerequisites

1. Bitcoffer.app installed under `/Applications`.
2. Unlock the app **once** on this Mac (Settings → MCP → enable MCP unlock escrow) so Keychain escrow exists.
3. Know your vault directory: `~/.bitcoffer/vaults/<uuid>`.

Canonical MCP binary (App Helpers; signed + Keychain context):

```
/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer
```

(`~/.bitcoffer/bin/bitcoffer` usually symlinks here.)

## Hosts

| Host | Config drop | Rules file | Page |
| --- | --- | --- | --- |
| Claude Code | `claude mcp add` or project `.mcp.json` | `CLAUDE.md` | [claude-code.md](claude-code.md) |
| Codex | `~/.codex/config.toml` | `AGENTS.md` | [codex.md](codex.md) |
| Cursor | `~/.cursor/mcp.json` | `AGENTS.md` / `.cursor/rules/` | [cursor.md](cursor.md) |
| WorkBuddy | `~/.workbuddy/mcp.json` | `CODEBUDDY.md` / `AGENTS.md` | [workbuddy.md](workbuddy.md) |

Shared rules: [rules.md](rules.md). Shared skills: [`skills/`](../../skills/). Shared MCP launcher: [`scripts/bitcoffer-launch.sh`](../../scripts/bitcoffer-launch.sh) (resolves the app-signed binary and local vault on connect).

## Universal smoke test (`tools/list` = 4)

Save as `/tmp/bitcoffer-tools-list-probe.py` and run:

```bash
export BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
export VAULT="$HOME/.bitcoffer/vaults/<your-uuid>"  # replace
python3 /tmp/bitcoffer-tools-list-probe.py
```

Probe script:

```python
import json, os, subprocess
bin_path = os.environ["BIN"]
vault = os.environ["VAULT"]
frames = [
    {"jsonrpc": "2.0", "id": 1, "method": "initialize",
     "params": {"protocolVersion": "2024-11-05", "capabilities": {},
               "clientInfo": {"name": "probe", "version": "0"}}},
    {"jsonrpc": "2.0", "method": "notifications/initialized"},
    {"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}},
]
payload = "".join(json.dumps(f) + chr(10) for f in frames)
env = {**os.environ, "BITCOFFER_VAULT_DIR": vault}
proc = subprocess.run([bin_path, "mcp", "--provider", "bitcoffer"],
                      input=payload, text=True, capture_output=True, env=env)
for line in proc.stdout.splitlines():
    line = line.strip()
    if not line:
        continue
    try:
        o = json.loads(line)
    except json.JSONDecodeError:
        continue
    if o.get("id") == 2:
        names = [t["name"] for t in o["result"]["tools"]]
        print(len(names), ", ".join(names))
```

Expect **4** tools listed above.
