import type { Metadata } from "next";
import { notFound, redirect } from "next/navigation";
import { AdminShell } from "@/features/admin/admin-shell";
import { loadAdminAuthorization } from "@/features/admin/authorization";
import { loadAssignmentWorkspace } from "@/features/admin/assignments";
import { loadAdminWorkspace } from "@/features/admin/management";
import { loadPublicationWorkspace } from "@/features/admin/publication";
import { isLocale } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";
export const metadata: Metadata = { robots: { index: false, follow: false } };

export default async function AdminRoute({
  params,
}: Readonly<{ params: Promise<{ locale: string }> }>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  const client = await createClient();
  const { data } = await client.auth.getUser();
  if (!data.user)
    redirect(`/${locale}/auth?next=${encodeURIComponent(`/${locale}/admin`)}`);
  const authorization = await loadAdminAuthorization(client);
  if (!authorization) notFound();
  const [workspace, publication] = await Promise.all([
    loadAdminWorkspace(client, authorization),
    loadPublicationWorkspace(client),
  ]);
  const assignments = authorization.isPlatformAdministrator
    ? await loadAssignmentWorkspace(client)
    : undefined;
  return (
    <AdminShell
      locale={locale}
      authorization={authorization}
      workspace={workspace}
      publication={publication}
      assignments={assignments}
    />
  );
}
