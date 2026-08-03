import { NextResponse, type NextRequest } from "next/server";
import { safeNextPath } from "@/features/auth/redirect";
import { isLocale } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/server";

export async function GET(
  request: NextRequest,
  context: { params: Promise<{ locale: string }> },
) {
  const { locale } = await context.params;
  if (!isLocale(locale)) {
    return NextResponse.redirect(
      new URL("/en/auth?error=callback", request.url),
    );
  }
  const code = request.nextUrl.searchParams.get("code");
  const next = safeNextPath(request.nextUrl.searchParams.get("next"), locale);
  if (code) {
    const client = await createClient();
    const { error } = await client.auth.exchangeCodeForSession(code);
    if (!error) return NextResponse.redirect(new URL(next, request.url));
  }
  return NextResponse.redirect(
    new URL(`/${locale}/auth?error=callback`, request.url),
  );
}
