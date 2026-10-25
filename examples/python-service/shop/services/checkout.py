from shop.domain.order import Order
from shop.repositories.orders import save


def place_order(lines):
    order = Order(lines)
    save(order)
    return {"total": order.total()}
