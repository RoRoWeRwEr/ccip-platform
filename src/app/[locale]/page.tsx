import Link from "next/link";
import { notFound } from "next/navigation";
import { isLocale, messages } from "@/lib/i18n";

export default async function HomePage({
  params,
}: Readonly<{ params: Promise<{ locale: string }> }>) {
  const { locale } = await params;

  if (!isLocale(locale)) {
    notFound();
  }

  const copy = messages[locale];
  const otherLocale = locale === "ar" ? "en" : "ar";

  return (
    <main className="bg-canvas text-ink min-h-screen overflow-hidden">
      <div className="mx-auto flex min-h-screen max-w-7xl flex-col px-5 py-6 sm:px-8 lg:px-12">
        <header
          className="flex items-center justify-between"
          aria-label={copy.navigationLabel}
        >
          <Link
            href={`/${locale}`}
            className="flex items-center gap-3 font-semibold"
          >
            <span className="bg-brand shadow-brand grid size-10 place-items-center rounded-2xl text-sm text-white">
              CC
            </span>
            <span>{copy.brand}</span>
          </Link>
          <Link
            href={`/${otherLocale}`}
            hrefLang={otherLocale}
            className="border-line hover:border-brand hover:text-brand focus-visible:outline-brand rounded-full border bg-white/80 px-4 py-2 text-sm font-semibold transition focus-visible:outline-2 focus-visible:outline-offset-4"
          >
            {copy.languageSwitch}
          </Link>
        </header>

        <section className="grid flex-1 items-center gap-14 py-16 lg:grid-cols-[1.1fr_0.9fr] lg:py-24">
          <div className="max-w-3xl">
            <p className="border-accent/30 bg-accent-soft text-accent-deep mb-5 inline-flex rounded-full border px-4 py-2 text-sm font-bold">
              {copy.eyebrow}
            </p>
            <h1 className="text-5xl leading-[1.08] font-bold tracking-tight text-balance sm:text-6xl lg:text-7xl">
              {copy.title}
            </h1>
            <p className="text-muted mt-7 max-w-2xl text-lg leading-8 sm:text-xl">
              {copy.description}
            </p>
            <div className="mt-9 flex flex-col gap-3 sm:flex-row">
              <span className="bg-brand shadow-brand rounded-full px-6 py-3 text-center font-bold text-white">
                {copy.primaryAction}
              </span>
              <span className="border-line text-ink rounded-full border bg-white px-6 py-3 text-center font-bold">
                {copy.secondaryAction}
              </span>
            </div>
            <p className="text-muted mt-5 text-sm">{copy.foundationNotice}</p>
          </div>

          <div className="relative mx-auto w-full max-w-lg" aria-hidden="true">
            <div className="bg-accent/15 absolute -inset-8 rounded-full blur-3xl" />
            <div className="shadow-card relative rotate-2 rounded-[2rem] border border-white/60 bg-white/90 p-6 backdrop-blur">
              <div className="from-brand to-brand-deep rounded-[1.5rem] bg-gradient-to-br p-6 text-white">
                <div className="flex items-start justify-between">
                  <span className="text-sm font-semibold opacity-80">
                    CCIP VALUE
                  </span>
                  <span className="text-2xl">✦</span>
                </div>
                <p className="mt-16 text-4xl font-bold">
                  3,250 <span className="text-lg">SAR</span>
                </p>
                <p className="mt-2 text-sm opacity-80">{copy.sampleValue}</p>
              </div>
              <div className="grid grid-cols-3 gap-3 pt-5 text-center">
                {copy.signals.map((signal) => (
                  <div
                    key={signal.label}
                    className="bg-canvas rounded-2xl px-2 py-4"
                  >
                    <p className="text-brand text-lg font-bold">
                      {signal.value}
                    </p>
                    <p className="text-muted mt-1 text-xs">{signal.label}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}
