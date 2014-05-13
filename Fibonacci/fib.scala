object Fib{
	def main(args: Array[String]){
		val n=40
		println("fib("+n+") = "+fib(n))
	}
	def fib(n: Int): Int = {
		if(n==0||n==1)
			1
		else
			fib(n-1)+fib(n-2)
	}
}
