import type { SupabaseClient } from "@supabase/supabase-js";
import { z } from "zod";
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

export interface NetworkSummary {
  id: string;
  slug: string;
  nameAr: string;
  nameEn: string;
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

export interface CardDetail {
  id: string;
  slug: string;
  nameAr: string;
  nameEn: string;
  descriptionAr: string | null;
  descriptionEn: string | null;
  annualFee: number;
  minimumSalary: number | null;
  imageUrl: string | null;
  cardTier: string | null;
  targetUser: string | null;
  applicationUrl: string | null;
  termsUrl: string | null;
  foreignTransactionFeeRate: number | null;
  bank: {
    id: string;
    slug: string;
    nameAr: string;
    nameEn: string;
    logoUrl: string | null;
  };
  network: {
    id: string;
    slug: string;
    nameAr: string;
    nameEn: string;
    logoUrl: string | null;
  };
  currency: { code: string; symbol: string | null; decimalPlaces: number };
  loyaltyProgram: {
    id: string;
    slug: string;
    nameAr: string;
    nameEn: string;
    type: string | null;
    logoUrl: string | null;
    websiteUrl: string | null;
  } | null;
  fees: Array<{
    id: string;
    feeType: Database["public"]["Enums"]["fee_type"];
    nameAr: string;
    nameEn: string;
    amount: number | null;
    percentage: number | null;
    descriptionAr: string | null;
    descriptionEn: string | null;
    billingPeriod: string | null;
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
  rewardRules: Array<{
    id: string;
    rewardType: string;
    calculationMethod: string;
    rewardValue: number;
    minimumSpend: number | null;
    capAmount: number | null;
    capPeriod: string | null;
    targets: Array<{
      id: string;
      nameAr: string | null;
      nameEn: string | null;
      categorySlug: string | null;
    }>;
  }>;
  eligibility: Array<{
    id: string;
    requirementType: string;
    nameAr: string;
    nameEn: string;
    descriptionAr: string | null;
    descriptionEn: string | null;
    minimumAmount: number | null;
    maximumAmount: number | null;
    minimumAge: number | null;
    maximumAge: number | null;
    mandatory: boolean;
  }>;
  merchants: Array<{
    id: string;
    slug: string;
    nameAr: string;
    nameEn: string;
    classification: string | null;
    channelType: string | null;
  }>;
  publication: {
    versionNumber: number;
    effectiveFrom: string;
    effectiveUntil: string | null;
    publishedAt: string;
  };
  provenance: {
    sourceType: string;
    authorityLevel: string;
    sourceLocator: string;
    sourceTitle: string;
    sourceOwner: string;
    retrievedAt: string;
    verifiedAt: string;
  } | null;
}

const nullableString = z
  .string()
  .nullable()
  .optional()
  .transform((value) => value ?? null);
const nullableNumber = z
  .number()
  .nonnegative()
  .nullable()
  .optional()
  .transform((value) => value ?? null);
const publishedCardDetailSchema = z.object({
  card: z.object({
    id: z.string().uuid(),
    slug: z.string(),
    name_ar: z.string(),
    name_en: z.string(),
    description_ar: nullableString,
    description_en: nullableString,
    annual_fee: z.number().nonnegative(),
    minimum_salary: nullableNumber,
    image_url: nullableString,
    card_tier: nullableString,
    target_user: nullableString,
    application_url: nullableString,
    terms_url: nullableString,
    foreign_transaction_fee_rate: nullableNumber,
  }),
  bank: z.object({
    id: z.string().uuid(),
    slug: z.string(),
    name_ar: z.string(),
    name_en: z.string(),
    logo_url: nullableString,
  }),
  network: z.object({
    id: z.string().uuid(),
    slug: z.string(),
    name_ar: z.string(),
    name_en: z.string(),
    logo_url: nullableString,
  }),
  currency: z.object({
    code: z.string(),
    symbol: nullableString,
    decimal_places: z.number().int().nonnegative(),
  }),
  loyalty_program: z
    .object({
      id: z.string().uuid(),
      slug: z.string(),
      name_ar: z.string(),
      name_en: z.string(),
      type: nullableString,
      logo_url: nullableString,
      website_url: nullableString,
    })
    .nullable(),
  fees: z.array(
    z.object({
      id: z.string().uuid(),
      fee_type: z.string(),
      name_ar: z.string(),
      name_en: z.string(),
      description_ar: nullableString,
      description_en: nullableString,
      amount: nullableNumber,
      percentage: nullableNumber,
      billing_period: nullableString,
    }),
  ),
  benefits: z.array(
    z.object({
      id: z.string().uuid(),
      slug: z.string(),
      name_ar: z.string(),
      name_en: z.string(),
      description_ar: nullableString,
      description_en: nullableString,
      is_featured: z.boolean().optional().default(false),
    }),
  ),
  reward_rules: z.array(
    z.object({
      id: z.string().uuid(),
      reward_type: z.string(),
      calculation_method: z.string(),
      reward_value: z.number().nonnegative(),
      minimum_spend: nullableNumber,
      cap_amount: nullableNumber,
      cap_period: nullableString,
      targets: z.array(
        z.object({
          id: z.string().uuid(),
          category_slug: nullableString,
          merchant_category: z
            .object({ name_ar: z.string(), name_en: z.string() })
            .nullable()
            .optional(),
        }),
      ),
    }),
  ),
  eligibility: z.array(
    z.object({
      id: z.string().uuid(),
      requirement_type: z.string(),
      name_ar: z.string(),
      name_en: z.string(),
      description_ar: nullableString,
      description_en: nullableString,
      minimum_amount: nullableNumber,
      maximum_amount: nullableNumber,
      minimum_age: nullableNumber,
      maximum_age: nullableNumber,
      is_mandatory: z.boolean().optional().default(true),
    }),
  ),
  merchants: z.array(
    z.object({
      id: z.string().uuid(),
      slug: z.string(),
      display_name_ar: z.string(),
      display_name_en: z.string(),
      merchant_classification: nullableString,
      channel_type: nullableString,
    }),
  ),
  publication: z.object({
    version_number: z.number().int().positive(),
    effective_from: z.string(),
    effective_until: nullableString,
    published_at: z.string(),
  }),
  provenance: z
    .object({
      source_type: z.string(),
      authority_level: z.string(),
      source_locator: z.string(),
      source_title: z.string(),
      source_owner: z.string(),
      retrieved_at: z.string(),
      verified_at: z.string(),
    })
    .nullable(),
});

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

export async function listPublicNetworks(
  client: CatalogClient,
): Promise<NetworkSummary[]> {
  const { data, error } = await client
    .from("card_networks")
    .select("id,slug,name_ar,name_en")
    .eq("is_active", true)
    .order("name_en")
    .limit(50);
  if (error) throw dependencyError("network query", error);
  return (data ?? []).map((network) => ({
    id: network.id,
    slug: network.slug,
    nameAr: network.name_ar,
    nameEn: network.name_en,
  }));
}

export async function listPublicCards(
  client: CatalogClient,
  input: {
    page?: unknown;
    pageSize?: unknown;
    bankSlug?: string;
    networkSlug?: string;
    search?: string;
    locale?: "ar" | "en";
    maxAnnualFee?: number;
    targetUser?: Database["public"]["Enums"]["target_user_type"];
    maxMinimumSalary?: number;
  } = {},
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
  if (input.networkSlug)
    query = query.eq("card_networks.slug", input.networkSlug);
  if (input.search)
    query = query.ilike(
      input.locale === "ar" ? "name_ar" : "name_en",
      `%${input.search.replaceAll("%", "\\%").replaceAll("_", "\\_")}%`,
    );
  if (input.maxAnnualFee !== undefined)
    query = query.lte("annual_fee", input.maxAnnualFee);
  if (input.targetUser) query = query.eq("target_user", input.targetUser);
  if (input.maxMinimumSalary !== undefined)
    query = query.lte("minimum_salary", input.maxMinimumSalary);
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
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug)) return null;
  const { data, error } = await client.rpc("get_published_card_detail", {
    requested_slug: slug,
  });
  if (error) throw dependencyError("published card detail query", error);
  if (data === null) return null;

  const parsed = publishedCardDetailSchema.safeParse(data);
  if (!parsed.success)
    throw dependencyError("published card detail validation", parsed.error);
  const value = parsed.data;
  return {
    id: value.card.id,
    slug: value.card.slug,
    nameAr: value.card.name_ar,
    nameEn: value.card.name_en,
    descriptionAr: value.card.description_ar,
    descriptionEn: value.card.description_en,
    annualFee: value.card.annual_fee,
    minimumSalary: value.card.minimum_salary,
    imageUrl: value.card.image_url,
    cardTier: value.card.card_tier,
    targetUser: value.card.target_user,
    applicationUrl: value.card.application_url,
    termsUrl: value.card.terms_url,
    foreignTransactionFeeRate: value.card.foreign_transaction_fee_rate,
    bank: {
      id: value.bank.id,
      slug: value.bank.slug,
      nameAr: value.bank.name_ar,
      nameEn: value.bank.name_en,
      logoUrl: value.bank.logo_url,
    },
    network: {
      id: value.network.id,
      slug: value.network.slug,
      nameAr: value.network.name_ar,
      nameEn: value.network.name_en,
      logoUrl: value.network.logo_url,
    },
    currency: {
      code: value.currency.code,
      symbol: value.currency.symbol,
      decimalPlaces: value.currency.decimal_places,
    },
    loyaltyProgram: value.loyalty_program
      ? {
          id: value.loyalty_program.id,
          slug: value.loyalty_program.slug,
          nameAr: value.loyalty_program.name_ar,
          nameEn: value.loyalty_program.name_en,
          type: value.loyalty_program.type,
          logoUrl: value.loyalty_program.logo_url,
          websiteUrl: value.loyalty_program.website_url,
        }
      : null,
    fees: value.fees.map((fee) => ({
      id: fee.id,
      feeType: fee.fee_type as Database["public"]["Enums"]["fee_type"],
      nameAr: fee.name_ar,
      nameEn: fee.name_en,
      descriptionAr: fee.description_ar,
      descriptionEn: fee.description_en,
      amount: fee.amount,
      percentage: fee.percentage,
      billingPeriod: fee.billing_period,
    })),
    benefits: value.benefits.map((benefit) => ({
      id: benefit.id,
      slug: benefit.slug,
      nameAr: benefit.name_ar,
      nameEn: benefit.name_en,
      descriptionAr: benefit.description_ar,
      descriptionEn: benefit.description_en,
      featured: benefit.is_featured,
    })),
    rewardRules: value.reward_rules.map((rule) => ({
      id: rule.id,
      rewardType: rule.reward_type,
      calculationMethod: rule.calculation_method,
      rewardValue: rule.reward_value,
      minimumSpend: rule.minimum_spend,
      capAmount: rule.cap_amount,
      capPeriod: rule.cap_period,
      targets: rule.targets.map((target) => ({
        id: target.id,
        nameAr: target.merchant_category?.name_ar ?? null,
        nameEn: target.merchant_category?.name_en ?? null,
        categorySlug: target.category_slug,
      })),
    })),
    eligibility: value.eligibility.map((item) => ({
      id: item.id,
      requirementType: item.requirement_type,
      nameAr: item.name_ar,
      nameEn: item.name_en,
      descriptionAr: item.description_ar,
      descriptionEn: item.description_en,
      minimumAmount: item.minimum_amount,
      maximumAmount: item.maximum_amount,
      minimumAge: item.minimum_age,
      maximumAge: item.maximum_age,
      mandatory: item.is_mandatory,
    })),
    merchants: value.merchants.map((merchant) => ({
      id: merchant.id,
      slug: merchant.slug,
      nameAr: merchant.display_name_ar,
      nameEn: merchant.display_name_en,
      classification: merchant.merchant_classification,
      channelType: merchant.channel_type,
    })),
    publication: {
      versionNumber: value.publication.version_number,
      effectiveFrom: value.publication.effective_from,
      effectiveUntil: value.publication.effective_until,
      publishedAt: value.publication.published_at,
    },
    provenance: value.provenance
      ? {
          sourceType: value.provenance.source_type,
          authorityLevel: value.provenance.authority_level,
          sourceLocator: value.provenance.source_locator,
          sourceTitle: value.provenance.source_title,
          sourceOwner: value.provenance.source_owner,
          retrievedAt: value.provenance.retrieved_at,
          verifiedAt: value.provenance.verified_at,
        }
      : null,
  };
}
