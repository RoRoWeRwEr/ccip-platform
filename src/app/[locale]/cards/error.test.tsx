import { fireEvent, render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import CatalogError from "./error";

let pathname = "/en/cards";

vi.mock("next/navigation", () => ({
  usePathname: () => pathname,
}));

describe("catalog degraded dependency state", () => {
  beforeEach(() => {
    pathname = "/en/cards";
  });

  it("shows a safe retry path without dependency details", () => {
    const reset = vi.fn();
    render(
      <CatalogError
        error={new Error("database secret detail")}
        reset={reset}
      />,
    );

    expect(
      screen.getByRole("heading", { name: "The catalog could not be loaded" }),
    ).toBeInTheDocument();
    expect(
      screen.queryByText(/database secret detail/i),
    ).not.toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: "Try again" }));
    expect(reset).toHaveBeenCalledOnce();
  });

  it("localizes the degraded state in Arabic", () => {
    pathname = "/ar/cards";
    render(
      <CatalogError error={new Error("failure")} reset={() => undefined} />,
    );
    expect(
      screen.getByRole("heading", { name: "تعذر تحميل الكتالوج" }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: "إعادة المحاولة" }),
    ).toBeVisible();
  });
});
