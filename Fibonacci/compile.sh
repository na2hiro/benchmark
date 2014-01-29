gcc -O3 -o out/fib_c fib.c
g++ -O3 -o out/fib_cpp fib.cpp
mcs fib.cs -o+ -out:out/fib_cs.exe
go build -o out/fib_go fib.go
rm fib.o; ghc -O -o out/fib_hs fib.hs
javac -d out fib.java

~/src/kotlinc/bin/kotlinc-jvm fib.kt -output out
luac52 -o out/fib_lua fib.lua
ocamlopt -o out/fib_ml fib.ml






~/src/ceylon/bin/ceylon compile-js --source . default
haxe fib_js.hxml 
haxe fib_cpp.hxml 
tsc --out fib_ts.js fib.ts
