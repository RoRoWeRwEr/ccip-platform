import { describe, expect, it, vi } from "vitest";
import {
  createDraft,
  decidePublication,
  rollbackVersion,
  submitPublication,
} from "./publication";

const versionId = "10000000-0000-4000-8000-000000000001";
const reviewerId = "10000000-0000-4000-8000-000000000002";
const approverId = "10000000-0000-4000-8000-000000000003";

describe("controlled publication workflow", () => {
  it("creates only a typed DRAFT row with the next version", async () => {
    const insert = vi.fn().mockResolvedValue({ error: null });
    const chain = {
      select: vi.fn(),
      eq: vi.fn(),
      order: vi.fn(),
      limit: vi.fn(),
      maybeSingle: vi
        .fn()
        .mockResolvedValue({ data: { version_number: 2 }, error: null }),
    };
    chain.select.mockReturnValue(chain);
    chain.eq.mockReturnValue(chain);
    chain.order.mockReturnValue(chain);
    chain.limit.mockReturnValue(chain);
    const client = {
      from: vi.fn((table: string) =>
        table === "catalog_publication_versions" &&
        client.from.mock.calls.length === 1
          ? chain
          : { insert },
      ),
    };
    await createDraft(client as never, {
      target: `CARD:${versionId}`,
      summary: "Updated official terms",
      snapshot: '{"name_en":"Card"}',
    });
    expect(insert).toHaveBeenCalledWith(
      expect.objectContaining({
        card_id: versionId,
        version_number: 3,
        content_snapshot: { name_en: "Card" },
      }),
    );
  });

  it("submits through the controlled function with separated actors", async () => {
    const rpc = vi.fn().mockResolvedValue({ data: versionId, error: null });
    await submitPublication({ rpc } as never, {
      versionId,
      reviewerId,
      approverId,
      publishAt: "",
      unpublishAt: "",
    });
    expect(rpc).toHaveBeenCalledWith(
      "submit_catalog_publication",
      expect.objectContaining({
        reviewer_id: reviewerId,
        final_approver_id: approverId,
      }),
    );
  });

  it("records decisions only through the controlled function", async () => {
    const rpc = vi
      .fn()
      .mockResolvedValue({ data: "REVIEW_APPROVED", error: null });
    await decidePublication({ rpc } as never, {
      requestId: versionId,
      decision: "APPROVE",
      comments: "Official source verified",
    });
    expect(rpc).toHaveBeenCalledWith(
      "decide_catalog_publication",
      expect.anything(),
    );
  });

  it("rejects a rollback to the same version before RPC", async () => {
    const rpc = vi.fn();
    await expect(
      rollbackVersion({ rpc } as never, {
        currentId: versionId,
        replacementId: versionId,
        reason: "Bad rollback",
      }),
    ).rejects.toMatchObject({ code: "BAD_REQUEST" });
    expect(rpc).not.toHaveBeenCalled();
  });
});
