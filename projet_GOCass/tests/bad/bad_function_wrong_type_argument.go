package main

type S struct {
	c int
}

type T struct {
	a, b int
}

func foo(t T, s V) { t.a = t.a + 1; t.b = t.b + 1 }

func main() {
}
