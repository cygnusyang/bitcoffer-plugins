#!/usr/bin/env sh
# bitcoffer-mcp-setup.sh — register the bitcoffer MCP server for Claude Code on THIS machine.
#
# The bitcoffer MCP registration is user-scoped and machine-specific (it bakes in
# the bitcoffer binary path and the vault directory), so it must be re-run on every
# new Mac / new user. This script auto-detects everything that varies:
#
#   - the Bitcoffer App helper binary (the ONLY binary that unlocks via Keychain)
#   - the vault directory under the Bitcoffer app container
#
# and then runs `claude mcp add bitcoffer --scope user`.
#
# One-time use on a new machine:
#   sh plugins/claude-code/scripts/bitcoffer-mcp-setup.sh   # from the bitcoffer repo root
#   bitcoffer-setup                                          # PATH shim while the plugin is enabled
#
# Overrides (set as env before running):
#   BITCOFFER_BIN         path to a bitcoffer binary (default: the App helper under /Applications)
#   BITCOFFER_VAULT_DIR   path to a vault directory (default: newest vault in the app container)
#
# Per-machine prerequisites:
#   1. The Bitcoffer app installed (or BITCOFFER_BIN pointing at a working binary).
#   2. The vault unlocked ONCE via the Bitcoffer app — Keychain escrow is per
#      machine + per user; until then the MCP cannot unlock without a password.
#   3. For the browser-login script only: `npm i -g playwright` + `npx playwright install chromium`.

set -eu

# --- 1. locate the bitcoffer binary -------------------------------------------
if [ -n "${BITCOFFER_BIN:-}" ]; then
  BIN="$BITCOFFER_BIN"
elif [ -x /Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer ]; then
  BIN=/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer
else
  echo "✗ bitcoffer binary not found. Install the Bitcoffer app, or set BITCOFFER_BIN." >&2
  exit 1
fi
echo "✓ bitcoffer binary: $BIN"

# --- 2. locate the vault -----------------------------------------------------
CONTAINER="$HOME/Library/Containers/app.coffer.Coffer/Data/Documents/Bitcoffer"
if [ -n "${BITCOFFER_VAULT_DIR:-}" ]; then
  VAULT="${BITCOFFER_VAULT_DIR%/}"
else
  # Newest-modified vault wins when there are several.
  VAULT="$(ls -dt "$CONTAINER"/*/ 2>/dev/null | head -n 1)"
  if [ -z "$VAULT" ]; then
    echo "✗ no vault found under $CONTAINER." >&2
    echo "  Unlock the Bitcoffer app once on this machine, or set BITCOFFER_VAULT_DIR." >&2
    exit 1
  fi
  VAULT="${VAULT%/}"
fi
echo "✓ vault:        $VAULT"

# --- 3. register -------------------------------------------------------------
if ! command -v claude >/dev/null 2>&1; then
  echo "✗ claude CLI not found on PATH — is Claude Code installed?" >&2
  exit 1
fi

# Idempotent: `claude mcp add` errors out if the server already exists, so
# remove first when re-running on a machine that was already set up.
if claude mcp list 2>/dev/null | grep -q '^bitcoffer:'; then
  echo "! bitcoffer already registered — re-registering with the detected values."
  # 清除旧手动注册（主仓 README 的 `claude mcp add`）遗留的 local 作用域条目
  claude mcp remove bitcoffer >/dev/null 2>&1 || true
  claude mcp remove bitcoffer --scope user >/dev/null 2>&1 || true
fi

if ! claude mcp add bitcoffer --scope user --env "BITCOFFER_VAULT_DIR=$VAULT" -- "$BIN" mcp --provider bitcoffer; then
  echo "✗ claude mcp add 失败——可能存在其他作用域的同名 bitcoffer 条目，运行 claude mcp list 查看并手动清理后重试。" >&2
  exit 1
fi

echo
echo "✓ registered. Status:"
claude mcp list 2>&1 | grep '^bitcoffer' || true
echo
echo "Note: Keychain escrow is per-machine — the MCP unlocks with no password only"
echo "after the Bitcoffer app has been unlocked once on this machine."
