import type { Metadata } from "next";
import type { ReactNode } from "react";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "CCIP — Credit Card Intelligence",
    template: "%s | CCIP",
  },
  description:
    "Compare Saudi credit cards and understand their real annual value.",
};

export default function RootLayout({
  children,
}: Readonly<{ children: ReactNode }>) {
  return children;
}
