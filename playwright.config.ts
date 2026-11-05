import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  // ショット1枚につきベースライン1つ、プラットフォーム別ではない。
  // 描画環境はフォントの固定で制御するものであり、名前の一部ではない。
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
      // Playwright は既定で `--no-sandbox` 付きの Chromium を起動する
      // (`chromiumSandbox: true` を明示しない限り)。
      args: ['--font-render-hinting=none', '--disable-lcd-text'],
    },
  },

  expect: {
    toHaveScreenshot: {
      // グレースケールのアンチエイリアスで、ローカル実行が CI の Linux
      // ベースラインと余裕を持って突き合わせられるようにする。
      // tests/screenshot.css を参照。
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

  // 配信するのは作業コピーそのもの: index.html と assets/css をそのまま。
  // python3 は flake のランナーが運ぶ (nix/vrt.nix)。
  webServer: {
    command: 'python3 -m http.server 4173',
    port: 4173,
    timeout: 30000,
    reuseExistingServer: !process.env.CI,
  },
});
