package main

type T struct{ a, b int }

func foo(t T)         { t.a = t.a + 1; t.b = t.b + 1 }
func bar(t *T, t int) { t.a = t.a + 1; t.b = t.b + 1 }

func main() {
	var variable_non_used int
}
