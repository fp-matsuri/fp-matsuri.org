import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  snapshotPathTemplate: '{testDir}/{testFileDir}/{testFileName}-snapshots/{arg}{ext}',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: process.env.CI ? [['github'], ['html']] : 'html',

  use: {
    baseURL: 'http://localhost:4173',
    trace: 'on-first-retry',
    launchOptions: {
      args: ['--font-render-hinting=none', '--disable-lcd-text'],
    },
  },

  expect: {
    toHaveScreenshot: {
      stylePath: './tests/screenshot.css',
      ...(process.env.CI
        ? { maxDiffPixels: 0 }
        : { maxDiffPixelRatio: 0.001 }),
    },
  },

  projects: [
    {
      name: 'chromium',
      use: { browserName: 'chromium', viewport: { width: 1440, height: 900 } },
    },
  ],

  webServer: {
    command: 'python3 -m http.server 4173',
    port: 4173,
    timeout: 30000,
    reuseExistingServer: !process.env.CI,
  },
});
