import type { Instrumentation } from "next";
import { getLogger } from "@/lib/logging/logger";

export const onRequestError: Instrumentation.onRequestError = async (
  _error,
  request,
  context,
) => {
  getLogger().error(
    {
      event: "request_error",
      method: request.method,
      route: context.routePath,
      routeType: context.routeType,
      router: context.routerKind,
    },
    "Unhandled request error",
  );
};
