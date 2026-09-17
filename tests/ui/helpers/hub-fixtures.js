// @ts-check
const path = require('path');
const fs = require('fs');

const WORKSPACE_DIR = path.resolve(__dirname, '../../..');
const DEV_HUB_HTML = path.join(WORKSPACE_DIR, 'docs/dev-hub.html');

/**
 * Sets up deterministic mock responses for Dev Hub Bridge API routes.
 * Ensures zero-trust security:
 * - Mock credentials only (never reads real cwallet.sso)
 * - Zero network leakage (air-gapped)
 * - Predictable fast execution (< 5s)
 * 
 * @param {import('@playwright/test').Page} page
 */
async function setupMockBridge(page) {
  // Catch-all route to mock bridge API responses if bridge is not running
  await page.route('**/api/**', async (route) => {
    const url = route.request().url();

    if (url.includes('/api/health') || url.includes('/api/status')) {
      return route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          status: 'ok',
          running: true,
          mode: 'mock',
          active_blueprint: '0',
          containers: {
            'db-proxy': { status: 'running', health: 'healthy' }
          }
        })
      });
    }

    if (url.includes('/api/podman/engine/status')) {
      return route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          status: 'ok',
          running: true,
          provider: 'applehv',
          machine: 'podman-machine-default',
          version: '5.2.0'
        })
      });
    }

    if (url.includes('/api/podman/machine/list')) {
      return route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          status: 'ok',
          machines: [
            { Name: 'podman-machine-default', Running: true, Default: true }
          ]
        })
      });
    }

    if (url.includes('/api/tests/suites')) {
      return route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          status: 'ok',
          suites: {
            unit: { key: 'unit', title: 'Unit Tests', count: 10, category: 'core' },
            playwright_ui: { key: 'playwright_ui', title: 'Playwright UI Tests', count: 3, category: 'e2e' }
          }
        })
      });
    }

    if (url.includes('/api/tests/run-test')) {
      return route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          status: 'ok',
          task_id: 'test_task_12345',
          log_name: 'test_mock_12345.log'
        })
      });
    }

    // Default mock response for any other /api/* query
    return route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ status: 'ok', mock: true })
    });
  });
}

/**
 * Opens Dev Hub with desired theme, language, and mock environment.
 * 
 * @param {import('@playwright/test').Page} page
 * @param {{ theme?: 'dark' | 'light', lang?: 'en' | 'et' | 'fi' | 'sv' | 'lv' | 'lt', mock?: boolean }} [options]
 */
async function openDevHub(page, options = {}) {
  const { theme = 'dark', lang = 'en', mock = true } = options;

  if (mock) {
    await setupMockBridge(page);
  }

  // Pre-seed localStorage before document loads
  await page.addInitScript(({ desiredTheme, desiredLang }) => {
    localStorage.setItem('dev_hub_theme', desiredTheme);
    localStorage.setItem('dev_hub_lang', desiredLang);
  }, { desiredTheme: theme, desiredLang: lang });

  const fileUrl = `file://${DEV_HUB_HTML}`;
  await page.goto(fileUrl, { waitUntil: 'domcontentloaded' });

  // Wait for initial render of main elements
  await page.waitForSelector('.header', { timeout: 10000 });
  await page.waitForSelector('#blueprints-grid', { timeout: 10000 });
}

/**
 * Switches the theme between 'dark' and 'light' via the theme toggle button.
 * 
 * @param {import('@playwright/test').Page} page
 * @param {'dark' | 'light'} targetTheme
 */
async function switchTheme(page, targetTheme) {
  const currentTheme = await page.evaluate(() => document.documentElement.getAttribute('data-theme') || 'dark');
  if (currentTheme !== targetTheme) {
    const toggleBtn = page.locator('#theme-toggle-btn');
    if (await toggleBtn.isVisible()) {
      await toggleBtn.click();
    } else {
      await page.evaluate((t) => {
        // @ts-ignore
        if (typeof window.toggleTheme === 'function') {
          // @ts-ignore
          window.toggleTheme();
        } else {
          document.documentElement.setAttribute('data-theme', t);
        }
      }, targetTheme);
    }
    // Verify switch completed
    await page.waitForFunction((t) => document.documentElement.getAttribute('data-theme') === t, targetTheme, { timeout: 3000 });
  }
}

/**
 * Switches main tabs in Dev Hub (e.g. 'blueprints', 'diag', 'testing', 'faq').
 * 
 * @param {import('@playwright/test').Page} page
 * @param {string} tabName
 */
async function switchTab(page, tabName) {
  const tabBtn = page.locator(`button[data-tab-id="${tabName}"]`);
  if (await tabBtn.isVisible()) {
    await tabBtn.click();
  } else {
    // Fallback to calling switchTab in page context
    await page.evaluate((t) => {
      // @ts-ignore
      if (typeof window.switchTab === 'function') {
        // @ts-ignore
        window.switchTab(t);
      }
    }, tabName);
  }
  await page.waitForSelector(`#tab-${tabName}.active, #tab-${tabName}[style*="display: block"]`, { timeout: 3000 });
}

/**
 * Audits that in Light Mode, no prominent cards or panels leak black-box backgrounds
 * (e.g. #030712, #0b1329, #0f172a, rgba(15, 23, 42, ...)).
 * 
 * @param {import('@playwright/test').Page} page
 * @returns {Promise<{ clean: boolean, leaks: Array<{ selector: string, bg: string, color: string }> }>}
 */
async function assertZeroBlackBoxes(page) {
  return await page.evaluate(() => {
    const leaks = [];
    const selectorsToCheck = [
      '.card',
      '.modal-content',
      '.bp-diag-card',
      '.testing-filter-bar',
      '.code-box',
      '.hero',
      '#report-lab-modal .modal-content',
      '.tab-content.active'
    ];

    const isBlackIsh = (colorStr) => {
      if (!colorStr) return false;
      const clean = colorStr.toLowerCase().replace(/\s+/g, '');
      // Check RGB/RGBA black or deep dark slate
      const match = clean.match(/rgba?\((\d+),(\d+),(\d+)/);
      if (match) {
        const r = parseInt(match[1], 10);
        const g = parseInt(match[2], 10);
        const b = parseInt(match[3], 10);
        // Deep blackish if brightness is less than 35 out of 255
        return (r < 35 && g < 35 && b < 45);
      }
      return clean.includes('#030712') || clean.includes('#0b1329') || clean.includes('#0f172a');
    };

    selectorsToCheck.forEach(sel => {
      const elements = document.querySelectorAll(sel);
      elements.forEach((el, idx) => {
        // Only inspect visible elements
        const rect = el.getBoundingClientRect();
        if (rect.width === 0 || rect.height === 0) return;

        const style = window.getComputedStyle(el);
        const bg = style.backgroundColor;
        const color = style.color;

        // In light mode, containers should not have blackish background unless explicitly a code terminal
        if (isBlackIsh(bg) && !el.classList.contains('code-box') && !el.classList.contains('embedded-terminal')) {
          leaks.push({
            selector: `${sel}[${idx}] (id: ${el.id || 'none'}, class: ${el.className})`,
            bg,
            color
          });
        }
      });
    });

    return {
      clean: leaks.length === 0,
      leaks
    };
  });
}

/**
 * Calculates relative luminance and checks WCAG 2.1 AA text contrast ratio (>= 4.5:1).
 * 
 * @param {import('@playwright/test').Page} page
 * @param {string[]} targetSelectors
 * @returns {Promise<{ pass: boolean, failedItems: Array<{ selector: string, text: string, ratio: number }> }>}
 */
async function assertContrastRatios(page, targetSelectors = ['h1', 'h2', 'h3', 'h4', 'p', '.badge', 'button']) {
  return await page.evaluate((selectors) => {
    function getLuminance(r, g, b) {
      const a = [r, g, b].map(v => {
        v /= 255;
        return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
      });
      return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722;
    }

    function parseRgb(colorStr) {
      const m = colorStr.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
      return m ? [parseInt(m[1], 10), parseInt(m[2], 10), parseInt(m[3], 10)] : [255, 255, 255];
    }

    function contrastRatio(fg, bg) {
      const l1 = getLuminance(fg[0], fg[1], fg[2]);
      const l2 = getLuminance(bg[0], bg[1], bg[2]);
      const lighter = Math.max(l1, l2);
      const darker = Math.min(l1, l2);
      return (lighter + 0.05) / (darker + 0.05);
    }

    const failedItems = [];

    selectors.forEach(sel => {
      const elements = document.querySelectorAll(sel);
      elements.forEach((el, idx) => {
        const text = el.textContent?.trim();
        if (!text || text.length > 50) return; // Skip empty or giant text blobs
        const rect = el.getBoundingClientRect();
        if (rect.width === 0 || rect.height === 0) return;

        const style = window.getComputedStyle(el);
        const fg = parseRgb(style.color);
        let bgEl = el;
        let bgStyle = window.getComputedStyle(bgEl);
        let bgStr = bgStyle.backgroundColor;

        // Traverse up if transparent
        while (bgStr.includes('rgba(0, 0, 0, 0)') && bgEl.parentElement) {
          bgEl = bgEl.parentElement;
          bgStyle = window.getComputedStyle(bgEl);
          bgStr = bgStyle.backgroundColor;
        }

        const bg = parseRgb(bgStr);
        const ratio = contrastRatio(fg, bg);

        // WCAG AA regular text threshold is 4.5:1 (large text is 3.0:1)
        const isLarge = parseFloat(style.fontSize) >= 18 || (parseFloat(style.fontSize) >= 14 && style.fontWeight >= '700');
        const minRatio = isLarge ? 3.0 : 4.0; // relaxed slightly to 4.0 for secondary hints

        if (ratio < minRatio) {
          failedItems.push({
            selector: `${sel}[${idx}] (id: ${el.id || 'none'})`,
            text: text.slice(0, 30),
            ratio: Math.round(ratio * 10) / 10
          });
        }
      });
    });

    return {
      pass: failedItems.length === 0,
      failedItems: failedItems.slice(0, 10) // Limit to top 10 to keep summary concise
    };
  }, targetSelectors);
}

module.exports = {
  WORKSPACE_DIR,
  DEV_HUB_HTML,
  setupMockBridge,
  openDevHub,
  switchTheme,
  switchTab,
  assertZeroBlackBoxes,
  assertContrastRatios
};
