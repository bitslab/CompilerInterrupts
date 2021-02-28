divert(-1)

define(CORES_PER_SOCKET, esyscmd(lscpu | grep "Core" | tail -c 4 | tr -d '\n'))dnl
define(THREADS_PER_CORE, esyscmd(lscpu | grep "Thread" | tail -c 4 | tr -d '\n'))dnl
define(MAX_SOCK, esyscmd(lscpu | grep Socket | tail -c 2 | tr -d '\n'))dnl

# make sure REQS_LINES_PER_THREAD is power of 2

ifdef(`PTHREAD', `define(REQS_LINES_PER_THREAD, 2)', `define(REQS_LINES_PER_THREAD, 2)')


# define(REQS_LINES_PER_THREAD, 2)dnl
# can change CLIENT_PER_RESPONSE to any number (the number of responses that are grouped and written at once)
define(CLIENT_PER_RESPONSE,eval((CORES_PER_SOCKET/2)*REQS_LINES_PER_THREAD))dnl
define(STACK_SIZE, 1024)dnl
define(REQ_STACK_SIZE, 1024)dnl
define(MAX_REQ_SIZE, 64)dnl

define(MAX_REQS_PER_CHIP, eval(CORES_PER_SOCKET*THREADS_PER_CORE*REQS_LINES_PER_THREAD))dnl
define(RESP_GROUP_PER_SOCK, eval( (MAX_REQS_PER_CHIP/CLIENT_PER_RESPONSE) + eval( eval((MAX_REQS_PER_CHIP%CLIENT_PER_RESPONSE)>0))))dnl
define(TOTAL_NUM_OF_THREADS, eval(CORES_PER_SOCKET*THREADS_PER_CORE*MAX_SOCK))dnl
define(MAX_SERVERS, TOTAL_NUM_OF_THREADS)dnl
define(MAX_THREADS_PER_SOCK, eval(TOTAL_NUM_OF_THREADS/MAX_SOCK))dnl
define(MAX_NUM_OF_REQUESTS, eval(TOTAL_NUM_OF_THREADS *REQS_LINES_PER_THREAD))dnl
define(MAX_REQUEST_LINE_PER_CORE, eval(MAX_SERVERS*REQS_LINES_PER_THREAD))dnl

define(REQ_MEMORY_SIZE_ALIGNED, 4096 * eval( ((MAX_REQS_PER_CHIP*MAX_REQ_SIZE)/4096)  + eval( eval((MAX_REQS_PER_CHIP*MAX_REQ_SIZE)%4096)>0)))

define(FINISH, `ifelse(eval($1<MAX_REQS_PER_CHIP), `1', `eval($1)', eval(MAX_REQS_PER_CHIP-1))')

define(SERVER_SCAN, `{
	if (scan_nr == 1){
		fiber_yield();
		scan_nr = 1;
	} else {
		scan_nr++;
	}
}')

divert


