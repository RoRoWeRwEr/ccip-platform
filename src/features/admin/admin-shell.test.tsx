import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { AdminShell } from "./admin-shell";

describe("admin authorization shell", () => {
  it("shows global platform access without privileged details", () => {
    render(
      <AdminShell
        locale="en"
        authorization={{
          email: "admin@example.test",
          isPlatformAdministrator: true,
          global: true,
          banks: [],
        }}
      />,
    );
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
      "Administration access",
    );
    expect(screen.getByText("GLOBAL")).toBeInTheDocument();
    expect(
      screen.getByText(/does not use privileged credentials/i),
    ).toBeInTheDocument();
  });

  it("shows only effective bank scopes in Arabic", () => {
    render(
      <AdminShell
        locale="ar"
        authorization={{
          email: "catalog@example.test",
          isPlatformAdministrator: false,
          global: false,
          banks: [
            { id: "bank-1", nameAr: "بنك الاختبار", nameEn: "Test Bank" },
          ],
        }}
      />,
    );
    expect(screen.getByText("بنك الاختبار")).toBeInTheDocument();
    expect(screen.getByText("Test Bank")).toBeInTheDocument();
    expect(screen.queryByText("عالمي")).not.toBeInTheDocument();
  });
});
