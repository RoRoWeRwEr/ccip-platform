import "server-only";

import pino from "pino";
import { getServerEnvironment } from "@/lib/config/env";

let logger: pino.Logger | undefined;

export function getLogger(): pino.Logger {
  if (!logger) {
    const environment = getServerEnvironment();
    logger = pino({
      level: environment.LOG_LEVEL,
      base: { service: "ccip-web", version: environment.APP_VERSION },
      redact: {
        paths: [
          "req.headers.authorization",
          "req.headers.cookie",
          "request.headers.authorization",
          "request.headers.cookie",
          "password",
          "token",
          "access_token",
          "refresh_token",
          "*.password",
          "*.token",
        ],
        censor: "[REDACTED]",
      },
    });
  }
  return logger;
}
