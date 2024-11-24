
all: minipython.exe
	./minipython.exe --debug test.py
	gcc -no-pie -g test.s && ./a.out

debug: minipython.exe
	./minipython.exe --debug test.py

llvm: minipython.exe
	llc-16 test.ll -o test.s
	gcc -no-pie -g test.s && ./a.out

minipython.exe:
	dune build minipython.exe

clean:
	dune clean

.PHONY: all clean minipython.exe



