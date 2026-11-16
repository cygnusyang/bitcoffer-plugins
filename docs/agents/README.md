# Bitcoffer · AI host paste packs

**English** | [简体中文](README.zh.md)

Paste-ready MCP config for four hosts, all pointing at the same launcher.

> Goal: paste → connect → `tools/list` shows **4** tools:
> `list_secret_names`, `list_secrets`, `run_with_secret`, `get_secret_metadata`.
> Security: Use Secret, not Read Secret. Never echo a secret.
> Out of scope: MCP marketplace listings; host completion hooks.

Every pack follows the same six sections: launcher config, explicit-binary fallback, rules, acceptance, uninstall, troubleshooting.

## Prerequisites

1. Bitcoffer.app installed on macOS (this is macOS-only — the app, the helper and the launcher).
2. The app unlocked **once** on this machine, with **Settings → MCP / Agent collaboration → MCP unlock escrow** enabled. Escrow is per machine and per user; without it the server cannot unlock the vault in the background.
3. The launcher at `~/.bitcoffer/bitcoffer-launch.sh` (see the install section of the [README](../../README.md#install)).

You do **not** need to know your vault UUID. The launcher resolves it; `BITCOFFER_VAULT_DIR` only exists to override that.

## Hosts

| Host | Config drop | Rules file | Pack |
| --- | --- | --- | --- |
| Claude Code | `claude mcp add` or project `.mcp.json` | `CLAUDE.md` | [claude-code.md](claude-code.md) |
| Codex | `~/.codex/config.toml` | `AGENTS.md` | [codex.md](codex.md) |
| Cursor | `~/.cursor/mcp.json` | `AGENTS.md` / `.cursor/rules/` | [cursor.md](cursor.md) |
| WorkBuddy | `~/.workbuddy/mcp.json` (needs an explicit trust click) | `CODEBUDDY.md` / `AGENTS.md` | [workbuddy.md](workbuddy.md) |

Shared rules: [rules.md](rules.md). Shared skills: [`skills/`](../../skills/). Shared launcher: [`scripts/bitcoffer-launch.sh`](../../scripts/bitcoffer-launch.sh).

## Canonical binary, for the fallback configs

```
/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer
```

(`~/.bitcoffer/bin/bitcoffer` usually symlinks here.) App Store and TestFlight builds bundle no helper — on those, install the standalone CLI and use `~/.bitcoffer/libexec/bitcoffer.app/Contents/MacOS/bitcoffer`.

## Universal smoke test (`tools/list` = 4)

No host involved. Save as `~/.bitcoffer/tools-list-probe.py` and run:

```bash
python3 ~/.bitcoffer/tools-list-probe.py
```

```python
#!/usr/bin/env python3
"""Connect to the bitcoffer MCP server and assert it exposes exactly 4 tools."""
import json, os, pathlib, subprocess, sys

launcher = pathlib.Path.home() / ".bitcoffer" / "bitcoffer-launch.sh"
if not launcher.exists():
    sys.exit(f"launcher not found: {launcher}")

frames = [
    {"jsonrpc": "2.0", "id": 1, "method": "initialize",
     "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                "clientInfo": {"name": "probe", "version": "0"}}},
    {"jsonrpc": "2.0", "method": "notifications/initialized"},
    {"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}},
]
payload = "".join(json.dumps(f) + "\n" for f in frames)

proc = subprocess.run([str(launcher)], input=payload, text=True,
                      capture_output=True, env=dict(os.environ), timeout=60)

names = []
for line in proc.stdout.splitlines():
    try:
        msg = json.loads(line)
    except json.JSONDecodeError:
        continue
    if msg.get("id") == 2:
        names = [t["name"] for t in msg["result"]["tools"]]

expected = {"list_secret_names", "list_secrets", "run_with_secret", "get_secret_metadata"}
print(f"{len(names)} tools: {', '.join(sorted(names)) or '(none)'}")
if set(names) != expected:
    sys.exit(f"FAIL — expected {sorted(expected)}\nlauncher stderr:\n{proc.stderr}")
print("OK")
```

Expected: exactly the 4 tools listed above. Anything else means the launcher did not reach the vault — its stderr names every path it checked.

To test an explicit binary instead of the launcher, set `BITCOFFER_BIN` and `BITCOFFER_VAULT_DIR` in the environment before running the probe; the launcher forwards both.
