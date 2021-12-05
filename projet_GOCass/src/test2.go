package main

import "fmt"

type S struct {
	c int
}

type T struct {
	a, b int
}

func foo(t T, t int) { t.a = t.a + 1; t.b = t.b + 1 }

func main() {
	var r *int
	r = nil
	fmt.Print(r)
}
