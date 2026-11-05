import { test, expect } from '@playwright/test';

test('top page renders as the baseline', async ({ page }) => {
  await page.goto('/', { waitUntil: 'load' });
  // The two cards are the content that only the built site answers; a shot
  // taken before them is a shot of the header alone.
  await expect(page.getByRole('heading', { name: '関数型まつり 2026' })).toBeVisible();
  await expect(page).toHaveScreenshot('top-page.png', { fullPage: true });
});
