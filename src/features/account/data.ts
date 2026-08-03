import type { SupabaseClient } from "@supabase/supabase-js";
import type { Database, Json } from "@/types/database";
import { AppError } from "@/lib/errors/app-error";
import type { CardDetail } from "@/features/catalog/data/repository";

type Client = SupabaseClient<Database>;

function dependency(operation: string, cause: unknown) {
  return new AppError("DEPENDENCY_UNAVAILABLE", `${operation} failed`, {
    cause,
  });
}

async function currentUser(client: Client) {
  const { data, error } = await client.auth.getUser();
  if (error) throw dependency("account authentication", error);
  if (!data.user)
    throw new AppError("UNAUTHENTICATED", "Authentication required");
  return data.user;
}

function text(value: Json, key: string) {
  if (!value || Array.isArray(value) || typeof value !== "object") return null;
  const candidate = value[key];
  return typeof candidate === "string" ? candidate : null;
}

export type UserDashboard = {
  email: string;
  profile: {
    displayName: string | null;
    language: string;
    timezone: string;
    onboardingStatus: string;
  } | null;
  collections: Array<{
    id: string;
    name: string;
    nameAr: string | null;
    count: number;
  }>;
  savedCards: Array<{
    id: string;
    collectionId: string;
    cardId: string;
    nameEn: string | null;
    nameAr: string | null;
    slug: string | null;
    savedAt: string;
    pinned: boolean;
  }>;
  comparisons: Array<{
    id: string;
    name: string | null;
    nameAr: string | null;
    status: string;
    cardCount: number;
    startedAt: string;
  }>;
};

export async function loadUserDashboard(
  client: Client,
): Promise<UserDashboard> {
  const user = await currentUser(client);
  const [profileQuery, collectionQuery, savedQuery, comparisonQuery] =
    await Promise.all([
      client
        .from("user_profiles")
        .select(
          "display_name,preferred_language_code,timezone_name,onboarding_status",
        )
        .eq("user_id", user.id)
        .maybeSingle(),
      client
        .from("user_card_collections")
        .select("id,collection_name,collection_name_ar,card_count")
        .eq("user_id", user.id)
        .eq("is_deleted", false)
        .eq("is_archived", false)
        .order("display_order"),
      client
        .from("user_saved_cards")
        .select("id,collection_id,card_id,card_snapshot,saved_at,is_pinned")
        .eq("user_id", user.id)
        .eq("is_removed", false)
        .order("saved_at", { ascending: false })
        .limit(100),
      client
        .from("card_comparisons")
        .select(
          "id,comparison_name,comparison_name_ar,comparison_status,card_count,started_at",
        )
        .eq("user_id", user.id)
        .eq("is_deleted", false)
        .order("started_at", { ascending: false })
        .limit(50),
    ]);
  for (const [operation, result] of [
    ["profile query", profileQuery],
    ["collection query", collectionQuery],
    ["saved cards query", savedQuery],
    ["saved comparisons query", comparisonQuery],
  ] as const) {
    if (result.error) throw dependency(operation, result.error);
  }
  return {
    email: user.email ?? "",
    profile: profileQuery.data
      ? {
          displayName: profileQuery.data.display_name,
          language: profileQuery.data.preferred_language_code,
          timezone: profileQuery.data.timezone_name,
          onboardingStatus: profileQuery.data.onboarding_status,
        }
      : null,
    collections: (collectionQuery.data ?? []).map((collection) => ({
      id: collection.id,
      name: collection.collection_name,
      nameAr: collection.collection_name_ar,
      count: collection.card_count,
    })),
    savedCards: (savedQuery.data ?? []).map((saved) => ({
      id: saved.id,
      collectionId: saved.collection_id,
      cardId: saved.card_id,
      nameEn: text(saved.card_snapshot, "name_en"),
      nameAr: text(saved.card_snapshot, "name_ar"),
      slug: text(saved.card_snapshot, "slug"),
      savedAt: saved.saved_at,
      pinned: saved.is_pinned,
    })),
    comparisons: (comparisonQuery.data ?? []).map((comparison) => ({
      id: comparison.id,
      name: comparison.comparison_name,
      nameAr: comparison.comparison_name_ar,
      status: comparison.comparison_status,
      cardCount: comparison.card_count,
      startedAt: comparison.started_at,
    })),
  };
}

export async function updateUserProfile(
  client: Client,
  input: { displayName: string; language: "ar" | "en" },
) {
  const user = await currentUser(client);
  const displayName = input.displayName.trim();
  const { error } = await client
    .from("user_profiles")
    .update({
      display_name: displayName || null,
      preferred_language_code: input.language,
      onboarding_status: "COMPLETED",
    })
    .eq("user_id", user.id);
  if (error) throw dependency("profile update", error);
}

export async function createCollection(client: Client, name: string) {
  const user = await currentUser(client);
  const normalized = name.trim();
  if (!normalized || normalized.length > 200) {
    throw new AppError("BAD_REQUEST", "Collection name is invalid");
  }
  const { error } = await client.from("user_card_collections").insert({
    user_id: user.id,
    collection_code: `CUSTOM_${Date.now()}`,
    collection_name: normalized,
    collection_type: "CUSTOM",
  });
  if (error) throw dependency("collection creation", error);
}

export async function savePublishedCard(client: Client, card: CardDetail) {
  const user = await currentUser(client);
  const favoritesQuery = await client
    .from("user_card_collections")
    .select("id")
    .eq("user_id", user.id)
    .eq("collection_code", "FAVORITES")
    .eq("is_deleted", false)
    .maybeSingle();
  if (favoritesQuery.error)
    throw dependency("favorites query", favoritesQuery.error);
  let collection = favoritesQuery.data;
  if (!collection) {
    const created = await client
      .from("user_card_collections")
      .insert({
        user_id: user.id,
        collection_code: "FAVORITES",
        collection_name: "Favorites",
        collection_name_ar: "المفضلة",
        collection_type: "FAVORITES",
        is_default: true,
      })
      .select("id")
      .single();
    if (created.error) throw dependency("favorites creation", created.error);
    collection = created.data;
  }
  const { error } = await client.from("user_saved_cards").upsert(
    {
      user_id: user.id,
      collection_id: collection.id,
      card_id: card.id,
      saved_reference: `card:${user.id}:${card.id}`,
      saved_source: "CARD_DETAIL",
      card_snapshot: {
        id: card.id,
        slug: card.slug,
        name_ar: card.nameAr,
        name_en: card.nameEn,
        bank_name_ar: card.bank.nameAr,
        bank_name_en: card.bank.nameEn,
        publication_version: card.publication.versionNumber,
      },
      is_removed: false,
      is_archived: false,
      removed_at: null,
      archived_at: null,
    },
    { onConflict: "collection_id,card_id" },
  );
  if (error) throw dependency("card save", error);
}

export async function removeSavedCard(client: Client, id: string) {
  const user = await currentUser(client);
  const now = new Date().toISOString();
  const { error } = await client
    .from("user_saved_cards")
    .update({
      is_removed: true,
      is_archived: true,
      removed_at: now,
      archived_at: now,
    })
    .eq("id", id)
    .eq("user_id", user.id);
  if (error) throw dependency("saved card removal", error);
}
