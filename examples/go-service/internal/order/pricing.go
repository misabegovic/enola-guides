package order

import "example.com/shop/internal/store"

// The second breach: the domain imports the store.
func LastTotal() int {
	return store.LatestTotal()
}
