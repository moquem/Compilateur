package main
import "fmt"

func sum(n int) int {
	res := 0;
	for i := 0; i <= n; i++ {
		res = res + i;
	}
	return res
}

func main () {
	fmt.Print(sum(10));
	fmt.Print("\n");
}
