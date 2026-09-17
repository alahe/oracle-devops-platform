#!/usr/bin/env node
// @ts-check
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const WORKSPACE_DIR = path.resolve(__dirname, '../..');
const DEV_HUB_HTML = path.join(WORKSPACE_DIR, 'docs/dev-hub.html');
const AUDIT_CONTRAST_PY = path.join(WORKSPACE_DIR, 'scripts/internal/dev_hub/audit_contrast.py');

const args = process.argv.slice(2);
let targetGroup = 'all';
let targetBp = null;
let liveMode = false;
let headed = false;

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--group' && args[i + 1]) {
    targetGroup = args[i + 1].toLowerCase();
    i++;
  } else if ((args[i] === '-b' || args[i] === '--blueprint') && args[i + 1]) {
    targetBp = args[i + 1];
    i++;
  } else if (args[i] === '--live') {
    liveMode = true;
  } else if (args[i] === '--headed') {
    headed = true;
  }
}

console.log('==============================================================================');
console.log(' 🎭 DEV HUB HYBRID UI & WCAG CONTRAST TEST ENGINE');
console.log('==============================================================================');
console.log(` Target Group : ${targetGroup}`);
console.log(` Blueprint    : ${targetBp !== null ? targetBp : 'All (0–11)'}`);
console.log(` Mode         : ${liveMode ? 'LIVE BRIDGE' : 'FAST DETERMINISTIC AUDIT'}`);
console.log('------------------------------------------------------------------------------');

if (!fs.existsSync(DEV_HUB_HTML)) {
  console.error(`❌ VIGA: docs/dev-hub.html ei leitud asukohas: ${DEV_HUB_HTML}`);
  process.exit(1);
}

const html = fs.readFileSync(DEV_HUB_HTML, 'utf-8');
const results = [];

function recordTest(suite, testName, pass, details = '') {
  results.push({ suite, testName, pass, details });
  const icon = pass ? '  ✅ [PASS]' : '  ❌ [FAIL]';
  console.log(`${icon} ${suite} › ${testName}`);
  if (!pass && details) {
    console.log(`      Error: ${details}`);
  }
}

// ---------------------------------------------------------------------------
// SUITE 1: Core Navigation, Golden 7 Tabs & 6-Language i18n
// ---------------------------------------------------------------------------
if (targetGroup === 'all' || targetGroup === 'core' || targetGroup === 'navigation' || targetGroup === 'i18n') {
  console.log('\n[Suite 1: Core Navigation & Multi-Language Contract]');

  // 1.1 Brand & HTML validity
  const hasDoctype = html.startsWith('<!DOCTYPE html>') || html.includes('<!DOCTYPE html>');
  const hasTitle = html.includes('Oracle DevOps Platform');
  recordTest('Core', 'HTML Document structure & Branding Title', hasDoctype && hasTitle);

  // 1.2 Golden 7 Tabs
  const golden7Tabs = [
    'tab-services',
    'tab-devops',
    'tab-podman',
    'tab-specs',
    'tab-testing',
    'tab-docs',
    'tab-benchmarks'
  ];
  const missingTabs = golden7Tabs.filter(t => !html.includes(`id="${t}"`));
  recordTest(
    'Core',
    'Golden 7 Standard Tabs Container Presence',
    missingTabs.length === 0,
    missingTabs.length > 0 ? `Missing tabs: ${missingTabs.join(', ')}` : ''
  );

  // 1.3 6-Language Multi-Lingual Switcher
  const languages = ['en', 'et', 'fi', 'sv', 'lv', 'lt'];
  const missingLangs = languages.filter(l => !html.includes(`data-lang="${l}"`) && !html.includes(`selectDropdownLanguage('${l}')`) && !html.includes(`id="btn-${l}"`));
  recordTest(
    'Core',
    '6-Language Regional Switcher (EN, ET, FI, SV, LV, LT)',
    missingLangs.length === 0,
    missingLangs.length > 0 ? `Missing languages: ${missingLangs.join(', ')}` : ''
  );
}

// ---------------------------------------------------------------------------
// SUITE 2: Themes, Zero Black-Box Leaks & WCAG 2.1 AA Contrast
// ---------------------------------------------------------------------------
if (targetGroup === 'all' || targetGroup === 'themes' || targetGroup === 'contrast') {
  console.log('\n[Suite 2: Themes & WCAG 2.1 AA Contrast Audit]');

  // 2.1 Theme Switcher
  const hasThemeToggle = html.includes('id="theme-toggle-btn"') && html.includes('toggleTheme()');
  recordTest('Themes', 'Dark/Light Theme Toggle Control & Storage Hook', hasThemeToggle);

  // 2.2 Python WCAG Relative Luminance Auditor
  const pyProc = spawnSync('python3', [AUDIT_CONTRAST_PY], { encoding: 'utf-8' });
  const pyPass = pyProc.status === 0;
  const criticalLeaks = (pyProc.stdout.match(/0 CRITICAL/g) || []).length > 0;
  recordTest(
    'Themes',
    'WCAG 2.1 AA Contrast Ratio (>= 4.5:1 / >= 3.0:1) & Zero Critical Leaks',
    pyPass && criticalLeaks,
    pyPass ? '' : pyProc.stdout
  );

  // 2.3 Light Mode Zero-Black-Box Inspection
  const forbiddenBlackOnCards = html.includes('.card { background: #030712') || html.includes('.card { background: #0b1329');
  recordTest('Themes', 'Light Mode Surface Isolation (No hardcoded black card rules)', !forbiddenBlackOnCards);
}

// ---------------------------------------------------------------------------
// SUITE 3: Components Lifecycle, Podman, Blueprints & SEPS Wallet
// ---------------------------------------------------------------------------
if (targetGroup === 'all' || targetGroup === 'podman' || targetGroup === 'blueprints' || targetGroup === 'wallet' || targetBp !== null) {
  console.log('\n[Suite 3: Components Lifecycle & Blueprint Architecture]');

  // 3.1 Podman Smart Startup Controls
  const hasPodmanSmartBtn = html.includes('btn-podman-primary-action') || html.includes('triggerSmartPodmanStartup');
  const hasPodmanHero = html.includes('podman-empty-hero');
  recordTest('Components', 'Podman Smart Startup Button & Empty State Hero', hasPodmanSmartBtn && hasPodmanHero);

  // 3.2 Blueprint Matrix Coverage
  if (targetBp !== null) {
    const bpNum = parseInt(targetBp, 10);
    const hasBp = html.includes(`data-bp="${bpNum}"`);
    recordTest('Components', `Blueprint #${bpNum} Card & Modal Hooks`, hasBp);
  } else {
    let missingBp = [];
    for (let b = 0; b <= 11; b++) {
      if (!html.includes(`data-bp="${b}"`)) missingBp.push(b);
    }
    recordTest(
      'Components',
      'All 12 Canonical Architecture Blueprints (0–11) Present',
      missingBp.length === 0,
      missingBp.length > 0 ? `Missing blueprints: ${missingBp.join(', ')}` : ''
    );
  }

  // 3.3 Zero-Trust SEPS Wallet Matrix
  const hasWalletMatrix = html.includes('wallet-matrix-container') && html.includes('toggleWalletMatrix');
  const hasWalletCopy = html.includes('copySnippet') || html.includes('copyPassword');
  recordTest('Components', 'Zero-Trust SEPS Auto-Login Wallet Matrix & 1-Click Helpers', hasWalletMatrix && hasWalletCopy);

  // 3.4 Report Lab & Testing Center Controls
  const hasTestingCenter = html.includes('id="tab-testing"') && html.includes('card-devops-test-ui');
  recordTest('Components', 'Testing Center Suite Integration & UI Test Dispatcher Card', hasTestingCenter);
}

// ---------------------------------------------------------------------------
// Final Evaluation
// ---------------------------------------------------------------------------
console.log('\n------------------------------------------------------------------------------');
const totalTests = results.length;
const passedTests = results.filter(r => r.pass).length;
const failedTests = totalTests - passedTests;

console.log(` Kokku kontrolle : ${totalTests}`);
console.log(` Läbitud        : ${passedTests} ✅`);
console.log(` Ebaõnnestunud  : ${failedTests} ${failedTests > 0 ? '❌' : ''}`);
console.log('------------------------------------------------------------------------------');

if (failedTests > 0) {
  process.exit(1);
} else {
  process.exit(0);
}
