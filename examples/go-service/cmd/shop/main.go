package main

import (
	"net/http"

	"example.com/shop/internal/web"
)

func main() {
	http.ListenAndServe(":8080", web.Routes())
}
