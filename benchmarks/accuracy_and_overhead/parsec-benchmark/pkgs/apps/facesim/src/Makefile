PREFIX		:= ${PARSECDIR}/pkgs/apps/facesim/inst/${PARSECPLAT}
BINARY		:= facesim

export version	?= pthreads
export PHYSBAM	?= /AD-home/cmonta9/parsec-benchmark/pkgs/apps/facesim/obj/amd64-linux.gcc
export CXXFLAGS	?= -fpermissive -fno-exceptions -DPARSEC_VERSION=3.0-beta-20150206 -fexceptions

ifdef version
	ifeq "$(version)" "pthreads"
		CXXFLAGS+=-DENABLE_PTHREADS	
	endif

	ifeq "$(version)" "serial"
		CXXFLAGS+=-DNEW_SERIAL_IMPLEMENTATIOM	
	endif
endif

all:
	$(MAKE) -C TaskQ/lib all
	$(MAKE) -C Benchmarks/facesim

install:
	mkdir -p $(PREFIX)/bin
	cp -f Benchmarks/facesim/$(BINARY) $(PREFIX)/bin/$(BINARY)

