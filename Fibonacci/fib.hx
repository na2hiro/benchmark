class Fib{
	static function fib(n: Int): Int{
		if(n==0||n==1) return 1;
		return fib(n-1)+fib(n-2);
	}
	static function main(){
		var n=40;
		trace("fib("+n+") = "+fib(n));
	}
}
