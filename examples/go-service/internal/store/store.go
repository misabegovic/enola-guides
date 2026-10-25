package store

import "database/sql"

var db *sql.DB

func SaveOrder(total int) {
	db.Exec("INSERT INTO orders (total) VALUES ($1)", total)
}

func RecentOrders() []int { return nil }

func LatestTotal() int { return 0 }
