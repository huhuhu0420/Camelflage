# Camelflage

This is not a hat; it is a camel swallowed by a python.

![Camelflage](./images/camelflage.png)

## Description

Camelflage is a compiler written in Ocaml that compiles Mini-Python.

The syntax and semantics of Mini-Python are defined in [Mini-Python](./mini-python.pdf)

The program will take a Mini-Python program as input and parse it to AST, then generate the corresponding IR code using `LLVM`. Next, the program will compile the IR code to assembly code using `llc` and finally generate an executable file by using `gcc`.

```
Mini-Python -> AST -> Typed AST -> IR -> Assembly -> Executable -> Output
```

## Environment

- Ocaml 4.14.0
- LLVM 14

## Test

To test the compiler, run the following command:

```bash
chmod +x tests-mini-python/test
make test
```

or

```bash
docker-compose up
```

The result of the test will be displayed in the terminal.

```bash
Testing ../minipython.exe

Part 1 (parsing)
bad ................................
good .........................................................................
Parsing: 105/105 : 100%
Part 2 (type checking)
bad ..............
good ..................................................
Typing: 64/64 : 100%
Part 3 (code generation)
Execution with no runtime error
-------------------------------
.........................................
Execution with a runtime error
------------------------------
.......
Compilation:
Compilation: 48/48 : 100%
Code behavior: 48/48 : 100%
Expected output: 48/48 : 100%
```
