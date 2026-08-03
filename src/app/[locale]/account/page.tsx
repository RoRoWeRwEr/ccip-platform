import type { Metadata } from "next";
import { notFound, redirect } from "next/navigation";
import { AccountPage } from "@/features/account/account-page";
import { loadUserDashboard } from "@/features/account/data";
import { isLocale } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";
export const metadata: Metadata = { robots: { index: false, follow: false } };

export default async function AccountRoute({
  params,
}: Readonly<{ params: Promise<{ locale: string }> }>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  const client = await createClient();
  const { data } = await client.auth.getUser();
  if (!data.user)
    redirect(
      `/${locale}/auth?next=${encodeURIComponent(`/${locale}/account`)}`,
    );
  return (
    <AccountPage locale={locale} dashboard={await loadUserDashboard(client)} />
  );
}
