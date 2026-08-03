import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { cache } from "react";
import { CardDetailPage } from "@/features/catalog/components/card-detail-page";
import { getPublicCardBySlug } from "@/features/catalog/data/repository";
import { isLocale } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

const load = cache(async (locale: string, slug: string) => {
  if (!isLocale(locale) || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug)) notFound();
  const card = await getPublicCardBySlug(await createClient(), slug);
  if (!card) notFound();
  return { locale, card } as const;
});

export async function generateMetadata({
  params,
}: Readonly<{
  params: Promise<{ locale: string; slug: string }>;
}>): Promise<Metadata> {
  const { locale, slug } = await params;
  const loaded = await load(locale, slug);
  const name = loaded.locale === "ar" ? loaded.card.nameAr : loaded.card.nameEn;
  const description =
    loaded.locale === "ar"
      ? loaded.card.descriptionAr
      : loaded.card.descriptionEn;
  return {
    title: name,
    description: description ?? `${name} — CCIP`,
    alternates: {
      canonical: `/${loaded.locale}/cards/${loaded.card.slug}`,
      languages: {
        ar: `/ar/cards/${loaded.card.slug}`,
        en: `/en/cards/${loaded.card.slug}`,
      },
    },
  };
}

export default async function CardDetailRoute({
  params,
}: Readonly<{ params: Promise<{ locale: string; slug: string }> }>) {
  const { locale, slug } = await params;
  const loaded = await load(locale, slug);
  return <CardDetailPage locale={loaded.locale} card={loaded.card} />;
}
