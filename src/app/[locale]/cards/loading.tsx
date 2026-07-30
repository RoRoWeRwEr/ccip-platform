export default function CatalogLoading() {
  return (
    <main
      className="mx-auto min-h-[70vh] max-w-7xl px-5 py-12 sm:px-8 lg:px-12"
      role="status"
      aria-label="Loading catalog / تحميل الكتالوج"
    >
      <div className="bg-line h-12 max-w-xl animate-pulse rounded-2xl" />
      <div className="bg-line mt-4 h-6 max-w-2xl animate-pulse rounded-xl" />
      <div className="mt-12 grid gap-5 md:grid-cols-2 xl:grid-cols-3">
        {[1, 2, 3, 4, 5, 6].map((item) => (
          <div
            key={item}
            className="border-line h-64 animate-pulse rounded-3xl border bg-white"
          />
        ))}
      </div>
      <span className="sr-only">Loading catalog / جارٍ تحميل الكتالوج</span>
    </main>
  );
}
