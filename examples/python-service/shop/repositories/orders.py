from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class OrderRow(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True)
    sku = Column(String)

    @classmethod
    def latest_price(cls, sku):
        return 0


def save(order):
    return OrderRow()


def recent_orders():
    return []
