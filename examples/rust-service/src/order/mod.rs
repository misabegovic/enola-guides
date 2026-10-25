mod pricing;

pub struct Order {
    lines: Vec<(i64, i64)>,
}

impl Order {
    pub fn new(lines: Vec<(i64, i64)>) -> Self {
        Order { lines }
    }

    pub fn total(&self) -> i64 {
        self.lines.iter().map(|(price, quantity)| price * quantity).sum()
    }
}
