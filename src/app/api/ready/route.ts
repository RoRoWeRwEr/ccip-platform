import { NextResponse } from "next/server";
import { toSafeError } from "@/lib/errors/app-error";
import { checkReadiness } from "@/lib/health/readiness";
import { getRequestId } from "@/lib/http/request-id";

export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  const requestId = getRequestId(request.headers);
  try {
    const readiness = await checkReadiness();
    return NextResponse.json(
      { status: "ready", service: "ccip-web", ...readiness, requestId },
      { headers: { "cache-control": "no-store", "x-request-id": requestId } },
    );
  } catch (cause) {
    const safe = toSafeError(cause);
    return NextResponse.json(
      {
        status: "not_ready",
        error: {
          code: "DEPENDENCY_UNAVAILABLE",
          message: safe.body.error.message,
        },
        requestId,
      },
      {
        status: 503,
        headers: {
          "cache-control": "no-store",
          "retry-after": "5",
          "x-request-id": requestId,
        },
      },
    );
  }
}
