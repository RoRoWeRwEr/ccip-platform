export const locales = ["ar", "en"] as const;

export type Locale = (typeof locales)[number];

export function isLocale(value: string): value is Locale {
  return locales.includes(value as Locale);
}

export const messages = {
  ar: {
    metaTitle: "اختيار أذكى للبطاقات الائتمانية السعودية",
    metaDescription:
      "قارن البطاقات الائتمانية السعودية وافهم الرسوم والمكافآت والقيمة السنوية بوضوح.",
    brand: "ذكاء البطاقات",
    navigationLabel: "التنقل الرئيسي",
    navigation: [
      { href: "/cards", label: "البطاقات" },
      { href: "/compare", label: "المقارنة" },
      { href: "/recommendation", label: "التوصية" },
    ],
    languageSwitch: "English",
    languageSwitchLabel: "Switch to English",
    skipLink: "انتقل إلى المحتوى الرئيسي",
    eyebrow: "قرارات أوضح، قيمة أكبر",
    title: "اعرف القيمة الحقيقية لبطاقتك الائتمانية.",
    description:
      "قارن بطاقات الائتمان السعودية، افهم الرسوم والمكافآت، واختر بثقة بناءً على طريقة إنفاقك.",
    primaryAction: "استكشف البطاقات",
    secondaryAction: "احسب قيمتك السنوية",
    trustNote:
      "معلومات واضحة من مصادر رسمية. لا نمثل بنكاً ولا نقدم نصيحة مالية أو قراراً ائتمانياً.",
    valuePreviewLabel: "مثال توضيحي للقيمة السنوية",
    valuePreview: "مثال القيمة السنوية",
    sampleValue: "قيمة سنوية صافية تقديرية",
    signals: [
      { value: "12×", label: "تحويل سنوي" },
      { value: "SAR", label: "قيمة موحّدة" },
      { value: "100%", label: "شرح واضح" },
    ],
    personaEyebrow: "ابدأ بما يهمك",
    personaTitle: "أي نوع من القيمة تبحث عنه؟",
    personaDescription:
      "اختر هدفاً لنأخذك إلى بطاقات مناسبة كبداية. يمكنك دائماً تعديل الفلاتر لاحقاً.",
    personas: [
      {
        key: "cashback",
        title: "استرداد نقدي",
        description: "للباحثين عن قيمة مباشرة وواضحة على مشترياتهم اليومية.",
        action: "عرض بطاقات الاسترداد",
      },
      {
        key: "travel",
        title: "سفر وأميال",
        description:
          "للمسافرين الذين يهتمون بالأميال والمطارات ومزايا الرحلات.",
        action: "عرض بطاقات السفر",
      },
      {
        key: "everyday",
        title: "قيمة يومية",
        description: "لمن يريد توازناً عملياً بين الرسوم والمكافآت والمزايا.",
        action: "عرض الخيارات المتوازنة",
      },
    ],
    principlesTitle: "وضوح يمكنك الاعتماد عليه",
    principles: [
      {
        title: "بيانات موثوقة",
        description:
          "نعرض معلومات الكتالوج المنشورة والمستندة إلى مصادر رسمية فقط.",
      },
      {
        title: "قيمة قابلة للفهم",
        description:
          "نوضح الرسوم والمكافآت والافتراضات بدلاً من إخفائها خلف ترتيب غامض.",
      },
      {
        title: "اختيارك أولاً",
        description: "الأداة للمقارنة ودعم القرار؛ القرار النهائي لك دائماً.",
      },
    ],
    disclaimer:
      "CCIP منصة معلومات ودعم قرار، وليست بنكاً أو مقرضاً أو مستشاراً مالياً. راجع الشروط الرسمية قبل التقديم.",
  },
  en: {
    metaTitle: "Smarter choices for Saudi credit cards",
    metaDescription:
      "Compare Saudi credit cards and understand fees, rewards, and annual value with clarity.",
    brand: "Card Intelligence",
    navigationLabel: "Primary navigation",
    navigation: [
      { href: "/cards", label: "Cards" },
      { href: "/compare", label: "Compare" },
      { href: "/recommendation", label: "Recommendation" },
    ],
    languageSwitch: "العربية",
    languageSwitchLabel: "التبديل إلى العربية",
    skipLink: "Skip to main content",
    eyebrow: "Clearer choices, stronger value",
    title: "Know what your credit card is really worth.",
    description:
      "Compare Saudi credit cards, understand fees and rewards, and choose confidently around the way you spend.",
    primaryAction: "Explore cards",
    secondaryAction: "Calculate annual value",
    trustNote:
      "Clear information from official sources. We are not a bank and do not provide financial advice or credit decisions.",
    valuePreviewLabel: "Illustrative annual value example",
    valuePreview: "Annual value example",
    sampleValue: "Estimated annual net value",
    signals: [
      { value: "12×", label: "Annualized" },
      { value: "SAR", label: "Common value" },
      { value: "100%", label: "Explained" },
    ],
    personaEyebrow: "Start with what matters",
    personaTitle: "What kind of value are you looking for?",
    personaDescription:
      "Choose a goal and we will take you to a useful starting set. You can refine the filters at any time.",
    personas: [
      {
        key: "cashback",
        title: "Cashback",
        description:
          "For straightforward value back on the purchases you make every day.",
        action: "See cashback cards",
      },
      {
        key: "travel",
        title: "Travel and miles",
        description:
          "For travelers who value miles, airport access, and trip benefits.",
        action: "See travel cards",
      },
      {
        key: "everyday",
        title: "Everyday value",
        description:
          "For a practical balance of fees, rewards, and useful benefits.",
        action: "See balanced options",
      },
    ],
    principlesTitle: "Clarity you can rely on",
    principles: [
      {
        title: "Trusted data",
        description:
          "We show published catalog information grounded in official sources.",
      },
      {
        title: "Understandable value",
        description:
          "We explain fees, rewards, and assumptions instead of hiding them behind an opaque ranking.",
      },
      {
        title: "Your choice first",
        description:
          "The product supports comparison and decisions; the final choice always remains yours.",
      },
    ],
    disclaimer:
      "CCIP is an information and decision-support platform, not a bank, lender, or financial adviser. Review official terms before applying.",
  },
} as const satisfies Record<Locale, object>;
