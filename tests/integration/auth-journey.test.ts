import { randomUUID } from "node:crypto";
import { createClient } from "@supabase/supabase-js";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import type { Database } from "@/types/database";
import {
  createCollection,
  loadUserDashboard,
  updateUserProfile,
} from "@/features/account/data";

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
let secondUserId: string;
const secondEmail = `auth-${randomUUID()}@example.test`;

beforeAll(async () => {
  const { data, error } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
  });
  if (error) throw error;
  userId = data.user.id;
  const second = await admin.auth.admin.createUser({
    email: secondEmail,
    password,
    email_confirm: true,
  });
  if (second.error) throw second.error;
  secondUserId = second.data.user.id;
});

afterAll(async () => {
  if (userId) await admin.auth.admin.deleteUser(userId);
  if (secondUserId) await admin.auth.admin.deleteUser(secondUserId);
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

  it("provisions and isolates profile and collection data through authenticated RLS", async () => {
    const owner = createClient<Database>(url, publishableKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const other = createClient<Database>(url, publishableKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    expect(
      (await owner.auth.signInWithPassword({ email, password })).error,
    ).toBeNull();
    expect(
      (await other.auth.signInWithPassword({ email: secondEmail, password }))
        .error,
    ).toBeNull();

    await updateUserProfile(owner, {
      displayName: "Integration Member",
      language: "en",
    });
    await createCollection(owner, "My shortlist");
    await expect(loadUserDashboard(owner)).resolves.toMatchObject({
      email,
      profile: { displayName: "Integration Member", language: "en" },
      collections: [{ name: "My shortlist" }],
    });
    await expect(loadUserDashboard(other)).resolves.toMatchObject({
      email: secondEmail,
      profile: { displayName: null },
      collections: [],
    });
  });
});
