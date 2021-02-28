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
#include "ffwd.h"

#define ITERATION 1000000
#define MULTIPLIER 5003
#define MULTIPLIER2 5779
#define MAX 15485863

#define SOCKETS 2

#ifdef ALIGNED_VARIABLES
#define SIZE 1024*1024*16
#else
#define SIZE 1024*1024*256
#endif

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

#ifdef PTHREAD
	fiber_barrier_t barrier;
#else
	pthread_barrier_t barrier;
#endif

struct timespec t_start, t_end; 
int num_of_servers = 1;
int num_of_hw_threads;
int num_of_threads;
int duration;
int affinity_with_core = 2; 
int num_of_vars = SIZE;

static volatile int stop;

#ifdef ALIGNED_VARIABLES
typedef struct shared_data_t 
{
   int element;
   char padding[64-4];
} shared_data __attribute__((aligned(64)));

volatile shared_data variable[SIZE] = {0};

#elif NUMA_ALLOC_VARIABLES
typedef struct var_size{
	uint32_t var[16];
} var_size;

var_size** arrays;

var_size** numa_alloc_arrays(uint64_t servers, uint64_t varPerServerLocal){
	
	var_size **arr = malloc(sizeof(var_size*) * servers);
	
	for(int i=0; i<servers; i++){
		// This only works runnning on a 2 socket machine
		if(i == (servers - 1)){
			varPerServerLocal = num_of_vars - (i - 1) * varPerServerLocal;
		}
		arr[i] = numa_alloc_onnode(sizeof(var_size) * varPerServerLocal, i % SOCKETS);
		// Zero the array
		memset(arr[i], 0, sizeof(var_size) * varPerServerLocal);
	}

	return arr;
}

uint64_t ffwd_incr(uint64_t server, uint64_t addr) {
	arrays[server][addr].var[0]++;
	return 0;
}

#else
volatile int variable[SIZE] = {0};
#endif

int client_work;

#if !defined(NUMA_ALLOC_VARIABLES)
uint64_t increment (uint64_t a){

#ifdef ALIGNED_VARIABLES
    variable[a].element++;
#else
    variable[a]++;
#endif

    return a;
}
#endif

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



void* client(void *input_data){

    data* mydata = (data *) input_data;
    mydata->ops = 0;

    int i = 0;
    int servers = num_of_servers;
    uint64_t return_value; //this is going to hold the &increment return value from ffwd_exec

#ifdef PTHREAD
    pthread_barrier_wait(&barrier);
#else
    fiber_barrier_wait(&barrier);
#endif
    int randno = rand();
    uint64_t server_to_call, index_to_increment;
    server_to_call = randno % servers;

    int max_reached = 0;
    uint64_t client_poll_cycles_accumulator = 0, start, end;
    volatile uint64_t counter = 0;
    int rand_work = rand() % ((client_work+50)/10);

#ifdef NUMA_ALLOC_VARIABLES
	int mult = rand();
	int server_chunk = num_of_vars / num_of_servers;
	int last_chunk = (num_of_servers - 1) * server_chunk;
	int addr;
#endif 

#if defined(INCREASING_VARS) || defined(NUMA_ALLOC_VARIABLES) 
    int vars = num_of_vars;
    int rem = (vars % num_of_servers) ? 1 : 0;
    int vars_per_server = (vars/num_of_servers) + rem;

    randno = randno % vars;
#else
    randno = ((randno + MULTIPLIER) % MAX);
#endif

    while(mydata->ops != ITERATION){
     
        server_to_call = (randno % servers);
        index_to_increment = server_to_call*32;

        start = __rdtsc();

#ifdef NUMA_ALLOC_VARIABLES
	addr = randno - (server_chunk * (randno/vars_per_server));
        FFWD_EXEC(randno/vars_per_server, ffwd_incr, return_value, 2, randno/vars_per_server, addr)
#elif INCREASING_VARS
	FFWD_EXEC(randno/vars_per_server, increment, return_value, 1, randno)
#else
        FFWD_EXEC(server_to_call, increment, return_value, 1, index_to_increment)
#endif

        end = __rdtsc();

        client_poll_cycles_accumulator += end - start;

#ifdef PROFILE_CLIENT_LATENCY
	//if (mydata->id == 0 && (end-start) < 11000) printf("found!\n");
	mydata->latency_distribution[get_bucket(end - start)]++;
#endif

        //Do other work
        for(int j = 0; j < client_work + rand_work; j++){
            counter++;
            //__asm__ __volatile__("rep;nop;": : :"memory"); 
        }

#if defined(INCREASING_VARS)
        randno = ((randno + MULTIPLIER) % vars);
#else
	randno = ((randno + MULTIPLIER) % MAX);
#endif
        mydata->ops++;
    }

//    printf("[%d] - waiting for the end\n", mydata->id);

    //Update client poll cycles shared variable
    mydata->poll_cycles = client_poll_cycles_accumulator / mydata->ops;
    mydata->local_ops = counter;

    return 0;
}

int main (int argc, char ** argv){
    if(numa_available() < 0){
        printf("System does not support NUMA API!\n");
    }

    int c, i;
    while((c = getopt(argc, argv, "t:d:s:w:p:g:h:")) != -1){
        switch (c)
        {
            case 't':
            {
                num_of_threads = atoi(optarg);
                break;
            }
            case 'd':
            {
                duration = atoi(optarg);
                break;
            }
            case 's':
            {
                num_of_servers = atoi(optarg);
                break;
            }
            case 'p':
            {
                num_of_hw_threads = atoi(optarg);
                break;
            }
	    case 'w':
            {
                client_work = atoi(optarg);
                break;
            }
            case 'g':
            {
                num_of_vars = atoi(optarg);
                break;
            }
        }
    }

    num_of_hwth_to_check = num_of_threads+1;

    #ifdef EXP_LOAD
        printf("load exponential\n");
    #else 
        printf("load uniform\n");        
    #endif

    ffwd_init();
    // pass the number of threads including the server threads upto that thread count
    // ex: for 4 servers and 10 clients use 11 (10 fits in one socket and here we have one server per socket)
#ifndef PTHREAD	
	fiber_manager_init(num_of_hw_threads);
	// fiber_manager_init(num_of_hwth_to_check);
#endif

    data **th_data;
    th_data = (data **) malloc(num_of_threads * sizeof(data *));

#ifdef NUMA_ALLOC_VARIABLES
	int var_per_server =  num_of_vars / num_of_servers;
	arrays = numa_alloc_arrays(num_of_servers, var_per_server);
#endif

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
    timeout.tv_sec = duration / 1000;
    timeout.tv_nsec = (duration % 1000) * 1000000;
    stop = 0;

#ifdef PTHREAD
    pthread_t **t = (pthread_t**) malloc (num_of_threads * sizeof(pthread_t*));
    pthread_barrier_init(&barrier, NULL ,num_of_threads+1);
#else
    fiber_t** t = (fiber_t**) malloc (num_of_threads * sizeof(fiber_t*));    
    fiber_barrier_init(&barrier, NULL ,num_of_threads+1);
#endif
    launch_servers(num_of_servers);


    for (i = 0; i < num_of_threads; i++){
        t[i] = ffwd_thread_create(client, (void *)(th_data[i]));
    }

#ifdef PTHREAD
    pthread_barrier_wait(&barrier);
#else
    fiber_barrier_wait(&barrier);
#endif
    clock_gettime(CLOCK_MONOTONIC, &t_start);




#ifdef PTHREAD	
    for (i = 0; i < num_of_threads; i++){

        pthread_join(*t[i], 0);
    }

    clock_gettime(CLOCK_MONOTONIC, &t_end);
#else
    for (i = 0; i < num_of_threads; i++){

        fiber_join(t[i], 0);
    }

    clock_gettime(CLOCK_MONOTONIC, &t_end);
    fiber_join_and_shutdown();
#endif
    ffwd_shutdown();


    uint64_t nr_ops = 0, nr_poll_cycles = 0;
    for (i = 0;  i < num_of_threads; i++) {
        nr_ops += (th_data[i]->ops);
	nr_poll_cycles += (th_data[i]->poll_cycles);
    }

    uint64_t ops_done = 0;
    
#ifdef NUMA_ALLOC_VARIABLES 
	
	uint64_t server_sum = 0;
	uint64_t overall_count_server = 0;
	for(int i = 0; i < num_of_servers; i++){
		server_sum = 0;
		if(i == (num_of_servers- 1)){
			var_per_server = num_of_vars - (i - 1) * var_per_server;
		}
		for(int j = 0; j < var_per_server; j++){
			server_sum += arrays[i][j].var[0];
		}
		// printf("server: %d, ops: %ld\n", i, server_sum);
		overall_count_server += server_sum;
	}
	//assert(nr_ops == overall_count_server);
	//printf("########### nr_ops [%ld] != overall_count_server [%ld]\n", nr_ops, overall_count_server);
#else
	
	for (i = 0; i < SIZE; i++) {
	#ifdef ALIGNED_VARIABLES
	    ops_done += variable[i].element;
	#else
	    ops_done += variable[i];
    	#endif
    }
    assert(nr_ops == ops_done);
#endif

    uint64_t start = (t_start.tv_sec * 1000000000LL) + t_start.tv_nsec;
    uint64_t finish = (t_end.tv_sec * 1000000000LL) + t_end.tv_nsec;
    uint64_t real_duration = finish - start;
    double duration_sec = (double)(real_duration) / 1000000000LL;

    uint64_t sum_clients_poll_cycles = 0;
    uint64_t sum_clients_local_mops = 0;
    uint64_t sum_clients_mops = 0;
    uint64_t clients_avg_poll_cycles = nr_poll_cycles / num_of_threads;
    uint64_t clients_avg_ops = nr_ops / num_of_threads;
    uint64_t sum_clients_ops_deviation = 0, sum_clients_poll_cycles_dev = 0;

    for(i = 0; i < num_of_threads; i++){
        sum_clients_poll_cycles += th_data[i]->poll_cycles;
        sum_clients_local_mops += th_data[i]->local_ops;
        sum_clients_mops += th_data[i]->ops;
        sum_clients_ops_deviation += (clients_avg_ops - th_data[i]->ops) * (clients_avg_ops - th_data[i]->ops);
	sum_clients_poll_cycles_dev += (clients_avg_poll_cycles - th_data[i]->poll_cycles) * (clients_avg_poll_cycles - th_data[i]->poll_cycles);
    }

    uint64_t std_dev_ops_server = sqrt(sum_clients_ops_deviation / num_of_threads);
    uint64_t std_dev_poll_cycles = sqrt(sum_clients_poll_cycles_dev / num_of_threads);

    printf("clients_nr %d \nhw_threads %d \nserver_nr %d \nduration %.3f \n", num_of_threads, num_of_hw_threads, num_of_servers, duration_sec);
    printf("num_of_vars %d \n", num_of_vars);
    printf("client_work %d \nstd_dev_ops_server %ld \nstd_dev_mops_server %.3f\n", client_work, std_dev_ops_server, std_dev_ops_server / ((double)(duration_sec*1000000LL)));
    printf("avg_cl_poll_cl %ld\nstd_dev_cl_poll_cl %ld\navg_cl_local_mops %.3f\n", sum_clients_poll_cycles / num_of_threads, std_dev_poll_cycles, (sum_clients_local_mops) / ((double)(num_of_threads*duration_sec*1000000LL)));
    printf("tot_ops %ld \nml_ops_per_sec %.3f\n", nr_ops, (nr_ops)/((double)(duration_sec*1000000LL)));

    printf("interrupt_fr 0\nserver_1_local_mops 0.000\n");
    printf("tot_server_1_increments 0 \ntot_server_2_increments 0 \nserver_2_local_mops 0.000\n");

    printf("clients_avg_mops %.3f \nserver_client_mops 0.000\n", (sum_clients_mops) / ((double)(num_of_threads*duration_sec*1000000LL)));

    printf("flat_delegation_mops %.3f\n",(ops_done)/((double)(duration_sec*1000000LL)));
    // Here doorbell_checks == doorbell_ring_nr since there is no doorbell
//    printf("doorbell_checks %ld\ndoorbell_ring_nr %ld\ndoorbell_zero_work_polls %ld\n", doorbell_ring_nr, doorbell_ring_nr, doorbell_zero_work_polls);
//    printf("doorbell_ring_perc %.3f\nzero_work_polls_perc %.3f\n", ((double)doorbell_ring_nr) / ((double)doorbell_ring_nr), ((double)doorbell_zero_work_polls) / ((double)doorbell_ring_nr));

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
	printf("%ld-%ld %.5f\n", get_lower_bound(i), get_upper_bound(i), ((double)latency_distribution_accumulator[i]) / ((double)ops_done));
    }
    
#endif

    return 0;
}
