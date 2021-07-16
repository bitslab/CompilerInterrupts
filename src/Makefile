ifeq ($(shell uname), Darwin)
LLVM_CONFIG=llvm-config
LOADABLE_MODULE_OPTIONS=-bundle -undefined dynamic_lookup
else
LLVM_CONFIG=llvm-config-12
LOADABLE_MODULE_OPTIONS=-shared -O1
endif

ifndef VERBOSE
	QUIET:=@
endif

SRC_DIR?=$(PWD)
LIB_DIR=$(SRC_DIR)/../lib

COMMON_FLAGS=-g -Wall -Wextra -Wno-unused-parameter -Wno-implicit-fallthrough -fPIC
LDFLAGS+=$(shell $(LLVM_CONFIG) --ldflags)
CXXFLAGS+=$(COMMON_FLAGS) $(shell $(LLVM_CONFIG) --cxxflags)
CPPFLAGS+=$(shell $(LLVM_CONFIG) --cppflags) -I$(SRC_DIR)

CI_PASS_OBJECTS=CompilerInterrupt.o
CI_PASS=CompilerInterrupt.so

CI_LIB_OBJECTS=ci_lib.o
CI_LIB_DYN=libci.so
CI_LIB_STATIC=libci.a

default: $(LIB_DIR)/$(CI_PASS) $(LIB_DIR)/$(CI_LIB_DYN) $(LIB_DIR)/$(CI_LIB_STATIC)

%.o: $(SRC_DIR)/%.cpp
	@echo "Compiling $*.cpp"
	clang-format -i $<
	$(QUIET)$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $<

$(LIB_DIR)/$(CI_PASS): $(CI_PASS_OBJECTS)
	@echo "Creating Compiler Interrupt Pass library $@"
	$(QUIET)$(CXX) -o $@ $(LOADABLE_MODULE_OPTIONS) $(CXXFLAGS) $(LDFLAGS) $^

%.o: $(SRC_DIR)/%.c
	@echo "Compiling $*.c"
	$(QUIET)gcc -c -fPIC $< -o $@

$(LIB_DIR)/$(CI_LIB_DYN): $(CI_LIB_OBJECTS)
	@echo "Creating Compiler Interrupt API dynamic library $@"
	$(QUIET)gcc -shared $< -o $@

$(LIB_DIR)/$(CI_LIB_STATIC): $(CI_LIB_OBJECTS)
	@echo "Creating Compiler Interrupt API static library $@"
	$(QUIET)ar -rcs $@ $<

clean:
	$(QUIET)rm -f $(LIB_DIR)/$(CI_PASS) $(LIB_DIR)/$(CI_LIB_DYN) $(LIB_DIR)/$(CI_LIB_STATIC) $(CI_PASS_OBJECTS) $(CI_LIB_OBJECTS)
