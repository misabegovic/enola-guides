use axum::{routing::get, routing::post, Json, Router};

use crate::checkout::place_order;
use crate::store::recent_orders;

pub fn router() -> Router {
    Router::new().nest("/orders", orders())
}

fn orders() -> Router {
    Router::new()
        .route("/", post(create_order))
        .route("/recent", get(list_recent))
}

async fn create_order(Json(lines): Json<Vec<(i64, i64)>>) -> Json<i64> {
    Json(place_order(lines))
}

// The breach the example exists to show: a handler reads the store
// without going through the application layer.
async fn list_recent() -> Json<Vec<i64>> {
    Json(recent_orders())
}
