class Order:
    def __init__(self, lines):
        self.lines = lines

    def total(self):
        return sum(line["price"] * line["quantity"] for line in self.lines)
