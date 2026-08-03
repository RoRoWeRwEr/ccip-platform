import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CalculatorPage } from "@/features/calculator/calculator-page";
import {
  spendingCategories,
  type MonthlySpending,
} from "@/features/calculator/calculation";
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
  return { title: locale === "ar" ? "حاسبة الإنفاق" : "Spending calculator" };
}

function one(value: string | string[] | undefined) {
  return Array.isArray(value) ? (value[0] ?? "") : (value ?? "");
}

function boundedNumber(value: string | string[] | undefined, maximum: number) {
  const parsed = Number(one(value));
  return Number.isFinite(parsed) && parsed >= 0 ? Math.min(parsed, maximum) : 0;
}

export default async function CalculatorRoute({
  params,
  searchParams,
}: Readonly<{
  params: Promise<{ locale: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}>) {
  const [{ locale }, query] = await Promise.all([params, searchParams]);
  if (!isLocale(locale)) notFound();
  const selected = /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(one(query.card))
    ? one(query.card)
    : "";
  const spending = Object.fromEntries(
    spendingCategories.map((category) => [
      category,
      boundedNumber(query[category], 100_000),
    ]),
  ) as MonthlySpending;
  const valuation = boundedNumber(query.valuation, 100);
  const client = await createClient();
  const [optionsPage, card] = await Promise.all([
    listPublicCards(client, {
      page: 1,
      pageSize: 50,
      locale,
      sort: "NAME_ASC",
    }),
    selected ? getPublicCardBySlug(client, selected) : Promise.resolve(null),
  ]);
  return (
    <CalculatorPage
      locale={locale}
      options={optionsPage.items}
      card={card}
      selected={selected}
      spending={spending}
      valuation={valuation}
    />
  );
}
