import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { RecommendationPage } from "@/features/recommendation/recommendation-page";
import {
  spendingCategories,
  type MonthlySpending,
} from "@/features/calculator/calculation";
import type { RecommendationGoal } from "@/features/recommendation/engine";
import { listRecommendationCandidates } from "@/features/catalog/data/repository";
import { isLocale } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";
export async function generateMetadata({
  params,
}: Readonly<{ params: Promise<{ locale: string }> }>): Promise<Metadata> {
  const { locale } = await params;
  return isLocale(locale)
    ? { title: locale === "ar" ? "توصية البطاقة" : "Card recommendation" }
    : {};
}
function one(value: string | string[] | undefined) {
  return Array.isArray(value) ? (value[0] ?? "") : (value ?? "");
}
function bounded(value: string | string[] | undefined, maximum: number) {
  const parsed = Number(one(value));
  return Number.isFinite(parsed) && parsed >= 0 ? Math.min(parsed, maximum) : 0;
}
export default async function RecommendationRoute({
  params,
  searchParams,
}: Readonly<{
  params: Promise<{ locale: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}>) {
  const [{ locale }, query] = await Promise.all([params, searchParams]);
  if (!isLocale(locale)) notFound();
  const goals: RecommendationGoal[] = ["CASHBACK", "MILES", "GENERAL_VALUE"];
  const goal = goals.includes(one(query.goal) as RecommendationGoal)
    ? (one(query.goal) as RecommendationGoal)
    : "GENERAL_VALUE";
  const spending = Object.fromEntries(
    spendingCategories.map((category) => [
      category,
      bounded(query[category], 100000),
    ]),
  ) as MonthlySpending;
  const optional = (value: string | string[] | undefined, maximum: number) =>
    one(value) === "" ? null : bounded(value, maximum);
  const client = await createClient();
  const candidates = await listRecommendationCandidates(client);
  return (
    <RecommendationPage
      locale={locale}
      candidates={candidates}
      goal={goal}
      spending={spending}
      salary={optional(query.salary, 1000000)}
      maximumFee={optional(query.fee, 1000000)}
      pointsValue={bounded(query.points, 100)}
      milesValue={bounded(query.miles, 100)}
      submitted={Object.keys(query).length > 0}
    />
  );
}
