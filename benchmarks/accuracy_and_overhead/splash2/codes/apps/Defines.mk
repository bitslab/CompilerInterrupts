CC := clang-9
OPT := opt-9
LLVM_LINK := llvm-link-9
#CC := /mnt/nilanjana/bin/clang
#OPT := /mnt/nilanjana/bin/opt
#LLVM_LINK := /mnt/nilanjana/bin/llvm-link

TARGET1 := $(TARGET_NAME)-lc
TARGET2 := $(TARGET_NAME)-orig

all: $(TARGET1)

$(TARGET1): createfiles lc_all.ll
	$(CC) -g $(CFLAGS) -fstandalone-debug $(word 2,$^) $(LOADLIBS) $(LDFLAGS) -o $@ 

$(TARGET2): createfiles opt_simplified.ll
	$(CC) -g $(CFLAGS) -fstandalone-debug $(word 2,$^) $(LOADLIBS) $(LDFLAGS) -o $@ 

lc_all.ll: opt_simplified.ll
	$(OPT) $(LC_FLAGS) < $< > $@

opt_simplified.ll: llvm_all.ll
	$(OPT) $(OPT_FLAGS) -S < $< > $@

#opt_simplified.ll: opt_all.ll
#	$(OPT) $(OPT_FLAGS) -S < $< > $@
#
#opt_all.ll: llvm_all.ll
#	$(OPT) $(OPT_LEVEL) -S < $< > $@

llvm_all.ll: $(INTERMEDIATE_FILES)
	$(LLVM_LINK) $^ -o $@

$(INTERMEDIATE_FILES): llvm_%.ll : %.c
	$(CC) $(CFLAGS) -S -emit-llvm -o $@ $< > /dev/null 2>&1

createfiles: $(HDR_FILES) $(SRC_FILES)

$(HDR_FILES): %.h: %.H
	$(M4) $(MACROS) $< > $@

$(SRC_FILES): %.c: %.C
	$(M4) $(MACROS) $< > $@

clean-$(TARGET1):
	rm -rf *.c *.h *.ll *.o $(TARGET1)

clean-$(TARGET2):
	rm -rf *.c *.h *.ll *.o $(TARGET2)

clean:
	rm -rf *.c *.h *.ll *.o $(TARGET1) $(TARGET2)
