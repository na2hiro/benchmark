#include<stdio.h>

int fib(int n){
	if(n==0||n==1){
		return 1;
	}
	return fib(n-1)+fib(n-2);
}
int main(int argc, char* argv[]){
	int n=40;
	printf("fib(%d) = %d\n", n, fib(n));
}
