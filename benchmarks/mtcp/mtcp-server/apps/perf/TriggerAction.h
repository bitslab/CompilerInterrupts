#include <unistd.h>
#include "mtcp_api.h"
#include "TriggerActionDecl.h"

  void init_stats() {
#ifdef CI
    printf("CI version of app is running\n");
    register_ci(compiler_interrupt_handler);
#else
    printf("Original version of app is running\n");
#endif
  }

  void compiler_interrupt_handler(long ic) {
    if((void *)mtcp_ctx->mtcp_thr_ctx) {
      //printf("Calling CI RunMainLoop, mtcp context: %p\n", (void *)(mtcp_ctx->mtcp_thr_ctx));
      RunMainLoop((void *)mtcp_ctx->mtcp_thr_ctx);
    }
    else
      printf("MTCP context not initialized yet");
  }

#if 0

//#ifdef INTV_SAMPLING /* Prints every interval stat, always prints ret_inst & time cycles */
//#ifdef PERF_CNTR /* reads perf counters for ret_inst & time cycles */
//#ifdef PAPI /* Uses hardware CI */
//#ifdef LIBFIBER /* for user level preemptive multitasking mode */
//#ifdef AVG_STATS /* compute avg over each sample on-the-go */

#ifdef LIBFIBER
#undef INTV_SAMPLING
#undef PERF_CNTR
#undef PAPI
#undef AVG_STATS
#endif

#ifdef INTV_SAMPLING /* Export every interval stats */
#define PERF_CNTR
#else
#undef RUNNING_MEDIAN
#endif

#ifdef INTV_SAMPLING
__thread uint64_t *buffer_tsc = NULL;
__thread long *buffer_ret_ic = NULL;
__thread long *buffer_ic = NULL;
#endif

/* For Trigger */
#ifdef RUNNING_MEDIAN
#define SAMPLE_CT 100
__thread uint64_t small_buffer_tsc[SAMPLE_CT];
__thread long small_buffer_ret_ic[SAMPLE_CT];
__thread long small_buffer_ic[SAMPLE_CT];
__thread int64_t small_sample_count = -1;
__thread int64_t sample_count = 0;
#else
__thread int64_t sample_count = -1;
#endif
__thread uint64_t last_tsc = 0;
__thread uint64_t last_ret_ic = 0;
__thread double last_avg_ic = 0;
__thread double last_avg_ret_ic = 0;
__thread double last_avg_tsc = 0;
__thread int counter_id = 0;
int counter_id_alloc;
int __get_id_and_increment() {
  //using the gcc atomic built-ins
  return __sync_fetch_and_add(&counter_id_alloc, 1);
}

// To heapify a subtree rooted with node i which is
// an index in arr[]. n is size of heap
void heapify(long arr[], int n, int i)
{
    int largest = i; // Initialize largest as root
    int l = 2*i + 1; // left = 2*i + 1
    int r = 2*i + 2; // right = 2*i + 2

    // If left child is larger than root
    if (l < n && arr[l] > arr[largest])
        largest = l;

    // If right child is larger than largest so far
    if (r < n && arr[r] > arr[largest])
        largest = r;

    // If largest is not root
    if (largest != i)
    {
        int tmp = arr[i];
        arr[i] = arr[largest];
        arr[largest] = tmp;

        // Recursively heapify the affected sub-tree
        heapify(arr, n, largest);
    }
}

// main function to do heap sort
void heapSort(long arr[], int n)
{
    // Build heap (rearrange array)
    for (int i = n / 2 - 1; i >= 0; i--)
        heapify(arr, n, i);

    // One by one extract an element from heap
    for (int i=n-1; i>=0; i--)
    {
        // Move current root to end
        int tmp = arr[0];
        arr[0] = arr[i];
        arr[i] = tmp;

        // call max heapify on the reduced heap
        heapify(arr, i, 0);
    }
}

#ifdef LIBFIBER

/************************************************ LibFiber ******************************************************/
  void init_stats(int index) {
    register_ci(compiler_interrupt_handler);
  }

  void compiler_interrupt_handler(long ic) {
    fiber_yield();
  }

  void print_timing_stats(void) {
  }

#elif defined(AVG_STATS)

  /* this function gets called from all threads, but twice from main. disregard it the second time */
  void init_stats(int index) {

    //printf("1. Init stats called with index: %d\n", index);

    /* first call from main */
    static int is_main_first_occ = 1;

    /* return if this is the second call to main */
    if(index == 0 && is_main_first_occ > 1) {
      //errs() << "Main called again. " << is_main_first_occ << " times\n";
      return;
    }

    counter_id = __get_id_and_increment(); // set counter_id of main to 1
    //printf("2. (not main) Init stats called with index: %d\n", index);

    register_ci(compiler_interrupt_handler);

    #ifdef PERF_CNTR

      /* Setting thread affinity when taking interval statistics with respect to hardware performance counters */
      pthread_t thread = pthread_self();
      int max_cpus = sysconf(_SC_NPROCESSORS_ONLN);
      cpu_set_t cpuset;
      CPU_ZERO(&cpuset);
      if(index > max_cpus) {
        printf("WARNING: Thread id is greater than the number of CPUs.\n");
        index = index % max_cpus;
      }
      CPU_SET(index, &cpuset);
      if(0 != pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset)) {
        printf("Unable to set thread affinity\n");
      }

      if(index == 0) { /* for first call to main */
        struct perf_event_attr attr;
        memset(&attr, 0, sizeof(struct perf_event_attr));
        attr.type = PERF_TYPE_HARDWARE;
        attr.size = sizeof(struct perf_event_attr);
        attr.config = PERF_COUNT_HW_INSTRUCTIONS;
        attr.inherit = 1;
        attr.pinned = 1;
        attr.exclude_idle = 1;
        attr.exclude_kernel = 1;
        int perf_fds = perf_event_open(&attr, getpid(), -1, -1, 0);
        ioctl(perf_fds, PERF_EVENT_IOC_RESET, 0); // Resetting counter to zero
        ioctl(perf_fds, PERF_EVENT_IOC_ENABLE, 0); // Start counters
      }

      #ifdef INTV_SAMPLING
        if(!buffer_tsc) 
          buffer_tsc = malloc(BUFFER_SIZE*sizeof(uint64_t));
        if(!buffer_ret_ic) 
          buffer_ret_ic = malloc(BUFFER_SIZE*sizeof(long));
        if(!buffer_ic) 
          buffer_ic = malloc(BUFFER_SIZE*sizeof(long));
      #endif

      /* increment this counter in the first call from main */
      if(index == 0)
        is_main_first_occ++;

    #endif
  }

#ifndef RUNNING_MEDIAN
  /*********************** For Trigger, with every interval stat being directly stored **********************/
  void compiler_interrupt_handler(long ic) {

    #ifdef PERF_CNTR
      /* get the time stamp */
      uint64_t rax_lo, rdx_hi, aux_cpuid;

      asm volatile ( "rdtscp\n" : "=a" (rax_lo), "=d" (rdx_hi), "=c" (aux_cpuid) : : );
      uint64_t curr_tsc = (rdx_hi << 32) + rax_lo;
      //uint64_t curr_ret_ic = 0; /* not using this value */

      int ecx = (1<<30); // For instruction count // https://software.intel.com/en-us/forums/software-tuning-performance-optimization-platform-monitoring/topic/595214
      asm volatile("rdpmc\n" : "=a"(rax_lo), "=d"(rdx_hi) : "c"(ecx));
      uint64_t curr_ret_ic = (rax_lo | (rdx_hi << 32));

      /* TSC & RET IC are not absolute values, but the interval is defined by the difference between the current & the last */
      if(sample_count >= 0) {
        uint64_t tsc = curr_tsc - last_tsc;
        uint64_t ret_ic = curr_ret_ic - last_ret_ic;

        #ifdef INTV_SAMPLING
          if(sample_count < BUFFER_SIZE) {
            if(buffer_tsc)
              buffer_tsc[sample_count] = tsc;
            if(buffer_ret_ic)
              buffer_ret_ic[sample_count] = ret_ic;
          }
        #else
          last_avg_tsc = (double)((last_avg_tsc*sample_count) + tsc) / (sample_count+1);
          last_avg_ret_ic = (double)((last_avg_ret_ic*sample_count) + ret_ic) / (sample_count+1);
        #endif
      }

      /* Resetting all static variables */
      last_tsc = curr_tsc;
      last_ret_ic = curr_ret_ic;
    #endif

    #ifdef INTV_SAMPLING
      if(sample_count >= 0 && sample_count < BUFFER_SIZE) {
        if(buffer_ic)
          buffer_ic[sample_count] = ic;
      }
    #else
      if(sample_count >= 0) {
        last_avg_ic = (double)((last_avg_ic*sample_count) + ic) / (sample_count+1);
      }
    #endif

    sample_count++;
  }
#else
  /* Only for Debugging */
  /*********************** For Trigger, with every interval stat being directly stored **********************/
  void compiler_interrupt_handler(long ic) {

    #ifdef PERF_CNTR
      /* get the time stamp */
      uint64_t rax_lo, rdx_hi, aux_cpuid;

      asm volatile ( "rdtscp\n" : "=a" (rax_lo), "=d" (rdx_hi), "=c" (aux_cpuid) : : );
      uint64_t curr_tsc = (rdx_hi << 32) + rax_lo;
      //uint64_t curr_ret_ic = 0; /* not using this value */

      int ecx = (1<<30); // For instruction count // https://software.intel.com/en-us/forums/software-tuning-performance-optimization-platform-monitoring/topic/595214
      asm volatile("rdpmc\n" : "=a"(rax_lo), "=d"(rdx_hi) : "c"(ecx));
      uint64_t curr_ret_ic = (rax_lo | (rdx_hi << 32));

      /* TSC & RET IC are not absolute values, but the interval is defined by the difference between the current & the last */
      if(small_sample_count >= 0) {
        uint64_t tsc = curr_tsc - last_tsc;
        uint64_t ret_ic = curr_ret_ic - last_ret_ic;

        #ifdef INTV_SAMPLING
          if(small_sample_count < SAMPLE_CT) {
            small_buffer_tsc[small_sample_count] = tsc;
            small_buffer_ret_ic[small_sample_count] = ret_ic;
          }
          else {
            if(sample_count < BUFFER_SIZE) {
              // find median & add it to the bigger list
              heapSort(small_buffer_tsc, SAMPLE_CT);
              heapSort(small_buffer_ret_ic, SAMPLE_CT);
              uint64_t tsc_median = small_buffer_tsc[SAMPLE_CT/2];
              uint64_t ret_ic_median = small_buffer_ret_ic[SAMPLE_CT/2];
              if(buffer_tsc)
                buffer_tsc[sample_count] = tsc_median;
              if(buffer_ret_ic)
                buffer_ret_ic[sample_count] = ret_ic_median;
            }
          }
        #else
          last_avg_tsc = (double)((last_avg_tsc*sample_count) + tsc) / (sample_count+1);
          last_avg_ret_ic = (double)((last_avg_ret_ic*sample_count) + ret_ic) / (sample_count+1);
        #endif
      }

      /* Resetting all static variables */
      last_tsc = curr_tsc;
      last_ret_ic = curr_ret_ic;
    #endif

    #ifdef INTV_SAMPLING
      if(small_sample_count >=0 ) {
        if(small_sample_count < SAMPLE_CT) {
          small_buffer_ic[small_sample_count] = ic;
        }
        else {
          if(sample_count < BUFFER_SIZE) {
            // find median & add it to the bigger list
            heapSort(small_buffer_ic, SAMPLE_CT);
            uint64_t ic_median = small_buffer_ic[SAMPLE_CT/2];
            if(buffer_ic)
              buffer_ic[sample_count] = ic_median;
            sample_count++;
          }
        }
      }
    #else
      if(sample_count >= 0) {
        last_avg_ic = (double)((last_avg_ic*sample_count) + ic) / (sample_count+1);
        sample_count++;
      }
    #endif

    if(small_sample_count < SAMPLE_CT)
      small_sample_count++;
    else
      small_sample_count = 0;
  }
#endif

  void print_timing_stats() {
    ci_disable();

    //printf("PRINT_TIMING_STATS CALLED WITH INDEX: %d\n", counter_id);
    /* Print every interval */
    #ifdef INTV_SAMPLING 
      int i;
      char name[500];
      sprintf(name, "/local_home/nilanjana/temp/interval_stats/interval_stats_thread%d.txt", counter_id);

      FILE *fp = fopen(name, "w");
      if(!fp) {
        printf("Could not open file %s to write\n", name);
        exit(1);
      }
      //printf("PushSeq IC RIC TSC\n");
      fprintf(fp, "Total Samples: %d\n", sample_count);
      fprintf(fp, "PushSeq IC RIC TSC\n");

      for(i=0; i<BUFFER_SIZE && i<sample_count; i++) {
        if(buffer_ic && buffer_ret_ic && buffer_tsc) {
          //printf("%ld %ld %ld %ld\n", i, buffer_ic[i], buffer_ret_ic[i], buffer_tsc[i]);
          fprintf(fp, "%ld %ld %ld %ld\n", i, buffer_ic[i], buffer_ret_ic[i], buffer_tsc[i]);
        }
      }
#if 0
      if (buffer_ic) {
        free(buffer_ic);
        buffer_ic = NULL;
      }
      if (buffer_ret_ic) {
        free(buffer_ret_ic);
        buffer_ret_ic = NULL;
      }
      if (buffer_tsc) {
        free(buffer_tsc);
        buffer_tsc = NULL;
      }
#endif
      fclose(fp);
    #else
      #ifdef PERF_CNTR
        printf("samples:%d, avg_intv_cycles:%0.1lf, avg_intv_ic:%0.1lf\n", sample_count, last_avg_tsc, last_avg_ic);
      #else
        printf("avg_intv_ic:%0.1lf\n", last_avg_ic);
      #endif
    #endif
    ci_enable();
  }

#elif defined(PAPI)

  /*************************************** For PAPI *********************************************/
  #include <pthread.h>

  /* For PAPI */
  __thread int events[NUM_HWEVENTS] = { PAPI_TOT_CYC, PAPI_TOT_INS };
  int event_set[MAX_COUNT];

  void init_stats(int index) {

    /* first call from main */
    static int is_main_first_occ = 1;

    /* return if this is the second call to main */
    if(index == 0 && is_main_first_occ > 1)
      return;

    if(index == 0)
      instruction_counter_init();

    /* increment this counter in the first call from main */
    if(index == 0)
      is_main_first_occ++;

    instruction_counter_register_thread();

    /* Setting thread affinity when taking interval statistics with respect to hardware performance counters */
    pthread_t thread = pthread_self();
    int max_cpus = sysconf(_SC_NPROCESSORS_ONLN);
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    if(index > max_cpus) {
      printf("WARNING: Thread id is greater than the number of CPUs.\n");
      index = index % max_cpus;
    }
    CPU_SET(index, &cpuset);
    if(0 != pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset)) {
      printf("Unable to set thread affinity\n");
    }

    #ifdef INTV_SAMPLING
      if(!buffer_tsc) 
        buffer_tsc = malloc(BUFFER_SIZE*sizeof(uint64_t));
      if(!buffer_ret_ic) 
        buffer_ret_ic = malloc(BUFFER_SIZE*sizeof(long));
    #endif
  }

  void hw_interrupt_handler(long long tot_inst, long long tot_cyc) {

    if(sample_count >= 0) {
      #ifdef INTV_SAMPLING
        if(sample_count >= 0 && sample_count < BUFFER_SIZE) {
          if(buffer_tsc)
            buffer_tsc[sample_count] = tot_cyc;
          if(buffer_ret_ic)
            buffer_ret_ic[sample_count] = tot_inst;
        }
      #else
        last_avg_tsc = (double)((last_avg_tsc*sample_count) + tot_cyc) / (sample_count+1);
        last_avg_ret_ic = (double)((last_avg_ret_ic*sample_count) + tot_inst) / (sample_count+1);
      #endif
    }

    sample_count++;
  }

  void papi_interrupt_handler(int i, void *v1, long_long ll, void *v2) {
    long long counter_values[NUM_HWEVENTS];
    if (PAPI_read(event_set[counter_id], counter_values) != PAPI_OK){
      perror("PAPI: failed to read counter...");
      return;
    }
    //assert(counter_values[TOT_INST_IDX] >= 0 && counter_values[TOT_CYC_IDX] >= 0);
    //printf("Counter: %lld, Cycles: %lld\n", counter_values[TOT_INST_IDX], counter_values[TOT_CYC_IDX]);
    //hw_interrupt_handler(counter_values[TOT_INST_IDX], counter_values[TOT_CYC_IDX]);
    assert(counter_values[TOT_CYC_IDX] >= 0);
    __reset();
    hw_interrupt_handler(counter_values[TOT_INST_IDX], counter_values[TOT_CYC_IDX]);
  }

  void print_timing_stats(void) {
    /* Print every interval */
    #ifdef INTV_SAMPLING 
      int i;
      char name[500];
      sprintf(name, "/local_home/nilanjana/temp/interval_stats/interval_stats_thread%d.txt", counter_id);

      FILE *fp = fopen(name, "w");
      if(!fp) {
        printf("Could not open file %s to write\n", name);
        exit(1);
      }
      //printf("PushSeq IC RIC TSC\n");
      fprintf(fp, "Total Samples: %d\n", sample_count);
      fprintf(fp, "PushSeq IC RIC TSC\n");
      //static int first = 1;

      //if(!first)
        //return;
      //else
        //first = 0;

      for(i=0; i<BUFFER_SIZE && i<sample_count; i++) {
        if(buffer_ret_ic && buffer_tsc) {
          fprintf(fp, "%ld 0 %ld %ld\n", i, buffer_ret_ic[i], buffer_tsc[i]);
        }
      }
      fclose(fp);
    #else
      printf("samples:%d, avg_intv_cycles:%0.1lf, avg_intv_ret_ic:%0.1lf\n", sample_count, last_avg_tsc, last_avg_ret_ic);
    #endif
  }

  /* Called once in the program, from main() */
  int instruction_counter_init() {

    int retval = PAPI_library_init( PAPI_VER_CURRENT );

    if ( retval != PAPI_VER_CURRENT ){
      perror("PAPI: library failed...");
      return -1;
    }

    if (PAPI_thread_init(pthread_self) != PAPI_OK) {
      perror("PAPI: failed to init thread...");
      return -1;
    }

    memset(event_set, PAPI_NULL, sizeof(int) * MAX_COUNT);
    counter_id = __get_id_and_increment(); // set counter_id of main to 1

    return 0;
  }

  /* Called per thread */
  int instruction_counter_register_thread(){

    if(counter_id) // thread has already been registered
      return 0;
    counter_id = __get_id_and_increment();
    PAPI_register_thread();

    /*set domain*/
    if (PAPI_set_domain(PAPI_DOM_USER) != PAPI_OK) {
      perror("PAPI: domain set failed...");
      return -1;
    }
    /* Create an EventSet */ 
    int err = PAPI_create_eventset(&event_set[counter_id]);
    if (err != PAPI_OK) {
      perror("PAPI: event set failed...");
      printf("create eventset failure code: %d\n", err);
      return -1;
    }

    int event_codes[NUM_HWEVENTS] = {PAPI_TOT_INS, PAPI_TOT_CYC};
    if (PAPI_add_events(event_set[counter_id], event_codes, NUM_HWEVENTS) != PAPI_OK) {
      perror("PAPI: add events failed...");
      return -1;
    }

    int ret = instruction_counter_set_handler(papi_interrupt_handler);

    return ret;
  }

  int instruction_counter_set_handler(ic_overflow_handler_t handler){
    //printf("Using PAPI interval threshold: %d\n", IC_THRESHOLD);
    //printf("Setting handler for thread %d\n", counter_id);
    int ret = PAPI_overflow(event_set[counter_id], PAPI_TOT_CYC, IC_THRESHOLD, 0, handler);
    //printf("Have set handler for thread %d\n", counter_id);
    if (ret != PAPI_OK){
      printf("PAPI_overflow returned : %d for counter id %d\n", ret, counter_id);
      perror("PAPI: failed to register handler function for overflow...");
      return -1;
    }
    return instruction_counter_start();
  }

  int __reset() {
    if (PAPI_reset(event_set[counter_id]) != PAPI_OK){
      perror("PAPI: failed to read counter...");
      return -1;
    }
    else{
      return 0;
    }
  }

  int instruction_counter_start() {
    //printf("Starting counter for thread %d\n", counter_id);
    int ret = PAPI_start(event_set[counter_id]);
    //printf("Started counter for thread %d\n", counter_id);
    if (ret != PAPI_OK && ret != PAPI_EISRUN) {
      perror("PAPI: failed to start counters...");
      printf("start counters failure code %d\n", ret);
      return -1;
    }
    return 0;
  }

  int instruction_counter_stop() {
    long long counter_values[NUM_HWEVENTS];
    printf("PAPI stop for thread %d\n", counter_id);
    if (PAPI_stop(event_set[counter_id], counter_values) != PAPI_OK) {
      perror("PAPI: failed to stop counter...");
      return -1;
    }
    //printf("Counter at stop: %lld\n", counter_values[TOT_INST_IDX]);
    return 0;
  }

#else

  /************************************* Default implementations ***********************************/
  void init_stats(int index) {
  }

  void print_timing_stats(void) {
  }

#endif
#endif
