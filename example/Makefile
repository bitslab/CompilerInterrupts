CC := clang-9
OPT := opt-9

CI_LIB_HOME := $(shell pwd)/../lib
CI_PASS = $(CI_LIB_HOME)/CompilerInterrupt.so
CI_LIB = $(CI_LIB_HOME)/libci.so
INC = -I../src/

all: gcc_demo ci_llvm_demo

gcc_demo: $(CI_LIB)
	gcc demo.c $(INC) -L$(CI_LIB_HOME) -Wl,-rpath=$(CI_LIB_HOME) -o gcc_demo -lpthread -lci

ci_llvm_demo: $(CI_LIB) ci_demo.ll
	$(CC) $(INC) -L$(CI_LIB_HOME) -Wl,-rpath=$(CI_LIB_HOME) -g ci_demo.ll -o $@ -lpthread -lci

ci_demo.ll: opt_demo.ll
	$(OPT) -load $(CI_PASS) -S -logicalclock -clock-type 1 -config 2 -inst-gran 2 -all-dev 100 -push-intv 1000 -commit-intv 1000 -mem-ops-cost 1 < $< > $@

opt_demo.ll: ir_demo.ll
	$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@

ir_demo.ll: demo.c
	#$(CC) $(INC) -fno-discard-value-names -g -S -emit-llvm -o $@ $<
	$(CC) $(INC) -g -S -emit-llvm -o $@ $<

libci.so: ci_lib.o
	gcc -shared $< -o $@

ci_lib.o: ci_lib.c ci_lib.h
	gcc -c -fPIC $< -o $@

clean:
	rm -f gcc_demo ci_llvm_demo *.so *.ll
