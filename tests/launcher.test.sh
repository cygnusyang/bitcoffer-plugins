#!/usr/bin/env sh
# Behavioral tests for scripts/bitcoffer-launch.sh: resolution order and
# fail-closed behaviour, exercised with a fake HOME and fake binaries.
# No Bitcoffer app or macOS host is required.

set -eu

DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
LAUNCHER="$DIR/../scripts/bitcoffer-launch.sh"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "ok: $1"; }

# mock_bitcoffer <path> — write an executable CLI that records its argv and the
# vault env var into $MOCK_LOG_FILE.
mock_bitcoffer() {
  cat > "$1" <<'EOF'
#!/usr/bin/env sh
printf 'argv=%s\n' "$*" >> "$MOCK_LOG_FILE"
printf 'vault=%s\n' "${BITCOFFER_VAULT_DIR:-}" >> "$MOCK_LOG_FILE"
EOF
  chmod +x "$1"
}

# --- 1. BITCOFFER_BIN wins and argv is forwarded --------------------------
h="$TMPROOT/t1"; mkdir -p "$h/bin" "$h/.bitcoffer/vaults/uuid-1"
mock_bitcoffer "$h/bin/bitcoffer"
MOCK_LOG_FILE="$h/mock.log" HOME="$h" BITCOFFER_BIN="$h/bin/bitcoffer" "$LAUNCHER"
grep -q '^argv=mcp --provider bitcoffer$' "$h/mock.log" \
  || fail "1: argv was not forwarded as 'mcp --provider bitcoffer'"
pass "1: BITCOFFER_BIN honoured and argv forwarded"

# --- 2. BITCOFFER_BIN pointing at a bad path fails loudly -----------------
h="$TMPROOT/t2"; mkdir -p "$h"
if HOME="$h" BITCOFFER_BIN="/nonexistent/bitcoffer" "$LAUNCHER" 2>"$h/err"; then
  fail "2: expected non-zero exit for a non-executable BITCOFFER_BIN"
fi
grep -q 'not executable' "$h/err" || fail "2: expected a 'not executable' diagnostic"
pass "2: bad BITCOFFER_BIN fails loudly"

# --- 3. STANDALONE_LINK resolves, active-vault pointer wins over newest ----
h="$TMPROOT/t3"
mkdir -p "$h/.bitcoffer/bin" "$h/.bitcoffer/vaults/uuid-old" "$h/.bitcoffer/vaults/uuid-new"
mock_bitcoffer "$h/.bitcoffer/bin/bitcoffer"
printf 'uuid-old\n' > "$h/.bitcoffer/vaults/active-vault"
# Make uuid-new newer; the active-vault pointer must still win.
touch "$h/.bitcoffer/vaults/uuid-new"
MOCK_LOG_FILE="$h/mock.log" HOME="$h" "$LAUNCHER"
grep -q "vault=$h/.bitcoffer/vaults/uuid-old" "$h/mock.log" \
  || fail "3: active-vault pointer did not win over the newest vault"
pass "3: standalone link resolved and active-vault pointer honoured"

# --- 4. a traversal pointer is rejected, falling back to newest -----------
h="$TMPROOT/t4"
mkdir -p "$h/.bitcoffer/bin" "$h/.bitcoffer/vaults/uuid-fallback"
mock_bitcoffer "$h/.bitcoffer/bin/bitcoffer"
printf '../../etc\n' > "$h/.bitcoffer/vaults/active-vault"
MOCK_LOG_FILE="$h/mock.log" HOME="$h" "$LAUNCHER"
grep -q "vault=$h/.bitcoffer/vaults/uuid-fallback" "$h/mock.log" \
  || fail "4: traversal pointer was not rejected (vault escaped the root)"
pass "4: malformed active-vault pointer rejected"

# --- 5. no vault fails loudly ---------------------------------------------
h="$TMPROOT/t5"; mkdir -p "$h/bin"
mock_bitcoffer "$h/bin/bitcoffer"
if MOCK_LOG_FILE="$h/mock.log" HOME="$h" BITCOFFER_BIN="$h/bin/bitcoffer" "$LAUNCHER" 2>"$h/err"; then
  fail "5: expected non-zero exit when no vault exists"
fi
grep -q 'no vault found' "$h/err" || fail "5: expected a 'no vault found' diagnostic"
pass "5: missing vault fails loudly"

echo "launcher tests passed"
