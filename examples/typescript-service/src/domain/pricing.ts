// The second breach: the domain imports the database schema.
import { orders } from "../db/schema";

export function pricedTable() {
  return orders;
}
