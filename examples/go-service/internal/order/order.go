package order

type Line struct {
	Price    int
	Quantity int
}

type Order struct{ lines []Line }

func New(lines []Line) Order { return Order{lines: lines} }

func (o Order) Total() int {
	sum := 0
	for _, line := range o.lines {
		sum += line.Price * line.Quantity
	}
	return sum
}
