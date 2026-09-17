// @ts-check
const { defineConfig, devices } = require('@playwright/test');
const path = require('path');

/**
 * Playwright Configuration for Oracle DevOps Platform Dev Hub UI Testing
 * - Prioritizes existing host Google Chrome or Microsoft Edge
 * - Zero-Trust & Zero-Port-Conflict: Mock by default or run against dynamic ephemeral server
 * - Viewport: 1440x900 (responsive standard laptop)
 * - Animations disabled for deterministic tests
 */
module.exports = defineConfig({
  testDir: './specs',
  timeout: 30000,
  expect: {
    timeout: 5000
  },
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [
    ['list'],
    ['html', { outputFolder: '../reports/playwright-report', open: 'never' }],
    ['json', { outputFile: '../reports/playwright-summary.json' }]
  ],
  use: {
    actionTimeout: 5000,
    navigationTimeout: 10000,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    viewport: { width: 1440, height: 900 },
    ignoreHTTPSErrors: true,
    // Emulate reduced motion to disable CSS transitions & animations
    reducedMotion: 'reduce'
  },
  projects: [
    {
      name: 'Google Chrome',
      use: {
        channel: 'chrome',
        launchOptions: {
          args: [
            '--disable-web-security',
            '--allow-file-access-from-files',
            '--disable-features=IsolateOrigins,site-per-process'
          ]
        }
      }
    }
  ],
  outputDir: './test-results'
});
