import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import type { CardDetail } from "@/features/catalog/data/repository";
import { RecommendationPage } from "./recommendation-page";

const spending = {
  general: 1_000,
  groceries: 0,
  dining: 0,
  fuel: 0,
  travel: 0,
  "online-shopping": 0,
};
const card = {
  id: "11111111-1111-4111-8111-111111111111",
  slug: "cash-card",
  nameAr: "بطاقة",
  nameEn: "Cash Card",
  descriptionAr: null,
  descriptionEn: null,
  annualFee: 100,
  minimumSalary: null,
  imageUrl: null,
  cardTier: null,
  targetUser: "GENERAL",
  applicationUrl: null,
  termsUrl: null,
  foreignTransactionFeeRate: null,
  bank: { id: "b", slug: "bank", nameAr: "بنك", nameEn: "Bank", logoUrl: null },
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
  rewardRules: [
    {
      id: "r",
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
    versionNumber: 3,
    effectiveFrom: "2026-01-01",
    effectiveUntil: null,
    publishedAt: "2026-01-01",
  },
  provenance: null,
} satisfies CardDetail;

describe("recommendation page", () => {
  it("renders ranked explainable published results", () => {
    render(
      <RecommendationPage
        locale="en"
        candidates={[card]}
        goal="CASHBACK"
        spending={spending}
        salary={null}
        maximumFee={null}
        pointsValue={0.01}
        milesValue={0.02}
        submitted
      />,
    );
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
      "Card recommendation",
    );
    expect(screen.getByRole("heading", { level: 2 })).toHaveTextContent(
      "Cash Card",
    );
    expect(
      screen.getByText(/published catalog version 3/i),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("link", { name: "View published card details" }),
    ).toHaveAttribute("href", "/en/cards/cash-card");
  });
  it("renders the Arabic honest empty state", () => {
    render(
      <RecommendationPage
        locale="ar"
        candidates={[]}
        goal="GENERAL_VALUE"
        spending={{ ...spending, general: 0 }}
        salary={null}
        maximumFee={null}
        pointsValue={0}
        milesValue={0}
        submitted
      />,
    );
    expect(screen.getByText(/لا توجد بطاقة منشورة/)).toBeInTheDocument();
  });
});
