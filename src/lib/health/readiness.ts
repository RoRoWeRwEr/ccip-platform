import { createClient } from "@supabase/supabase-js";
import { getServerEnvironment } from "@/lib/config/env";
import type { Database } from "@/types/database";

const READINESS_TIMEOUT_MS = 3_000;

export async function checkReadiness(
  options: { timeoutMs?: number } = {},
): Promise<{
  ready: true;
  latencyMs: number;
}> {
  const environment = getServerEnvironment();
  const client = createClient<Database>(
    environment.NEXT_PUBLIC_SUPABASE_URL,
    environment.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,
    {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUrl: false,
      },
    },
  );
  const controller = new AbortController();
  const timeout = setTimeout(
    () => controller.abort(),
    options.timeoutMs ?? READINESS_TIMEOUT_MS,
  );
  const startedAt = performance.now();

  try {
    const { error } = await client
      .from("countries")
      .select("id", { head: true })
      .limit(1)
      .abortSignal(controller.signal);
    if (error) throw error;
    return {
      ready: true,
      latencyMs: Math.round(performance.now() - startedAt),
    };
  } finally {
    clearTimeout(timeout);
  }
}
