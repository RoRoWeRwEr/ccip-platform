import { describe, expect, it, vi } from "vitest";
import {
  createCatalogAssignment,
  revokeCatalogAssignment,
} from "./assignments";

const userId = "10000000-0000-4000-8000-000000000001";
const bankId = "10000000-0000-4000-8000-000000000002";
const roleId = "42000000-0000-4000-8000-000000000002";
const assignmentId = "10000000-0000-4000-8000-000000000003";

describe("catalog assignment administration", () => {
  it("rejects BANK scope without a bank before writing", async () => {
    const rpc = vi.fn();
    await expect(
      createCatalogAssignment({ rpc } as never, {
        userId,
        scope: "BANK",
        bankId: "",
        reason: "Bank catalog owner",
        validUntil: "",
      }),
    ).rejects.toMatchObject({ code: "BAD_REQUEST" });
    expect(rpc).not.toHaveBeenCalled();
  });

  it("requires platform administrator before assignment writes", async () => {
    const from = vi.fn();
    const rpc = vi.fn().mockResolvedValue({ data: false, error: null });
    await expect(
      createCatalogAssignment({ rpc, from } as never, {
        userId,
        scope: "GLOBAL",
        bankId: "",
        reason: "Platform catalog owner",
        validUntil: "",
      }),
    ).rejects.toMatchObject({ code: "FORBIDDEN" });
    expect(from).not.toHaveBeenCalled();
  });

  it("creates the parent role and explicit BANK scope", async () => {
    const scopeInsert = vi.fn().mockResolvedValue({ error: null });
    const roleChain = {
      select: vi.fn(),
      eq: vi.fn(),
      single: vi.fn().mockResolvedValue({ data: { id: roleId }, error: null }),
    };
    roleChain.select.mockReturnValue(roleChain);
    roleChain.eq.mockReturnValue(roleChain);
    const parentChain = {
      insert: vi.fn(),
      select: vi.fn(),
      single: vi
        .fn()
        .mockResolvedValue({ data: { id: assignmentId }, error: null }),
    };
    parentChain.insert.mockReturnValue(parentChain);
    parentChain.select.mockReturnValue(parentChain);
    const client = {
      rpc: vi.fn().mockResolvedValue({ data: true, error: null }),
      from: vi.fn((table: string) =>
        table === "platform_roles"
          ? roleChain
          : table === "user_platform_role_assignments"
            ? parentChain
            : { insert: scopeInsert },
      ),
    };
    await createCatalogAssignment(client as never, {
      userId,
      scope: "BANK",
      bankId,
      reason: "Bank catalog owner",
      validUntil: "",
    });
    expect(scopeInsert).toHaveBeenCalledWith(
      expect.objectContaining({
        scope_type: "BANK",
        bank_id: bankId,
        role_assignment_id: assignmentId,
      }),
    );
  });

  it("checks platform authorization before revocation", async () => {
    const from = vi.fn();
    const rpc = vi.fn().mockResolvedValue({ data: false, error: null });
    await expect(
      revokeCatalogAssignment({ rpc, from } as never, {
        scopeId: bankId,
        roleAssignmentId: assignmentId,
        reason: "Role change",
      }),
    ).rejects.toMatchObject({ code: "FORBIDDEN" });
    expect(from).not.toHaveBeenCalled();
  });
});
