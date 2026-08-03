// @vitest-environment node

import { createServer } from "node:http";
import { afterEach, describe, expect, it } from "vitest";
import { checkReadiness } from "./readiness";

const originalUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const originalKey = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

afterEach(() => {
  if (originalUrl === undefined) delete process.env.NEXT_PUBLIC_SUPABASE_URL;
  else process.env.NEXT_PUBLIC_SUPABASE_URL = originalUrl;
  if (originalKey === undefined)
    delete process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  else process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY = originalKey;
});

describe("readiness dependency probe", () => {
  it("aborts a stalled dependency within the configured timeout", async () => {
    const server = createServer(() => undefined);
    await new Promise<void>((resolve) =>
      server.listen(0, "127.0.0.1", resolve),
    );
    const address = server.address();
    if (!address || typeof address === "string")
      throw new Error("No test port");

    process.env.NEXT_PUBLIC_SUPABASE_URL = `http://127.0.0.1:${address.port}`;
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY =
      "test-publishable-key-with-safe-length";

    const startedAt = performance.now();
    await expect(checkReadiness({ timeoutMs: 25 })).rejects.toThrow();
    expect(performance.now() - startedAt).toBeLessThan(1_000);
    await new Promise<void>((resolve, reject) =>
      server.close((error) => (error ? reject(error) : resolve())),
    );
  });
});
