import { z } from "zod";

const publicEnvironmentSchema = z.object({
  NEXT_PUBLIC_SUPABASE_URL: z
    .url()
    .refine(
      (value) =>
        value.startsWith("https://") ||
        value.startsWith("http://127.0.0.1") ||
        value.startsWith("http://localhost"),
      "Supabase URL must use HTTPS except for local development",
    ),
  NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: z.string().trim().min(20),
});

const serverEnvironmentSchema = publicEnvironmentSchema.extend({
  APP_VERSION: z.string().trim().min(1).max(100).default("local"),
  LOG_LEVEL: z
    .enum(["fatal", "error", "warn", "info", "debug", "trace", "silent"])
    .default("info"),
});

export type PublicEnvironment = z.infer<typeof publicEnvironmentSchema>;
export type ServerEnvironment = z.infer<typeof serverEnvironmentSchema>;

function formatEnvironmentError(error: z.ZodError): string {
  return error.issues
    .map((issue) => `${issue.path.join(".")}: ${issue.message}`)
    .join("; ");
}

export function parsePublicEnvironment(
  environment: Record<string, string | undefined>,
): PublicEnvironment {
  const result = publicEnvironmentSchema.safeParse(environment);
  if (!result.success) {
    throw new Error(
      `Invalid public environment: ${formatEnvironmentError(result.error)}`,
    );
  }
  return result.data;
}

export function parseServerEnvironment(
  environment: Record<string, string | undefined>,
): ServerEnvironment {
  const result = serverEnvironmentSchema.safeParse(environment);
  if (!result.success) {
    throw new Error(
      `Invalid server environment: ${formatEnvironmentError(result.error)}`,
    );
  }
  return result.data;
}

export function getPublicEnvironment(): PublicEnvironment {
  return parsePublicEnvironment({
    NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
    NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY:
      process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,
  });
}

export function getServerEnvironment(): ServerEnvironment {
  return parseServerEnvironment({
    NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
    NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY:
      process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,
    APP_VERSION: process.env.APP_VERSION,
    LOG_LEVEL: process.env.LOG_LEVEL,
  });
}
