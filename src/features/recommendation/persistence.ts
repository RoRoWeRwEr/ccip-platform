import type { SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/types/database";
import { AppError } from "@/lib/errors/app-error";

type Client = SupabaseClient<Database>;

export type RecommendationHistoryItem = {
  id: string;
  name: string | null;
  status: Database["public"]["Enums"]["recommendation_run_status"];
  startedAt: string;
  completedAt: string | null;
  cardsRecommended: number;
  topCardId: string | null;
  confidence: number | null;
  results: Array<{
    id: string;
    cardId: string;
    rank: number | null;
    netValue: number | null;
    rewardValue: number | null;
    annualFee: number | null;
    confidence: string | null;
  }>;
};

function failure(operation: string, cause: unknown) {
  return new AppError("DEPENDENCY_UNAVAILABLE", `${operation} failed`, {
    cause,
  });
}

export async function listRecommendationHistory(
  client: Client,
  limit = 20,
): Promise<RecommendationHistoryItem[]> {
  const { data: authData, error: authError } = await client.auth.getUser();
  if (authError)
    throw failure("recommendation history authentication", authError);
  if (!authData.user) return [];
  const boundedLimit = Math.min(Math.max(Math.trunc(limit), 1), 50);
  const { data: runs, error: runError } = await client
    .from("recommendation_runs")
    .select(
      "id,run_name,run_status,started_at,completed_at,cards_recommended,top_recommendation_card_id,overall_confidence",
    )
    .order("started_at", { ascending: false })
    .limit(boundedLimit);
  if (runError) throw failure("recommendation history query", runError);
  if (!runs.length) return [];
  const { data: results, error: resultError } = await client
    .from("recommendation_results")
    .select(
      "id,recommendation_run_id,card_id,recommendation_rank,expected_net_value,expected_reward_value,expected_annual_fee,confidence_level",
    )
    .in(
      "recommendation_run_id",
      runs.map((run) => run.id),
    )
    .eq("is_visible", true)
    .order("recommendation_rank", { ascending: true });
  if (resultError)
    throw failure("recommendation result history query", resultError);
  return runs.map((run) => ({
    id: run.id,
    name: run.run_name,
    status: run.run_status,
    startedAt: run.started_at,
    completedAt: run.completed_at,
    cardsRecommended: run.cards_recommended,
    topCardId: run.top_recommendation_card_id,
    confidence: run.overall_confidence,
    results: results
      .filter((result) => result.recommendation_run_id === run.id)
      .map((result) => ({
        id: result.id,
        cardId: result.card_id,
        rank: result.recommendation_rank,
        netValue: result.expected_net_value,
        rewardValue: result.expected_reward_value,
        annualFee: result.expected_annual_fee,
        confidence: result.confidence_level,
      })),
  }));
}

export async function saveRecommendationResult(
  client: Client,
  input: {
    collectionId: string;
    cardId: string;
    runId: string;
    resultId: string;
    expectedAnnualValue?: number;
    rank?: number;
  },
) {
  const { data: authData, error: authError } = await client.auth.getUser();
  if (authError) throw failure("save recommendation authentication", authError);
  if (!authData.user)
    throw new AppError("UNAUTHENTICATED", "Authentication required");
  const { data, error } = await client
    .from("user_saved_cards")
    .insert({
      user_id: authData.user.id,
      collection_id: input.collectionId,
      card_id: input.cardId,
      recommendation_run_id: input.runId,
      recommendation_result_id: input.resultId,
      saved_reference: `recommendation:${input.resultId}`,
      saved_source: "RECOMMENDATION_DETAIL",
      expected_annual_value: input.expectedAnnualValue,
      rank_at_save: input.rank,
    })
    .select("id")
    .single();
  if (error) throw failure("save recommendation result", error);
  return data.id;
}
