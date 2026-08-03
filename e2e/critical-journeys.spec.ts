import { expect, test } from "@playwright/test";

test("serves the bilingual public shell and locale direction", async ({
  page,
}) => {
  await page.goto("/en");
  await expect(page.getByRole("heading", { level: 1 })).toContainText(
    "really worth",
  );
  await expect(page.locator("html")).toHaveAttribute("dir", "ltr");
  await page.goto("/ar");
  await expect(page.getByRole("heading", { level: 1 })).toContainText(
    "القيمة الحقيقية",
  );
  await expect(page.locator("html")).toHaveAttribute("dir", "rtl");
});

test("keeps public decision-support journeys reachable", async ({ page }) => {
  for (const path of [
    "/en/cards",
    "/en/compare",
    "/en/calculator",
    "/en/recommendation",
  ]) {
    await page.goto(path);
    await expect(page.locator("#main-content")).toBeVisible();
    await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
  }
});

test("redirects protected user and administrator routes to safe login", async ({
  page,
}) => {
  await page.goto("/en/account");
  await expect(page).toHaveURL(/\/en\/auth\?next=%2Fen%2Faccount$/);
  await expect(page.getByLabel("Email address")).toBeVisible();
  await page.goto("/en/admin");
  await expect(page).toHaveURL(/\/en\/auth\?next=%2Fen%2Fadmin$/);
  await expect(page.getByLabel("Password")).toBeVisible();
});

test("exposes healthy operational endpoints without secrets", async ({
  request,
}) => {
  const health = await request.get("/api/health");
  expect(health.ok()).toBeTruthy();
  const body = await health.json();
  expect(body).toMatchObject({ status: "ok" });
  expect(JSON.stringify(body)).not.toMatch(/service.role|secret|password/i);
});
