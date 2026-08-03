"use client";

import { useState, type FormEvent } from "react";
import { createClient } from "@/lib/supabase/browser";
import type { Locale } from "@/lib/i18n";
import { safeNextPath } from "./redirect";

type Mode = "login" | "signup" | "recover" | "update";

const copy = {
  ar: {
    eyebrow: "حسابك",
    title: "احفظ اختياراتك بأمان",
    description:
      "سجّل الدخول للوصول إلى العناصر المحفوظة والسجل الخاص بك. يمكنك متابعة الاستكشاف كضيف.",
    email: "البريد الإلكتروني",
    password: "كلمة المرور",
    newPassword: "كلمة مرور جديدة",
    login: "تسجيل الدخول",
    signup: "إنشاء حساب",
    recover: "استعادة كلمة المرور",
    update: "تحديث كلمة المرور",
    logout: "تسجيل الخروج",
    account: "تم تسجيل الدخول باسم",
    confirmation: "تحقق من بريدك الإلكتروني لإكمال العملية.",
    success: "تمت العملية بنجاح.",
    error: "تعذر إكمال العملية. تحقق من البيانات وحاول مرة أخرى.",
    callbackError: "رابط المصادقة غير صالح أو انتهت صلاحيته. حاول مرة أخرى.",
    guest: "المتابعة كضيف",
  },
  en: {
    eyebrow: "Your account",
    title: "Keep your choices securely",
    description:
      "Sign in to access your saved items and private history. You can keep exploring as a guest.",
    email: "Email address",
    password: "Password",
    newPassword: "New password",
    login: "Sign in",
    signup: "Create account",
    recover: "Reset password",
    update: "Update password",
    logout: "Sign out",
    account: "Signed in as",
    confirmation: "Check your email to complete the process.",
    success: "The operation completed successfully.",
    error:
      "We could not complete the operation. Check the details and try again.",
    callbackError: "The authentication link is invalid or expired. Try again.",
    guest: "Continue as guest",
  },
} as const;

export function AuthPage({
  locale,
  initialMode,
  next,
  userEmail,
  hasCallbackError,
}: Readonly<{
  locale: Locale;
  initialMode: Mode;
  next: string;
  userEmail: string | null;
  hasCallbackError?: boolean;
}>) {
  const text = copy[locale];
  const [mode, setMode] = useState<Mode>(initialMode);
  const [message, setMessage] = useState(
    hasCallbackError ? text.callbackError : "",
  );
  const [busy, setBusy] = useState(false);
  const destination = safeNextPath(next, locale);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setBusy(true);
    setMessage("");
    const form = new FormData(event.currentTarget);
    const email = String(form.get("email") ?? "").trim();
    const password = String(form.get("password") ?? "");
    const client = createClient();
    let error: { message: string } | null = null;
    if (mode === "login") {
      ({ error } = await client.auth.signInWithPassword({ email, password }));
      if (!error) window.location.assign(destination);
    } else if (mode === "signup") {
      ({ error } = await client.auth.signUp({
        email,
        password,
        options: {
          emailRedirectTo: `${window.location.origin}/${locale}/auth/callback?next=${encodeURIComponent(destination)}`,
        },
      }));
      if (!error) setMessage(text.confirmation);
    } else if (mode === "recover") {
      ({ error } = await client.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/${locale}/auth/callback?next=${encodeURIComponent(`/${locale}/auth?mode=update`)}`,
      }));
      if (!error) setMessage(text.confirmation);
    } else {
      ({ error } = await client.auth.updateUser({ password }));
      if (!error) setMessage(text.success);
    }
    if (error) setMessage(text.error);
    setBusy(false);
  }

  async function signOut() {
    setBusy(true);
    const { error } = await createClient().auth.signOut();
    if (error) {
      setMessage(text.error);
      setBusy(false);
      return;
    }
    window.location.assign(`/${locale}`);
  }

  const needsEmail = mode !== "update";
  const needsPassword = mode !== "recover";
  const submitLabel = text[mode];

  return (
    <main id="main-content" className="mx-auto max-w-3xl px-5 py-12 sm:px-8">
      <section className="border-line rounded-3xl border bg-white p-6 shadow-sm sm:p-10">
        <p className="text-brand text-sm font-bold tracking-wide uppercase">
          {text.eyebrow}
        </p>
        <h1 className="mt-3 text-3xl font-black sm:text-4xl">{text.title}</h1>
        <p className="text-muted mt-4 leading-7">{text.description}</p>

        {userEmail && mode !== "update" ? (
          <div className="mt-8">
            <p className="font-semibold">
              {text.account} <span dir="ltr">{userEmail}</span>
            </p>
            <button
              type="button"
              disabled={busy}
              onClick={signOut}
              className="bg-brand focus-visible:outline-accent mt-5 min-h-11 rounded-full px-6 py-3 font-bold text-white focus-visible:outline-2 focus-visible:outline-offset-4 disabled:opacity-60"
            >
              {text.logout}
            </button>
          </div>
        ) : (
          <form onSubmit={submit} className="mt-8 space-y-5">
            {needsEmail && (
              <label className="block font-bold">
                {text.email}
                <input
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  className="border-line focus:border-brand mt-2 min-h-12 w-full rounded-xl border px-4 font-normal outline-none"
                />
              </label>
            )}
            {needsPassword && (
              <label className="block font-bold">
                {mode === "update" ? text.newPassword : text.password}
                <input
                  name="password"
                  type="password"
                  minLength={8}
                  autoComplete={
                    mode === "login" ? "current-password" : "new-password"
                  }
                  required
                  className="border-line focus:border-brand mt-2 min-h-12 w-full rounded-xl border px-4 font-normal outline-none"
                />
              </label>
            )}
            <button
              type="submit"
              disabled={busy}
              className="bg-brand focus-visible:outline-accent min-h-11 rounded-full px-6 py-3 font-bold text-white focus-visible:outline-2 focus-visible:outline-offset-4 disabled:opacity-60"
            >
              {submitLabel}
            </button>
            {message && (
              <p role="status" aria-live="polite" className="text-muted">
                {message}
              </p>
            )}
          </form>
        )}

        {!userEmail && mode !== "update" && (
          <nav aria-label={text.eyebrow} className="mt-8 flex flex-wrap gap-3">
            {(["login", "signup", "recover"] as const).map((item) => (
              <button
                key={item}
                type="button"
                onClick={() => {
                  setMode(item);
                  setMessage("");
                }}
                aria-pressed={mode === item}
                className="catalog-filter"
              >
                {text[item]}
              </button>
            ))}
          </nav>
        )}
        <a
          href={`/${locale}`}
          className="text-brand mt-8 inline-flex min-h-11 items-center font-bold underline underline-offset-4"
        >
          {text.guest}
        </a>
      </section>
    </main>
  );
}
