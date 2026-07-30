import Link from "next/link";
import { messages, type Locale } from "@/lib/i18n";

const personaIcons = ["↙", "✈", "◎"] as const;

export function HomePage({ locale }: Readonly<{ locale: Locale }>) {
  const copy = messages[locale];
  const otherLocale = locale === "ar" ? "en" : "ar";

  return (
    <div className="bg-canvas text-ink min-h-screen">
      <a
        href="#main-content"
        className="focus:bg-brand sr-only focus:not-sr-only focus:fixed focus:start-4 focus:top-4 focus:z-50 focus:rounded-full focus:px-4 focus:py-3 focus:text-white"
      >
        {copy.skipLink}
      </a>

      <header className="border-line/80 border-b bg-white/90 backdrop-blur">
        <div className="mx-auto flex max-w-7xl flex-wrap items-center justify-between gap-4 px-5 py-4 sm:px-8 lg:px-12">
          <Link
            href={`/${locale}`}
            className="flex items-center gap-3 font-bold"
          >
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
        </div>
      </header>

      <main id="main-content">
        <section className="relative overflow-hidden">
          <div
            className="bg-accent/10 absolute end-[-8rem] top-[-8rem] size-80 rounded-full blur-3xl"
            aria-hidden="true"
          />
          <div className="mx-auto grid max-w-7xl items-center gap-12 px-5 py-16 sm:px-8 sm:py-20 lg:grid-cols-[1.1fr_0.9fr] lg:px-12 lg:py-28">
            <div className="max-w-3xl">
              <p className="border-accent/30 bg-accent-soft text-accent-deep mb-5 inline-flex rounded-full border px-4 py-2 text-sm font-bold">
                {copy.eyebrow}
              </p>
              <h1 className="text-4xl leading-tight font-bold tracking-tight text-balance sm:text-6xl lg:text-7xl">
                {copy.title}
              </h1>
              <p className="text-muted mt-6 max-w-2xl text-lg leading-8 sm:text-xl">
                {copy.description}
              </p>
              <div className="mt-8 flex flex-col gap-3 sm:flex-row">
                <Link
                  className="bg-brand shadow-brand hover:bg-brand-deep focus-visible:outline-accent rounded-full px-6 py-3 text-center font-bold text-white transition focus-visible:outline-2 focus-visible:outline-offset-4"
                  href={`/${locale}/cards`}
                >
                  {copy.primaryAction}
                </Link>
                <Link
                  className="border-line hover:border-brand hover:text-brand focus-visible:outline-brand rounded-full border bg-white px-6 py-3 text-center font-bold transition focus-visible:outline-2 focus-visible:outline-offset-4"
                  href={`/${locale}/calculator`}
                >
                  {copy.secondaryAction}
                </Link>
              </div>
              <p className="text-muted mt-5 max-w-xl text-sm leading-6">
                {copy.trustNote}
              </p>
            </div>

            <div
              className="relative mx-auto w-full max-w-lg"
              aria-label={copy.valuePreviewLabel}
            >
              <div
                className="bg-accent/15 absolute -inset-8 rounded-full blur-3xl"
                aria-hidden="true"
              />
              <div className="shadow-card relative rotate-1 rounded-[2rem] border border-white/60 bg-white/95 p-5 backdrop-blur sm:p-6">
                <div className="from-brand to-brand-deep rounded-[1.5rem] bg-gradient-to-br p-6 text-white">
                  <div className="flex items-start justify-between">
                    <span className="text-sm font-semibold opacity-80">
                      {copy.valuePreview}
                    </span>
                    <span aria-hidden="true" className="text-2xl">
                      ✦
                    </span>
                  </div>
                  <p className="mt-14 text-4xl font-bold" dir="ltr">
                    3,250 <span className="text-lg">SAR</span>
                  </p>
                  <p className="mt-2 text-sm opacity-80">{copy.sampleValue}</p>
                </div>
                <dl className="grid grid-cols-3 gap-2 pt-5 text-center sm:gap-3">
                  {copy.signals.map((signal) => (
                    <div
                      key={signal.label}
                      className="bg-canvas rounded-2xl px-2 py-4"
                    >
                      <dt className="text-muted mt-1 text-xs">
                        {signal.label}
                      </dt>
                      <dd
                        className="text-brand -order-1 text-lg font-bold"
                        dir="ltr"
                      >
                        {signal.value}
                      </dd>
                    </div>
                  ))}
                </dl>
              </div>
            </div>
          </div>
        </section>

        <section
          className="bg-white py-16 sm:py-20"
          aria-labelledby="persona-heading"
        >
          <div className="mx-auto max-w-7xl px-5 sm:px-8 lg:px-12">
            <div className="max-w-2xl">
              <p className="text-brand text-sm font-bold tracking-wide">
                {copy.personaEyebrow}
              </p>
              <h2
                id="persona-heading"
                className="mt-2 text-3xl font-bold tracking-tight sm:text-4xl"
              >
                {copy.personaTitle}
              </h2>
              <p className="text-muted mt-4 leading-7">
                {copy.personaDescription}
              </p>
            </div>
            <div className="mt-9 grid gap-4 md:grid-cols-3">
              {copy.personas.map((persona, index) => (
                <Link
                  key={persona.key}
                  href={`/${locale}/cards?persona=${persona.key}`}
                  className="border-line hover:border-brand focus-visible:outline-brand group bg-canvas rounded-3xl border p-6 transition hover:-translate-y-1 hover:shadow-lg focus-visible:outline-2 focus-visible:outline-offset-4"
                >
                  <span
                    aria-hidden="true"
                    className="bg-accent-soft text-accent-deep grid size-11 place-items-center rounded-2xl text-xl"
                  >
                    {personaIcons[index]}
                  </span>
                  <h3 className="mt-5 text-xl font-bold">{persona.title}</h3>
                  <p className="text-muted mt-2 leading-7">
                    {persona.description}
                  </p>
                  <span className="text-brand mt-5 inline-flex font-bold">
                    {persona.action}{" "}
                    <span
                      aria-hidden="true"
                      className="ms-2 transition group-hover:translate-x-1 rtl:group-hover:-translate-x-1"
                    >
                      →
                    </span>
                  </span>
                </Link>
              ))}
            </div>
          </div>
        </section>

        <section
          className="py-16 sm:py-20"
          aria-labelledby="principles-heading"
        >
          <div className="mx-auto max-w-7xl px-5 sm:px-8 lg:px-12">
            <h2
              id="principles-heading"
              className="text-center text-3xl font-bold tracking-tight sm:text-4xl"
            >
              {copy.principlesTitle}
            </h2>
            <div className="mt-10 grid gap-6 md:grid-cols-3">
              {copy.principles.map((principle, index) => (
                <article
                  key={principle.title}
                  className="rounded-3xl bg-white p-6 shadow-sm"
                >
                  <p
                    className="text-accent text-sm font-black"
                    aria-hidden="true"
                  >
                    0{index + 1}
                  </p>
                  <h3 className="mt-3 text-xl font-bold">{principle.title}</h3>
                  <p className="text-muted mt-2 leading-7">
                    {principle.description}
                  </p>
                </article>
              ))}
            </div>
          </div>
        </section>
      </main>

      <footer className="bg-brand-deep text-white">
        <div className="mx-auto flex max-w-7xl flex-col gap-4 px-5 py-8 text-sm sm:px-8 md:flex-row md:items-center md:justify-between lg:px-12">
          <p className="font-bold">{copy.brand}</p>
          <p className="max-w-2xl text-white/75">{copy.disclaimer}</p>
        </div>
      </footer>
    </div>
  );
}
