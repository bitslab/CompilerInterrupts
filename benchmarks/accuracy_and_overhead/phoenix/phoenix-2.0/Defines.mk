#------------------------------------------------------------------------------
# Copyright (c) 2007-2009, Stanford University
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Stanford University nor the names of its 
#       contributors may be used to endorse or promote products derived from 
#       this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY STANFORD UNIVERSITY ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL STANFORD UNIVERSITY BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#------------------------------------------------------------------------------ 

# This Makefile requires GNU make.

# Query the shell to compile the code correctly for different architectures.
OSTYPE = $(shell uname)
LLVM_BUILD = /mnt/nilanjana

ifeq ($(OSTYPE),CYGWIN_NT-5.1)
OS = -D_CYGWIN_
endif

ifeq ($(OSTYPE),Linux)
OS = -D_LINUX_
CC = clang-9 
#DEBUG = -g
CFLAGS = -Wall $(OS) $(DEBUG) -O3 -D_GNU_SOURCE
LIBS = -pthread -lpapi
endif

ifeq ($(OSTYPE),SunOS)
OS =  -D_SOLARIS_
#CC = cc
CC = clang-9 
#DEBUG = -g
CFLAGS = -Wall $(OS) $(DEBUG) -O3 -D_FILE_OFFSET_BITS=64
LIBS = -lm -lrt -lthread -lmtmalloc -llgrp
endif

ifeq ($(OSTYPE),Darwin)
OS = -D_DARWIN_
endif

ARCHTYPE = $(shell uname -p)

ifeq ($(ARCHTYPE),sparc)
ARCH = -DCPU_V9
endif

ifeq ($(shell uname -m),x86_64)
ARCH = -D__x86_64__
endif

CC := clang-9
OPT := opt-9
LLVM_LINK := llvm-link-9
#CC := /mnt/nilanjana/bin/clang
#OPT := /mnt/nilanjana/bin/opt
#LLVM_LINK := /mnt/nilanjana/bin/llvm-link

CFLAGS += -Wall $(ARCH) -O3 -D_GNU_SOURCE

# The $(OS) flag is included here to define the OS-specific constant so that
# only the appropriate portions of the application get compiled. See the README
# file for more information.
AR = ar
RANLIB = ranlib
LDFLAGS =

PHOENIX = phoenix
LIB_PHOENIX = lib$(PHOENIX)

LINKAGE = static
ifeq ($(LINKAGE),static)
TARGET = $(LIB_PHOENIX).a
LIB_DEP = $(HOME)/$(LIB_DIR)/$(TARGET)
endif

ifeq ($(LINKAGE),dynamic)
TARGET = $(LIB_PHOENIX).so
LIB_DEP =
endif

SRC_DIR = src
LIB_DIR = lib
INC_DIR = include
TESTS_DIR = tests
CI_LIB_HOME = $(shell pwd)/../../../../../#w.r.t src directory
CI_HOME = $(shell pwd)/../../../#w.r.t src directory

# these variables may be exported from outside
INST_LEVEL ?= 1
PUSH_INTV ?= 5000
CYCLE_INTV ?= 5000
CMMT_INTV ?= 1000
ALLOWED_DEVIATION ?= 100
CLOCK ?= 1
FIBER_CONFIG ?= 0
CONFIG ?= 2
EXTRA_FLAGS ?= -DAVG_STATS
#CFLAGS += -g $(EXTRA_FLAGS) -I$(CI_HOME) -I$(CI_LIB_HOME)
CFLAGS += $(EXTRA_FLAGS) -I$(CI_LIB_HOME)/src -I$(CI_HOME) -I$(CI_LIB_HOME)/../src -I$(CI_HOME)/../

LIBS +=  -Wl,-rpath=./$(LIB_DIR)/ -L$(CI_LIB_HOME)/../lib/ -Wl,-rpath=$(CI_LIB_HOME)/../lib/ -lci $(EXTRA_LD_FLAGS)
#LDFLAGS := -lm -static -lpapi
#disable-verify
LC_FLAGS =  -load $(CI_LIB_HOME)/../lib/CompilerInterrupt.so -S -logicalclock -config $(CONFIG) -clock-type $(CLOCK) -inst-gran $(INST_LEVEL) -all-dev $(ALLOWED_DEVIATION) -push-intv $(PUSH_INTV) -commit-intv $(CMMT_INTV) -target-cycles $(CYCLE_INTV) -mem-ops-cost 1 -fiber-config $(FIBER_CONFIG) -config-file $(CI_HOME)/lc-config.txt

SRC_LC_FLAGS = -load $(CI_LIB_HOME)/lib/CompilerInterrupt.so -S -logicalclock -config $(CONFIG) -clock-type $(CLOCK) -inst-gran $(INST_LEVEL) -all-dev $(ALLOWED_DEVIATION) -push-intv $(PUSH_INTV) -commit-intv $(CMMT_INTV) -target-cycles $(CYCLE_INTV) -mem-ops-cost 1 -fiber-config $(FIBER_CONFIG) -config-file $(CI_HOME)/lc-config.txt

#OPT_FLAGS = -break-crit-edges -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution
OPT_FLAGS = -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution
#OPT_FLAGS = -postdomtree -mem2reg -indvars -mergereturn -loop-simplify -branch-prob -scalar-evolution
