use crate::order::Order;
use crate::store::save_order;

pub fn place_order(lines: Vec<(i64, i64)>) -> i64 {
    let total = Order::new(lines).total();
    save_order(total);
    total
}
