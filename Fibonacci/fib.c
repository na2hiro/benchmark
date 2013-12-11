#include<stdio.h>

void main(){
	int n=40;
	printf("fib(%d) = %d\n", n, fib(n));
}

int fib(int n){
	if(n==0 || n==1){
		return 1;
	}
	return fib(n-1)+fib(n-2);
}
