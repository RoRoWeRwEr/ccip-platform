import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import CatalogError from "@/app/[locale]/cards/error";
import CatalogLoading from "@/app/[locale]/cards/loading";

vi.mock("next/navigation", () => ({ usePathname: () => "/en/cards" }));

describe("catalog route states", () => {
  it("announces loading without exposing fake card content", () => {
    render(<CatalogLoading />);
    expect(
      screen.getByRole("status", { name: "Loading catalog / تحميل الكتالوج" }),
    ).toBeInTheDocument();
  });

  it("renders a safe retry action for dependency failures", () => {
    const reset = vi.fn();
    render(
      <CatalogError
        error={new Error("private dependency detail")}
        reset={reset}
      />,
    );
    expect(
      screen.getByRole("heading", { name: "The catalog could not be loaded" }),
    ).toBeInTheDocument();
    expect(
      screen.queryByText("private dependency detail"),
    ).not.toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: "Try again" }));
    expect(reset).toHaveBeenCalledOnce();
  });
});
