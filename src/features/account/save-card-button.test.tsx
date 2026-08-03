import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import type { CardDetail } from "@/features/catalog/data/repository";
import { SaveCardButton } from "./save-card-button";

const savePublishedCard = vi.hoisted(() => vi.fn());
vi.mock("./data", () => ({ savePublishedCard }));
vi.mock("@/lib/supabase/browser", () => ({ createClient: () => ({}) }));

const card = {
  id: "card-1",
  slug: "published-card",
  nameAr: "بطاقة منشورة",
  nameEn: "Published Card",
  bank: { nameAr: "بنك", nameEn: "Bank" },
  publication: { versionNumber: 1 },
} as CardDetail;

describe("save card button", () => {
  it("saves the publication-safe card through the authenticated data boundary", async () => {
    savePublishedCard.mockResolvedValue(undefined);
    render(<SaveCardButton locale="en" card={card} />);
    fireEvent.click(screen.getByRole("button", { name: "Save card" }));
    await waitFor(() => expect(savePublishedCard).toHaveBeenCalledOnce());
    expect(screen.getByRole("button", { name: "Saved" })).toBeDisabled();
  });
});
