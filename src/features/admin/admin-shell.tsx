import type { Locale } from "@/lib/i18n";
import type { AdminAuthorization } from "./authorization";
import type { AssignmentWorkspace } from "./assignments";
import { AssignmentPanel } from "./assignment-panel";
import type { AdminWorkspace } from "./management";
import { ManagementPanel } from "./management-panel";
import type { PublicationWorkspace } from "./publication";
import { PublicationPanel } from "./publication-panel";

const copy = {
  en: {
    eyebrow: "Catalog administration",
    title: "Administration access",
    signedIn: "Signed in as",
    effective: "Effective catalog scope",
    global: "GLOBAL",
    globalDescription: "All banks and shared catalog resources",
    bank: "BANK",
    platform: "Platform administrator",
    catalog: "Catalog administrator",
    safety:
      "Access is evaluated by the database from your active assignments. This page does not use privileged credentials or browser-provided role claims.",
  },
  ar: {
    eyebrow: "إدارة الكتالوج",
    title: "صلاحيات الإدارة",
    signedIn: "تم تسجيل الدخول باسم",
    effective: "نطاق الكتالوج الفعّال",
    global: "عالمي",
    globalDescription: "جميع البنوك وموارد الكتالوج المشتركة",
    bank: "بنك",
    platform: "مسؤول المنصة",
    catalog: "مسؤول الكتالوج",
    safety:
      "تقيّم قاعدة البيانات الصلاحيات من التعيينات الفعّالة. لا تستخدم هذه الصفحة بيانات اعتماد مميزة أو ادعاءات أدوار مقدمة من المتصفح.",
  },
} as const;

export function AdminShell({
  locale,
  authorization,
  workspace,
  publication,
  assignments,
}: Readonly<{
  locale: Locale;
  authorization: AdminAuthorization;
  workspace?: AdminWorkspace;
  publication?: PublicationWorkspace;
  assignments?: AssignmentWorkspace;
}>) {
  const text = copy[locale];
  return (
    <main
      id="main-content"
      tabIndex={-1}
      className="mx-auto min-h-screen max-w-5xl px-5 py-12 sm:px-8"
    >
      <p className="text-brand text-sm font-bold">{text.eyebrow}</p>
      <h1 className="mt-2 text-4xl font-bold">{text.title}</h1>
      <p className="text-muted mt-3">
        {text.signedIn} <span dir="ltr">{authorization.email}</span> ·{" "}
        {authorization.isPlatformAdministrator ? text.platform : text.catalog}
      </p>

      <section
        aria-labelledby="effective-scope"
        className="border-line mt-8 rounded-3xl border bg-white p-6 shadow-sm"
      >
        <h2 id="effective-scope" className="text-2xl font-bold">
          {text.effective}
        </h2>
        {authorization.global ? (
          <div className="bg-accent-soft mt-5 rounded-2xl p-5">
            <p className="text-accent-deep text-lg font-bold">{text.global}</p>
            <p className="text-muted mt-1">{text.globalDescription}</p>
          </div>
        ) : (
          <ul className="mt-5 grid gap-3 sm:grid-cols-2">
            {authorization.banks.map((bank) => (
              <li key={bank.id} className="border-line rounded-2xl border p-4">
                <p className="text-brand text-xs font-bold">{text.bank}</p>
                <p className="mt-1 font-bold">
                  {locale === "ar" ? bank.nameAr : bank.nameEn}
                </p>
                <p className="text-muted text-sm">
                  {locale === "ar" ? bank.nameEn : bank.nameAr}
                </p>
              </li>
            ))}
          </ul>
        )}
      </section>
      <p className="text-muted mt-6 max-w-3xl text-sm leading-6">
        {text.safety}
      </p>
      {workspace && (
        <ManagementPanel
          locale={locale}
          authorization={authorization}
          workspace={workspace}
        />
      )}
      {workspace && publication && (
        <PublicationPanel
          locale={locale}
          targets={workspace.targets}
          workspace={publication}
        />
      )}
      {workspace && assignments && (
        <AssignmentPanel
          locale={locale}
          banks={workspace.targets}
          assignments={assignments}
        />
      )}
    </main>
  );
}
