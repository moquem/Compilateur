package main

import "fmt"

type T struct {
	x, y int
}

func main() {
	t := new(T)
	fmt.Print("coucou\n")
	fmt.Print(t.y)
	fmt.Print("coucou")
	fmt.Print("\n")
	t.x = 1
	p := &t.x
	fmt.Print(*p)
	fmt.Print("\n")
	*p = 2
	fmt.Print(*p)
	fmt.Print("\n")
}
