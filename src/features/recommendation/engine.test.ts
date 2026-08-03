import { describe, expect, it } from "vitest";
import type { CardDetail } from "@/features/catalog/data/repository";
import type { MonthlySpending } from "@/features/calculator/calculation";
import { recommendCards, type RecommendationCandidate } from "./engine";

const spending: MonthlySpending = {
  general: 1_000,
  groceries: 0,
  dining: 0,
  fuel: 0,
  travel: 0,
  "online-shopping": 0,
};

function candidate({
  id,
  name,
  rewardType = "CASHBACK",
  rewardValue = 1,
  annualFee = 0,
  minimumSalary = null,
  bank = "bank",
  eligible = true,
}: {
  id: string;
  name: string;
  rewardType?: string;
  rewardValue?: number;
  annualFee?: number;
  minimumSalary?: number | null;
  bank?: string;
  eligible?: boolean;
}): RecommendationCandidate {
  const card = {
    id,
    slug: name.toLowerCase().replaceAll(" ", "-"),
    nameAr: name,
    nameEn: name,
    descriptionAr: null,
    descriptionEn: null,
    annualFee,
    minimumSalary,
    imageUrl: null,
    cardTier: null,
    targetUser: "GENERAL",
    applicationUrl: null,
    termsUrl: null,
    foreignTransactionFeeRate: null,
    bank: {
      id: `bank-${id}`,
      slug: bank,
      nameAr: bank,
      nameEn: bank,
      logoUrl: null,
    },
    network: {
      id: `network-${id}`,
      slug: "visa",
      nameAr: "فيزا",
      nameEn: "Visa",
      logoUrl: null,
    },
    currency: { code: "SAR", symbol: "SAR", decimalPlaces: 2 },
    loyaltyProgram: null,
    fees: [],
    benefits: [],
    rewardRules: [
      {
        id: `rule-${id}`,
        rewardType,
        calculationMethod: "PERCENTAGE",
        rewardValue,
        minimumSpend: null,
        minimumSpendPeriod: null,
        capAmount: null,
        capPeriod: null,
        roundingMethod: "NONE",
        targets: [],
      },
    ],
    eligibility: [],
    merchants: [],
    publication: {
      versionNumber: 1,
      effectiveFrom: "2026-01-01",
      effectiveUntil: null,
      publishedAt: "2026-01-01",
    },
    provenance: null,
  } satisfies CardDetail;
  return {
    card,
    recommendationEligible: eligible,
    available: true,
    published: true,
  };
}

describe("recommendation domain engine", () => {
  it("filters eligibility and preferences then ranks deterministically by approved tie-breakers", () => {
    const results = recommendCards(
      [
        candidate({ id: "a", name: "Alpha", rewardValue: 2, annualFee: 100 }),
        candidate({ id: "b", name: "Beta", rewardValue: 1, annualFee: 0 }),
        candidate({ id: "c", name: "Gamma", rewardValue: 9, eligible: false }),
        candidate({
          id: "d",
          name: "Salary",
          rewardValue: 10,
          minimumSalary: 20_000,
        }),
        candidate({
          id: "e",
          name: "Excluded",
          rewardValue: 10,
          bank: "blocked",
        }),
      ],
      {
        spending,
        goal: "CASHBACK",
        monthlySalary: 10_000,
        excludedBankSlugs: ["blocked"],
        sarPerRewardUnit: {},
      },
    );
    expect(results.map((result) => result.card.nameEn)).toEqual([
      "Alpha",
      "Beta",
    ]);
    expect(results.map((result) => result.rank)).toEqual([1, 2]);
    expect(results[0].netValue).toBe(140);
  });

  it("uses fixed valuations, goal alignment, stable name ordering, and explanation output", () => {
    const results = recommendCards(
      [
        candidate({
          id: "b",
          name: "Zulu",
          rewardType: "MILES",
          rewardValue: 1,
        }),
        candidate({
          id: "a",
          name: "Alpha",
          rewardType: "POINTS",
          rewardValue: 2,
        }),
      ],
      {
        spending,
        goal: "MILES",
        sarPerRewardUnit: { MILES: 0.02, POINTS: 0.01 },
      },
    );
    expect(results.map((result) => result.card.nameEn)).toEqual([
      "Zulu",
      "Alpha",
    ]);
    expect(results[0].recommendationScore).toBe(100);
    expect(results[0].confidence).toBe("HIGH");
    expect(results[0].reasons).toHaveLength(3);
    expect(results[0].assumptions.join(" ")).toContain("publication version");
  });

  it("returns identical finite results for identical inputs", () => {
    const candidates = [candidate({ id: "a", name: "Stable", rewardValue: 2 })];
    const input = {
      spending,
      goal: "GENERAL_VALUE" as const,
      sarPerRewardUnit: {},
    };
    const first = recommendCards(candidates, input);
    expect(recommendCards(candidates, input)).toEqual(first);
    expect(Number.isFinite(first[0].netValue)).toBe(true);
  });
});
