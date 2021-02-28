CC := clang-9
OPT := opt-9
#CC := /mnt/nilanjana/bin/clang
#OPT := /mnt/nilanjana/bin/opt
CUR_PATH := $(shell pwd)
CI_LIB_INCLUDE_PATH := $(CUR_PATH)/../../src/
CI_LIB_PATH := $(CUR_PATH)/../../lib/
CI_PASS_LIB := $(CI_LIB_PATH)/CompilerInterrupt.so
CONFIG_FILE=$(CUR_PATH)/../../config/ir_weights.txt
FFWD_PATH := $(CUR_PATH)/ffwd

CI_LIBS= -L$(CI_LIB_PATH) -Wl,-rpath=$(CI_LIB_PATH) -lci 

FIBER_LIBRARY = -Wno-unused-variable -Ilibfiber/include -Ilibfiber/submodules/libev -Ilibfiber/src -I$(FFWD_PATH) -I$(CI_LIB_INCLUDE_PATH)
FIBER_FLAGS_CP = -lm -m64 -DARCH_x86_64 -fno-omit-frame-pointer -fno-stack-protector -D_REENTRANT -O3 -DFIBER_STACK_MALLOC -DLINUX -DUSE_COMPILER_THREAD_LOCAL -DFIBER_FAST_SWITCHING -DFAST_PATH -lpthread -ldl -lm -lrt -mavx

all: m4 ffwd_add ci_500 ci_1000 ci_1500 ci_2000 ci_4000 ci_8000 hw_int_ffwd_add ci_preemptive

ci_500: ffwd_add_lg_ck_ci_500_ch_st_and_ld ffwd_add_lg_ck_ci_500_nt_st_and_ld ffwd_add_lg_ck_ci_500_nt_st_and_sfence ffwd_add_lg_ck_ci_500_nt_st_and_ch_ld ffwd_add_lg_ck_ci_500_no_doorbell ffwd_add_lg_ck_ci_500_stateful_doorbell ffwd_add_lg_ck_ci_500_sampling_doorbell ffwd_add_lg_ck_ci_500_3_clients_poll ffwd_add_lg_ck_ci_500_skip_poll

ci_1000: ffwd_add_lg_ck_ci_1000_ch_st_and_ld ffwd_add_lg_ck_ci_1000_nt_st_and_ld ffwd_add_lg_ck_ci_1000_nt_st_and_sfence ffwd_add_lg_ck_ci_1000_nt_st_and_ch_ld ffwd_add_lg_ck_ci_1000_no_doorbell ffwd_add_lg_ck_ci_1000_stateful_doorbell ffwd_add_lg_ck_ci_1000_sampling_doorbell ffwd_add_lg_ck_ci_1000_3_clients_poll ffwd_add_lg_ck_ci_1000_skip_poll

ci_1500: ffwd_add_lg_ck_ci_1500_ch_st_and_ld ffwd_add_lg_ck_ci_1500_nt_st_and_ld ffwd_add_lg_ck_ci_1500_nt_st_and_sfence ffwd_add_lg_ck_ci_1500_nt_st_and_ch_ld ffwd_add_lg_ck_ci_1500_no_doorbell ffwd_add_lg_ck_ci_1500_stateful_doorbell ffwd_add_lg_ck_ci_1500_sampling_doorbell ffwd_add_lg_ck_ci_1500_3_clients_poll ffwd_add_lg_ck_ci_1500_skip_poll

ci_2000: ffwd_add_lg_ck_ci_2000_ch_st_and_ld ffwd_add_lg_ck_ci_2000_nt_st_and_ld ffwd_add_lg_ck_ci_2000_nt_st_and_sfence ffwd_add_lg_ck_ci_2000_nt_st_and_ch_ld ffwd_add_lg_ck_ci_2000_no_doorbell ffwd_add_lg_ck_ci_2000_stateful_doorbell ffwd_add_lg_ck_ci_2000_sampling_doorbell ffwd_add_lg_ck_ci_2000_3_clients_poll ffwd_add_lg_ck_ci_2000_skip_poll

ci_4000: ffwd_add_lg_ck_ci_4000_ch_st_and_ld ffwd_add_lg_ck_ci_4000_nt_st_and_ld ffwd_add_lg_ck_ci_4000_nt_st_and_sfence ffwd_add_lg_ck_ci_4000_nt_st_and_ch_ld ffwd_add_lg_ck_ci_4000_no_doorbell ffwd_add_lg_ck_ci_4000_stateful_doorbell ffwd_add_lg_ck_ci_4000_sampling_doorbell ffwd_add_lg_ck_ci_4000_3_clients_poll ffwd_add_lg_ck_ci_4000_skip_poll

ci_8000: ffwd_add_lg_ck_ci_8000_ch_st_and_ld ffwd_add_lg_ck_ci_8000_nt_st_and_ld ffwd_add_lg_ck_ci_8000_nt_st_and_sfence ffwd_add_lg_ck_ci_8000_nt_st_and_ch_ld ffwd_add_lg_ck_ci_8000_no_doorbell ffwd_add_lg_ck_ci_8000_stateful_doorbell ffwd_add_lg_ck_ci_8000_sampling_doorbell ffwd_add_lg_ck_ci_8000_3_clients_poll ffwd_add_lg_ck_ci_8000_skip_poll

ci_preemptive: ffwd_add_lg_ck_ci_250_preemptive_user_thread ffwd_add_lg_ck_ci_350_preemptive_user_thread ffwd_add_lg_ck_ci_500_preemptive_user_thread ffwd_add_lg_ck_ci_1000_preemptive_user_thread ffwd_add_lg_ck_ci_2000_preemptive_user_thread 

ci_preemptive_iterations: ffwd_add_iterations_lg_ck_ci_250_preemptive_user_thread ffwd_add_iterations_lg_ck_ci_350_preemptive_user_thread ffwd_add_iterations_lg_ck_ci_500_preemptive_user_thread ffwd_add_iterations_lg_ck_ci_1000_preemptive_user_thread ffwd_add_iterations_lg_ck_ci_2000_preemptive_user_thread 

PROGRAM_TO_TEST ?= $(FFWD_PATH)/ffwd_add_iterations_flat_delegation_and_dummy.c
INST_LEVEL 	?= 2
CMMT_INTV	?= 1000
ifeq ($(INST_LEVEL),2)
	CYCLE_INTV_MUL = 1  
else
	CYCLE_INTV_MUL = 4
endif


#### ffwd with dedicated server ####

#### compile with -DEXP_LOAD for an exponential load growth - macros.m4 for different # of clients

m4:
	m4 -Ulen -Uindex $(FFWD_FLAGS) $(FFWD_PATH)/macros.m4 m4-1.4.18/examples/forloop3.m4 $(FFWD_PATH)/ffwd_macros.H > $(FFWD_PATH)/ffwd_macros.h
	m4 -Ulen -Uindex $(FFWD_FLAGS) $(FFWD_PATH)/macros.m4 m4-1.4.18/examples/forloop3.m4 $(FFWD_PATH)/libffwd.C > $(FFWD_PATH)/libffwd.c
	m4 -Ulen -Uindex $(FFWD_FLAGS) $(FFWD_PATH)/macros.m4 m4-1.4.18/examples/forloop3.m4 $(FFWD_PATH)/libffwd.C > $(FFWD_PATH)/libffwd_original.c
	m4 -Ulen -Uindex $(FFWD_FLAGS) $(FFWD_PATH)/macros.m4 m4-1.4.18/examples/forloop3.m4 $(FFWD_PATH)/libffwd_preemptive_CI.C > $(FFWD_PATH)/libffwd_preemptive_CI.c
	m4 -Ulen -Uindex $(FFWD_FLAGS) $(FFWD_PATH)/macros.m4 m4-1.4.18/examples/forloop3.m4 $(FFWD_PATH)/libffwd_llvm.C > $(FFWD_PATH)/libffwd_llvm.c
	m4 -Ulen -Uindex $(FFWD_PATH)/thread_layout.m4 $(FFWD_PATH)/thread_layout.H > $(FFWD_PATH)/thread_layout.h

libfiber/libfiber.a: m4
	$(MAKE) clean -C libfiber > /dev/null 2>&1
	$(MAKE) FIBER_FLAGS="$(FFWD_FLAGS) -DFAST_PATH" libfiber.a -C libfiber

libffwd.o: m4 $(FFWD_PATH)/libffwd_original.c $(FFWD_PATH)/ffwd.h
	gcc -O3 -Wall -g -fPIE -m64 -DARCH_x86_64 -DFAST_PATH $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -c -o libffwd.o $(FFWD_PATH)/libffwd_original.c -lnuma -lpthread $(FFWD_FLAGS) -lpthread -ldl -lm -lrt > /dev/null 2>&1

ffwd_add.o: m4 $(FFWD_PATH)/ffwd_add.c  $(FFWD_PATH)/ffwd.h
	gcc -O3 -g -m64 -fPIE -DARCH_x86_64 -Wall -DFAST_PATH $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -c $(FFWD_PATH)/ffwd_add.c -o $@ -lnuma -lpthread $(FFWD_FLAGS) -lpthread -ldl -lm -lrt > /dev/null 2>&1

ffwd_add: ffwd_add.o libffwd.o libfiber/libfiber.a
	cc -O3 -g -m64 -fPIE -DARCH_x86_64 -Wall -DFAST_PATH $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -Llibfiber -Llibfiber/bin $< libfiber/libfiber.a libffwd.o -o $@ -lpthread -ldl -lm -lrt -lnuma -lpthread $(FFWD_FLAGS) -lpthread -ldl -lm -lrt

ffwd_add_iterations.o: m4 $(FFWD_PATH)//ffwd_add_iterations.c $(FFWD_PATH)//ffwd.h
	gcc -O3 -g -m64 -fPIE -DARCH_x86_64 -Wall -DFAST_PATH $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -c $(FFWD_PATH)/ffwd_add_iterations.c -o $@ -lnuma -lpthread $(FFWD_FLAGS) -lpthread -ldl -lm -lrt

ffwd_add_iterations: ffwd_add_iterations.o libffwd.o libfiber/libfiber.a
	cc -O3 -g -m64 -fPIE -DARCH_x86_64 -Wall -DFAST_PATH $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -Llibfiber -Llibfiber/bin $< libffwd.o libfiber/libfiber.a  -o $@ -lpthread -ldl -lm -lrt -lnuma -lpthread $(FFWD_FLAGS) -lpthread -ldl -lm -lrt

#### i++ benchmark with locks [TICKET, MCS, MUTEX, SPIN, TAS, TTAS] ####

ffwd_add_fiber_locks.o: m4 $(FFWD_PATH)/fiber_lock.c $(FFWD_PATH)/ffwd.h 
	@gcc -O3 -g -m64 -fPIE -fno-omit-frame-pointer -DARCH_x86_64 -Wall $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -DMUTEX -c $(FFWD_PATH)/fiber_lock.c -o $@ -lnuma -lpthread $(FFWD_FLAGS) -lpthread -ldl -lm -lrt 

ffwd_add_fiber_locks: ffwd_add_fiber_locks.o libffwd.o libfiber/libfiber.a 
	@cc -O3 -g -m64 -fPIE -fno-omit-frame-pointer -DARCH_x86_64 -Wall $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -DMUTEX -Llibfiber -Llibfiber/bin $< libfiber/libfiber.a libffwd.o -o $@ -lpthread -ldl -lm -lrt -lnuma -lpthread $(FFWD_FLAGS) -lpthread -ldl -lm -lrt


#### ffwd w/o dedicated server - compiler interrupts w/ different delta ####

#### compile with -DEXP_LOAD for an exponential load growth 

ir_ffwd_add_lg_ck.ll: $(FFWD_PATH)/ffwd_add_lg_ck_separate.c $(FFWD_PATH)/ffwd.h 
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -DLG_CK 

opt_ffwd_add_lg_ck.ll: ir_ffwd_add_lg_ck.ll $(FFWD_PATH)/ffwd.h
	@$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@

ci_ffwd_add_lg_ck_500.ll: opt_ffwd_add_lg_ck.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 500 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ci_ffwd_add_lg_ck_1000.ll: opt_ffwd_add_lg_ck.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 1000 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ci_ffwd_add_lg_ck_1500.ll: opt_ffwd_add_lg_ck.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 1500 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ci_ffwd_add_lg_ck_2000.ll: opt_ffwd_add_lg_ck.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 2000 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ci_ffwd_add_lg_ck_4000.ll: opt_ffwd_add_lg_ck.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 4000 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ci_ffwd_add_lg_ck_8000.ll: opt_ffwd_add_lg_ck.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 8000 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@


#### ffwd w/o dedicated server - compiler interrupts w/ different delta and preemptive user threading ####
# compile with ir_libffwd_no_doorbell.ll to rollback 

LIBS=libfiber/libfiber.a

ir_ffwd_add_lg_ck_preemptive_user_thread.ll: $(FFWD_PATH)/ffwd_add_flat_delegation.c $(FFWD_PATH)/ffwd.h $(LIBS) 
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(FFWD_FLAGS) -DLG_CK

opt_ffwd_add_lg_ck_preemptive_user_thread.ll: ir_ffwd_add_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	@$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@


ci_ffwd_add_lg_ck_250_preemptive_user_thread.ll: opt_ffwd_add_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 250 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_lg_ck_ci_250_preemptive_user_thread: ci_ffwd_add_lg_ck_250_preemptive_user_thread.ll ir_libffwd_preemptive_CI.ll $(LIBS) 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ci_ffwd_add_lg_ck_350_preemptive_user_thread.ll: opt_ffwd_add_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 350 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_lg_ck_ci_350_preemptive_user_thread: ci_ffwd_add_lg_ck_350_preemptive_user_thread.ll ir_libffwd_preemptive_CI.ll $(LIBS)   
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ci_ffwd_add_lg_ck_500_preemptive_user_thread.ll: opt_ffwd_add_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 500 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_lg_ck_ci_500_preemptive_user_thread: ci_ffwd_add_lg_ck_500_preemptive_user_thread.ll ir_libffwd_preemptive_CI.ll $(LIBS) 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ci_ffwd_add_lg_ck_1000_preemptive_user_thread.ll: opt_ffwd_add_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 1000 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_lg_ck_ci_1000_preemptive_user_thread: ci_ffwd_add_lg_ck_1000_preemptive_user_thread.ll ir_libffwd_preemptive_CI.ll $(LIBS)
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ci_ffwd_add_lg_ck_2000_preemptive_user_thread.ll: opt_ffwd_add_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 2000 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_lg_ck_ci_2000_preemptive_user_thread: ci_ffwd_add_lg_ck_2000_preemptive_user_thread.ll ir_libffwd_preemptive_CI.ll $(LIBS)
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ci_ffwd_add_lg_ck_4000_preemptive_user_thread.ll: opt_ffwd_add_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 4000 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_lg_ck_ci_4000_preemptive_user_thread: ci_ffwd_add_lg_ck_4000_preemptive_user_thread.ll ir_libffwd_preemptive_CI.ll $(LIBS)
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 



#### ffwd w/o dedicated server iteration based - compiler interrupts w/ different delta and preemptive user threading ####
# compile with ir_libffwd_no_doorbell.ll to rollback 


ir_ffwd_add_iterations_lg_ck_preemptive_user_thread.ll: $(PROGRAM_TO_TEST) $(LIBS)
	$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(FFWD_FLAGS) -DLG_CK

opt_ffwd_add_iterations_lg_ck_preemptive_user_thread.ll: ir_ffwd_add_iterations_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@


ci_ffwd_add_iterations_lg_ck_$(CI_DELTA)_preemptive_user_thread_general.ll: opt_ffwd_add_iterations_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran $(INST_LEVEL) -all-dev 100 -push-intv $(CI_DELTA) -target-cycles $(CI_DELTA) -commit-intv $(CMMT_INTV) -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_iterations_lg_ck_ci_$(CI_DELTA)_preemptive_user_thread_general: ci_ffwd_add_iterations_lg_ck_$(CI_DELTA)_preemptive_user_thread_general.ll ir_libffwd_preemptive_CI.ll $(LIBS) 
	$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 


ci_ffwd_add_iterations_lg_ck_250_preemptive_user_thread.ll: opt_ffwd_add_iterations_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran $(INST_LEVEL) -all-dev 100 -push-intv 250 -target-cycles 250 -commit-intv $(CMMT_INTV) -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_iterations_lg_ck_ci_250_preemptive_user_thread: ci_ffwd_add_iterations_lg_ck_250_preemptive_user_thread.ll ir_libffwd_preemptive_CI.ll $(LIBS) 
	$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ci_ffwd_add_iterations_lg_ck_350_preemptive_user_thread.ll: opt_ffwd_add_iterations_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran $(INST_LEVEL) -all-dev 100 -push-intv 350 -target-cycles 350 -commit-intv $(CMMT_INTV) -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_iterations_lg_ck_ci_350_preemptive_user_thread: ci_ffwd_add_iterations_lg_ck_350_preemptive_user_thread.ll ir_libffwd_preemptive_CI.ll $(LIBS)
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma

ci_ffwd_add_iterations_lg_ck_500_preemptive_user_thread.ll: opt_ffwd_add_iterations_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran $(INST_LEVEL) -all-dev 100 -push-intv 500 -target-cycles 500 -commit-intv $(CMMT_INTV) -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_iterations_lg_ck_ci_500_preemptive_user_thread: ci_ffwd_add_iterations_lg_ck_500_preemptive_user_thread.ll ir_libffwd_preemptive_CI.ll $(LIBS)
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ci_ffwd_add_iterations_lg_ck_1000_preemptive_user_thread.ll: opt_ffwd_add_iterations_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran $(INST_LEVEL) -all-dev 100 -push-intv 1000 -target-cycles 1000 -commit-intv $(CMMT_INTV) -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_iterations_lg_ck_ci_1000_preemptive_user_thread: ci_ffwd_add_iterations_lg_ck_1000_preemptive_user_thread.ll ir_libffwd_preemptive_CI.ll $(LIBS)
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma

ci_ffwd_add_iterations_lg_ck_2000_preemptive_user_thread.ll: opt_ffwd_add_iterations_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran $(INST_LEVEL) -all-dev 100 -push-intv 2000 -target-cycles 2000 -commit-intv $(CMMT_INTV) -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_iterations_lg_ck_ci_2000_preemptive_user_thread: ci_ffwd_add_iterations_lg_ck_2000_preemptive_user_thread.ll ir_libffwd_preemptive_CI.ll $(LIBS)
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma

ci_ffwd_add_iterations_lg_ck_4000_preemptive_user_thread.ll: opt_ffwd_add_iterations_lg_ck_preemptive_user_thread.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran $(INST_LEVEL) -all-dev 100 -push-intv 4000 -target-cycles 4000 -commit-intv $(CMMT_INTV) -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_iterations_lg_ck_ci_4000_preemptive_user_thread: ci_ffwd_add_iterations_lg_ck_4000_preemptive_user_thread.ll ir_libffwd_preemptive_CI.ll $(LIBS)
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma


############ tests for different doorbell implementations - binary generation CI 500 #### 

ffwd_add_lg_ck_ci_500_ch_st_and_ld: ci_ffwd_add_lg_ck_500.ll ir_libffwd_ch_st_and_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_500_nt_st_and_ld: ci_ffwd_add_lg_ck_500.ll ir_libffwd_nt_st_and_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_500_nt_st_and_sfence: ci_ffwd_add_lg_ck_500.ll ir_libffwd_nt_st_and_sfence.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_500_nt_st_and_ch_ld: ci_ffwd_add_lg_ck_500.ll ir_libffwd_nt_st_and_ch_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_500_stateful_doorbell: ci_ffwd_add_lg_ck_500.ll ir_libffwd_stateful_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_500_sampling_doorbell: ci_ffwd_add_lg_ck_500.ll ir_libffwd_sampling_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_500_3_clients_poll: ci_ffwd_add_lg_ck_500.ll ir_libffwd_3_clients_poll.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_500_skip_poll: ci_ffwd_add_lg_ck_500.ll ir_libffwd_skip_poll.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_500_no_doorbell: ci_ffwd_add_lg_ck_500.ll ir_libffwd_no_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 


############ tests for different doorbell implementations - binary generation CI 1000 #### 

ffwd_add_lg_ck_ci_1000_ch_st_and_ld: ci_ffwd_add_lg_ck_1000.ll ir_libffwd_ch_st_and_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1000_nt_st_and_ld: ci_ffwd_add_lg_ck_1000.ll ir_libffwd_nt_st_and_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1000_nt_st_and_sfence: ci_ffwd_add_lg_ck_1000.ll ir_libffwd_nt_st_and_sfence.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1000_nt_st_and_ch_ld: ci_ffwd_add_lg_ck_1000.ll ir_libffwd_nt_st_and_ch_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1000_stateful_doorbell: ci_ffwd_add_lg_ck_1000.ll ir_libffwd_stateful_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1000_sampling_doorbell: ci_ffwd_add_lg_ck_1000.ll ir_libffwd_sampling_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1000_3_clients_poll: ci_ffwd_add_lg_ck_1000.ll ir_libffwd_3_clients_poll.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1000_skip_poll: ci_ffwd_add_lg_ck_1000.ll ir_libffwd_skip_poll.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1000_no_doorbell: ci_ffwd_add_lg_ck_1000.ll ir_libffwd_no_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 


############ tests for different doorbell implementations - binary generation CI 1500 #### 

ffwd_add_lg_ck_ci_1500_ch_st_and_ld: ci_ffwd_add_lg_ck_1500.ll ir_libffwd_ch_st_and_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1500_nt_st_and_ld: ci_ffwd_add_lg_ck_1500.ll ir_libffwd_nt_st_and_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1500_nt_st_and_sfence: ci_ffwd_add_lg_ck_1500.ll ir_libffwd_nt_st_and_sfence.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1500_nt_st_and_ch_ld: ci_ffwd_add_lg_ck_1500.ll ir_libffwd_nt_st_and_ch_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1500_stateful_doorbell: ci_ffwd_add_lg_ck_1500.ll ir_libffwd_stateful_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1500_sampling_doorbell: ci_ffwd_add_lg_ck_1500.ll ir_libffwd_sampling_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1500_3_clients_poll: ci_ffwd_add_lg_ck_1500.ll ir_libffwd_3_clients_poll.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1500_skip_poll: ci_ffwd_add_lg_ck_1500.ll ir_libffwd_skip_poll.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_1500_no_doorbell: ci_ffwd_add_lg_ck_1500.ll ir_libffwd_no_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 


############ tests for different doorbell implementations - binary generation CI 2000 #### 

ffwd_add_lg_ck_ci_2000_ch_st_and_ld: ci_ffwd_add_lg_ck_2000.ll ir_libffwd_ch_st_and_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_2000_nt_st_and_ld: ci_ffwd_add_lg_ck_2000.ll ir_libffwd_nt_st_and_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_2000_nt_st_and_sfence: ci_ffwd_add_lg_ck_2000.ll ir_libffwd_nt_st_and_sfence.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_2000_nt_st_and_ch_ld: ci_ffwd_add_lg_ck_2000.ll ir_libffwd_nt_st_and_ch_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_2000_stateful_doorbell: ci_ffwd_add_lg_ck_2000.ll ir_libffwd_stateful_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_2000_sampling_doorbell: ci_ffwd_add_lg_ck_2000.ll ir_libffwd_sampling_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_2000_3_clients_poll: ci_ffwd_add_lg_ck_2000.ll ir_libffwd_3_clients_poll.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_2000_skip_poll: ci_ffwd_add_lg_ck_2000.ll ir_libffwd_skip_poll.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_2000_no_doorbell: ci_ffwd_add_lg_ck_2000.ll ir_libffwd_no_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 


############ tests for different doorbell implementations - binary generation CI 4000 #### 

ffwd_add_lg_ck_ci_4000_ch_st_and_ld: ci_ffwd_add_lg_ck_4000.ll ir_libffwd_ch_st_and_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_4000_nt_st_and_ld: ci_ffwd_add_lg_ck_4000.ll ir_libffwd_nt_st_and_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_4000_nt_st_and_sfence: ci_ffwd_add_lg_ck_4000.ll ir_libffwd_nt_st_and_sfence.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_4000_nt_st_and_ch_ld: ci_ffwd_add_lg_ck_4000.ll ir_libffwd_nt_st_and_ch_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_4000_stateful_doorbell: ci_ffwd_add_lg_ck_4000.ll ir_libffwd_stateful_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_4000_sampling_doorbell: ci_ffwd_add_lg_ck_4000.ll ir_libffwd_sampling_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_4000_3_clients_poll: ci_ffwd_add_lg_ck_4000.ll ir_libffwd_3_clients_poll.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_4000_skip_poll: ci_ffwd_add_lg_ck_4000.ll ir_libffwd_skip_poll.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_4000_no_doorbell: ci_ffwd_add_lg_ck_4000.ll ir_libffwd_no_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 


############ tests for different doorbell implementations - binary generation CI 8000 #### 

ffwd_add_lg_ck_ci_8000_ch_st_and_ld: ci_ffwd_add_lg_ck_8000.ll ir_libffwd_ch_st_and_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_8000_nt_st_and_ld: ci_ffwd_add_lg_ck_8000.ll ir_libffwd_nt_st_and_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_8000_nt_st_and_sfence: ci_ffwd_add_lg_ck_8000.ll ir_libffwd_nt_st_and_sfence.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_8000_nt_st_and_ch_ld: ci_ffwd_add_lg_ck_8000.ll ir_libffwd_nt_st_and_ch_ld.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_8000_stateful_doorbell: ci_ffwd_add_lg_ck_8000.ll ir_libffwd_stateful_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_8000_sampling_doorbell: ci_ffwd_add_lg_ck_8000.ll ir_libffwd_sampling_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_8000_3_clients_poll: ci_ffwd_add_lg_ck_8000.ll ir_libffwd_3_clients_poll.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_8000_skip_poll: ci_ffwd_add_lg_ck_8000.ll ir_libffwd_skip_poll.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 

ffwd_add_lg_ck_ci_8000_no_doorbell: ci_ffwd_add_lg_ck_8000.ll ir_libffwd_no_doorbell.ll libfiber/libfiber.a 
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 


###### tests for different doorbell implementations - first llvm pass ######

ir_libffwd_ch_st_and_ld.ll: $(FFWD_PATH)/libffwd.c $(FFWD_PATH)/ffwd.h
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -DDOORBELL

ir_libffwd_nt_st_and_ld.ll: $(FFWD_PATH)/libffwd.c $(FFWD_PATH)/ffwd.h
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -DDOORBELL -DNT_STORE -DNT_LOAD

ir_libffwd_nt_st_and_sfence.ll: $(FFWD_PATH)/libffwd.c $(FFWD_PATH)/ffwd.h
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -DDOORBELL -DSFENCE_CLIENT

ir_libffwd_nt_st_and_ch_ld.ll: $(FFWD_PATH)/libffwd.c $(FFWD_PATH)/ffwd.h
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -DDOORBELL -DNT_STORE

ir_libffwd_stateful_doorbell.ll: $(FFWD_PATH)/libffwd.c $(FFWD_PATH)/ffwd.h
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -DDOORBELL -DSTATEFUL_DOORBELL

ir_libffwd_sampling_doorbell.ll: $(FFWD_PATH)/libffwd.c $(FFWD_PATH)/ffwd.h
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -DDOORBELL -DSAMPLING_DOORBELL

ir_libffwd_3_clients_poll.ll: $(FFWD_PATH)/libffwd.c $(FFWD_PATH)/ffwd.h
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -DREDUCED_POLL

ir_libffwd_skip_poll.ll: $(FFWD_PATH)/libffwd.c $(FFWD_PATH)/ffwd.h
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -DPOLL_SKIP

ir_libffwd_no_doorbell.ll: $(FFWD_PATH)/libffwd.c $(FFWD_PATH)/ffwd.h
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(FFWD_FLAGS)

ir_libffwd_preemptive_CI.ll: $(FFWD_PATH)/libffwd_preemptive_CI.c $(FFWD_PATH)/ffwd.h
	@$(CC) -g -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(FFWD_FLAGS)


#### ffwd w/o dedicated server - hardware interrupts via PAPI ####

ir_hw_int_ffwd_add.ll: $(FFWD_PATH)/ffwd_add_hw_interrupt_PAPI.c $(FFWD_PATH)/ffwd.h $(FFWD_PATH)/instructionCounter.h
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) -DLG_CK

ir_instructionCounter.ll: $(FFWD_PATH)/instructionCounter.c $(FFWD_PATH)/instructionCounter.h $(FFWD_PATH)/util.h 
	@$(CC) -S -emit-llvm -o $@ $<

hw_int_ffwd_add: ir_hw_int_ffwd_add.ll ir_libffwd_no_doorbell.ll ir_instructionCounter.ll libfiber/libfiber.a
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma -lpapi


#### ffwd w/ dedicated server - client instrumented but CI always disabled

ir_libffwd_disabled_CI.ll: $(FFWD_PATH)/libffwd_llvm.c $(FFWD_PATH)/ffwd.h
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(FFWD_FLAGS)

ir_ffwd_add_lg_ck_disabled.ll: $(FFWD_PATH)/ffwd_add.c $(FFWD_PATH)/ffwd.h 
	@$(CC) -S -emit-llvm -o $@ $< $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(FFWD_FLAGS)

opt_ffwd_add_lg_ck_disabled.ll: ir_ffwd_add_lg_ck_disabled.ll $(FFWD_PATH)/ffwd.h
	@$(OPT) -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution -S < $< > $@


ci_ffwd_add_lg_ck_250_disabled.ll: opt_ffwd_add_lg_ck_disabled.ll $(FFWD_PATH)/ffwd.h
	$(OPT) -load $(CI_PASS_LIB) -S -logicalclock -clock-type 1 -config 2 -inst-gran 1 -all-dev 100 -push-intv 250 -commit-intv 1000 -mem-ops-cost 1 -fiber-config 5 -config-file $(CONFIG_FILE) < $< > $@

ffwd_add_lg_ck_ci_250_disabled: ci_ffwd_add_lg_ck_250_disabled.ll ir_libffwd_disabled_CI.ll libfiber/libfiber.a  
	@$(CC) -g $^ -o $@ $(FIBER_LIBRARY) $(FIBER_FLAGS_CP) $(CI_LIBS) -lnuma 



clean:
	rm -f  libffwd.o ffwd_add.o ffwd_add ffwd_add_*lg_ck_ci_*0* hw_int_ffwd_add libfiber/bin/* libfiber/libfiber.a *.ll $(FFWD_PATH)/ffwd_macros.h $(FFWD_PATH)/libffwd.c $(FFWD_PATH)/thread_layout.h
