#!/usr/bin/env sh
# bitcoffer-launch.sh — zero-config launcher for the bitcoffer MCP server.
#
# Bitcoffer needs a per-machine BITCOFFER_VAULT_DIR (fail-closed if missing) and must
# run from the App-signed binary. This wrapper resolves both at connect time so
# a host can start the MCP server with zero per-user config once the Bitcoffer app
# is installed and unlocked once on that machine.
#
# Resolution order:
#   binary:  $BITCOFFER_BIN → App helper under /Applications → bitcoffer on PATH (warn)
#   vault:   $BITCOFFER_VAULT_DIR → active-vault pointer → newest vault dir under ~/.bitcoffer/vaults
#
# Any extra argv is forwarded to `bitcoffer mcp` unchanged.

set -eu

# --- 1. locate the bitcoffer binary -------------------------------------------
if [ -n "${BITCOFFER_BIN:-}" ]; then
  BIN="$BITCOFFER_BIN"
elif [ -x /Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer ]; then
  BIN=/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer
elif command -v bitcoffer >/dev/null 2>&1; then
  BIN="$(command -v bitcoffer)"
  echo "[bitcoffer-launch] warning: using bare 'bitcoffer' on PATH — signature/Keychain escrow may fail; prefer the Bitcoffer app" >&2
else
  echo "[bitcoffer-launch] bitcoffer binary not found. Install the Bitcoffer app, or set BITCOFFER_BIN." >&2
  exit 1
fi

# --- 2. resolve the vault -----------------------------------------------------
# Canonical vault root is <home>/.bitcoffer/vaults (same as the app). Prefer the
# active-vault pointer, then the newest vault dir; $BITCOFFER_VAULT_DIR always wins.
if [ -z "${BITCOFFER_VAULT_DIR:-}" ]; then
  ROOT="$HOME/.bitcoffer/vaults"
  VAULT=""
  if [ -f "$ROOT/active-vault" ]; then
    ACTIVE="$(tr -d '[:space:]' < "$ROOT/active-vault")"
    [ -n "$ACTIVE" ] && [ -d "$ROOT/$ACTIVE" ] && VAULT="$ROOT/$ACTIVE"
  fi
  if [ -z "$VAULT" ]; then
    VAULT="$(ls -dt "$ROOT"/*/ 2>/dev/null | head -n 1)"
  fi
  if [ -z "$VAULT" ]; then
    echo "[bitcoffer-launch] no vault found under $ROOT. Unlock the Bitcoffer app once on this machine, or set BITCOFFER_VAULT_DIR." >&2
    exit 1
  fi
  export BITCOFFER_VAULT_DIR="${VAULT%/}"
fi

exec "$BIN" mcp --provider bitcoffer "$@"
