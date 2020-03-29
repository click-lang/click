# Click/src

This is the main directory for the source code of the Click compiler and tools. The structure should be pretty self-explanatory, but it breaks down as follows:

## backend
This directory contains the backend for the Click compiler - now since Click runs on a VM, the backend servers to translate the Click IR into YVM bytecode. 
The backend for the compiler is written using the nanopass framework.

## Front-end 
This section is very minimal. Since Click mainly uses s-expressions plus some special syntax, it harnesses Racket's reader in order to parse the source code, 
and from there pass it off to the backend. The front-end also performs the tasks of evaluating macros and doing some degree of type inference. While Click is a 
dynamically typed programming language, performing type inference is always a good way to get some performance boosts when possible. 

## lib
This directory contains the source code for the Click standard library. The standard library is written in Click. 

## tools 
This directory contains all the tools that you'll use to interface directly with the Click programming language, YVM, package manager, or anything else. The tools are 
written largely in Perl and Python since they operate well as glue between Racket and Rust while being cross platform.

## vm
This directory contains the source code for the YVM, the Yew Virtual Machine. The virtual machine is a bytecode interpreter meant to operate well with dynamic and 
functional programming languages.
