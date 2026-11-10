---
name: bitcoffer-setup
description: Diagnose and repair the Bitcoffer MCP connection — run when Bitcoffer tools are missing, the server fails to connect, or on a brand-new machine/first run
---

# Bitcoffer Setup — Diagnose and repair the bitcoffer MCP connection

Use this skill when Bitcoffer MCP tools are missing, the server fails to connect, or you are using bitcoffer for the first time on a new machine. Work through the checks in order; that is the fastest way to hit the root cause.

Download: https://ai.cygnusyang.top/bitcoffer/

## Diagnostic order

### 1. Three prerequisites

**a. The Bitcoffer App is installed (the embedded helper is required)**:

```
test -x /Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer && echo OK || echo MISSING
```

If missing → tell the user to install the Bitcoffer App from https://ai.cygnusyang.top/bitcoffer/, then come back.

**b. A vault already exists**:

The documented local vault directory is `~/.bitcoffer/vaults/` (UUID subdirectories underneath):

```
ls "$HOME/.bitcoffer/vaults/"
```

If empty → tell the user to open the Bitcoffer App and create or unlock a vault once. To override detection, set `BITCOFFER_VAULT_DIR` to a specific vault directory (`~/.bitcoffer/vaults/<uuid>`).

**c. Keychain escrow already exists (this machine has been unlocked once)**:

Escrow is per machine, per user. The most direct check: try connecting with the shared launch script `scripts/bitcoffer-launch.sh` and look in the logs for `vault unlocked via MCP keychain escrow`. If it reports that MCP 解锁托管 (*MCP unlock escrow*) is not enabled → tell the user: App Settings → MCP / Agent 协作 (*MCP / Agent collaboration*) → enable "MCP 解锁托管" (*MCP unlock escrow*), and unlock once.

### 2. Launch script and overrides

Prefer pointing the host's MCP `command` at the shared script `scripts/bitcoffer-launch.sh` (it auto-detects the App-signed binary and the local vault on connect). You usually do not need to write paths by hand; override with environment variables when needed:

- `BITCOFFER_BIN` — set the bitcoffer binary
- `BITCOFFER_VAULT_DIR` — set a specific vault directory

bitcoffer must run from the in-App path; a bare binary on PATH may fail because of signing / Keychain context.

## Done when

- The bitcoffer MCP server is connected in the host, and the protocol tools are available: `list_secret_names` / `list_secrets` / `run_with_secret` / `get_secret_metadata` (4 in total; **values are still never returned**).
- `list_secret_names` returns a list of names.

If all of the above pass and it still will not connect, give the host's MCP connection status and the launch logs to the user / report them.

## Appendix: host configuration

How each host registers MCP and how to check the connection status is documented in [`docs/agents/`](../../docs/agents/) in this repo. Do not hard-code any one host's CLI commands in this skill.
