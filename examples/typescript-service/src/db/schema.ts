import { integer, pgTable, serial } from "drizzle-orm/pg-core";

export const orders = pgTable("orders", {
  id: serial("id").primaryKey(),
  total: integer("total").notNull(),
});
