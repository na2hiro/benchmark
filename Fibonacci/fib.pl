fib(0, 1):-!.
fib(1, 1):-!.
fib(N, Fib):-
	N1 is N-1,
	N2 is N-2,
	fib(N1, FN1),
	fib(N2, FN2),
	Fib is FN1+FN2.

