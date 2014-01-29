Integer fib(Integer n){
	if(n==0||n==1){ return 1; }
	return fib(n-1)+fib(n-2);
}

shared void main(){
	value n=40;
	print("fib(``n``) = ``fib(n)``");
}
