function fib(n)
  if n==0||n==1
    return 1
  end
  return fib(n-1)+fib(n-2)
end
n = 40
println("fib(", n, ") = ", fib(n))
