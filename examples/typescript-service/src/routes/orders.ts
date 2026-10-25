import { Router } from "express";
import type { Request, Response } from "express";
import { placeOrder } from "../services/checkout";
import { recentOrders } from "../db/orders";

export async function createOrder(req: Request, res: Response) {
  res.json(await placeOrder(req.body.lines));
}

// The breach the example exists to show: a route reads the database
// without going through the application layer.
export async function listRecent(_req: Request, res: Response) {
  res.json(await recentOrders());
}

export const ordersRouter = Router();
ordersRouter.post("/", createOrder);
ordersRouter.get("/recent", listRecent);
