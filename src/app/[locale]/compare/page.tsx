import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { ComparisonPage } from "@/features/comparison/comparison-page";
import {
  getPublicCardBySlug,
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
    title: locale === "ar" ? "مقارنة البطاقات" : "Compare credit cards",
  };
}

function selections(value: string | string[] | undefined) {
  const values = Array.isArray(value) ? value : value ? [value] : [];
  return [
    ...new Set(
      values
        .flatMap((entry) => entry.split(","))
        .map((entry) => entry.trim())
        .filter((entry) => /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(entry)),
    ),
  ].slice(0, 3);
}

export default async function CompareRoute({
  params,
  searchParams,
}: Readonly<{
  params: Promise<{ locale: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}>) {
  const [{ locale }, query] = await Promise.all([params, searchParams]);
  if (!isLocale(locale)) notFound();
  const selected = selections(query.card ?? query.cards);
  const client = await createClient();
  const [optionsPage, selectedCards] = await Promise.all([
    listPublicCards(client, {
      page: 1,
      pageSize: 50,
      locale,
      sort: "NAME_ASC",
    }),
    Promise.all(selected.map((slug) => getPublicCardBySlug(client, slug))),
  ]);
  return (
    <ComparisonPage
      locale={locale}
      options={optionsPage.items}
      cards={selectedCards.filter((card) => card !== null)}
      selected={selected}
    />
  );
}
