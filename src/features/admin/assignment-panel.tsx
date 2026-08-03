"use client";
import { useState } from "react";
import type { Locale } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/browser";
import type { AdminWorkspace } from "./management";
import {
  createCatalogAssignment,
  revokeCatalogAssignment,
  type AssignmentWorkspace,
} from "./assignments";

export function AssignmentPanel({
  locale,
  banks,
  assignments,
}: Readonly<{
  locale: Locale;
  banks: AdminWorkspace["targets"];
  assignments: AssignmentWorkspace;
}>) {
  const ar = locale === "ar";
  const [status, setStatus] = useState("");
  const field = "border-line mt-1 w-full rounded-xl border p-3";
  const bankOptions = banks.filter((bank) => bank.value.startsWith("BANK:"));
  async function run(task: () => Promise<void>) {
    try {
      await task();
      setStatus(
        ar ? "تم تحديث التعيين وتسجيله." : "Assignment updated and audited.",
      );
      window.location.reload();
    } catch {
      setStatus(
        ar
          ? "رُفض التغيير. يلزم مسؤول منصة ونطاق صالح."
          : "Change rejected. Platform administrator and valid scope required.",
      );
    }
  }
  return (
    <section
      className="border-line mt-10 rounded-3xl border bg-white p-6"
      aria-labelledby="assignments-heading"
    >
      <h2 id="assignments-heading" className="text-2xl font-bold">
        {ar ? "تعيينات مسؤولي الكتالوج" : "Catalog administrator assignments"}
      </h2>
      <p className="text-muted mt-2">
        {ar
          ? "هذه الواجهة متاحة لمسؤولي المنصة فقط وتحافظ على سجل التعيين والإلغاء."
          : "Platform-administrator only. Assignment and revocation history is retained."}
      </p>
      <form
        className="bg-canvas mt-6 grid gap-3 rounded-2xl p-4 md:grid-cols-2"
        onSubmit={(e) => {
          e.preventDefault();
          const f = new FormData(e.currentTarget);
          void run(() =>
            createCatalogAssignment(createClient(), {
              userId: f.get("user"),
              scope: f.get("scope"),
              bankId: f.get("bank"),
              reason: f.get("reason"),
              validUntil: f.get("until"),
            }),
          );
        }}
      >
        <label>
          {ar ? "معرّف المستخدم UUID" : "User UUID"}
          <input name="user" required className={field} />
        </label>
        <label>
          {ar ? "النطاق" : "Scope"}
          <select name="scope" className={field}>
            <option value="BANK">BANK</option>
            <option value="GLOBAL">GLOBAL</option>
          </select>
        </label>
        <label>
          {ar ? "البنك (لنطاق BANK)" : "Bank (BANK scope)"}
          <select name="bank" className={field}>
            <option value="">—</option>
            {bankOptions.map((bank) => (
              <option key={bank.value} value={bank.value.slice(5)}>
                {ar ? bank.nameAr : bank.nameEn}
              </option>
            ))}
          </select>
        </label>
        <label>
          {ar ? "صالح حتى (اختياري)" : "Valid until (optional)"}
          <input name="until" type="datetime-local" className={field} />
        </label>
        <label className="md:col-span-2">
          {ar ? "سبب التعيين" : "Assignment reason"}
          <textarea name="reason" required maxLength={1000} className={field} />
        </label>
        <button className="bg-brand rounded-full p-3 font-bold text-white md:col-span-2">
          {ar ? "إنشاء التعيين" : "Create assignment"}
        </button>
      </form>
      <ul className="mt-6 space-y-3">
        {assignments.map((assignment) => (
          <li key={assignment.id} className="bg-canvas rounded-2xl p-4">
            <p className="font-bold">
              {assignment.scope}
              {assignment.bankId ? ` · ${assignment.bankId}` : ""}
            </p>
            <p className="text-muted text-sm break-all">{assignment.userId}</p>
            <p className="text-muted text-sm">
              {assignment.reason} ·{" "}
              {assignment.revokedAt
                ? ar
                  ? "ملغى"
                  : "Revoked"
                : ar
                  ? "فعّال"
                  : "Active"}
            </p>
            {!assignment.revokedAt && (
              <form
                className="mt-3 flex flex-col gap-2 sm:flex-row"
                onSubmit={(e) => {
                  e.preventDefault();
                  const f = new FormData(e.currentTarget);
                  void run(() =>
                    revokeCatalogAssignment(createClient(), {
                      scopeId: assignment.id,
                      roleAssignmentId: assignment.roleAssignmentId,
                      reason: f.get("reason"),
                    }),
                  );
                }}
              >
                <input
                  name="reason"
                  required
                  maxLength={1000}
                  placeholder={ar ? "سبب الإلغاء" : "Revocation reason"}
                  className={field}
                />
                <button className="rounded-full bg-red-700 px-5 py-3 font-bold text-white">
                  {ar ? "إلغاء" : "Revoke"}
                </button>
              </form>
            )}
          </li>
        ))}
      </ul>
      {status && (
        <p role="status" className="mt-5">
          {status}
        </p>
      )}
    </section>
  );
}
