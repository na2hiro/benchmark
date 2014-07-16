func fib(n: Int) -> Int{
    if(n == 0 || n == 1){
        return 1
    }
    return fib ( n - 1 ) + fib ( n - 2 )
}
var n = 40

println("fib(\(n)) = \(fib(n))")