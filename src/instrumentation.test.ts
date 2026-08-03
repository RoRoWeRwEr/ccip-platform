import { beforeEach, describe, expect, it, vi } from "vitest";

const error = vi.fn();

vi.mock("@/lib/logging/logger", () => ({
  getLogger: () => ({ error }),
}));

import { onRequestError } from "./instrumentation";

describe("request error instrumentation", () => {
  beforeEach(() => error.mockClear());

  it("records route metadata without the error, URL, or headers", async () => {
    await onRequestError(
      new Error("secret failure"),
      {
        path: "/en/account?token=secret",
        method: "GET",
        headers: { cookie: "session=secret" },
      },
      {
        routerKind: "App Router",
        routePath: "/[locale]/account",
        routeType: "render",
        revalidateReason: undefined,
      },
    );

    expect(error).toHaveBeenCalledWith(
      {
        event: "request_error",
        method: "GET",
        route: "/[locale]/account",
        routeType: "render",
        router: "App Router",
      },
      "Unhandled request error",
    );
    expect(JSON.stringify(error.mock.calls)).not.toMatch(
      /secret|cookie|token/i,
    );
  });
});
