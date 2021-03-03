# CompilerInterrupts
This is a framework for compiling programs with instrumentation such that they can call user-specified code at fixed intervals during the program's run time.

# First Step: Build & Setup
a. To build Compiler Interrupt transformation pass, and its helper library, run: 
  cd src; make; cd ../
  (The generated libraries will be exported to ./lib path)
b. For creating experiment related setup:
  cd src; ./setup.sh; cd ../

# Benchmarks
For running all experiments, run ./benchmarks/experiments.sh. It will take many hours. One can run each experiment individually from the script too.

1. Accuracy & overhead Benchmarks

2. Application in Server Delegation

