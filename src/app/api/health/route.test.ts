import { describe, expect, it } from "vitest";
import { GET } from "./route";

describe("health endpoint", () => {
  it("returns a safe non-cached process health response", async () => {
    const response = GET(
      new Request("http://localhost/api/health", {
        headers: { "x-request-id": "test-123" },
      }),
    );
    expect(response.status).toBe(200);
    expect(response.headers.get("cache-control")).toBe("no-store");
    expect(response.headers.get("x-request-id")).toBe("test-123");
    expect(await response.json()).toEqual({
      status: "ok",
      service: "ccip-web",
      version: "local",
      requestId: "test-123",
    });
  });
});
