# CompilerInterrupts
This is a framework for compiling programs with instrumentation such that they can call user-specified code at fixed intervals during the program's run time.

# First Step: Build & Setup
a. To build Compiler Interrupt transformation pass, and its helper library, run: 
  cd src; make; cd ../
  (The generated libraries will be exported to ./lib path)
b. For creating experiment related setup:
  cd src; ./setup.sh; cd ../


# Compiler Interrupts framework
  a. An analysis & transformation pass (CompilerInterrupt.so) to be run with LLVM's opt at the time of compilation
  b. An intermediate library (libci.so) to be linked with the application - provides the user with API to register interrupt handlers, enable or disable them

  The sources for both are in src/ directory. libci.so is a simple library built from ci_lib.* files and the api names are self-explanatory. The Compiler Interrupt pass is built from CompilerInterrupt.cpp, which is complex, and the code starts at runOnModule() function. This file has explanatory comments, but they are probably not at a level (yet) that can be easily deciphered by someone unacquainted with this.

# Benchmarks
a. MTCP experiments (path: benchmarks/mtcp)
b. Shenango experiments (path: benchmarks/shenango, benchmarks/cpuminer-multi/)
c. Server delegation experiments (path: benchmarks/server_delegation)
d. Accuracy & Overhead experiments (path: benchmarks/accuracy_and_overhead)
