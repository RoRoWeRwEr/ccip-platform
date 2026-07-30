import { z } from "zod";

export const DEFAULT_PAGE_SIZE = 20;
export const MAX_PAGE_SIZE = 50;

const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).max(10_000).default(1),
  pageSize: z.coerce
    .number()
    .int()
    .min(1)
    .max(MAX_PAGE_SIZE)
    .default(DEFAULT_PAGE_SIZE),
});

export type Pagination = z.infer<typeof paginationSchema>;

export function parsePagination(input: {
  page?: unknown;
  pageSize?: unknown;
}): Pagination {
  return paginationSchema.parse(input);
}

export function toRange(pagination: Pagination) {
  const from = (pagination.page - 1) * pagination.pageSize;
  return { from, to: from + pagination.pageSize - 1 };
}

export interface Page<T> {
  items: T[];
  page: number;
  pageSize: number;
  total: number;
  totalPages: number;
}

export function makePage<T>(
  items: T[],
  count: number | null,
  pagination: Pagination,
): Page<T> {
  const total = count ?? items.length;
  return {
    items,
    page: pagination.page,
    pageSize: pagination.pageSize,
    total,
    totalPages: total === 0 ? 0 : Math.ceil(total / pagination.pageSize),
  };
}
