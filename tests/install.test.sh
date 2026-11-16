#!/usr/bin/env sh
# End-to-end install/uninstall check for the Bitcoffer cask.
#
# This test installs the real cask, verifies it lands, uninstalls it with
# --zap, and verifies nothing is left behind — while the vault (user data)
# survives, as the cask's caveats promise.
#
# It is destructive to any existing Bitcoffer install, so it refuses to run
# on a machine that already has /Applications/Bitcoffer.app. Run it in a
# throwaway macOS environment; .github/workflows/install-check.yml does that.

set -eu

APP="/Applications/Bitcoffer.app"
CASK="cygnusyang/bitcoffer/bitcoffer"
VAULT="$HOME/.bitcoffer/vaults/install-test-keep"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "ok: $1"; }

command -v brew >/dev/null 2>&1 || fail "brew not found"
[ "$(uname -s)" = "Darwin" ] || fail "macOS-only test"

# --- preflight: refuse to touch a working install -------------------------
[ ! -e "$APP" ] || fail "$APP already exists — refusing to touch a working install; run this in a throwaway environment"
if brew list --cask 2>/dev/null | grep -qx bitcoffer; then
  fail "the bitcoffer cask is already registered — refusing to run"
fi
pass "preflight: no existing Bitcoffer install"

# Plant a vault so we can prove --zap preserves user data (cask caveat).
mkdir -p "$VAULT"
echo sentinel > "$VAULT/sentinel"

# --- install --------------------------------------------------------------
brew install --cask "$CASK" || fail "brew install --cask failed"
[ -d "$APP" ] || fail "app not installed at $APP"
[ -f "$APP/Contents/Info.plist" ] || fail "app bundle looks invalid (no Info.plist)"
pass "install: app landed at $APP"

# --- uninstall ------------------------------------------------------------
brew uninstall --cask --zap bitcoffer || fail "brew uninstall --cask --zap failed"
pass "uninstall: completed"

# --- assert clean ---------------------------------------------------------
check_gone() { [ ! -e "$1" ] || fail "left behind after uninstall: $1"; }

check_gone "$APP"
check_gone "$HOME/Library/Caches/top.cygnusyang.coffer"
check_gone "$HOME/Library/Preferences/top.cygnusyang.coffer.plist"
check_gone "$HOME/Library/Saved Application State/top.cygnusyang.coffer.savedState"
check_gone "$(brew --prefix)/Caskroom/bitcoffer"
pass "assert: app, zap paths and Caskroom are gone"

if brew list --cask 2>/dev/null | grep -qx bitcoffer; then
  fail "cask still registered after uninstall"
fi
pass "assert: cask is no longer registered"

[ -d "$VAULT" ] || fail "vault was removed by --zap (cask caveats say it must be kept)"
[ -f "$VAULT/sentinel" ] || fail "vault contents were removed by --zap"
pass "assert: vault preserved as documented"

echo "install/uninstall test passed"
