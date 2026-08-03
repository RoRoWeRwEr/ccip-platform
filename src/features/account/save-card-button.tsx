"use client";

import { useState } from "react";
import type { CardDetail } from "@/features/catalog/data/repository";
import type { Locale } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/browser";
import { savePublishedCard } from "./data";

export function SaveCardButton({
  locale,
  card,
}: Readonly<{ locale: Locale; card: CardDetail }>) {
  const [state, setState] = useState<"idle" | "busy" | "saved" | "error">(
    "idle",
  );
  const label = locale === "ar" ? "حفظ البطاقة" : "Save card";
  async function save() {
    setState("busy");
    try {
      await savePublishedCard(createClient(), card);
      setState("saved");
    } catch (error) {
      if (
        error instanceof Error &&
        "code" in error &&
        error.code === "UNAUTHENTICATED"
      ) {
        window.location.assign(
          `/${locale}/auth?next=${encodeURIComponent(`/${locale}/cards/${card.slug}`)}`,
        );
        return;
      }
      setState("error");
    }
  }
  return (
    <div className="mt-5">
      <button
        type="button"
        onClick={save}
        disabled={state === "busy" || state === "saved"}
        className="border-line focus-visible:outline-brand min-h-11 rounded-full border px-5 py-2 font-bold focus-visible:outline-2 focus-visible:outline-offset-4 disabled:opacity-60"
      >
        {state === "saved" ? (locale === "ar" ? "تم الحفظ" : "Saved") : label}
      </button>
      {state === "error" ? (
        <p role="status" className="text-accent-deep mt-2 text-sm">
          {locale === "ar"
            ? "تعذر حفظ البطاقة. حاول مرة أخرى."
            : "Could not save the card. Try again."}
        </p>
      ) : null}
    </div>
  );
}
