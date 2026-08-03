import Link from "next/link";
import type {
  CardDetail,
  CardSummary,
} from "@/features/catalog/data/repository";
import type { Locale } from "@/lib/i18n";

const copy = {
  en: {
    title: "Compare credit cards",
    intro:
      "Select up to three published cards and compare key attributes side by side.",
    select: "Card",
    choose: "Choose a card",
    compare: "Compare",
    clear: "Clear",
    empty: "Choose at least one card to start comparing.",
    attribute: "Attribute",
    bank: "Bank",
    network: "Network",
    fee: "Annual fee",
    salary: "Minimum salary",
    persona: "Persona",
    rewards: "Rewards",
    eligibility: "Eligibility requirements",
    details: "View details",
    notProvided: "Not provided",
  },
  ar: {
    title: "مقارنة البطاقات الائتمانية",
    intro: "اختر حتى ثلاث بطاقات منشورة وقارن الخصائص الأساسية جنباً إلى جنب.",
    select: "البطاقة",
    choose: "اختر بطاقة",
    compare: "مقارنة",
    clear: "مسح",
    empty: "اختر بطاقة واحدة على الأقل لبدء المقارنة.",
    attribute: "الخاصية",
    bank: "البنك",
    network: "الشبكة",
    fee: "الرسوم السنوية",
    salary: "الحد الأدنى للراتب",
    persona: "الفئة",
    rewards: "المكافآت",
    eligibility: "متطلبات الأهلية",
    details: "عرض التفاصيل",
    notProvided: "غير معلن",
  },
} as const;

function money(locale: Locale, value: number) {
  return new Intl.NumberFormat(locale === "ar" ? "ar-SA" : "en-SA", {
    style: "currency",
    currency: "SAR",
    maximumFractionDigits: 0,
  }).format(value);
}

export function ComparisonPage({
  locale,
  options,
  cards,
  selected,
}: Readonly<{
  locale: Locale;
  options: CardSummary[];
  cards: CardDetail[];
  selected: string[];
}>) {
  const text = copy[locale];
  const rows = cards.length
    ? [
        [
          text.bank,
          ...cards.map((card) =>
            locale === "ar" ? card.bank.nameAr : card.bank.nameEn,
          ),
        ],
        [
          text.network,
          ...cards.map((card) =>
            locale === "ar" ? card.network.nameAr : card.network.nameEn,
          ),
        ],
        [text.fee, ...cards.map((card) => money(locale, card.annualFee))],
        [
          text.salary,
          ...cards.map((card) =>
            card.minimumSalary === null
              ? text.notProvided
              : money(locale, card.minimumSalary),
          ),
        ],
        [
          text.persona,
          ...cards.map((card) => card.targetUser ?? text.notProvided),
        ],
        [
          text.rewards,
          ...cards.map((card) =>
            card.rewardRules.length
              ? card.rewardRules
                  .map((rule) => `${rule.rewardType} ${rule.rewardValue}`)
                  .join(", ")
              : text.notProvided,
          ),
        ],
        [
          text.eligibility,
          ...cards.map((card) =>
            card.eligibility.length
              ? card.eligibility
                  .map((item) => (locale === "ar" ? item.nameAr : item.nameEn))
                  .join(", ")
              : text.notProvided,
          ),
        ],
      ]
    : [];
  return (
    <main
      id="main-content"
      tabIndex={-1}
      className="mx-auto min-h-[70vh] max-w-7xl px-5 py-12 sm:px-8 lg:px-12"
    >
      <header className="max-w-3xl">
        <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">
          {text.title}
        </h1>
        <p className="text-muted mt-4 text-lg leading-8">{text.intro}</p>
      </header>
      <form
        action={`/${locale}/compare`}
        method="get"
        className="border-line mt-8 grid gap-4 rounded-3xl border bg-white p-5 md:grid-cols-3"
      >
        {[0, 1, 2].map((index) => (
          <label key={index} className="grid gap-2 text-sm font-bold">
            <span>
              {text.select} {index + 1}
            </span>
            <select
              name="card"
              defaultValue={selected[index] ?? ""}
              className="border-line min-h-11 rounded-xl border px-3"
            >
              <option value="">{text.choose}</option>
              {options.map((card) => (
                <option key={card.id} value={card.slug}>
                  {locale === "ar" ? card.nameAr : card.nameEn}
                </option>
              ))}
            </select>
          </label>
        ))}
        <div className="flex items-center gap-3 md:col-span-3">
          <button
            type="submit"
            className="bg-brand min-h-11 rounded-full px-6 font-bold text-white"
          >
            {text.compare}
          </button>
          <Link className="catalog-filter" href={`/${locale}/compare`}>
            {text.clear}
          </Link>
        </div>
      </form>
      {!cards.length ? (
        <p className="border-line text-muted mt-10 rounded-3xl border bg-white p-10 text-center">
          {text.empty}
        </p>
      ) : (
        <div className="border-line mt-10 overflow-x-auto rounded-3xl border bg-white">
          <table className="w-full min-w-[720px] border-collapse">
            <caption className="sr-only">{text.title}</caption>
            <thead>
              <tr>
                <th className="border-line border-b p-4 text-start">
                  {text.attribute}
                </th>
                {cards.map((card) => (
                  <th
                    key={card.id}
                    className="border-line border-b p-4 text-start"
                  >
                    <span className="block text-lg">
                      {locale === "ar" ? card.nameAr : card.nameEn}
                    </span>
                    <Link
                      className="text-brand mt-2 inline-block text-sm underline"
                      href={`/${locale}/cards/${card.slug}`}
                    >
                      {text.details}
                    </Link>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {rows.map(([label, ...values]) => (
                <tr key={label}>
                  <th
                    scope="row"
                    className="border-line border-b p-4 text-start"
                  >
                    {label}
                  </th>
                  {values.map((value, index) => (
                    <td
                      key={cards[index].id}
                      className="border-line border-b p-4 align-top"
                    >
                      {value}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </main>
  );
}
