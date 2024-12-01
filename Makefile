
all: minipython.exe
	./minipython.exe --debug test.py
	gcc -no-pie -g test.s && ./a.out

type: minipython.exe
	./minipython.exe --debug --type-only test.py

ir: minipython.exe
	./minipython.exe --debug --ir-only test.py
	llc-14 test.ll -o test.s
	./a.out

llvm: minipython.exe
	llc-16 test.ll -o test.s
	gcc -no-pie -g test.s && ./a.out

minipython.exe:
	dune build minipython.exe

clean:
	dune clean

.PHONY: all clean minipython.exe



