import { randomUUID } from "node:crypto";
import { createClient } from "@supabase/supabase-js";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import type { Database } from "@/types/database";

const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const publishableKey = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
const serviceRoleKey = process.env.SUPABASE_TEST_SERVICE_ROLE_KEY;

if (!url || !publishableKey || !serviceRoleKey) {
  throw new Error(
    "Integration tests require local Supabase URL, publishable key, and service-role key",
  );
}

const admin = createClient<Database>(url, serviceRoleKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});
const email = `auth-${randomUUID()}@example.test`;
const password = "integration-password-42";
let userId: string;

beforeAll(async () => {
  const { data, error } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
  });
  if (error) throw error;
  userId = data.user.id;
});

afterAll(async () => {
  if (userId) await admin.auth.admin.deleteUser(userId);
});

describe("Supabase authentication journey", () => {
  it("creates, validates, and clears an authenticated session", async () => {
    const client = createClient<Database>(url, publishableKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: login, error: loginError } =
      await client.auth.signInWithPassword({ email, password });
    expect(loginError).toBeNull();
    expect(login.user?.id).toBe(userId);
    const { data: current, error: userError } = await client.auth.getUser();
    expect(userError).toBeNull();
    expect(current.user?.email).toBe(email);
    await expect(client.auth.signOut()).resolves.toMatchObject({ error: null });
    expect((await client.auth.getSession()).data.session).toBeNull();
  });

  it("keeps password-recovery acceptance non-enumerating", async () => {
    const client = createClient<Database>(url, publishableKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const known = await client.auth.resetPasswordForEmail(email, {
      redirectTo: "http://127.0.0.1:3000/en/auth/callback",
    });
    const unknown = await client.auth.resetPasswordForEmail(
      `missing-${randomUUID()}@example.test`,
      { redirectTo: "http://127.0.0.1:3000/en/auth/callback" },
    );
    expect(known.error).toBeNull();
    expect(unknown.error).toBeNull();
  });
});
