from shop.repositories.orders import OrderRow


def last_price(sku):
    # The breach the example exists to show: the domain reads a table.
    return OrderRow.latest_price(sku)
