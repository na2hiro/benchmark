let rec fib n = if n=0 || n=1 then 1 else fib (n-1) + fib(n-2) in

let n = 40 in Printf.printf "fib(%d) = %d\n" n (fib n)
