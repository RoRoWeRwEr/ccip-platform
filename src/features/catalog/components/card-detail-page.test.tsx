import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import type { CardDetail } from "@/features/catalog/data/repository";
import { CardDetailPage } from "./card-detail-page";

const card: CardDetail = {
  id: "50000000-0000-4000-8000-000000000001",
  slug: "approved-card",
  nameAr: "البطاقة المعتمدة",
  nameEn: "Approved Card",
  descriptionAr: "وصف عربي",
  descriptionEn: "English description",
  annualFee: 100,
  minimumSalary: 5000,
  imageUrl: null,
  cardTier: "GOLD",
  targetUser: "GENERAL",
  applicationUrl: "https://bank.example/apply",
  termsUrl: "javascript:alert(1)",
  foreignTransactionFeeRate: 2.5,
  bank: {
    id: "50000000-0000-4000-8000-000000000002",
    slug: "bank",
    nameAr: "البنك",
    nameEn: "Bank",
    logoUrl: null,
  },
  network: {
    id: "50000000-0000-4000-8000-000000000003",
    slug: "visa",
    nameAr: "فيزا",
    nameEn: "Visa",
    logoUrl: null,
  },
  currency: { code: "SAR", symbol: "ر.س", decimalPlaces: 2 },
  loyaltyProgram: {
    id: "50000000-0000-4000-8000-000000000004",
    slug: "points",
    nameAr: "نقاط",
    nameEn: "Points",
    type: "BANK_POINTS",
    logoUrl: null,
    websiteUrl: null,
  },
  fees: [
    {
      id: "50000000-0000-4000-8000-000000000005",
      feeType: "ANNUAL",
      nameAr: "رسوم سنوية",
      nameEn: "Annual fee",
      amount: 100,
      percentage: null,
      descriptionAr: null,
      descriptionEn: null,
      billingPeriod: "YEARLY",
    },
  ],
  benefits: [
    {
      id: "50000000-0000-4000-8000-000000000006",
      slug: "lounge",
      nameAr: "صالات",
      nameEn: "Lounge access",
      descriptionAr: null,
      descriptionEn: "Airport access",
      featured: true,
    },
  ],
  rewardRules: [
    {
      id: "50000000-0000-4000-8000-000000000007",
      rewardType: "POINTS",
      calculationMethod: "FIXED",
      rewardValue: 2,
      minimumSpend: null,
      capAmount: null,
      capPeriod: "NONE",
      targets: [
        {
          id: "50000000-0000-4000-8000-000000000008",
          nameAr: "البقالة",
          nameEn: "Groceries",
          categorySlug: null,
        },
      ],
    },
  ],
  eligibility: [
    {
      id: "50000000-0000-4000-8000-000000000009",
      requirementType: "AGE",
      nameAr: "العمر",
      nameEn: "Age",
      descriptionAr: null,
      descriptionEn: "Age 21+",
      minimumAmount: null,
      maximumAmount: null,
      minimumAge: 21,
      maximumAge: null,
      mandatory: true,
    },
  ],
  merchants: [
    {
      id: "50000000-0000-4000-8000-000000000010",
      slug: "merchant",
      nameAr: "تاجر",
      nameEn: "Merchant",
      classification: "RETAIL",
      channelType: "OMNICHANNEL",
    },
  ],
  publication: {
    versionNumber: 3,
    effectiveFrom: "2026-01-01T00:00:00Z",
    effectiveUntil: null,
    publishedAt: "2026-01-01T00:00:00Z",
  },
  provenance: {
    sourceType: "OFFICIAL_PRODUCT_PAGE",
    authorityLevel: "OFFICIAL_PRIMARY",
    sourceLocator: "https://bank.example/card",
    sourceTitle: "Official card page",
    sourceOwner: "Bank",
    retrievedAt: "2026-01-01T00:00:00Z",
    verifiedAt: "2026-01-02T00:00:00Z",
  },
};

describe("published card detail page", () => {
  it("renders every published relationship and safe official links in English", () => {
    render(<CardDetailPage locale="en" card={card} />);
    expect(
      screen.getByRole("heading", { level: 1, name: "Approved Card" }),
    ).toBeInTheDocument();
    for (const heading of [
      "Fees",
      "Benefits",
      "Rewards",
      "Eligibility",
      "Loyalty program",
      "Related merchants",
      "Publication information",
      "Official source",
    ])
      expect(
        screen.getByRole("heading", { name: heading }),
      ).toBeInTheDocument();
    expect(screen.getByText("Groceries")).toBeInTheDocument();
    expect(screen.getByText("Merchant")).toBeInTheDocument();
    expect(
      screen.getByRole("link", { name: "Official application" }),
    ).toHaveAttribute("href", "https://bank.example/apply");
    expect(
      screen.queryByRole("link", { name: "Terms and conditions" }),
    ).not.toBeInTheDocument();
    expect(
      screen.getByRole("link", { name: "Official card page" }),
    ).toHaveAttribute("href", "https://bank.example/card");
  });

  it("renders equivalent Arabic content and honest partial-data states", () => {
    render(
      <CardDetailPage
        locale="ar"
        card={{ ...card, benefits: [], merchants: [] }}
      />,
    );
    expect(
      screen.getByRole("heading", { level: 1, name: "البطاقة المعتمدة" }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("heading", { name: "المزايا" }),
    ).toBeInTheDocument();
    expect(
      screen.getAllByText("لا تتوفر بيانات منشورة لهذا القسم حالياً.").length,
    ).toBeGreaterThanOrEqual(2);
  });
});
