import { describe, expect, it, vi } from "vitest";
import { createMerchant, createProvenance } from "./management";

describe("admin catalog management boundaries", () => {
  it("maps a validated card source to the typed provenance foreign key", async () => {
    const insert = vi.fn().mockResolvedValue({ error: null });
    const client = { from: vi.fn(() => ({ insert })) };
    await createProvenance(client as never, {
      target: "CARD:10000000-0000-4000-8000-000000000001",
      title: "Official card",
      owner: "Bank",
      url: "https://bank.example/card",
    });
    expect(insert).toHaveBeenCalledWith(
      expect.objectContaining({
        target_entity_type: "CARD",
        card_id: "10000000-0000-4000-8000-000000000001",
        authority_level: "OFFICIAL_PRIMARY",
      }),
    );
  });

  it("rejects invalid source URLs before a database write", async () => {
    const from = vi.fn();
    await expect(
      createProvenance({ from } as never, {
        target: "BANK:10000000-0000-4000-8000-000000000001",
        title: "Source",
        owner: "Bank",
        url: "javascript:alert(1)",
      }),
    ).rejects.toMatchObject({ code: "BAD_REQUEST" });
    expect(from).not.toHaveBeenCalled();
  });

  it("requires GLOBAL scope before merchant writes", async () => {
    const from = vi.fn();
    const client = {
      rpc: vi.fn().mockResolvedValue({ data: false, error: null }),
      from,
    };
    await expect(
      createMerchant(client as never, {
        slug: "merchant",
        nameEn: "Merchant",
        nameAr: "تاجر",
      }),
    ).rejects.toMatchObject({ code: "FORBIDDEN" });
    expect(from).not.toHaveBeenCalled();
  });
});
