import type { SupabaseClient } from "@supabase/supabase-js";
import { AppError } from "@/lib/errors/app-error";
import type { Database } from "@/types/database";
import { makePage, parsePagination, toRange, type Page } from "./pagination";

type CatalogClient = SupabaseClient<Database>;

export interface BankSummary {
  id: string;
  slug: string;
  nameAr: string;
  nameEn: string;
  shortNameAr: string | null;
  shortNameEn: string | null;
  logoUrl: string | null;
}

export interface CardSummary {
  id: string;
  slug: string;
  nameAr: string;
  nameEn: string;
  annualFee: number;
  imageUrl: string | null;
  cardTier: string | null;
  targetUser: Database["public"]["Enums"]["target_user_type"];
  minimumSalary: number | null;
  publishedAt: string;
  bank: Pick<BankSummary, "id" | "slug" | "nameAr" | "nameEn" | "logoUrl">;
  network: {
    id: string;
    slug: string;
    nameAr: string;
    nameEn: string;
    logoUrl: string | null;
  };
  loyaltyProgram: {
    id: string;
    slug: string;
    nameAr: string;
    nameEn: string;
    logoUrl: string | null;
  } | null;
}

export interface CardDetail extends CardSummary {
  descriptionAr: string | null;
  descriptionEn: string | null;
  applicationUrl: string | null;
  termsUrl: string | null;
  foreignTransactionFeeRate: number | null;
  fees: Array<{
    id: string;
    feeType: Database["public"]["Enums"]["fee_type"];
    nameAr: string;
    nameEn: string;
    amount: number | null;
    percentage: number | null;
  }>;
  benefits: Array<{
    id: string;
    slug: string;
    nameAr: string;
    nameEn: string;
    descriptionAr: string | null;
    descriptionEn: string | null;
    featured: boolean;
  }>;
}

function dependencyError(operation: string, cause: unknown): AppError {
  return new AppError("DEPENDENCY_UNAVAILABLE", `Catalog ${operation} failed`, {
    cause,
  });
}

export async function listPublicBanks(
  client: CatalogClient,
  input: { page?: unknown; pageSize?: unknown } = {},
): Promise<Page<BankSummary>> {
  const pagination = parsePagination(input);
  const { from, to } = toRange(pagination);
  const { data, error, count } = await client
    .from("banks")
    .select("id,slug,name_ar,name_en,short_name_ar,short_name_en,logo_url", {
      count: "exact",
    })
    .eq("is_active", true)
    .order("name_en", { ascending: true })
    .order("id", { ascending: true })
    .range(from, to);

  if (error) throw dependencyError("bank query", error);
  const items = (data ?? []).map((bank) => ({
    id: bank.id,
    slug: bank.slug,
    nameAr: bank.name_ar,
    nameEn: bank.name_en,
    shortNameAr: bank.short_name_ar,
    shortNameEn: bank.short_name_en,
    logoUrl: bank.logo_url,
  }));
  return makePage(items, count, pagination);
}

export async function listPublicCards(
  client: CatalogClient,
  input: { page?: unknown; pageSize?: unknown; bankSlug?: string } = {},
): Promise<Page<CardSummary>> {
  const pagination = parsePagination(input);
  const { from, to } = toRange(pagination);
  let query = client
    .from("cards")
    .select(
      "id,slug,name_ar,name_en,annual_fee,image_url,card_tier,target_user,minimum_salary,published_at,bank:banks!inner(id,slug,name_ar,name_en,logo_url),network:card_networks!inner(id,slug,name_ar,name_en,logo_url),loyalty_program:loyalty_programs(id,slug,name_ar,name_en,logo_url)",
      { count: "exact" },
    )
    .eq("is_active", true)
    .eq("availability_status", "AVAILABLE")
    .not("published_at", "is", null)
    .lte("published_at", new Date().toISOString())
    .order("published_at", { ascending: false })
    .order("id", { ascending: true })
    .range(from, to);

  if (input.bankSlug) query = query.eq("banks.slug", input.bankSlug);
  const { data, error, count } = await query;
  if (error) throw dependencyError("card query", error);

  const items = (data ?? []).flatMap((card) => {
    if (!card.published_at || !card.bank || !card.network) return [];
    return [
      {
        id: card.id,
        slug: card.slug,
        nameAr: card.name_ar,
        nameEn: card.name_en,
        annualFee: card.annual_fee,
        imageUrl: card.image_url,
        cardTier: card.card_tier,
        targetUser: card.target_user,
        minimumSalary: card.minimum_salary,
        publishedAt: card.published_at,
        bank: {
          id: card.bank.id,
          slug: card.bank.slug,
          nameAr: card.bank.name_ar,
          nameEn: card.bank.name_en,
          logoUrl: card.bank.logo_url,
        },
        network: {
          id: card.network.id,
          slug: card.network.slug,
          nameAr: card.network.name_ar,
          nameEn: card.network.name_en,
          logoUrl: card.network.logo_url,
        },
        loyaltyProgram: card.loyalty_program
          ? {
              id: card.loyalty_program.id,
              slug: card.loyalty_program.slug,
              nameAr: card.loyalty_program.name_ar,
              nameEn: card.loyalty_program.name_en,
              logoUrl: card.loyalty_program.logo_url,
            }
          : null,
      } satisfies CardSummary,
    ];
  });
  return makePage(items, count, pagination);
}

export async function getPublicCardBySlug(
  client: CatalogClient,
  slug: string,
): Promise<CardDetail | null> {
  const { data: card, error } = await client
    .from("cards")
    .select(
      "id,slug,name_ar,name_en,description_ar,description_en,annual_fee,image_url,card_tier,target_user,minimum_salary,published_at,application_url,terms_url,foreign_transaction_fee_rate,bank:banks!inner(id,slug,name_ar,name_en,logo_url),network:card_networks!inner(id,slug,name_ar,name_en,logo_url),loyalty_program:loyalty_programs(id,slug,name_ar,name_en,logo_url)",
    )
    .eq("slug", slug)
    .eq("is_active", true)
    .eq("availability_status", "AVAILABLE")
    .not("published_at", "is", null)
    .lte("published_at", new Date().toISOString())
    .maybeSingle();

  if (error) throw dependencyError("card detail query", error);
  if (!card?.published_at || !card.bank || !card.network) return null;

  const [
    { data: fees, error: feesError },
    { data: benefits, error: benefitsError },
  ] = await Promise.all([
    client
      .from("card_fees")
      .select("id,fee_type,name_ar,name_en,amount,percentage")
      .eq("card_id", card.id)
      .eq("is_active", true)
      .order("fee_type")
      .order("id"),
    client
      .from("card_benefits")
      .select(
        "id,slug,name_ar,name_en,description_ar,description_en,is_featured",
      )
      .eq("card_id", card.id)
      .eq("is_active", true)
      .order("display_order")
      .order("id"),
  ]);
  if (feesError || benefitsError)
    throw dependencyError(
      "card relationship query",
      feesError ?? benefitsError,
    );

  return {
    id: card.id,
    slug: card.slug,
    nameAr: card.name_ar,
    nameEn: card.name_en,
    descriptionAr: card.description_ar,
    descriptionEn: card.description_en,
    annualFee: card.annual_fee,
    imageUrl: card.image_url,
    cardTier: card.card_tier,
    targetUser: card.target_user,
    minimumSalary: card.minimum_salary,
    publishedAt: card.published_at,
    applicationUrl: card.application_url,
    termsUrl: card.terms_url,
    foreignTransactionFeeRate: card.foreign_transaction_fee_rate,
    bank: {
      id: card.bank.id,
      slug: card.bank.slug,
      nameAr: card.bank.name_ar,
      nameEn: card.bank.name_en,
      logoUrl: card.bank.logo_url,
    },
    network: {
      id: card.network.id,
      slug: card.network.slug,
      nameAr: card.network.name_ar,
      nameEn: card.network.name_en,
      logoUrl: card.network.logo_url,
    },
    loyaltyProgram: card.loyalty_program
      ? {
          id: card.loyalty_program.id,
          slug: card.loyalty_program.slug,
          nameAr: card.loyalty_program.name_ar,
          nameEn: card.loyalty_program.name_en,
          logoUrl: card.loyalty_program.logo_url,
        }
      : null,
    fees: (fees ?? []).map((fee) => ({
      id: fee.id,
      feeType: fee.fee_type,
      nameAr: fee.name_ar,
      nameEn: fee.name_en,
      amount: fee.amount,
      percentage: fee.percentage,
    })),
    benefits: (benefits ?? []).map((benefit) => ({
      id: benefit.id,
      slug: benefit.slug,
      nameAr: benefit.name_ar,
      nameEn: benefit.name_en,
      descriptionAr: benefit.description_ar,
      descriptionEn: benefit.description_en,
      featured: benefit.is_featured,
    })),
  };
}
