
all: minipython.exe
	./minipython.exe --debug test.py
	llc-14 test.ll -o test.s
	gcc -no-pie -g test.s && ./a.out

type: minipython.exe
	./minipython.exe --debug --type-only test.py

parse: minipython.exe
	./minipython.exe --debug --parse-only test.py

minipython.exe:
	dune build minipython.exe

clean:
	dune clean

.PHONY: all clean minipython.exe



