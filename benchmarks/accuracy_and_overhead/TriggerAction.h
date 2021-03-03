#include <unistd.h>
#include <sys/types.h>
#include "TriggerActionDecl.h"

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
#endif

#ifdef INTV_SAMPLING
__thread uint64_t *buffer_tsc = NULL;
__thread long *buffer_ret_ic = NULL;
__thread long *buffer_ic = NULL;
#endif

__thread uint64_t last_tsc = 0;
__thread uint64_t last_ret_ic = 0;
__thread double last_avg_ic = 0;
__thread double last_avg_ret_ic = 0;
__thread double last_avg_tsc = 0;

__thread int counter_id = 0;
int counter_id_alloc = 0;
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

#elif defined(PROFILE)

/************************************************ Profiling ******************************************************/
  __thread int ci_count = 0;
  __thread struct timeval g_tv_prev;
  void init_stats(int index) {
#ifdef SYS_gettid
    counter_id = syscall(SYS_gettid);
#else
    #error "SYS_gettid unavailable on this system"
#endif
    gettimeofday((struct timeval *) &g_tv_prev, NULL);
    register_ci(compiler_interrupt_handler);
  }

  void compiler_interrupt_handler(long ic) {
    if(ci_count == 1000000) {
      struct timeval tv_curr;
      gettimeofday(&tv_curr, NULL);
      double diff_sec = (double)((tv_curr.tv_sec - g_tv_prev.tv_sec)*1000000 + (tv_curr.tv_usec - g_tv_prev.tv_usec))/1000000;
      g_tv_prev.tv_sec = tv_curr.tv_sec;
      g_tv_prev.tv_usec = tv_curr.tv_usec;

      printf("Thread %d: 1000000 CI took %lf sec\n", counter_id, diff_sec);
      ci_count = 0;
    }
    else {
      ci_count++;
    }
  }

  void print_timing_stats(void) {
    struct timeval tv_curr;
    gettimeofday(&tv_curr, NULL);
    double diff_sec = (double)((tv_curr.tv_sec - g_tv_prev.tv_sec)*1000000 + (tv_curr.tv_usec - g_tv_prev.tv_usec))/1000000;
    printf("Thread %d: %d CI took %lf sec\n", counter_id, ci_count, diff_sec);
  }

#elif defined(INTV_SAMPLING)

  __thread uint64_t residue_intv = 0;

  void ci_disable_fn() {
    uint64_t rax_lo, rdx_hi, aux_cpuid;

    if(last_tsc) {
      asm volatile ( "rdtscp\n" : "=a" (rax_lo), "=d" (rdx_hi), "=c" (aux_cpuid) : : );
      residue_intv += ((rdx_hi << 32) + rax_lo) - last_tsc;
    }

    last_tsc=0;
    //compiler_interrupt_handler(0);
  }

  void ci_enable_fn() {
    uint64_t rax_lo, rdx_hi, aux_cpuid;

    asm volatile ( "rdtscp\n" : "=a" (rax_lo), "=d" (rdx_hi), "=c" (aux_cpuid) : : );
    last_tsc = (rdx_hi << 32) + rax_lo;

    //int ecx = (1<<30); // For instruction count // https://software.intel.com/en-us/forums/software-tuning-performance-optimization-platform-monitoring/topic/595214
    //asm volatile("rdpmc\n" : "=a"(rax_lo), "=d"(rdx_hi) : "c"(ecx));
    //last_ret_ic = (rax_lo | (rdx_hi << 32));
  }

  void init_stats(int index) {

    /* if the thread local variable has been initialized, it means this is a duplicate call for the same thread */
    if(buffer_tsc)
      return;

    /* Delete all previous interval stats files */
    char command[500];
#ifdef SYS_gettid
    sprintf(command, "exec rm -f /local_home/nilanjana/temp/interval_stats/interval_stats_thread%ld.txt", syscall(SYS_gettid));
    system(command);
#else
    #error "SYS_gettid unavailable on this system"
#endif

    if(!buffer_tsc) 
      buffer_tsc = (uint64_t *)calloc(BUF_SIZE, sizeof(uint64_t));
    //if(!buffer_ret_ic) 
      //buffer_ret_ic = (long *)malloc(BUF_SIZE*sizeof(long));
    //if(!buffer_ic) 
      //buffer_ic = (long *)malloc(BUF_SIZE*sizeof(long));

#if 0
    /* Setting thread affinity when taking interval statistics with respect to hardware performance counters */
    int cpu_id = __get_id_and_increment();
    int max_cpus = sysconf(_SC_NPROCESSORS_ONLN);
    pthread_t thread = pthread_self();
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    if(cpu_id > max_cpus) {
      printf("WARNING: Thread id is greater than the number of CPUs.\n");
      cpu_id = cpu_id % max_cpus;
    }
    CPU_SET(cpu_id, &cpuset);
    if(0 != pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset))
      printf("Unable to set thread affinity\n");
#endif

    /* This setting is done per thread (using pid parameter of perf_event_open)*/
    struct perf_event_attr attr;
    memset(&attr, 0, sizeof(struct perf_event_attr));
    attr.type = PERF_TYPE_HARDWARE;
    attr.size = sizeof(struct perf_event_attr);
    attr.config = PERF_COUNT_HW_INSTRUCTIONS;
    attr.inherit = 1;
    attr.pinned = 1;
    attr.exclude_idle = 1;
    attr.exclude_kernel = 1;
    //int perf_fds = perf_event_open(&attr, getpid(), -1, -1, 0);
    int perf_fds = perf_event_open(&attr, 0, -1, -1, 0);
    ioctl(perf_fds, PERF_EVENT_IOC_RESET, 0); // Resetting counter to zero
    ioctl(perf_fds, PERF_EVENT_IOC_ENABLE, 0); // Start counters

    register_ci(compiler_interrupt_handler);

    #if 1
    register_ci_enable_hook(ci_enable_fn);
    register_ci_disable_hook(ci_disable_fn);
    #endif
  }

  /*********************** For Trigger, with every interval stat being directly stored **********************/
  __thread unsigned int ci_count = 0;
  __thread unsigned int no_data_count = 0;
  __thread unsigned int outlier_idx = BUCKET_SIZE;
  /* Code path for getting interval statistics */
  void compiler_interrupt_handler(long ic) {

    /* get the time stamp */
    uint64_t rax_lo, rdx_hi, aux_cpuid;

    asm volatile ( "rdtscp\n" : "=a" (rax_lo), "=d" (rdx_hi), "=c" (aux_cpuid) : : );
    uint64_t curr_tsc = (rdx_hi << 32) + rax_lo;
    uint64_t tsc = curr_tsc - last_tsc + residue_intv;

    /*
    int ecx = (1<<30); // For instruction count // https://software.intel.com/en-us/forums/software-tuning-performance-optimization-platform-monitoring/topic/595214
    asm volatile("rdpmc\n" : "=a"(rax_lo), "=d"(rdx_hi) : "c"(ecx));
    uint64_t curr_ret_ic = (rax_lo | (rdx_hi << 32));
    */

    /* TSC & RET IC are not absolute values, but the interval is defined by the difference between the current & the last */
    if(buffer_tsc && last_tsc) {
      residue_intv = 0;
      if(tsc > 0 && tsc < BUCKET_SIZE) { // histogram
        buffer_tsc[tsc]++;
      } else if (tsc >= BUCKET_SIZE && outlier_idx < BUF_SIZE) {
        buffer_tsc[outlier_idx++]=tsc;
      } else no_data_count++;
    } else no_data_count++;

    /* Resetting all static variables */
    asm volatile ( "rdtscp\n" : "=a" (rax_lo), "=d" (rdx_hi), "=c" (aux_cpuid) : : );
    last_tsc = (rdx_hi << 32) + rax_lo;

    ci_count++;
  }

  void print_timing_stats() {
    ci_disable();

    /* Print every interval */
    char name[500];
#ifdef SYS_gettid
    sprintf(name, "/local_home/nilanjana/temp/interval_stats/interval_stats_thread%ld.txt", syscall(SYS_gettid));
#else
    #error "SYS_gettid unavailable on this system"
#endif


    /*
    if( access(name, F_OK ) == 0 ) {
      printf("%s already existed. Appending to it.\n", name);
    }
    */

    FILE *fp = fopen(name, "w");
    if(!fp) {
      printf("Could not open file %s to write\n", name);
      exit(1);
    }

    //printf("PushSeq IC RIC TSC\n");
    fprintf(fp, "#Total CI calls: %u\n", ci_count);
    fprintf(fp, "#Uncollected Samples: %u\n", no_data_count);
    fprintf(fp, "PushSeq IC RIC TSC\n");

    int i,j,k=0;
    if(buffer_tsc) {
      for(i=0; i<BUCKET_SIZE; i++) {
        if(buffer_tsc && buffer_tsc[i]>0) {
          for(j=0; j<buffer_tsc[i]; j++) {
            fprintf(fp, "%d %d %d %d\n", k++, 0, 0, i);
          }
        }
      }

      for(i=BUCKET_SIZE; i<outlier_idx; i++) {
        fprintf(fp, "%d %d %d %ld\n", k++, 0, 0, buffer_tsc[i]);
      }
    }

    fclose(fp);
    ci_enable();
  }

#elif defined(PERF_CNTR)
  void init_stats(int index) {

    /* This setting is done per thread (using pid parameter of perf_event_open)*/
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

    register_ci(compiler_interrupt_handler);
  }

  __thread int64_t sample_count = -1;
  void compiler_interrupt_handler(long ic) {
      /* get the time stamp */
    uint64_t rax_lo, rdx_hi, aux_cpuid;

    asm volatile ( "rdtscp\n" : "=a" (rax_lo), "=d" (rdx_hi), "=c" (aux_cpuid) : : );
    uint64_t curr_tsc = (rdx_hi << 32) + rax_lo;

    int ecx = (1<<30); // For instruction count // https://software.intel.com/en-us/forums/software-tuning-performance-optimization-platform-monitoring/topic/595214
    asm volatile("rdpmc\n" : "=a"(rax_lo), "=d"(rdx_hi) : "c"(ecx));
    uint64_t curr_ret_ic = (rax_lo | (rdx_hi << 32));

    /* TSC & RET IC are not absolute values, but the interval is defined by the difference between the current & the last */
    if(sample_count >= 0) {
      last_avg_tsc = (double)((last_avg_tsc*sample_count) + (curr_tsc - last_tsc)) / (sample_count+1);
      last_avg_ret_ic = (double)((last_avg_ret_ic*sample_count) + (curr_ret_ic - last_ret_ic)) / (sample_count+1);
      last_avg_ic = (double)((last_avg_ic*sample_count) + ic) / (sample_count+1);
    }

    /* Resetting all static variables */
    last_tsc = curr_tsc;
    last_ret_ic = curr_ret_ic;

    sample_count++;
  }

  void print_timing_stats() {
    ci_disable();
    printf("samples:%d, avg_intv_cycles:%0.1lf, avg_intv_ic:%0.1lf\n", sample_count, last_avg_tsc, last_avg_ic);
    ci_enable();
  }

#elif defined(AVG_STATS)

  /* this function gets called from all threads, but twice from main. disregard it the second time */
  void init_stats(int index) {
    register_ci(compiler_interrupt_handler);
  }

  /*********************** For Trigger, with every interval stat being directly stored **********************/
  /* Code path for getting interval statistics */
  __thread int64_t sample_count = 0;
  void compiler_interrupt_handler(long ic) {
    if(sample_count >= 0)
      last_avg_ic = (double)((last_avg_ic*sample_count) + ic) / (sample_count+1);

    sample_count++;
  }

  void print_timing_stats() {
    ci_disable();
#ifdef SYS_gettid
    printf("Thread %d: avg_intv_ic:%0.1lf\n", syscall(SYS_gettid), last_avg_ic);
#else
    #error "SYS_gettid unavailable on this system"
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
  }

  __thread int64_t sample_count = -1;
  void hw_interrupt_handler(long long tot_inst, long long tot_cyc) {

    if(sample_count >= 0) {
        last_avg_tsc = (double)((last_avg_tsc*sample_count) + tot_cyc) / (sample_count+1);
        last_avg_ret_ic = (double)((last_avg_ret_ic*sample_count) + tot_inst) / (sample_count+1);
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
    assert(counter_values[TOT_INST_IDX] >= 0);
    __reset();
    hw_interrupt_handler(counter_values[TOT_INST_IDX], counter_values[TOT_CYC_IDX]);
  }

  void print_timing_stats(void) {
    /* Print every interval */
    printf("samples:%d, avg_intv_cycles:%0.1lf, avg_intv_ret_ic:%0.1lf\n", sample_count, last_avg_tsc, last_avg_ret_ic);
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
