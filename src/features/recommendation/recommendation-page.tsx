import Link from "next/link";
import type { CardDetail } from "@/features/catalog/data/repository";
import {
  spendingCategories,
  type MonthlySpending,
} from "@/features/calculator/calculation";
import { recommendCards, type RecommendationGoal } from "./engine";
import type { Locale } from "@/lib/i18n";

const copy = {
  en: {
    title: "Card recommendation",
    intro:
      "Compare deterministic estimated annual value for your goal and spending. This is decision support, not financial advice or an approval prediction.",
    goal: "Primary goal",
    goals: {
      CASHBACK: "Cashback",
      MILES: "Miles",
      GENERAL_VALUE: "General value",
    },
    spending: "Monthly spending (SAR)",
    categories: {
      general: "Other/general",
      groceries: "Groceries",
      dining: "Dining",
      fuel: "Fuel",
      travel: "Travel",
      "online-shopping": "Online shopping",
    },
    salary: "Monthly salary (SAR, optional)",
    fee: "Maximum annual fee (SAR, optional)",
    points: "Fixed SAR value per point",
    miles: "Fixed SAR value per mile",
    submit: "Show recommendations",
    clear: "Clear",
    empty: "Enter spending and choose a goal to see eligible published cards.",
    noResults:
      "No published recommendation-eligible card matches these inputs.",
    reward: "Estimated annual rewards",
    annualFee: "Annual fee",
    net: "Estimated net annual value",
    confidence: "Valuation confidence",
    top: "Top spending categories",
    why: "Why this result",
    details: "View published card details",
    reasons: (goal: string, version: number) => [
      `Ranked deterministically by net annual value for the ${goal} goal.`,
      "Annual reward value uses your monthly spending and fixed SAR reward-unit assumptions.",
      `Uses published catalog version ${version}; offers and benefits are excluded from monetary value.`,
    ],
  },
  ar: {
    title: "توصية البطاقة",
    intro:
      "قارن القيمة السنوية التقديرية بطريقة حتمية حسب هدفك وإنفاقك. هذه أداة دعم قرار وليست نصيحة مالية أو توقعاً للموافقة.",
    goal: "الهدف الأساسي",
    goals: {
      CASHBACK: "الاسترداد النقدي",
      MILES: "الأميال",
      GENERAL_VALUE: "القيمة العامة",
    },
    spending: "الإنفاق الشهري (ر.س)",
    categories: {
      general: "أخرى/عامة",
      groceries: "البقالة",
      dining: "المطاعم",
      fuel: "الوقود",
      travel: "السفر",
      "online-shopping": "التسوق الإلكتروني",
    },
    salary: "الراتب الشهري (ر.س، اختياري)",
    fee: "الحد الأعلى للرسوم السنوية (ر.س، اختياري)",
    points: "القيمة الثابتة بالريال لكل نقطة",
    miles: "القيمة الثابتة بالريال لكل ميل",
    submit: "عرض التوصيات",
    clear: "مسح",
    empty: "أدخل إنفاقك واختر هدفاً لعرض البطاقات المنشورة المؤهلة.",
    noResults: "لا توجد بطاقة منشورة ومؤهلة للتوصية تطابق هذه المدخلات.",
    reward: "المكافآت السنوية التقديرية",
    annualFee: "الرسوم السنوية",
    net: "صافي القيمة السنوية التقديرية",
    confidence: "ثقة التقييم",
    top: "أهم فئات الإنفاق",
    why: "سبب النتيجة",
    details: "عرض تفاصيل البطاقة المنشورة",
    reasons: (goal: string, version: number) => [
      `رُتبت النتيجة حتمياً حسب صافي القيمة السنوية لهدف ${goal}.`,
      "تستخدم قيمة المكافآت إنفاقك الشهري وافتراضات قيمة ثابتة بالريال.",
      `تستخدم إصدار الكتالوج المنشور ${version}، ولا تدخل العروض والمزايا في القيمة النقدية.`,
    ],
  },
} as const;

function money(locale: Locale, value: number) {
  return new Intl.NumberFormat(locale === "ar" ? "ar-SA" : "en-SA", {
    style: "currency",
    currency: "SAR",
    maximumFractionDigits: 2,
  }).format(value);
}

export function RecommendationPage({
  locale,
  candidates,
  goal,
  spending,
  salary,
  maximumFee,
  pointsValue,
  milesValue,
  submitted,
}: Readonly<{
  locale: Locale;
  candidates: CardDetail[];
  goal: RecommendationGoal;
  spending: MonthlySpending;
  salary: number | null;
  maximumFee: number | null;
  pointsValue: number;
  milesValue: number;
  submitted: boolean;
}>) {
  const text = copy[locale];
  const results = submitted
    ? recommendCards(
        candidates.map((card) => ({
          card,
          recommendationEligible: true,
          available: true,
          published: true,
        })),
        {
          spending,
          goal,
          monthlySalary: salary,
          maximumAnnualFee: maximumFee,
          sarPerRewardUnit: { POINTS: pointsValue, MILES: milesValue },
        },
      )
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
        action={`/${locale}/recommendation`}
        method="get"
        className="border-line mt-8 rounded-3xl border bg-white p-5"
      >
        <label className="grid max-w-xl gap-2 text-sm font-bold">
          {text.goal}
          <select
            name="goal"
            defaultValue={goal}
            className="border-line min-h-11 rounded-xl border px-3"
          >
            {(Object.keys(text.goals) as RecommendationGoal[]).map((value) => (
              <option key={value} value={value}>
                {text.goals[value]}
              </option>
            ))}
          </select>
        </label>
        <fieldset className="mt-6">
          <legend className="font-bold">{text.spending}</legend>
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
        <div className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {[
            ["salary", text.salary, salary],
            ["fee", text.fee, maximumFee],
            ["points", text.points, pointsValue],
            ["miles", text.miles, milesValue],
          ].map(([name, label, value]) => (
            <label key={String(name)} className="grid gap-2 text-sm font-bold">
              {label}
              <input
                name={String(name)}
                type="number"
                inputMode="decimal"
                min="0"
                max={name === "salary" ? 1000000 : 100}
                step={name === "salary" || name === "fee" ? "0.01" : "0.0001"}
                defaultValue={(value as number | null) ?? ""}
                className="border-line min-h-11 rounded-xl border px-3"
              />
            </label>
          ))}
        </div>
        <div className="mt-6 flex flex-wrap gap-3">
          <button
            type="submit"
            className="bg-brand min-h-11 rounded-full px-6 font-bold text-white"
          >
            {text.submit}
          </button>
          <Link className="catalog-filter" href={`/${locale}/recommendation`}>
            {text.clear}
          </Link>
        </div>
      </form>
      {!submitted ? (
        <p className="border-line text-muted mt-10 rounded-3xl border bg-white p-10 text-center">
          {text.empty}
        </p>
      ) : results.length === 0 ? (
        <p className="border-line text-muted mt-10 rounded-3xl border bg-white p-10 text-center">
          {text.noResults}
        </p>
      ) : (
        <ol className="mt-10 grid gap-6">
          {results.map((result) => (
            <li
              key={result.card.id}
              className="border-line rounded-3xl border bg-white p-6"
            >
              <div className="flex flex-wrap items-start justify-between gap-4">
                <div>
                  <p className="text-brand text-sm font-bold">#{result.rank}</p>
                  <h2 className="mt-1 text-2xl font-bold">
                    {locale === "ar" ? result.card.nameAr : result.card.nameEn}
                  </h2>
                  <p className="text-muted mt-1">
                    {locale === "ar"
                      ? result.card.bank.nameAr
                      : result.card.bank.nameEn}
                  </p>
                </div>
                <p className="bg-accent-soft text-accent-deep rounded-full px-4 py-2 text-sm font-bold">
                  {text.confidence}: {result.confidence}
                </p>
              </div>
              <dl className="mt-5 grid gap-3 sm:grid-cols-3">
                {[
                  [text.reward, result.annualRewardValue],
                  [text.annualFee, result.annualFee],
                  [text.net, result.netValue],
                ].map(([label, value]) => (
                  <div key={String(label)}>
                    <dt className="text-muted text-sm">{label}</dt>
                    <dd className="mt-1 text-xl font-bold">
                      {money(locale, Number(value))}
                    </dd>
                  </div>
                ))}
              </dl>
              {result.topCategories.length > 0 && (
                <p className="mt-5 text-sm">
                  <strong>{text.top}:</strong>{" "}
                  {result.topCategories
                    .map(
                      (category) =>
                        text.categories[
                          category as keyof typeof text.categories
                        ],
                    )
                    .join(", ")}
                </p>
              )}
              <h3 className="mt-5 font-bold">{text.why}</h3>
              <ul className="mt-2 list-disc space-y-1 ps-5 text-sm leading-6">
                {text
                  .reasons(
                    text.goals[goal],
                    result.card.publication.versionNumber,
                  )
                  .map((reason) => (
                    <li key={reason}>{reason}</li>
                  ))}
              </ul>
              <Link
                className="text-brand mt-5 inline-block font-bold underline"
                href={`/${locale}/cards/${result.card.slug}`}
              >
                {text.details}
              </Link>
            </li>
          ))}
        </ol>
      )}
    </main>
  );
}
