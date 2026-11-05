import { test, expect } from '@playwright/test';

test('top page renders as the baseline', async ({ page }) => {
  await page.goto('/', { waitUntil: 'load' });
  // 2枚のカードはビルド済みサイトがようやく答える内容。その描画待ち
  // なしのショットはヘッダーだけのショットにすぎない。
  await expect(page.getByRole('heading', { name: '関数型まつり 2026' })).toBeVisible();
  await expect(page).toHaveScreenshot('top-page.png', { fullPage: true });
});
