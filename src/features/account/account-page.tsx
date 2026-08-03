"use client";

import { useState, type FormEvent } from "react";
import Link from "next/link";
import type { Locale } from "@/lib/i18n";
import type { RecommendationHistoryItem } from "@/features/recommendation/persistence";
import { createClient } from "@/lib/supabase/browser";
import {
  createCollection,
  removeSavedCard,
  updateUserProfile,
  type UserDashboard,
} from "./data";

const copy = {
  ar: {
    title: "حسابي",
    profile: "الملف الشخصي",
    name: "الاسم المعروض",
    language: "اللغة المفضلة",
    save: "حفظ الملف",
    collections: "المجموعات",
    newCollection: "اسم مجموعة جديدة",
    create: "إنشاء مجموعة",
    saved: "البطاقات المحفوظة",
    comparisons: "المقارنات المحفوظة",
    history: "سجل التوصيات",
    historyCards: "بطاقات موصى بها",
    privacy:
      "سجل التوصيات للقراءة فقط ويخضع لدورة الاحتفاظ المحكومة في المنصة. إزالة بطاقة محفوظة تخفيها من العناصر النشطة ولا تحذف سجلات المحرك أو التدقيق. طلبات الحذف غير متاحة بعد في هذه الواجهة.",
    remove: "إزالة",
    empty: "لا توجد عناصر بعد.",
    success: "تم الحفظ.",
    error: "تعذر إكمال العملية. حاول مرة أخرى.",
  },
  en: {
    title: "My account",
    profile: "Profile",
    name: "Display name",
    language: "Preferred language",
    save: "Save profile",
    collections: "Collections",
    newCollection: "New collection name",
    create: "Create collection",
    saved: "Saved cards",
    comparisons: "Saved comparisons",
    history: "Recommendation history",
    historyCards: "recommended cards",
    privacy:
      "Recommendation history is read-only and follows the platform's governed retention lifecycle. Removing a saved card hides it from active saved items; it does not delete engine or audit history. Deletion requests are not yet available in this interface.",
    remove: "Remove",
    empty: "No items yet.",
    success: "Saved successfully.",
    error: "We could not complete the operation. Try again.",
  },
} as const;

export function AccountPage({
  locale,
  dashboard,
  history,
}: Readonly<{
  locale: Locale;
  dashboard: UserDashboard;
  history: RecommendationHistoryItem[];
}>) {
  const text = copy[locale];
  const [message, setMessage] = useState("");
  const [busy, setBusy] = useState(false);

  async function run(operation: () => Promise<void>) {
    setBusy(true);
    setMessage("");
    try {
      await operation();
      setMessage(text.success);
      window.location.reload();
    } catch {
      setMessage(text.error);
      setBusy(false);
    }
  }

  function profileSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    void run(() =>
      updateUserProfile(createClient(), {
        displayName: String(form.get("displayName") ?? ""),
        language: form.get("language") === "ar" ? "ar" : "en",
      }),
    );
  }

  function collectionSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    void run(() =>
      createCollection(createClient(), String(form.get("name") ?? "")),
    );
  }

  return (
    <main
      id="main-content"
      className="mx-auto max-w-5xl px-5 py-10 sm:px-8 lg:px-12"
    >
      <h1 className="text-4xl font-black">{text.title}</h1>
      <p className="text-muted mt-2" dir="ltr">
        {dashboard.email}
      </p>
      {message ? (
        <p role="status" aria-live="polite" className="mt-4 font-semibold">
          {message}
        </p>
      ) : null}

      <section className="border-line mt-8 rounded-3xl border bg-white p-6">
        <h2 className="text-2xl font-bold">{text.profile}</h2>
        <form
          onSubmit={profileSubmit}
          className="mt-5 grid gap-5 sm:grid-cols-2"
        >
          <label className="font-bold">
            {text.name}
            <input
              name="displayName"
              defaultValue={dashboard.profile?.displayName ?? ""}
              maxLength={200}
              className="border-line focus:border-brand mt-2 min-h-12 w-full rounded-xl border px-4 font-normal outline-none"
            />
          </label>
          <label className="font-bold">
            {text.language}
            <select
              name="language"
              defaultValue={dashboard.profile?.language ?? locale}
              className="border-line focus:border-brand mt-2 min-h-12 w-full rounded-xl border bg-white px-4 font-normal outline-none"
            >
              <option value="ar">العربية</option>
              <option value="en">English</option>
            </select>
          </label>
          <button
            disabled={busy}
            className="bg-brand min-h-11 rounded-full px-6 py-3 font-bold text-white disabled:opacity-60"
          >
            {text.save}
          </button>
        </form>
      </section>

      <section className="border-line mt-8 rounded-3xl border bg-white p-6">
        <h2 className="text-2xl font-bold">{text.collections}</h2>
        <form
          onSubmit={collectionSubmit}
          className="mt-5 flex flex-col gap-3 sm:flex-row"
        >
          <label className="sr-only" htmlFor="collection-name">
            {text.newCollection}
          </label>
          <input
            id="collection-name"
            name="name"
            required
            maxLength={200}
            placeholder={text.newCollection}
            className="border-line focus:border-brand min-h-12 flex-1 rounded-xl border px-4 outline-none"
          />
          <button
            disabled={busy}
            className="bg-brand min-h-11 rounded-full px-6 py-3 font-bold text-white disabled:opacity-60"
          >
            {text.create}
          </button>
        </form>
        <ul className="mt-5 grid gap-3 sm:grid-cols-2">
          {dashboard.collections.map((collection) => (
            <li
              key={collection.id}
              className="bg-canvas rounded-2xl p-4 font-semibold"
            >
              {locale === "ar"
                ? (collection.nameAr ?? collection.name)
                : collection.name}{" "}
              · {collection.count}
            </li>
          ))}
        </ul>
      </section>

      <section className="mt-8">
        <h2 className="text-2xl font-bold">{text.saved}</h2>
        {dashboard.savedCards.length ? (
          <ul className="mt-4 grid gap-4 sm:grid-cols-2">
            {dashboard.savedCards.map((card) => (
              <li
                key={card.id}
                className="border-line rounded-2xl border bg-white p-5"
              >
                <h3 className="font-bold">
                  {locale === "ar"
                    ? (card.nameAr ?? card.nameEn ?? card.cardId)
                    : (card.nameEn ?? card.nameAr ?? card.cardId)}
                </h3>
                <div className="mt-4 flex gap-4">
                  {card.slug ? (
                    <Link
                      className="text-brand font-bold underline"
                      href={`/${locale}/cards/${card.slug}`}
                    >
                      {locale === "ar" ? "عرض" : "View"}
                    </Link>
                  ) : null}
                  <button
                    type="button"
                    disabled={busy}
                    onClick={() =>
                      void run(() => removeSavedCard(createClient(), card.id))
                    }
                    className="text-accent-deep font-bold underline disabled:opacity-60"
                  >
                    {text.remove}
                  </button>
                </div>
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-muted mt-4">{text.empty}</p>
        )}
      </section>

      <section className="mt-8">
        <h2 className="text-2xl font-bold">{text.comparisons}</h2>
        {dashboard.comparisons.length ? (
          <ul className="mt-4 grid gap-4 sm:grid-cols-2">
            {dashboard.comparisons.map((comparison) => (
              <li
                key={comparison.id}
                className="border-line rounded-2xl border bg-white p-5"
              >
                <h3 className="font-bold">
                  {locale === "ar"
                    ? (comparison.nameAr ?? comparison.name ?? comparison.id)
                    : (comparison.name ?? comparison.nameAr ?? comparison.id)}
                </h3>
                <p className="text-muted mt-2">
                  {comparison.status} · {comparison.cardCount}
                </p>
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-muted mt-4">{text.empty}</p>
        )}
      </section>

      <section className="mt-8">
        <h2 className="text-2xl font-bold">{text.history}</h2>
        <p className="text-muted mt-3 max-w-3xl leading-7">{text.privacy}</p>
        {history.length ? (
          <ol className="mt-4 grid gap-4 sm:grid-cols-2">
            {history.map((run) => (
              <li
                key={run.id}
                className="border-line rounded-2xl border bg-white p-5"
              >
                <h3 className="font-bold">{run.name ?? run.status}</h3>
                <p className="text-muted mt-2">
                  {new Intl.DateTimeFormat(
                    locale === "ar" ? "ar-SA" : "en-SA",
                    { dateStyle: "medium", timeStyle: "short" },
                  ).format(new Date(run.startedAt))}
                </p>
                <p className="text-muted mt-2">
                  {run.cardsRecommended} {text.historyCards}
                </p>
              </li>
            ))}
          </ol>
        ) : (
          <p className="text-muted mt-4">{text.empty}</p>
        )}
      </section>
    </main>
  );
}
