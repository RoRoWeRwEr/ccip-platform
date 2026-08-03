import type { Locale } from "@/lib/i18n";

export function safeNextPath(value: string | null, locale: Locale) {
  const fallback = `/${locale}`;
  if (!value || !value.startsWith("/") || value.startsWith("//")) {
    return fallback;
  }
  try {
    const url = new URL(value, "https://ccip.invalid");
    return url.origin === "https://ccip.invalid"
      ? `${url.pathname}${url.search}${url.hash}`
      : fallback;
  } catch {
    return fallback;
  }
}
