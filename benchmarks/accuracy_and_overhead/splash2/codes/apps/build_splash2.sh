#!/bin/bash

rm -f wnslog.txt wnserr.txt
make -f Makefile.lc water-ns-clean
BUILD_LOG=wnslog.txt ERROR_LOG=wnserr.txt ALLOWED_DEVIATION=0 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc water-ns

rm -f wsplog.txt wsperr.txt
make -f Makefile.lc water-sp-clean
BUILD_LOG=wsplog.txt ERROR_LOG=wsperr.txt ALLOWED_DEVIATION=0 CLOCK_TYPE=0 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc water-sp

rm -f ocplog.txt ocperr.txt
make -f Makefile.lc ocean-cp-clean
BUILD_LOG=ocplog.txt ERROR_LOG=ocperr.txt ALLOWED_DEVIATION=0 CLOCK_TYPE=0 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc ocean-cp

rm -f oncplog.txt oncperr.txt
make -f Makefile.lc ocean-ncp-clean
BUILD_LOG=oncplog.txt ERROR_LOG=oncperr.txt ALLOWED_DEVIATION=0 CLOCK_TYPE=0 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc ocean-ncp

rm -f barneslog.txt barneserr.txt
make -f Makefile.lc barnes-clean
BUILD_LOG=barneslog.txt ERROR_LOG=barneserr.txt ALLOWED_DEVIATION=0 CLOCK_TYPE=0 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc barnes

rm -f volrendlog.txt volrenderr.txt
make -f Makefile.lc volrend-clean
BUILD_LOG=volrendlog.txt ERROR_LOG=volrenderr.txt ALLOWED_DEVIATION=0 CLOCK_TYPE=0 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc volrend 

rm -f fmmlog.txt fmmerr.txt
make -f Makefile.lc fmm-clean
BUILD_LOG=fmmlog.txt ERROR_LOG=fmmerr.txt ALLOWED_DEVIATION=0 CLOCK_TYPE=0 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc fmm

rm -f rtlog.txt rterr.txt
make -f Makefile.lc raytrace-clean
BUILD_LOG=rtlog.txt ERROR_LOG=rterr.txt ALLOWED_DEVIATION=0 CLOCK_TYPE=0 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc raytrace

rm -f rdlog.txt rderr.txt
make -f Makefile.lc radiosity-clean
BUILD_LOG=rdlog.txt ERROR_LOG=rderr.txt ALLOWED_DEVIATION=0 CLOCK_TYPE=0 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc radiosity
