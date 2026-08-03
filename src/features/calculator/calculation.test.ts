import { describe, expect, it } from "vitest";
import type { CardDetail } from "@/features/catalog/data/repository";
import { calculateAnnualCardValue, type MonthlySpending } from "./calculation";

const spending: MonthlySpending = {
  general: 0,
  groceries: 1_000,
  dining: 500,
  fuel: 0,
  travel: 0,
  "online-shopping": 0,
};

function card(rewardRules: CardDetail["rewardRules"]): CardDetail {
  return {
    id: "11111111-1111-4111-8111-111111111111",
    slug: "test-card",
    nameAr: "بطاقة",
    nameEn: "Card",
    descriptionAr: null,
    descriptionEn: null,
    annualFee: 100,
    minimumSalary: null,
    imageUrl: null,
    cardTier: null,
    targetUser: null,
    applicationUrl: null,
    termsUrl: null,
    foreignTransactionFeeRate: null,
    bank: {
      id: "b",
      slug: "bank",
      nameAr: "بنك",
      nameEn: "Bank",
      logoUrl: null,
    },
    network: {
      id: "n",
      slug: "visa",
      nameAr: "فيزا",
      nameEn: "Visa",
      logoUrl: null,
    },
    currency: { code: "SAR", symbol: "SAR", decimalPlaces: 2 },
    loyaltyProgram: null,
    fees: [],
    benefits: [],
    rewardRules,
    eligibility: [],
    merchants: [],
    publication: {
      versionNumber: 2,
      effectiveFrom: "2026-01-01",
      effectiveUntil: null,
      publishedAt: "2026-01-01",
    },
    provenance: null,
  };
}

describe("annual card value calculator", () => {
  it("annualizes categories, prefers a targeted rule, applies caps, and subtracts the fee", () => {
    const result = calculateAnnualCardValue(
      card([
        {
          id: "general",
          rewardType: "POINTS",
          calculationMethod: "FIXED",
          rewardValue: 1,
          minimumSpend: null,
          minimumSpendPeriod: null,
          capAmount: null,
          capPeriod: null,
          roundingMethod: "NONE",
          targets: [],
        },
        {
          id: "grocery",
          rewardType: "POINTS",
          calculationMethod: "FIXED",
          rewardValue: 2,
          minimumSpend: null,
          minimumSpendPeriod: null,
          capAmount: 10_000,
          capPeriod: "YEAR",
          roundingMethod: "NONE",
          targets: [
            { id: "t", nameAr: null, nameEn: null, categorySlug: "groceries" },
          ],
        },
      ]),
      spending,
      0.01,
    );
    expect(result.annualSpend).toBe(18_000);
    expect(result.annualRewardQuantity).toBe(16_000);
    expect(result.annualRewardValue).toBe(160);
    expect(result.netValue).toBe(60);
  });

  it("uses SAR parity for cashback and returns finite values for unsafe inputs", () => {
    const result = calculateAnnualCardValue(
      card([
        {
          id: "cash",
          rewardType: "CASHBACK",
          calculationMethod: "PERCENTAGE",
          rewardValue: 2,
          minimumSpend: null,
          minimumSpendPeriod: null,
          capAmount: null,
          capPeriod: null,
          roundingMethod: "NONE",
          targets: [],
        },
      ]),
      { ...spending, groceries: Number.POSITIVE_INFINITY, dining: -20 },
      Number.NaN,
    );
    expect(result.annualRewardValue).toBe(0);
    expect(result.netValue).toBe(-100);
    expect(
      Object.values(result).some(
        (value) => typeof value === "number" && !Number.isFinite(value),
      ),
    ).toBe(false);
  });

  it("returns zero for unmet minimum spend and unsupported tiered rules", () => {
    const result = calculateAnnualCardValue(
      card([
        {
          id: "tier",
          rewardType: "POINTS",
          calculationMethod: "TIERED",
          rewardValue: 5,
          minimumSpend: 2_000,
          minimumSpendPeriod: "MONTH",
          capAmount: null,
          capPeriod: null,
          roundingMethod: "NONE",
          targets: [],
        },
      ]),
      spending,
      0.1,
    );
    expect(result.annualRewardQuantity).toBe(0);
  });

  it("applies monthly caps, reward rounding, and halala currency rounding", () => {
    const result = calculateAnnualCardValue(
      card([
        {
          id: "rounded",
          rewardType: "POINTS",
          calculationMethod: "PERCENTAGE",
          rewardValue: 0.333333,
          minimumSpend: null,
          minimumSpendPeriod: null,
          capAmount: 1.2,
          capPeriod: "MONTH",
          roundingMethod: "DOWN",
          targets: [],
        },
      ]),
      { ...spending, groceries: 10, dining: 0 },
      0.333333,
    );
    expect(result.annualRewardQuantity).toBe(0);
    expect(result.annualRewardValue).toBe(0);
    expect(result.netValue).toBe(-100);
  });

  it("shares a published cap across every category using the same rule", () => {
    const result = calculateAnnualCardValue(
      card([
        {
          id: "shared-cap",
          rewardType: "POINTS",
          calculationMethod: "FIXED",
          rewardValue: 1,
          minimumSpend: null,
          minimumSpendPeriod: null,
          capAmount: 100,
          capPeriod: "YEAR",
          roundingMethod: "NONE",
          targets: [],
        },
      ]),
      spending,
      1,
    );
    expect(result.annualRewardQuantity).toBe(100);
    expect(result.annualRewardValue).toBe(100);
    expect(result.netValue).toBe(0);
  });

  it("maintains finite bounded deterministic outputs across edge-oriented input combinations", () => {
    const values = [
      Number.NaN,
      Number.NEGATIVE_INFINITY,
      -1,
      0,
      0.001,
      0.1,
      999.99,
      100_000,
      Number.POSITIVE_INFINITY,
      Number.MAX_VALUE,
    ];
    const testCard = card([
      {
        id: "property",
        rewardType: "POINTS",
        calculationMethod: "PERCENTAGE",
        rewardValue: 12.345678,
        minimumSpend: 0.01,
        minimumSpendPeriod: "YEAR",
        capAmount: 50_000,
        capPeriod: "YEAR",
        roundingMethod: "NEAREST",
        targets: [],
      },
    ]);
    for (const spend of values) {
      for (const valuation of values) {
        const input = {
          ...spending,
          general: spend,
          groceries: spend,
          dining: spend,
        };
        const first = calculateAnnualCardValue(testCard, input, valuation);
        const second = calculateAnnualCardValue(testCard, input, valuation);
        expect(first).toEqual(second);
        for (const output of [
          first.annualSpend,
          first.annualRewardQuantity,
          first.annualRewardValue,
          first.annualFee,
          first.netValue,
          first.valuationApplied,
        ]) {
          expect(Number.isFinite(output)).toBe(true);
        }
        expect(first.annualSpend).toBeGreaterThanOrEqual(0);
        expect(first.annualRewardValue).toBeGreaterThanOrEqual(0);
        expect(first.annualFee).toBeGreaterThanOrEqual(0);
        expect(Math.abs((first.annualRewardValue * 100) % 1)).toBeLessThan(
          1e-9,
        );
      }
    }
  });
});
