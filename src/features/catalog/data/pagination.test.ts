import { describe, expect, it } from "vitest";
import { makePage, parsePagination, toRange } from "./pagination";

describe("catalog pagination", () => {
  it("applies bounded defaults and computes an inclusive database range", () => {
    const pagination = parsePagination({});
    expect(pagination).toEqual({ page: 1, pageSize: 20 });
    expect(toRange(parsePagination({ page: "3", pageSize: "10" }))).toEqual({
      from: 20,
      to: 29,
    });
  });

  it("rejects unbounded or invalid input", () => {
    expect(() => parsePagination({ page: 0 })).toThrow();
    expect(() => parsePagination({ pageSize: 51 })).toThrow();
    expect(() => parsePagination({ page: Number.POSITIVE_INFINITY })).toThrow();
  });

  it("returns stable page metadata for empty and populated results", () => {
    expect(makePage([], 0, { page: 1, pageSize: 20 }).totalPages).toBe(0);
    expect(makePage(["a"], 41, { page: 2, pageSize: 20 })).toMatchObject({
      page: 2,
      total: 41,
      totalPages: 3,
    });
  });
});
