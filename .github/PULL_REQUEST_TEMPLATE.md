## What changed

<!-- One sentence. What behaviour is different after this pull request? -->

## Why

<!-- The problem this solves. If it is a bug, what was the symptom? -->

## Scope

- [ ] Launcher (`scripts/bitcoffer-launch.sh`)
- [ ] Login helper (`scripts/bitcoffer-login*`)
- [ ] Skill (`skills/`)
- [ ] Host config / paste pack (`docs/agents/`)
- [ ] Docs only

## Checklist

- [ ] English and Simplified Chinese files are updated **together** (`X.md` ↔ `X.zh.md`).
- [ ] No secret value, real token, vault path or licence key anywhere in the diff.
- [ ] No machine-specific path (`/Users/<name>/...`), internal hostname or internal repository URL.
- [ ] No host install command added to a skill; host commands stay in `docs/agents/`.
- [ ] `shellcheck -s sh scripts/bitcoffer-launch.sh` and `node --check scripts/bitcoffer-login.mjs` pass (if touched).
- [ ] The `tools/list` probe still returns exactly **4** tools (if the launcher or a config changed).
- [ ] `CHANGELOG.md` and `CHANGELOG.zh.md` have an entry under `[Unreleased]`.

## Verification

<!-- What you ran, and what you saw. Paste output, not a promise. -->
