# CompilerInterrupts
This is a framework for compiling programs with instrumentation such that they can call user-specified code at fixed intervals during the program's run time.

# First Step: Build & Setup
a. To build Compiler Interrupt transformation pass, and its helper library, run: 
  cd src; make; cd ../
  (The generated libraries will be exported to ./lib path)
b. For creating experiment related setup:
  cd src; ./setup.sh; cd ../

# Benchmarks
1. Accuracy & overhead Benchmarks
  a. Unzip the inputs & put them at the right location

2. Application in Server Delegation
  a. To build and run experiments:
    pushd ./benchmarks/server_delegation/
    ./fetch-n-add.sh
    ./client-req-latency.sh
    popd

   Generated results will be exported in ./benchmarks/server_delegation/exp_results and the plots will be exported in ./benchmarks/server_delegation/plots
   Both experiments approximately take an hour to run.

