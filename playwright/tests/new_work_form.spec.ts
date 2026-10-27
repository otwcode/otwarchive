import { test, expect } from "@playwright/test";

test.use({ storageState: "playwright/.auth/user.json" });

// The aria snapshot records the visible text of the page (roles and
// accessible names) and fails with a text diff when it changes. If the
// change is intentional, regenerate with: npm run test:playwright:update
test("new work form text is unchanged", async ({ page }) => {
  await page.goto("/works/new");
  await expect(page.getByRole("main")).toMatchAriaSnapshot({
    name: "new_work_form.aria.yml",
  });
});
