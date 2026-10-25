package checkout

import (
	"example.com/shop/internal/order"
	"example.com/shop/internal/store"
)

type Line = order.Line

func PlaceOrder(lines []Line) int {
	total := order.New(lines).Total()
	store.SaveOrder(total)
	return total
}
