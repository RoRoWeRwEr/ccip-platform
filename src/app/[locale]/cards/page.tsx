import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CatalogPage } from "@/features/catalog/components/catalog-page";
import {
  listPublicBanks,
  listPublicCards,
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

export default async function CardsRoute({
  params,
  searchParams,
}: Readonly<{
  params: Promise<{ locale: string }>;
  searchParams: Promise<{ page?: string | string[]; bank?: string | string[] }>;
}>) {
  const [{ locale }, query] = await Promise.all([params, searchParams]);
  if (!isLocale(locale)) notFound();

  const page = readPage(query.page);
  const bank = Array.isArray(query.bank) ? query.bank[0] : query.bank;
  const selectedBank = bank?.slice(0, 120) || undefined;
  const client = await createClient();
  const [bankPage, cardPage] = await Promise.all([
    listPublicBanks(client, { page: 1, pageSize: 50 }),
    listPublicCards(client, { page, pageSize: 12, bankSlug: selectedBank }),
  ]);

  return (
    <CatalogPage
      locale={locale}
      banks={bankPage.items}
      cards={cardPage.items}
      page={cardPage.page}
      totalPages={cardPage.totalPages}
      selectedBank={selectedBank}
    />
  );
}
