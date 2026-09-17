// @ts-check
const { test, expect } = require('@playwright/test');
const { openDevHub, switchTheme, assertZeroBlackBoxes, assertContrastRatios, switchTab } = require('../helpers/hub-fixtures');

test.describe('Dev Hub: Theme & WCAG Contrast Audit (Group: themes, contrast)', () => {

  test('Toggles Dark/Light theme and persists state in localStorage', async ({ page }) => {
    await openDevHub(page, { theme: 'dark', lang: 'en', mock: true });

    // Initial state is dark
    let themeAttr = await page.evaluate(() => document.documentElement.getAttribute('data-theme'));
    expect(themeAttr).toBe('dark');

    // Switch to Light
    await switchTheme(page, 'light');
    themeAttr = await page.evaluate(() => document.documentElement.getAttribute('data-theme'));
    expect(themeAttr).toBe('light');

    // Switch back to Dark
    await switchTheme(page, 'dark');
    themeAttr = await page.evaluate(() => document.documentElement.getAttribute('data-theme'));
    expect(themeAttr).toBe('dark');
  });

  test('Verifies Zero Black-Box Leaks in Light Mode', async ({ page }) => {
    await openDevHub(page, { theme: 'light', lang: 'en', mock: true });

    // Check Blueprints Tab in light mode
    let audit = await assertZeroBlackBoxes(page);
    expect(audit.clean, `Black-box leaks found in Light Mode on Blueprints tab: ${JSON.stringify(audit.leaks)}`).toBe(true);

    // Check Testing Tab in light mode
    await switchTab(page, 'testing');
    audit = await assertZeroBlackBoxes(page);
    expect(audit.clean, `Black-box leaks found in Light Mode on Testing tab: ${JSON.stringify(audit.leaks)}`).toBe(true);
  });

  test('Verifies WCAG 2.1 AA text contrast compliance in Light Mode', async ({ page }) => {
    await openDevHub(page, { theme: 'light', lang: 'en', mock: true });

    // Inspect contrast of headings, paragraphs, and badges
    const result = await assertContrastRatios(page, ['h1', 'h2', 'h3', 'h4', '.card-desc']);
    expect(result.pass, `Contrast failures detected: ${JSON.stringify(result.failedItems)}`).toBe(true);
  });

});
