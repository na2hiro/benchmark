function fib(n){
	if(n==0||n==1){
		return 1;
	}
	return fib(n-1)+fib(n-2);
}
var n=40;
console.log("fib("+n+") = "+fib(n));
