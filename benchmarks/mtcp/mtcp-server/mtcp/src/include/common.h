#include <unistd.h>
#include <sys/time.h>
#include <semaphore.h>
#include <sys/mman.h>
#include <signal.h>
#include <assert.h>
#include <sched.h>

#include "mtcp.h"
#include "socket.h"
#include "tcp_stream.h"
#include "tcp_in.h"
#include "tcp_out.h"

void
HandleCloseCalls(tcp_stream *stream, mtcp_manager_t mtcp, uint32_t cur_ts,
    int *handled, int *delayed, int *control, int *send, int *ack);

int
HandleCloseCallsInt(mtcp_manager_t mtcp, uint32_t cur_ts);

void
HandleResetCalls(tcp_stream *stream, mtcp_manager_t mtcp, uint32_t cur_ts);

int
HandleResetCallsInt(mtcp_manager_t mtcp, uint32_t cur_ts);
