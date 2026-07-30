import { createServerClient } from "@supabase/ssr";
import { type NextRequest, NextResponse } from "next/server";
import { getPublicEnvironment } from "@/lib/config/env";
import { getRequestId } from "@/lib/http/request-id";
import type { Database } from "@/types/database";

export async function refreshSession(request: NextRequest) {
  const requestId = getRequestId(request.headers);
  const requestHeaders = new Headers(request.headers);
  requestHeaders.set("x-request-id", requestId);

  let response = NextResponse.next({ request: { headers: requestHeaders } });
  response.headers.set("x-request-id", requestId);

  try {
    const environment = getPublicEnvironment();
    const supabase = createServerClient<Database>(
      environment.NEXT_PUBLIC_SUPABASE_URL,
      environment.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,
      {
        cookies: {
          getAll: () => request.cookies.getAll(),
          setAll: (cookiesToSet) => {
            cookiesToSet.forEach(({ name, value }) =>
              request.cookies.set(name, value),
            );
            response = NextResponse.next({
              request: { headers: requestHeaders },
            });
            response.headers.set("x-request-id", requestId);
            cookiesToSet.forEach(({ name, value, options }) =>
              response.cookies.set(name, value, options),
            );
          },
        },
      },
    );

    // Validates and refreshes the signed session; never trust cookie contents alone.
    await supabase.auth.getClaims();
  } catch {
    // Public routes remain available when deployment configuration is absent or
    // Supabase is temporarily unreachable. Protected routes recheck auth server-side.
  }

  return response;
}
