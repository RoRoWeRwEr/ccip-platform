import type { SupabaseClient } from "@supabase/supabase-js";
import { z } from "zod";
import { AppError } from "@/lib/errors/app-error";
import type { Database } from "@/types/database";
import type { AdminAuthorization } from "./authorization";

type Client = SupabaseClient<Database>;
const provenanceInput = z.object({
  target: z.string().regex(/^(BANK|CARD):[0-9a-f-]{36}$/i),
  title: z.string().trim().min(1).max(500),
  owner: z.string().trim().min(1).max(300),
  url: z
    .string()
    .trim()
    .url()
    .max(2048)
    .regex(/^https:\/\//i),
});
const merchantInput = z.object({
  slug: z
    .string()
    .trim()
    .regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/),
  nameEn: z.string().trim().min(1).max(300),
  nameAr: z.string().trim().min(1).max(300),
});
function failure(operation: string, cause: unknown) {
  return new AppError("DEPENDENCY_UNAVAILABLE", `${operation} failed`, {
    cause,
  });
}

export type AdminWorkspace = {
  targets: Array<{ value: string; nameAr: string; nameEn: string }>;
  sources: Array<{ id: string; title: string; target: string; state: string }>;
  merchants: Array<{
    id: string;
    slug: string;
    nameAr: string;
    nameEn: string;
    state: string;
  }>;
};

export async function loadAdminWorkspace(
  client: Client,
  authorization: AdminAuthorization,
): Promise<AdminWorkspace> {
  const [banks, cards, sources, merchants] = await Promise.all([
    client
      .from("banks")
      .select("id,name_ar,name_en")
      .eq("is_active", true)
      .order("name_en"),
    client
      .from("cards")
      .select("id,bank_id,name_ar,name_en")
      .order("name_en")
      .limit(500),
    client
      .from("catalog_source_provenance")
      .select(
        "id,target_entity_type,source_title,verification_status,lifecycle_status",
      )
      .order("created_at", { ascending: false })
      .limit(100),
    authorization.global
      ? client
          .from("merchants")
          .select(
            "id,slug,display_name_ar,display_name_en,verification_status,lifecycle_status",
          )
          .order("created_at", { ascending: false })
          .limit(100)
      : Promise.resolve({ data: [], error: null }),
  ]);
  for (const [name, result] of [
    ["banks", banks],
    ["cards", cards],
    ["provenance", sources],
    ["merchants", merchants],
  ] as const) {
    if (result.error) throw failure(`admin ${name} query`, result.error);
  }
  const allowed = new Set(
    authorization.global
      ? (banks.data ?? []).map((bank) => bank.id)
      : authorization.banks.map((bank) => bank.id),
  );
  return {
    targets: [
      ...(banks.data ?? [])
        .filter((bank) => allowed.has(bank.id))
        .map((bank) => ({
          value: `BANK:${bank.id}`,
          nameAr: `بنك: ${bank.name_ar}`,
          nameEn: `Bank: ${bank.name_en}`,
        })),
      ...(cards.data ?? [])
        .filter((card) => allowed.has(card.bank_id))
        .map((card) => ({
          value: `CARD:${card.id}`,
          nameAr: `بطاقة: ${card.name_ar}`,
          nameEn: `Card: ${card.name_en}`,
        })),
    ],
    sources: (sources.data ?? []).map((source) => ({
      id: source.id,
      title: source.source_title,
      target: source.target_entity_type,
      state: `${source.verification_status} / ${source.lifecycle_status}`,
    })),
    merchants: (merchants.data ?? []).map((merchant) => ({
      id: merchant.id,
      slug: merchant.slug,
      nameAr: merchant.display_name_ar,
      nameEn: merchant.display_name_en,
      state: `${merchant.verification_status} / ${merchant.lifecycle_status}`,
    })),
  };
}

export async function createProvenance(client: Client, input: unknown) {
  const parsed = provenanceInput.safeParse(input);
  if (!parsed.success)
    throw new AppError("BAD_REQUEST", "Invalid provenance input");
  const [type, id] = parsed.data.target.split(":") as ["BANK" | "CARD", string];
  const { error } = await client.from("catalog_source_provenance").insert({
    target_entity_type: type,
    ...(type === "BANK" ? { bank_id: id } : { card_id: id }),
    source_type:
      type === "BANK" ? "OFFICIAL_BANK_WEBSITE" : "OFFICIAL_PRODUCT_PAGE",
    authority_level: "OFFICIAL_PRIMARY",
    source_locator: parsed.data.url,
    source_title: parsed.data.title,
    source_owner: parsed.data.owner,
  });
  if (error) throw failure("provenance creation", error);
}

export async function createMerchant(client: Client, input: unknown) {
  const parsed = merchantInput.safeParse(input);
  if (!parsed.success)
    throw new AppError("BAD_REQUEST", "Invalid merchant input");
  const scope = await client.rpc("has_active_catalog_scope", {
    requested_bank_id: null as unknown as string,
  });
  if (scope.error) throw failure("global authorization", scope.error);
  if (!scope.data) throw new AppError("FORBIDDEN", "GLOBAL scope required");
  const { error } = await client.from("merchants").insert({
    slug: parsed.data.slug,
    display_name_en: parsed.data.nameEn,
    display_name_ar: parsed.data.nameAr,
  });
  if (error) throw failure("merchant creation", error);
}
