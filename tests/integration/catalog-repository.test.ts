import { createClient } from "@supabase/supabase-js";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  getPublicCardBySlug,
  listPublicBanks,
  listPublicCards,
} from "@/features/catalog/data/repository";
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
const publicClient = createClient<Database>(url, publishableKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

const ids = {
  country: "f1000000-0000-4000-8000-000000000001",
  currency: "f1000000-0000-4000-8000-000000000002",
  network: "f1000000-0000-4000-8000-000000000003",
  bank: "f1000000-0000-4000-8000-000000000004",
  publishedCard: "f1000000-0000-4000-8000-000000000005",
  draftCard: "f1000000-0000-4000-8000-000000000006",
  fee: "f1000000-0000-4000-8000-000000000007",
  benefit: "f1000000-0000-4000-8000-000000000008",
};

async function cleanup() {
  await admin.from("card_benefits").delete().eq("id", ids.benefit);
  await admin.from("card_fees").delete().eq("id", ids.fee);
  await admin
    .from("cards")
    .delete()
    .in("id", [ids.publishedCard, ids.draftCard]);
  await admin.from("banks").delete().eq("id", ids.bank);
  await admin.from("card_networks").delete().eq("id", ids.network);
  await admin.from("currencies").delete().eq("id", ids.currency);
  await admin.from("countries").delete().eq("id", ids.country);
}

beforeAll(async () => {
  await cleanup();
  const { error: referenceError } = await admin.from("countries").insert({
    id: ids.country,
    code: "ZZ",
    slug: "integration-country",
    name_ar: "بلد الاختبار",
    name_en: "Integration Country",
  });
  if (referenceError) throw referenceError;
  const { error: currencyError } = await admin.from("currencies").insert({
    id: ids.currency,
    code: "TST",
    slug: "integration-currency",
    name_ar: "عملة الاختبار",
    name_en: "Integration Currency",
    symbol: "T",
  });
  if (currencyError) throw currencyError;
  const { error: networkError } = await admin.from("card_networks").insert({
    id: ids.network,
    slug: "integration-network",
    name_ar: "شبكة الاختبار",
    name_en: "Integration Network",
  });
  if (networkError) throw networkError;
  const { error: bankError } = await admin.from("banks").insert({
    id: ids.bank,
    country_id: ids.country,
    slug: "integration-bank",
    name_ar: "بنك الاختبار",
    name_en: "Integration Bank",
  });
  if (bankError) throw bankError;
  const { error: cardError } = await admin.from("cards").insert([
    {
      id: ids.publishedCard,
      bank_id: ids.bank,
      card_network_id: ids.network,
      currency_id: ids.currency,
      slug: "integration-published-card",
      name_ar: "بطاقة منشورة",
      name_en: "Published Integration Card",
      published_at: new Date(Date.now() - 60_000).toISOString(),
      annual_fee: 500,
    },
    {
      id: ids.draftCard,
      bank_id: ids.bank,
      card_network_id: ids.network,
      currency_id: ids.currency,
      slug: "integration-draft-card",
      name_ar: "بطاقة مسودة",
      name_en: "Draft Integration Card",
      published_at: null,
      annual_fee: 0,
    },
  ]);
  if (cardError) throw cardError;
  const { error: feeError } = await admin.from("card_fees").insert({
    id: ids.fee,
    card_id: ids.publishedCard,
    fee_type: "ANNUAL",
    name_ar: "الرسوم السنوية",
    name_en: "Annual fee",
    amount: 500,
    currency_id: ids.currency,
  });
  if (feeError) throw feeError;
  const { error: benefitError } = await admin.from("card_benefits").insert({
    id: ids.benefit,
    card_id: ids.publishedCard,
    slug: "integration-benefit",
    name_ar: "ميزة الاختبار",
    name_en: "Integration benefit",
    is_featured: true,
  });
  if (benefitError) throw benefitError;
});

afterAll(cleanup);

describe("public catalog repository against local RLS", () => {
  it("returns active banks through the anonymous role", async () => {
    const page = await listPublicBanks(publicClient, { page: 1, pageSize: 10 });
    expect(page.items.some((bank) => bank.slug === "integration-bank")).toBe(
      true,
    );
  });

  it("returns only published cards and supports a bank filter", async () => {
    const page = await listPublicCards(publicClient, {
      page: 1,
      pageSize: 10,
      bankSlug: "integration-bank",
    });
    expect(page.items.map((card) => card.slug)).toContain(
      "integration-published-card",
    );
    expect(page.items.map((card) => card.slug)).not.toContain(
      "integration-draft-card",
    );
  });

  it("loads a published card with active fees and benefits", async () => {
    const card = await getPublicCardBySlug(
      publicClient,
      "integration-published-card",
    );
    expect(card).toMatchObject({
      annualFee: 500,
      bank: { slug: "integration-bank" },
      fees: [{ amount: 500 }],
      benefits: [{ slug: "integration-benefit", featured: true }],
    });
  });

  it("fails closed for an unpublished card", async () => {
    await expect(
      getPublicCardBySlug(publicClient, "integration-draft-card"),
    ).resolves.toBeNull();
  });
});
