import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { AuthPage } from "@/features/auth/auth-page";
import { safeNextPath } from "@/features/auth/redirect";
import { isLocale } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export const metadata: Metadata = {
  robots: { index: false, follow: false },
};

function one(value: string | string[] | undefined) {
  return Array.isArray(value) ? (value[0] ?? "") : (value ?? "");
}

export default async function AuthRoute({
  params,
  searchParams,
}: Readonly<{
  params: Promise<{ locale: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}>) {
  const [{ locale }, query] = await Promise.all([params, searchParams]);
  if (!isLocale(locale)) notFound();
  const requestedMode = one(query.mode);
  const mode = ["login", "signup", "recover", "update"].includes(requestedMode)
    ? (requestedMode as "login" | "signup" | "recover" | "update")
    : "login";
  const client = await createClient();
  const { data } = await client.auth.getUser();
  return (
    <AuthPage
      locale={locale}
      initialMode={mode}
      next={safeNextPath(one(query.next), locale)}
      userEmail={data.user?.email ?? null}
      hasCallbackError={one(query.error) === "callback"}
    />
  );
}
