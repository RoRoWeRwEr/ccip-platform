import Link from "next/link";
import type { CardDetail } from "@/features/catalog/data/repository";
import type { Locale } from "@/lib/i18n";

const copy = {
  ar: {
    back: "العودة إلى البطاقات",
    annualFee: "الرسوم السنوية",
    minimumSalary: "الحد الأدنى للراتب",
    foreignFee: "رسوم العمليات الأجنبية",
    fees: "الرسوم",
    benefits: "المزايا",
    rewards: "المكافآت",
    eligibility: "الأهلية",
    loyalty: "برنامج الولاء",
    merchants: "التجار المرتبطون",
    source: "المصدر الرسمي",
    publication: "معلومات النشر",
    noData: "لا تتوفر بيانات منشورة لهذا القسم حالياً.",
    mandatory: "متطلب إلزامي",
    apply: "التقديم الرسمي",
    terms: "الشروط والأحكام",
    effective: "ساري منذ",
    version: "إصدار",
    verified: "تم التحقق",
  },
  en: {
    back: "Back to cards",
    annualFee: "Annual fee",
    minimumSalary: "Minimum salary",
    foreignFee: "Foreign transaction fee",
    fees: "Fees",
    benefits: "Benefits",
    rewards: "Rewards",
    eligibility: "Eligibility",
    loyalty: "Loyalty program",
    merchants: "Related merchants",
    source: "Official source",
    publication: "Publication information",
    noData: "No published data is currently available for this section.",
    mandatory: "Mandatory requirement",
    apply: "Official application",
    terms: "Terms and conditions",
    effective: "Effective from",
    version: "Version",
    verified: "Verified",
  },
} satisfies Record<Locale, Record<string, string>>;

function money(locale: Locale, value: number, currency: string) {
  return new Intl.NumberFormat(locale === "ar" ? "ar-SA" : "en-SA", {
    style: "currency",
    currency,
    maximumFractionDigits: 2,
  }).format(value);
}

function date(locale: Locale, value: string) {
  return new Intl.DateTimeFormat(locale === "ar" ? "ar-SA" : "en-SA", {
    dateStyle: "medium",
  }).format(new Date(value));
}

function safeUrl(value: string | null) {
  if (!value) return null;
  try {
    const url = new URL(value);
    return url.protocol === "https:" || url.protocol === "http:" ? value : null;
  } catch {
    return null;
  }
}

function Empty({ children }: Readonly<{ children: string }>) {
  return <p className="text-muted rounded-2xl bg-white p-5">{children}</p>;
}

export function CardDetailPage({
  locale,
  card,
}: Readonly<{ locale: Locale; card: CardDetail }>) {
  const text = copy[locale];
  const local = <T extends { nameAr: string; nameEn: string }>(item: T) =>
    locale === "ar" ? item.nameAr : item.nameEn;
  const description = locale === "ar" ? card.descriptionAr : card.descriptionEn;
  const applicationUrl = safeUrl(card.applicationUrl);
  const termsUrl = safeUrl(card.termsUrl);
  const sourceUrl = safeUrl(card.provenance?.sourceLocator ?? null);
  return (
    <main
      id="main-content"
      className="mx-auto min-h-[70vh] max-w-6xl px-5 py-10 sm:px-8 lg:px-12"
    >
      <Link
        href={`/${locale}/cards`}
        className="text-brand focus-visible:outline-brand inline-flex min-h-11 items-center rounded-full font-bold hover:underline focus-visible:outline-2 focus-visible:outline-offset-4"
      >
        ← {text.back}
      </Link>
      <header className="border-line mt-5 rounded-3xl border bg-white p-6 shadow-sm sm:p-9">
        <p className="text-brand font-bold">
          {local(card.bank)} · {local(card.network)}
        </p>
        <h1 className="mt-2 text-4xl font-black tracking-tight sm:text-5xl">
          {local(card)}
        </h1>
        {description ? (
          <p className="text-muted mt-4 max-w-3xl text-lg leading-8">
            {description}
          </p>
        ) : null}
        <dl className="mt-7 grid gap-4 sm:grid-cols-3">
          <div>
            <dt className="text-muted text-sm">{text.annualFee}</dt>
            <dd className="mt-1 text-xl font-bold" dir="auto">
              {money(locale, card.annualFee, card.currency.code)}
            </dd>
          </div>
          <div>
            <dt className="text-muted text-sm">{text.minimumSalary}</dt>
            <dd className="mt-1 text-xl font-bold" dir="auto">
              {card.minimumSalary === null
                ? text.noData
                : money(locale, card.minimumSalary, card.currency.code)}
            </dd>
          </div>
          <div>
            <dt className="text-muted text-sm">{text.foreignFee}</dt>
            <dd className="mt-1 text-xl font-bold" dir="auto">
              {card.foreignTransactionFeeRate === null
                ? text.noData
                : `${card.foreignTransactionFeeRate}%`}
            </dd>
          </div>
        </dl>
        {applicationUrl || termsUrl ? (
          <div className="mt-7 flex flex-wrap gap-3">
            {applicationUrl ? (
              <a
                className="bg-brand focus-visible:outline-accent inline-flex min-h-11 items-center rounded-full px-5 py-2 font-bold text-white focus-visible:outline-2 focus-visible:outline-offset-4"
                href={applicationUrl}
                rel="noopener noreferrer"
              >
                {text.apply}
              </a>
            ) : null}
            {termsUrl ? (
              <a
                className="border-line focus-visible:outline-brand inline-flex min-h-11 items-center rounded-full border px-5 py-2 font-bold focus-visible:outline-2 focus-visible:outline-offset-4"
                href={termsUrl}
                rel="noopener noreferrer"
              >
                {text.terms}
              </a>
            ) : null}
          </div>
        ) : null}
      </header>

      <div className="mt-8 grid gap-8 lg:grid-cols-2">
        <section aria-labelledby="fees-heading">
          <h2 id="fees-heading" className="text-2xl font-bold">
            {text.fees}
          </h2>
          {card.fees.length ? (
            <ul className="mt-4 space-y-3">
              {card.fees.map((fee) => (
                <li
                  key={fee.id}
                  className="border-line rounded-2xl border bg-white p-5"
                >
                  <h3 className="font-bold">{local(fee)}</h3>
                  <p className="text-muted mt-2" dir="auto">
                    {fee.amount !== null
                      ? money(locale, fee.amount, card.currency.code)
                      : fee.percentage !== null
                        ? `${fee.percentage}%`
                        : text.noData}
                  </p>
                </li>
              ))}
            </ul>
          ) : (
            <div className="mt-4">
              <Empty>{text.noData}</Empty>
            </div>
          )}
        </section>
        <section aria-labelledby="benefits-heading">
          <h2 id="benefits-heading" className="text-2xl font-bold">
            {text.benefits}
          </h2>
          {card.benefits.length ? (
            <ul className="mt-4 space-y-3">
              {card.benefits.map((benefit) => (
                <li
                  key={benefit.id}
                  className="border-line rounded-2xl border bg-white p-5"
                >
                  <h3 className="font-bold">{local(benefit)}</h3>
                  {(
                    locale === "ar"
                      ? benefit.descriptionAr
                      : benefit.descriptionEn
                  ) ? (
                    <p className="text-muted mt-2 leading-7">
                      {locale === "ar"
                        ? benefit.descriptionAr
                        : benefit.descriptionEn}
                    </p>
                  ) : null}
                </li>
              ))}
            </ul>
          ) : (
            <div className="mt-4">
              <Empty>{text.noData}</Empty>
            </div>
          )}
        </section>
        <section aria-labelledby="rewards-heading">
          <h2 id="rewards-heading" className="text-2xl font-bold">
            {text.rewards}
          </h2>
          {card.rewardRules.length ? (
            <ul className="mt-4 space-y-3">
              {card.rewardRules.map((rule) => (
                <li
                  key={rule.id}
                  className="border-line rounded-2xl border bg-white p-5"
                >
                  <h3 className="font-bold">{rule.rewardType}</h3>
                  <p className="text-muted mt-2" dir="auto">
                    {rule.rewardValue} · {rule.calculationMethod}
                  </p>
                  {rule.targets.length ? (
                    <p className="text-muted mt-2">
                      {rule.targets
                        .map((target) =>
                          locale === "ar"
                            ? (target.nameAr ?? target.categorySlug)
                            : (target.nameEn ?? target.categorySlug),
                        )
                        .filter(Boolean)
                        .join("، ")}
                    </p>
                  ) : null}
                </li>
              ))}
            </ul>
          ) : (
            <div className="mt-4">
              <Empty>{text.noData}</Empty>
            </div>
          )}
        </section>
        <section aria-labelledby="eligibility-heading">
          <h2 id="eligibility-heading" className="text-2xl font-bold">
            {text.eligibility}
          </h2>
          {card.eligibility.length ? (
            <ul className="mt-4 space-y-3">
              {card.eligibility.map((item) => (
                <li
                  key={item.id}
                  className="border-line rounded-2xl border bg-white p-5"
                >
                  <h3 className="font-bold">{local(item)}</h3>
                  {item.mandatory ? (
                    <p className="text-accent-deep mt-2 text-sm font-bold">
                      {text.mandatory}
                    </p>
                  ) : null}
                  {(
                    locale === "ar" ? item.descriptionAr : item.descriptionEn
                  ) ? (
                    <p className="text-muted mt-2">
                      {locale === "ar"
                        ? item.descriptionAr
                        : item.descriptionEn}
                    </p>
                  ) : null}
                </li>
              ))}
            </ul>
          ) : (
            <div className="mt-4">
              <Empty>{text.noData}</Empty>
            </div>
          )}
        </section>
        <section aria-labelledby="loyalty-heading">
          <h2 id="loyalty-heading" className="text-2xl font-bold">
            {text.loyalty}
          </h2>
          {card.loyaltyProgram ? (
            <div className="border-line mt-4 rounded-2xl border bg-white p-5">
              <h3 className="font-bold">{local(card.loyaltyProgram)}</h3>
              {card.loyaltyProgram.type ? (
                <p className="text-muted mt-2">{card.loyaltyProgram.type}</p>
              ) : null}
            </div>
          ) : (
            <div className="mt-4">
              <Empty>{text.noData}</Empty>
            </div>
          )}
        </section>
        <section aria-labelledby="merchants-heading">
          <h2 id="merchants-heading" className="text-2xl font-bold">
            {text.merchants}
          </h2>
          {card.merchants.length ? (
            <ul className="mt-4 flex flex-wrap gap-2">
              {card.merchants.map((merchant) => (
                <li
                  key={merchant.id}
                  className="border-line rounded-full border bg-white px-4 py-3 font-bold"
                >
                  {local(merchant)}
                </li>
              ))}
            </ul>
          ) : (
            <div className="mt-4">
              <Empty>{text.noData}</Empty>
            </div>
          )}
        </section>
      </div>

      <aside
        className="border-line mt-8 grid gap-6 rounded-3xl border bg-white p-6 sm:grid-cols-2"
        aria-label={text.publication}
      >
        <section>
          <h2 className="text-xl font-bold">{text.publication}</h2>
          <p className="text-muted mt-3">
            {text.version} {card.publication.versionNumber} · {text.effective}{" "}
            <span dir="auto">
              {date(locale, card.publication.effectiveFrom)}
            </span>
          </p>
        </section>
        <section>
          <h2 className="text-xl font-bold">{text.source}</h2>
          {card.provenance ? (
            <>
              {sourceUrl ? (
                <a
                  className="text-brand mt-3 block font-bold underline"
                  href={sourceUrl}
                  rel="noopener noreferrer"
                >
                  {card.provenance.sourceTitle}
                </a>
              ) : (
                <p className="mt-3 font-bold">{card.provenance.sourceTitle}</p>
              )}
              <p className="text-muted mt-2">
                {card.provenance.sourceOwner} · {text.verified}{" "}
                <span dir="auto">
                  {date(locale, card.provenance.verifiedAt)}
                </span>
              </p>
            </>
          ) : (
            <p className="text-muted mt-3">{text.noData}</p>
          )}
        </section>
      </aside>
    </main>
  );
}
