import { describe, expect, it, vi } from "vitest";
import { loadAdminAuthorization } from "./authorization";

function client({
  platform = false,
  global = false,
  bankIds = [] as string[],
} = {}) {
  const banks = [
    { id: "bank-1", name_ar: "الأول", name_en: "First" },
    { id: "bank-2", name_ar: "الثاني", name_en: "Second" },
  ];
  return {
    auth: {
      getUser: vi.fn().mockResolvedValue({
        data: { user: { id: "user-1", email: "admin@example.test" } },
        error: null,
      }),
    },
    rpc: vi.fn(
      async (name: string, args: { requested_bank_id?: string | null }) => ({
        data:
          name === "has_active_platform_role"
            ? platform
            : args.requested_bank_id === null
              ? global
              : bankIds.includes(args.requested_bank_id ?? ""),
        error: null,
      }),
    ),
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        eq: vi.fn(() => ({
          order: vi.fn().mockResolvedValue({ data: banks, error: null }),
        })),
      })),
    })),
  };
}

describe("admin authorization", () => {
  it("maps platform administrators to global access without enumerating banks", async () => {
    const mock = client({ platform: true });
    await expect(loadAdminAuthorization(mock as never)).resolves.toMatchObject({
      global: true,
      isPlatformAdministrator: true,
    });
    expect(mock.from).not.toHaveBeenCalled();
  });

  it("returns only banks approved by the scope-aware database gate", async () => {
    await expect(
      loadAdminAuthorization(client({ bankIds: ["bank-2"] }) as never),
    ).resolves.toMatchObject({ global: false, banks: [{ id: "bank-2" }] });
  });

  it("denies users with no effective scope", async () => {
    await expect(loadAdminAuthorization(client() as never)).resolves.toBeNull();
  });
});
