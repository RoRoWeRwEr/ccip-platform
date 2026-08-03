import { describe, expect, it, vi } from "vitest";
import type { SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/types/database";
import {
  listRecommendationHistory,
  saveRecommendationResult,
} from "./persistence";

type Client = SupabaseClient<Database>;

function query<T>(data: T, error: unknown = null) {
  const builder = {
    select: vi.fn(),
    order: vi.fn(),
    limit: vi.fn(),
    in: vi.fn(),
    eq: vi.fn(),
    insert: vi.fn(),
    single: vi.fn(),
    then: (
      resolve: (value: { data: T; error: unknown }) => unknown,
      reject?: (reason: unknown) => unknown,
    ) => Promise.resolve({ data, error }).then(resolve, reject),
  };
  for (const method of [
    "select",
    "order",
    "limit",
    "in",
    "eq",
    "insert",
    "single",
  ] as const) {
    builder[method].mockReturnValue(builder);
  }
  return builder;
}

function client({
  userId,
  tables = {},
}: {
  userId?: string;
  tables?: Record<string, ReturnType<typeof query>>;
}) {
  return {
    auth: {
      getUser: vi.fn().mockResolvedValue({
        data: { user: userId ? { id: userId } : null },
        error: null,
      }),
    },
    from: vi.fn((table: string) => tables[table]),
  } as unknown as Client;
}

describe("recommendation persistence", () => {
  it("keeps guest recommendation history ephemeral", async () => {
    const persistenceClient = client({});
    await expect(listRecommendationHistory(persistenceClient)).resolves.toEqual(
      [],
    );
    expect(persistenceClient.from).not.toHaveBeenCalled();
  });

  it("maps only visible results from owned runs into history", async () => {
    const runs = query([
      {
        id: "run-1",
        run_name: "Travel shortlist",
        run_status: "COMPLETED" as const,
        started_at: "2026-08-03T09:00:00Z",
        completed_at: "2026-08-03T09:00:01Z",
        cards_recommended: 1,
        top_recommendation_card_id: "card-1",
        overall_confidence: 0.9,
      },
    ]);
    const results = query([
      {
        id: "result-1",
        recommendation_run_id: "run-1",
        card_id: "card-1",
        recommendation_rank: 1,
        expected_net_value: 950,
        expected_reward_value: 1_000,
        expected_annual_fee: 50,
        confidence_level: "HIGH" as const,
      },
    ]);
    const persistenceClient = client({
      userId: "user-1",
      tables: { recommendation_runs: runs, recommendation_results: results },
    });

    const history = await listRecommendationHistory(persistenceClient, 500);

    expect(runs.limit).toHaveBeenCalledWith(50);
    expect(results.eq).toHaveBeenCalledWith("is_visible", true);
    expect(history).toEqual([
      expect.objectContaining({
        id: "run-1",
        name: "Travel shortlist",
        results: [
          expect.objectContaining({ id: "result-1", cardId: "card-1" }),
        ],
      }),
    ]);
  });

  it("requires authentication before saving a recommendation", async () => {
    await expect(
      saveRecommendationResult(client({}), {
        collectionId: "collection-1",
        cardId: "card-1",
        runId: "run-1",
        resultId: "result-1",
      }),
    ).rejects.toMatchObject({ code: "UNAUTHENTICATED", status: 401 });
  });

  it("writes an authenticated save through the ownership-protected table", async () => {
    const savedCards = query({ id: "saved-1" });
    const persistenceClient = client({
      userId: "user-1",
      tables: { user_saved_cards: savedCards },
    });

    await expect(
      saveRecommendationResult(persistenceClient, {
        collectionId: "collection-1",
        cardId: "card-1",
        runId: "run-1",
        resultId: "result-1",
        expectedAnnualValue: 950,
        rank: 1,
      }),
    ).resolves.toBe("saved-1");
    expect(savedCards.insert).toHaveBeenCalledWith({
      user_id: "user-1",
      collection_id: "collection-1",
      card_id: "card-1",
      recommendation_run_id: "run-1",
      recommendation_result_id: "result-1",
      saved_reference: "recommendation:result-1",
      saved_source: "RECOMMENDATION_DETAIL",
      expected_annual_value: 950,
      rank_at_save: 1,
    });
  });
});
