### GCC ###
GCC=gcc

export LLVM_BUILD ?= /mnt/nilanjana
export OPT_FLAGS = -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution

CC=clang-9 ${CC_OPT}
OPT=opt-9
LLVM_LINK=llvm-link-9
#CC=$(LLVM_BUILD)/bin/clang ${CC_OPT}
#OPT=$(LLVM_BUILD)/bin/opt
#LLVM_LINK=$(LLVM_BUILD)/bin/llvm-link

ifeq ($(shell uname -m),x86_64)
GCC_OPT = -m64
else
GCC_OPT =
endif
GCC_OPT += -Wall -fPIC -c
GCC_OPT += -DNDEBUG -O3 -DNETSTAT -DINFO -DDBGERR -DDBGCERR


### LIBRARIES AND INCLUDES ###
CFLAGS = -I./include/

### SOURCE CODE ###
SRCS = tdate_parse.c http_parsing.c netlib.c

#OBJS = $(patsubst %.c,%.o,$(SRCS))
OPT_OBJS = $(patsubst %.c,opt_%.ll,$(SRCS))
OBJS = $(patsubst %.c,%.ll,$(SRCS))

ifeq ($V,) # no echo
	export MSG=@echo
	export HIDE=
else
	export MSG=@\#
	export HIDE=
endif

### COMPILE ###
all: default

default: $(OBJS)

$(OPT_OBJS): opt_%.ll: %.c Makefile
	$(HIDE) $(CC) ${GCC_OPT} ${CFLAGS} -S -emit-llvm -o $@ $< >/dev/null 2>&1

$(OBJS): %.ll: opt_%.ll Makefile
	$(HIDE) $(OPT) $(OPT_FLAGS) -S < $< > $@

#$(OBJS): %.o: %.c Makefile
#	$(MSG) "   CC $<"
#	$(HIDE) ${CC} ${GCC_OPT} ${CFLAGS} $<

clean:
	$(MSG) "   CC *.o"
	$(HIDE) rm -rf *~ *.o *.ll

distclean: clean
	rm -f Makefile
