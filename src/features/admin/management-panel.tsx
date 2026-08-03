"use client";
import { useState } from "react";
import type { Locale } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/browser";
import type { AdminAuthorization } from "./authorization";
import {
  createMerchant,
  createProvenance,
  type AdminWorkspace,
} from "./management";

export function ManagementPanel({
  locale,
  authorization,
  workspace,
}: Readonly<{
  locale: Locale;
  authorization: AdminAuthorization;
  workspace: AdminWorkspace;
}>) {
  const ar = locale === "ar";
  const [status, setStatus] = useState("");
  async function submit(task: () => Promise<void>) {
    try {
      await task();
      setStatus(
        ar
          ? "تم الحفظ وتسجيل حدث التدقيق."
          : "Saved and recorded in the audit trail.",
      );
      window.location.reload();
    } catch {
      setStatus(
        ar
          ? "رُفض التغيير. تحقق من النطاق والمدخلات."
          : "Change rejected. Check scope and input.",
      );
    }
  }
  const field = "border-line mt-1 w-full rounded-xl border p-3";
  return (
    <div className="mt-10 grid gap-8 lg:grid-cols-2">
      <section className="border-line rounded-3xl border bg-white p-6">
        <h2 className="text-2xl font-bold">
          {ar ? "مصادر البيانات" : "Source provenance"}
        </h2>
        <form
          className="mt-5 grid gap-3"
          onSubmit={(event) => {
            event.preventDefault();
            const f = new FormData(event.currentTarget);
            void submit(() =>
              createProvenance(createClient(), {
                target: f.get("target"),
                title: f.get("title"),
                owner: f.get("owner"),
                url: f.get("url"),
              }),
            );
          }}
        >
          <label>
            {ar ? "هدف الكتالوج" : "Catalog target"}
            <select name="target" required className={field}>
              {workspace.targets.map((target) => (
                <option key={target.value} value={target.value}>
                  {ar ? target.nameAr : target.nameEn}
                </option>
              ))}
            </select>
          </label>
          <label>
            {ar ? "عنوان المصدر" : "Source title"}
            <input name="title" required maxLength={500} className={field} />
          </label>
          <label>
            {ar ? "مالك المصدر" : "Source owner"}
            <input name="owner" required maxLength={300} className={field} />
          </label>
          <label>
            {ar ? "رابط المصدر الرسمي" : "Official source URL"}
            <input
              name="url"
              required
              type="url"
              maxLength={2048}
              className={field}
            />
          </label>
          <button
            disabled={!workspace.targets.length}
            className="bg-brand rounded-full p-3 font-bold text-white disabled:opacity-50"
          >
            {ar ? "حفظ المصدر" : "Save source"}
          </button>
        </form>
        <ul className="mt-6 space-y-2">
          {workspace.sources.map((source) => (
            <li className="bg-canvas rounded-xl p-3" key={source.id}>
              <b>{source.title}</b>
              <p className="text-muted text-sm">
                {source.target} · {source.state}
              </p>
            </li>
          ))}
        </ul>
      </section>
      {authorization.global && (
        <section className="border-line rounded-3xl border bg-white p-6">
          <h2 className="text-2xl font-bold">
            {ar ? "التجار المشتركون" : "Shared merchants"}
          </h2>
          <form
            className="mt-5 grid gap-3"
            onSubmit={(event) => {
              event.preventDefault();
              const f = new FormData(event.currentTarget);
              void submit(() =>
                createMerchant(createClient(), {
                  slug: f.get("slug"),
                  nameEn: f.get("nameEn"),
                  nameAr: f.get("nameAr"),
                }),
              );
            }}
          >
            <label>
              {ar ? "المعرّف" : "Stable slug"}
              <input
                name="slug"
                required
                pattern="[a-z0-9]+(?:-[a-z0-9]+)*"
                className={field}
              />
            </label>
            <label>
              English name
              <input
                name="nameEn"
                required
                maxLength={300}
                dir="ltr"
                className={field}
              />
            </label>
            <label>
              الاسم بالعربية
              <input
                name="nameAr"
                required
                maxLength={300}
                dir="rtl"
                className={field}
              />
            </label>
            <button className="bg-brand rounded-full p-3 font-bold text-white">
              {ar ? "إضافة تاجر" : "Add merchant"}
            </button>
          </form>
          <ul className="mt-6 space-y-2">
            {workspace.merchants.map((merchant) => (
              <li className="bg-canvas rounded-xl p-3" key={merchant.id}>
                <b>{ar ? merchant.nameAr : merchant.nameEn}</b>
                <p className="text-muted text-sm">
                  {merchant.slug} · {merchant.state}
                </p>
              </li>
            ))}
          </ul>
        </section>
      )}
      {status && (
        <p role="status" className="lg:col-span-2">
          {status}
        </p>
      )}
    </div>
  );
}
