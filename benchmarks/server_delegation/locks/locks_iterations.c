#define _GNU_SOURCE
#include <pthread.h>
#include <numa.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <fcntl.h>
#include <getopt.h>
#include <math.h>
#include "locks.h"

#include <x86intrin.h>

#define ITERATION 1000000
//#define NUMBER_OF_THREADS

#define NUM_BUCKETS 400
#define MAX_LATENCY 400010
#define MIN_LATENCY 10

typedef struct data
{
    uint64_t ops;
    uint64_t poll_cycles;
    uint64_t local_ops;
    int id;

#ifdef PROFILE_CLIENT_LATENCY
        int latency_distribution[NUM_BUCKETS];
#endif
  
}data __attribute__((aligned(128)));

int exp_duration;
int num_of_threads;
int client_delay;
struct timespec t_start, t_lap, t_end;
pthread_barrier_t barrier_start;
volatile int integer_start=0;
pthread_barrier_t safe_id;

struct {
	int counter;
	char dummy [124];
}lonely __attribute__((aligned(128))) = {0}; 


#ifdef PROFILE_CLIENT_LATENCY
uint64_t latency_intervals[NUM_BUCKETS] = {0};

void init_latency_intervals(){
      int i;
      uint64_t step = (MAX_LATENCY - MIN_LATENCY) / NUM_BUCKETS;

      for(i = 0; i < NUM_BUCKETS; i++){
              latency_intervals[i] = MIN_LATENCY + (step * i);
      }
}

int get_bucket(uint64_t latency){
      int i = 0;

      if (latency <= latency_intervals[0]) return 0;

      for(i = 1; i < NUM_BUCKETS - 1; i++){
        if(latency <= latency_intervals[i]) return i;
      }

      return NUM_BUCKETS - 1;
}

uint64_t get_lower_bound(int index){
        uint64_t step = (MAX_LATENCY - MIN_LATENCY) / NUM_BUCKETS;

        if(index == 0) return 0;

        return MIN_LATENCY + (step * (index - 1));
}

uint64_t get_upper_bound(int index){
        uint64_t step = (MAX_LATENCY - MIN_LATENCY) / NUM_BUCKETS;
        return MIN_LATENCY + (step * index);
}
#endif


#ifdef TICKET
	#define IAF_U32(a) __sync_add_and_fetch(a,1)
	#define TICKET_BASE_WAIT 512
	#define TICKET_WAIT_NEXT 128

	struct ticketlock
	{
		volatile int ticket;
		volatile int turn;
	} the_lock __attribute__((aligned(128)));

	typedef struct ticketlock ticketlock;

	static inline void
        nop_rep(uint32_t num_reps)
        {
            uint32_t i;
            for (i = 0; i < num_reps; i++)
            {
                __asm__ __volatile__ ("NOP");
            }
        }

	void ticket_lock(ticketlock *lock)
	{
	  uint32_t my_ticket = IAF_U32(&(lock->turn));


	  uint32_t wait = TICKET_BASE_WAIT;
	  uint32_t distance_prev = 1;

	  while (1)
	    {
		    uint32_t cur = lock->ticket;
		    if (cur == my_ticket)
				break;
		  
		    uint32_t distance = my_ticket - cur;

		    if (distance > 1)
		    {
		      	if (distance != distance_prev)
		        {
		      	  	distance_prev = distance;
		      	   	wait = TICKET_BASE_WAIT;
		        }

		      	nop_rep(distance * wait);
		    }
		    else
		    {
			    nop_rep(TICKET_WAIT_NEXT);
		    }

		    if (distance > 20)
		   	{
			    sched_yield();
		    }
	    }

	}

	static void ticket_unlock(ticketlock *t)
	{
		__asm__ __volatile__("" ::: "memory"); 
		t->ticket++;
	}

#elif MCS
	#define atomic_barrier() __sync_synchronize()
	typedef struct mcs_lock_t mcs_lock_t;
	typedef volatile struct mcs_lock_t * mcs_lock;
	struct mcs_lock_t
	{	
		volatile mcs_lock_t * next;
		volatile uint8_t spin;
	};
	mcs_lock *mcslock;
	static inline void *xchg_64(void *ptr, void *x)
	{
		__asm__ __volatile__("xchgq %0,%1"
					:"=r" ((unsigned long long) x)
					:"m" (*(volatile long long *)ptr), "0" ((unsigned long long) x)
					:"memory");

		return x;
	}

	static void lock_mcs(mcs_lock *m, mcs_lock_t *me)
	{

		mcs_lock_t *tail;
		
		me->next = NULL;
		atomic_barrier();

		tail = (mcs_lock_t *) xchg_64(m, me);
		
		/* No one there? */
		if (!tail) return;

		/* Someone there, need to link in */
		me->spin = 0;
		atomic_barrier();

		tail->next = me;	
		
		/* Spin on my spin variable */
		while (!me->spin) cpu_relax();
		
		return;
	}

	static void unlock_mcs(mcs_lock *m, mcs_lock_t *me)
	{
		/* No successor yet? */
		volatile mcs_lock_t *succ;
		// if (!(me->next))
		if (!(succ = me->next))
		{
			/* Try to atomically unlock */
			if (__sync_val_compare_and_swap(m, me, NULL) == me) return;
		
			/* Wait for successor to appear */
			do {
				succ = me->next;
				cpu_relax();
			} while (!succ);
				// cpu_relax();
		}

		/* Unlock next one */
		succ->spin = 1;	
	}
#elif TAS
	#define UNLOCKED 0
	#define LOCKED 1
	#define TAS_U8(a) tas_uint8(a)
	#define COMPILER_BARRIER __asm__ __volatile__("" ::: "memory");

	static inline uint8_t tas_uint8(volatile uint8_t *addr) {
	    uint8_t oldval;
	    __asm__ __volatile__("xchgb %0,%1"
	            : "=q"(oldval), "=m"(*addr)
	            : "0"((unsigned char) 0xff), "m"(*addr) : "memory");
	    return (uint8_t) oldval;
	}

	typedef uint8_t spinlock_lock_data_t;

	typedef struct spinlock_lock_t 
	{
	        spinlock_lock_data_t lock;
	        uint8_t padding[128-1];
	} spinlock_lock_t __attribute__((aligned(128)));

	spinlock_lock_t *the_lock;

	void spinlock_lock(spinlock_lock_t* the_lock) 
	{
	    volatile spinlock_lock_data_t* l = &(the_lock->lock);
	    while (TAS_U8(l)) 
	    {
	        cpu_relax();
	    } 
	}

	void spinlock_unlock(spinlock_lock_t *the_lock) 
	{
	    COMPILER_BARRIER;
	    the_lock->lock = UNLOCKED;
	}

#elif SPIN

	typedef int spinlock;

	struct spin_lock
	{
		spinlock status;
		char dummy[124];
	} the_lock __attribute__((aligned(128)));
	
	static inline unsigned xchg_32(void *ptr, unsigned x)
	{
		__asm__ __volatile__("xchgl %0,%1"
					:"=r" ((unsigned) x)
					:"m" (*(volatile unsigned *)ptr), "0" (x)
					:"memory");

		return x;
	}

	static void spin_lock(spinlock *lock)
	{	
		int delay = 1;
		while (1){

			if (!xchg_32(lock, EBUSY)) return;
			
			while (*lock) {
					cpu_relax();
			}
		}
	}

	static void spin_unlock(spinlock *lock)
	{
		barrier();
		*lock = 0;
	}
#elif MUTEX
	pthread_mutex_t lock;
#elif TTAS
	#define UNLOCKED 0
	#define LOCKED 1
	#define COMPILER_BARRIER __asm__ __volatile__("" ::: "memory")
	#define TAS_U8(a) tas_uint8(a)
	
	static inline uint8_t tas_uint8(volatile uint8_t *addr) {
	    uint8_t oldval;
	    __asm__ __volatile__("xchgb %0,%1"
	            : "=q"(oldval), "=m"(*addr)
	            : "0"((unsigned char) 0xff), "m"(*addr) : "memory");
	    return (uint8_t) oldval;
	}

	typedef uint8_t ttas_lock_data_t;

	typedef struct ttas_lock_t {
	    ttas_lock_data_t lock;
	    uint8_t padding[127];
	}ttas_lock_t __attribute__((aligned(128)));

	ttas_lock_t* the_lock;

	void ttas_lock(ttas_lock_t * the_lock) {
	    uint32_t delay;
	    volatile ttas_lock_data_t* l = &(the_lock->lock);
	    while (1){
	        while ((*l)==1) {}
	        if (TAS_U8(l)==UNLOCKED) {
	            return;
	        }
	    }
	}
	void ttas_unlock(ttas_lock_t *the_lock) 
	{
	    COMPILER_BARRIER;
	    the_lock->lock=0;
	}
	int init_ttas_global(ttas_lock_t* the_lock) {
	    the_lock->lock=0;
	    barrier();
	    return 0;
	}
#endif

#ifdef TICKET 
	#define LOCK() ticket_lock(&the_lock);
#elif MCS
	#define LOCK() lock_mcs(mcslock, the_lock);
#elif TAS
	#define LOCK() spinlock_lock(the_lock);
#elif SPIN
	#define LOCK() spin_lock(&(the_lock.status));
#elif MUTEX
	#define LOCK() pthread_mutex_lock(&lock);
#elif TTAS
	#define LOCK() ttas_lock(the_lock);
#endif

#ifdef TICKET 
	#define UNLOCK() ticket_unlock(&the_lock);
#elif MCS
	#define UNLOCK() unlock_mcs(mcslock, the_lock);
#elif TAS
	#define UNLOCK() spinlock_unlock(the_lock);
#elif SPIN
	#define UNLOCK() spin_unlock(&(the_lock.status));
#elif MUTEX
	#define UNLOCK() pthread_mutex_unlock(&lock);
#elif TTAS 
	#define UNLOCK() ttas_unlock(the_lock);
#endif

void pin_thread(int core_id){
	int num_cpu = numa_num_configured_cpus();
	struct bitmask * cpumask = numa_bitmask_alloc(num_cpu);
	numa_bitmask_setbit(cpumask, core_id);
	numa_sched_setaffinity(0, cpumask);
}

#ifdef JAIN
	uint8_t* jains;
#endif

void* client(void * input_data){

	data* mydata = (data *) input_data;
    	mydata->ops = 0;
	
	int i;
	//const int _id = (int)*(int*)id;
	const int _id = mydata->id;
	pin_thread(_id);
	pthread_barrier_wait(&safe_id);
	//int delay = client_delay;
	int result;
	volatile uint64_t counter = 0, start, end;
	int rand_work = rand() % ((client_delay+50)/10);
	
	#ifdef JAIN
		int jains_local[ITERATION];
	#endif

	#ifdef MCS
		mcs_lock_t *the_lock;
		the_lock = malloc (sizeof(mcs_lock_t));
		atomic_barrier();
	#endif

	while(!integer_start) {
		__asm__ __volatile__("nop;": : :"memory");
	}

	#ifdef DEBUG
		int last_result = 0;
		int number_of_btb_acq = 0;
	#endif

	while( mydata->ops != ITERATION ){

		#ifdef PROFILE_CLIENT_LATENCY
		start = __rdtsc();	
		#endif

		#ifdef ATOMIC
			result = __sync_fetch_and_add(&(lonely.counter),1);
		#else
			LOCK()
			result = lonely.counter++;
			UNLOCK()
		#endif
		
		#ifdef PROFILE_CLIENT_LATENCY
		end = __rdtsc();

	        mydata->latency_distribution[get_bucket(end - start)]++;
		#endif

		#ifdef JAIN
			jains_local[i] = result;
		#endif

		#ifdef DEBUG
		if((result-last_result) == 1)
			number_of_btb_acq++;
		last_result = result;
		#endif

		for(int j=0;j<client_delay + rand_work;j++) {
			__asm__ __volatile__("rep;nop;": : :"memory"); 
			//counter++;
		}
	        
		//Do other work
        	//for(int j = 0; j < client_delay + rand_work; j++){
        	//	counter++;
	        //}
		
		mydata->ops++;
	}

	#ifdef JAIN
		for(i = 0; i < ITERATION; i++){
			jains[jains_local[i]] = _id;
		}
	#endif

	#ifdef DEBUG
		printf("%d : %d\n", _id, number_of_btb_acq);
	#endif	

	return 0;
}

pthread_t * create_thread(void *(* func) (void *), void* data){
	pthread_t * thread = malloc(sizeof(pthread_t));
	pthread_create(thread, 0, func, data);
	
	return thread;
}

int main (int argc, char ** argv){
	
	if(numa_available() < 0){
		printf("System does not support NUMA API!\n");
	}

	int c;
	while((c = getopt(argc, argv, "t:c:d:")) != -1) {
		switch (c) {
		case 't':
			num_of_threads = atoi(optarg);
			break;
		case 'c':
			client_delay = atoi(optarg);
			break;
		case 'd':
			exp_duration = atoi(optarg);
			break;
		}
	}

	#ifdef JAIN
		jains = malloc(num_of_threads * ITERATION);
	#endif
	
	int i;
	pthread_t * t[128];
	pthread_barrier_init(&safe_id, 0, 2);

	data **th_data;
	th_data = (data **) malloc(num_of_threads * sizeof(data *));
	
	for (i = 0; i < num_of_threads; i++) {
		th_data[i] = (data *) malloc(sizeof(data));
		th_data[i]->ops = 0;
		th_data[i]->id = i;
		th_data[i]->poll_cycles = 0;
		th_data[i]->local_ops = 0;
	
	#ifdef PROFILE_CLIENT_LATENCY
        	init_latency_intervals();
        	for(int b = 0; b < NUM_BUCKETS; b++)
          		th_data[i]->latency_distribution[b] = 0;
	#endif

	}

	struct timespec timeout;
	timeout.tv_sec = exp_duration / 1000;
    	timeout.tv_nsec = (exp_duration % 1000) * 1000000;

	#ifdef TICKET 
		the_lock.ticket = 1;
		the_lock.turn = 0;
	#elif MCS
		mcslock = (mcs_lock *) malloc (sizeof(mcs_lock));
		*(mcslock) = 0;
		atomic_barrier();
	#elif TTAS
		the_lock = (ttas_lock_t *) malloc (sizeof(ttas_lock_t));
		init_ttas_global(the_lock);
	#elif MUTEX
		pthread_mutex_init(&lock,0);
	#elif TAS
		the_lock = (spinlock_lock_t*) malloc (sizeof(spinlock_lock_t));
		the_lock->lock = UNLOCKED;
	#endif
	
	for (i = 0; i < num_of_threads; i++){
		#ifdef OPTERON
			if (i < 8){
				t[i] = create_pinned_thread(increment, i);
			}
			else if (i >= 8 && i < 16){
				t[i] = create_thread(client, i+8);
			}
			else if (i >= 16 && i < 24){
				t[i] = create_thread(client, i+16);
			}
			else if (i >= 24 && i < 32){
				t[i] = create_thread(client, i+24);
			}
			else if (i >= 32 && i < 40){
				t[i] = create_thread(client, i-24);
			}
			else if (i >= 40 && i < 48){
				t[i] = create_thread(client, i-16);
			}
			else if (i >= 48 && i < 56){
				t[i] = create_thread(client, i-8);
			}
			else if (i >= 56 && i < 64){
				t[i] = create_thread(client, i);
			}
		#else
			t[i] = create_thread(client, (void *)(th_data[i]));
		#endif
		pthread_barrier_wait(&safe_id);
	}
	
	clock_gettime(CLOCK_MONOTONIC, &t_start);
	integer_start = 1;

	for (i = 0; i < num_of_threads; i++){
		pthread_join(*t[i], 0);
	}
	clock_gettime(CLOCK_MONOTONIC, &t_end);

	#ifdef JAIN
		double occur[128] = {0.0};
		double nom = 0.0;
		double den = 0.0;
		double index = 0.0;
		int k;
		int rounds = 0;
		int max_itr = num_of_threads * ITERATION;
		int q;

		// for (i =310000; i< 310100; i++)
		// 	printf("jains[%d] = %d\n", i, jains[i]);

		// for (i = 0; i< (max_itr - num_of_threads); i++){
		for (i = 0; i< max_itr; i=i+(num_of_threads*5)){
			for (k=i; k < i+(num_of_threads*5); k++){
				occur[jains[k]]++;
			}

			for (k=0; k < num_of_threads; k++){
				occur[k] = occur[k] / (double)(num_of_threads*5);
			}

			for (k=0; k < num_of_threads; k++){
				nom += occur[k];
				den += (occur[k] * occur[k]);
			}

			if (den != 0)
				index += ((nom * nom) / (num_of_threads * den));
			
			for (k=0; k < num_of_threads; k++){
				occur[k] = 0;
			}

			nom = 0;
			den = 0;
			rounds++;
		}

		index = index / rounds;

		free(jains);
	#endif

	uint64_t nr_ops = 0;
	for (i = 0;  i < num_of_threads; i++) {
        	nr_ops += (th_data[i]->ops);
	}

	uint64_t start = (t_start.tv_sec * 1000000000LL) + t_start.tv_nsec;
	uint64_t finish = (t_end.tv_sec * 1000000000LL) + t_end.tv_nsec;
	uint64_t duration = finish - start;
	//double duration_msec = (double)(duration)/1000LL;
	double duration_sec = (double)(duration) / 1000000000LL;

#ifdef JAIN
    	printf("%.3f %.3f %d %.3f\n",  duration_sec, (nr_ops)/((double)(duration_sec*1000000LL)), client_delay, index);    	
#else
	    
	printf("clients_nr %d \nserver_nr 0\nduration %.3f \ninterrupt_fr 0\n", num_of_threads, duration_sec);
	printf("client_work %d \nstd_dev_ops_server 0 \nstd_dev_mops_server 0.000\n", client_delay);
	printf("avg_cl_poll_cl 0 \navg_cl_local_mops 0.000\n");
	printf("tot_ops %ld \nml_ops_per_sec %.3f \n", nr_ops, (nr_ops)/((double)(duration_sec*1000000LL)));
	printf("tot_server_increments 0\nserver_local_mops 0.000 \n");
	printf("clients_avg_mops 0.000 \nserver_client_mops 0.000\n");
	
	#ifdef PROFILE_CLIENT_LATENCY
    	int latency_distribution_accumulator[NUM_BUCKETS] = {0};

    	for(int k = 0; k < num_of_threads; k++){
      	//printf("client %d: \n", th_data[k]->id);
        	for(i = 0; i < NUM_BUCKETS; i++){
                	//printf("%ld-%ld %.5f\n", get_lower_bound(i), get_upper_bound(i) , ((double)th_data[k]->latency_distribution[i]) / ((double)th_data[k]->ops));
                	latency_distribution_accumulator[i]+= th_data[k]->latency_distribution[i];
        	}
    	}
    	printf("aggregate results: \n");
    	for(i = 0; i < NUM_BUCKETS; i++){
        	printf("%ld-%ld %.5f\n", get_lower_bound(i), get_upper_bound(i), ((double)latency_distribution_accumulator[i]) / ((double)nr_ops));
    	}
	#endif

#endif

	return 0;
}
