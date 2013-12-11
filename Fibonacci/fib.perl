sub fib{
	if(@_[0]==0||@_[0]==1){
		return 1;
	}
	return fib(@_[0]-1)+fib(@_[0]-2);
}
$n=40;
print("fib(".$n.") = ".fib($n));
