import { describe, expect, it } from "vitest";
import { isLocale, locales, messages } from "./i18n";

describe("locale foundation", () => {
  it("supports exactly Arabic and English", () => {
    expect(locales).toEqual(["ar", "en"]);
    expect(isLocale("ar")).toBe(true);
    expect(isLocale("en")).toBe(true);
    expect(isLocale("fr")).toBe(false);
  });

  it("provides equivalent required content in both languages", () => {
    for (const locale of locales) {
      const copy = messages[locale];
      expect(copy.title.length).toBeGreaterThan(10);
      expect(copy.description.length).toBeGreaterThan(20);
      expect(copy.signals).toHaveLength(3);
      expect(copy.navigation).toHaveLength(3);
      expect(copy.personas.map((persona) => persona.key)).toEqual([
        "cashback",
        "travel",
        "everyday",
      ]);
      expect(copy.principles).toHaveLength(3);
    }
  });
});
