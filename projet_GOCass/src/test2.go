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
	var x T
	x.a = 3
	_ := "coucou"
	_ := "baaah"
	z := 3
	_, x.b = 3, 2
	foo(x)
	fmt.Print(z)
}
