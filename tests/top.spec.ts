import { test, expect } from '@playwright/test';

test('top page renders as the baseline', async ({ page }) => {
  await page.goto('/', { waitUntil: 'load' });
  await expect(page.getByRole('heading', { name: '関数型まつり 2026' })).toBeVisible();
  await expect(page).toHaveScreenshot('top-page.png', { fullPage: true });
});
