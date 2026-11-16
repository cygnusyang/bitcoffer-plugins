#!/usr/bin/env node
// bitcoffer-login.mjs — browser-login driver for bitcoffer's `run_with_secret`.
//
// The password reaches this process ONLY through an env var (--password-env);
// it never appears in argv, stdout, stderr, or logs, so it never enters
// the model context. This script fills a login form and (optionally) submits
// it in a persistent Chromium profile so the session survives future runs.
//
// Modes:
//   smoke:  --smoke            navigate, locate fields, report; no fill/submit
//   filled: --no-submit        fill fields but leave the submit to a human
//   login:  (default)          fill and submit, wait for a success signal
//
// Usage via run_with_secret:
//   run_with_secret {
//     secret: "<bitcoffer secret name>",
//     cmd: "bitcoffer-login",
//     args: ["--url", "https://community.obsidian.md/",
//            "--email", "you@example.com",
//            "--password-env", "PASSWORD",
//            "--open", ".login-button",
//            "--success-selector", ".current-user"],
//     env_name: "PASSWORD"
//   }
//
// Success signals (any one, polled): --success-selector (CSS), --success-text
// (substring of body), --success-url (RegExp on the final URL). Failure signals:
// --error-selector (CSS, checked each poll). If you provide NO success signal,
// the run submits and then reports "submitted-unconfirmed" — the login is not
// judged to have succeeded or failed. If a success signal is provided but none
// fires within --success-wait-ms the run reports "timeout" — the human should
// check the window (2FA/captcha may be pending), it does NOT mean the login
// failed.

import { spawnSync } from 'node:child_process';
import { createRequire } from 'node:module';
import { homedir } from 'node:os';
import path from 'node:path';
import fs from 'node:fs';
import { fileURLToPath } from 'node:url';
import { setTimeout as sleep } from 'node:timers/promises';

const require = createRequire(import.meta.url);

// --- playwright resolution -------------------------------------------------
// Portable loader. On any machine this resolves in order:
//   1. --playwright-path <dir> (explicit override)
//   2. local / NODE_PATH resolution (require('playwright'))
//   3. the global npm install (`npm root -g`)
// If none match, print the one-time install command instead of a bare error.
function loadPlaywright(a) {
  if (a['playwright-path']) {
    for (const p of [path.join(a['playwright-path'], 'index.js'), a['playwright-path']]) {
      try { return require(p); } catch {}
    }
  }
  try { return require('playwright'); } catch {}
  try {
    const r = spawnSync('npm', ['root', '-g'], { encoding: 'utf8' });
    const root = (r.stdout || '').trim();
    if (root) { try { return require(path.join(root, 'playwright')); } catch {} }
  } catch {}
  throw new Error(
    'playwright not found. Install it once on this machine:\n' +
    '  npm i -g playwright && npx playwright install chromium\n' +
    '(or pass --playwright-path <dir> pointing at a playwright install)');
}

// --- arg parsing -----------------------------------------------------------
// Accepts both `--flag value` and `--flag=value`; a bare `--flag` is boolean.
function parseArgs(argv) {
  const a = {};
  for (let i = 0; i < argv.length; i++) {
    const k = argv[i];
    if (!k.startsWith('--')) continue;
    const body = k.slice(2);
    const eq = body.indexOf('=');
    if (eq !== -1) {
      a[body.slice(0, eq)] = body.slice(eq + 1);
      continue;
    }
    const next = argv[i + 1];
    if (next === undefined || next.startsWith('--')) { a[body] = true; continue; }
    a[body] = next; i++;
  }
  return a;
}

function usage() {
  return [
    'Usage: bitcoffer-login.mjs --url <login-url> --password-env <ENV> [options]',
    '  --url <url>                (required) page to open',
    '  --password-env <ENV>       (required, unless --smoke) env var holding the password',
    '  --email <addr>             username/email to fill (optional)',
    '  --open <selector>          click this to open the login form before filling',
    '  --email-selector <css>     default #login-account-name',
    '  --password-selector <css>  default #login-account-password',
    '  --submit-selector <css>    default #login-button',
    '  --profile <dir>            persistent profile (default ~/.cache/bitcoffer-login/<host>)',
    '  --headless                 run headless (default: headed, so a human can watch / do 2FA)',
    '  --no-submit                fill but do not click submit',
    '  --smoke                    locate fields only, never fill or submit (no password needed)',
    '  --close                    close the browser after the run (default: keep it open for 2FA)',
    '  --success-selector <css>   success signal (any one)',
    '  --success-text <text>      success signal (substring of body text)',
    '  --success-url <regex>      success signal (matched against final URL)',
    '  --error-selector <css>     default ".alert-error, #login-error, .login-error"',
    '  --success-wait-ms <ms>     how long to poll for a success signal, default 15000',
    '  --op-timeout-ms <ms>       timeout for a single DOM operation, default 5000',
    '  --goto-timeout-ms <ms>     navigation timeout, default 30000',
    '  --help                     show this help',
    '',
    'Without any success signal the run reports "submitted-unconfirmed" after',
    'submitting: the login is neither confirmed nor ruled out.',
  ].join('\n');
}

const DEFAULTS = {
  emailSelector: '#login-account-name',
  passwordSelector: '#login-account-password',
  submitSelector: '#login-button',
  errorSelector: '.alert-error, #login-error, .login-error',
  successWaitMs: 15000,
  opTimeoutMs: 5000,
  gotoTimeoutMs: 30000,
};

// --- pure helpers (unit-testable) -----------------------------------------

// Whether the located/filled fields satisfy what this run needs. In smoke mode
// both fields are required (the point is to verify the selectors); in fill
// modes the email field is only required when --email was actually given.
function fieldsSatisfied(a, fields) {
  const emailRequired = !!a.smoke || !!a.email;
  const passwordOk = fields.password === true;
  const emailOk = !emailRequired || fields.email === true;
  return { ok: passwordOk && emailOk, passwordOk, emailOk, emailRequired };
}

// Resolve the password from the environment. Smoke runs need none; anything
// else refuses to continue with a blank password (fail closed, no playwright).
function resolvePassword(a) {
  if (a.smoke) return { ok: true, password: '' };
  const name = a['password-env'];
  const password = process.env[name] ?? '';
  if (password === '') {
    return { ok: false, error: `env var ${name} is empty/unset — refusing to log in with a blank password` };
  }
  return { ok: true, password };
}

// --- run -------------------------------------------------------------------
async function run() {
  const a = parseArgs(process.argv.slice(2));
  if (a.help) {
    console.log(usage());
    process.exit(0);
  }
  if (!a.url || (!a['password-env'] && !a.smoke)) {
    console.error(usage());
    process.exit(2);
  }

  const pw = resolvePassword(a);
  if (!pw.ok) {
    console.error(`[bitcoffer-login] ${pw.error}`);
    process.exit(3);
  }

  const playwright = loadPlaywright(a);

  const host = new URL(a.url).hostname;
  const slug = host.replace(/\./g, '-');
  const profile = a.profile || path.join(homedir(), '.cache', 'bitcoffer-login', slug);
  fs.mkdirSync(profile, { recursive: true });

  const ctx = await playwright.chromium.launchPersistentContext(profile, {
    headless: !!a.headless,
    viewport: { width: 1280, height: 900 },
  });
  const page = ctx.pages()[0] || (await ctx.newPage());

  const receipt = {
    ok: false,
    mode: a.smoke ? 'smoke' : (a['no-submit'] ? 'filled' : 'login'),
    url: a.url,
    host,
    profile,
    fields: { email: false, password: false },
    outcome: null,
    note: null,
  };

  try {
    // Keep per-operation timeouts independent of the success-poll deadline:
    // a long --success-wait-ms (slow 2FA) must not make a missing field hang.
    page.setDefaultTimeout(Number(a['op-timeout-ms']) || DEFAULTS.opTimeoutMs);
    const resp = await page.goto(a.url, {
      waitUntil: 'domcontentloaded',
      timeout: Number(a['goto-timeout-ms']) || DEFAULTS.gotoTimeoutMs,
    });
    receipt.status = resp ? resp.status() : null;

    if (a.open) {
      try { await page.click(a.open); }
      catch { /* form may already be visible — proceed */ }
    }

    const emailSelector = a['email-selector'] || DEFAULTS.emailSelector;
    const passwordSelector = a['password-selector'] || DEFAULTS.passwordSelector;

    // Locate fields (smoke) or fill them (filled / login).
    if (a.smoke) {
      receipt.fields.email = !!(await page.$(emailSelector));
      receipt.fields.password = !!(await page.$(passwordSelector));
    } else {
      if (a.email) {
        const el = await page.$(emailSelector);
        if (el) { await el.fill(a.email); receipt.fields.email = true; }
      }
      const el = await page.$(passwordSelector);
      if (el) { await el.fill(pw.password); receipt.fields.password = true; }
    }

    const fields = fieldsSatisfied(a, receipt.fields);
    if (!fields.ok) {
      const missing = [];
      if (!fields.passwordOk) missing.push('password');
      if (fields.emailRequired && !fields.emailOk) missing.push('email');
      receipt.outcome = a.smoke ? 'fields-missing' : 'fill-incomplete';
      receipt.note = `could not locate the ${missing.join(' and ')} field${missing.length > 1 ? 's' : ''} — nothing was ${a.smoke ? 'verified' : 'submitted'}`;
      return receipt;
    }

    if (a.smoke) {
      receipt.ok = true;
      receipt.outcome = 'fields-located';
      receipt.note = 'smoke only — fields located, no credentials used';
      return receipt;
    }

    if (a['no-submit']) {
      receipt.ok = true;
      receipt.outcome = 'filled-awaiting-human';
      receipt.note = 'fields filled in the visible window; submit left to you';
      return receipt;
    }

    // Submit and poll for a success/failure signal.
    const submit = await page.$(a['submit-selector'] || DEFAULTS.submitSelector);
    if (!submit) {
      receipt.ok = false;
      receipt.outcome = 'submit-missing';
      receipt.note = 'submit button not found — fields filled but nothing clicked';
      return receipt;
    }
    await submit.click();

    const successSel = a['success-selector'];
    const successText = a['success-text'];
    const successUrl = a['success-url'] ? new RegExp(a['success-url']) : null;
    const errorSel = a['error-selector'] || DEFAULTS.errorSelector;
    const waitMs = Number(a['success-wait-ms']) || DEFAULTS.successWaitMs;
    const hasSuccessSignal = !!(successSel || successText || successUrl);

    const deadline = Date.now() + waitMs;
    while (Date.now() < deadline) {
      const url = page.url();
      if (successUrl && successUrl.test(url)) {
        receipt.ok = true; receipt.outcome = 'success-url'; receipt.url = url; break;
      }
      if (successSel && (await page.$(successSel))) {
        receipt.ok = true; receipt.outcome = 'success-selector'; break;
      }
      if (successText) {
        const body = (await page.textContent('body')) || '';
        if (body.includes(successText)) {
          receipt.ok = true; receipt.outcome = 'success-text'; break;
        }
      }
      if (await page.$(errorSel)) {
        receipt.ok = false;
        receipt.outcome = 'error-signal';
        receipt.note = 'login form reports an error — likely wrong credentials or a failed 2FA step';
        break;
      }
      await sleep(400);
    }
    if (receipt.outcome === null) {
      receipt.ok = false;
      if (hasSuccessSignal) {
        receipt.outcome = 'timeout';
        receipt.note = 'no success/error signal within the wait — check the window (2FA/captcha may be pending)';
      } else {
        receipt.outcome = 'submitted-unconfirmed';
        receipt.note = 'login submitted but no success signal was provided, so the result could not be confirmed — check the window (2FA/captcha may be pending)';
      }
    }
    receipt.title = await page.title();
    return receipt;
  } finally {
    // Smoke runs close immediately. Real runs keep the browser open so a human
    // can finish 2FA and the persistent profile keeps the session; --close
    // overrides that for scripted use.
    if (a.smoke || a.close) await ctx.close();
  }
}

// --- entry -----------------------------------------------------------------
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isMain) {
  run()
    .then((r) => { console.log(JSON.stringify(r)); process.exit(r.ok ? 0 : 1); })
    .catch((e) => { console.error('[bitcoffer-login] failed:', e.message); process.exit(1); });
}

export { parseArgs, fieldsSatisfied, resolvePassword, DEFAULTS };
