#define _GNU_SOURCE
#include <pthread.h>
#include <numa.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <fcntl.h>
#include <getopt.h>
#include <sys/mman.h>
#include <math.h>
#include <string.h>
#include <assert.h>


#ifdef SPIN
	#define INIT 	pthread_spin_init
	#define LOCK_T 	pthread_spinlock_t
	#define	LOCK 	pthread_spin_lock
	#define UNLOCK 	pthread_spin_unlock
#else
	#define INIT 	pthread_mutex_init
	#define LOCK_T 	pthread_mutex_t
	#define LOCK  	pthread_mutex_lock
	#define UNLOCK  pthread_mutex_unlock
#endif // SPIN

#define ITERATIONS 1000000

typedef struct var_size{
	LOCK_T lock;
	uint32_t var;
	char pad[64 - (sizeof(LOCK_T) + sizeof(uint32_t))];
} var_size;

pthread_barrier_t barrier;
volatile int 	stop;
uint64_t 		server_mask;
uint64_t 		addr_mask;
var_size* 		array;
uint64_t 		variables;
uint64_t 		server_shift;
uint64_t		num_servers;
int 			delay = 0;

void* client_func(void* arg){
	
	
	int server = 0;
	int addr   = 0;
	int mult   = rand();
	int randno = rand();

	uint64_t local_count = 0;

	int rand_work = rand() % ((delay+50)/10);

	pthread_barrier_wait(&barrier);

	while(local_count < ITERATIONS){
		randno += mult;
		addr   = randno & addr_mask;
		local_count++;
		LOCK(&array[addr].lock);
		array[addr].var++;
		UNLOCK(&array[addr].lock);
		for (int i=0; i < delay + rand_work; i++){
			__asm__ __volatile__("rep;nop;": : :"memory"); 
		}
	}

	return (void*) local_count;
}

int main (int argc, char* argv[]) {

	int time_var, num_clients;
	struct timespec timeout, t_start, t_end;
	uint64_t varPerServer = 0;
	uint64_t possible_servers = 0;

    int c, i;
    while((c = getopt(argc, argv, "t:s:c:v:d:h:")) != -1){
        switch (c)\
        {
			case 't':
				time_var = atoi(optarg);
				break;
			case 's':
				num_servers = atoi(optarg);
				break;
			case 'v':
				variables = atoi(optarg);
				break;
			case 'd':
				delay = atoi(optarg);
				break;
        }
    }
	
	addr_mask    = variables - 1;

	timeout.tv_sec  = time_var / 1000;
	timeout.tv_nsec = (time_var % 1000) * 1000000;
	stop = 0;

	// Allocate some memory for the fetch and add arrays
	array = malloc(variables * sizeof(struct var_size));
	memset(array, 0, variables * sizeof(struct var_size));
	
	for(int i = 0; i < variables; i++){
	
		#ifdef SPIN
			INIT(&array[i].lock, PTHREAD_PROCESS_SHARED);
		#else
			INIT(&array[i].lock, NULL);
		#endif // SPIN
	}	


	// Launch the lock clients
	pthread_t *thds = malloc(sizeof(pthread_t) * num_servers);
	
	pthread_barrier_init(&barrier, NULL, num_servers+1);

	srand(time(NULL));

	
	for(uint64_t i = 0; i < num_servers; i++){
		pthread_create(&thds[i], NULL, client_func, NULL);
	}
	
	pthread_barrier_wait(&barrier);
	clock_gettime(CLOCK_MONOTONIC, &t_start);
	
	
	
	void* ret;
	uint64_t overall_count = 0;
	for(int i = 0; i < num_servers; i++){
		pthread_join(thds[i], &ret);
		overall_count += (uint64_t) ret;
	}

	clock_gettime(CLOCK_MONOTONIC, &t_end);

	uint64_t server_sum = 0;
	uint64_t overall_count_server = 0;
	server_sum = 0;
	for(int i = 0; i < variables; i++){		
		server_sum += array[i].var;
	}

	assert(overall_count == server_sum);

    uint64_t start = (t_start.tv_sec * 1000000000LL) + t_start.tv_nsec;
    uint64_t finish = (t_end.tv_sec * 1000000000LL) + t_end.tv_nsec;
    uint64_t duration = finish - start;
    double duration_sec = (double)(duration) / 1000000000LL;

    
	//printf("Secs: %lf Ops: %ld Mops: %lf\n", 
	//	duration_sec, overall_count, (double) overall_count / (duration_sec * 1000000));


    printf("hw_threads %d \nnum_of_vars %ld \nduration %.3f \nml_ops_per_sec %.3f \n",
	num_servers, 
	variables, 
	duration_sec,
        (double) overall_count / (duration_sec * 1000000));

    return 0;
}
