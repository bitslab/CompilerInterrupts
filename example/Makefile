CC := clang-9
OPT := opt-9

CI_ROOT := $(shell pwd)/../
CI_LIB_HOME := $(CI_ROOT)/lib
CI_PASS = $(CI_LIB_HOME)/CompilerInterrupt.so
CI_LIB = $(CI_LIB_HOME)/libci.so
INC = -I$(CI_ROOT)/src/

all: orig_demo ci_demo

orig_demo: $(CI_LIB)
	$(CC) demo.c $(INC) -L$(CI_LIB_HOME) -Wl,-rpath=$(CI_LIB_HOME) -o $@ -lpthread -lci

ci_demo: ci_demo.ll $(CI_LIB)
	$(CC) $(INC) -L$(CI_LIB_HOME) -Wl,-rpath=$(CI_LIB_HOME) -g $< -o $@ -lpthread -lci

ci_demo.ll: opt_demo.ll
	$(OPT) -load $(CI_PASS) -S -logicalclock -clock-type 1 -config 2 -inst-gran 2 -all-dev 100 -push-intv 1000 -commit-intv 1000 -mem-ops-cost 1 < $< > $@

opt_demo.ll: ir_demo.ll
	$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@

ir_demo.ll: demo.c
	$(CC) $(INC) -g -S -emit-llvm -o $@ $<

clean:
	rm -f orig_demo ci_demo *.ll
