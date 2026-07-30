export const locales = ["ar", "en"] as const;

export type Locale = (typeof locales)[number];

export function isLocale(value: string): value is Locale {
  return locales.includes(value as Locale);
}

export const messages = {
  ar: {
    brand: "منصة ذكاء البطاقات",
    navigationLabel: "التنقل الرئيسي",
    languageSwitch: "English",
    eyebrow: "قرارات أوضح، قيمة أكبر",
    title: "اعرف القيمة الحقيقية لبطاقتك الائتمانية.",
    description:
      "قارن بطاقات الائتمان السعودية، افهم الرسوم والمكافآت، واحصل على توصية شفافة تناسب إنفاقك.",
    primaryAction: "استكشف البطاقات",
    secondaryAction: "احسب قيمتك السنوية",
    foundationNotice:
      "يجري الآن بناء تجربة الكتالوج العامة فوق قاعدة بيانات موثوقة ومراجعة.",
    sampleValue: "قيمة سنوية صافية تقديرية",
    signals: [
      { value: "12×", label: "تحويل شهري" },
      { value: "SAR", label: "قيمة موحّدة" },
      { value: "100%", label: "شرح واضح" },
    ],
  },
  en: {
    brand: "Card Intelligence",
    navigationLabel: "Primary navigation",
    languageSwitch: "العربية",
    eyebrow: "Clearer choices, stronger value",
    title: "Know what your credit card is really worth.",
    description:
      "Compare Saudi credit cards, understand fees and rewards, and get a transparent recommendation shaped around your spending.",
    primaryAction: "Explore cards",
    secondaryAction: "Calculate annual value",
    foundationNotice:
      "The public catalog experience is being built on a reviewed, trusted data foundation.",
    sampleValue: "Estimated annual net value",
    signals: [
      { value: "12×", label: "Monthly to annual" },
      { value: "SAR", label: "Common value" },
      { value: "100%", label: "Explained" },
    ],
  },
} as const satisfies Record<Locale, object>;
