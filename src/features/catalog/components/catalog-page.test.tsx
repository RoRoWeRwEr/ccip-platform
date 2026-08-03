import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import type {
  BankSummary,
  CardSummary,
} from "@/features/catalog/data/repository";
import { CatalogPage } from "./catalog-page";

const bank: BankSummary = {
  id: "bank-1",
  slug: "trusted-bank",
  nameAr: "البنك الموثوق",
  nameEn: "Trusted Bank",
  shortNameAr: null,
  shortNameEn: null,
  logoUrl: null,
};

const card: CardSummary = {
  id: "card-1",
  slug: "value-card",
  nameAr: "بطاقة القيمة",
  nameEn: "Value Card",
  annualFee: 0,
  imageUrl: null,
  cardTier: null,
  targetUser: "GENERAL",
  minimumSalary: null,
  publishedAt: "2026-01-01T00:00:00Z",
  bank: {
    id: bank.id,
    slug: bank.slug,
    nameAr: bank.nameAr,
    nameEn: bank.nameEn,
    logoUrl: null,
  },
  network: {
    id: "network-1",
    slug: "visa",
    nameAr: "فيزا",
    nameEn: "Visa",
    logoUrl: null,
  },
  loyaltyProgram: null,
};

describe("catalog browsing page", () => {
  it("renders localized cards, bank state, and stable pagination links", () => {
    render(
      <CatalogPage
        locale="en"
        banks={[bank]}
        networks={[]}
        cards={[card]}
        page={2}
        totalPages={3}
        selectedBank={bank.slug}
        filters={{}}
      />,
    );
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
      "Saudi credit cards",
    );
    expect(screen.getByRole("link", { name: "Trusted Bank" })).toHaveAttribute(
      "aria-current",
      "page",
    );
    expect(
      screen.getByRole("heading", { name: "Value Card" }),
    ).toBeInTheDocument();
    expect(screen.getByText("No annual fee")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "View details" })).toHaveAttribute(
      "href",
      "/en/cards/value-card",
    );
    expect(screen.getByRole("link", { name: "Previous" })).toHaveAttribute(
      "href",
      "/en/cards?bank=trusted-bank",
    );
    expect(screen.getByRole("link", { name: "Next" })).toHaveAttribute(
      "href",
      "/en/cards?bank=trusted-bank&page=3",
    );
  });

  it("renders an honest Arabic empty state without invented catalog data", () => {
    render(
      <CatalogPage
        locale="ar"
        banks={[]}
        networks={[]}
        cards={[]}
        page={1}
        totalPages={0}
        filters={{}}
      />,
    );
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
      "البطاقات الائتمانية السعودية",
    );
    expect(
      screen.getByRole("heading", { name: "لا توجد بطاقات منشورة هنا حالياً" }),
    ).toBeInTheDocument();
    expect(
      screen.queryByRole("link", { name: "التالي" }),
    ).not.toBeInTheDocument();
  });

  it("renders reversible search and filter state", () => {
    render(
      <CatalogPage
        locale="en"
        banks={[bank]}
        networks={[
          { id: "network-1", slug: "visa", nameAr: "فيزا", nameEn: "Visa" },
        ]}
        cards={[]}
        page={1}
        totalPages={0}
        filters={{
          q: "value",
          network: "visa",
          fee: "500",
          persona: "GENERAL",
        }}
      />,
    );
    expect(
      screen.getByRole("searchbox", { name: "Search card names" }),
    ).toHaveValue("value");
    expect(screen.getByRole("combobox", { name: "All networks" })).toHaveValue(
      "visa",
    );
    expect(
      screen.getByRole("link", { name: "Trusted Bank" }).getAttribute("href"),
    ).toContain("q=value");
    expect(screen.getByRole("link", { name: "Clear filters" })).toHaveAttribute(
      "href",
      "/en/cards",
    );
  });
});
