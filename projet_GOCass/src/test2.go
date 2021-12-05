package main

import "fmt"

type S struct {
	c int
}

type T struct {
	a, b int
}

func main() {
	var r *int
	r = nil
	fmt.Print(r)
}
