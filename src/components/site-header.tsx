import Link from "next/link";
import { messages, type Locale } from "@/lib/i18n";

export function SiteHeader({ locale }: Readonly<{ locale: Locale }>) {
  const copy = messages[locale];
  const otherLocale = locale === "ar" ? "en" : "ar";
  return (
    <header className="border-line/80 border-b bg-white/90 backdrop-blur">
      <div className="mx-auto flex max-w-7xl flex-wrap items-center justify-between gap-4 px-5 py-4 sm:px-8 lg:px-12">
        <Link href={`/${locale}`} className="flex items-center gap-3 font-bold">
          <span className="bg-brand shadow-brand grid size-10 place-items-center rounded-2xl text-sm text-white">
            CC
          </span>
          <span>{copy.brand}</span>
        </Link>
        <nav
          aria-label={copy.navigationLabel}
          className="order-3 w-full sm:order-2 sm:w-auto"
        >
          <ul className="flex items-center justify-between gap-2 text-sm font-semibold sm:justify-start sm:gap-6">
            {copy.navigation.map((item) => (
              <li key={item.href}>
                <Link
                  className="hover:text-brand focus-visible:outline-brand rounded-md py-2 focus-visible:outline-2 focus-visible:outline-offset-4"
                  href={`/${locale}${item.href}`}
                >
                  {item.label}
                </Link>
              </li>
            ))}
          </ul>
        </nav>
        <Link
          href={`/${otherLocale}`}
          hrefLang={otherLocale}
          lang={otherLocale}
          aria-label={copy.languageSwitchLabel}
          className="border-line hover:border-brand hover:text-brand focus-visible:outline-brand order-2 rounded-full border bg-white px-4 py-2 text-sm font-bold transition focus-visible:outline-2 focus-visible:outline-offset-4 sm:order-3"
        >
          {copy.languageSwitch}
        </Link>
        <Link
          href={`/${locale}/auth`}
          className="border-line hover:border-brand hover:text-brand focus-visible:outline-brand order-2 rounded-full border bg-white px-4 py-2 text-sm font-bold transition focus-visible:outline-2 focus-visible:outline-offset-4 sm:order-3"
        >
          {locale === "ar" ? "الحساب" : "Account"}
        </Link>
      </div>
    </header>
  );
}

export function SiteFooter({ locale }: Readonly<{ locale: Locale }>) {
  const copy = messages[locale];
  return (
    <footer className="bg-brand-deep text-white">
      <div className="mx-auto flex max-w-7xl flex-col gap-4 px-5 py-8 text-sm sm:px-8 md:flex-row md:items-center md:justify-between lg:px-12">
        <p className="font-bold">{copy.brand}</p>
        <p className="max-w-2xl text-white/75">{copy.disclaimer}</p>
      </div>
    </footer>
  );
}
