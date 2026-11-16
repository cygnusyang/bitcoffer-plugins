# Security Policy

**English** | [简体中文](SECURITY.zh.md)

Bitcoffer holds passwords, API keys and tokens. Anything that makes a secret value reach a place it should not — the model context, a log file, shell history, a child process of a command you did not ask for — is treated as a vulnerability, not a bug report.

## Design invariants

These are the guarantees this repository claims. A way to break one of them is a vulnerability:

1. **No reveal path.** There is no tool, flag or environment variable that returns a secret value. `list_secret_names`, `list_secrets` and `get_secret_metadata` return names and metadata only.
2. **Values reach a subprocess only through its environment**, and only for a command the user explicitly asked to run via `run_with_secret`.
3. **No network.** The MCP server speaks JSON-RPC over stdio. It opens no TCP/UDP listener and makes no outbound connection.
4. **No cloud.** The vault is a local encrypted file. There is no account, no sync and no telemetry.

## Reporting a vulnerability

- **Preferred:** [private vulnerability reporting](https://github.com/cygnusyang/bitcoffer-plugins/security/advisories/new) on this repository.
- **Alternative:** email <ruohuyang@163.com> with `BITCOFFER SECURITY` in the subject.
- **Do not open a public issue** for a vulnerability, and do not include a real secret in a report. Redact values; describe their shape instead.

A useful report contains:

| Field | What to include |
| --- | --- |
| Component | Launcher, login helper, a skill, a host config snippet, or the app itself |
| Version | Repository tag/commit, and the Bitcoffer app version if relevant |
| Environment | macOS version, chip, MCP host (Claude Code / Cursor / Codex / WorkBuddy / other) |
| Reproduction | Steps, or a minimal script with secrets replaced by placeholders |
| Impact | Which invariant above is broken, and whether a value was disclosed |

## Scope

**In scope**

- `scripts/bitcoffer-launch.sh` — path resolution, environment handling, argument forwarding
- `scripts/bitcoffer-login` and `scripts/bitcoffer-login.mjs` — how the password is passed, logged, or persisted
- `skills/**` — instructions that could lead an agent to leak a value
- `docs/agents/**` — config snippets that would put a secret in a file that is read back, committed, or logged
- The Bitcoffer application itself (same reporting channel)

**Out of scope**

- Vulnerabilities in a host application (Claude Code, Cursor, Codex, WorkBuddy) — report those upstream
- An attacker who already has your logged-in user account, full disk access, or your unlocked keychain; the design does not defend against that
- Malicious MCP servers you installed on purpose
- Social engineering of the maintainer

## Threat model, stated plainly

Bitcoffer protects against **accidental and structural disclosure**: an agent that would otherwise `echo` a password into its context, a script that would otherwise hard-code a key, a config file that would otherwise be committed. It does **not** protect against code already running with your user privileges. Treat the Mac as the trust boundary.

## What to expect

- Acknowledgement within **3 business days**.
- An assessment (severity, affected versions, whether a fix is needed) within **10 business days**.
- Fix and coordinated disclosure for high-severity issues targeted at **30 days**. Low-severity documentation issues may ship with the next release.
- Credit in the advisory unless you ask to stay anonymous.

## Supported versions

Only the latest release tag receives security fixes. This repository is pre-1.0: pin to a tag and read [CHANGELOG.md](CHANGELOG.md) before upgrading.
