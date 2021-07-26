ifneq ($(shell command -v llvm-config-9 2> /dev/null),)
  LLVM_CONFIG = llvm-config-9
else ifneq ($(shell command -v llvm-config-12 2> /dev/null),)
  LLVM_CONFIG = llvm-config-12
else ifneq ($(shell command -v llvm-config-11 2> /dev/null),)
  LLVM_CONFIG = llvm-config-11
else ifneq ($(shell command -v llvm-config-10 2> /dev/null),)
  LLVM_CONFIG = llvm-config-10
else ifneq ($(shell command -v llvm-config 2> /dev/null),)
  LLVM_CONFIG = llvm-config
else
  $(error Unable to locate the LLVM toolchain. \
    Check your $$PATH or reinstall LLVM. Minimum supported LLVM version is 9)
endif

ifneq ($(shell command -v clang-format 2> /dev/null),)
  CLANG_FORMAT = clang-format
else
  $(error Please install clang-format)
endif

LLVM_VERSION := $(shell $(LLVM_CONFIG) --version | cut -d '.' -f 1)
ifeq ($(LLVM_VERSION), 12)
  LLVM_VRSN_FLAG = -DLLVM12
else ifeq ($(LLVM_VERSION), 11)
  LLVM_VRSN_FLAG = -DLLVM11
else ifeq ($(LLVM_VERSION), 10)
  LLVM_VRSN_FLAG = -DLLVM10
else ifeq ($(LLVM_VERSION), 9)
  LLVM_VRSN_FLAG = -DLLVM9
else
  $(error LLVM $(LLVM_VERSION) is not supported. Minimum supported LLVM version is 9)
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

SRC_DIR := $(shell pwd)
LIB_DIR = $(SRC_DIR)/../lib

COMMON_FLAGS = -g -Wall -Wextra -Wno-unused-parameter -Wno-implicit-fallthrough -fPIC
LDFLAGS += $(shell $(LLVM_CONFIG) --ldflags)
CXXFLAGS += $(COMMON_FLAGS) $(shell $(LLVM_CONFIG) --cxxflags)
CPPFLAGS += $(shell $(LLVM_CONFIG) --cppflags) -I$(SRC_DIR)

CI_PASS_OBJECT = CompilerInterrupt.o
CI_PASS = CompilerInterrupt.so

CI_LIB_OBJECT = ci_lib.o
CI_LIB_DYN = libci.so
CI_LIB_STATIC = libci.a

all: $(LIB_DIR)/$(CI_PASS) $(LIB_DIR)/$(CI_LIB_DYN) $(LIB_DIR)/$(CI_LIB_STATIC)

%.o: $(SRC_DIR)/%.cpp
	$(info Compiling $*.cpp)
	$(QUIET)$(CXX) $(LLVM_VRSN_FLAG) -c $(CPPFLAGS) $(CXXFLAGS) $<

$(LIB_DIR)/$(CI_PASS): $(CI_PASS_OBJECT)
	$(info Creating Compiler Interrupt Pass library $@)
	$(QUIET)$(CXX) -o $@ $(LOADABLE_MODULE_OPTIONS) $(CXXFLAGS) $(LDFLAGS) $^

%.o: $(SRC_DIR)/%.c
	$(info Compiling $*.c)
	$(QUIET)gcc -c -fPIC $< -o $@

$(LIB_DIR)/$(CI_LIB_DYN): $(CI_LIB_OBJECT)
	$(info Creating Compiler Interrupt API dynamic library $@)
	$(QUIET)gcc -shared $< -o $@

$(LIB_DIR)/$(CI_LIB_STATIC): $(CI_LIB_OBJECT)
	$(info Creating Compiler Interrupt API static library $@)
	$(QUIET)ar -rcs $@ $<

format:
	$(CLANG_FORMAT) -style=llvm -i $(wildcard *.cpp) $(wildcard *.c) $(wildcard *.h)

clean:
	$(QUIET)rm -f $(LIB_DIR)/$(CI_PASS) $(LIB_DIR)/$(CI_LIB_DYN) \
		$(LIB_DIR)/$(CI_LIB_STATIC) $(CI_PASS_OBJECT) $(CI_LIB_OBJECT)
