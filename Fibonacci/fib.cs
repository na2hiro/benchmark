class FibBench{
	static int fib(int n){
		if(n==0 || n==1){
			return 1;
		}
		return fib(n-1)+fib(n-2);
	}
	static void Main(){
		int n=40;
		System.Console.WriteLine("fib("+n+") = "+fib(n));
	}
}
