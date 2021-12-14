package main

import "fmt"

type S struct {
	c T
}

type T struct {
	a, b int
}

func foo(t T) { t.a = t.a + 1; t.b = t.b + 1 }

func main() {
	var _ T
	var a T
	a.a = 3
	a.b = 5
	foo(a)
	fmt.Print(a.b, a.a)
}
