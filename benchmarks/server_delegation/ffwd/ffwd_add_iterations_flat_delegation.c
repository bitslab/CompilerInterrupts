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
#include "ci_lib.h"

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


#ifdef PROFILE_SERVER_POLL_LATENCY
#define OVERLOADED_SET_SIZE 8
int overloaded_set[] = {0, 8, 16, 24, 32, 40, 48, 53};

#endif

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

fiber_barrier_t barrier;

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

int client_work, interrupt_fr;
uint64_t doorbell_checks = 0;

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


uint64_t  __attribute__ ((noinline)) update_cycles(uint64_t client_poll_cycles_accumulator, uint64_t ops){
    return client_poll_cycles_accumulator / (ops + 1);
}

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


void interrupt_handler(long ic){

#ifdef DEBUG_YIELD  
    //printf("[%d] client yield\n", test);
    test++;
#endif
    // yield the CPU
        fiber_yield();

#ifdef DEBUG_YIELD
    //printf("[%d] client resume\n", test);
    test++;
#endif
}


void* client_server(void *input_data){
   
    ci_disable();

    data* mydata = (data *) input_data;
    mydata->ops = 0;
    
    int servers = num_of_servers;
    uint64_t return_value; //this is going to hold the &increment return value from ffwd_exec

/*###### profiling server latency ######*/
//    uint64_t server_latency[56];
//    int server_call_count[56]; 
//    for (int i = 0; i < servers; i++){
//	    server_latency[i] = 0;
//	    server_call_count[i] = 0;
//    }
/*###### END profiling server latency ######*/

    fiber_barrier_wait(&barrier);

    int randno = rand();
    uint64_t server_to_call, index_to_increment;

    server_to_call = mydata->id;

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
    
    //int server_set = (randno % servers) + 1;
    int server_set = 1;
    ci_enable();
    //lc_disabled_count = 0;

    while (mydata->ops != ITERATION){

#ifdef AFFINITY_LOAD
	// Affinity based load
        if (mydata->ops % 100 > affinity_with_core){
            server_to_call = (randno % servers);
	} 
	else { 
            server_to_call = mydata->id % servers;           
	}

#elif HOT_SERVERS_LOAD
	// Hot/Cold-servers based load
        if (mydata->ops % 100 > 25){
            server_to_call = (randno % servers);
	} 
	else { 
            server_to_call = overloaded_set[(randno % OVERLOADED_SET_SIZE)];
	}

	// Exponential load
/*
	server_to_call = (randno % server_set);
	if (mydata->ops % 16384 == 0) server_set = (server_set + 1) % (servers + 1); 
	if (server_set == 0) server_set = 1;
*/

#elif EXPONENTIAL_LOAD
	// Exponential load 2
	for (int j=0; j < servers; j++) {
		//if(randno > MAX / (1<<(j+1))){
		if(randno > vars / pow(1.33, j+1)){
			server_to_call = j;
			break;
		}
	}

#else
	// Uniform load 
        server_to_call = (randno % servers);
#endif

	index_to_increment = server_to_call*32;

        start = __rdtsc();

	ci_disable();

#ifdef NUMA_ALLOC_VARIABLES
	addr = randno - (server_chunk * (randno/vars_per_server));
	#ifdef EXPONENTIAL_LOAD
        	FFWD_EXEC(server_to_call, ffwd_incr, return_value, 2, server_to_call, randno % vars_per_server)
	#else
        	FFWD_EXEC(randno/vars_per_server, ffwd_incr, return_value, 2, randno/vars_per_server, addr)
	#endif
#elif INCREASING_VARS
	FFWD_EXEC(randno/vars_per_server, increment, return_value, 1, randno)
#else
        FFWD_EXEC(server_to_call, increment, return_value, 1, index_to_increment)
#endif

        ci_enable(); 
        end = __rdtsc();
	
//	if(mydata->id%2 == 1) printf("[%d] %ld work done!\n", mydata->id, mydata->ops);
//	if(mydata->ops % 100000 == 0) printf("[%d] %ld work done!\n", mydata->id, mydata->ops);

        client_poll_cycles_accumulator += end - start;
//	server_latency[server_to_call] += client_poll_cycles_accumulator; 
//	server_call_count[server_to_call]++;

#ifdef PROFILE_CLIENT_LATENCY
	mydata->latency_distribution[get_bucket(end - start)]++;
#endif
	
        //Do other work
        for(int j = 0; j < client_work + rand_work; j++){
            counter++;
            //__asm__ __volatile__("rep;nop;": : :"memory"); 
    	}

#ifdef INCREASING_VARS
        randno = ((randno + MULTIPLIER) % vars);
#else
	randno = ((randno + MULTIPLIER) % MAX);
#endif
    	mydata->ops++;

    }
    
    ci_disable();
//    printf("[%d] - finished\n", mydata->id);
    //Update client poll cycles shared variable
    mydata->poll_cycles = update_cycles(client_poll_cycles_accumulator, mydata->ops);
    mydata->local_ops = counter;

//    for (int i = 0; i < servers; i++){
//    	printf("[%d] avg_latency_server[%i] = %ld\n", mydata->id, i, server_latency[i]/server_call_count[i]);
//    }
    
    return 0;
}

void* client(void *input_data){

    ci_disable();

    data* mydata = (data *) input_data;
    mydata->ops = 0;

    int servers = num_of_servers;
    uint64_t return_value; //this is going to hold the &increment return value from ffwd_exec

    fiber_barrier_wait(&barrier);

    int randno = rand();
    uint64_t server_to_call, index_to_increment;
    server_to_call = randno % servers;

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

#ifdef INCREASING_VARS
        randno = ((randno + MULTIPLIER) % vars);
#else
	randno = ((randno + MULTIPLIER) % MAX);
#endif
        mydata->ops++;
    }

//    printf("[%d] - waiting for the end\n", mydata->id);

    //Update client poll cycles shared variable
//    mydata->poll_cycles = client_poll_cycles_accumulator / mydata->ops;
    mydata->poll_cycles = update_cycles(client_poll_cycles_accumulator, mydata->ops);
    mydata->local_ops = counter;

    return 0;
}

int main (int argc, char ** argv){
    if(numa_available() < 0){
        printf("System does not support NUMA API!\n");
    }

    int c, i;
    while((c = getopt(argc, argv, "a:s:t:d:w:i:p:g:h:")) != -1){
        switch (c)
        {
            case 's':
            {
                num_of_servers = atoi(optarg);
                break;
            }
	    case 'a':
	    {
	    	affinity_with_core = atoi(optarg);
		assert(0 < affinity_with_core && affinity_with_core < 100);
		break;	
	    }
            case 't':
            {
                num_of_threads = atoi(optarg);
                break;
            }
            case 'p':
            {
                num_of_hw_threads = atoi(optarg);
                break;
            }
            case 'd':
            {
                duration = atoi(optarg);
                break;
            }
            case 'w':
            {
                client_work = atoi(optarg);
                break;
            }
            case 'i':
            {
                interrupt_fr = atoi(optarg);
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

    int num_of_clients = num_of_threads;
    int num_of_standard_clients = num_of_clients - num_of_servers;
	num_of_standard_clients = num_of_clients;

    ffwd_init();
    // pass the number of threads including the server threads upto that thread count
    // ex: for 4 servers and 10 clients use 11 (10 fits in one socket and here we have one server per socket)
    fiber_manager_init(num_of_hw_threads);

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

    // The +1 is due to the server fiber
    fiber_t** t = (fiber_t**) malloc ((num_of_clients)* sizeof(fiber_t*));
    // Wait all the clients + the main thread
    fiber_barrier_init(&barrier, NULL , num_of_threads + 1);

    int flat_server_core[56];

    // Create the server fibers
    for (i = 0; i < num_of_servers; i++){
        flat_server_core[i] = launch_server_flat_delegation();
//        printf("server %d on core %d\n", i, flat_server_core[i]);
    }

    register_ci(interrupt_handler);
    ci_disable();
    int num_of_client_servers = 0;
#ifdef FLAT_DELEGATION
    for(i=0; i < num_of_clients; i++){
    	if( i%num_of_hw_threads < num_of_servers ){
	    t[i] = ffwd_thread_create_and_pin(client_server, (void*)(th_data[i]), flat_server_core[i%num_of_servers]);
	    num_of_client_servers++;
	} else
	    t[i] = ffwd_thread_create(client, (void *)(th_data[i]));
    }
#else
    // Pin the special first clients to the same servers core
    for(i = 0; i < num_of_servers; i++){
        t[i] = ffwd_thread_create_and_pin(client_server, (void *)(th_data[i]), flat_server_core[i]);
    }

    // Create the remaining standard client fibers
    for (i = num_of_servers; i < num_of_threads; i++){
        t[i] = ffwd_thread_create(client, (void *)(th_data[i]));
    }

#endif

    fiber_barrier_wait(&barrier);

    clock_gettime(CLOCK_MONOTONIC, &t_start);
    

    // The +1 is due to the server fiber
    for (i = 0; i < num_of_clients; i++){
        fiber_join(t[i], 0);
    }

    clock_gettime(CLOCK_MONOTONIC, &t_end);

    fiber_join_and_shutdown();
    ffwd_shutdown();

    uint64_t ops_requested = 0, ops_done = 0;

    for (i = 0; i < num_of_threads; i++){
    	ops_requested += th_data[i]->ops;
    }

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
	//assert(ops_requested == overall_count_server);
	//printf("########### ops_requested [%ld] != overall_count_server [%ld]\n", ops_requested, overall_count_server);
#else

    for (i = 0; i < SIZE; i++) {
	#ifdef ALIGNED_VARIABLES
	    ops_done += variable[i].element;
	#else
	    ops_done += variable[i];
    	#endif
    }
	
    assert(ops_requested == ops_done);
#endif 

    uint64_t nr_ops = 0, nr_poll_cycles = 0;
    uint64_t nr_server_1_ops = th_data[0]->ops;
    uint64_t nr_server_2_ops = th_data[1]->ops;

    for (i = 0;  i < num_of_threads; i++) {
        nr_ops += (th_data[i]->ops);
	nr_poll_cycles += (th_data[i]->poll_cycles);
    }

#ifdef EXCLUSIVE
    for (i = 0; i < num_of_client_servers; i++) {
    	nr_ops -= ITERATION;
    }
#endif

    uint64_t start = (t_start.tv_sec * 1000000000LL) + t_start.tv_nsec;
    uint64_t finish = (t_end.tv_sec * 1000000000LL) + t_end.tv_nsec;
    uint64_t real_duration = finish - start;
    double duration_sec = (double)(real_duration) / 1000000000LL;

    uint64_t sum_clients_poll_cycles = 0;
    uint64_t sum_clients_local_mops = 0;
    uint64_t sum_clients_mops = 0;
    uint64_t clients_avg_ops = (nr_ops) / num_of_standard_clients;
    uint64_t clients_avg_poll_cycles = (nr_poll_cycles) / num_of_standard_clients;
    uint64_t sum_clients_ops_dev = 0, sum_clients_poll_cycles_dev = 0;

    for(i = 0; i < num_of_threads; i++){
        sum_clients_poll_cycles += th_data[i]->poll_cycles;
        sum_clients_local_mops += th_data[i]->local_ops;
        sum_clients_mops += th_data[i]->ops;
        sum_clients_ops_dev += (clients_avg_ops - th_data[i]->ops) * (clients_avg_ops - th_data[i]->ops); 
	sum_clients_poll_cycles_dev += (clients_avg_poll_cycles - th_data[i]->poll_cycles) * (clients_avg_poll_cycles - th_data[i]->poll_cycles);
    }

    uint64_t std_dev_ops_server = sqrt(sum_clients_ops_dev / num_of_standard_clients);
    uint64_t std_dev_poll_cycles = sqrt(sum_clients_poll_cycles_dev / num_of_standard_clients);


      char name[500];
      sprintf(name, "results.txt");
      FILE *fp = fopen(name, "w");
      if(!fp) {
        printf("Could not open file %s to write\n", name);
        exit(1);
      }


    fprintf(fp, "clients_nr %d \nhw_threads %d \nserver_nr %d \nduration %.3f \ninterrupt_fr %d\n", num_of_clients, num_of_hw_threads, num_of_servers, duration_sec, interrupt_fr);
    fprintf(fp, "num_of_vars %d \n", num_of_vars);
    fprintf(fp, "client_work %d \nstd_dev_ops_server %ld \nstd_dev_mops_server %.3f\n", client_work, std_dev_ops_server, std_dev_ops_server / ((double)(duration_sec*1000000LL)));
    fprintf(fp, "avg_cl_poll_cl %ld\nstd_dev_cl_poll_cl %ld\navg_cl_local_mops %.3f\n", sum_clients_poll_cycles / num_of_standard_clients, std_dev_poll_cycles, (sum_clients_local_mops) / ((double)(num_of_standard_clients*duration_sec*1000000LL)));
    fprintf(fp, "tot_ops %ld \nml_ops_per_sec %.3f \n", nr_ops, (nr_ops)/((double)(duration_sec*1000000LL)));
    fprintf(fp, "tot_server_1_increments %ld\nserver_1_local_mops %.3f \n", nr_server_1_ops, (nr_server_1_ops) / ((double)(duration_sec*1000000LL)));
    fprintf(fp, "tot_server_2_increments %ld\nserver_2_local_mops %.3f \n", nr_server_2_ops, (nr_server_2_ops) / ((double)(duration_sec*1000000LL)));
    fprintf(fp, "clients_avg_mops %.3f \nserver_client_mops %.3f\n", (sum_clients_mops) / ((double)(num_of_standard_clients*duration_sec*1000000LL)), (nr_server_1_ops) / ((double)(duration_sec*1000000LL)));
    fprintf(fp, "flat_delegation_mops %.3f\n", (ops_done)/((double)(duration_sec*1000000LL)));

#ifdef PROFILE_CLIENT_LATENCY
    int latency_distribution_accumulator[NUM_BUCKETS] = {0};

    for(int k = 0; k < num_of_clients; k++){
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

/*
doorbell_ring_perc = # of times the doorbell ranged / # of times we checked the doorbell
zero_work_poll_perc = # of times the doorbell ranged but there was no work to do / # of times the doorbell ranged 
*/

//    printf("doorbell_checks %ld\ndoorbell_ring_nr %ld\ndoorbell_zero_work_polls %ld\n", doorbell_checks, doorbell_ring_nr, doorbell_zero_work_polls);
//    printf("doorbell_ring_perc %.3f\nzero_work_polls_perc %.3f\n", ((double)doorbell_ring_nr) / ((double)doorbell_checks), ((double)doorbell_zero_work_polls) / ((double)doorbell_ring_nr));
    
    return 0;
}
