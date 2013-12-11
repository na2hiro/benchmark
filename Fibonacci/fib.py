def fib(n):
	if n==0 or n==1:
		return 1
	return fib(n-1)+fib(n-2)

if __name__ == '__main__':
	n=40
	print "fib(%d) = %d" % (n, fib(n))
