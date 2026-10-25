package web

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"

	"example.com/shop/internal/checkout"
	"example.com/shop/internal/store"
)

func Routes() http.Handler {
	r := chi.NewRouter()
	r.Post("/orders", createOrder)
	r.Get("/orders/recent", listRecent)
	return r
}

func createOrder(w http.ResponseWriter, req *http.Request) {
	var lines []checkout.Line
	json.NewDecoder(req.Body).Decode(&lines)
	json.NewEncoder(w).Encode(checkout.PlaceOrder(lines))
}

// The breach the example exists to show: a handler reads the store
// without going through the application layer.
func listRecent(w http.ResponseWriter, req *http.Request) {
	json.NewEncoder(w).Encode(store.RecentOrders())
}
