import Link from "next/link";
import type {
  CardDetail,
  CardSummary,
} from "@/features/catalog/data/repository";
import type { Locale } from "@/lib/i18n";
import {
  calculateAnnualCardValue,
  spendingCategories,
  type MonthlySpending,
} from "./calculation";

const copy = {
  en: {
    title: "Spending calculator",
    intro:
      "Estimate a published card's annual reward value from your monthly spending. Results are informational estimates, not guarantees.",
    card: "Published card",
    choose: "Choose a card",
    monthly: "Monthly spending (SAR)",
    valuation: "Fixed SAR value per reward unit",
    valuationHint:
      "Cashback always uses SAR parity. For points or miles, enter the fixed reference value you want this estimate to use.",
    calculate: "Calculate annual value",
    clear: "Clear",
    annualSpend: "Annual spending",
    rewardUnits: "Annual reward units",
    rewardValue: "Estimated annual reward value",
    annualFee: "Annual fee",
    netValue: "Estimated net annual value",
    breakdown: "Calculation breakdown",
    category: "Category",
    rule: "Published rule",
    noRule: "No applicable published rule",
    assumptions: "Assumptions and limitations",
    annualized: "Monthly spending is annualized by multiplying by 12.",
    cashbackParity: "Cashback is valued at SAR parity (1 reward unit = SAR 1).",
    fixedValuation: (value: string) =>
      `Reward units use the entered fixed reference of SAR ${value} per unit.`,
    ruleSelection:
      "The most specific published category rule is used; otherwise the first published general rule applies.",
    limitations:
      "Published minimums, caps, and rounding are applied. Tiered rules without published tiers and transaction/day minimums that cannot be verified from monthly totals return zero.",
    netMethod:
      "Offers and benefits are excluded. Net value is annual reward value minus annual fee.",
    publication: (version: number, date: string) =>
      `Catalog publication version ${version}, effective ${date}.`,
    empty: "Choose a card and enter spending to calculate an estimate.",
    categories: {
      general: "Other/general",
      groceries: "Groceries",
      dining: "Dining",
      fuel: "Fuel",
      travel: "Travel",
      "online-shopping": "Online shopping",
    },
  },
  ar: {
    title: "حاسبة الإنفاق",
    intro:
      "قدّر قيمة المكافآت السنوية لبطاقة منشورة من إنفاقك الشهري. النتائج تقديرات معلوماتية وليست ضماناً.",
    card: "البطاقة المنشورة",
    choose: "اختر بطاقة",
    monthly: "الإنفاق الشهري (ر.س)",
    valuation: "القيمة الثابتة بالريال لكل وحدة مكافأة",
    valuationHint:
      "يُحتسب الاسترداد النقدي بقيمته بالريال. للنقاط أو الأميال، أدخل القيمة المرجعية الثابتة المستخدمة في هذا التقدير.",
    calculate: "احسب القيمة السنوية",
    clear: "مسح",
    annualSpend: "الإنفاق السنوي",
    rewardUnits: "وحدات المكافأة السنوية",
    rewardValue: "قيمة المكافآت السنوية التقديرية",
    annualFee: "الرسوم السنوية",
    netValue: "صافي القيمة السنوية التقديرية",
    breakdown: "تفاصيل الحساب",
    category: "الفئة",
    rule: "القاعدة المنشورة",
    noRule: "لا توجد قاعدة منشورة مطبقة",
    assumptions: "الافتراضات والقيود",
    annualized: "يُحوّل الإنفاق الشهري إلى سنوي بضربه في 12.",
    cashbackParity:
      "يُقيّم الاسترداد النقدي بالقيمة نفسها (كل وحدة = ريال واحد).",
    fixedValuation: (value: string) =>
      `تستخدم وحدات المكافأة القيمة المرجعية المدخلة: ${value} ريال لكل وحدة.`,
    ruleSelection:
      "تُستخدم قاعدة الفئة المنشورة الأكثر تحديداً، وإلا فتُستخدم أول قاعدة عامة منشورة.",
    limitations:
      "تُطبق الحدود الدنيا والسقوف والتقريب المنشورة. القواعد المتدرجة دون شرائح منشورة وحدود المعاملة/اليوم التي لا يمكن التحقق منها من الإجماليات الشهرية تُحتسب صفراً.",
    netMethod:
      "لا تدخل العروض والمزايا في القيمة. صافي القيمة هو قيمة المكافآت السنوية ناقص الرسوم السنوية.",
    publication: (version: number, date: string) =>
      `إصدار الكتالوج المنشور ${version}، ساري من ${date}.`,
    empty: "اختر بطاقة وأدخل الإنفاق لحساب التقدير.",
    categories: {
      general: "أخرى/عامة",
      groceries: "البقالة",
      dining: "المطاعم",
      fuel: "الوقود",
      travel: "السفر",
      "online-shopping": "التسوق الإلكتروني",
    },
  },
} as const;

function money(locale: Locale, value: number) {
  return new Intl.NumberFormat(locale === "ar" ? "ar-SA" : "en-SA", {
    style: "currency",
    currency: "SAR",
    maximumFractionDigits: 2,
  }).format(value);
}

function number(locale: Locale, value: number) {
  return new Intl.NumberFormat(locale === "ar" ? "ar-SA" : "en-SA", {
    maximumFractionDigits: 2,
  }).format(value);
}

export function CalculatorPage({
  locale,
  options,
  card,
  selected,
  spending,
  valuation,
}: Readonly<{
  locale: Locale;
  options: CardSummary[];
  card: CardDetail | null;
  selected: string;
  spending: MonthlySpending;
  valuation: number;
}>) {
  const text = copy[locale];
  const result = card
    ? calculateAnnualCardValue(card, spending, valuation)
    : null;
  const assumptions =
    result && card
      ? [
          text.annualized,
          result.cashbackParity
            ? text.cashbackParity
            : text.fixedValuation(number(locale, result.valuationApplied)),
          text.ruleSelection,
          text.limitations,
          text.netMethod,
          text.publication(
            card.publication.versionNumber,
            card.publication.effectiveFrom,
          ),
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
        action={`/${locale}/calculator`}
        method="get"
        className="border-line mt-8 rounded-3xl border bg-white p-5"
      >
        <label className="grid max-w-xl gap-2 text-sm font-bold">
          {text.card}
          <select
            name="card"
            defaultValue={selected}
            className="border-line min-h-11 rounded-xl border px-3"
          >
            <option value="">{text.choose}</option>
            {options.map((option) => (
              <option key={option.id} value={option.slug}>
                {locale === "ar" ? option.nameAr : option.nameEn}
              </option>
            ))}
          </select>
        </label>
        <fieldset className="mt-6">
          <legend className="font-bold">{text.monthly}</legend>
          <div className="mt-3 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {spendingCategories.map((category) => (
              <label key={category} className="grid gap-2 text-sm font-bold">
                {text.categories[category]}
                <input
                  name={category}
                  type="number"
                  inputMode="decimal"
                  min="0"
                  max="100000"
                  step="0.01"
                  defaultValue={spending[category] || ""}
                  className="border-line min-h-11 rounded-xl border px-3"
                />
              </label>
            ))}
          </div>
        </fieldset>
        <label className="mt-6 grid max-w-xl gap-2 text-sm font-bold">
          {text.valuation}
          <input
            name="valuation"
            type="number"
            inputMode="decimal"
            min="0"
            max="100"
            step="0.0001"
            defaultValue={valuation || ""}
            className="border-line min-h-11 rounded-xl border px-3"
          />
          <span className="text-muted text-xs leading-5 font-normal">
            {text.valuationHint}
          </span>
        </label>
        <div className="mt-6 flex flex-wrap gap-3">
          <button
            type="submit"
            className="bg-brand min-h-11 rounded-full px-6 font-bold text-white"
          >
            {text.calculate}
          </button>
          <Link className="catalog-filter" href={`/${locale}/calculator`}>
            {text.clear}
          </Link>
        </div>
      </form>
      {!result || !card ? (
        <p className="border-line text-muted mt-10 rounded-3xl border bg-white p-10 text-center">
          {text.empty}
        </p>
      ) : (
        <section className="mt-10" aria-labelledby="calculator-results">
          <h2 id="calculator-results" className="text-3xl font-bold">
            {locale === "ar" ? card.nameAr : card.nameEn}
          </h2>
          <dl className="mt-5 grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
            {[
              [text.annualSpend, money(locale, result.annualSpend)],
              [text.rewardUnits, number(locale, result.annualRewardQuantity)],
              [text.rewardValue, money(locale, result.annualRewardValue)],
              [text.annualFee, money(locale, result.annualFee)],
              [text.netValue, money(locale, result.netValue)],
            ].map(([label, value]) => (
              <div
                key={label}
                className="border-line rounded-2xl border bg-white p-4"
              >
                <dt className="text-muted text-sm">{label}</dt>
                <dd className="mt-2 text-xl font-bold">{value}</dd>
              </div>
            ))}
          </dl>
          <div className="border-line mt-8 overflow-x-auto rounded-3xl border bg-white">
            <table className="w-full min-w-[680px] border-collapse">
              <caption className="p-4 text-start text-xl font-bold">
                {text.breakdown}
              </caption>
              <thead>
                <tr>
                  <th className="border-line border-y p-4 text-start">
                    {text.category}
                  </th>
                  <th className="border-line border-y p-4 text-start">
                    {text.annualSpend}
                  </th>
                  <th className="border-line border-y p-4 text-start">
                    {text.rule}
                  </th>
                  <th className="border-line border-y p-4 text-start">
                    {text.rewardUnits}
                  </th>
                </tr>
              </thead>
              <tbody>
                {result.categoryResults.map((item) => (
                  <tr key={item.category}>
                    <th
                      scope="row"
                      className="border-line border-b p-4 text-start"
                    >
                      {text.categories[item.category]}
                    </th>
                    <td className="border-line border-b p-4">
                      {money(locale, item.annualSpend)}
                    </td>
                    <td className="border-line border-b p-4">
                      {item.rule
                        ? `${item.rule.rewardType} · ${item.rule.calculationMethod} · ${item.rule.rewardValue}`
                        : text.noRule}
                    </td>
                    <td className="border-line border-b p-4">
                      {number(locale, item.rewardQuantity)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <aside
            className="bg-accent-soft mt-8 rounded-3xl p-6"
            aria-labelledby="calculator-assumptions"
          >
            <h3 id="calculator-assumptions" className="text-xl font-bold">
              {text.assumptions}
            </h3>
            <ul className="mt-3 list-disc space-y-2 ps-5 text-sm leading-6">
              {assumptions.map((assumption) => (
                <li key={assumption}>{assumption}</li>
              ))}
            </ul>
          </aside>
        </section>
      )}
    </main>
  );
}
