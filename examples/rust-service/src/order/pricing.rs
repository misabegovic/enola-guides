// The second breach: the domain uses the store.
use crate::store::latest_total;

pub fn last_total() -> i64 {
    latest_total()
}
