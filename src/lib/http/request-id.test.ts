import { describe, expect, it } from "vitest";
import { getRequestId } from "./request-id";

describe("request correlation", () => {
  it("preserves a safe upstream request id", () => {
    expect(
      getRequestId(new Headers({ "x-request-id": "edge:request-123" })),
    ).toBe("edge:request-123");
  });

  it("replaces unsafe or oversized values", () => {
    expect(
      getRequestId(new Headers({ "x-request-id": "unsafe value\n" })),
    ).toMatch(/^[0-9a-f-]{36}$/);
    expect(
      getRequestId(new Headers({ "x-request-id": "x".repeat(129) })),
    ).toMatch(/^[0-9a-f-]{36}$/);
  });
});
