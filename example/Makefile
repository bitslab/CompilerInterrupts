ifeq ($(shell which llvm-config-12),)
  ifeq ($(shell which llvm-config-9),)
    ifeq ($(shell which llvm-config),)
      $(error Unable to locate the LLVM toolchain. \
        Check your $$PATH or reinstall. Supported LLVM versions are 9 and 12)
    else
      LLVM_CONFIG = llvm-config
      CLANG_FORMAT = clang-format
      CC = clang
      OPT = opt
      LLVM_LINK = llvm-link
    endif
  else
    LLVM_CONFIG = llvm-config-9
    CLANG_FORMAT = clang-format-9
    CC = clang-9
    OPT = opt-9
    LLVM_LINK = llvm-link-9
  endif
else
  LLVM_CONFIG = llvm-config-12
  CLANG_FORMAT = clang-format-12
  CC = clang-12
  OPT = opt-12
  LLVM_LINK = llvm-link-12
endif

LLVM_VERSION := $(shell $(LLVM_CONFIG) --version | cut -d '.' -f 1)
ifeq ($(LLVM_VERSION), 12)
else ifeq ($(LLVM_VERSION), 9)
else
  $(error LLVM $(LLVM_VERSION) is not supported. Supported LLVM versions are 9 and 12)
endif

$(info Found LLVM $(LLVM_VERSION) toolchain)

ifeq ($(shell uname), Darwin)
  LOADABLE_MODULE_OPTIONS = -bundle -undefined dynamic_lookup
else
  LOADABLE_MODULE_OPTIONS = -shared -O1
endif

CI_ROOT := $(shell pwd)/../
CI_LIB_HOME := $(CI_ROOT)/lib
CI_PASS := $(CI_LIB_HOME)/CompilerInterrupt.so
CI_LIB := $(CI_LIB_HOME)/libci.so
INC := -I$(CI_ROOT)/src/

# CI configuration
export CI_TYPE ?= 2
export PROBE_INTV ?= 100
export LIBCOST ?= 100
CI_CONFIG = -load $(CI_PASS) -compilerinterrupt -inst-gran $(CI_TYPE) -commit-intv $(PROBE_INTV) -all-dev $(LIBCOST)

all: orig_demo ci_demo ci_mult_files ci_modularity_demo

# unmodified run of a demo program
orig_demo: demo.c $(CI_LIB)
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
	$(CC) $(LOADABLE_MODULE_OPTIONS) -fPIC $< -o $@

ci_%.ll: opt_%.ll
	$(OPT) -S $(CI_CONFIG) < $< > $@

opt_%.ll: ir_%.ll
	$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@

# compile all C files to LLVM IR
ir_%.ll: %.c
	$(CLANG_FORMAT) -style=llvm -i $(wildcard *.c) $(wildcard *.h)
	$(CC) $(INC) -g -S -emit-llvm -o $@ $<

# clean
clean:
	rm -f orig_demo ci_demo ci_mult_files ci_modularity_demo *.ll
	rm -rf *.dSYM
