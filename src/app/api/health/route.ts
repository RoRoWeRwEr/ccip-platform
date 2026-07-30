import { NextResponse } from "next/server";
import { getRequestId } from "@/lib/http/request-id";

export const dynamic = "force-dynamic";

export function GET(request: Request) {
  const requestId = getRequestId(request.headers);
  return NextResponse.json(
    {
      status: "ok",
      service: "ccip-web",
      version: process.env.APP_VERSION ?? "local",
      requestId,
    },
    { headers: { "cache-control": "no-store", "x-request-id": requestId } },
  );
}
