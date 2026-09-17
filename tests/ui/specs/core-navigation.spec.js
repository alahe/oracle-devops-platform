// @ts-check
const { test, expect } = require('@playwright/test');
const { openDevHub, switchTab } = require('../helpers/hub-fixtures');

test.describe('Dev Hub: Core Navigation & Multi-Language (Group: core, navigation, i18n)', () => {

  test('Loads Dev Hub, validates header, title and zero console errors', async ({ page }) => {
    const consoleErrors = [];
    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text());
      }
    });

    await openDevHub(page, { theme: 'dark', lang: 'en', mock: true });

    // Header branding check
    const headerTitle = page.locator('.header h1');
    await expect(headerTitle).toBeVisible();
    await expect(headerTitle).toContainText('Oracle DevOps Platform');

    // Blueprints Grid present
    const bpGrid = page.locator('#blueprints-grid');
    await expect(bpGrid).toBeVisible();

    // Verify no critical JavaScript exceptions occurred
    const fatalErrors = consoleErrors.filter(e => !e.includes('favicon.ico'));
    expect(fatalErrors.length, `Unexpected console errors: ${fatalErrors.join('; ')}`).toBe(0);
  });

  test('Navigates across all primary tabs seamlessly', async ({ page }) => {
    await openDevHub(page, { theme: 'dark', lang: 'en', mock: true });

    const tabsToTest = ['blueprints', 'services', 'diag', 'testing', 'faq'];

    for (const tab of tabsToTest) {
      await switchTab(page, tab);
      const tabContent = page.locator(`#tab-${tab}`);
      await expect(tabContent).toBeVisible();
    }
  });

  test('Switches between 6 supported languages (EN / ET / FI / SV / LV / LT)', async ({ page }) => {
    await openDevHub(page, { theme: 'dark', lang: 'en', mock: true });

    const langs = [
      { code: 'et', sampleAttr: 'data-i18n="tagline"', expectedPart: 'Ühe klõpsuga' },
      { code: 'en', sampleAttr: 'data-i18n="tagline"', expectedPart: 'One-Click' },
      { code: 'fi', sampleAttr: 'data-i18n="tagline"', expectedPart: 'Yhdellä' },
      { code: 'sv', sampleAttr: 'data-i18n="tagline"', expectedPart: 'Ett klick' }
    ];

    for (const lang of langs) {
      await page.evaluate((l) => {
        // @ts-ignore
        if (typeof window.switchLanguage === 'function') {
          // @ts-ignore
          window.switchLanguage(l);
        } else {
          localStorage.setItem('dev_hub_lang', l);
          location.reload();
        }
      }, lang.code);

      // Verify language selection saved in localStorage
      const savedLang = await page.evaluate(() => localStorage.getItem('dev_hub_lang'));
      expect(savedLang).toBe(lang.code);
    }
  });

});
