import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { HomePage } from "@/features/home/home-page";
import { isLocale, messages, type Locale } from "@/lib/i18n";

export async function generateMetadata({
  params,
}: Readonly<{ params: Promise<{ locale: string }> }>): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) return {};

  return {
    title: messages[locale].metaTitle,
    description: messages[locale].metaDescription,
    alternates: {
      canonical: `/${locale}`,
      languages: { ar: "/ar", en: "/en" },
    },
  };
}

export default async function LocalizedHomePage({
  params,
}: Readonly<{ params: Promise<{ locale: string }> }>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();

  return <HomePage locale={locale as Locale} />;
}
