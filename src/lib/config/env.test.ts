import { describe, expect, it } from "vitest";
import { parsePublicEnvironment, parseServerEnvironment } from "./env";

const validEnvironment = {
  NEXT_PUBLIC_SUPABASE_URL: "https://example.supabase.co",
  NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: "sb_publishable_test_key_1234567890",
};

describe("environment validation", () => {
  it("accepts a secure Supabase configuration and applies server defaults", () => {
    expect(parseServerEnvironment(validEnvironment)).toMatchObject({
      ...validEnvironment,
      APP_VERSION: "local",
      LOG_LEVEL: "info",
    });
  });

  it("accepts local HTTP Supabase while rejecting remote insecure URLs", () => {
    expect(
      parsePublicEnvironment({
        ...validEnvironment,
        NEXT_PUBLIC_SUPABASE_URL: "http://127.0.0.1:54321",
      }),
    ).toBeDefined();
    expect(() =>
      parsePublicEnvironment({
        ...validEnvironment,
        NEXT_PUBLIC_SUPABASE_URL: "http://example.com",
      }),
    ).toThrow("Supabase URL must use HTTPS");
  });

  it("fails closed when a required browser value is missing", () => {
    expect(() => parsePublicEnvironment({})).toThrow(
      "NEXT_PUBLIC_SUPABASE_URL",
    );
  });
});
