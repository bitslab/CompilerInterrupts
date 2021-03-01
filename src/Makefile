LLVM_CONFIG=llvm-config-9
#LLVM_CONFIG=/mnt/nilanjana/bin/llvm-config

ifndef VERBOSE
	QUIET:=@
endif
QUIET:=@

SRC_DIR?=$(PWD)
LIB_DIR=$(SRC_DIR)/../lib
LDFLAGS+=$(shell $(LLVM_CONFIG) --ldflags)
COMMON_FLAGS=-g -Wall -Wextra -Wno-unused-parameter -Wno-implicit-fallthrough -fPIC
CXXFLAGS+=$(COMMON_FLAGS) $(shell $(LLVM_CONFIG) --cxxflags)
CPPFLAGS+=$(shell $(LLVM_CONFIG) --cppflags) -I$(SRC_DIR)

ifeq ($(shell uname), Darwin)
LOADABLE_MODULE_OPTIONS=-bundle -undefined dynamic_lookup
else
LOADABLE_MODULE_OPTIONS=-shared -O1
endif

CI_PASS=CompilerInterrupt.so
CI_PASS_OBJECTS=CompilerInterrupt.o
CI_LIB=libci.so
CI_LIB_OBJECTS=ci_lib.o

default: $(LIB_DIR)/$(CI_PASS) $(LIB_DIR)/$(CI_LIB)

%.o: $(SRC_DIR)/%.cpp
	@echo "Compiling $*.cpp"
	$(QUIET)$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $<

$(LIB_DIR)/$(CI_PASS): $(CI_PASS_OBJECTS)
	@echo "Creating library $@"
	mkdir -p $(LIB_DIR)
	$(QUIET)$(CXX) -o $@ $(LOADABLE_MODULE_OPTIONS) $(CXXFLAGS) $(LDFLAGS) $^

%.o: $(SRC_DIR)/%.c
	@echo "Compiling $*.c"
	$(QUIET)gcc -c -fPIC $< -o $@

$(LIB_DIR)/$(CI_LIB): $(CI_LIB_OBJECTS)
	$(QUIET)gcc -shared $< -o $@

clean:
	$(QUIET)rm -f $(LIB_DIR)/$(CI_PASS) $(CI_PASS_OBJECTS) $(LIB_DIR)/$(CI_LIB) $(CI_LIB_OBJECTS)
