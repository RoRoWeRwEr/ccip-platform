import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { AuthPage } from "./auth-page";

const auth = vi.hoisted(() => ({
  signUp: vi.fn(),
  resetPasswordForEmail: vi.fn(),
  signInWithPassword: vi.fn(),
  updateUser: vi.fn(),
  signOut: vi.fn(),
}));

vi.mock("@/lib/supabase/browser", () => ({
  createClient: () => ({ auth }),
}));

describe("authentication page", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    auth.signUp.mockResolvedValue({ error: null });
    auth.resetPasswordForEmail.mockResolvedValue({ error: null });
  });

  it("renders an authenticated session without exposing a password form", () => {
    render(
      <AuthPage
        locale="en"
        initialMode="login"
        next="/en"
        userEmail="member@example.test"
      />,
    );
    expect(screen.getByText(/member@example\.test/)).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: "Sign out" }),
    ).toBeInTheDocument();
    expect(screen.queryByLabelText("Password")).not.toBeInTheDocument();
  });

  it("creates an account with a local safe callback and confirmation state", async () => {
    render(
      <AuthPage
        locale="en"
        initialMode="signup"
        next="/en/recommendation"
        userEmail={null}
      />,
    );
    fireEvent.change(screen.getByLabelText("Email address"), {
      target: { value: "new@example.test" },
    });
    fireEvent.change(screen.getByLabelText("Password"), {
      target: { value: "correct-horse" },
    });
    fireEvent.submit(screen.getByLabelText("Email address").closest("form")!);

    await waitFor(() => expect(auth.signUp).toHaveBeenCalledOnce());
    expect(auth.signUp).toHaveBeenCalledWith({
      email: "new@example.test",
      password: "correct-horse",
      options: {
        emailRedirectTo: expect.stringMatching(
          /\/en\/auth\/callback\?next=%2Fen%2Frecommendation$/,
        ),
      },
    });
    expect(screen.getByRole("status")).toHaveTextContent("Check your email");
  });

  it("offers a bilingual recovery flow without requesting a password", async () => {
    render(
      <AuthPage
        locale="ar"
        initialMode="recover"
        next="//evil.example"
        userEmail={null}
      />,
    );
    expect(screen.queryByLabelText("كلمة المرور")).not.toBeInTheDocument();
    fireEvent.change(screen.getByLabelText("البريد الإلكتروني"), {
      target: { value: "owner@example.test" },
    });
    fireEvent.submit(
      screen.getByLabelText("البريد الإلكتروني").closest("form")!,
    );
    await waitFor(() =>
      expect(auth.resetPasswordForEmail).toHaveBeenCalledOnce(),
    );
    expect(auth.resetPasswordForEmail).toHaveBeenCalledWith(
      "owner@example.test",
      expect.objectContaining({
        redirectTo: expect.stringContaining("%2Far%2Fauth%3Fmode%3Dupdate"),
      }),
    );
  });
});
