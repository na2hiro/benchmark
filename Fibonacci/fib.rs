fn main() {
    let n = 40;
    println!("fib({}) = {}", n, fib(n));
}

fn fib(n: u8) -> u64 {
    match n {
        0 | 1 => 1,
        n => fib(n - 1) + fib(n - 2),
    }
}