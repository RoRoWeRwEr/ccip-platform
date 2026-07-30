"use client";

import { usePathname } from "next/navigation";

export default function CatalogError({
  reset,
}: Readonly<{ error: Error & { digest?: string }; reset: () => void }>) {
  const isArabic = usePathname().startsWith("/ar/");
  return (
    <main className="mx-auto grid min-h-[70vh] max-w-3xl place-items-center px-5 py-16 text-center">
      <div>
        <div
          aria-hidden="true"
          className="bg-accent-soft text-accent-deep mx-auto grid size-14 place-items-center rounded-2xl text-2xl"
        >
          !
        </div>
        <h1 className="mt-5 text-3xl font-bold">
          {isArabic ? "تعذر تحميل الكتالوج" : "The catalog could not be loaded"}
        </h1>
        <p className="text-muted mt-3 leading-7">
          {isArabic
            ? "لم نتمكن من الوصول إلى البيانات الآن. حاول مرة أخرى بعد قليل."
            : "We could not reach the catalog data right now. Please try again shortly."}
        </p>
        <button
          type="button"
          onClick={reset}
          className="bg-brand focus-visible:outline-accent mt-6 min-h-11 rounded-full px-6 py-3 font-bold text-white focus-visible:outline-2 focus-visible:outline-offset-4"
        >
          {isArabic ? "إعادة المحاولة" : "Try again"}
        </button>
      </div>
    </main>
  );
}
