import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CatalogPage } from "@/features/catalog/components/catalog-page";
import {
  listPublicBanks,
  listPublicCards,
  listPublicNetworks,
} from "@/features/catalog/data/repository";
import { isLocale } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export async function generateMetadata({
  params,
}: Readonly<{ params: Promise<{ locale: string }> }>): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) return {};
  return {
    title:
      locale === "ar" ? "البطاقات الائتمانية السعودية" : "Saudi credit cards",
    description:
      locale === "ar"
        ? "تصفّح البطاقات الائتمانية السعودية المنشورة والمتاحة."
        : "Browse published and available Saudi credit cards.",
  };
}

function readPage(value: string | string[] | undefined) {
  const raw = Array.isArray(value) ? value[0] : value;
  const page = Number(raw ?? "1");
  return Number.isInteger(page) && page >= 1 && page <= 10_000 ? page : 1;
}

function one(value: string | string[] | undefined, max = 120) {
  return (
    (Array.isArray(value) ? value[0] : value)?.trim().slice(0, max) || undefined
  );
}

function nonnegative(value: string | undefined) {
  if (!value) return undefined;
  const number = Number(value);
  return Number.isFinite(number) && number >= 0 && number <= 1_000_000
    ? number
    : undefined;
}

export default async function CardsRoute({
  params,
  searchParams,
}: Readonly<{
  params: Promise<{ locale: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}>) {
  const [{ locale }, query] = await Promise.all([params, searchParams]);
  if (!isLocale(locale)) notFound();

  const page = readPage(query.page);
  const selectedBank = one(query.bank);
  const selectedNetwork = one(query.network);
  const search = one(query.q, 80);
  const fee = nonnegative(one(query.fee));
  const salary = nonnegative(one(query.salary));
  const personaRaw = one(query.persona);
  const persona = [
    "GENERAL",
    "STUDENT",
    "SALARY",
    "PRIVATE_BANKING",
    "BUSINESS",
  ].includes(personaRaw ?? "")
    ? (personaRaw as
        "GENERAL" | "STUDENT" | "SALARY" | "PRIVATE_BANKING" | "BUSINESS")
    : undefined;
  const client = await createClient();
  const [bankPage, networks, cardPage] = await Promise.all([
    listPublicBanks(client, { page: 1, pageSize: 50 }),
    listPublicNetworks(client),
    listPublicCards(client, {
      page,
      pageSize: 12,
      bankSlug: selectedBank,
      networkSlug: selectedNetwork,
      search,
      locale,
      maxAnnualFee: fee,
      targetUser: persona,
      maxMinimumSalary: salary,
    }),
  ]);

  return (
    <CatalogPage
      locale={locale}
      banks={bankPage.items}
      networks={networks}
      cards={cardPage.items}
      page={cardPage.page}
      totalPages={cardPage.totalPages}
      selectedBank={selectedBank}
      filters={{
        q: search,
        network: selectedNetwork,
        fee: fee?.toString(),
        salary: salary?.toString(),
        persona,
      }}
    />
  );
}
