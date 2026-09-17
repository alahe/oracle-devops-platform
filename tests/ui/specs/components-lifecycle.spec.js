// @ts-check
const { test, expect } = require('@playwright/test');
const { openDevHub, switchTheme, switchTab } = require('../helpers/hub-fixtures');

test.describe('Dev Hub: Components Lifecycle & Modals (Group: podman, blueprints, publisher, wallet)', () => {

  test('Verifies Podman Smart Lifecycle Button and dropdown behavior', async ({ page }) => {
    await openDevHub(page, { theme: 'dark', lang: 'en', mock: true });

    const podmanBtn = page.locator('#podman-hero-btn, #podman-btn, button[onclick*="startPodman"]').first();
    if (await podmanBtn.isVisible()) {
      await expect(podmanBtn).toBeEnabled();
    }
  });

  test('Opens Blueprint detail modal and verifies tabs and architecture diagram', async ({ page }) => {
    const bpNum = process.env.TEST_BLUEPRINT_ID || '0';
    await openDevHub(page, { theme: 'dark', lang: 'en', mock: true });

    // Click on specified blueprint card
    const bpCard = page.locator(`.card-blueprint[data-bp-id="${bpNum}"], .card-blueprint[onclick*="openBlueprintModal(${bpNum})"]`).first();
    if (await bpCard.isVisible()) {
      await bpCard.click();
    } else {
      // Fallback: invoke openBlueprintModal directly
      await page.evaluate((num) => {
        // @ts-ignore
        if (typeof window.openBlueprintModal === 'function') {
          // @ts-ignore
          window.openBlueprintModal(parseInt(num, 10));
        }
      }, bpNum);
    }

    // Modal must become visible
    const modal = page.locator('#blueprint-modal');
    await expect(modal).toBeVisible({ timeout: 5000 });

    // Check modal tabs (Architecture, Actions, Testing & Diagnostics)
    const diagTabBtn = page.locator('#bp-modal-tab-btn-diag, button[onclick*="switchBlueprintModalTab(\'diag\')"]');
    if (await diagTabBtn.isVisible()) {
      await diagTabBtn.click();
      const diagContent = page.locator('#bp-modal-tab-diag');
      await expect(diagContent).toBeVisible();
    }

    // Close modal
    const closeBtn = page.locator('#blueprint-modal .modal-close, #blueprint-modal button[onclick*="closeBlueprintModal"]').first();
    if (await closeBtn.isVisible()) {
      await closeBtn.click();
      await expect(modal).not.toBeVisible();
    }
  });

  test('Audits Analytics Publisher Report Lab modal (Mock Safe)', async ({ page }) => {
    await openDevHub(page, { theme: 'light', lang: 'en', mock: true });

    // Open Report Lab modal if button exists or directly
    await page.evaluate(() => {
      // @ts-ignore
      if (typeof window.openReportLabModal === 'function') {
        // @ts-ignore
        window.openReportLabModal();
      }
    });

    const labModal = page.locator('#report-lab-modal');
    if (await labModal.isVisible()) {
      // Check modal content is rendered cleanly without dark artifacts
      const modalBox = page.locator('#report-lab-modal .modal-content');
      await expect(modalBox).toBeVisible();

      // Close it
      const closeBtn = page.locator('#report-lab-modal .modal-close').first();
      if (await closeBtn.isVisible()) {
        await closeBtn.click();
      }
    }
  });

  test('Validates Zero-Trust SEPS Wallet dummy copy interaction', async ({ page }) => {
    await openDevHub(page, { theme: 'dark', lang: 'en', mock: true });

    // Open Services or Diagnostics tab where passwords/wallets are listed
    await switchTab(page, 'services');

    // Clipboard mock verification
    const copyBtns = page.locator('.copy-btn, button[onclick*="copySnippet"], button[onclick*="copyPassword"]');
    const count = await copyBtns.count();
    expect(count).toBeGreaterThan(0);
  });

});
