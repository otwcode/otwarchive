import { test as setup, expect } from "@playwright/test";

const authFile = "playwright/.auth/user.json";
const user = process.env.PLAYWRIGHT_USER || "testuser";
const password = process.env.PLAYWRIGHT_PASSWORD || "password";

setup("authenticate", async ({ page }) => {
  await page.goto("/users/login");
  await page.locator("#user_login").fill(user);
  await page.locator("#user_password").fill(password);
  await page.locator("form#new_user").getByRole("button", { name: /log in/i }).click();
  await expect(page.locator("#main")).toContainText(/successfully logged in/i);
  await page.context().storageState({ path: authFile });
});
