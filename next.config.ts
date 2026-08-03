import type { NextConfig } from "next";

const developmentScriptPolicy =
  process.env.NODE_ENV === "development"
    ? "script-src 'self' 'unsafe-inline' 'unsafe-eval'"
    : "script-src 'self' 'unsafe-inline'";
const developmentConnectPolicy =
  process.env.NODE_ENV === "development"
    ? "connect-src 'self' https://*.supabase.co wss://*.supabase.co http://127.0.0.1:* ws://127.0.0.1:* http://localhost:* ws://localhost:*"
    : "connect-src 'self' https://*.supabase.co wss://*.supabase.co";

const securityHeaders = [
  {
    key: "Content-Security-Policy",
    value: `default-src 'self'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'; object-src 'none'; ${developmentScriptPolicy}; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; ${developmentConnectPolicy}; upgrade-insecure-requests`,
  },
  { key: "Cross-Origin-Opener-Policy", value: "same-origin" },
  { key: "Cross-Origin-Resource-Policy", value: "same-origin" },
  {
    key: "Permissions-Policy",
    value: "camera=(), microphone=(), geolocation=(), payment=()",
  },
  { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
  {
    key: "Strict-Transport-Security",
    value: "max-age=31536000; includeSubDomains",
  },
  { key: "X-Content-Type-Options", value: "nosniff" },
  { key: "X-DNS-Prefetch-Control", value: "off" },
  { key: "X-Frame-Options", value: "DENY" },
] as const;

const nextConfig: NextConfig = {
  poweredByHeader: false,
  reactStrictMode: true,
  async headers() {
    return [{ source: "/(.*)", headers: [...securityHeaders] }];
  },
};

export default nextConfig;
