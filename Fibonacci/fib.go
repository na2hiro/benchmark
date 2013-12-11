package main

import "fmt"

func fib(n int) int{
	if n==0 || n==1{
		return 1
	}
	return fib(n-1)+fib(n-2)
}

func main(){
	var n int = 40
	fmt.Printf("fib(%d) = %d\n", n, fib(n))
}
