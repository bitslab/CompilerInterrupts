#!/bin/bash

read -p "Have you replaced the path with your path?: " opt
if [ $opt -eq 0 ]; then
  exit
fi
sed -i 's/logicalclock\/ci-llvm-v9\/test-suite/CompilerInterrupts\/benchmarks/' Makefile.lc
sed -i 's/logicalclock\/ci-llvm-v9\/test-suite/CompilerInterrupts\/benchmarks/' Makefile.orig
