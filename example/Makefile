ifeq ($(shell uname), Darwin)
CC := clang
OPT := opt
LLVM_LINK := llvm-link
else
CC := clang-12
OPT := opt-12
LLVM_LINK := llvm-link-12
endif

CI_ROOT := $(shell pwd)/../
CI_LIB_HOME := $(CI_ROOT)/lib
CI_PASS = $(CI_LIB_HOME)/CompilerInterrupt.so
CI_LIB = $(CI_LIB_HOME)/libci.so
INC = -I$(CI_ROOT)/src/

# CI configuration
export CI_TYPE ?= 2
export PROBE_INTV ?= 100
export LIBCOST ?= 100
CI_CONFIG=-load $(CI_PASS) -logicalclock -inst-gran $(CI_TYPE) -commit-intv $(PROBE_INTV) -all-dev $(LIBCOST)


all: clang_format orig_demo ci_demo ci_mult_files ci_modularity_demo

# clang-format
clang_format:
	clang-format -i demo.c
	clang-format -i demo_mult_files.c
	clang-format -i utility_func.c
	clang-format -i utility_func.h


# unmodified run of a demo program
orig_demo: $(CI_LIB)
	$(CC) demo.c $(INC) -L$(CI_LIB_HOME) -Wl,-rpath,$(CI_LIB_HOME) -o $@ -lpthread -lci


# ci-based run of a demo program
ci_demo: ci_demo.ll $(CI_LIB)
	$(CC) $(INC) -L$(CI_LIB_HOME) -Wl,-rpath,$(CI_LIB_HOME) -g $< -o $@ -lpthread -lci

ci_demo.ll: opt_demo.ll
	$(OPT) -S $(CI_CONFIG) < $< > $@

opt_demo.ll: ir_demo.ll
	$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@


# ci-based run of a demo prgram with multiple source files
ci_mult_files: ci_mult_files.ll $(CI_LIB)
	$(CC) $(INC) -L$(CI_LIB_HOME) -Wl,-rpath,$(CI_LIB_HOME) -g $< -o $@ -lpthread -lci

ci_mult_files.ll: opt_mult_files.ll
	$(OPT) -S $(CI_CONFIG) < $< > $@

opt_mult_files.ll: combined_mult_files.ll
	$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@

combined_mult_files.ll: ir_demo_mult_files.ll ir_utility_func.ll
	$(LLVM_LINK) $^ -o $@


# modularity example: ci-based run of a demo prgram using a ci-instrumented library
ci_modularity_demo: ci_demo_mult_files.ll libutility.so $(CI_LIB)
	$(CC) $(INC) -L./ -L$(CI_LIB_HOME) -Wl,-rpath,./ -Wl,-rpath,$(CI_LIB_HOME) -g $< -o $@ -lpthread -lci -lutility

libutility.so: ci_utility_func.ll
	$(CC) -shared -fPIC $< -o $@

ci_%.ll: opt_%.ll
	$(OPT) -S $(CI_CONFIG) < $< > $@

opt_%.ll: ir_%.ll
	$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@


# compile all C files to LLVM IR
ir_%.ll: %.c
	$(CC) $(INC) -g -S -emit-llvm -o $@ $<


clean:
	rm -f orig_demo ci_demo ci_mult_files ci_modularity_demo *.ll
