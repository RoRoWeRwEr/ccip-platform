import type { CardDetail } from "@/features/catalog/data/repository";

export const spendingCategories = [
  "general",
  "groceries",
  "dining",
  "fuel",
  "travel",
  "online-shopping",
] as const;

export type SpendingCategory = (typeof spendingCategories)[number];
export type MonthlySpending = Record<SpendingCategory, number>;

export type CalculationResult = {
  annualSpend: number;
  annualRewardQuantity: number;
  annualRewardValue: number;
  annualFee: number;
  netValue: number;
  categoryResults: Array<{
    category: SpendingCategory;
    annualSpend: number;
    rewardQuantity: number;
    rule: CardDetail["rewardRules"][number] | null;
  }>;
  assumptions: string[];
};

function finiteNonNegative(value: number, maximum: number) {
  return Number.isFinite(value) && value > 0 ? Math.min(value, maximum) : 0;
}

function normalized(value: string | null) {
  return value?.trim().toLowerCase().replaceAll("_", "-") ?? null;
}

function capForYear(amount: number, period: string | null) {
  switch (period) {
    case "MONTH":
      return amount * 12;
    case "QUARTER":
      return amount * 4;
    default:
      return amount;
  }
}

export function calculateAnnualCardValue(
  card: CardDetail,
  monthlySpending: MonthlySpending,
  sarPerRewardUnit: number,
): CalculationResult {
  const valuation = finiteNonNegative(sarPerRewardUnit, 100);
  const generalRules = card.rewardRules.filter(
    (rule) => rule.targets.length === 0,
  );
  const categoryResults = spendingCategories.map((category) => {
    const monthly = finiteNonNegative(monthlySpending[category], 100_000);
    const annualSpend = monthly * 12;
    const targeted = card.rewardRules.find((rule) =>
      rule.targets.some(
        (target) => normalized(target.categorySlug) === category,
      ),
    );
    const rule = targeted ?? generalRules[0] ?? null;
    if (!rule || annualSpend === 0) {
      return { category, annualSpend, rewardQuantity: 0, rule };
    }
    if (rule.minimumSpend !== null && monthly < rule.minimumSpend) {
      return { category, annualSpend, rewardQuantity: 0, rule };
    }
    let rewardQuantity =
      rule.calculationMethod === "PERCENTAGE"
        ? (annualSpend * rule.rewardValue) / 100
        : rule.calculationMethod === "FIXED"
          ? annualSpend * rule.rewardValue
          : 0;
    if (rule.capAmount !== null) {
      rewardQuantity = Math.min(
        rewardQuantity,
        capForYear(rule.capAmount, rule.capPeriod),
      );
    }
    return {
      category,
      annualSpend,
      rewardQuantity: finiteNonNegative(rewardQuantity, 1_000_000_000),
      rule,
    };
  });
  const annualSpend = categoryResults.reduce(
    (total, result) => total + result.annualSpend,
    0,
  );
  const annualRewardQuantity = categoryResults.reduce(
    (total, result) => total + result.rewardQuantity,
    0,
  );
  const cashbackOnly = card.rewardRules.every(
    (rule) => rule.rewardType === "CASHBACK",
  );
  const effectiveValuation = cashbackOnly ? 1 : valuation;
  const annualRewardValue = annualRewardQuantity * effectiveValuation;
  const annualFee = finiteNonNegative(card.annualFee, 1_000_000);
  return {
    annualSpend,
    annualRewardQuantity,
    annualRewardValue,
    annualFee,
    netValue: annualRewardValue - annualFee,
    categoryResults,
    assumptions: [
      "Monthly spending is annualized by multiplying by 12.",
      cashbackOnly
        ? "Cashback is valued at SAR parity (1 reward unit = SAR 1)."
        : `Reward units are valued at the entered fixed reference of SAR ${effectiveValuation.toFixed(4)} per unit.`,
      "The most specific published category rule is used; otherwise the first published general rule applies.",
      "Published minimum-spend and reward-cap fields are applied. Tiered rules without published tiers return zero.",
      "Offers and benefits are excluded from monetary value. Net value is annual reward value minus annual fee.",
      `Catalog publication version ${card.publication.versionNumber}, effective ${card.publication.effectiveFrom}.`,
    ],
  };
}
