import { orders } from "./schema";

export async function saveOrder(total: number) {
  return { table: orders, total };
}

export async function recentOrders() {
  return [{ table: orders }];
}
