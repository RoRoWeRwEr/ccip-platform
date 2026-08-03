import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";

const publicRoutes = [
  "/en",
  "/ar",
  "/en/cards",
  "/en/compare",
  "/en/calculator",
  "/en/recommendation",
  "/en/auth",
] as const;

for (const route of publicRoutes) {
  test(`${route} has no serious accessibility violations or horizontal overflow`, async ({
    page,
  }) => {
    await page.goto(route);
    await expect(page.locator("#main-content")).toBeVisible();
    const results = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
      .analyze();
    expect(
      results.violations.filter(({ impact }) =>
        ["serious", "critical"].includes(impact ?? ""),
      ),
    ).toEqual([]);
    const overflow = await page.evaluate(
      () => document.documentElement.scrollWidth - window.innerWidth,
    );
    expect(overflow).toBeLessThanOrEqual(1);
  });
}

test("keyboard users can reveal the skip link and reach main content", async ({
  page,
}) => {
  await page.goto("/en");
  await page.keyboard.press("Tab");
  const skip = page.getByRole("link", { name: "Skip to main content" });
  await expect(skip).toBeFocused();
  await page.keyboard.press("Enter");
  await expect(page.locator("#main-content")).toBeFocused();
});

test("critical content remains available at 200 percent zoom", async ({
  page,
}) => {
  await page.goto("/ar/recommendation");
  await page.evaluate(() => {
    document.documentElement.style.zoom = "2";
  });
  await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
  await expect(page.locator("#main-content")).toBeVisible();
});
