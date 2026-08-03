import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import type {
  CardDetail,
  CardSummary,
} from "@/features/catalog/data/repository";
import { CalculatorPage } from "./calculator-page";

const summary = {
  id: "11111111-1111-4111-8111-111111111111",
  slug: "cash-card",
  nameAr: "بطاقة الاسترداد",
  nameEn: "Cash Card",
  annualFee: 100,
  imageUrl: null,
  cardTier: null,
  targetUser: "GENERAL",
  minimumSalary: null,
  publishedAt: "2026-01-01",
  bank: {
    id: "22222222-2222-4222-8222-222222222222",
    slug: "bank",
    nameAr: "بنك",
    nameEn: "Bank",
    logoUrl: null,
  },
  network: {
    slug: "visa",
    nameAr: "فيزا",
    nameEn: "Visa",
    logoUrl: null,
  },
  rewardSummary: [],
} satisfies CardSummary;

const detail = {
  ...summary,
  descriptionAr: null,
  descriptionEn: null,
  applicationUrl: null,
  termsUrl: null,
  foreignTransactionFeeRate: null,
  network: {
    ...summary.network,
    id: "33333333-3333-4333-8333-333333333333",
  },
  currency: { code: "SAR", symbol: "SAR", decimalPlaces: 2 },
  loyaltyProgram: null,
  fees: [],
  benefits: [],
  rewardRules: [
    {
      id: "cashback",
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

const spending = {
  general: 1_000,
  groceries: 0,
  dining: 0,
  fuel: 0,
  travel: 0,
  "online-shopping": 0,
};

describe("calculator page", () => {
  it("renders shareable inputs, results, breakdown, and assumptions", () => {
    render(
      <CalculatorPage
        locale="en"
        options={[summary]}
        card={detail}
        selected={summary.slug}
        spending={spending}
        valuation={0}
      />,
    );
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
      "Spending calculator",
    );
    expect(
      screen.getByRole("table", { name: "Calculation breakdown" }),
    ).toBeInTheDocument();
    expect(screen.getByText("Estimated net annual value")).toBeInTheDocument();
    expect(
      screen.getByText(/Cashback is valued at SAR parity/),
    ).toBeInTheDocument();
  });

  it("renders the Arabic empty state and labels", () => {
    render(
      <CalculatorPage
        locale="ar"
        options={[]}
        card={null}
        selected=""
        spending={{ ...spending, general: 0 }}
        valuation={0}
      />,
    );
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
      "حاسبة الإنفاق",
    );
    expect(screen.getByText(/اختر بطاقة وأدخل الإنفاق/)).toBeInTheDocument();
  });
});
