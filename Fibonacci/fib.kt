fun main(args : Array<String>) {
  val n : Int = 40;
  println("fib(${n}) = ${fib(n)}");
}

fun fib(n: Int): Int{
  if(n==0||n==1) return 1;
  return fib(n-1)+fib(n-2);
}
