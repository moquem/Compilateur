package main

type S struct {
	c int
}

type T struct {
	a, b int
}

func foo(t T) string { t.a = t.a + 1; t.b = t.b + 1; return 2 }

func main() {
}
