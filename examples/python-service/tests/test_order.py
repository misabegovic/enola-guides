from shop.domain.order import Order


def test_total():
    assert Order([{"price": 2, "quantity": 3}]).total() == 6
