import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  // One baseline per shot, not one per platform: the platform a shot was
  // rendered on is what the fonts are pinned for, not part of its name.
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
      // Playwright already launches Chromium with `--no-sandbox`, unless
      // `chromiumSandbox: true` asks it not to.
      args: ['--font-render-hinting=none', '--disable-lcd-text'],
    },
  },

  expect: {
    toHaveScreenshot: {
      // Greyscale antialiasing, so a local run compares against CI's Linux
      // baselines with room to spare. See tests/screenshot.css.
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

  // The site is the working copy: index.html and assets/css beside it.
  // python3 arrives through the flake's runner (nix/vrt.nix).
  webServer: {
    command: 'python3 -m http.server 4173',
    port: 4173,
    timeout: 30000,
    reuseExistingServer: !process.env.CI,
  },
});
