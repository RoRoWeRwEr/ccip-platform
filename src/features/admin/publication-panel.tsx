"use client";
import { useState } from "react";
import type { Locale } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/browser";
import type { AdminWorkspace } from "./management";
import {
  createDraft,
  decidePublication,
  publishVersion,
  rollbackVersion,
  submitPublication,
  unpublishVersion,
  type PublicationWorkspace,
} from "./publication";

export function PublicationPanel({
  locale,
  targets,
  workspace,
}: Readonly<{
  locale: Locale;
  targets: AdminWorkspace["targets"];
  workspace: PublicationWorkspace;
}>) {
  const ar = locale === "ar";
  const [message, setMessage] = useState("");
  const input = "border-line mt-1 w-full rounded-xl border p-3";
  async function run(task: () => Promise<void>) {
    try {
      await task();
      setMessage(
        ar ? "تم تنفيذ الإجراء وتسجيله." : "Action completed and recorded.",
      );
      window.location.reload();
    } catch {
      setMessage(
        ar
          ? "رُفض الإجراء. تحقق من الدور والنطاق والحالة."
          : "Action rejected. Check role, scope, and state.",
      );
    }
  }
  return (
    <section
      className="border-line mt-10 rounded-3xl border bg-white p-6"
      aria-labelledby="publication-heading"
    >
      <h2 id="publication-heading" className="text-2xl font-bold">
        {ar ? "سير عمل النشر" : "Publication workflow"}
      </h2>
      <p className="text-muted mt-2">
        {ar
          ? "كل انتقال يستخدم وظائف المراجعة والنشر المحكومة في قاعدة البيانات."
          : "Every transition uses the database-controlled review and publication functions."}
      </p>
      <div className="mt-6 grid gap-6 lg:grid-cols-2">
        <form
          className="bg-canvas grid gap-3 rounded-2xl p-4"
          onSubmit={(e) => {
            e.preventDefault();
            const f = new FormData(e.currentTarget);
            void run(() =>
              createDraft(createClient(), {
                target: f.get("target"),
                summary: f.get("summary"),
                snapshot: f.get("snapshot"),
              }),
            );
          }}
        >
          <h3 className="font-bold">{ar ? "مسودة جديدة" : "New draft"}</h3>
          <select name="target" required className={input}>
            {targets.map((t) => (
              <option key={t.value} value={t.value}>
                {ar ? t.nameAr : t.nameEn}
              </option>
            ))}
          </select>
          <input
            name="summary"
            required
            maxLength={2000}
            placeholder={ar ? "ملخص التغيير" : "Change summary"}
            className={input}
          />
          <textarea
            name="snapshot"
            required
            defaultValue="{}"
            maxLength={100000}
            rows={5}
            dir="ltr"
            aria-label={ar ? "لقطة JSON" : "JSON snapshot"}
            className={input}
          />
          <button
            disabled={!targets.length}
            className="bg-brand rounded-full p-3 font-bold text-white disabled:opacity-50"
          >
            {ar ? "إنشاء المسودة" : "Create draft"}
          </button>
        </form>
        <form
          className="bg-canvas grid gap-3 rounded-2xl p-4"
          onSubmit={(e) => {
            e.preventDefault();
            const f = new FormData(e.currentTarget);
            void run(() =>
              submitPublication(createClient(), {
                versionId: f.get("version"),
                reviewerId: f.get("reviewer"),
                approverId: f.get("approver"),
                publishAt: f.get("publishAt"),
                unpublishAt: f.get("unpublishAt"),
              }),
            );
          }}
        >
          <h3 className="font-bold">
            {ar ? "إرسال وجدولة" : "Submit and schedule"}
          </h3>
          <select name="version" required className={input}>
            {workspace.versions
              .filter((v) => v.status === "DRAFT")
              .map((v) => (
                <option key={v.id} value={v.id}>
                  v{v.version} · {v.summary}
                </option>
              ))}
          </select>
          <input
            name="reviewer"
            required
            type="text"
            placeholder={ar ? "معرّف المراجع UUID" : "Reviewer UUID"}
            className={input}
          />
          <input
            name="approver"
            required
            type="text"
            placeholder={
              ar ? "معرّف المعتمد النهائي UUID" : "Final approver UUID"
            }
            className={input}
          />
          <label>
            {ar ? "موعد النشر" : "Publish at"}
            <input name="publishAt" type="datetime-local" className={input} />
          </label>
          <label>
            {ar ? "موعد الإلغاء" : "Unpublish at"}
            <input name="unpublishAt" type="datetime-local" className={input} />
          </label>
          <button className="bg-brand rounded-full p-3 font-bold text-white">
            {ar ? "إرسال" : "Submit"}
          </button>
        </form>
        <form
          className="bg-canvas grid gap-3 rounded-2xl p-4"
          onSubmit={(e) => {
            e.preventDefault();
            const f = new FormData(e.currentTarget);
            void run(() =>
              decidePublication(createClient(), {
                requestId: f.get("request"),
                decision: f.get("decision"),
                comments: f.get("comments"),
              }),
            );
          }}
        >
          <h3 className="font-bold">
            {ar ? "قرار المراجعة" : "Review decision"}
          </h3>
          <select name="request" required className={input}>
            {workspace.requests
              .filter((r) => r.status === "IN_REVIEW")
              .map((r) => (
                <option key={r.id} value={r.id}>
                  {r.id}
                </option>
              ))}
          </select>
          <select name="decision" className={input}>
            <option value="APPROVE">{ar ? "موافقة" : "Approve"}</option>
            <option value="REJECT">{ar ? "رفض" : "Reject"}</option>
          </select>
          <textarea
            name="comments"
            required
            maxLength={2000}
            placeholder={ar ? "التعليق" : "Decision comments"}
            className={input}
          />
          <button className="bg-brand rounded-full p-3 font-bold text-white">
            {ar ? "تسجيل القرار" : "Record decision"}
          </button>
        </form>
        <form
          className="bg-canvas grid gap-3 rounded-2xl p-4"
          onSubmit={(e) => {
            e.preventDefault();
            const f = new FormData(e.currentTarget);
            const action = String(f.get("action"));
            const version = String(f.get("version"));
            const reason = String(f.get("reason"));
            void run(() =>
              action === "publish"
                ? publishVersion(createClient(), version)
                : unpublishVersion(createClient(), {
                    versionId: version,
                    archive: action === "archive",
                    reason,
                  }),
            );
          }}
        >
          <h3 className="font-bold">
            {ar ? "النشر والإلغاء" : "Publish and unpublish"}
          </h3>
          <select name="version" required className={input}>
            {workspace.versions.map((v) => (
              <option key={v.id} value={v.id}>
                v{v.version} · {v.status} · {v.summary}
              </option>
            ))}
          </select>
          <select name="action" className={input}>
            <option value="publish">{ar ? "نشر" : "Publish"}</option>
            <option value="suspend">{ar ? "تعليق" : "Suspend"}</option>
            <option value="archive">{ar ? "أرشفة" : "Archive"}</option>
          </select>
          <input
            name="reason"
            required
            maxLength={2000}
            placeholder={ar ? "السبب" : "Reason"}
            className={input}
          />
          <button className="bg-brand rounded-full p-3 font-bold text-white">
            {ar ? "تنفيذ" : "Execute"}
          </button>
        </form>
        <form
          className="bg-canvas grid gap-3 rounded-2xl p-4 lg:col-span-2"
          onSubmit={(e) => {
            e.preventDefault();
            const f = new FormData(e.currentTarget);
            void run(() =>
              rollbackVersion(createClient(), {
                currentId: f.get("current"),
                replacementId: f.get("replacement"),
                reason: f.get("reason"),
              }),
            );
          }}
        >
          <h3 className="font-bold">{ar ? "الرجوع إلى إصدار" : "Rollback"}</h3>
          <div className="grid gap-3 md:grid-cols-2">
            <select
              name="current"
              required
              aria-label={ar ? "الإصدار المنشور" : "Published version"}
              className={input}
            >
              {workspace.versions
                .filter((v) => v.status === "PUBLISHED")
                .map((v) => (
                  <option key={v.id} value={v.id}>
                    v{v.version} · {v.summary}
                  </option>
                ))}
            </select>
            <select
              name="replacement"
              required
              aria-label={ar ? "الإصدار البديل" : "Replacement version"}
              className={input}
            >
              {workspace.versions
                .filter((v) =>
                  ["APPROVED", "SCHEDULED", "SUSPENDED"].includes(v.status),
                )
                .map((v) => (
                  <option key={v.id} value={v.id}>
                    v{v.version} · {v.status}
                  </option>
                ))}
            </select>
          </div>
          <input
            name="reason"
            required
            maxLength={2000}
            placeholder={ar ? "سبب الرجوع" : "Rollback reason"}
            className={input}
          />
          <button className="bg-brand rounded-full p-3 font-bold text-white">
            {ar ? "تنفيذ الرجوع" : "Rollback"}
          </button>
        </form>
      </div>
      {message && (
        <p role="status" className="mt-5">
          {message}
        </p>
      )}
      <h3 className="mt-8 text-xl font-bold">{ar ? "السجل" : "History"}</h3>
      <ol className="mt-3 space-y-2">
        {workspace.events.map((event) => (
          <li key={event.id} className="bg-canvas rounded-xl p-3">
            <b>{event.type}</b>
            <span className="text-muted">
              {" "}
              · {event.from ?? "—"} → {event.to ?? "—"}
            </span>
          </li>
        ))}
      </ol>
    </section>
  );
}
