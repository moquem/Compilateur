package main

type S struct {
	c T
}

type T struct {
	a, b S
}

func foo(t T) { t.a = t.a + 1; t.b = t.b + 1 }

func main() {
	var x T
	x.a = 3
	x.b = 3
	foo(x)
}
