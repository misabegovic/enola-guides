export type Line = { price: number; quantity: number };

export class Order {
  constructor(private readonly lines: Line[]) {}

  total(): number {
    return this.lines.reduce((sum, line) => sum + line.price * line.quantity, 0);
  }
}
