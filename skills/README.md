# Bitcoffer shared skills

This directory is the **single source** for host-agnostic Bitcoffer skills (also the tree a skill registry should package). Do not fork these bodies per host.

| Skill | Purpose |
| --- | --- |
| [bitcoffer-credentials](bitcoffer-credentials/SKILL.md) | Use secrets via MCP (`run_with_secret`) without reading values into the model context |
| [bitcoffer-setup](bitcoffer-setup/SKILL.md) | Diagnose / repair the local Bitcoffer MCP connection |

Host-specific MCP configuration and paste steps live in [`docs/agents/`](../docs/agents/). Skill bodies and appendices point at that directory; they do not hard-code host names.

Shared tools used with these skills:

- [`scripts/bitcoffer-launch.sh`](../scripts/bitcoffer-launch.sh) — resolve the app-signed binary and the local vault, then start the MCP server
- [`scripts/bitcoffer-login`](../scripts/bitcoffer-login) — browser-login driver; the password arrives only via an env var from `run_with_secret`

Download the Bitcoffer app: https://ai.cygnusyang.top/bitcoffer/
