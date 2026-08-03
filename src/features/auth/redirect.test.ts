import { describe, expect, it } from "vitest";
import { safeNextPath } from "./redirect";

describe("safeNextPath", () => {
  it("accepts local application paths", () => {
    expect(safeNextPath("/en/recommendation?goal=MILES", "en")).toBe(
      "/en/recommendation?goal=MILES",
    );
  });

  it.each([
    [null, "/ar"],
    ["https://evil.example", "/ar"],
    ["//evil.example/path", "/ar"],
    ["javascript:alert(1)", "/ar"],
  ])("rejects unsafe redirect %s", (value, expected) => {
    expect(safeNextPath(value, "ar")).toBe(expected);
  });
});
