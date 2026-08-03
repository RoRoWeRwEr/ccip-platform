import type { SupabaseClient } from "@supabase/supabase-js";
import { z } from "zod";
import { AppError } from "@/lib/errors/app-error";
import type { Database } from "@/types/database";

type Client = SupabaseClient<Database>;
const uuid = z.string().uuid();
const reason = z.string().trim().min(1).max(1000);

function failure(operation: string, cause: unknown) {
  return new AppError("DEPENDENCY_UNAVAILABLE", `${operation} failed`, {
    cause,
  });
}

async function requirePlatformAdministrator(client: Client) {
  const result = await client.rpc("has_active_platform_role", {
    requested_role_code: "PLATFORM_ADMINISTRATOR",
  });
  if (result.error) throw failure("platform authorization", result.error);
  if (!result.data)
    throw new AppError("FORBIDDEN", "PLATFORM_ADMINISTRATOR required");
}

export type AssignmentWorkspace = Array<{
  id: string;
  roleAssignmentId: string;
  userId: string;
  scope: string;
  bankId: string | null;
  reason: string;
  validFrom: string;
  validUntil: string | null;
  revokedAt: string | null;
  revocationReason: string | null;
}>;

export async function loadAssignmentWorkspace(
  client: Client,
): Promise<AssignmentWorkspace> {
  await requirePlatformAdministrator(client);
  const [roles, scopes] = await Promise.all([
    client
      .from("user_platform_role_assignments")
      .select("id,user_id,role_id,valid_from,valid_until,revoked_at")
      .order("assigned_at", { ascending: false })
      .limit(500),
    client
      .from("catalog_administrator_scope_assignments")
      .select(
        "id,role_assignment_id,scope_type,bank_id,assignment_reason,valid_from,valid_until,revoked_at,revocation_reason",
      )
      .order("assigned_at", { ascending: false })
      .limit(500),
  ]);
  if (roles.error) throw failure("role assignment history", roles.error);
  if (scopes.error) throw failure("catalog scope history", scopes.error);
  const byId = new Map((roles.data ?? []).map((role) => [role.id, role]));
  return (scopes.data ?? []).flatMap((scope) => {
    const role = byId.get(scope.role_assignment_id);
    if (!role) return [];
    return [
      {
        id: scope.id,
        roleAssignmentId: role.id,
        userId: role.user_id,
        scope: scope.scope_type,
        bankId: scope.bank_id,
        reason: scope.assignment_reason,
        validFrom: scope.valid_from,
        validUntil: scope.valid_until,
        revokedAt: scope.revoked_at ?? role.revoked_at,
        revocationReason: scope.revocation_reason,
      },
    ];
  });
}

export async function createCatalogAssignment(client: Client, input: unknown) {
  const parsed = z
    .object({
      userId: uuid,
      scope: z.enum(["GLOBAL", "BANK"]),
      bankId: uuid.optional().or(z.literal("")),
      reason,
      validUntil: z.string().max(35).optional().or(z.literal("")),
    })
    .safeParse(input);
  if (
    !parsed.success ||
    (parsed.data.scope === "BANK" && !parsed.data.bankId) ||
    (parsed.data.scope === "GLOBAL" && parsed.data.bankId)
  )
    throw new AppError("BAD_REQUEST", "Invalid catalog assignment");
  await requirePlatformAdministrator(client);
  const role = await client
    .from("platform_roles")
    .select("id")
    .eq("role_code", "CATALOG_ADMINISTRATOR")
    .eq("is_active", true)
    .single();
  if (role.error) throw failure("catalog role lookup", role.error);
  const until = parsed.data.validUntil
    ? new Date(parsed.data.validUntil)
    : null;
  if (until && (!Number.isFinite(until.getTime()) || until <= new Date()))
    throw new AppError("BAD_REQUEST", "Invalid validity window");
  const parent = await client
    .from("user_platform_role_assignments")
    .insert({
      user_id: parsed.data.userId,
      role_id: role.data.id,
      scope_type: "PLATFORM",
      assignment_reason: parsed.data.reason,
      valid_until: until?.toISOString(),
    })
    .select("id")
    .single();
  if (parent.error) throw failure("catalog role assignment", parent.error);
  const scope = await client
    .from("catalog_administrator_scope_assignments")
    .insert({
      role_assignment_id: parent.data.id,
      scope_type: parsed.data.scope,
      bank_id: parsed.data.scope === "BANK" ? parsed.data.bankId || null : null,
      assignment_reason: parsed.data.reason,
      valid_until: until?.toISOString(),
    });
  if (scope.error) {
    await client
      .from("user_platform_role_assignments")
      .update({
        revoked_at: new Date().toISOString(),
        revocation_reason: "Scope creation failed; parent assignment closed",
      })
      .eq("id", parent.data.id);
    throw failure("catalog scope assignment", scope.error);
  }
}

export async function revokeCatalogAssignment(client: Client, input: unknown) {
  const parsed = z
    .object({ scopeId: uuid, roleAssignmentId: uuid, reason })
    .safeParse(input);
  if (!parsed.success) throw new AppError("BAD_REQUEST", "Invalid revocation");
  await requirePlatformAdministrator(client);
  const now = new Date().toISOString();
  const scope = await client
    .from("catalog_administrator_scope_assignments")
    .update({ revoked_at: now, revocation_reason: parsed.data.reason })
    .eq("id", parsed.data.scopeId)
    .is("revoked_at", null);
  if (scope.error) throw failure("catalog scope revocation", scope.error);
  const parent = await client
    .from("user_platform_role_assignments")
    .update({ revoked_at: now, revocation_reason: parsed.data.reason })
    .eq("id", parsed.data.roleAssignmentId)
    .is("revoked_at", null);
  if (parent.error) throw failure("catalog role revocation", parent.error);
}
