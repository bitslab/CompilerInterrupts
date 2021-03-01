TARGET1 := $(TARGET_NAME)-lc
TARGET2 := $(TARGET_NAME)-orig

ifeq ($(LINKAGE),dynamic)
CFLAGS += -fPIC
TARGET1_LIB := $(TARGET1).so
TARGET2_LIB := $(TARGET2).so
LIB_DEP = 
endif

ifeq ($(LINKAGE),static)
TARGET1_LIB := $(TARGET1).a
TARGET2_LIB := $(TARGET2).a
LIB_DEP = $(HOME)/$(LIB_DIR)/$(TARGET1)
endif

.PHONY: default all clean

SRC_FILES := $(wildcard *.c)
INTERMEDIATE_FILES := $(patsubst %.c, llvm_%.ll, $(SRCS))

all: $(TARGET1)

$(TARGET1): $(TARGET1_LIB)
	cp $< $(HOME)/$(LIB_DIR)

$(TARGET2): $(TARGET2_LIB)
	cp $< $(HOME)/$(LIB_DIR)

$(TARGET1).a: phoenix-lc.o
	$(AR) cr $@ $<
	$(RANLIB) $@

$(TARGET2).a: phoenix-lc.o
	$(AR) cr $@ $<
	$(RANLIB) $@

$(TARGET1).so: phoenix.o
	$(CC) --shared -o $@ $<

$(TARGET2).so: phoenix.o
	$(CC) --shared -o $@ $<

phoenix-lc.o: lc_all.ll
	$(LLVM_BUILD)/bin/llc -relocation-model=pic -filetype=obj $< -o $@

phoenix.o: opt_all.ll
	$(LLVM_BUILD)/bin/llc -relocation-model=pic -filetype=obj $< -o $@

lc_all.ll: opt_simplified.ll
	$(LLVM_BUILD)/bin/opt $(SRC_LC_FLAGS) -defclock=false -out-cost-file ./cost.txt < $< > $@

opt_simplified.ll: opt_all.ll
	$(LLVM_BUILD)/bin/opt $(OPT_FLAGS) -S < $< > $@
	
opt_all.ll: llvm_all.ll
	$(LLVM_BUILD)/bin/opt $(OPT_LEVEL) -S < $< > $@

llvm_all.ll: $(INTERMEDIATE_FILES)
	$(LLVM_BUILD)/bin/llvm-link $^ -o $@

$(INTERMEDIATE_FILES): llvm_%.ll : %.c
	$(LLVM_BUILD)/bin/clang -S -emit-llvm $(CFLAGS) -I$(HOME)/$(INC_DIR) -o $@ $<

clean:
	rm -f $(HOME)/$(LIB_DIR)/$(TARGET1) $(HOME)/$(LIB_DIR)/$(TARGET2) $(TARGET1) $(TARGET2) $(INTERMEDIATE_FILES) *.a *.so *.o *.ll
