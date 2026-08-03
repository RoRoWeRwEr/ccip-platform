import type { CardDetail } from "@/features/catalog/data/repository";
import {
  calculateAnnualCardValue,
  type MonthlySpending,
} from "@/features/calculator/calculation";

export type RecommendationGoal = "CASHBACK" | "MILES" | "GENERAL_VALUE";

export type RecommendationCandidate = {
  card: CardDetail;
  recommendationEligible: boolean;
  available: boolean;
  published: boolean;
};

export type RecommendationInput = {
  spending: MonthlySpending;
  goal: RecommendationGoal;
  monthlySalary?: number | null;
  maximumAnnualFee?: number | null;
  preferredBankSlugs?: readonly string[];
  excludedBankSlugs?: readonly string[];
  sarPerRewardUnit: Readonly<Record<string, number>>;
};

export type RecommendationResult = {
  rank: number;
  card: CardDetail;
  annualRewardValue: number;
  annualFee: number;
  netValue: number;
  recommendationScore: number;
  confidence: "HIGH" | "MEDIUM" | "LOW";
  topCategories: string[];
  reasons: string[];
  assumptions: string[];
};

function safeNonNegative(value: number | null | undefined) {
  return typeof value === "number" && Number.isFinite(value) && value >= 0
    ? value
    : null;
}

function goalRewardType(goal: RecommendationGoal) {
  return goal === "GENERAL_VALUE" ? null : goal;
}

function scoreGoal(card: CardDetail, goal: RecommendationGoal) {
  const expected = goalRewardType(goal);
  if (expected === null) return 50;
  return card.rewardRules.some((rule) => rule.rewardType === expected)
    ? 100
    : 0;
}

function localizedName(card: CardDetail) {
  return card.nameEn.normalize("NFKD").toLocaleLowerCase("en");
}

export function recommendCards(
  candidates: readonly RecommendationCandidate[],
  input: RecommendationInput,
): RecommendationResult[] {
  const salary = safeNonNegative(input.monthlySalary);
  const maximumFee = safeNonNegative(input.maximumAnnualFee);
  const preferred = new Set(input.preferredBankSlugs ?? []);
  const excluded = new Set(input.excludedBankSlugs ?? []);

  const evaluated = candidates
    .filter(
      ({ card, recommendationEligible, available, published }) =>
        recommendationEligible &&
        available &&
        published &&
        !excluded.has(card.bank.slug) &&
        (preferred.size === 0 || preferred.has(card.bank.slug)) &&
        (maximumFee === null || card.annualFee <= maximumFee) &&
        (card.minimumSalary === null ||
          (salary !== null && salary >= card.minimumSalary)),
    )
    .map(({ card }) => {
      const value = calculateAnnualCardValue(
        card,
        input.spending,
        input.sarPerRewardUnit,
      );
      const recommendationScore = scoreGoal(card, input.goal);
      const valuedRules = card.rewardRules.filter(
        (rule) =>
          rule.rewardType === "CASHBACK" ||
          safeNonNegative(input.sarPerRewardUnit[rule.rewardType]) !== null,
      );
      const confidence =
        valuedRules.length === card.rewardRules.length && valuedRules.length > 0
          ? "HIGH"
          : valuedRules.length > 0
            ? "MEDIUM"
            : "LOW";
      const topCategories = value.categoryResults
        .filter((result) => result.rewardQuantity > 0)
        .sort(
          (left, right) =>
            right.rewardQuantity - left.rewardQuantity ||
            left.category.localeCompare(right.category),
        )
        .slice(0, 3)
        .map((result) => result.category);
      return {
        rank: 0,
        card,
        annualRewardValue: value.annualRewardValue,
        annualFee: value.annualFee,
        netValue: value.netValue,
        recommendationScore,
        confidence,
        topCategories,
        reasons: [
          `Estimated net annual value is SAR ${value.netValue.toFixed(2)}.`,
          recommendationScore === 100
            ? `Published rewards align with the ${input.goal} goal.`
            : input.goal === "GENERAL_VALUE"
              ? "Ranked for general monetary value."
              : `No published ${input.goal} rule was found; monetary value still determines rank.`,
          `Annual fee is SAR ${value.annualFee.toFixed(2)}.`,
        ],
        assumptions: [
          "Monthly spending is annualized by 12.",
          "Only candidates explicitly marked published, available, and recommendation-eligible are evaluated.",
          "Offers and benefits are excluded from monetary value.",
          "Fixed reward-unit valuations supplied with this run are used; cashback uses SAR parity.",
          `Catalog publication version ${card.publication.versionNumber} effective ${card.publication.effectiveFrom}.`,
        ],
      } satisfies RecommendationResult;
    });

  evaluated.sort(
    (left, right) =>
      right.netValue - left.netValue ||
      right.annualRewardValue - left.annualRewardValue ||
      left.annualFee - right.annualFee ||
      right.recommendationScore - left.recommendationScore ||
      localizedName(left.card).localeCompare(localizedName(right.card)) ||
      left.card.id.localeCompare(right.card.id),
  );
  return evaluated.map((result, index) => ({ ...result, rank: index + 1 }));
}
