# Hello example
This project shows basic setup of components using languages defined
in `nedryglot`.

All the headings below corresponds to the attributes to use when using
`nix build` or `nix-shell`.

## numpyWrapper
This python library creates a function that returns an array. This
wrapper is used in `hello`.

## pythonHello
Hello is a simple python client to print HELLO and some numbers. A
python client will build to a binary available after a `nix build -f
default.nix pythonHello` in `result/bin/hello`.

pythonHello also has a sub component called `nested`.

## pythonHelloExt
Is the same thing as pythonHello but it uses a base extension for
declaration.

## shellSetup
Sample of the interactive shell. When you enter the shell you can
generate some defaults for the python project.

## baseRust, windowsRust and crossRust
Three rust components that show different ways of setting up cross
compilation (baseRust is not cross compiled).

