ifneq ($(shell command -v llvm-config-12 2> /dev/null),)
  LLVM_CONFIG = llvm-config-12
  LLVM_LINK = llvm-link-12
  CC = clang-12
  OPT = opt-12
else ifneq ($(shell command -v llvm-config-9 2> /dev/null),)
  LLVM_CONFIG = llvm-config-9
  LLVM_LINK = llvm-link-9
  CC = clang-9
  OPT = opt-9
else ifneq ($(shell command -v llvm-config 2> /dev/null),)
  LLVM_CONFIG = llvm-config
  LLVM_LINK = llvm-link
  CC = clang
  OPT = opt
else
  $(error Unable to locate the LLVM toolchain. \
    Check your $$PATH or reinstall LLVM. Supported LLVM versions are 9 and 12)
endif

ifneq ($(shell command -v clang-format 2> /dev/null),)
  CLANG_FORMAT = clang-format
else
  CLANG_FORMAT = -clang-format # ignore error
endif

LLVM_VERSION := $(shell $(LLVM_CONFIG) --version | cut -d '.' -f 1)
ifeq ($(LLVM_VERSION), 12)
  ifneq ($(shell command -v clang-format-12 2> /dev/null),)
    CLANG_FORMAT = clang-format-12
  endif
else ifeq ($(LLVM_VERSION), 9)
  LLVM_VRSN_FLAG = -DLLVM9
  ifneq ($(shell command -v clang-format-9 2> /dev/null),)
    CLANG_FORMAT = clang-format-9
  endif
else
  $(error LLVM $(LLVM_VERSION) is not officialy supported. Supported LLVM versions are 9 and 12)
endif

$(info Found LLVM $(LLVM_VERSION) toolchain)

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

all: orig_demo ci_demo ci_mult_files ci_modularity_demo

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
ci_modularity_demo: ci_demo_mult_files.ll libutility.so $(CI_LIB)
	$(QUIET)$(CC) $(INC) -L./ -L$(CI_LIB_HOME) -Wl,-rpath,./ -Wl,-rpath,$(CI_LIB_HOME) -g $< -o $@ -lpthread -lci -lutility

libutility.so: ci_utility_func.ll
	$(QUIET)$(CC) $(LOADABLE_MODULE_OPTIONS) -fPIC $< -o $@

ci_%.ll: opt_%.ll
	$(QUIET)$(OPT) -S $(CI_CONFIG) < $< > $@

opt_%.ll: ir_%.ll
	$(QUIET)$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@

# compile all C files to LLVM IR
ir_%.ll: %.c
	$(QUIET)$(CLANG_FORMAT) -style=llvm -i $(wildcard *.c) $(wildcard *.h)
	$(QUIET)$(CC) $(INC) -g -S -emit-llvm -o $@ $<

# clean
clean:
	$(QUIET)rm -f orig_demo ci_demo ci_mult_files ci_modularity_demo *.ll
	$(QUIET)rm -rf *.dSYM
