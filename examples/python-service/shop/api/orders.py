from fastapi import APIRouter

from shop.repositories.orders import recent_orders
from shop.services.checkout import place_order

router = APIRouter(prefix="/orders")


@router.post("")
def create_order(payload: dict):
    return place_order(payload["lines"])


# The breach the example exists to show: a route reads the database
# without going through the application layer.
@router.get("/recent")
def list_recent():
    return recent_orders()
