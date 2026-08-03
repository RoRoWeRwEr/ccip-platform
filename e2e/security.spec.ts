import { expect, test } from "@playwright/test";

test("responses enforce the browser security policy without framework disclosure", async ({
  request,
}) => {
  const response = await request.get("/en");
  expect(response.ok()).toBeTruthy();
  const headers = response.headers();
  expect(headers["content-security-policy"]).toContain(
    "frame-ancestors 'none'",
  );
  expect(headers["content-security-policy"]).toContain("object-src 'none'");
  expect(headers["x-frame-options"]).toBe("DENY");
  expect(headers["x-content-type-options"]).toBe("nosniff");
  expect(headers["referrer-policy"]).toBe("strict-origin-when-cross-origin");
  expect(headers["strict-transport-security"]).toContain("max-age=31536000");
  expect(headers["cross-origin-resource-policy"]).toBe("same-origin");
  expect(headers["x-powered-by"]).toBeUndefined();
});

test("hostile authentication destinations remain local", async ({ page }) => {
  await page.goto("/en/auth?next=https%3A%2F%2Fevil.example%2Fsteal");
  await expect(page.getByLabel("Email address")).toBeVisible();
  await expect(page).toHaveURL(/127\.0\.0\.1:3000\/en\/auth/);
  await page.getByRole("button", { name: "Create account" }).click();
  await expect(page.getByLabel("Password")).toBeVisible();
  const externalLinks = await page
    .locator("a")
    .evaluateAll(
      (links) =>
        links.filter((link) =>
          (link as HTMLAnchorElement).href.startsWith("https://evil.example"),
        ).length,
    );
  expect(externalLinks).toBe(0);
});

test("operational failures do not disclose credentials", async ({
  request,
}) => {
  const response = await request.get("/api/ready");
  const body = await response.text();
  expect(body).not.toMatch(/service.role|publishable.key|password|secret|jwt/i);
});
