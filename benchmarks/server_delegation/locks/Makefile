#SHELL = /bin/bash

CFLAGS = -std=c99 -O3 -ggdb -g
LIBS = -lnuma -lm -lpthread

LLVM_BUILD_PATH=/AD-home/cmonta9/llvm_build

LOCK_TYPES=tas spin ttas mcs mutex ticket


all: tas spin ttas ticket mcs atomic mutex tas_iterations spin_iterations ttas_iterations ticket_iterations mcs_iterations atomic_iterations mutex_iterations 


all_iterations: $(patsubst %, %_iterations, $(LOCK_TYPES))

################# Time based benchmarks #################

tas: locks.c
	gcc $(CFLAGS) -o $@ $< $(LIBS) -DTAS;

mutex_inc_var_iterations: locks_increasing_vars_iterations.c
	gcc $(CFLAGS) -o $@ $< $(LIBS);

spin_inc_var_iterations: locks_increasing_vars_iterations.c
	gcc $(CFLAGS) -o $@ $< $(LIBS) -DSPIN;

mutex_inc_var: locks_increasing_vars.c
	gcc $(CFLAGS) -o $@ $< $(LIBS);

spin_inc_var: locks_increasing_vars.c
	gcc $(CFLAGS) -o $@ $< $(LIBS) -DSPIN;

spin: locks.c
	gcc $(CFLAGS) -o $@ $< $(LIBS) -DSPIN;

ttas: locks.c
	gcc $(CFLAGS) -o $@ $< $(LIBS) -DTTAS;

ticket: locks.c
	gcc $(CFLAGS) -o $@ $< $(LIBS) -DTICKET;

mcs: locks.c
	gcc $(CFLAGS) -o $@ $< $(LIBS) -DMCS;

atomic: locks.c
	gcc $(CFLAGS) $(C99) -o $@ $< $(LIBS) -DATOMIC;

mutex: locks.c
	gcc $(CFLAGS) $(C99) -o $@ $< $(LIBS) -DMUTEX;


################# Iterations based benchmarks #################

tas_iterations: locks_iterations.c
	gcc $(CFLAGS) -o $@ $< $(LIBS) -DTAS $(FFWD_FLAGS);

spin_iterations: locks_iterations.c
	gcc $(CFLAGS) -o $@ $< $(LIBS) -DSPIN $(FFWD_FLAGS);

ttas_iterations: locks_iterations.c
	gcc $(CFLAGS) -o $@ $< $(LIBS) -DTTAS $(FFWD_FLAGS);

ticket_iterations: locks_iterations.c
	gcc $(CFLAGS) -o $@ $< $(LIBS) -DTICKET $(FFWD_FLAGS);

mcs_iterations: locks_iterations.c
	gcc $(CFLAGS) -o $@ $< $(LIBS) -DMCS $(FFWD_FLAGS);

atomic_iterations: locks_iterations.c
	gcc $(CFLAGS) $(C99) -o $@ $< $(LIBS) -DATOMIC $(FFWD_FLAGS);

mutex_iterations: locks_iterations.c
	gcc $(CFLAGS) $(C99) -o $@ $< $(LIBS) -DMUTEX $(FFWD_FLAGS);


################# Other locks benchmarks #################

jains_spin: locks.c
	gcc $(CFLAGS) -o $@ locks.c $(LIBS) -DJAIN -DSPIN;

jains_ticket: locks.c
	gcc $(CFLAGS) -o $@ locks.c $(LIBS) -DJAIN -DTICKET;

jains_mcs: locks.c
	gcc $(CFLAGS) -o $@ locks.c $(LIBS) -DJAIN -DMCS;

jains_atomic: locks.c
	gcc $(CFLAGS) $(C99) -o $@ locks.c $(LIBS) -DATOMIC -DJAIN;

jains_mutex: locks.c
	gcc $(CFLAGS) $(C99) -o $@ locks.c $(LIBS) -DMUTEX -DJAIN;

clean:
	rm -f tas spin ttas ticket mcs jains_spin jains_ticket jains_mcs atomic mutex jains_atomic jains_mutex tas_iterations spin_iterations ttas_iterations ticket_iterations mcs_iterations atomic_iterations mutex_iterations mutex_inc_var_iterations spin_inc_var_iterations mutex_inc_var spin_inc_var

