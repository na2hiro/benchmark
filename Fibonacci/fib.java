class fib{
	static int fib(int n){
		if(n==0|n==1){
			return 1;
		}
		return fib(n-1)+fib(n-2);
	}
	public static void main(String[] args){
		int n = 40;
		System.out.printf("fib(%d) = %d\n", n, fib(n));
	}
}
