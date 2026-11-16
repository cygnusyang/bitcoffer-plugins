#!/usr/bin/env sh
# bitcoffer-launch.sh — zero-config launcher for the bitcoffer MCP server.
#
# Bitcoffer needs a per-machine BITCOFFER_VAULT_DIR (fail-closed if missing) and must
# run from an App-signed binary. This wrapper resolves both at connect time so a host
# can start the MCP server with zero per-user config once the Bitcoffer app is
# installed and unlocked once on that machine.
#
# Resolution order:
#   binary:  $BITCOFFER_BIN
#            → Developer ID build's bundled CLI
#              (/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer)
#            → standalone CLI (App Store builds do not bundle one)
#              ($HOME/.bitcoffer/libexec/bitcoffer.app/Contents/MacOS/bitcoffer,
#               $HOME/.bitcoffer/bin/bitcoffer)
#            → bitcoffer on PATH (warn)
#   vault:   $BITCOFFER_VAULT_DIR → ~/.bitcoffer/vaults/active-vault pointer
#            → newest vault dir under ~/.bitcoffer/vaults
#
# Any extra argv is forwarded to `bitcoffer mcp` unchanged.

set -eu

HELPER_BIN="/Applications/Bitcoffer.app/Contents/Helpers/bitcoffer.app/Contents/MacOS/bitcoffer"
STANDALONE_APP_BIN="$HOME/.bitcoffer/libexec/bitcoffer.app/Contents/MacOS/bitcoffer"
STANDALONE_LINK="$HOME/.bitcoffer/bin/bitcoffer"
VAULT_ROOT="$HOME/.bitcoffer/vaults"

# --- 1. locate the bitcoffer binary -------------------------------------------
if [ -n "${BITCOFFER_BIN:-}" ]; then
  if [ -x "$BITCOFFER_BIN" ]; then
    BIN="$BITCOFFER_BIN"
  else
    echo "[bitcoffer-launch] \$BITCOFFER_BIN is set to '$BITCOFFER_BIN' but it is not executable. Unset it or fix the path." >&2
    exit 1
  fi
elif [ -x "$HELPER_BIN" ]; then
  BIN="$HELPER_BIN"
elif [ -x "$STANDALONE_APP_BIN" ]; then
  BIN="$STANDALONE_APP_BIN"
elif [ -x "$STANDALONE_LINK" ]; then
  BIN="$STANDALONE_LINK"
elif command -v bitcoffer >/dev/null 2>&1; then
  BIN="$(command -v bitcoffer)"
  echo "[bitcoffer-launch] warning: using bare 'bitcoffer' on PATH — signature/Keychain escrow may fail; prefer the app-signed binary" >&2
else
  {
    echo "[bitcoffer-launch] no usable bitcoffer CLI found. Checked:"
    echo "  \$BITCOFFER_BIN (unset)"
    echo "  $HELPER_BIN"
    echo "  $STANDALONE_APP_BIN"
    echo "  $STANDALONE_LINK"
    echo "  bitcoffer on PATH (not found)"
    if [ -L "$STANDALONE_LINK" ] && [ ! -e "$STANDALONE_LINK" ]; then
      echo ""
      echo "  $STANDALONE_LINK is a dangling symlink -> $(readlink "$STANDALONE_LINK" 2>/dev/null || echo '(unreadable)')"
      echo "  It points at a CLI that no longer exists (e.g. left over from a Developer ID"
      echo "  install replaced by an App Store build). Re-install the standalone CLI."
    fi
    if [ -d /Applications/Bitcoffer.app ] && [ ! -d /Applications/Bitcoffer.app/Contents/Helpers ]; then
      echo ""
      echo "  /Applications/Bitcoffer.app is installed but bundles no CLI. That is normal for"
      echo "  Mac App Store / TestFlight builds: the sandbox forbids non-sandboxed helpers, so"
      echo "  the CLI ships separately. Download bitcoffer-cli-<version>.tar.gz from the GitHub"
      echo "  releases, run ./install.sh, then re-run this launcher."
    fi
  } >&2
  exit 1
fi

# --- 2. resolve the vault -----------------------------------------------------
# Canonical vault root is <home>/.bitcoffer/vaults (same as the app). Prefer the
# active-vault pointer, then the newest vault dir; $BITCOFFER_VAULT_DIR always wins.
if [ -z "${BITCOFFER_VAULT_DIR:-}" ]; then
  VAULT=""
  if [ -f "$VAULT_ROOT/active-vault" ]; then
    ACTIVE="$(tr -d '[:space:]' < "$VAULT_ROOT/active-vault")"
    case "$ACTIVE" in
      # Accept only a bare directory name; reject path separators and traversal
      # so a malformed pointer cannot escape $VAULT_ROOT.
      */*|*..*) : ;;
      *) [ -n "$ACTIVE" ] && [ -d "$VAULT_ROOT/$ACTIVE" ] && VAULT="$VAULT_ROOT/$ACTIVE" ;;
    esac
  fi
  if [ -z "$VAULT" ]; then
    # Vault directories are UUIDs created by the app, so `ls` is safe here;
    # a find/xargs dance would be longer and no more correct.
    # shellcheck disable=SC2012
    VAULT="$(ls -dt "$VAULT_ROOT"/*/ 2>/dev/null | head -n 1)"
  fi
  if [ -z "$VAULT" ]; then
    echo "[bitcoffer-launch] no vault found under $VAULT_ROOT. Open the Bitcoffer app and unlock or create a vault once on this machine, or set BITCOFFER_VAULT_DIR." >&2
    exit 1
  fi
  export BITCOFFER_VAULT_DIR="${VAULT%/}"
fi

exec "$BIN" mcp --provider bitcoffer "$@"
