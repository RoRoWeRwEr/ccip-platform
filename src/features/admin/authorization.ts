import type { SupabaseClient } from "@supabase/supabase-js";
import { AppError } from "@/lib/errors/app-error";
import type { Database } from "@/types/database";

type Client = SupabaseClient<Database>;

export type AdminAuthorization = {
  email: string;
  isPlatformAdministrator: boolean;
  global: boolean;
  banks: Array<{ id: string; nameAr: string; nameEn: string }>;
};

function dependency(operation: string, cause: unknown) {
  return new AppError("DEPENDENCY_UNAVAILABLE", `${operation} failed`, {
    cause,
  });
}

export async function loadAdminAuthorization(
  client: Client,
): Promise<AdminAuthorization | null> {
  const { data: auth, error: authError } = await client.auth.getUser();
  if (authError) throw dependency("admin authentication", authError);
  if (!auth.user)
    throw new AppError("UNAUTHENTICATED", "Authentication required");

  const platformQuery = await client.rpc("has_active_platform_role", {
    requested_role_code: "PLATFORM_ADMINISTRATOR",
  });
  if (platformQuery.error)
    throw dependency(
      "platform administrator authorization",
      platformQuery.error,
    );

  if (platformQuery.data) {
    return {
      email: auth.user.email ?? "",
      isPlatformAdministrator: true,
      global: true,
      banks: [],
    };
  }

  const globalQuery = await client.rpc("has_active_catalog_scope", {
    // The SQL argument is nullable for GLOBAL scope; generated types cannot
    // currently express null function arguments.
    requested_bank_id: null as unknown as string,
  });
  if (globalQuery.error)
    throw dependency("global catalog authorization", globalQuery.error);
  if (globalQuery.data) {
    return {
      email: auth.user.email ?? "",
      isPlatformAdministrator: false,
      global: true,
      banks: [],
    };
  }

  const bankQuery = await client
    .from("banks")
    .select("id,name_ar,name_en")
    .eq("is_active", true)
    .order("name_en");
  if (bankQuery.error) throw dependency("bank catalog query", bankQuery.error);

  const checks = await Promise.all(
    (bankQuery.data ?? []).map(async (bank) => {
      const result = await client.rpc("has_active_catalog_scope", {
        requested_bank_id: bank.id,
      });
      if (result.error)
        throw dependency("bank catalog authorization", result.error);
      return result.data
        ? { id: bank.id, nameAr: bank.name_ar, nameEn: bank.name_en }
        : null;
    }),
  );
  const banks = checks.filter((bank) => bank !== null);
  if (banks.length === 0) return null;

  return {
    email: auth.user.email ?? "",
    isPlatformAdministrator: false,
    global: false,
    banks,
  };
}
