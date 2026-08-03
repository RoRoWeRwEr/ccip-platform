import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { AccountPage } from "./account-page";

describe("account page", () => {
  it("renders owner-scoped profile, saved cards, and comparisons", () => {
    render(
      <AccountPage
        locale="en"
        dashboard={{
          email: "member@example.test",
          profile: {
            displayName: "Member",
            language: "en",
            timezone: "Asia/Riyadh",
            onboardingStatus: "COMPLETED",
          },
          collections: [
            {
              id: "collection-1",
              name: "Favorites",
              nameAr: "المفضلة",
              count: 1,
            },
          ],
          savedCards: [
            {
              id: "saved-1",
              collectionId: "collection-1",
              cardId: "card-1",
              nameEn: "Published Card",
              nameAr: "بطاقة منشورة",
              slug: "published-card",
              savedAt: "2026-08-03T00:00:00Z",
              pinned: false,
            },
          ],
          comparisons: [
            {
              id: "comparison-1",
              name: "Travel options",
              nameAr: "خيارات السفر",
              status: "COMPLETED",
              cardCount: 2,
              startedAt: "2026-08-03T00:00:00Z",
            },
          ],
        }}
        history={[
          {
            id: "run-1",
            name: "Travel recommendation",
            status: "completed",
            startedAt: "2026-08-03T00:00:00Z",
            completedAt: "2026-08-03T00:00:01Z",
            cardsRecommended: 2,
            topCardId: "card-1",
            confidence: 0.9,
            results: [],
          },
        ]}
      />,
    );
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
      "My account",
    );
    expect(screen.getByText("Published Card")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "View" })).toHaveAttribute(
      "href",
      "/en/cards/published-card",
    );
    expect(screen.getByText("Travel options")).toBeInTheDocument();
    expect(screen.getByText("Travel recommendation")).toBeInTheDocument();
    expect(
      screen.getByText(/governed retention lifecycle/i),
    ).toBeInTheDocument();
  });

  it("renders honest Arabic empty states", () => {
    render(
      <AccountPage
        locale="ar"
        dashboard={{
          email: "member@example.test",
          profile: null,
          collections: [],
          savedCards: [],
          comparisons: [],
        }}
        history={[]}
      />,
    );
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
      "حسابي",
    );
    expect(screen.getAllByText("لا توجد عناصر بعد.")).toHaveLength(3);
  });
});
