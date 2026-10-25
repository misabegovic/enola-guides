import { Order, type Line } from "../domain/order";
import { saveOrder } from "../db/orders";

export async function placeOrder(lines: Line[]) {
  const order = new Order(lines);
  await saveOrder(order.total());
  return { total: order.total() };
}
