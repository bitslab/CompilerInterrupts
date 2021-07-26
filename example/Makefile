ifneq ($(shell command -v llvm-config-9 2> /dev/null),)
  VERSION=-9
else ifneq ($(shell command -v llvm-config-12 2> /dev/null),)
  VERSION=-12
else ifneq ($(shell command -v llvm-config-11 2> /dev/null),)
  VERSION=-11
else ifneq ($(shell command -v llvm-config-10 2> /dev/null),)
  VERSION=-10
else ifneq ($(shell command -v llvm-config 2> /dev/null),)
  VERSION=
else
  $(error Unable to locate the LLVM toolchain for supported versions 9-12)
endif

LLVM_CONFIG = llvm-config$(VERSION)
LLVM_LINK = llvm-link$(VERSION)
OPT = opt$(VERSION)

ifneq ($(shell command -v clang$(VERSION) 2> /dev/null),)
  CC = clang$(VERSION)
else
  $(error Please install clang$(VERSION))
endif

ifneq ($(shell command -v clang-format 2> /dev/null),)
  CLANG_FORMAT = clang-format
else
  $(error Please install clang-format)
endif

LLVM_VERSION := $(shell $(LLVM_CONFIG) --version | cut -d '.' -f 1)

ifeq ($(shell uname), Darwin)
  LOADABLE_MODULE_OPTIONS = -bundle -undefined dynamic_lookup
else
  LOADABLE_MODULE_OPTIONS = -shared -O1
endif

ifndef VERBOSE
  QUIET := @
endif

CI_ROOT := $(shell pwd)/../
CI_LIB_HOME := $(CI_ROOT)/lib
CI_PASS := $(CI_LIB_HOME)/CompilerInterrupt.so
CI_LIB := $(CI_LIB_HOME)/libci.so
INC := -I$(CI_ROOT)/src

# CI configuration
export CI_TYPE ?= 2
export PROBE_INTV ?= 100
export LIBCOST ?= 100
CI_CONFIG = -load $(CI_PASS) -logicalclock -inst-gran=$(CI_TYPE) -commit-intv=$(PROBE_INTV) -all-dev=$(LIBCOST)
DEPENDENCY_CONFIG = -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution

all: orig_demo ci_demo ci_mult_files ci_modularity_demo ci_profiler
	$(info Using LLVM $(LLVM_VERSION) toolchain)

# unmodified run of a demo program
orig_demo: demo.c $(CI_LIB)
	$(QUIET)$(CC) demo.c $(INC) -L$(CI_LIB_HOME) -Wl,-rpath,$(CI_LIB_HOME) -o $@ -lpthread -lci


# ci-based run of a demo program
ci_demo: ci_demo.ll $(CI_LIB)
	$(QUIET)$(CC) $(INC) -L$(CI_LIB_HOME) -Wl,-rpath,$(CI_LIB_HOME) -g $< -o $@ -lpthread -lci

ci_demo.ll: opt_demo.ll
	$(QUIET)$(OPT) -S $(CI_CONFIG) < $< > $@

opt_demo.ll: ir_demo.ll
	$(QUIET)$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@


# CI-based run of a demo program with multiple source files
ci_mult_files: ci_mult_files.ll $(CI_LIB)
	$(QUIET)$(CC) $(INC) -L$(CI_LIB_HOME) -Wl,-rpath,$(CI_LIB_HOME) -g $< -o $@ -lpthread -lci

ci_mult_files.ll: opt_mult_files.ll
	$(QUIET)$(OPT) -S $(CI_CONFIG) < $< > $@

opt_mult_files.ll: combined_mult_files.ll
	$(QUIET)$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@

combined_mult_files.ll: ir_demo_mult_files.ll ir_utility_func.ll
	$(QUIET)$(LLVM_LINK) $^ -o $@


# modularity example: CI-based run of a demo prgram using a CI-instrumented library
# by individually compiling each component
ci_modularity_demo: ci_demo_mult_files.ll libutility.so $(CI_LIB)
	$(QUIET)$(CC) $(INC) -L./ -L$(CI_LIB_HOME) -Wl,-rpath,./ -Wl,-rpath,$(CI_LIB_HOME) -g $< -o $@ -lpthread -lci -lutility

libutility.so: ci_utility_func.ll
	$(QUIET)$(CC) $(LOADABLE_MODULE_OPTIONS) -fPIC $< -o $@


# profiler: check the cycle interval achieved for a given IR interval
ci_profiler: ci_profiler.ll
	$(QUIET)$(CC) $(INC) -L$(CI_LIB_HOME) -Wl,-rpath,$(CI_LIB_HOME) -g $< -o $@ -lpthread -lci


# run the CI pass
ci_%.ll: opt_%.ll
	$(QUIET)$(OPT) -S $(CI_CONFIG) < $< > $@

# run dependency passes on the IR
opt_%.ll: ir_%.ll
	$(QUIET)$(OPT) -S $(DEPENDENCY_CONFIG) < $< > $@

# compile all C files to LLVM IR
ir_%.ll: %.c
	$(QUIET)$(CC) $(INC) -g -S -emit-llvm -o $@ $< # use -fno-discard-value-names to keep meaningful variable names for debugging


# for the developers
format:
	$(CLANG_FORMAT) -style=llvm -i $(wildcard *.c) $(wildcard *.h)


# clean
clean:
	$(QUIET)rm -f orig_demo ci_demo ci_mult_files ci_modularity_demo ci_profiler libutility.so *.ll
	$(QUIET)rm -rf *.dSYM
