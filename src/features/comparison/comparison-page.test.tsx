import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import type {
  CardDetail,
  CardSummary,
} from "@/features/catalog/data/repository";
import { ComparisonPage } from "./comparison-page";

const summary = {
  id: "11111111-1111-4111-8111-111111111111",
  slug: "one-card",
  nameAr: "بطاقة",
  nameEn: "One Card",
  annualFee: 100,
  imageUrl: null,
  cardTier: null,
  targetUser: "GENERAL",
  minimumSalary: 5000,
  publishedAt: "2026-01-01",
  bank: {
    id: "22222222-2222-4222-8222-222222222222",
    slug: "bank",
    nameAr: "بنك",
    nameEn: "Bank",
    logoUrl: null,
  },
  network: { slug: "visa", nameAr: "فيزا", nameEn: "Visa", logoUrl: null },
  rewardSummary: [],
} satisfies CardSummary;
const detail = {
  ...summary,
  network: { ...summary.network, id: "33333333-3333-4333-8333-333333333333" },
  descriptionAr: null,
  descriptionEn: null,
  applicationUrl: null,
  termsUrl: null,
  foreignTransactionFeeRate: null,
  targetUser: "GENERAL",
  currency: { code: "SAR", symbol: "SAR", decimalPlaces: 2 },
  loyaltyProgram: null,
  fees: [],
  benefits: [],
  rewardRules: [
    {
      id: "r",
      rewardType: "POINTS",
      calculationMethod: "FIXED",
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

describe("comparison page", () => {
  it("renders a shareable selection form and comparison table", () => {
    render(
      <ComparisonPage
        locale="en"
        options={[summary]}
        cards={[detail]}
        selected={[summary.slug]}
      />,
    );
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
      "Compare credit cards",
    );
    expect(screen.getByRole("table")).toBeInTheDocument();
    expect(screen.getByText("POINTS 2")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "View details" })).toHaveAttribute(
      "href",
      "/en/cards/one-card",
    );
  });
  it("renders the Arabic empty state", () => {
    render(
      <ComparisonPage locale="ar" options={[]} cards={[]} selected={[]} />,
    );
    expect(
      screen.getByText("اختر بطاقة واحدة على الأقل لبدء المقارنة."),
    ).toBeInTheDocument();
  });
});
