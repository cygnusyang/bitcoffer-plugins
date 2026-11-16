// Unit tests for the pure helpers in scripts/bitcoffer-login.mjs.
// No browser or playwright required.
import test from 'node:test';
import assert from 'node:assert/strict';
import { parseArgs, fieldsSatisfied, resolvePassword, DEFAULTS } from '../scripts/bitcoffer-login.mjs';

test('parseArgs: space-separated flag values', () => {
  assert.deepEqual(
    parseArgs(['--url', 'https://example.com', '--password-env', 'PASSWORD']),
    { url: 'https://example.com', 'password-env': 'PASSWORD' },
  );
});

test('parseArgs: --flag=value form', () => {
  assert.deepEqual(
    parseArgs(['--url=https://example.com', '--headless']),
    { url: 'https://example.com', headless: true },
  );
});

test('parseArgs: bare flags are boolean', () => {
  assert.deepEqual(
    parseArgs(['--smoke', '--close']),
    { smoke: true, close: true },
  );
});

test('parseArgs: a value that looks like a flag is not consumed', () => {
  // A following `--x` must not be eaten as the value of the previous flag.
  assert.deepEqual(
    parseArgs(['--url', '--smoke']),
    { url: true, smoke: true },
  );
});

test('fieldsSatisfied: smoke mode requires both fields', () => {
  assert.equal(fieldsSatisfied({ smoke: true }, { email: true, password: true }).ok, true);
  assert.equal(fieldsSatisfied({ smoke: true }, { email: false, password: true }).ok, false);
  assert.equal(fieldsSatisfied({ smoke: true }, { email: true, password: false }).ok, false);
});

test('fieldsSatisfied: fill mode only requires email when --email is given', () => {
  assert.equal(fieldsSatisfied({ email: 'a@b.c' }, { email: true, password: true }).ok, true);
  assert.equal(fieldsSatisfied({ email: 'a@b.c' }, { email: false, password: true }).ok, false);
  assert.equal(fieldsSatisfied({}, { email: false, password: true }).ok, true);
  assert.equal(fieldsSatisfied({}, { email: true, password: false }).ok, false);
});

test('fieldsSatisfied: exposes which fields are missing', () => {
  const r = fieldsSatisfied({ email: 'a@b.c' }, { email: false, password: true });
  assert.equal(r.ok, false);
  assert.equal(r.passwordOk, true);
  assert.equal(r.emailOk, false);
  assert.equal(r.emailRequired, true);
});

test('resolvePassword: smoke runs need no password', () => {
  assert.deepEqual(resolvePassword({ smoke: true }), { ok: true, password: '' });
});

test('resolvePassword: refuses a blank or unset password', () => {
  delete process.env.BT_TEST_PW;
  const r = resolvePassword({ 'password-env': 'BT_TEST_PW' });
  assert.equal(r.ok, false);
  assert.match(r.error, /BT_TEST_PW/);
});

test('resolvePassword: accepts a set password without echoing it', () => {
  process.env.BT_TEST_PW = 'hunter2';
  assert.deepEqual(
    resolvePassword({ 'password-env': 'BT_TEST_PW' }),
    { ok: true, password: 'hunter2' },
  );
  delete process.env.BT_TEST_PW;
});

test('DEFAULTS: success wait is independent of per-operation timeout', () => {
  assert.ok(DEFAULTS.successWaitMs > DEFAULTS.opTimeoutMs);
  assert.equal(typeof DEFAULTS.successWaitMs, 'number');
  assert.equal(typeof DEFAULTS.opTimeoutMs, 'number');
});
