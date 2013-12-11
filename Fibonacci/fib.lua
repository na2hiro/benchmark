function fib(n)
	if n==0 or n==1 then
		return 1
	end
	return fib(n-1)+fib(n-2)
end
n=40
print("fib("..n..") = "..fib(n))
