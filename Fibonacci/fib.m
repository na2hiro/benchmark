#import <Foundation/Foundation.h>

int fib(int n){
    if(n == 0 || n == 1){
        return 1;
    }
    return fib(n - 1) + fib(n - 2);
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        int n = 40;
        NSLog(@"fib(%d) = %d\n", n, fib(n));
    }
}
