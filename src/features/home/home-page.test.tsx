import { render, screen, within } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { SiteHeader } from "@/components/site-header";
import { HomePage } from "./home-page";

function renderPage(locale: "ar" | "en") {
  render(
    <>
      <a href="#main-content">
        {locale === "ar" ? "انتقل إلى المحتوى الرئيسي" : "Skip to main content"}
      </a>
      <SiteHeader locale={locale} />
      <HomePage locale={locale} />
    </>,
  );
}

describe("localized homepage", () => {
  it("provides an accessible English shell and real journey links", () => {
    renderPage("en");

    expect(
      screen.getByRole("link", { name: "Skip to main content" }),
    ).toHaveAttribute("href", "#main-content");
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
      "Know what your credit card is really worth.",
    );
    const navigation = screen.getByRole("navigation", {
      name: "Primary navigation",
    });
    expect(
      within(navigation).getByRole("link", { name: "Cards" }),
    ).toHaveAttribute("href", "/en/cards");
    expect(screen.getByRole("link", { name: "Explore cards" })).toHaveAttribute(
      "href",
      "/en/cards",
    );
    expect(
      screen.getByRole("link", { name: /See cashback cards/ }),
    ).toHaveAttribute("href", "/en/cards?persona=cashback");
    expect(
      screen.getByRole("link", { name: "التبديل إلى العربية" }),
    ).toHaveAttribute("href", "/ar");
  });

  it("provides equivalent Arabic navigation and persona entry points", () => {
    renderPage("ar");

    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
      "اعرف القيمة الحقيقية",
    );
    expect(
      screen.getByRole("navigation", { name: "التنقل الرئيسي" }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("link", { name: "استكشف البطاقات" }),
    ).toHaveAttribute("href", "/ar/cards");
    expect(
      screen.getByRole("link", { name: /عرض بطاقات السفر/ }),
    ).toHaveAttribute("href", "/ar/cards?persona=travel");
    expect(
      screen.getByRole("link", { name: "Switch to English" }),
    ).toHaveAttribute("href", "/en");
  });
});
