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
  valuationApplied: number;
  cashbackParity: boolean;
  categoryResults: Array<{
    category: SpendingCategory;
    annualSpend: number;
    rewardQuantity: number;
    rule: CardDetail["rewardRules"][number] | null;
    limitation: "TIERED" | "MINIMUM_PERIOD" | null;
  }>;
};

const MONEY_SCALE = 100n;
const RATE_SCALE = 1_000_000n;
const MAX_MONTHLY_HALALAS = 10_000_000n;
const MAX_REWARD_MICRO_UNITS = 1_000_000_000_000_000n;

function boundedScaled(value: number, scale: bigint, maximum: bigint) {
  if (!Number.isFinite(value) || value <= 0) return 0n;
  if (value >= Number(maximum) / Number(scale)) return maximum;
  const scaled = BigInt(Math.round(value * Number(scale)));
  return scaled > maximum ? maximum : scaled;
}

function divideHalfUp(numerator: bigint, denominator: bigint) {
  return (numerator + denominator / 2n) / denominator;
}

function toNumber(value: bigint, scale: bigint) {
  return Number(value) / Number(scale);
}

function normalized(value: string | null) {
  return value?.trim().toLowerCase().replaceAll("_", "-") ?? null;
}

function annualCapMicroUnits(amount: number, period: string | null) {
  const base = boundedScaled(amount, RATE_SCALE, MAX_REWARD_MICRO_UNITS);
  switch (period) {
    case "MONTH":
      return base * 12n;
    case "QUARTER":
      return base * 4n;
    default:
      return base;
  }
}

function roundReward(value: bigint, method: string) {
  const whole = value / RATE_SCALE;
  const remainder = value % RATE_SCALE;
  if (remainder === 0n || method === "NONE") return value;
  if (method === "UP") return (whole + 1n) * RATE_SCALE;
  if (method === "DOWN") return whole * RATE_SCALE;
  if (method === "NEAREST") {
    return (whole + (remainder * 2n >= RATE_SCALE ? 1n : 0n)) * RATE_SCALE;
  }
  return value;
}

function meetsMinimum(
  monthlyHalalas: bigint,
  annualHalalas: bigint,
  minimum: number | null,
  period: string | null,
) {
  if (minimum === null) return { meets: true, unsupported: false };
  const minimumHalalas = boundedScaled(
    minimum,
    MONEY_SCALE,
    MAX_MONTHLY_HALALAS * 12n,
  );
  if (period === "YEAR") {
    return { meets: annualHalalas >= minimumHalalas, unsupported: false };
  }
  if (period === "MONTH" || period === null) {
    return { meets: monthlyHalalas >= minimumHalalas, unsupported: false };
  }
  return { meets: false, unsupported: true };
}

export function calculateAnnualCardValue(
  card: CardDetail,
  monthlySpending: MonthlySpending,
  sarPerRewardUnit: number,
): CalculationResult {
  const valuationMicroSar = boundedScaled(
    sarPerRewardUnit,
    RATE_SCALE,
    100n * RATE_SCALE,
  );
  const generalRules = card.rewardRules.filter(
    (rule) => rule.targets.length === 0,
  );
  const uncappedResults = spendingCategories.map((category) => {
    const monthlyHalalas = boundedScaled(
      monthlySpending[category],
      MONEY_SCALE,
      MAX_MONTHLY_HALALAS,
    );
    const annualHalalas = monthlyHalalas * 12n;
    const targeted = card.rewardRules.find((rule) =>
      rule.targets.some(
        (target) => normalized(target.categorySlug) === category,
      ),
    );
    const rule = targeted ?? generalRules[0] ?? null;
    if (!rule || annualHalalas === 0n) {
      return {
        category,
        annualHalalas,
        rewardMicroUnits: 0n,
        rule,
        limitation: null,
      };
    }
    const minimum = meetsMinimum(
      monthlyHalalas,
      annualHalalas,
      rule.minimumSpend,
      rule.minimumSpendPeriod,
    );
    if (!minimum.meets) {
      return {
        category,
        annualHalalas,
        rewardMicroUnits: 0n,
        rule,
        limitation: minimum.unsupported ? ("MINIMUM_PERIOD" as const) : null,
      };
    }
    const rateMicro = boundedScaled(
      rule.rewardValue,
      RATE_SCALE,
      1_000_000n * RATE_SCALE,
    );
    let rewardMicroUnits =
      rule.calculationMethod === "PERCENTAGE"
        ? divideHalfUp(annualHalalas * rateMicro, 10_000n)
        : rule.calculationMethod === "FIXED"
          ? divideHalfUp(annualHalalas * rateMicro, MONEY_SCALE)
          : 0n;
    const limitation =
      rule.calculationMethod === "TIERED" ? ("TIERED" as const) : null;
    rewardMicroUnits = roundReward(rewardMicroUnits, rule.roundingMethod);
    return {
      category,
      annualHalalas,
      rewardMicroUnits:
        rewardMicroUnits > MAX_REWARD_MICRO_UNITS
          ? MAX_REWARD_MICRO_UNITS
          : rewardMicroUnits,
      rule,
      limitation,
    };
  });
  const usedCaps = new Map<string, bigint>();
  const internalResults = uncappedResults.map((result) => {
    if (!result.rule || result.rule.capAmount === null) return result;
    const cap = annualCapMicroUnits(
      result.rule.capAmount,
      result.rule.capPeriod,
    );
    const used = usedCaps.get(result.rule.id) ?? 0n;
    const remaining = cap > used ? cap - used : 0n;
    const rewardMicroUnits =
      result.rewardMicroUnits < remaining ? result.rewardMicroUnits : remaining;
    usedCaps.set(result.rule.id, used + rewardMicroUnits);
    return { ...result, rewardMicroUnits };
  });
  const annualSpendHalalas = internalResults.reduce(
    (total, result) => total + result.annualHalalas,
    0n,
  );
  const annualRewardMicroUnits = internalResults.reduce(
    (total, result) => total + result.rewardMicroUnits,
    0n,
  );
  const cashbackParity =
    card.rewardRules.length > 0 &&
    card.rewardRules.every((rule) => rule.rewardType === "CASHBACK");
  const appliedValuation = cashbackParity ? RATE_SCALE : valuationMicroSar;
  const rewardValueHalalas = divideHalfUp(
    annualRewardMicroUnits * appliedValuation * MONEY_SCALE,
    RATE_SCALE * RATE_SCALE,
  );
  const annualFeeHalalas = boundedScaled(
    card.annualFee,
    MONEY_SCALE,
    100_000_000n,
  );
  return {
    annualSpend: toNumber(annualSpendHalalas, MONEY_SCALE),
    annualRewardQuantity: toNumber(annualRewardMicroUnits, RATE_SCALE),
    annualRewardValue: toNumber(rewardValueHalalas, MONEY_SCALE),
    annualFee: toNumber(annualFeeHalalas, MONEY_SCALE),
    netValue: toNumber(rewardValueHalalas - annualFeeHalalas, MONEY_SCALE),
    valuationApplied: toNumber(appliedValuation, RATE_SCALE),
    cashbackParity,
    categoryResults: internalResults.map((result) => ({
      category: result.category,
      annualSpend: toNumber(result.annualHalalas, MONEY_SCALE),
      rewardQuantity: toNumber(result.rewardMicroUnits, RATE_SCALE),
      rule: result.rule,
      limitation: result.limitation,
    })),
  };
}
