import { describe, expect, it } from "vitest";
import { AppError, toSafeError } from "./app-error";

describe("safe application errors", () => {
  it("exposes safe client errors", () => {
    expect(toSafeError(new AppError("NOT_FOUND", "Card not found"))).toEqual({
      status: 404,
      body: { error: { code: "NOT_FOUND", message: "Card not found" } },
    });
  });

  it("redacts internal errors and unknown exceptions", () => {
    expect(
      toSafeError(new AppError("INTERNAL_ERROR", "database password leaked")),
    ).toEqual({
      status: 500,
      body: { error: { code: "INTERNAL_ERROR", message: "Request failed" } },
    });
    expect(toSafeError(new Error("secret"))).toEqual({
      status: 500,
      body: { error: { code: "INTERNAL_ERROR", message: "Request failed" } },
    });
  });
});
