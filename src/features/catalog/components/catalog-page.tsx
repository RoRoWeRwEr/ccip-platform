import Link from "next/link";
import type {
  BankSummary,
  CardSummary,
} from "@/features/catalog/data/repository";
import type { Locale } from "@/lib/i18n";

interface CatalogCopy {
  title: string;
  description: string;
  allBanks: string;
  banksLabel: string;
  cardsLabel: string;
  emptyTitle: string;
  emptyDescription: string;
  annualFee: string;
  noAnnualFee: string;
  minimumSalary: string;
  salaryUnknown: string;
  previous: string;
  next: string;
  page: string;
  viewDetails: string;
}

const copy: Record<Locale, CatalogCopy> = {
  ar: {
    title: "البطاقات الائتمانية السعودية",
    description:
      "تصفّح البطاقات المنشورة والمتاحة وقارن الرسوم والمتطلبات الأساسية.",
    allBanks: "كل البنوك",
    banksLabel: "تصفية حسب البنك",
    cardsLabel: "البطاقات المتاحة",
    emptyTitle: "لا توجد بطاقات منشورة هنا حالياً",
    emptyDescription:
      "جرّب بنكاً آخر أو ارجع لاحقاً بعد نشر بيانات رسمية جديدة.",
    annualFee: "الرسوم السنوية",
    noAnnualFee: "بدون رسوم سنوية",
    minimumSalary: "الحد الأدنى للراتب",
    salaryUnknown: "غير معلن",
    previous: "السابق",
    next: "التالي",
    page: "صفحة",
    viewDetails: "عرض التفاصيل",
  },
  en: {
    title: "Saudi credit cards",
    description:
      "Browse published, available cards and compare core fees and eligibility at a glance.",
    allBanks: "All banks",
    banksLabel: "Filter by bank",
    cardsLabel: "Available cards",
    emptyTitle: "No published cards here yet",
    emptyDescription:
      "Try another bank or check back after new official catalog data is published.",
    annualFee: "Annual fee",
    noAnnualFee: "No annual fee",
    minimumSalary: "Minimum salary",
    salaryUnknown: "Not provided",
    previous: "Previous",
    next: "Next",
    page: "Page",
    viewDetails: "View details",
  },
};

function formatSar(locale: Locale, value: number) {
  return new Intl.NumberFormat(locale === "ar" ? "ar-SA" : "en-SA", {
    style: "currency",
    currency: "SAR",
    maximumFractionDigits: 0,
  }).format(value);
}

function catalogHref(locale: Locale, page: number, bankSlug?: string) {
  const params = new URLSearchParams();
  if (bankSlug) params.set("bank", bankSlug);
  if (page > 1) params.set("page", String(page));
  const query = params.toString();
  return `/${locale}/cards${query ? `?${query}` : ""}`;
}

export function CatalogPage({
  locale,
  banks,
  cards,
  page,
  totalPages,
  selectedBank,
}: Readonly<{
  locale: Locale;
  banks: BankSummary[];
  cards: CardSummary[];
  page: number;
  totalPages: number;
  selectedBank?: string;
}>) {
  const text = copy[locale];

  return (
    <main
      id="main-content"
      className="mx-auto min-h-[70vh] max-w-7xl px-5 py-12 sm:px-8 lg:px-12"
    >
      <header className="max-w-3xl">
        <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">
          {text.title}
        </h1>
        <p className="text-muted mt-4 text-lg leading-8">{text.description}</p>
      </header>

      <nav className="mt-9" aria-label={text.banksLabel}>
        <ul className="flex flex-wrap gap-2">
          <li>
            <Link
              aria-current={!selectedBank ? "page" : undefined}
              className="catalog-filter"
              href={catalogHref(locale, 1)}
            >
              {text.allBanks}
            </Link>
          </li>
          {banks.map((bank) => (
            <li key={bank.id}>
              <Link
                aria-current={selectedBank === bank.slug ? "page" : undefined}
                className="catalog-filter"
                href={catalogHref(locale, 1, bank.slug)}
              >
                {locale === "ar" ? bank.nameAr : bank.nameEn}
              </Link>
            </li>
          ))}
        </ul>
      </nav>

      <section className="mt-10" aria-labelledby="cards-heading">
        <h2 id="cards-heading" className="sr-only">
          {text.cardsLabel}
        </h2>
        {cards.length === 0 ? (
          <div className="border-line rounded-3xl border bg-white px-6 py-14 text-center">
            <div
              aria-hidden="true"
              className="bg-accent-soft text-accent-deep mx-auto grid size-14 place-items-center rounded-2xl text-2xl"
            >
              ◇
            </div>
            <h3 className="mt-5 text-2xl font-bold">{text.emptyTitle}</h3>
            <p className="text-muted mx-auto mt-3 max-w-xl leading-7">
              {text.emptyDescription}
            </p>
          </div>
        ) : (
          <ul className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
            {cards.map((card) => {
              const name = locale === "ar" ? card.nameAr : card.nameEn;
              const bankName =
                locale === "ar" ? card.bank.nameAr : card.bank.nameEn;
              return (
                <li
                  key={card.id}
                  className="border-line flex min-w-0 flex-col rounded-3xl border bg-white p-6 shadow-sm"
                >
                  <div className="flex items-start gap-4">
                    <div
                      aria-hidden="true"
                      className="from-brand to-brand-deep grid size-14 shrink-0 place-items-center rounded-2xl bg-gradient-to-br text-lg font-black text-white"
                    >
                      {bankName.slice(0, 2).toUpperCase()}
                    </div>
                    <div className="min-w-0">
                      <p className="text-brand text-sm font-bold">{bankName}</p>
                      <h3 className="mt-1 text-xl font-bold">{name}</h3>
                      <p className="text-muted mt-1 text-sm">
                        {card.network.nameEn}
                      </p>
                    </div>
                  </div>
                  <dl className="border-line mt-6 grid grid-cols-2 gap-4 border-y py-5">
                    <div>
                      <dt className="text-muted text-sm">{text.annualFee}</dt>
                      <dd className="mt-1 font-bold" dir="auto">
                        {card.annualFee === 0
                          ? text.noAnnualFee
                          : formatSar(locale, card.annualFee)}
                      </dd>
                    </div>
                    <div>
                      <dt className="text-muted text-sm">
                        {text.minimumSalary}
                      </dt>
                      <dd className="mt-1 font-bold" dir="auto">
                        {card.minimumSalary === null
                          ? text.salaryUnknown
                          : formatSar(locale, card.minimumSalary)}
                      </dd>
                    </div>
                  </dl>
                  <Link
                    className="text-brand focus-visible:outline-brand mt-5 inline-flex min-h-11 items-center justify-center rounded-full font-bold hover:underline focus-visible:outline-2 focus-visible:outline-offset-4"
                    href={`/${locale}/cards/${card.slug}`}
                  >
                    {text.viewDetails}
                  </Link>
                </li>
              );
            })}
          </ul>
        )}
      </section>

      {totalPages > 1 ? (
        <nav
          className="mt-10 flex items-center justify-center gap-4"
          aria-label={`${text.page} ${page}`}
        >
          {page > 1 ? (
            <Link
              className="catalog-page-link"
              href={catalogHref(locale, page - 1, selectedBank)}
              rel="prev"
            >
              {text.previous}
            </Link>
          ) : (
            <span className="catalog-page-link opacity-40" aria-disabled="true">
              {text.previous}
            </span>
          )}
          <span className="text-muted text-sm">
            {text.page} {page} / {totalPages}
          </span>
          {page < totalPages ? (
            <Link
              className="catalog-page-link"
              href={catalogHref(locale, page + 1, selectedBank)}
              rel="next"
            >
              {text.next}
            </Link>
          ) : (
            <span className="catalog-page-link opacity-40" aria-disabled="true">
              {text.next}
            </span>
          )}
        </nav>
      ) : null}
    </main>
  );
}
