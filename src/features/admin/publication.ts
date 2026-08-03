import type { SupabaseClient } from "@supabase/supabase-js";
import { z } from "zod";
import { AppError } from "@/lib/errors/app-error";
import type { Database, Json } from "@/types/database";

type Client = SupabaseClient<Database>;
const uuid = z.string().uuid();
const target = z.string().regex(/^(BANK|CARD):[0-9a-f-]{36}$/i);
const reason = z.string().trim().min(1).max(2000);

function failure(operation: string, cause: unknown) {
  return new AppError("DEPENDENCY_UNAVAILABLE", `${operation} failed`, {
    cause,
  });
}

export type PublicationWorkspace = {
  versions: Array<{
    id: string;
    target: string;
    version: number;
    status: string;
    summary: string;
    scheduledAt: string | null;
  }>;
  requests: Array<{
    id: string;
    versionId: string;
    status: string;
    reviewerId: string;
    approverId: string;
    submittedAt: string;
  }>;
  events: Array<{
    id: string;
    versionId: string;
    type: string;
    from: string | null;
    to: string | null;
    occurredAt: string;
  }>;
};

export async function loadPublicationWorkspace(
  client: Client,
): Promise<PublicationWorkspace> {
  const [versions, requests, events] = await Promise.all([
    client
      .from("catalog_publication_versions")
      .select(
        "id,target_entity_type,target_entity_id,version_number,lifecycle_status,change_summary,scheduled_publish_at",
      )
      .order("updated_at", { ascending: false })
      .limit(100),
    client
      .from("catalog_publication_requests")
      .select(
        "id,publication_version_id,request_status,reviewer_user_id,final_approver_user_id,submitted_at",
      )
      .order("submitted_at", { ascending: false })
      .limit(100),
    client
      .from("catalog_publication_events")
      .select(
        "id,publication_version_id,event_type,from_status,to_status,occurred_at",
      )
      .order("event_sequence", { ascending: false })
      .limit(200),
  ]);
  for (const [name, result] of [
    ["versions", versions],
    ["requests", requests],
    ["history", events],
  ] as const)
    if (result.error) throw failure(`publication ${name}`, result.error);
  return {
    versions: (versions.data ?? []).map((row) => ({
      id: row.id,
      target: `${row.target_entity_type}:${row.target_entity_id}`,
      version: row.version_number,
      status: row.lifecycle_status,
      summary: row.change_summary,
      scheduledAt: row.scheduled_publish_at,
    })),
    requests: (requests.data ?? []).map((row) => ({
      id: row.id,
      versionId: row.publication_version_id,
      status: row.request_status,
      reviewerId: row.reviewer_user_id,
      approverId: row.final_approver_user_id,
      submittedAt: row.submitted_at,
    })),
    events: (events.data ?? []).map((row) => ({
      id: row.id,
      versionId: row.publication_version_id,
      type: row.event_type,
      from: row.from_status,
      to: row.to_status,
      occurredAt: row.occurred_at,
    })),
  };
}

export async function createDraft(client: Client, input: unknown) {
  const schema = z.object({
    target,
    summary: reason,
    snapshot: z.string().min(2).max(100_000),
  });
  const parsed = schema.safeParse(input);
  if (!parsed.success)
    throw new AppError("BAD_REQUEST", "Invalid publication draft");
  let snapshot: Json;
  try {
    snapshot = JSON.parse(parsed.data.snapshot) as Json;
  } catch {
    throw new AppError("BAD_REQUEST", "Snapshot must be valid JSON");
  }
  if (!snapshot || Array.isArray(snapshot) || typeof snapshot !== "object")
    throw new AppError("BAD_REQUEST", "Snapshot must be a JSON object");
  const [type, id] = parsed.data.target.split(":") as ["BANK" | "CARD", string];
  const latest = await client
    .from("catalog_publication_versions")
    .select("version_number")
    .eq("target_entity_type", type)
    .eq("target_entity_id", id)
    .order("version_number", { ascending: false })
    .limit(1)
    .maybeSingle();
  if (latest.error) throw failure("publication version lookup", latest.error);
  const result = await client.from("catalog_publication_versions").insert({
    target_entity_type: type,
    ...(type === "BANK" ? { bank_id: id } : { card_id: id }),
    version_number: (latest.data?.version_number ?? 0) + 1,
    content_snapshot: snapshot,
    change_summary: parsed.data.summary,
  });
  if (result.error) throw failure("publication draft creation", result.error);
}

export async function submitPublication(client: Client, input: unknown) {
  const parsed = z
    .object({
      versionId: uuid,
      reviewerId: uuid,
      approverId: uuid,
      publishAt: z.string().max(35).optional(),
      unpublishAt: z.string().max(35).optional(),
    })
    .safeParse(input);
  if (!parsed.success)
    throw new AppError("BAD_REQUEST", "Invalid publication submission");
  const publishDate = parsed.data.publishAt
    ? new Date(parsed.data.publishAt)
    : null;
  const unpublishDate = parsed.data.unpublishAt
    ? new Date(parsed.data.unpublishAt)
    : null;
  if (
    (publishDate && !Number.isFinite(publishDate.getTime())) ||
    (unpublishDate && !Number.isFinite(unpublishDate.getTime()))
  )
    throw new AppError("BAD_REQUEST", "Invalid publication schedule");
  const publishAt = publishDate?.toISOString();
  const unpublishAt = unpublishDate?.toISOString();
  if (publishAt && unpublishAt && unpublishAt <= publishAt)
    throw new AppError("BAD_REQUEST", "Unpublication must follow publication");
  const result = await client.rpc("submit_catalog_publication", {
    requested_version_id: parsed.data.versionId,
    reviewer_id: parsed.data.reviewerId,
    final_approver_id: parsed.data.approverId,
    publish_at: publishAt,
    unpublish_at: unpublishAt,
  });
  if (result.error) throw failure("publication submission", result.error);
}

export async function decidePublication(client: Client, input: unknown) {
  const parsed = z
    .object({
      requestId: uuid,
      decision: z.enum(["APPROVE", "REJECT"]),
      comments: reason,
    })
    .safeParse(input);
  if (!parsed.success)
    throw new AppError("BAD_REQUEST", "Invalid publication decision");
  const result = await client.rpc("decide_catalog_publication", {
    requested_request_id: parsed.data.requestId,
    decision: parsed.data.decision,
    comments: parsed.data.comments,
  });
  if (result.error) throw failure("publication decision", result.error);
}

export async function publishVersion(client: Client, versionId: string) {
  const id = uuid.safeParse(versionId);
  if (!id.success) throw new AppError("BAD_REQUEST", "Invalid version");
  const result = await client.rpc("publish_catalog_version", {
    requested_version_id: id.data,
  });
  if (result.error) throw failure("publication", result.error);
}
export async function unpublishVersion(client: Client, input: unknown) {
  const parsed = z
    .object({ versionId: uuid, archive: z.boolean(), reason })
    .safeParse(input);
  if (!parsed.success)
    throw new AppError("BAD_REQUEST", "Invalid unpublication");
  const result = await client.rpc("unpublish_catalog_version", {
    requested_version_id: parsed.data.versionId,
    archive: parsed.data.archive,
    reason: parsed.data.reason,
  });
  if (result.error) throw failure("unpublication", result.error);
}
export async function rollbackVersion(client: Client, input: unknown) {
  const parsed = z
    .object({ currentId: uuid, replacementId: uuid, reason })
    .safeParse(input);
  if (!parsed.success || parsed.data.currentId === parsed.data.replacementId)
    throw new AppError("BAD_REQUEST", "Invalid rollback");
  const result = await client.rpc("rollback_catalog_version", {
    current_version_id: parsed.data.currentId,
    replacement_version_id: parsed.data.replacementId,
    reason: parsed.data.reason,
  });
  if (result.error) throw failure("publication rollback", result.error);
}
