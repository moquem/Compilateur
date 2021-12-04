package main

import "fmt"

type S struct {
	c int
}

type T struct {
	a, b int
}

func main() {
	var var_unused = 5
	fmt.Print(var_unused)
	var_unused = 2
}
