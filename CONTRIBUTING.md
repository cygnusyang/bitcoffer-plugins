# Contributing

**English** | [简体中文](CONTRIBUTING.zh.md)

Thanks for taking the time. This repository is small on purpose: a launcher, a login helper, two skills and a set of host paste packs. Contributions that keep it small are the easiest to accept.

## What this repository is (and is not)

| This repo | Not this repo |
| --- | --- |
| The MCP launcher, the browser-login helper | The Bitcoffer application source (proprietary, not here) |
| Host-agnostic skills | A host-specific plugin marketplace listing |
| Paste-ready config for Claude Code, Cursor, Codex, WorkBuddy | A wrapper SDK or a client library |

If your change needs to modify the app to work, it belongs upstream, not here.

## Ways to help

- **Bug in a host config** — open an issue with the host, its version, and the exact snippet you pasted.
- **New host support** — see the checklist below.
- **Docs / translation drift** — an English file and its `简体中文` counterpart disagreeing is a bug. Report it.
- **Skill wording** — if an agent read the skill and still leaked a value or failed to find the vault, that is the most valuable report you can send. Include the transcript with secrets redacted.

## Language policy

English is the source of truth and the file a model loads. Every document also ships a full Simplified Chinese translation, not a summary:

- `X.md` → `X.zh.md`, same directory, same structure, same headings.
- Both files are updated **in the same pull request**. A change that touches only one side will be sent back.
- Each file carries a language switch line at the top: `**English** | [简体中文](X.zh.md)` and the mirror.
- `SKILL.zh.md` files carry **no YAML frontmatter**. Frontmatter would make a skill loader treat the same directory as two skills with the same name; the Chinese file is for humans.

## Changing the launcher or the login helper

No build step, no dependencies for the launcher (POSIX `sh`). Before opening a pull request:

```bash
shellcheck -s sh scripts/bitcoffer-launch.sh
node --check scripts/bitcoffer-login.mjs
cp scripts/bitcoffer-login /tmp/bitcoffer-login-shim.mjs && node --check /tmp/bitcoffer-login-shim.mjs
```

The last line is not a typo: `scripts/bitcoffer-login` is a Node ESM shim with no file extension — it has to be callable as `bitcoffer-login` on `PATH` — so `node --check` will parse it as CommonJS and choke on its `import`. Copying it to a `.mjs` name is the cheapest way to syntax-check it.

Then exercise the resolution order by hand — the cases that break in practice are the boring ones:

| Case | Expected |
| --- | --- |
| App installed, vault present | connects, `tools/list` returns 4 |
| `BITCOFFER_BIN` set to a wrong path | fails loudly, does not fall back silently |
| `BITCOFFER_VAULT_DIR` set to a stale vault | uses it, does not silently pick another |
| No app, no CLI on `PATH` | prints every path it checked, exits non-zero |
| Store build (no bundled helper) | explains that the CLI ships separately |

Verify the MCP surface end to end with the probe in [`docs/agents/README.md`](docs/agents/README.md#universal-smoke-test-toolslist--4) — expect exactly **4** tools.

## Adding a host

1. `docs/agents/<host>.md` + `docs/agents/<host>.zh.md`.
2. Follow the shape of an existing pack: prerequisites → config drop (exact file, exact snippet) → how to verify → how to uninstall.
3. Add the row to the host table in both `docs/agents/README.md` and `docs/agents/README.zh.md`.
4. Add the pair to the language index in both `README.md` and `README.zh.md`.
5. Never hard-code a machine path. Use `/Users/you/...` or `$HOME/...`.

## Rules that get a pull request rejected

- A secret value, a real token, a vault path or a licence key anywhere in the diff.
- A machine-specific absolute path (`/Users/<name>/...`), an internal hostname, or an internal repository URL.
- A host install command baked into a **skill**. Skills are host-agnostic; host commands live in `docs/agents/`.
- Docs that promise a feature the app does not have. If it is not shipped, it is not in the docs.

## Commits

[Conventional Commits](https://www.conventionalcommits.org/), one logical change per commit:

```
feat(launcher): resolve standalone CLI paths
fix(skill): stop suggesting printenv for debugging
docs(cursor): correct the config drop path
chore: relicense under MIT
```

## Licence

Contributions are accepted under the [MIT licence](LICENSE). By opening a pull request you confirm you have the right to submit the code under those terms.
