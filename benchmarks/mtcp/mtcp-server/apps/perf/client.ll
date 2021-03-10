; ModuleID = '<stdin>'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.mtcp_context = type { i32, i8* }
%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.strlong = type { i8*, i64 }
%struct.Options = type { i8*, i8**, i8* }
%struct.mtcp_conf = type { i32, i32, i32, i32, i32, i32, i32 }
%struct.mtcp_epoll_event = type { i32, %union.mtcp_epoll_data }
%union.mtcp_epoll_data = type { i8* }
%struct.sockaddr_in = type { i16, i16, %struct.in_addr, [8 x i8] }
%struct.in_addr = type { i32 }
%struct.timeval = type { i64, i64 }
%struct.sockaddr = type { i16, [14 x i8] }
%struct.timezone = type { i32, i32 }
%struct.tm = type { i32, i32, i32, i32, i32, i32, i32, i32, i32, i64, i8* }
%struct.cpu_set_t = type { [16 x i64] }

@mtcp_ctx = dso_local thread_local local_unnamed_addr global %struct.mtcp_context* null, align 8, !dbg !0
@intvActionHook = common dso_local local_unnamed_addr global void (i64)* null, align 8, !dbg !60
@str = private unnamed_addr constant [29 x i8] c"CI version of app is running\00", align 1
@.str.1 = private unnamed_addr constant [33 x i8] c"MTCP context not initialized yet\00", align 1
@stderr = external dso_local local_unnamed_addr global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [17 x i8] c"Received SIGINT\0A\00", align 1
@.str.3 = private unnamed_addr constant [74 x i8] c"(client initiates)   usage: ./client send [ip] [port] [length (seconds)]\0A\00", align 1
@.str.4 = private unnamed_addr constant [62 x i8] c"(server initiates)   usage: ./client wait [length (seconds)]\0A\00", align 1
@.str.5 = private unnamed_addr constant [5 x i8] c"send\00", align 1
@.str.6 = private unnamed_addr constant [19 x i8] c"[DEBUG] Send mode\0A\00", align 1
@.str.7 = private unnamed_addr constant [5 x i8] c"wait\00", align 1
@.str.8 = private unnamed_addr constant [19 x i8] c"[DEBUG] Wait mode\0A\00", align 1
@.str.9 = private unnamed_addr constant [19 x i8] c"Unknown mode \22%s\22\0A\00", align 1
@.str.10 = private unnamed_addr constant [31 x i8] c"[DEBUG] Initializing mtcp...\0A\0A\00", align 1
@.str.11 = private unnamed_addr constant [12 x i8] c"client.conf\00", align 1
@.str.12 = private unnamed_addr constant [29 x i8] c"Failed to initialize mtcp.\0A\0A\00", align 1
@.str.13 = private unnamed_addr constant [36 x i8] c"[DEBUG] Creating thread context...\0A\00", align 1
@.str.16 = private unnamed_addr constant [32 x i8] c"Failed to create mtcp context.\0A\00", align 1
@.str.17 = private unnamed_addr constant [46 x i8] c"[DEBUG] Creating pool of TCP source ports...\0A\00", align 1
@.str.18 = private unnamed_addr constant [29 x i8] c"[DEBUG] Creating epoller...\0A\00", align 1
@.str.19 = private unnamed_addr constant [28 x i8] c"Failed to allocate events.\0A\00", align 1
@.str.20 = private unnamed_addr constant [28 x i8] c"[DEBUG] Creating socket...\0A\00", align 1
@.str.21 = private unnamed_addr constant [26 x i8] c"Failed to create socket.\0A\00", align 1
@.str.22 = private unnamed_addr constant [43 x i8] c"Failed to set socket in nonblocking mode.\0A\00", align 1
@.str.23 = private unnamed_addr constant [41 x i8] c"Failed to bind to the listening socket.\0A\00", align 1
@.str.24 = private unnamed_addr constant [22 x i8] c"Failed to listen: %s\0A\00", align 1
@.str.25 = private unnamed_addr constant [16 x i8] c"mtcp_epoll_wait\00", align 1
@.str.26 = private unnamed_addr constant [23 x i8] c"Invalid socket id %d.\0A\00", align 1
@.str.27 = private unnamed_addr constant [33 x i8] c"[DEBUG] Accepted new connection\0A\00", align 1
@.str.28 = private unnamed_addr constant [18 x i8] c"mtcp_accept() %s\0A\00", align 1
@.str.29 = private unnamed_addr constant [35 x i8] c"Received event on unknown socket.\0A\00", align 1
@.str.30 = private unnamed_addr constant [30 x i8] c"[DEBUG] Connecting socket...\0A\00", align 1
@.str.31 = private unnamed_addr constant [22 x i8] c"mtcp_connect failed.\0A\00", align 1
@.str.32 = private unnamed_addr constant [13 x i8] c"mtcp_connect\00", align 1
@.str.33 = private unnamed_addr constant [29 x i8] c"[DEBUG] Connection created.\0A\00", align 1
@.str.34 = private unnamed_addr constant [32 x i8] c"sockfd == events[i].data.sockid\00", align 1
@.str.35 = private unnamed_addr constant [9 x i8] c"client.c\00", align 1
@__PRETTY_FUNCTION__.main = private unnamed_addr constant [23 x i8] c"int main(int, char **)\00", align 1
@.str.37 = private unnamed_addr constant [45 x i8] c"[DEBUG] Done writing... waiting for FIN-ACK\0A\00", align 1
@.str.36 = private unnamed_addr constant [50 x i8] c"[DEBUG] Got FIN-ACK from receiver (%d bytes): %s\0A\00", align 1
@.str.38 = private unnamed_addr constant [41 x i8] c"[DEBUG] Done reading. Closing socket...\0A\00", align 1
@.str.39 = private unnamed_addr constant [24 x i8] c"[DEBUG] Socket closed.\0A\00", align 1
@str.44 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1
@.str.41 = private unnamed_addr constant [18 x i8] c"Time elapsed: %f\0A\00", align 1
@.str.42 = private unnamed_addr constant [22 x i8] c"Total bytes sent: %d\0A\00", align 1
@.str.43 = private unnamed_addr constant [26 x i8] c"Throughput: %.3fMbit/sec\0A\00", align 1
@.str = private unnamed_addr constant [4 x i8] c"GET\00", align 1
@.str.1.1 = private unnamed_addr constant [5 x i8] c"POST\00", align 1
@.str.2.2 = private unnamed_addr constant [5 x i8] c"HTTP\00", align 1
@.str.3.3 = private unnamed_addr constant [4 x i8] c"1.1\00", align 1
@.str.4.4 = private unnamed_addr constant [4 x i8] c"1.0\00", align 1
@.str.5.5 = private unnamed_addr constant [9 x i8] c"max-age=\00", align 1
@.str.6.6 = private unnamed_addr constant [10 x i8] c"s-maxage=\00", align 1
@.str.14 = private unnamed_addr constant [29 x i8] c"%d-%[a-zA-Z]-%d %d:%d:%d GMT\00", align 1
@scan_mon.sorted = internal unnamed_addr global i1 false, align 4
@scan_mon.mon_tab = internal global [23 x %struct.strlong] [%struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.27.21, i32 0, i32 0), i64 0 }, %struct.strlong { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.28.22, i32 0, i32 0), i64 0 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.29.23, i32 0, i32 0), i64 1 }, %struct.strlong { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.30.24, i32 0, i32 0), i64 1 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.31.25, i32 0, i32 0), i64 2 }, %struct.strlong { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.32.26, i32 0, i32 0), i64 2 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.33.27, i32 0, i32 0), i64 3 }, %struct.strlong { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.34.28, i32 0, i32 0), i64 3 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.35.29, i32 0, i32 0), i64 4 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.36.30, i32 0, i32 0), i64 5 }, %struct.strlong { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.37.31, i32 0, i32 0), i64 5 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.38.32, i32 0, i32 0), i64 6 }, %struct.strlong { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.39.33, i32 0, i32 0), i64 6 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.40, i32 0, i32 0), i64 7 }, %struct.strlong { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.41.34, i32 0, i32 0), i64 7 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.42.35, i32 0, i32 0), i64 8 }, %struct.strlong { i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.43.36, i32 0, i32 0), i64 8 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.44, i32 0, i32 0), i64 9 }, %struct.strlong { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.45, i32 0, i32 0), i64 9 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.46, i32 0, i32 0), i64 10 }, %struct.strlong { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.47, i32 0, i32 0), i64 10 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.48, i32 0, i32 0), i64 11 }, %struct.strlong { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.49, i32 0, i32 0), i64 11 }], align 16
@.str.1.15 = private unnamed_addr constant [29 x i8] c"%d %[a-zA-Z] %d %d:%d:%d GMT\00", align 1
@.str.2.16 = private unnamed_addr constant [29 x i8] c"%d:%d:%d GMT %d-%[a-zA-Z]-%d\00", align 1
@.str.3.17 = private unnamed_addr constant [29 x i8] c"%d:%d:%d GMT %d %[a-zA-Z] %d\00", align 1
@.str.4.18 = private unnamed_addr constant [40 x i8] c"%[a-zA-Z], %d-%[a-zA-Z]-%d %d:%d:%d GMT\00", align 1
@scan_wday.sorted = internal unnamed_addr global i1 false, align 4
@scan_wday.wday_tab = internal global [14 x %struct.strlong] [%struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.50, i32 0, i32 0), i64 0 }, %struct.strlong { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.51, i32 0, i32 0), i64 0 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.52, i32 0, i32 0), i64 1 }, %struct.strlong { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.53, i32 0, i32 0), i64 1 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.54, i32 0, i32 0), i64 2 }, %struct.strlong { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.55, i32 0, i32 0), i64 2 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.56, i32 0, i32 0), i64 3 }, %struct.strlong { i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.57, i32 0, i32 0), i64 3 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.58, i32 0, i32 0), i64 4 }, %struct.strlong { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.59, i32 0, i32 0), i64 4 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.60, i32 0, i32 0), i64 5 }, %struct.strlong { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.61, i32 0, i32 0), i64 5 }, %struct.strlong { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.62, i32 0, i32 0), i64 6 }, %struct.strlong { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.63, i32 0, i32 0), i64 6 }], align 16
@.str.5.19 = private unnamed_addr constant [40 x i8] c"%[a-zA-Z], %d %[a-zA-Z] %d %d:%d:%d GMT\00", align 1
@.str.6.20 = private unnamed_addr constant [39 x i8] c"%[a-zA-Z] %[a-zA-Z] %d %d:%d:%d GMT %d\00", align 1
@tm_to_time.monthtab = internal unnamed_addr constant [12 x i32] [i32 0, i32 31, i32 59, i32 90, i32 120, i32 151, i32 181, i32 212, i32 243, i32 273, i32 304, i32 334], align 16
@.str.50 = private unnamed_addr constant [4 x i8] c"sun\00", align 1
@.str.51 = private unnamed_addr constant [7 x i8] c"sunday\00", align 1
@.str.52 = private unnamed_addr constant [4 x i8] c"mon\00", align 1
@.str.53 = private unnamed_addr constant [7 x i8] c"monday\00", align 1
@.str.54 = private unnamed_addr constant [4 x i8] c"tue\00", align 1
@.str.55 = private unnamed_addr constant [8 x i8] c"tuesday\00", align 1
@.str.56 = private unnamed_addr constant [4 x i8] c"wed\00", align 1
@.str.57 = private unnamed_addr constant [10 x i8] c"wednesday\00", align 1
@.str.58 = private unnamed_addr constant [4 x i8] c"thu\00", align 1
@.str.59 = private unnamed_addr constant [9 x i8] c"thursday\00", align 1
@.str.60 = private unnamed_addr constant [4 x i8] c"fri\00", align 1
@.str.61 = private unnamed_addr constant [7 x i8] c"friday\00", align 1
@.str.62 = private unnamed_addr constant [4 x i8] c"sat\00", align 1
@.str.63 = private unnamed_addr constant [9 x i8] c"saturday\00", align 1
@.str.27.21 = private unnamed_addr constant [4 x i8] c"jan\00", align 1
@.str.28.22 = private unnamed_addr constant [8 x i8] c"january\00", align 1
@.str.29.23 = private unnamed_addr constant [4 x i8] c"feb\00", align 1
@.str.30.24 = private unnamed_addr constant [9 x i8] c"february\00", align 1
@.str.31.25 = private unnamed_addr constant [4 x i8] c"mar\00", align 1
@.str.32.26 = private unnamed_addr constant [6 x i8] c"march\00", align 1
@.str.33.27 = private unnamed_addr constant [4 x i8] c"apr\00", align 1
@.str.34.28 = private unnamed_addr constant [6 x i8] c"april\00", align 1
@.str.35.29 = private unnamed_addr constant [4 x i8] c"may\00", align 1
@.str.36.30 = private unnamed_addr constant [4 x i8] c"jun\00", align 1
@.str.37.31 = private unnamed_addr constant [5 x i8] c"june\00", align 1
@.str.38.32 = private unnamed_addr constant [4 x i8] c"jul\00", align 1
@.str.39.33 = private unnamed_addr constant [5 x i8] c"july\00", align 1
@.str.40 = private unnamed_addr constant [4 x i8] c"aug\00", align 1
@.str.41.34 = private unnamed_addr constant [7 x i8] c"august\00", align 1
@.str.42.35 = private unnamed_addr constant [4 x i8] c"sep\00", align 1
@.str.43.36 = private unnamed_addr constant [10 x i8] c"september\00", align 1
@.str.44 = private unnamed_addr constant [4 x i8] c"oct\00", align 1
@.str.45 = private unnamed_addr constant [8 x i8] c"october\00", align 1
@.str.46 = private unnamed_addr constant [4 x i8] c"nov\00", align 1
@.str.47 = private unnamed_addr constant [9 x i8] c"november\00", align 1
@.str.48 = private unnamed_addr constant [4 x i8] c"dec\00", align 1
@.str.49 = private unnamed_addr constant [9 x i8] c"december\00", align 1
@timet_to_httpdate.day_of_week = internal unnamed_addr constant [7 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.7.49, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.8.50, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.9.51, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.10.52, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.11.53, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.12.54, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.13.55, i32 0, i32 0)], align 16
@timet_to_httpdate.months = internal unnamed_addr constant [12 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.14.38, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.15, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.16.39, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.17.40, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.18.41, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.19.42, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.20.43, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.21.44, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.22.45, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.23.46, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.24.47, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.25.48, i32 0, i32 0)], align 16
@.str.26.37 = private unnamed_addr constant [35 x i8] c"%s, %02d %s %4d %02d:%02d:%02d GMT\00", align 1
@.str.14.38 = private unnamed_addr constant [4 x i8] c"Jan\00", align 1
@.str.15 = private unnamed_addr constant [4 x i8] c"Feb\00", align 1
@.str.16.39 = private unnamed_addr constant [4 x i8] c"Mar\00", align 1
@.str.17.40 = private unnamed_addr constant [4 x i8] c"Apr\00", align 1
@.str.18.41 = private unnamed_addr constant [4 x i8] c"May\00", align 1
@.str.19.42 = private unnamed_addr constant [4 x i8] c"Jun\00", align 1
@.str.20.43 = private unnamed_addr constant [4 x i8] c"Jul\00", align 1
@.str.21.44 = private unnamed_addr constant [4 x i8] c"Aug\00", align 1
@.str.22.45 = private unnamed_addr constant [4 x i8] c"Sep\00", align 1
@.str.23.46 = private unnamed_addr constant [4 x i8] c"Oct\00", align 1
@.str.24.47 = private unnamed_addr constant [4 x i8] c"Nov\00", align 1
@.str.25.48 = private unnamed_addr constant [4 x i8] c"Dec\00", align 1
@.str.7.49 = private unnamed_addr constant [4 x i8] c"Sun\00", align 1
@.str.8.50 = private unnamed_addr constant [4 x i8] c"Mon\00", align 1
@.str.9.51 = private unnamed_addr constant [4 x i8] c"Tue\00", align 1
@.str.10.52 = private unnamed_addr constant [4 x i8] c"Wed\00", align 1
@.str.11.53 = private unnamed_addr constant [4 x i8] c"Thu\00", align 1
@.str.12.54 = private unnamed_addr constant [4 x i8] c"Fri\00", align 1
@.str.13.55 = private unnamed_addr constant [4 x i8] c"Sat\00", align 1
@Options = common local_unnamed_addr global %struct.Options zeroinitializer, align 8
@.str.64 = private unnamed_addr constant [25 x i8] c"%d: invalid CPU number.\0A\00", align 1
@.str.1.65 = private unnamed_addr constant [22 x i8] c"%d: uexpected cmask.\0A\00", align 1
@.str.2.66 = private unnamed_addr constant [34 x i8] c"socket() failed, errno=%d msg=%s\0A\00", align 1
@.str.3.67 = private unnamed_addr constant [33 x i8] c"fcntl() failed, errno=%d msg=%s\0A\00", align 1
@.str.4.68 = private unnamed_addr constant [32 x i8] c"bind() failed, errno=%d msg=%s\0A\00", align 1
@.str.5.69 = private unnamed_addr constant [29 x i8] c"failed creating socket - %d\0A\00", align 1
@.str.6.70 = private unnamed_addr constant [30 x i8] c"failed fcntl'ing socket - %d\0A\00", align 1
@.str.7.71 = private unnamed_addr constant [53 x i8] c"failed connecting socket addr=%s port %d - errno %d\0A\00", align 1
@.str.8.72 = private unnamed_addr constant [33 x i8] c"no value provided for %s option\0A\00", align 1
@.str.9.73 = private unnamed_addr constant [28 x i8] c"option %s is not supported\0A\00", align 1
@str.15 = private unnamed_addr constant [41 x i8] c"The value for each option is as follows:\00", align 1
@str.74 = private unnamed_addr constant [39 x i8] c"Here is the list of allowable options:\00", align 1
@.str.12.75 = private unnamed_addr constant [8 x i8] c"%s: %s\0A\00", align 1
@.str.13.76 = private unnamed_addr constant [7 x i8] c"strtol\00", align 1
@.str.14.77 = private unnamed_addr constant [23 x i8] c"Parsing strtol error!\0A\00", align 1
@LocalLC = thread_local global i64 0
@lc_disabled_count = thread_local global i32 0

; Function Attrs: nounwind uwtable
define dso_local void @init_stats() local_unnamed_addr #0 !dbg !73 {
entry:
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @str, i64 0, i64 0)), !dbg !77
  %call1 = tail call i32 @register_ci(void (i64)* nonnull @compiler_interrupt_handler) #16, !dbg !78
  ret void, !dbg !79
}

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #1

; Function Attrs: nounwind uwtable
define dso_local void @compiler_interrupt_handler(i64 %ic) #0 !dbg !80 {
entry:
  call void @llvm.dbg.value(metadata i64 undef, metadata !82, metadata !DIExpression()), !dbg !83
  %0 = load %struct.mtcp_context*, %struct.mtcp_context** @mtcp_ctx, align 8, !dbg !84, !tbaa !86
  %mtcp_thr_ctx = getelementptr inbounds %struct.mtcp_context, %struct.mtcp_context* %0, i64 0, i32 1, !dbg !90
  %1 = load i8*, i8** %mtcp_thr_ctx, align 8, !dbg !90, !tbaa !91
  %tobool = icmp eq i8* %1, null, !dbg !94
  br i1 %tobool, label %if.else, label %if.then, !dbg !95

if.then:                                          ; preds = %entry
  tail call void @RunMainLoop(i8* nonnull %1) #16, !dbg !96
  br label %if.end, !dbg !98

if.else:                                          ; preds = %entry
  %call = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.1, i64 0, i64 0)), !dbg !99
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  ret void, !dbg !100
}

declare dso_local i32 @register_ci(void (i64)*) local_unnamed_addr #2

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.value(metadata, metadata, metadata) #3

declare dso_local void @RunMainLoop(i8*) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare dso_local i32 @printf(i8* nocapture readonly, ...) local_unnamed_addr #4

; Function Attrs: noreturn nounwind uwtable
define dso_local void @SignalHandler(i32 %signum) #5 !dbg !101 {
entry:
  call void @llvm.dbg.value(metadata i32 undef, metadata !105, metadata !DIExpression()), !dbg !106
  %0 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !107, !tbaa !86
  %1 = tail call i64 @fwrite(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.2, i64 0, i64 0), i64 16, i64 1, %struct._IO_FILE* %0) #17, !dbg !107
  tail call void @exit(i32 -1) #18, !dbg !108
  unreachable, !dbg !108
}

; Function Attrs: nofree nounwind
declare i64 @fwrite(i8* nocapture, i64, i64, %struct._IO_FILE* nocapture) local_unnamed_addr #1

; Function Attrs: noreturn nounwind
declare dso_local void @exit(i32) local_unnamed_addr #6

; Function Attrs: nofree nounwind uwtable
define dso_local void @print_usage(i32 %mode) local_unnamed_addr #7 !dbg !109 {
entry:
  call void @llvm.dbg.value(metadata i32 %mode, metadata !111, metadata !DIExpression()), !dbg !112
  %0 = icmp ult i32 %mode, 2, !dbg !113
  br i1 %0, label %if.then, label %if.end, !dbg !113

if.then:                                          ; preds = %entry
  %1 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !115, !tbaa !86
  %2 = tail call i64 @fwrite(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.3, i64 0, i64 0), i64 73, i64 1, %struct._IO_FILE* %1) #17, !dbg !115
  br label %if.end, !dbg !117

if.end:                                           ; preds = %if.then, %entry
  %3 = and i32 %mode, -3, !dbg !118
  %4 = icmp eq i32 %3, 0, !dbg !118
  br i1 %4, label %if.then5, label %if.end7, !dbg !118

if.then5:                                         ; preds = %if.end
  %5 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !120, !tbaa !86
  %6 = tail call i64 @fwrite(i8* getelementptr inbounds ([62 x i8], [62 x i8]* @.str.4, i64 0, i64 0), i64 61, i64 1, %struct._IO_FILE* %5) #17, !dbg !120
  br label %if.end7, !dbg !122

if.end7:                                          ; preds = %if.then5, %if.end
  ret void, !dbg !123
}

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** nocapture readonly %argv) local_unnamed_addr #0 !dbg !124 {
entry:
  %mcfg = alloca %struct.mtcp_conf, align 4
  %ev = alloca %struct.mtcp_epoll_event, align 8
  %saddr = alloca %struct.sockaddr_in, align 4
  %daddr = alloca %struct.sockaddr_in, align 4
  %t1 = alloca %struct.timeval, align 8
  %t2 = alloca %struct.timeval, align 8
  %ts_start = alloca %struct.timeval, align 8
  %now = alloca %struct.timeval, align 8
  %buf = alloca [8192 x i8], align 16
  %rcvbuf = alloca [8192 x i8], align 16
  call void @llvm.dbg.value(metadata i32 %argc, metadata !128, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i8** %argv, metadata !129, metadata !DIExpression()), !dbg !219
  %puts.i = tail call i32 @puts(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @str, i64 0, i64 0)) #16, !dbg !220
  %call1.i = tail call i32 @register_ci(void (i64)* nonnull @compiler_interrupt_handler) #16, !dbg !222
  %0 = bitcast %struct.mtcp_conf* %mcfg to i8*, !dbg !223
  call void @llvm.lifetime.start.p0i8(i64 28, i8* nonnull %0) #16, !dbg !223
  %1 = bitcast %struct.mtcp_epoll_event* %ev to i8*, !dbg !224
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %1) #16, !dbg !224
  call void @llvm.dbg.value(metadata i32 0, metadata !147, metadata !DIExpression()), !dbg !219
  %2 = bitcast %struct.sockaddr_in* %saddr to i8*, !dbg !225
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %2) #16, !dbg !225
  %3 = bitcast %struct.sockaddr_in* %daddr to i8*, !dbg !225
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %3) #16, !dbg !225
  call void @llvm.dbg.value(metadata i32 3, metadata !168, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 0, metadata !170, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 0, metadata !171, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 0, metadata !172, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 0, metadata !173, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 0, metadata !174, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 0, metadata !175, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata double 0.000000e+00, metadata !176, metadata !DIExpression()), !dbg !219
  %4 = bitcast %struct.timeval* %t1 to i8*, !dbg !226
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %4) #16, !dbg !226
  %5 = bitcast %struct.timeval* %t2 to i8*, !dbg !226
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %5) #16, !dbg !226
  %6 = bitcast %struct.timeval* %ts_start to i8*, !dbg !227
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %6) #16, !dbg !227
  %7 = bitcast %struct.timeval* %now to i8*, !dbg !227
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %7) #16, !dbg !227
  %8 = getelementptr inbounds [8192 x i8], [8192 x i8]* %buf, i64 0, i64 0, !dbg !228
  call void @llvm.lifetime.start.p0i8(i64 8192, i8* nonnull %8) #16, !dbg !228
  call void @llvm.dbg.declare(metadata [8192 x i8]* %buf, metadata !198, metadata !DIExpression()), !dbg !229
  %9 = getelementptr inbounds [8192 x i8], [8192 x i8]* %rcvbuf, i64 0, i64 0, !dbg !230
  call void @llvm.lifetime.start.p0i8(i64 8192, i8* nonnull %9) #16, !dbg !230
  call void @llvm.dbg.declare(metadata [8192 x i8]* %rcvbuf, metadata !202, metadata !DIExpression()), !dbg !231
  call void @llvm.dbg.value(metadata i32 0, metadata !203, metadata !DIExpression()), !dbg !219
  %cmp = icmp slt i32 %argc, 2, !dbg !232
  br i1 %cmp, label %if.then, label %if.end, !dbg !234

if.then:                                          ; preds = %entry
  call void @llvm.dbg.value(metadata i32 0, metadata !111, metadata !DIExpression()) #16, !dbg !235
  %10 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !238, !tbaa !86
  %11 = tail call i64 @fwrite(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.3, i64 0, i64 0), i64 73, i64 1, %struct._IO_FILE* %10) #19, !dbg !238
  %12 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !239, !tbaa !86
  %13 = tail call i64 @fwrite(i8* getelementptr inbounds ([62 x i8], [62 x i8]* @.str.4, i64 0, i64 0), i64 61, i64 1, %struct._IO_FILE* %12) #19, !dbg !239
  %14 = load i32, i32* @lc_disabled_count, !dbg !240
  %clock_running = icmp eq i32 %14, 0, !dbg !240
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock, !dbg !240

if_clock_enabled:                                 ; preds = %if.then
  %15 = load i64, i64* @LocalLC, !dbg !240
  %16 = add i64 54, %15, !dbg !240
  store i64 %16, i64* @LocalLC, !dbg !240
  %commit = icmp ugt i64 %16, 5000, !dbg !240
  br i1 %commit, label %pushBlock, label %postInstrumentation, !dbg !240

pushBlock:                                        ; preds = %if_clock_enabled
  %17 = add i32 %14, 1, !dbg !240
  store i32 %17, i32* @lc_disabled_count, !dbg !240
  store i64 9, i64* @LocalLC, !dbg !240
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook, !dbg !240
  call void %ci_handler(i64 %16), !dbg !240
  %18 = load i32, i32* @lc_disabled_count, !dbg !240
  %19 = sub i32 %18, 1, !dbg !240
  store i32 %19, i32* @lc_disabled_count, !dbg !240
  br label %postInstrumentation, !dbg !240

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock, !dbg !240

postClockEnabledBlock:                            ; preds = %if.then, %postInstrumentation
  br label %cleanup308, !dbg !240

if.end:                                           ; preds = %entry
  %arrayidx = getelementptr inbounds i8*, i8** %argv, i64 1, !dbg !241
  %20 = load i8*, i8** %arrayidx, align 8, !dbg !241, !tbaa !86
  %call = tail call i32 @strncmp(i8* %20, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.5, i64 0, i64 0), i64 4) #20, !dbg !242
  %cmp1 = icmp eq i32 %call, 0, !dbg !243
  br i1 %cmp1, label %if.then2, label %if.else19, !dbg !244

if.then2:                                         ; preds = %if.end
  %cmp3 = icmp slt i32 %argc, 5, !dbg !245
  %21 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !247, !tbaa !86
  %22 = load i32, i32* @lc_disabled_count, !dbg !248
  %clock_running3 = icmp eq i32 %22, 0, !dbg !248
  br i1 %clock_running3, label %if_clock_enabled4, label %postClockEnabledBlock9, !dbg !248

if_clock_enabled4:                                ; preds = %if.then2
  %23 = load i64, i64* @LocalLC, !dbg !248
  %24 = add i64 56, %23, !dbg !248
  store i64 %24, i64* @LocalLC, !dbg !248
  %commit5 = icmp ugt i64 %24, 5000, !dbg !248
  br i1 %commit5, label %pushBlock7, label %postInstrumentation6, !dbg !248

pushBlock7:                                       ; preds = %if_clock_enabled4
  %25 = add i32 %22, 1, !dbg !248
  store i32 %25, i32* @lc_disabled_count, !dbg !248
  store i64 9, i64* @LocalLC, !dbg !248
  %ci_handler8 = load void (i64)*, void (i64)** @intvActionHook, !dbg !248
  call void %ci_handler8(i64 %24), !dbg !248
  %26 = load i32, i32* @lc_disabled_count, !dbg !248
  %27 = sub i32 %26, 1, !dbg !248
  store i32 %27, i32* @lc_disabled_count, !dbg !248
  br label %postInstrumentation6, !dbg !248

postInstrumentation6:                             ; preds = %if_clock_enabled4, %pushBlock7
  br label %postClockEnabledBlock9, !dbg !248

postClockEnabledBlock9:                           ; preds = %if.then2, %postInstrumentation6
  br i1 %cmp3, label %if.then4, label %if.end5, !dbg !248

if.then4:                                         ; preds = %postClockEnabledBlock9
  call void @llvm.dbg.value(metadata i32 1, metadata !111, metadata !DIExpression()) #16, !dbg !249
  %28 = tail call i64 @fwrite(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.3, i64 0, i64 0), i64 73, i64 1, %struct._IO_FILE* %21) #19, !dbg !252
  %29 = load i32, i32* @lc_disabled_count, !dbg !253
  %clock_running10 = icmp eq i32 %29, 0, !dbg !253
  br i1 %clock_running10, label %if_clock_enabled11, label %postClockEnabledBlock16, !dbg !253

if_clock_enabled11:                               ; preds = %if.then4
  %30 = load i64, i64* @LocalLC, !dbg !253
  %31 = add i64 3, %30, !dbg !253
  store i64 %31, i64* @LocalLC, !dbg !253
  %commit12 = icmp ugt i64 %31, 5000, !dbg !253
  br i1 %commit12, label %pushBlock14, label %postInstrumentation13, !dbg !253

pushBlock14:                                      ; preds = %if_clock_enabled11
  %32 = add i32 %29, 1, !dbg !253
  store i32 %32, i32* @lc_disabled_count, !dbg !253
  store i64 9, i64* @LocalLC, !dbg !253
  %ci_handler15 = load void (i64)*, void (i64)** @intvActionHook, !dbg !253
  call void %ci_handler15(i64 %31), !dbg !253
  %33 = load i32, i32* @lc_disabled_count, !dbg !253
  %34 = sub i32 %33, 1, !dbg !253
  store i32 %34, i32* @lc_disabled_count, !dbg !253
  br label %postInstrumentation13, !dbg !253

postInstrumentation13:                            ; preds = %if_clock_enabled11, %pushBlock14
  br label %postClockEnabledBlock16, !dbg !253

postClockEnabledBlock16:                          ; preds = %if.then4, %postInstrumentation13
  br label %cleanup308, !dbg !253

if.end5:                                          ; preds = %postClockEnabledBlock9
  call void @llvm.dbg.value(metadata i32 1, metadata !203, metadata !DIExpression()), !dbg !219
  %35 = tail call i64 @fwrite(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.6, i64 0, i64 0), i64 18, i64 1, %struct._IO_FILE* %21) #17, !dbg !254
  %sin_family = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %daddr, i64 0, i32 0, !dbg !255
  store i16 2, i16* %sin_family, align 4, !dbg !256, !tbaa !257
  %arrayidx7 = getelementptr inbounds i8*, i8** %argv, i64 2, !dbg !261
  %36 = load i8*, i8** %arrayidx7, align 8, !dbg !261, !tbaa !86
  %call8 = tail call i32 @inet_addr(i8* %36) #16, !dbg !262
  %s_addr = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %daddr, i64 0, i32 2, i32 0, !dbg !263
  store i32 %call8, i32* %s_addr, align 4, !dbg !264, !tbaa !265
  %arrayidx9 = getelementptr inbounds i8*, i8** %argv, i64 3, !dbg !266
  %37 = load i8*, i8** %arrayidx9, align 8, !dbg !266, !tbaa !86
  call void @llvm.dbg.value(metadata i8* %37, metadata !267, metadata !DIExpression()) #16, !dbg !275
  %call.i = tail call i64 @strtol(i8* nocapture nonnull %37, i8** null, i32 10) #16, !dbg !277
  %conv = trunc i64 %call.i to i16, !dbg !266
  call void @llvm.dbg.value(metadata i16 %conv, metadata !208, metadata !DIExpression()), !dbg !278
  %38 = tail call i1 @llvm.is.constant.i16(i16 %conv), !dbg !279
  br i1 %38, label %if.then11, label %if.else, !dbg !266

if.then11:                                        ; preds = %if.end5
  %rev458 = tail call i16 @llvm.bswap.i16(i16 %conv)
  call void @llvm.dbg.value(metadata i16 %rev458, metadata !204, metadata !DIExpression()), !dbg !278
  br label %if.end63_dummy, !dbg !279

if.else:                                          ; preds = %if.end5
  %39 = tail call i16 asm "rorw $$8, ${0:w}", "=r,0,~{cc},~{dirflag},~{fpsr},~{flags}"(i16 %conv) #11, !dbg !279, !srcloc !281
  call void @llvm.dbg.value(metadata i16 %39, metadata !204, metadata !DIExpression()), !dbg !278
  br label %if.end63_dummy

if.else19:                                        ; preds = %if.end
  %call21 = tail call i32 @strncmp(i8* %20, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.7, i64 0, i64 0), i64 4) #20, !dbg !282
  %cmp22 = icmp eq i32 %call21, 0, !dbg !283
  br i1 %cmp22, label %if.then24, label %if.end59, !dbg !284

if.then24:                                        ; preds = %if.else19
  %cmp25 = icmp slt i32 %argc, 4, !dbg !285
  %40 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !287, !tbaa !86
  %41 = load i32, i32* @lc_disabled_count, !dbg !288
  %clock_running17 = icmp eq i32 %41, 0, !dbg !288
  br i1 %clock_running17, label %if_clock_enabled18, label %postClockEnabledBlock23, !dbg !288

if_clock_enabled18:                               ; preds = %if.then24
  %42 = load i64, i64* @LocalLC, !dbg !288
  %43 = add i64 59, %42, !dbg !288
  store i64 %43, i64* @LocalLC, !dbg !288
  %commit19 = icmp ugt i64 %43, 5000, !dbg !288
  br i1 %commit19, label %pushBlock21, label %postInstrumentation20, !dbg !288

pushBlock21:                                      ; preds = %if_clock_enabled18
  %44 = add i32 %41, 1, !dbg !288
  store i32 %44, i32* @lc_disabled_count, !dbg !288
  store i64 9, i64* @LocalLC, !dbg !288
  %ci_handler22 = load void (i64)*, void (i64)** @intvActionHook, !dbg !288
  call void %ci_handler22(i64 %43), !dbg !288
  %45 = load i32, i32* @lc_disabled_count, !dbg !288
  %46 = sub i32 %45, 1, !dbg !288
  store i32 %46, i32* @lc_disabled_count, !dbg !288
  br label %postInstrumentation20, !dbg !288

postInstrumentation20:                            ; preds = %if_clock_enabled18, %pushBlock21
  br label %postClockEnabledBlock23, !dbg !288

postClockEnabledBlock23:                          ; preds = %if.then24, %postInstrumentation20
  br i1 %cmp25, label %if.then27, label %if.end28, !dbg !288

if.then27:                                        ; preds = %postClockEnabledBlock23
  call void @llvm.dbg.value(metadata i32 2, metadata !111, metadata !DIExpression()) #16, !dbg !289
  %47 = tail call i64 @fwrite(i8* getelementptr inbounds ([62 x i8], [62 x i8]* @.str.4, i64 0, i64 0), i64 61, i64 1, %struct._IO_FILE* %40) #19, !dbg !292
  %48 = load i32, i32* @lc_disabled_count, !dbg !293
  %clock_running24 = icmp eq i32 %48, 0, !dbg !293
  br i1 %clock_running24, label %if_clock_enabled25, label %postClockEnabledBlock30, !dbg !293

if_clock_enabled25:                               ; preds = %if.then27
  %49 = load i64, i64* @LocalLC, !dbg !293
  %50 = add i64 3, %49, !dbg !293
  store i64 %50, i64* @LocalLC, !dbg !293
  %commit26 = icmp ugt i64 %50, 5000, !dbg !293
  br i1 %commit26, label %pushBlock28, label %postInstrumentation27, !dbg !293

pushBlock28:                                      ; preds = %if_clock_enabled25
  %51 = add i32 %48, 1, !dbg !293
  store i32 %51, i32* @lc_disabled_count, !dbg !293
  store i64 9, i64* @LocalLC, !dbg !293
  %ci_handler29 = load void (i64)*, void (i64)** @intvActionHook, !dbg !293
  call void %ci_handler29(i64 %50), !dbg !293
  %52 = load i32, i32* @lc_disabled_count, !dbg !293
  %53 = sub i32 %52, 1, !dbg !293
  store i32 %53, i32* @lc_disabled_count, !dbg !293
  br label %postInstrumentation27, !dbg !293

postInstrumentation27:                            ; preds = %if_clock_enabled25, %pushBlock28
  br label %postClockEnabledBlock30, !dbg !293

postClockEnabledBlock30:                          ; preds = %if.then27, %postInstrumentation27
  br label %cleanup308, !dbg !293

if.end28:                                         ; preds = %postClockEnabledBlock23
  call void @llvm.dbg.value(metadata i32 2, metadata !203, metadata !DIExpression()), !dbg !219
  %54 = tail call i64 @fwrite(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.8, i64 0, i64 0), i64 18, i64 1, %struct._IO_FILE* %40) #17, !dbg !294
  %sin_family30 = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %saddr, i64 0, i32 0, !dbg !295
  store i16 2, i16* %sin_family30, align 4, !dbg !296, !tbaa !257
  %arrayidx31 = getelementptr inbounds i8*, i8** %argv, i64 2, !dbg !297
  %55 = load i8*, i8** %arrayidx31, align 8, !dbg !297, !tbaa !86
  %call32 = tail call i32 @inet_addr(i8* %55) #16, !dbg !298
  %s_addr34 = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %saddr, i64 0, i32 2, i32 0, !dbg !299
  store i32 %call32, i32* %s_addr34, align 4, !dbg !300, !tbaa !265
  %arrayidx37 = getelementptr inbounds i8*, i8** %argv, i64 3, !dbg !301
  %56 = load i8*, i8** %arrayidx37, align 8, !dbg !301, !tbaa !86
  call void @llvm.dbg.value(metadata i8* %56, metadata !267, metadata !DIExpression()) #16, !dbg !302
  %call.i461 = tail call i64 @strtol(i8* nocapture nonnull %56, i8** null, i32 10) #16, !dbg !304
  %conv39 = trunc i64 %call.i461 to i16, !dbg !301
  call void @llvm.dbg.value(metadata i16 %conv39, metadata !213, metadata !DIExpression()), !dbg !305
  %57 = tail call i1 @llvm.is.constant.i16(i16 %conv39), !dbg !306
  br i1 %57, label %if.then40, label %if.else49, !dbg !301

if.then40:                                        ; preds = %if.end28
  %rev = tail call i16 @llvm.bswap.i16(i16 %conv39)
  call void @llvm.dbg.value(metadata i16 %rev, metadata !209, metadata !DIExpression()), !dbg !305
  br label %if.end63_dummy1, !dbg !306

if.else49:                                        ; preds = %if.end28
  %58 = tail call i16 asm "rorw $$8, ${0:w}", "=r,0,~{cc},~{dirflag},~{fpsr},~{flags}"(i16 %conv39) #11, !dbg !306, !srcloc !308
  call void @llvm.dbg.value(metadata i16 %58, metadata !209, metadata !DIExpression()), !dbg !305
  br label %if.end63_dummy1

if.end59:                                         ; preds = %if.else19
  %59 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !309, !tbaa !86
  %call57 = tail call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %59, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.9, i64 0, i64 0), i8* %20) #17, !dbg !309
  call void @llvm.dbg.value(metadata i32 0, metadata !111, metadata !DIExpression()) #16, !dbg !311
  %60 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !313, !tbaa !86
  %61 = tail call i64 @fwrite(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.3, i64 0, i64 0), i64 73, i64 1, %struct._IO_FILE* %60) #19, !dbg !313
  %62 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !314, !tbaa !86
  %63 = tail call i64 @fwrite(i8* getelementptr inbounds ([62 x i8], [62 x i8]* @.str.4, i64 0, i64 0), i64 61, i64 1, %struct._IO_FILE* %62) #19, !dbg !314
  call void @llvm.dbg.value(metadata i32 0, metadata !203, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 undef, metadata !169, metadata !DIExpression()), !dbg !219
  %64 = load i32, i32* @lc_disabled_count, !dbg !315
  %clock_running31 = icmp eq i32 %64, 0, !dbg !315
  br i1 %clock_running31, label %if_clock_enabled32, label %postClockEnabledBlock37, !dbg !315

if_clock_enabled32:                               ; preds = %if.end59
  %65 = load i64, i64* @LocalLC, !dbg !315
  %66 = add i64 66, %65, !dbg !315
  store i64 %66, i64* @LocalLC, !dbg !315
  %commit33 = icmp ugt i64 %66, 5000, !dbg !315
  br i1 %commit33, label %pushBlock35, label %postInstrumentation34, !dbg !315

pushBlock35:                                      ; preds = %if_clock_enabled32
  %67 = add i32 %64, 1, !dbg !315
  store i32 %67, i32* @lc_disabled_count, !dbg !315
  store i64 9, i64* @LocalLC, !dbg !315
  %ci_handler36 = load void (i64)*, void (i64)** @intvActionHook, !dbg !315
  call void %ci_handler36(i64 %66), !dbg !315
  %68 = load i32, i32* @lc_disabled_count, !dbg !315
  %69 = sub i32 %68, 1, !dbg !315
  store i32 %69, i32* @lc_disabled_count, !dbg !315
  br label %postInstrumentation34, !dbg !315

postInstrumentation34:                            ; preds = %if_clock_enabled32, %pushBlock35
  br label %postClockEnabledBlock37, !dbg !315

postClockEnabledBlock37:                          ; preds = %if.end59, %postInstrumentation34
  br label %cleanup308, !dbg !315

if.end63_dummy:                                   ; preds = %if.then11, %if.else
  %__v.0.sink.ph = phi i16 [ %rev458, %if.then11 ], [ %39, %if.else ]
  %70 = load i32, i32* @lc_disabled_count, !dbg !316
  %clock_running38 = icmp eq i32 %70, 0, !dbg !316
  br i1 %clock_running38, label %if_clock_enabled39, label %postClockEnabledBlock44, !dbg !316

if_clock_enabled39:                               ; preds = %if.end63_dummy
  %71 = load i64, i64* @LocalLC, !dbg !316
  %72 = add i64 20, %71, !dbg !316
  store i64 %72, i64* @LocalLC, !dbg !316
  %commit40 = icmp ugt i64 %72, 5000, !dbg !316
  br i1 %commit40, label %pushBlock42, label %postInstrumentation41, !dbg !316

pushBlock42:                                      ; preds = %if_clock_enabled39
  %73 = add i32 %70, 1, !dbg !316
  store i32 %73, i32* @lc_disabled_count, !dbg !316
  store i64 9, i64* @LocalLC, !dbg !316
  %ci_handler43 = load void (i64)*, void (i64)** @intvActionHook, !dbg !316
  call void %ci_handler43(i64 %72), !dbg !316
  %74 = load i32, i32* @lc_disabled_count, !dbg !316
  %75 = sub i32 %74, 1, !dbg !316
  store i32 %75, i32* @lc_disabled_count, !dbg !316
  br label %postInstrumentation41, !dbg !316

postInstrumentation41:                            ; preds = %if_clock_enabled39, %pushBlock42
  br label %postClockEnabledBlock44, !dbg !316

postClockEnabledBlock44:                          ; preds = %if.end63_dummy, %postInstrumentation41
  br label %if.end63, !dbg !316

if.end63_dummy1:                                  ; preds = %if.then40, %if.else49
  %__v.0.sink.ph2 = phi i16 [ %rev, %if.then40 ], [ %58, %if.else49 ]
  %76 = load i32, i32* @lc_disabled_count, !dbg !316
  %clock_running45 = icmp eq i32 %76, 0, !dbg !316
  br i1 %clock_running45, label %if_clock_enabled46, label %postClockEnabledBlock51, !dbg !316

if_clock_enabled46:                               ; preds = %if.end63_dummy1
  %77 = load i64, i64* @LocalLC, !dbg !316
  %78 = add i64 20, %77, !dbg !316
  store i64 %78, i64* @LocalLC, !dbg !316
  %commit47 = icmp ugt i64 %78, 5000, !dbg !316
  br i1 %commit47, label %pushBlock49, label %postInstrumentation48, !dbg !316

pushBlock49:                                      ; preds = %if_clock_enabled46
  %79 = add i32 %76, 1, !dbg !316
  store i32 %79, i32* @lc_disabled_count, !dbg !316
  store i64 9, i64* @LocalLC, !dbg !316
  %ci_handler50 = load void (i64)*, void (i64)** @intvActionHook, !dbg !316
  call void %ci_handler50(i64 %78), !dbg !316
  %80 = load i32, i32* @lc_disabled_count, !dbg !316
  %81 = sub i32 %80, 1, !dbg !316
  store i32 %81, i32* @lc_disabled_count, !dbg !316
  br label %postInstrumentation48, !dbg !316

postInstrumentation48:                            ; preds = %if_clock_enabled46, %pushBlock49
  br label %postClockEnabledBlock51, !dbg !316

postClockEnabledBlock51:                          ; preds = %if.end63_dummy1, %postInstrumentation48
  br label %if.end63, !dbg !316

if.end63:                                         ; preds = %postClockEnabledBlock51, %postClockEnabledBlock44
  %daddr.sink = phi %struct.sockaddr_in* [ %daddr, %postClockEnabledBlock44 ], [ %saddr, %postClockEnabledBlock51 ]
  %__v.0.sink = phi i16 [ %__v.0.sink.ph, %postClockEnabledBlock44 ], [ %__v.0.sink.ph2, %postClockEnabledBlock51 ]
  %mode.0.ph = phi i32 [ 1, %postClockEnabledBlock44 ], [ 2, %postClockEnabledBlock51 ]
  %sin_port = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %daddr.sink, i64 0, i32 1, !dbg !316
  store i16 %__v.0.sink, i16* %sin_port, align 2, !dbg !316, !tbaa !317
  %arrayidx17 = getelementptr inbounds i8*, i8** %argv, i64 4, !dbg !316
  %82 = load i8*, i8** %arrayidx17, align 8, !dbg !316, !tbaa !86
  %call.i459 = tail call i64 @strtol(i8* nocapture nonnull %82, i8** null, i32 10) #16, !dbg !316
  call void @llvm.dbg.value(metadata i32 0, metadata !203, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 undef, metadata !169, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata %struct.mtcp_conf* %mcfg, metadata !134, metadata !DIExpression(DW_OP_deref)), !dbg !219
  %call64 = call i32 @mtcp_getconf(%struct.mtcp_conf* nonnull %mcfg) #16, !dbg !318
  %num_cores = getelementptr inbounds %struct.mtcp_conf, %struct.mtcp_conf* %mcfg, i64 0, i32 0, !dbg !319
  store i32 1, i32* %num_cores, align 4, !dbg !320, !tbaa !321
  call void @llvm.dbg.value(metadata %struct.mtcp_conf* %mcfg, metadata !134, metadata !DIExpression(DW_OP_deref)), !dbg !219
  %call65 = call i32 @mtcp_setconf(%struct.mtcp_conf* nonnull %mcfg) #16, !dbg !323
  %call66 = call i64 @time(i64* null) #16, !dbg !324
  %conv67 = trunc i64 %call66 to i32, !dbg !324
  call void @srand(i32 %conv67) #16, !dbg !325
  %83 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !326, !tbaa !86
  %84 = call i64 @fwrite(i8* getelementptr inbounds ([31 x i8], [31 x i8]* @.str.10, i64 0, i64 0), i64 30, i64 1, %struct._IO_FILE* %83) #17, !dbg !326
  %call69 = call i32 @mtcp_init(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.11, i64 0, i64 0)) #16, !dbg !327
  %tobool = icmp eq i32 %call69, 0, !dbg !327
  br i1 %tobool, label %if.end72, label %if.then70, !dbg !329

if.then70:                                        ; preds = %if.end63
  %85 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !330, !tbaa !86
  %86 = call i64 @fwrite(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.12, i64 0, i64 0), i64 28, i64 1, %struct._IO_FILE* %85) #17, !dbg !330
  %87 = load i32, i32* @lc_disabled_count, !dbg !332
  %clock_running52 = icmp eq i32 %87, 0, !dbg !332
  br i1 %clock_running52, label %if_clock_enabled53, label %postClockEnabledBlock58, !dbg !332

if_clock_enabled53:                               ; preds = %if.then70
  %88 = load i64, i64* @LocalLC, !dbg !332
  %89 = add i64 24, %88, !dbg !332
  store i64 %89, i64* @LocalLC, !dbg !332
  %commit54 = icmp ugt i64 %89, 5000, !dbg !332
  br i1 %commit54, label %pushBlock56, label %postInstrumentation55, !dbg !332

pushBlock56:                                      ; preds = %if_clock_enabled53
  %90 = add i32 %87, 1, !dbg !332
  store i32 %90, i32* @lc_disabled_count, !dbg !332
  store i64 9, i64* @LocalLC, !dbg !332
  %ci_handler57 = load void (i64)*, void (i64)** @intvActionHook, !dbg !332
  call void %ci_handler57(i64 %89), !dbg !332
  %91 = load i32, i32* @lc_disabled_count, !dbg !332
  %92 = sub i32 %91, 1, !dbg !332
  store i32 %92, i32* @lc_disabled_count, !dbg !332
  br label %postInstrumentation55, !dbg !332

postInstrumentation55:                            ; preds = %if_clock_enabled53, %pushBlock56
  br label %postClockEnabledBlock58, !dbg !332

postClockEnabledBlock58:                          ; preds = %if.then70, %postInstrumentation55
  br label %cleanup308, !dbg !332

if.end72:                                         ; preds = %if.end63
  call void @llvm.dbg.value(metadata %struct.mtcp_conf* %mcfg, metadata !134, metadata !DIExpression(DW_OP_deref)), !dbg !219
  %call73 = call i32 @mtcp_getconf(%struct.mtcp_conf* nonnull %mcfg) #16, !dbg !333
  %max_concurrency = getelementptr inbounds %struct.mtcp_conf, %struct.mtcp_conf* %mcfg, i64 0, i32 1, !dbg !334
  store i32 3, i32* %max_concurrency, align 4, !dbg !335, !tbaa !336
  %max_num_buffers = getelementptr inbounds %struct.mtcp_conf, %struct.mtcp_conf* %mcfg, i64 0, i32 2, !dbg !337
  store i32 3, i32* %max_num_buffers, align 4, !dbg !338, !tbaa !339
  call void @llvm.dbg.value(metadata %struct.mtcp_conf* %mcfg, metadata !134, metadata !DIExpression(DW_OP_deref)), !dbg !219
  %call74 = call i32 @mtcp_setconf(%struct.mtcp_conf* nonnull %mcfg) #16, !dbg !340
  %call75 = call void (i32)* @mtcp_register_signal(i32 2, void (i32)* nonnull @SignalHandler) #16, !dbg !341
  %93 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !342, !tbaa !86
  %94 = call i64 @fwrite(i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.13, i64 0, i64 0), i64 35, i64 1, %struct._IO_FILE* %93) #17, !dbg !342
  %call77 = call i32 @mtcp_core_affinitize(i32 0) #16, !dbg !343
  %call84 = call %struct.mtcp_context* @mtcp_create_context(i32 0) #16, !dbg !344
  %tobool87 = icmp eq %struct.mtcp_context* %call84, null, !dbg !345
  %95 = load i32, i32* @lc_disabled_count, !dbg !347
  %clock_running59 = icmp eq i32 %95, 0, !dbg !347
  br i1 %clock_running59, label %if_clock_enabled60, label %postClockEnabledBlock65, !dbg !347

if_clock_enabled60:                               ; preds = %if.end72
  %96 = load i64, i64* @LocalLC, !dbg !347
  %97 = add i64 36, %96, !dbg !347
  store i64 %97, i64* @LocalLC, !dbg !347
  %commit61 = icmp ugt i64 %97, 5000, !dbg !347
  br i1 %commit61, label %pushBlock63, label %postInstrumentation62, !dbg !347

pushBlock63:                                      ; preds = %if_clock_enabled60
  %98 = add i32 %95, 1, !dbg !347
  store i32 %98, i32* @lc_disabled_count, !dbg !347
  store i64 9, i64* @LocalLC, !dbg !347
  %ci_handler64 = load void (i64)*, void (i64)** @intvActionHook, !dbg !347
  call void %ci_handler64(i64 %97), !dbg !347
  %99 = load i32, i32* @lc_disabled_count, !dbg !347
  %100 = sub i32 %99, 1, !dbg !347
  store i32 %100, i32* @lc_disabled_count, !dbg !347
  br label %postInstrumentation62, !dbg !347

postInstrumentation62:                            ; preds = %if_clock_enabled60, %pushBlock63
  br label %postClockEnabledBlock65, !dbg !347

postClockEnabledBlock65:                          ; preds = %if.end72, %postInstrumentation62
  br i1 %tobool87, label %if.then88, label %if.end90, !dbg !347

if.then88:                                        ; preds = %postClockEnabledBlock65
  %101 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !348, !tbaa !86
  %102 = call i64 @fwrite(i8* getelementptr inbounds ([32 x i8], [32 x i8]* @.str.16, i64 0, i64 0), i64 31, i64 1, %struct._IO_FILE* %101) #17, !dbg !348
  %103 = load i32, i32* @lc_disabled_count, !dbg !350
  %clock_running66 = icmp eq i32 %103, 0, !dbg !350
  br i1 %clock_running66, label %if_clock_enabled67, label %postClockEnabledBlock72, !dbg !350

if_clock_enabled67:                               ; preds = %if.then88
  %104 = load i64, i64* @LocalLC, !dbg !350
  %105 = add i64 3, %104, !dbg !350
  store i64 %105, i64* @LocalLC, !dbg !350
  %commit68 = icmp ugt i64 %105, 5000, !dbg !350
  br i1 %commit68, label %pushBlock70, label %postInstrumentation69, !dbg !350

pushBlock70:                                      ; preds = %if_clock_enabled67
  %106 = add i32 %103, 1, !dbg !350
  store i32 %106, i32* @lc_disabled_count, !dbg !350
  store i64 9, i64* @LocalLC, !dbg !350
  %ci_handler71 = load void (i64)*, void (i64)** @intvActionHook, !dbg !350
  call void %ci_handler71(i64 %105), !dbg !350
  %107 = load i32, i32* @lc_disabled_count, !dbg !350
  %108 = sub i32 %107, 1, !dbg !350
  store i32 %108, i32* @lc_disabled_count, !dbg !350
  br label %postInstrumentation69, !dbg !350

postInstrumentation69:                            ; preds = %if_clock_enabled67, %pushBlock70
  br label %postClockEnabledBlock72, !dbg !350

postClockEnabledBlock72:                          ; preds = %if.then88, %postInstrumentation69
  br label %cleanup308, !dbg !350

if.end90:                                         ; preds = %postClockEnabledBlock65
  call void @llvm.dbg.value(metadata %struct.mtcp_context* %call84, metadata !133, metadata !DIExpression()), !dbg !219
  store %struct.mtcp_context* %call84, %struct.mtcp_context** @mtcp_ctx, align 8, !dbg !351, !tbaa !86
  %cmp93 = icmp eq i32 %mode.0.ph, 1, !dbg !352
  br i1 %cmp93, label %if.then95, label %if.end102, !dbg !354

if.then95:                                        ; preds = %if.end90
  %109 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !355, !tbaa !86
  %110 = call i64 @fwrite(i8* getelementptr inbounds ([46 x i8], [46 x i8]* @.str.17, i64 0, i64 0), i64 45, i64 1, %struct._IO_FILE* %109) #17, !dbg !355
  %s_addr98 = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %daddr, i64 0, i32 2, i32 0, !dbg !357
  %111 = load i32, i32* %s_addr98, align 4, !dbg !357, !tbaa !265
  %sin_port99 = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %daddr, i64 0, i32 1, !dbg !358
  %112 = load i16, i16* %sin_port99, align 2, !dbg !358, !tbaa !317
  %conv100 = zext i16 %112 to i32, !dbg !359
  %call101 = call i32 @mtcp_init_rss(%struct.mtcp_context* nonnull %call84, i32 0, i32 1, i32 %111, i32 %conv100) #16, !dbg !360
  br label %if.end102, !dbg !361

if.end102:                                        ; preds = %if.then95, %if.end90
  %113 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !362, !tbaa !86
  %114 = call i64 @fwrite(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.18, i64 0, i64 0), i64 28, i64 1, %struct._IO_FILE* %113) #17, !dbg !362
  %115 = load i32, i32* %max_num_buffers, align 4, !dbg !363, !tbaa !339
  %call106 = call i32 @mtcp_epoll_create(%struct.mtcp_context* nonnull %call84, i32 %115) #16, !dbg !364
  call void @llvm.dbg.value(metadata i32 %call106, metadata !148, metadata !DIExpression()), !dbg !219
  %116 = load i32, i32* %max_num_buffers, align 4, !dbg !365, !tbaa !339
  %conv108 = sext i32 %116 to i64, !dbg !366
  %call109 = call noalias i8* @calloc(i64 %conv108, i64 16) #16, !dbg !367
  %117 = bitcast i8* %call109 to %struct.mtcp_epoll_event*, !dbg !368
  call void @llvm.dbg.value(metadata %struct.mtcp_epoll_event* %117, metadata !145, metadata !DIExpression()), !dbg !219
  %tobool110 = icmp eq i8* %call109, null, !dbg !369
  %118 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !219, !tbaa !86
  %119 = load i32, i32* @lc_disabled_count, !dbg !371
  %clock_running73 = icmp eq i32 %119, 0, !dbg !371
  br i1 %clock_running73, label %if_clock_enabled74, label %postClockEnabledBlock79, !dbg !371

if_clock_enabled74:                               ; preds = %if.end102
  %120 = load i64, i64* @LocalLC, !dbg !371
  %121 = add i64 21, %120, !dbg !371
  store i64 %121, i64* @LocalLC, !dbg !371
  %commit75 = icmp ugt i64 %121, 5000, !dbg !371
  br i1 %commit75, label %pushBlock77, label %postInstrumentation76, !dbg !371

pushBlock77:                                      ; preds = %if_clock_enabled74
  %122 = add i32 %119, 1, !dbg !371
  store i32 %122, i32* @lc_disabled_count, !dbg !371
  store i64 9, i64* @LocalLC, !dbg !371
  %ci_handler78 = load void (i64)*, void (i64)** @intvActionHook, !dbg !371
  call void %ci_handler78(i64 %121), !dbg !371
  %123 = load i32, i32* @lc_disabled_count, !dbg !371
  %124 = sub i32 %123, 1, !dbg !371
  store i32 %124, i32* @lc_disabled_count, !dbg !371
  br label %postInstrumentation76, !dbg !371

postInstrumentation76:                            ; preds = %if_clock_enabled74, %pushBlock77
  br label %postClockEnabledBlock79, !dbg !371

postClockEnabledBlock79:                          ; preds = %if.end102, %postInstrumentation76
  br i1 %tobool110, label %if.then111, label %if.end113, !dbg !371

if.then111:                                       ; preds = %postClockEnabledBlock79
  %125 = call i64 @fwrite(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.19, i64 0, i64 0), i64 27, i64 1, %struct._IO_FILE* %118) #17, !dbg !372
  %126 = load i32, i32* @lc_disabled_count, !dbg !374
  %clock_running80 = icmp eq i32 %126, 0, !dbg !374
  br i1 %clock_running80, label %if_clock_enabled81, label %postClockEnabledBlock86, !dbg !374

if_clock_enabled81:                               ; preds = %if.then111
  %127 = load i64, i64* @LocalLC, !dbg !374
  %128 = add i64 2, %127, !dbg !374
  store i64 %128, i64* @LocalLC, !dbg !374
  %commit82 = icmp ugt i64 %128, 5000, !dbg !374
  br i1 %commit82, label %pushBlock84, label %postInstrumentation83, !dbg !374

pushBlock84:                                      ; preds = %if_clock_enabled81
  %129 = add i32 %126, 1, !dbg !374
  store i32 %129, i32* @lc_disabled_count, !dbg !374
  store i64 9, i64* @LocalLC, !dbg !374
  %ci_handler85 = load void (i64)*, void (i64)** @intvActionHook, !dbg !374
  call void %ci_handler85(i64 %128), !dbg !374
  %130 = load i32, i32* @lc_disabled_count, !dbg !374
  %131 = sub i32 %130, 1, !dbg !374
  store i32 %131, i32* @lc_disabled_count, !dbg !374
  br label %postInstrumentation83, !dbg !374

postInstrumentation83:                            ; preds = %if_clock_enabled81, %pushBlock84
  br label %postClockEnabledBlock86, !dbg !374

postClockEnabledBlock86:                          ; preds = %if.then111, %postInstrumentation83
  br label %cleanup308, !dbg !374

if.end113:                                        ; preds = %postClockEnabledBlock79
  %132 = call i64 @fwrite(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.20, i64 0, i64 0), i64 27, i64 1, %struct._IO_FILE* %118) #17, !dbg !375
  %call115 = call i32 @mtcp_socket(%struct.mtcp_context* nonnull %call84, i32 2, i32 1, i32 0) #16, !dbg !376
  call void @llvm.dbg.value(metadata i32 %call115, metadata !167, metadata !DIExpression()), !dbg !219
  %cmp116 = icmp slt i32 %call115, 0, !dbg !377
  br i1 %cmp116, label %if.then118, label %if.end120, !dbg !379

if.then118:                                       ; preds = %if.end113
  %133 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !380, !tbaa !86
  %134 = call i64 @fwrite(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.21, i64 0, i64 0), i64 25, i64 1, %struct._IO_FILE* %133) #17, !dbg !380
  %135 = load i32, i32* @lc_disabled_count, !dbg !382
  %clock_running87 = icmp eq i32 %135, 0, !dbg !382
  br i1 %clock_running87, label %if_clock_enabled88, label %postClockEnabledBlock93, !dbg !382

if_clock_enabled88:                               ; preds = %if.then118
  %136 = load i64, i64* @LocalLC, !dbg !382
  %137 = add i64 8, %136, !dbg !382
  store i64 %137, i64* @LocalLC, !dbg !382
  %commit89 = icmp ugt i64 %137, 5000, !dbg !382
  br i1 %commit89, label %pushBlock91, label %postInstrumentation90, !dbg !382

pushBlock91:                                      ; preds = %if_clock_enabled88
  %138 = add i32 %135, 1, !dbg !382
  store i32 %138, i32* @lc_disabled_count, !dbg !382
  store i64 9, i64* @LocalLC, !dbg !382
  %ci_handler92 = load void (i64)*, void (i64)** @intvActionHook, !dbg !382
  call void %ci_handler92(i64 %137), !dbg !382
  %139 = load i32, i32* @lc_disabled_count, !dbg !382
  %140 = sub i32 %139, 1, !dbg !382
  store i32 %140, i32* @lc_disabled_count, !dbg !382
  br label %postInstrumentation90, !dbg !382

postInstrumentation90:                            ; preds = %if_clock_enabled88, %pushBlock91
  br label %postClockEnabledBlock93, !dbg !382

postClockEnabledBlock93:                          ; preds = %if.then118, %postInstrumentation90
  br label %cleanup308, !dbg !382

if.end120:                                        ; preds = %if.end113
  %call121 = call i32 @mtcp_setsock_nonblock(%struct.mtcp_context* nonnull %call84, i32 %call115) #16, !dbg !383
  call void @llvm.dbg.value(metadata i32 %call121, metadata !130, metadata !DIExpression()), !dbg !219
  %cmp122 = icmp slt i32 %call121, 0, !dbg !384
  br i1 %cmp122, label %if.then124, label %if.end126, !dbg !386

if.then124:                                       ; preds = %if.end120
  %141 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !387, !tbaa !86
  %142 = call i64 @fwrite(i8* getelementptr inbounds ([43 x i8], [43 x i8]* @.str.22, i64 0, i64 0), i64 42, i64 1, %struct._IO_FILE* %141) #17, !dbg !387
  %143 = load i32, i32* @lc_disabled_count, !dbg !389
  %clock_running94 = icmp eq i32 %143, 0, !dbg !389
  br i1 %clock_running94, label %if_clock_enabled95, label %postClockEnabledBlock100, !dbg !389

if_clock_enabled95:                               ; preds = %if.then124
  %144 = load i64, i64* @LocalLC, !dbg !389
  %145 = add i64 12, %144, !dbg !389
  store i64 %145, i64* @LocalLC, !dbg !389
  %commit96 = icmp ugt i64 %145, 5000, !dbg !389
  br i1 %commit96, label %pushBlock98, label %postInstrumentation97, !dbg !389

pushBlock98:                                      ; preds = %if_clock_enabled95
  %146 = add i32 %143, 1, !dbg !389
  store i32 %146, i32* @lc_disabled_count, !dbg !389
  store i64 9, i64* @LocalLC, !dbg !389
  %ci_handler99 = load void (i64)*, void (i64)** @intvActionHook, !dbg !389
  call void %ci_handler99(i64 %145), !dbg !389
  %147 = load i32, i32* @lc_disabled_count, !dbg !389
  %148 = sub i32 %147, 1, !dbg !389
  store i32 %148, i32* @lc_disabled_count, !dbg !389
  br label %postInstrumentation97, !dbg !389

postInstrumentation97:                            ; preds = %if_clock_enabled95, %pushBlock98
  br label %postClockEnabledBlock100, !dbg !389

postClockEnabledBlock100:                         ; preds = %if.then124, %postInstrumentation97
  br label %cleanup308, !dbg !389

if.end126:                                        ; preds = %if.end120
  %events127 = getelementptr inbounds %struct.mtcp_epoll_event, %struct.mtcp_epoll_event* %ev, i64 0, i32 0, !dbg !390
  store i32 1, i32* %events127, align 8, !dbg !391, !tbaa !392
  %data = getelementptr inbounds %struct.mtcp_epoll_event, %struct.mtcp_epoll_event* %ev, i64 0, i32 1, !dbg !394
  %sockid = bitcast %union.mtcp_epoll_data* %data to i32*, !dbg !395
  store i32 %call115, i32* %sockid, align 8, !dbg !396, !tbaa !397
  call void @llvm.dbg.value(metadata %struct.mtcp_epoll_event* %ev, metadata !146, metadata !DIExpression(DW_OP_deref)), !dbg !219
  %call128 = call i32 @mtcp_epoll_ctl(%struct.mtcp_context* nonnull %call84, i32 %call106, i32 1, i32 %call115, %struct.mtcp_epoll_event* nonnull %ev) #16, !dbg !398
  %cmp129 = icmp eq i32 %mode.0.ph, 2, !dbg !399
  %149 = load i32, i32* @lc_disabled_count, !dbg !401
  %clock_running101 = icmp eq i32 %149, 0, !dbg !401
  br i1 %clock_running101, label %if_clock_enabled102, label %postClockEnabledBlock107, !dbg !401

if_clock_enabled102:                              ; preds = %if.end126
  %150 = load i64, i64* @LocalLC, !dbg !401
  %151 = add i64 18, %150, !dbg !401
  store i64 %151, i64* @LocalLC, !dbg !401
  %commit103 = icmp ugt i64 %151, 5000, !dbg !401
  br i1 %commit103, label %pushBlock105, label %postInstrumentation104, !dbg !401

pushBlock105:                                     ; preds = %if_clock_enabled102
  %152 = add i32 %149, 1, !dbg !401
  store i32 %152, i32* @lc_disabled_count, !dbg !401
  store i64 9, i64* @LocalLC, !dbg !401
  %ci_handler106 = load void (i64)*, void (i64)** @intvActionHook, !dbg !401
  call void %ci_handler106(i64 %151), !dbg !401
  %153 = load i32, i32* @lc_disabled_count, !dbg !401
  %154 = sub i32 %153, 1, !dbg !401
  store i32 %154, i32* @lc_disabled_count, !dbg !401
  br label %postInstrumentation104, !dbg !401

postInstrumentation104:                           ; preds = %if_clock_enabled102, %pushBlock105
  br label %postClockEnabledBlock107, !dbg !401

postClockEnabledBlock107:                         ; preds = %if.end126, %postInstrumentation104
  br i1 %cmp129, label %if.then131, label %end_wait_loop, !dbg !401

if.then131:                                       ; preds = %postClockEnabledBlock107
  %155 = bitcast %struct.sockaddr_in* %saddr to %struct.sockaddr*, !dbg !402
  %call132 = call i32 @mtcp_bind(%struct.mtcp_context* nonnull %call84, i32 %call115, %struct.sockaddr* nonnull %155, i32 16) #16, !dbg !404
  call void @llvm.dbg.value(metadata i32 %call132, metadata !130, metadata !DIExpression()), !dbg !219
  %cmp133 = icmp slt i32 %call132, 0, !dbg !405
  br i1 %cmp133, label %if.then135, label %if.end137, !dbg !407

if.then135:                                       ; preds = %if.then131
  %156 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !408, !tbaa !86
  %157 = call i64 @fwrite(i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.23, i64 0, i64 0), i64 40, i64 1, %struct._IO_FILE* %156) #17, !dbg !408
  br label %if.end137, !dbg !410

if.end137:                                        ; preds = %if.then135, %if.then131
  %call138 = call i32 @mtcp_listen(%struct.mtcp_context* nonnull %call84, i32 %call115, i32 3) #16, !dbg !411
  call void @llvm.dbg.value(metadata i32 %call138, metadata !130, metadata !DIExpression()), !dbg !219
  %cmp139 = icmp slt i32 %call138, 0, !dbg !412
  br i1 %cmp139, label %if.then141, label %if.end145, !dbg !414

if.then141:                                       ; preds = %if.end137
  %158 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !415, !tbaa !86
  %call142 = tail call i32* @__errno_location() #11, !dbg !415
  %159 = load i32, i32* %call142, align 4, !dbg !415, !tbaa !417
  %call143 = call i8* @strerror(i32 %159) #16, !dbg !415
  %call144 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %158, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.24, i64 0, i64 0), i8* %call143) #17, !dbg !415
  br label %if.end145, !dbg !418

if.end145:                                        ; preds = %if.then141, %if.end137
  %call146482 = call i32 @mtcp_epoll_wait(%struct.mtcp_context* nonnull %call84, i32 %call106, %struct.mtcp_epoll_event* nonnull %117, i32 30000, i32 -1) #16, !dbg !419
  call void @llvm.dbg.value(metadata i32 %call146482, metadata !174, metadata !DIExpression()), !dbg !219
  %cmp147483 = icmp slt i32 %call146482, 0, !dbg !421
  %160 = load i32, i32* @lc_disabled_count, !dbg !423
  %clock_running108 = icmp eq i32 %160, 0, !dbg !423
  br i1 %clock_running108, label %if_clock_enabled109, label %postClockEnabledBlock114, !dbg !423

if_clock_enabled109:                              ; preds = %if.end145
  %161 = load i64, i64* @LocalLC, !dbg !423
  %162 = add i64 13, %161, !dbg !423
  store i64 %162, i64* @LocalLC, !dbg !423
  %commit110 = icmp ugt i64 %162, 5000, !dbg !423
  br i1 %commit110, label %pushBlock112, label %postInstrumentation111, !dbg !423

pushBlock112:                                     ; preds = %if_clock_enabled109
  %163 = add i32 %160, 1, !dbg !423
  store i32 %163, i32* @lc_disabled_count, !dbg !423
  store i64 9, i64* @LocalLC, !dbg !423
  %ci_handler113 = load void (i64)*, void (i64)** @intvActionHook, !dbg !423
  call void %ci_handler113(i64 %162), !dbg !423
  %164 = load i32, i32* @lc_disabled_count, !dbg !423
  %165 = sub i32 %164, 1, !dbg !423
  store i32 %165, i32* @lc_disabled_count, !dbg !423
  br label %postInstrumentation111, !dbg !423

postInstrumentation111:                           ; preds = %if_clock_enabled109, %pushBlock112
  br label %postClockEnabledBlock114, !dbg !423

postClockEnabledBlock114:                         ; preds = %if.end145, %postInstrumentation111
  br i1 %cmp147483, label %if.then149, label %for.cond.preheader.preheader, !dbg !423

for.cond.preheader.preheader:                     ; preds = %postClockEnabledBlock114
  %166 = load i32, i32* @lc_disabled_count, !dbg !424
  %clock_running115 = icmp eq i32 %166, 0, !dbg !424
  br i1 %clock_running115, label %if_clock_enabled116, label %postClockEnabledBlock121, !dbg !424

if_clock_enabled116:                              ; preds = %for.cond.preheader.preheader
  %167 = load i64, i64* @LocalLC, !dbg !424
  %168 = add i64 1, %167, !dbg !424
  store i64 %168, i64* @LocalLC, !dbg !424
  %commit117 = icmp ugt i64 %168, 5000, !dbg !424
  br i1 %commit117, label %pushBlock119, label %postInstrumentation118, !dbg !424

pushBlock119:                                     ; preds = %if_clock_enabled116
  %169 = add i32 %166, 1, !dbg !424
  store i32 %169, i32* @lc_disabled_count, !dbg !424
  store i64 9, i64* @LocalLC, !dbg !424
  %ci_handler120 = load void (i64)*, void (i64)** @intvActionHook, !dbg !424
  call void %ci_handler120(i64 %168), !dbg !424
  %170 = load i32, i32* @lc_disabled_count, !dbg !424
  %171 = sub i32 %170, 1, !dbg !424
  store i32 %171, i32* @lc_disabled_count, !dbg !424
  br label %postInstrumentation118, !dbg !424

postInstrumentation118:                           ; preds = %if_clock_enabled116, %pushBlock119
  br label %postClockEnabledBlock121, !dbg !424

postClockEnabledBlock121:                         ; preds = %for.cond.preheader.preheader, %postInstrumentation118
  br label %for.cond.preheader, !dbg !424

while.cond.loopexit.loopexit:                     ; preds = %postClockEnabledBlock177
  %172 = load i32, i32* @lc_disabled_count, !dbg !419
  %clock_running122 = icmp eq i32 %172, 0, !dbg !419
  br i1 %clock_running122, label %if_clock_enabled123, label %postClockEnabledBlock128, !dbg !419

if_clock_enabled123:                              ; preds = %while.cond.loopexit.loopexit
  %173 = load i64, i64* @LocalLC, !dbg !419
  %174 = add i64 1, %173, !dbg !419
  store i64 %174, i64* @LocalLC, !dbg !419
  %commit124 = icmp ugt i64 %174, 5000, !dbg !419
  br i1 %commit124, label %pushBlock126, label %postInstrumentation125, !dbg !419

pushBlock126:                                     ; preds = %if_clock_enabled123
  %175 = add i32 %172, 1, !dbg !419
  store i32 %175, i32* @lc_disabled_count, !dbg !419
  store i64 9, i64* @LocalLC, !dbg !419
  %ci_handler127 = load void (i64)*, void (i64)** @intvActionHook, !dbg !419
  call void %ci_handler127(i64 %174), !dbg !419
  %176 = load i32, i32* @lc_disabled_count, !dbg !419
  %177 = sub i32 %176, 1, !dbg !419
  store i32 %177, i32* @lc_disabled_count, !dbg !419
  br label %postInstrumentation125, !dbg !419

postInstrumentation125:                           ; preds = %if_clock_enabled123, %pushBlock126
  br label %postClockEnabledBlock128, !dbg !419

postClockEnabledBlock128:                         ; preds = %while.cond.loopexit.loopexit, %postInstrumentation125
  br label %while.cond.loopexit, !dbg !419

while.cond.loopexit:                              ; preds = %postClockEnabledBlock142, %postClockEnabledBlock128
  %call146 = call i32 @mtcp_epoll_wait(%struct.mtcp_context* nonnull %call84, i32 %call106, %struct.mtcp_epoll_event* nonnull %117, i32 30000, i32 -1) #16, !dbg !419
  call void @llvm.dbg.value(metadata i32 %call146, metadata !174, metadata !DIExpression()), !dbg !219
  %cmp147 = icmp slt i32 %call146, 0, !dbg !421
  %178 = load i32, i32* @lc_disabled_count, !dbg !423
  %clock_running129 = icmp eq i32 %178, 0, !dbg !423
  br i1 %clock_running129, label %if_clock_enabled130, label %postClockEnabledBlock135, !dbg !423

if_clock_enabled130:                              ; preds = %while.cond.loopexit
  %179 = load i64, i64* @LocalLC, !dbg !423
  %180 = add i64 4, %179, !dbg !423
  store i64 %180, i64* @LocalLC, !dbg !423
  %commit131 = icmp ugt i64 %180, 5000, !dbg !423
  br i1 %commit131, label %pushBlock133, label %postInstrumentation132, !dbg !423

pushBlock133:                                     ; preds = %if_clock_enabled130
  %181 = add i32 %178, 1, !dbg !423
  store i32 %181, i32* @lc_disabled_count, !dbg !423
  store i64 9, i64* @LocalLC, !dbg !423
  %ci_handler134 = load void (i64)*, void (i64)** @intvActionHook, !dbg !423
  call void %ci_handler134(i64 %180), !dbg !423
  %182 = load i32, i32* @lc_disabled_count, !dbg !423
  %183 = sub i32 %182, 1, !dbg !423
  store i32 %183, i32* @lc_disabled_count, !dbg !423
  br label %postInstrumentation132, !dbg !423

postInstrumentation132:                           ; preds = %if_clock_enabled130, %pushBlock133
  br label %postClockEnabledBlock135, !dbg !423

postClockEnabledBlock135:                         ; preds = %while.cond.loopexit, %postInstrumentation132
  br i1 %cmp147, label %if.then149.loopexit, label %for.cond.preheader, !dbg !423

for.cond.preheader:                               ; preds = %postClockEnabledBlock135, %postClockEnabledBlock121
  %call146484 = phi i32 [ %call146, %postClockEnabledBlock135 ], [ %call146482, %postClockEnabledBlock121 ]
  call void @llvm.dbg.value(metadata i32 0, metadata !131, metadata !DIExpression()), !dbg !219
  %cmp156480 = icmp sgt i32 %call146484, 0, !dbg !426
  %184 = load i32, i32* @lc_disabled_count, !dbg !424
  %clock_running136 = icmp eq i32 %184, 0, !dbg !424
  br i1 %clock_running136, label %if_clock_enabled137, label %postClockEnabledBlock142, !dbg !424

if_clock_enabled137:                              ; preds = %for.cond.preheader
  %185 = load i64, i64* @LocalLC, !dbg !424
  %186 = add i64 3, %185, !dbg !424
  store i64 %186, i64* @LocalLC, !dbg !424
  %commit138 = icmp ugt i64 %186, 5000, !dbg !424
  br i1 %commit138, label %pushBlock140, label %postInstrumentation139, !dbg !424

pushBlock140:                                     ; preds = %if_clock_enabled137
  %187 = add i32 %184, 1, !dbg !424
  store i32 %187, i32* @lc_disabled_count, !dbg !424
  store i64 9, i64* @LocalLC, !dbg !424
  %ci_handler141 = load void (i64)*, void (i64)** @intvActionHook, !dbg !424
  call void %ci_handler141(i64 %186), !dbg !424
  %188 = load i32, i32* @lc_disabled_count, !dbg !424
  %189 = sub i32 %188, 1, !dbg !424
  store i32 %189, i32* @lc_disabled_count, !dbg !424
  br label %postInstrumentation139, !dbg !424

postInstrumentation139:                           ; preds = %if_clock_enabled137, %pushBlock140
  br label %postClockEnabledBlock142, !dbg !424

postClockEnabledBlock142:                         ; preds = %for.cond.preheader, %postInstrumentation139
  br i1 %cmp156480, label %for.body.preheader, label %while.cond.loopexit, !dbg !424, !llvm.loop !428

for.body.preheader:                               ; preds = %postClockEnabledBlock142
  %wide.trip.count489 = zext i32 %call146484 to i64, !dbg !426
  %190 = load i32, i32* @lc_disabled_count, !dbg !424
  %clock_running143 = icmp eq i32 %190, 0, !dbg !424
  br i1 %clock_running143, label %if_clock_enabled144, label %postClockEnabledBlock149, !dbg !424

if_clock_enabled144:                              ; preds = %for.body.preheader
  %191 = load i64, i64* @LocalLC, !dbg !424
  %192 = add i64 2, %191, !dbg !424
  store i64 %192, i64* @LocalLC, !dbg !424
  %commit145 = icmp ugt i64 %192, 5000, !dbg !424
  br i1 %commit145, label %pushBlock147, label %postInstrumentation146, !dbg !424

pushBlock147:                                     ; preds = %if_clock_enabled144
  %193 = add i32 %190, 1, !dbg !424
  store i32 %193, i32* @lc_disabled_count, !dbg !424
  store i64 9, i64* @LocalLC, !dbg !424
  %ci_handler148 = load void (i64)*, void (i64)** @intvActionHook, !dbg !424
  call void %ci_handler148(i64 %192), !dbg !424
  %194 = load i32, i32* @lc_disabled_count, !dbg !424
  %195 = sub i32 %194, 1, !dbg !424
  store i32 %195, i32* @lc_disabled_count, !dbg !424
  br label %postInstrumentation146, !dbg !424

postInstrumentation146:                           ; preds = %if_clock_enabled144, %pushBlock147
  br label %postClockEnabledBlock149, !dbg !424

postClockEnabledBlock149:                         ; preds = %for.body.preheader, %postInstrumentation146
  br label %for.body, !dbg !424

if.then149.loopexit:                              ; preds = %postClockEnabledBlock135
  %196 = load i32, i32* @lc_disabled_count, !dbg !431
  %clock_running150 = icmp eq i32 %196, 0, !dbg !431
  br i1 %clock_running150, label %if_clock_enabled151, label %postClockEnabledBlock156, !dbg !431

if_clock_enabled151:                              ; preds = %if.then149.loopexit
  %197 = load i64, i64* @LocalLC, !dbg !431
  %198 = add i64 1, %197, !dbg !431
  store i64 %198, i64* @LocalLC, !dbg !431
  %commit152 = icmp ugt i64 %198, 5000, !dbg !431
  br i1 %commit152, label %pushBlock154, label %postInstrumentation153, !dbg !431

pushBlock154:                                     ; preds = %if_clock_enabled151
  %199 = add i32 %196, 1, !dbg !431
  store i32 %199, i32* @lc_disabled_count, !dbg !431
  store i64 9, i64* @LocalLC, !dbg !431
  %ci_handler155 = load void (i64)*, void (i64)** @intvActionHook, !dbg !431
  call void %ci_handler155(i64 %198), !dbg !431
  %200 = load i32, i32* @lc_disabled_count, !dbg !431
  %201 = sub i32 %200, 1, !dbg !431
  store i32 %201, i32* @lc_disabled_count, !dbg !431
  br label %postInstrumentation153, !dbg !431

postInstrumentation153:                           ; preds = %if_clock_enabled151, %pushBlock154
  br label %postClockEnabledBlock156, !dbg !431

postClockEnabledBlock156:                         ; preds = %if.then149.loopexit, %postInstrumentation153
  br label %if.then149, !dbg !431

if.then149:                                       ; preds = %postClockEnabledBlock156, %postClockEnabledBlock114
  %call150 = tail call i32* @__errno_location() #11, !dbg !431
  %202 = load i32, i32* %call150, align 4, !dbg !431, !tbaa !417
  %cmp151 = icmp eq i32 %202, 4, !dbg !434
  br i1 %cmp151, label %cleanup308_dummy, label %if.then153, !dbg !435

if.then153:                                       ; preds = %if.then149
  call void @perror(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.25, i64 0, i64 0)) #17, !dbg !436
  br label %cleanup308_dummy, !dbg !438

for.body:                                         ; preds = %postClockEnabledBlock177, %postClockEnabledBlock149
  %indvars.iv487 = phi i64 [ 0, %postClockEnabledBlock149 ], [ %indvars.iv.next488, %postClockEnabledBlock177 ]
  call void @llvm.dbg.value(metadata i64 %indvars.iv487, metadata !131, metadata !DIExpression()), !dbg !219
  %data159 = getelementptr inbounds %struct.mtcp_epoll_event, %struct.mtcp_epoll_event* %117, i64 %indvars.iv487, i32 1, !dbg !439
  %sockid160 = bitcast %union.mtcp_epoll_data* %data159 to i32*, !dbg !442
  %203 = load i32, i32* %sockid160, align 8, !dbg !442, !tbaa !397
  %cmp161 = icmp eq i32 %203, %call115, !dbg !443
  %204 = load i32, i32* @lc_disabled_count, !dbg !444
  %clock_running157 = icmp eq i32 %204, 0, !dbg !444
  br i1 %clock_running157, label %if_clock_enabled158, label %postClockEnabledBlock163, !dbg !444

if_clock_enabled158:                              ; preds = %for.body
  %205 = load i64, i64* @LocalLC, !dbg !444
  %206 = add i64 6, %205, !dbg !444
  store i64 %206, i64* @LocalLC, !dbg !444
  %commit159 = icmp ugt i64 %206, 5000, !dbg !444
  br i1 %commit159, label %pushBlock161, label %postInstrumentation160, !dbg !444

pushBlock161:                                     ; preds = %if_clock_enabled158
  %207 = add i32 %204, 1, !dbg !444
  store i32 %207, i32* @lc_disabled_count, !dbg !444
  store i64 9, i64* @LocalLC, !dbg !444
  %ci_handler162 = load void (i64)*, void (i64)** @intvActionHook, !dbg !444
  call void %ci_handler162(i64 %206), !dbg !444
  %208 = load i32, i32* @lc_disabled_count, !dbg !444
  %209 = sub i32 %208, 1, !dbg !444
  store i32 %209, i32* @lc_disabled_count, !dbg !444
  br label %postInstrumentation160, !dbg !444

postInstrumentation160:                           ; preds = %if_clock_enabled158, %pushBlock161
  br label %postClockEnabledBlock163, !dbg !444

postClockEnabledBlock163:                         ; preds = %for.body, %postInstrumentation160
  br i1 %cmp161, label %if.then163, label %if.else184, !dbg !444

if.then163:                                       ; preds = %postClockEnabledBlock163
  %call164 = call i32 @mtcp_accept(%struct.mtcp_context* nonnull %call84, i32 %call115, %struct.sockaddr* null, i32* null) #16, !dbg !445
  call void @llvm.dbg.value(metadata i32 %call164, metadata !132, metadata !DIExpression()), !dbg !219
  %cmp165 = icmp sgt i32 %call164, -1, !dbg !447
  br i1 %cmp165, label %if.then167, label %if.else174, !dbg !449

if.then167:                                       ; preds = %if.then163
  %cmp168 = icmp sgt i32 %call164, 9999, !dbg !450
  br i1 %cmp168, label %if.then170, label %if.end172, !dbg !453

if.then170:                                       ; preds = %if.then167
  %210 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !454, !tbaa !86
  %call171 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %210, i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.26, i64 0, i64 0), i32 %call164) #17, !dbg !454
  br label %if.end172, !dbg !456

if.end172:                                        ; preds = %if.then170, %if.then167
  %211 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !457, !tbaa !86
  %212 = call i64 @fwrite(i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.27, i64 0, i64 0), i64 32, i64 1, %struct._IO_FILE* %211) #17, !dbg !457
  br label %if.end178, !dbg !458

if.else174:                                       ; preds = %if.then163
  %213 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !459, !tbaa !86
  %call175 = tail call i32* @__errno_location() #11, !dbg !459
  %214 = load i32, i32* %call175, align 4, !dbg !459, !tbaa !417
  %call176 = call i8* @strerror(i32 %214) #16, !dbg !459
  %call177 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %213, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.28, i64 0, i64 0), i8* %call176) #17, !dbg !459
  br label %if.end178

if.end178:                                        ; preds = %if.else174, %if.end172
  call void @llvm.dbg.value(metadata %struct.mtcp_epoll_event* %ev, metadata !146, metadata !DIExpression(DW_OP_deref)), !dbg !219
  %call179 = call i32 @mtcp_epoll_ctl(%struct.mtcp_context* nonnull %call84, i32 %call106, i32 2, i32 %call115, %struct.mtcp_epoll_event* nonnull %ev) #16, !dbg !461
  call void @llvm.dbg.value(metadata i32 %call164, metadata !167, metadata !DIExpression()), !dbg !219
  store i32 5, i32* %events127, align 8, !dbg !462, !tbaa !392
  store i32 %call164, i32* %sockid, align 8, !dbg !463, !tbaa !397
  call void @llvm.dbg.value(metadata %struct.mtcp_epoll_event* %ev, metadata !146, metadata !DIExpression(DW_OP_deref)), !dbg !219
  %call183 = call i32 @mtcp_epoll_ctl(%struct.mtcp_context* nonnull %call84, i32 %call106, i32 1, i32 %call164, %struct.mtcp_epoll_event* nonnull %ev) #16, !dbg !464
  %215 = load i32, i32* @lc_disabled_count, !dbg !465
  %clock_running164 = icmp eq i32 %215, 0, !dbg !465
  br i1 %clock_running164, label %if_clock_enabled165, label %postClockEnabledBlock170, !dbg !465

if_clock_enabled165:                              ; preds = %if.end178
  %216 = load i64, i64* @LocalLC, !dbg !465
  %217 = add i64 18, %216, !dbg !465
  store i64 %217, i64* @LocalLC, !dbg !465
  %commit166 = icmp ugt i64 %217, 5000, !dbg !465
  br i1 %commit166, label %pushBlock168, label %postInstrumentation167, !dbg !465

pushBlock168:                                     ; preds = %if_clock_enabled165
  %218 = add i32 %215, 1, !dbg !465
  store i32 %218, i32* @lc_disabled_count, !dbg !465
  store i64 9, i64* @LocalLC, !dbg !465
  %ci_handler169 = load void (i64)*, void (i64)** @intvActionHook, !dbg !465
  call void %ci_handler169(i64 %217), !dbg !465
  %219 = load i32, i32* @lc_disabled_count, !dbg !465
  %220 = sub i32 %219, 1, !dbg !465
  store i32 %220, i32* @lc_disabled_count, !dbg !465
  br label %postInstrumentation167, !dbg !465

postInstrumentation167:                           ; preds = %if_clock_enabled165, %pushBlock168
  br label %postClockEnabledBlock170, !dbg !465

postClockEnabledBlock170:                         ; preds = %if.end178, %postInstrumentation167
  br label %end_wait_loop, !dbg !465

if.else184:                                       ; preds = %postClockEnabledBlock163
  %221 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !466, !tbaa !86
  %222 = call i64 @fwrite(i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str.29, i64 0, i64 0), i64 34, i64 1, %struct._IO_FILE* %221) #17, !dbg !466
  %indvars.iv.next488 = add nuw nsw i64 %indvars.iv487, 1, !dbg !468
  call void @llvm.dbg.value(metadata i32 undef, metadata !131, metadata !DIExpression(DW_OP_plus_uconst, 1, DW_OP_stack_value)), !dbg !219
  %exitcond490 = icmp eq i64 %indvars.iv.next488, %wide.trip.count489, !dbg !426
  %223 = load i32, i32* @lc_disabled_count, !dbg !424
  %clock_running171 = icmp eq i32 %223, 0, !dbg !424
  br i1 %clock_running171, label %if_clock_enabled172, label %postClockEnabledBlock177, !dbg !424

if_clock_enabled172:                              ; preds = %if.else184
  %224 = load i64, i64* @LocalLC, !dbg !424
  %225 = add i64 6, %224, !dbg !424
  store i64 %225, i64* @LocalLC, !dbg !424
  %commit173 = icmp ugt i64 %225, 5000, !dbg !424
  br i1 %commit173, label %pushBlock175, label %postInstrumentation174, !dbg !424

pushBlock175:                                     ; preds = %if_clock_enabled172
  %226 = add i32 %223, 1, !dbg !424
  store i32 %226, i32* @lc_disabled_count, !dbg !424
  store i64 9, i64* @LocalLC, !dbg !424
  %ci_handler176 = load void (i64)*, void (i64)** @intvActionHook, !dbg !424
  call void %ci_handler176(i64 %225), !dbg !424
  %227 = load i32, i32* @lc_disabled_count, !dbg !424
  %228 = sub i32 %227, 1, !dbg !424
  store i32 %228, i32* @lc_disabled_count, !dbg !424
  br label %postInstrumentation174, !dbg !424

postInstrumentation174:                           ; preds = %if_clock_enabled172, %pushBlock175
  br label %postClockEnabledBlock177, !dbg !424

postClockEnabledBlock177:                         ; preds = %if.else184, %postInstrumentation174
  br i1 %exitcond490, label %while.cond.loopexit.loopexit, label %for.body, !dbg !424, !llvm.loop !469

end_wait_loop:                                    ; preds = %postClockEnabledBlock170, %postClockEnabledBlock107
  %sockfd.0 = phi i32 [ %call164, %postClockEnabledBlock170 ], [ %call115, %postClockEnabledBlock107 ], !dbg !219
  call void @llvm.dbg.value(metadata i32 %sockfd.0, metadata !167, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.label(metadata !217), !dbg !471
  %229 = load i32, i32* @lc_disabled_count, !dbg !472
  %clock_running178 = icmp eq i32 %229, 0, !dbg !472
  br i1 %clock_running178, label %if_clock_enabled179, label %postClockEnabledBlock184, !dbg !472

if_clock_enabled179:                              ; preds = %end_wait_loop
  %230 = load i64, i64* @LocalLC, !dbg !472
  %231 = add i64 3, %230, !dbg !472
  store i64 %231, i64* @LocalLC, !dbg !472
  %commit180 = icmp ugt i64 %231, 5000, !dbg !472
  br i1 %commit180, label %pushBlock182, label %postInstrumentation181, !dbg !472

pushBlock182:                                     ; preds = %if_clock_enabled179
  %232 = add i32 %229, 1, !dbg !472
  store i32 %232, i32* @lc_disabled_count, !dbg !472
  store i64 9, i64* @LocalLC, !dbg !472
  %ci_handler183 = load void (i64)*, void (i64)** @intvActionHook, !dbg !472
  call void %ci_handler183(i64 %231), !dbg !472
  %233 = load i32, i32* @lc_disabled_count, !dbg !472
  %234 = sub i32 %233, 1, !dbg !472
  store i32 %234, i32* @lc_disabled_count, !dbg !472
  br label %postInstrumentation181, !dbg !472

postInstrumentation181:                           ; preds = %if_clock_enabled179, %pushBlock182
  br label %postClockEnabledBlock184, !dbg !472

postClockEnabledBlock184:                         ; preds = %end_wait_loop, %postInstrumentation181
  br i1 %cmp93, label %if.then190, label %if.end205, !dbg !472

if.then190:                                       ; preds = %postClockEnabledBlock184
  %235 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !473, !tbaa !86
  %236 = call i64 @fwrite(i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.30, i64 0, i64 0), i64 29, i64 1, %struct._IO_FILE* %235) #17, !dbg !473
  %237 = bitcast %struct.sockaddr_in* %daddr to %struct.sockaddr*, !dbg !476
  %call192 = call i32 @mtcp_connect(%struct.mtcp_context* nonnull %call84, i32 %sockfd.0, %struct.sockaddr* nonnull %237, i32 16) #16, !dbg !477
  call void @llvm.dbg.value(metadata i32 %call192, metadata !130, metadata !DIExpression()), !dbg !219
  %cmp193 = icmp slt i32 %call192, 0, !dbg !478
  %238 = load i32, i32* @lc_disabled_count, !dbg !480
  %clock_running185 = icmp eq i32 %238, 0, !dbg !480
  br i1 %clock_running185, label %if_clock_enabled186, label %postClockEnabledBlock191, !dbg !480

if_clock_enabled186:                              ; preds = %if.then190
  %239 = load i64, i64* @LocalLC, !dbg !480
  %240 = add i64 7, %239, !dbg !480
  store i64 %240, i64* @LocalLC, !dbg !480
  %commit187 = icmp ugt i64 %240, 5000, !dbg !480
  br i1 %commit187, label %pushBlock189, label %postInstrumentation188, !dbg !480

pushBlock189:                                     ; preds = %if_clock_enabled186
  %241 = add i32 %238, 1, !dbg !480
  store i32 %241, i32* @lc_disabled_count, !dbg !480
  store i64 9, i64* @LocalLC, !dbg !480
  %ci_handler190 = load void (i64)*, void (i64)** @intvActionHook, !dbg !480
  call void %ci_handler190(i64 %240), !dbg !480
  %242 = load i32, i32* @lc_disabled_count, !dbg !480
  %243 = sub i32 %242, 1, !dbg !480
  store i32 %243, i32* @lc_disabled_count, !dbg !480
  br label %postInstrumentation188, !dbg !480

postInstrumentation188:                           ; preds = %if_clock_enabled186, %pushBlock189
  br label %postClockEnabledBlock191, !dbg !480

postClockEnabledBlock191:                         ; preds = %if.then190, %postInstrumentation188
  br i1 %cmp193, label %if.then195, label %if.end203, !dbg !480

if.then195:                                       ; preds = %postClockEnabledBlock191
  %244 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !481, !tbaa !86
  %245 = call i64 @fwrite(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.31, i64 0, i64 0), i64 21, i64 1, %struct._IO_FILE* %244) #17, !dbg !481
  %call197 = tail call i32* @__errno_location() #11, !dbg !483
  %246 = load i32, i32* %call197, align 4, !dbg !483, !tbaa !417
  %cmp198 = icmp eq i32 %246, 115, !dbg !485
  %247 = load i32, i32* @lc_disabled_count, !dbg !486
  %clock_running192 = icmp eq i32 %247, 0, !dbg !486
  br i1 %clock_running192, label %if_clock_enabled193, label %postClockEnabledBlock198, !dbg !486

if_clock_enabled193:                              ; preds = %if.then195
  %248 = load i64, i64* @LocalLC, !dbg !486
  %249 = add i64 6, %248, !dbg !486
  store i64 %249, i64* @LocalLC, !dbg !486
  %commit194 = icmp ugt i64 %249, 5000, !dbg !486
  br i1 %commit194, label %pushBlock196, label %postInstrumentation195, !dbg !486

pushBlock196:                                     ; preds = %if_clock_enabled193
  %250 = add i32 %247, 1, !dbg !486
  store i32 %250, i32* @lc_disabled_count, !dbg !486
  store i64 9, i64* @LocalLC, !dbg !486
  %ci_handler197 = load void (i64)*, void (i64)** @intvActionHook, !dbg !486
  call void %ci_handler197(i64 %249), !dbg !486
  %251 = load i32, i32* @lc_disabled_count, !dbg !486
  %252 = sub i32 %251, 1, !dbg !486
  store i32 %252, i32* @lc_disabled_count, !dbg !486
  br label %postInstrumentation195, !dbg !486

postInstrumentation195:                           ; preds = %if_clock_enabled193, %pushBlock196
  br label %postClockEnabledBlock198, !dbg !486

postClockEnabledBlock198:                         ; preds = %if.then195, %postInstrumentation195
  br i1 %cmp198, label %if.end203, label %if.then200, !dbg !486

if.then200:                                       ; preds = %postClockEnabledBlock198
  call void @perror(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.32, i64 0, i64 0)) #17, !dbg !487
  %call201 = call i32 @mtcp_close(%struct.mtcp_context* nonnull %call84, i32 %sockfd.0) #16, !dbg !489
  %253 = load i32, i32* @lc_disabled_count, !dbg !490
  %clock_running199 = icmp eq i32 %253, 0, !dbg !490
  br i1 %clock_running199, label %if_clock_enabled200, label %postClockEnabledBlock205, !dbg !490

if_clock_enabled200:                              ; preds = %if.then200
  %254 = load i64, i64* @LocalLC, !dbg !490
  %255 = add i64 3, %254, !dbg !490
  store i64 %255, i64* @LocalLC, !dbg !490
  %commit201 = icmp ugt i64 %255, 5000, !dbg !490
  br i1 %commit201, label %pushBlock203, label %postInstrumentation202, !dbg !490

pushBlock203:                                     ; preds = %if_clock_enabled200
  %256 = add i32 %253, 1, !dbg !490
  store i32 %256, i32* @lc_disabled_count, !dbg !490
  store i64 9, i64* @LocalLC, !dbg !490
  %ci_handler204 = load void (i64)*, void (i64)** @intvActionHook, !dbg !490
  call void %ci_handler204(i64 %255), !dbg !490
  %257 = load i32, i32* @lc_disabled_count, !dbg !490
  %258 = sub i32 %257, 1, !dbg !490
  store i32 %258, i32* @lc_disabled_count, !dbg !490
  br label %postInstrumentation202, !dbg !490

postInstrumentation202:                           ; preds = %if_clock_enabled200, %pushBlock203
  br label %postClockEnabledBlock205, !dbg !490

postClockEnabledBlock205:                         ; preds = %if.then200, %postInstrumentation202
  br label %cleanup308, !dbg !490

if.end203:                                        ; preds = %postClockEnabledBlock198, %postClockEnabledBlock191
  %259 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !491, !tbaa !86
  %260 = call i64 @fwrite(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.33, i64 0, i64 0), i64 28, i64 1, %struct._IO_FILE* %259) #17, !dbg !491
  %261 = load i32, i32* @lc_disabled_count, !dbg !492
  %clock_running206 = icmp eq i32 %261, 0, !dbg !492
  br i1 %clock_running206, label %if_clock_enabled207, label %postClockEnabledBlock212, !dbg !492

if_clock_enabled207:                              ; preds = %if.end203
  %262 = load i64, i64* @LocalLC, !dbg !492
  %263 = add i64 3, %262, !dbg !492
  store i64 %263, i64* @LocalLC, !dbg !492
  %commit208 = icmp ugt i64 %263, 5000, !dbg !492
  br i1 %commit208, label %pushBlock210, label %postInstrumentation209, !dbg !492

pushBlock210:                                     ; preds = %if_clock_enabled207
  %264 = add i32 %261, 1, !dbg !492
  store i32 %264, i32* @lc_disabled_count, !dbg !492
  store i64 9, i64* @LocalLC, !dbg !492
  %ci_handler211 = load void (i64)*, void (i64)** @intvActionHook, !dbg !492
  call void %ci_handler211(i64 %263), !dbg !492
  %265 = load i32, i32* @lc_disabled_count, !dbg !492
  %266 = sub i32 %265, 1, !dbg !492
  store i32 %266, i32* @lc_disabled_count, !dbg !492
  br label %postInstrumentation209, !dbg !492

postInstrumentation209:                           ; preds = %if_clock_enabled207, %pushBlock210
  br label %postClockEnabledBlock212, !dbg !492

postClockEnabledBlock212:                         ; preds = %if.end203, %postInstrumentation209
  br label %if.end205, !dbg !492

if.end205:                                        ; preds = %postClockEnabledBlock212, %postClockEnabledBlock184
  call void @llvm.dbg.value(metadata %struct.timeval* %ts_start, metadata !187, metadata !DIExpression(DW_OP_deref)), !dbg !219
  %call206 = call i32 @clock_gettime(i32 1, %struct.timeval* nonnull %ts_start) #16, !dbg !493
  %tv_sec = getelementptr inbounds %struct.timeval, %struct.timeval* %ts_start, i64 0, i32 0, !dbg !494
  %267 = load i64, i64* %tv_sec, align 8, !dbg !494, !tbaa !495
  %sext = shl i64 %call.i459, 32, !dbg !498
  call void @llvm.dbg.value(metadata i64 %add, metadata !195, metadata !DIExpression()), !dbg !219
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 %8, i8 -112, i64 8192, i1 false), !dbg !499
  %arrayidx208 = getelementptr inbounds [8192 x i8], [8192 x i8]* %buf, i64 0, i64 8191, !dbg !500
  store i8 0, i8* %arrayidx208, align 1, !dbg !501, !tbaa !397
  br label %while.cond209, !dbg !502

while.cond209:                                    ; preds = %postClockEnabledBlock219, %if.end205
  %bytes_sent.0 = phi i32 [ 0, %if.end205 ], [ %add215, %postClockEnabledBlock219 ], !dbg !219
  call void @llvm.dbg.value(metadata i32 %bytes_sent.0, metadata !172, metadata !DIExpression()), !dbg !219
  %call213 = call i64 @mtcp_write(%struct.mtcp_context* %call84, i32 %sockfd.0, i8* nonnull %8, i64 8192) #16, !dbg !503
  %conv214 = trunc i64 %call213 to i32, !dbg !503
  call void @llvm.dbg.value(metadata i32 %conv214, metadata !170, metadata !DIExpression()), !dbg !219
  %add215 = add nsw i32 %bytes_sent.0, %conv214, !dbg !505
  call void @llvm.dbg.value(metadata i32 %add215, metadata !172, metadata !DIExpression()), !dbg !219
  %cmp216 = icmp sgt i32 %conv214, 0, !dbg !506
  %268 = load i32, i32* @lc_disabled_count, !dbg !508
  %clock_running213 = icmp eq i32 %268, 0, !dbg !508
  br i1 %clock_running213, label %if_clock_enabled214, label %postClockEnabledBlock219, !dbg !508

if_clock_enabled214:                              ; preds = %while.cond209
  %269 = load i64, i64* @LocalLC, !dbg !508
  %270 = add i64 8, %269, !dbg !508
  store i64 %270, i64* @LocalLC, !dbg !508
  %commit215 = icmp ugt i64 %270, 5000, !dbg !508
  br i1 %commit215, label %pushBlock217, label %postInstrumentation216, !dbg !508

pushBlock217:                                     ; preds = %if_clock_enabled214
  %271 = add i32 %268, 1, !dbg !508
  store i32 %271, i32* @lc_disabled_count, !dbg !508
  store i64 9, i64* @LocalLC, !dbg !508
  %ci_handler218 = load void (i64)*, void (i64)** @intvActionHook, !dbg !508
  call void %ci_handler218(i64 %270), !dbg !508
  %272 = load i32, i32* @lc_disabled_count, !dbg !508
  %273 = sub i32 %272, 1, !dbg !508
  store i32 %273, i32* @lc_disabled_count, !dbg !508
  br label %postInstrumentation216, !dbg !508

postInstrumentation216:                           ; preds = %if_clock_enabled214, %pushBlock217
  br label %postClockEnabledBlock219, !dbg !508

postClockEnabledBlock219:                         ; preds = %while.cond209, %postInstrumentation216
  br i1 %cmp216, label %if.then218, label %while.cond209, !dbg !508, !llvm.loop !509

if.then218:                                       ; preds = %postClockEnabledBlock219
  %add215.lcssa = phi i32 [ %add215, %postClockEnabledBlock219 ], !dbg !505
  %conv207 = ashr exact i64 %sext, 32, !dbg !498
  %add = add nsw i64 %267, %conv207, !dbg !511
  call void @llvm.dbg.value(metadata %struct.timeval* %t1, metadata !178, metadata !DIExpression(DW_OP_deref)), !dbg !219
  %call219 = call i32 @gettimeofday(%struct.timeval* nonnull %t1, %struct.timezone* null) #16, !dbg !512
  %tv_sec264 = getelementptr inbounds %struct.timeval, %struct.timeval* %now, i64 0, i32 0, !dbg !514
  %274 = load i32, i32* @lc_disabled_count, !dbg !521
  %clock_running220 = icmp eq i32 %274, 0, !dbg !521
  br i1 %clock_running220, label %if_clock_enabled221, label %postClockEnabledBlock226, !dbg !521

if_clock_enabled221:                              ; preds = %if.then218
  %275 = load i64, i64* @LocalLC, !dbg !521
  %276 = add i64 16, %275, !dbg !521
  store i64 %276, i64* @LocalLC, !dbg !521
  %commit222 = icmp ugt i64 %276, 5000, !dbg !521
  br i1 %commit222, label %pushBlock224, label %postInstrumentation223, !dbg !521

pushBlock224:                                     ; preds = %if_clock_enabled221
  %277 = add i32 %274, 1, !dbg !521
  store i32 %277, i32* @lc_disabled_count, !dbg !521
  store i64 9, i64* @LocalLC, !dbg !521
  %ci_handler225 = load void (i64)*, void (i64)** @intvActionHook, !dbg !521
  call void %ci_handler225(i64 %276), !dbg !521
  %278 = load i32, i32* @lc_disabled_count, !dbg !521
  %279 = sub i32 %278, 1, !dbg !521
  store i32 %279, i32* @lc_disabled_count, !dbg !521
  br label %postInstrumentation223, !dbg !521

postInstrumentation223:                           ; preds = %if_clock_enabled221, %pushBlock224
  br label %postClockEnabledBlock226, !dbg !521

postClockEnabledBlock226:                         ; preds = %if.then218, %postInstrumentation223
  br label %while.cond221.outer, !dbg !521

while.cond221.outer.loopexit:                     ; preds = %postClockEnabledBlock282
  %bytes_sent.3.lcssa = phi i32 [ %bytes_sent.3, %postClockEnabledBlock282 ], !dbg !219
  %sent_close.2.lcssa = phi i32 [ %sent_close.2, %postClockEnabledBlock282 ], !dbg !219
  call void @llvm.dbg.value(metadata i32 %bytes_sent.3.lcssa, metadata !172, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 %sent_close.2.lcssa, metadata !175, metadata !DIExpression()), !dbg !219
  %280 = load i32, i32* @lc_disabled_count, !dbg !522
  %clock_running227 = icmp eq i32 %280, 0, !dbg !522
  br i1 %clock_running227, label %if_clock_enabled228, label %postClockEnabledBlock233, !dbg !522

if_clock_enabled228:                              ; preds = %while.cond221.outer.loopexit
  %281 = load i64, i64* @LocalLC, !dbg !522
  %282 = add i64 3, %281, !dbg !522
  store i64 %282, i64* @LocalLC, !dbg !522
  %commit229 = icmp ugt i64 %282, 5000, !dbg !522
  br i1 %commit229, label %pushBlock231, label %postInstrumentation230, !dbg !522

pushBlock231:                                     ; preds = %if_clock_enabled228
  %283 = add i32 %280, 1, !dbg !522
  store i32 %283, i32* @lc_disabled_count, !dbg !522
  store i64 9, i64* @LocalLC, !dbg !522
  %ci_handler232 = load void (i64)*, void (i64)** @intvActionHook, !dbg !522
  call void %ci_handler232(i64 %282), !dbg !522
  %284 = load i32, i32* @lc_disabled_count, !dbg !522
  %285 = sub i32 %284, 1, !dbg !522
  store i32 %285, i32* @lc_disabled_count, !dbg !522
  br label %postInstrumentation230, !dbg !522

postInstrumentation230:                           ; preds = %if_clock_enabled228, %pushBlock231
  br label %postClockEnabledBlock233, !dbg !522

postClockEnabledBlock233:                         ; preds = %while.cond221.outer.loopexit, %postInstrumentation230
  br label %while.cond221.outer, !dbg !522

while.cond221.outer:                              ; preds = %postClockEnabledBlock233, %postClockEnabledBlock226
  %bytes_sent.1.ph = phi i32 [ %add215.lcssa, %postClockEnabledBlock226 ], [ %bytes_sent.3.lcssa, %postClockEnabledBlock233 ]
  %sent_close.0.ph = phi i32 [ 0, %postClockEnabledBlock226 ], [ %sent_close.2.lcssa, %postClockEnabledBlock233 ]
  br label %while.cond221, !dbg !522

while.cond221:                                    ; preds = %postClockEnabledBlock240, %while.cond221.outer
  call void @llvm.dbg.value(metadata i32 %sent_close.0.ph, metadata !175, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 %bytes_sent.1.ph, metadata !172, metadata !DIExpression()), !dbg !219
  %286 = load i32, i32* %max_num_buffers, align 4, !dbg !523, !tbaa !339
  %call225 = call i32 @mtcp_epoll_wait(%struct.mtcp_context* %call84, i32 %call106, %struct.mtcp_epoll_event* nonnull %117, i32 %286, i32 -1) #16, !dbg !524
  call void @llvm.dbg.value(metadata i32 %call225, metadata !173, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 0, metadata !214, metadata !DIExpression()), !dbg !525
  call void @llvm.dbg.value(metadata i32 %sent_close.0.ph, metadata !175, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 %bytes_sent.1.ph, metadata !172, metadata !DIExpression()), !dbg !219
  %cmp228475 = icmp sgt i32 %call225, 0, !dbg !526
  %287 = load i32, i32* @lc_disabled_count, !dbg !522
  %clock_running234 = icmp eq i32 %287, 0, !dbg !522
  br i1 %clock_running234, label %if_clock_enabled235, label %postClockEnabledBlock240, !dbg !522

if_clock_enabled235:                              ; preds = %while.cond221
  %288 = load i64, i64* @LocalLC, !dbg !522
  %289 = add i64 10, %288, !dbg !522
  store i64 %289, i64* @LocalLC, !dbg !522
  %commit236 = icmp ugt i64 %289, 5000, !dbg !522
  br i1 %commit236, label %pushBlock238, label %postInstrumentation237, !dbg !522

pushBlock238:                                     ; preds = %if_clock_enabled235
  %290 = add i32 %287, 1, !dbg !522
  store i32 %290, i32* @lc_disabled_count, !dbg !522
  store i64 9, i64* @LocalLC, !dbg !522
  %ci_handler239 = load void (i64)*, void (i64)** @intvActionHook, !dbg !522
  call void %ci_handler239(i64 %289), !dbg !522
  %291 = load i32, i32* @lc_disabled_count, !dbg !522
  %292 = sub i32 %291, 1, !dbg !522
  store i32 %292, i32* @lc_disabled_count, !dbg !522
  br label %postInstrumentation237, !dbg !522

postInstrumentation237:                           ; preds = %if_clock_enabled235, %pushBlock238
  br label %postClockEnabledBlock240, !dbg !522

postClockEnabledBlock240:                         ; preds = %while.cond221, %postInstrumentation237
  br i1 %cmp228475, label %for.body230.preheader, label %while.cond221, !dbg !522

for.body230.preheader:                            ; preds = %postClockEnabledBlock240
  %call225.lcssa = phi i32 [ %call225, %postClockEnabledBlock240 ], !dbg !524
  %wide.trip.count = zext i32 %call225.lcssa to i64, !dbg !526
  %293 = load i32, i32* @lc_disabled_count, !dbg !522
  %clock_running241 = icmp eq i32 %293, 0, !dbg !522
  br i1 %clock_running241, label %if_clock_enabled242, label %postClockEnabledBlock247, !dbg !522

if_clock_enabled242:                              ; preds = %for.body230.preheader
  %294 = load i64, i64* @LocalLC, !dbg !522
  %295 = add i64 3, %294, !dbg !522
  store i64 %295, i64* @LocalLC, !dbg !522
  %commit243 = icmp ugt i64 %295, 5000, !dbg !522
  br i1 %commit243, label %pushBlock245, label %postInstrumentation244, !dbg !522

pushBlock245:                                     ; preds = %if_clock_enabled242
  %296 = add i32 %293, 1, !dbg !522
  store i32 %296, i32* @lc_disabled_count, !dbg !522
  store i64 9, i64* @LocalLC, !dbg !522
  %ci_handler246 = load void (i64)*, void (i64)** @intvActionHook, !dbg !522
  call void %ci_handler246(i64 %295), !dbg !522
  %297 = load i32, i32* @lc_disabled_count, !dbg !522
  %298 = sub i32 %297, 1, !dbg !522
  store i32 %298, i32* @lc_disabled_count, !dbg !522
  br label %postInstrumentation244, !dbg !522

postInstrumentation244:                           ; preds = %if_clock_enabled242, %pushBlock245
  br label %postClockEnabledBlock247, !dbg !522

postClockEnabledBlock247:                         ; preds = %for.body230.preheader, %postInstrumentation244
  br label %for.body230, !dbg !522

for.body230:                                      ; preds = %postClockEnabledBlock282, %postClockEnabledBlock247
  %indvars.iv = phi i64 [ 0, %postClockEnabledBlock247 ], [ %indvars.iv.next, %postClockEnabledBlock282 ]
  %sent_close.1477 = phi i32 [ %sent_close.0.ph, %postClockEnabledBlock247 ], [ %sent_close.2, %postClockEnabledBlock282 ]
  %bytes_sent.2476 = phi i32 [ %bytes_sent.1.ph, %postClockEnabledBlock247 ], [ %bytes_sent.3, %postClockEnabledBlock282 ]
  call void @llvm.dbg.value(metadata i64 %indvars.iv, metadata !214, metadata !DIExpression()), !dbg !525
  call void @llvm.dbg.value(metadata i32 %sent_close.1477, metadata !175, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476, metadata !172, metadata !DIExpression()), !dbg !219
  %data233 = getelementptr inbounds %struct.mtcp_epoll_event, %struct.mtcp_epoll_event* %117, i64 %indvars.iv, i32 1, !dbg !527
  %sockid234 = bitcast %union.mtcp_epoll_data* %data233 to i32*, !dbg !527
  %299 = load i32, i32* %sockid234, align 8, !dbg !527, !tbaa !397
  %cmp235 = icmp eq i32 %sockfd.0, %299, !dbg !527
  br i1 %cmp235, label %if.end239, label %if.else238, !dbg !530

if.else238:                                       ; preds = %for.body230
  call void @__assert_fail(i8* getelementptr inbounds ([32 x i8], [32 x i8]* @.str.34, i64 0, i64 0), i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.35, i64 0, i64 0), i32 334, i8* getelementptr inbounds ([23 x i8], [23 x i8]* @__PRETTY_FUNCTION__.main, i64 0, i64 0)) #18, !dbg !527
  %300 = load i32, i32* @lc_disabled_count, !dbg !527
  %clock_running248 = icmp eq i32 %300, 0, !dbg !527
  br i1 %clock_running248, label %if_clock_enabled249, label %postClockEnabledBlock254, !dbg !527

if_clock_enabled249:                              ; preds = %if.else238
  %301 = load i64, i64* @LocalLC, !dbg !527
  %302 = add i64 2, %301, !dbg !527
  store i64 %302, i64* @LocalLC, !dbg !527
  %commit250 = icmp ugt i64 %302, 5000, !dbg !527
  br i1 %commit250, label %pushBlock252, label %postInstrumentation251, !dbg !527

pushBlock252:                                     ; preds = %if_clock_enabled249
  %303 = add i32 %300, 1, !dbg !527
  store i32 %303, i32* @lc_disabled_count, !dbg !527
  store i64 9, i64* @LocalLC, !dbg !527
  %ci_handler253 = load void (i64)*, void (i64)** @intvActionHook, !dbg !527
  call void %ci_handler253(i64 %302), !dbg !527
  %304 = load i32, i32* @lc_disabled_count, !dbg !527
  %305 = sub i32 %304, 1, !dbg !527
  store i32 %305, i32* @lc_disabled_count, !dbg !527
  br label %postInstrumentation251, !dbg !527

postInstrumentation251:                           ; preds = %if_clock_enabled249, %pushBlock252
  br label %postClockEnabledBlock254, !dbg !527

postClockEnabledBlock254:                         ; preds = %if.else238, %postInstrumentation251
  unreachable, !dbg !527

if.end239:                                        ; preds = %for.body230
  %events242 = getelementptr inbounds %struct.mtcp_epoll_event, %struct.mtcp_epoll_event* %117, i64 %indvars.iv, i32 0, !dbg !531
  %306 = load i32, i32* %events242, align 8, !dbg !531, !tbaa !392
  %and243 = and i32 %306, 1, !dbg !532
  %tobool244 = icmp eq i32 %and243, 0, !dbg !532
  %307 = load i32, i32* @lc_disabled_count, !dbg !533
  %clock_running255 = icmp eq i32 %307, 0, !dbg !533
  br i1 %clock_running255, label %if_clock_enabled256, label %postClockEnabledBlock261, !dbg !533

if_clock_enabled256:                              ; preds = %if.end239
  %308 = load i64, i64* @LocalLC, !dbg !533
  %309 = add i64 13, %308, !dbg !533
  store i64 %309, i64* @LocalLC, !dbg !533
  %commit257 = icmp ugt i64 %309, 5000, !dbg !533
  br i1 %commit257, label %pushBlock259, label %postInstrumentation258, !dbg !533

pushBlock259:                                     ; preds = %if_clock_enabled256
  %310 = add i32 %307, 1, !dbg !533
  store i32 %310, i32* @lc_disabled_count, !dbg !533
  store i64 9, i64* @LocalLC, !dbg !533
  %ci_handler260 = load void (i64)*, void (i64)** @intvActionHook, !dbg !533
  call void %ci_handler260(i64 %309), !dbg !533
  %311 = load i32, i32* @lc_disabled_count, !dbg !533
  %312 = sub i32 %311, 1, !dbg !533
  store i32 %312, i32* @lc_disabled_count, !dbg !533
  br label %postInstrumentation258, !dbg !533

postInstrumentation258:                           ; preds = %if_clock_enabled256, %pushBlock259
  br label %postClockEnabledBlock261, !dbg !533

postClockEnabledBlock261:                         ; preds = %if.end239, %postInstrumentation258
  br i1 %tobool244, label %if.else256, label %if.then245, !dbg !533

if.then245:                                       ; preds = %postClockEnabledBlock261
  %call248 = call i64 @mtcp_read(%struct.mtcp_context* %call84, i32 %sockfd.0, i8* nonnull %9, i64 8192) #16, !dbg !534
  %conv249 = trunc i64 %call248 to i32, !dbg !534
  call void @llvm.dbg.value(metadata i32 %conv249, metadata !171, metadata !DIExpression()), !dbg !219
  %cmp250 = icmp slt i32 %conv249, 1, !dbg !536
  %313 = load i32, i32* @lc_disabled_count, !dbg !538
  %clock_running262 = icmp eq i32 %313, 0, !dbg !538
  br i1 %clock_running262, label %if_clock_enabled263, label %postClockEnabledBlock268, !dbg !538

if_clock_enabled263:                              ; preds = %if.then245
  %314 = load i64, i64* @LocalLC, !dbg !538
  %315 = add i64 5, %314, !dbg !538
  store i64 %315, i64* @LocalLC, !dbg !538
  %commit264 = icmp ugt i64 %315, 5000, !dbg !538
  br i1 %commit264, label %pushBlock266, label %postInstrumentation265, !dbg !538

pushBlock266:                                     ; preds = %if_clock_enabled263
  %316 = add i32 %313, 1, !dbg !538
  store i32 %316, i32* @lc_disabled_count, !dbg !538
  store i64 9, i64* @LocalLC, !dbg !538
  %ci_handler267 = load void (i64)*, void (i64)** @intvActionHook, !dbg !538
  call void %ci_handler267(i64 %315), !dbg !538
  %317 = load i32, i32* @lc_disabled_count, !dbg !538
  %318 = sub i32 %317, 1, !dbg !538
  store i32 %318, i32* @lc_disabled_count, !dbg !538
  br label %postInstrumentation265, !dbg !538

postInstrumentation265:                           ; preds = %if_clock_enabled263, %pushBlock266
  br label %postClockEnabledBlock268, !dbg !538

postClockEnabledBlock268:                         ; preds = %if.then245, %postInstrumentation265
  br i1 %cmp250, label %for.inc285, label %stop_timer, !dbg !538

if.else256:                                       ; preds = %postClockEnabledBlock261
  %cmp260 = icmp eq i32 %306, 4, !dbg !539
  br i1 %cmp260, label %if.then262, label %for.inc285_dummy, !dbg !540

if.then262:                                       ; preds = %if.else256
  call void @llvm.dbg.value(metadata %struct.timeval* %now, metadata !194, metadata !DIExpression(DW_OP_deref)), !dbg !219
  %call263 = call i32 @clock_gettime(i32 1, %struct.timeval* nonnull %now) #16, !dbg !541
  %319 = load i64, i64* %tv_sec264, align 8, !dbg !542, !tbaa !495
  %cmp265 = icmp slt i64 %319, %add, !dbg !543
  br i1 %cmp265, label %if.then267, label %if.else273, !dbg !544

if.then267:                                       ; preds = %if.then262
  %call270 = call i64 @mtcp_write(%struct.mtcp_context* %call84, i32 %sockfd.0, i8* nonnull %8, i64 8192) #16, !dbg !545
  %conv271 = trunc i64 %call270 to i32, !dbg !545
  call void @llvm.dbg.value(metadata i32 %conv271, metadata !170, metadata !DIExpression()), !dbg !219
  %add272 = add nsw i32 %bytes_sent.2476, %conv271, !dbg !547
  call void @llvm.dbg.value(metadata i32 %add272, metadata !172, metadata !DIExpression()), !dbg !219
  br label %for.inc285_dummy_dummy, !dbg !548

if.else273:                                       ; preds = %if.then262
  %tobool274 = icmp eq i32 %sent_close.1477, 0, !dbg !549
  br i1 %tobool274, label %if.then275, label %for.inc285_dummy_dummy_dummy, !dbg !551

if.then275:                                       ; preds = %if.else273
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 %8, i8 -106, i64 8192, i1 false), !dbg !552
  %call279 = call i64 @mtcp_write(%struct.mtcp_context* %call84, i32 %sockfd.0, i8* nonnull %8, i64 1) #16, !dbg !554
  %320 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !555, !tbaa !86
  %321 = call i64 @fwrite(i8* getelementptr inbounds ([45 x i8], [45 x i8]* @.str.37, i64 0, i64 0), i64 44, i64 1, %struct._IO_FILE* %320) #17, !dbg !555
  call void @llvm.dbg.value(metadata i32 1, metadata !175, metadata !DIExpression()), !dbg !219
  br label %for.inc285_dummy_dummy_dummy, !dbg !556

for.inc285_dummy_dummy_dummy:                     ; preds = %if.else273, %if.then275
  %sent_close.2.ph.ph.ph = phi i32 [ 1, %if.then275 ], [ %sent_close.1477, %if.else273 ]
  br label %for.inc285_dummy_dummy, !dbg !557

for.inc285_dummy_dummy:                           ; preds = %for.inc285_dummy_dummy_dummy, %if.then267
  %bytes_sent.3.ph.ph = phi i32 [ %add272, %if.then267 ], [ %bytes_sent.2476, %for.inc285_dummy_dummy_dummy ]
  %sent_close.2.ph.ph = phi i32 [ %sent_close.1477, %if.then267 ], [ %sent_close.2.ph.ph.ph, %for.inc285_dummy_dummy_dummy ]
  br label %for.inc285_dummy, !dbg !557

for.inc285_dummy:                                 ; preds = %for.inc285_dummy_dummy, %if.else256
  %bytes_sent.3.ph = phi i32 [ %bytes_sent.2476, %if.else256 ], [ %bytes_sent.3.ph.ph, %for.inc285_dummy_dummy ]
  %sent_close.2.ph = phi i32 [ %sent_close.1477, %if.else256 ], [ %sent_close.2.ph.ph, %for.inc285_dummy_dummy ]
  %322 = load i32, i32* @lc_disabled_count, !dbg !557
  %clock_running269 = icmp eq i32 %322, 0, !dbg !557
  br i1 %clock_running269, label %if_clock_enabled270, label %postClockEnabledBlock275, !dbg !557

if_clock_enabled270:                              ; preds = %for.inc285_dummy
  %323 = load i64, i64* @LocalLC, !dbg !557
  %324 = add i64 8, %323, !dbg !557
  store i64 %324, i64* @LocalLC, !dbg !557
  %commit271 = icmp ugt i64 %324, 5000, !dbg !557
  br i1 %commit271, label %pushBlock273, label %postInstrumentation272, !dbg !557

pushBlock273:                                     ; preds = %if_clock_enabled270
  %325 = add i32 %322, 1, !dbg !557
  store i32 %325, i32* @lc_disabled_count, !dbg !557
  store i64 9, i64* @LocalLC, !dbg !557
  %ci_handler274 = load void (i64)*, void (i64)** @intvActionHook, !dbg !557
  call void %ci_handler274(i64 %324), !dbg !557
  %326 = load i32, i32* @lc_disabled_count, !dbg !557
  %327 = sub i32 %326, 1, !dbg !557
  store i32 %327, i32* @lc_disabled_count, !dbg !557
  br label %postInstrumentation272, !dbg !557

postInstrumentation272:                           ; preds = %if_clock_enabled270, %pushBlock273
  br label %postClockEnabledBlock275, !dbg !557

postClockEnabledBlock275:                         ; preds = %for.inc285_dummy, %postInstrumentation272
  br label %for.inc285, !dbg !557

for.inc285:                                       ; preds = %postClockEnabledBlock275, %postClockEnabledBlock268
  %bytes_sent.3 = phi i32 [ %bytes_sent.2476, %postClockEnabledBlock268 ], [ %bytes_sent.3.ph, %postClockEnabledBlock275 ], !dbg !219
  %sent_close.2 = phi i32 [ %sent_close.1477, %postClockEnabledBlock268 ], [ %sent_close.2.ph, %postClockEnabledBlock275 ], !dbg !219
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1, !dbg !557
  call void @llvm.dbg.value(metadata i32 undef, metadata !214, metadata !DIExpression(DW_OP_plus_uconst, 1, DW_OP_stack_value)), !dbg !525
  call void @llvm.dbg.value(metadata i32 %sent_close.2, metadata !175, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 %bytes_sent.3, metadata !172, metadata !DIExpression()), !dbg !219
  %exitcond = icmp eq i64 %indvars.iv.next, %wide.trip.count, !dbg !526
  %328 = load i32, i32* @lc_disabled_count, !dbg !522
  %clock_running276 = icmp eq i32 %328, 0, !dbg !522
  br i1 %clock_running276, label %if_clock_enabled277, label %postClockEnabledBlock282, !dbg !522

if_clock_enabled277:                              ; preds = %for.inc285
  %329 = load i64, i64* @LocalLC, !dbg !522
  %330 = add i64 6, %329, !dbg !522
  store i64 %330, i64* @LocalLC, !dbg !522
  %commit278 = icmp ugt i64 %330, 5000, !dbg !522
  br i1 %commit278, label %pushBlock280, label %postInstrumentation279, !dbg !522

pushBlock280:                                     ; preds = %if_clock_enabled277
  %331 = add i32 %328, 1, !dbg !522
  store i32 %331, i32* @lc_disabled_count, !dbg !522
  store i64 9, i64* @LocalLC, !dbg !522
  %ci_handler281 = load void (i64)*, void (i64)** @intvActionHook, !dbg !522
  call void %ci_handler281(i64 %330), !dbg !522
  %332 = load i32, i32* @lc_disabled_count, !dbg !522
  %333 = sub i32 %332, 1, !dbg !522
  store i32 %333, i32* @lc_disabled_count, !dbg !522
  br label %postInstrumentation279, !dbg !522

postInstrumentation279:                           ; preds = %if_clock_enabled277, %pushBlock280
  br label %postClockEnabledBlock282, !dbg !522

postClockEnabledBlock282:                         ; preds = %for.inc285, %postInstrumentation279
  br i1 %exitcond, label %while.cond221.outer.loopexit, label %for.body230, !dbg !522, !llvm.loop !558

stop_timer:                                       ; preds = %postClockEnabledBlock268
  %bytes_sent.2476.lcssa1 = phi i32 [ %bytes_sent.2476, %postClockEnabledBlock268 ]
  %call248.lcssa = phi i64 [ %call248, %postClockEnabledBlock268 ], !dbg !534
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476.lcssa1, metadata !172, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476.lcssa1, metadata !172, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476.lcssa1, metadata !172, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476.lcssa1, metadata !172, metadata !DIExpression()), !dbg !219
  %conv249.le = trunc i64 %call248.lcssa to i32, !dbg !534
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476.lcssa1, metadata !172, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476.lcssa1, metadata !172, metadata !DIExpression()), !dbg !219
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476.lcssa1, metadata !172, metadata !DIExpression()), !dbg !219
  %334 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !560, !tbaa !86
  %call255 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %334, i8* getelementptr inbounds ([50 x i8], [50 x i8]* @.str.36, i64 0, i64 0), i32 %conv249.le, i8* nonnull %9) #17, !dbg !560
  call void @llvm.dbg.label(metadata !218), !dbg !562
  call void @llvm.dbg.value(metadata %struct.timeval* %t2, metadata !186, metadata !DIExpression(DW_OP_deref)), !dbg !219
  %call288 = call i32 @gettimeofday(%struct.timeval* nonnull %t2, %struct.timezone* null) #16, !dbg !563
  %335 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !564, !tbaa !86
  %336 = call i64 @fwrite(i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.38, i64 0, i64 0), i64 40, i64 1, %struct._IO_FILE* %335) #17, !dbg !564
  %call290 = call i32 @mtcp_close(%struct.mtcp_context* nonnull %call84, i32 %sockfd.0) #16, !dbg !565
  %337 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !566, !tbaa !86
  %338 = call i64 @fwrite(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.39, i64 0, i64 0), i64 23, i64 1, %struct._IO_FILE* %337) #17, !dbg !566
  %puts = call i32 @puts(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @str.44, i64 0, i64 0)), !dbg !567
  %tv_sec293 = getelementptr inbounds %struct.timeval, %struct.timeval* %t2, i64 0, i32 0, !dbg !568
  %339 = load i64, i64* %tv_sec293, align 8, !dbg !568, !tbaa !569
  %tv_sec294 = getelementptr inbounds %struct.timeval, %struct.timeval* %t1, i64 0, i32 0, !dbg !571
  %340 = load i64, i64* %tv_sec294, align 8, !dbg !571, !tbaa !569
  %sub = sub nsw i64 %339, %340, !dbg !572
  %conv295 = sitofp i64 %sub to double, !dbg !573
  call void @llvm.dbg.value(metadata double %conv295, metadata !176, metadata !DIExpression()), !dbg !219
  %tv_usec = getelementptr inbounds %struct.timeval, %struct.timeval* %t2, i64 0, i32 1, !dbg !574
  %341 = load i64, i64* %tv_usec, align 8, !dbg !574, !tbaa !575
  %tv_usec296 = getelementptr inbounds %struct.timeval, %struct.timeval* %t1, i64 0, i32 1, !dbg !576
  %342 = load i64, i64* %tv_usec296, align 8, !dbg !576, !tbaa !575
  %sub297 = sub nsw i64 %341, %342, !dbg !577
  %conv298 = sitofp i64 %sub297 to double, !dbg !578
  %div = fdiv double %conv298, 1.000000e+06, !dbg !579
  %add299 = fadd double %div, %conv295, !dbg !580
  call void @llvm.dbg.value(metadata double %add299, metadata !176, metadata !DIExpression()), !dbg !219
  %call300 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.41, i64 0, i64 0), double %add299), !dbg !581
  %call301 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.42, i64 0, i64 0), i32 %bytes_sent.2476.lcssa1), !dbg !582
  %conv302 = sitofp i32 %bytes_sent.2476.lcssa1 to double, !dbg !583
  %mul303 = fmul double %conv302, 8.000000e+00, !dbg !584
  %div304 = fdiv double %mul303, 1.000000e+06, !dbg !585
  %div305 = fdiv double %div304, %add299, !dbg !586
  %call306 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.43, i64 0, i64 0), double %div305), !dbg !587
  call void @mtcp_destroy_context(%struct.mtcp_context* %call84) #16, !dbg !588
  call void (...) @mtcp_destroy() #16, !dbg !589
  %343 = load i32, i32* @lc_disabled_count, !dbg !590
  %clock_running283 = icmp eq i32 %343, 0, !dbg !590
  br i1 %clock_running283, label %if_clock_enabled284, label %postClockEnabledBlock289, !dbg !590

if_clock_enabled284:                              ; preds = %stop_timer
  %344 = load i64, i64* @LocalLC, !dbg !590
  %345 = add i64 45, %344, !dbg !590
  store i64 %345, i64* @LocalLC, !dbg !590
  %commit285 = icmp ugt i64 %345, 5000, !dbg !590
  br i1 %commit285, label %pushBlock287, label %postInstrumentation286, !dbg !590

pushBlock287:                                     ; preds = %if_clock_enabled284
  %346 = add i32 %343, 1, !dbg !590
  store i32 %346, i32* @lc_disabled_count, !dbg !590
  store i64 9, i64* @LocalLC, !dbg !590
  %ci_handler288 = load void (i64)*, void (i64)** @intvActionHook, !dbg !590
  call void %ci_handler288(i64 %345), !dbg !590
  %347 = load i32, i32* @lc_disabled_count, !dbg !590
  %348 = sub i32 %347, 1, !dbg !590
  store i32 %348, i32* @lc_disabled_count, !dbg !590
  br label %postInstrumentation286, !dbg !590

postInstrumentation286:                           ; preds = %if_clock_enabled284, %pushBlock287
  br label %postClockEnabledBlock289, !dbg !590

postClockEnabledBlock289:                         ; preds = %stop_timer, %postInstrumentation286
  br label %cleanup308, !dbg !590

cleanup308_dummy:                                 ; preds = %if.then149, %if.then153
  %349 = load i32, i32* @lc_disabled_count, !dbg !591
  %clock_running290 = icmp eq i32 %349, 0, !dbg !591
  br i1 %clock_running290, label %if_clock_enabled291, label %postClockEnabledBlock296, !dbg !591

if_clock_enabled291:                              ; preds = %cleanup308_dummy
  %350 = load i64, i64* @LocalLC, !dbg !591
  %351 = add i64 5, %350, !dbg !591
  store i64 %351, i64* @LocalLC, !dbg !591
  %commit292 = icmp ugt i64 %351, 5000, !dbg !591
  br i1 %commit292, label %pushBlock294, label %postInstrumentation293, !dbg !591

pushBlock294:                                     ; preds = %if_clock_enabled291
  %352 = add i32 %349, 1, !dbg !591
  store i32 %352, i32* @lc_disabled_count, !dbg !591
  store i64 9, i64* @LocalLC, !dbg !591
  %ci_handler295 = load void (i64)*, void (i64)** @intvActionHook, !dbg !591
  call void %ci_handler295(i64 %351), !dbg !591
  %353 = load i32, i32* @lc_disabled_count, !dbg !591
  %354 = sub i32 %353, 1, !dbg !591
  store i32 %354, i32* @lc_disabled_count, !dbg !591
  br label %postInstrumentation293, !dbg !591

postInstrumentation293:                           ; preds = %if_clock_enabled291, %pushBlock294
  br label %postClockEnabledBlock296, !dbg !591

postClockEnabledBlock296:                         ; preds = %cleanup308_dummy, %postInstrumentation293
  br label %cleanup308, !dbg !591

cleanup308:                                       ; preds = %postClockEnabledBlock296, %postClockEnabledBlock289, %postClockEnabledBlock205, %postClockEnabledBlock100, %postClockEnabledBlock93, %postClockEnabledBlock86, %postClockEnabledBlock72, %postClockEnabledBlock58, %postClockEnabledBlock37, %postClockEnabledBlock30, %postClockEnabledBlock16, %postClockEnabledBlock
  %retval.0 = phi i32 [ -1, %postClockEnabledBlock ], [ -1, %postClockEnabledBlock16 ], [ -1, %postClockEnabledBlock58 ], [ -1, %postClockEnabledBlock93 ], [ -1, %postClockEnabledBlock100 ], [ -1, %postClockEnabledBlock205 ], [ 0, %postClockEnabledBlock289 ], [ -1, %postClockEnabledBlock86 ], [ -1, %postClockEnabledBlock72 ], [ -1, %postClockEnabledBlock30 ], [ -1, %postClockEnabledBlock37 ], [ -1, %postClockEnabledBlock296 ]
  call void @llvm.lifetime.end.p0i8(i64 8192, i8* nonnull %9) #16, !dbg !591
  call void @llvm.lifetime.end.p0i8(i64 8192, i8* nonnull %8) #16, !dbg !591
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %7) #16, !dbg !591
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %6) #16, !dbg !591
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %5) #16, !dbg !591
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %4) #16, !dbg !591
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %3) #16, !dbg !591
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %2) #16, !dbg !591
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %1) #16, !dbg !591
  call void @llvm.lifetime.end.p0i8(i64 28, i8* nonnull %0) #16, !dbg !591
  %355 = load i32, i32* @lc_disabled_count, !dbg !591
  %clock_running297 = icmp eq i32 %355, 0, !dbg !591
  br i1 %clock_running297, label %if_clock_enabled298, label %postClockEnabledBlock303, !dbg !591

if_clock_enabled298:                              ; preds = %cleanup308
  %356 = load i64, i64* @LocalLC, !dbg !591
  %357 = add i64 11, %356, !dbg !591
  store i64 %357, i64* @LocalLC, !dbg !591
  %commit299 = icmp ugt i64 %357, 5000, !dbg !591
  br i1 %commit299, label %pushBlock301, label %postInstrumentation300, !dbg !591

pushBlock301:                                     ; preds = %if_clock_enabled298
  %358 = add i32 %355, 1, !dbg !591
  store i32 %358, i32* @lc_disabled_count, !dbg !591
  store i64 9, i64* @LocalLC, !dbg !591
  %ci_handler302 = load void (i64)*, void (i64)** @intvActionHook, !dbg !591
  call void %ci_handler302(i64 %357), !dbg !591
  %359 = load i32, i32* @lc_disabled_count, !dbg !591
  %360 = sub i32 %359, 1, !dbg !591
  store i32 %360, i32* @lc_disabled_count, !dbg !591
  br label %postInstrumentation300, !dbg !591

postInstrumentation300:                           ; preds = %if_clock_enabled298, %pushBlock301
  br label %postClockEnabledBlock303, !dbg !591

postClockEnabledBlock303:                         ; preds = %cleanup308, %postInstrumentation300
  ret i32 %retval.0, !dbg !591
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #8

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #3

; Function Attrs: nofree nounwind readonly
declare dso_local i32 @strncmp(i8* nocapture, i8* nocapture, i64) local_unnamed_addr #9

; Function Attrs: nounwind
declare dso_local i32 @inet_addr(i8*) local_unnamed_addr #10

; Function Attrs: nofree nounwind
declare dso_local i64 @strtol(i8* readonly, i8** nocapture, i32) local_unnamed_addr #4

; Function Attrs: nounwind readnone
declare i1 @llvm.is.constant.i16(i16) #11

; Function Attrs: nounwind readnone speculatable
declare i16 @llvm.bswap.i16(i16) #3

; Function Attrs: nofree nounwind
declare dso_local i32 @fprintf(%struct._IO_FILE* nocapture, i8* nocapture readonly, ...) local_unnamed_addr #4

declare dso_local i32 @mtcp_getconf(%struct.mtcp_conf*) local_unnamed_addr #2

declare dso_local i32 @mtcp_setconf(%struct.mtcp_conf*) local_unnamed_addr #2

; Function Attrs: nounwind
declare dso_local i64 @time(i64*) local_unnamed_addr #10

; Function Attrs: nounwind
declare dso_local void @srand(i32) local_unnamed_addr #10

declare dso_local i32 @mtcp_init(i8*) local_unnamed_addr #2

declare dso_local void (i32)* @mtcp_register_signal(i32, void (i32)*) local_unnamed_addr #2

declare dso_local i32 @mtcp_core_affinitize(i32) local_unnamed_addr #2

declare dso_local %struct.mtcp_context* @mtcp_create_context(i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_init_rss(%struct.mtcp_context*, i32, i32, i32, i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_epoll_create(%struct.mtcp_context*, i32) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @calloc(i64, i64) local_unnamed_addr #4

declare dso_local i32 @mtcp_socket(%struct.mtcp_context*, i32, i32, i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_setsock_nonblock(%struct.mtcp_context*, i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_epoll_ctl(%struct.mtcp_context*, i32, i32, i32, %struct.mtcp_epoll_event*) local_unnamed_addr #2

declare dso_local i32 @mtcp_bind(%struct.mtcp_context*, i32, %struct.sockaddr*, i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_listen(%struct.mtcp_context*, i32, i32) local_unnamed_addr #2

; Function Attrs: nounwind readnone
declare dso_local i32* @__errno_location() local_unnamed_addr #12

; Function Attrs: nounwind
declare dso_local i8* @strerror(i32) local_unnamed_addr #10

declare dso_local i32 @mtcp_epoll_wait(%struct.mtcp_context*, i32, %struct.mtcp_epoll_event*, i32, i32) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare dso_local void @perror(i8* nocapture readonly) local_unnamed_addr #4

declare dso_local i32 @mtcp_accept(%struct.mtcp_context*, i32, %struct.sockaddr*, i32*) local_unnamed_addr #2

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.label(metadata) #3

declare dso_local i32 @mtcp_connect(%struct.mtcp_context*, i32, %struct.sockaddr*, i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_close(%struct.mtcp_context*, i32) local_unnamed_addr #2

; Function Attrs: nounwind
declare dso_local i32 @clock_gettime(i32, %struct.timeval*) local_unnamed_addr #10

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #8

declare dso_local i64 @mtcp_write(%struct.mtcp_context*, i32, i8*, i64) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare dso_local i32 @gettimeofday(%struct.timeval* nocapture, %struct.timezone* nocapture) local_unnamed_addr #4

; Function Attrs: noreturn nounwind
declare dso_local void @__assert_fail(i8*, i8*, i32, i8*) local_unnamed_addr #6

declare dso_local i64 @mtcp_read(%struct.mtcp_context*, i32, i8*, i64) local_unnamed_addr #2

declare dso_local void @mtcp_destroy_context(%struct.mtcp_context*) local_unnamed_addr #2

declare dso_local void @mtcp_destroy(...) local_unnamed_addr #2

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #8

; Function Attrs: nofree nounwind uwtable
define i32 @find_http_header(i8* %data, i32 %len) local_unnamed_addr #7 {
entry:
  %idxprom = sext i32 %len to i64
  %arrayidx = getelementptr inbounds i8, i8* %data, i64 %idxprom
  %0 = load i8, i8* %arrayidx, align 1, !tbaa !397
  store i8 0, i8* %arrayidx, align 1, !tbaa !397
  %cmp6 = icmp sgt i32 %len, 0
  %sub.ptr.rhs.cast17 = ptrtoint i8* %data to i64
  br i1 %cmp6, label %entry.split.us, label %land.rhs

entry.split.us:                                   ; preds = %entry
  %call.us53 = tail call i8* @strchr(i8* nonnull %data, i32 10) #20
  %cmp.us54 = icmp eq i8* %call.us53, null
  %1 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %1, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %entry.split.us
  %2 = load i64, i64* @LocalLC
  %3 = add i64 3, %2
  store i64 %3, i64* @LocalLC
  %commit = icmp ugt i64 %3, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %4 = add i32 %1, 1
  store i32 %4, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %3)
  %5 = load i32, i32* @lc_disabled_count
  %6 = sub i32 %5, 1
  store i32 %6, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %entry.split.us, %postInstrumentation
  br i1 %cmp.us54, label %while.end, label %while.body.us

land.rhs.us:                                      ; preds = %postClockEnabledBlock28, %postClockEnabledBlock21, %postClockEnabledBlock14
  %call.us = tail call i8* @strchr(i8* nonnull %incdec.ptr.us, i32 10) #20
  %cmp.us = icmp eq i8* %call.us, null
  %7 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %7, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %land.rhs.us
  %8 = load i64, i64* @LocalLC
  %9 = add i64 3, %8
  store i64 %9, i64* @LocalLC
  %commit3 = icmp ugt i64 %9, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %10 = add i32 %7, 1
  store i32 %10, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %9)
  %11 = load i32, i32* @lc_disabled_count
  %12 = sub i32 %11, 1
  store i32 %12, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %land.rhs.us, %postInstrumentation4
  br i1 %cmp.us, label %while.end, label %while.body.us

while.body.us:                                    ; preds = %postClockEnabledBlock7, %postClockEnabledBlock
  %call.us55 = phi i8* [ %call.us, %postClockEnabledBlock7 ], [ %call.us53, %postClockEnabledBlock ]
  %incdec.ptr.us = getelementptr inbounds i8, i8* %call.us55, i64 1
  %13 = load i8, i8* %incdec.ptr.us, align 1, !tbaa !397
  %14 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %14, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %while.body.us
  %15 = load i64, i64* @LocalLC
  %16 = add i64 3, %15
  store i64 %16, i64* @LocalLC
  %commit10 = icmp ugt i64 %16, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %17 = add i32 %14, 1
  store i32 %17, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %16)
  %18 = load i32, i32* @lc_disabled_count
  %19 = sub i32 %18, 1
  store i32 %19, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %while.body.us, %postInstrumentation11
  switch i8 %13, label %land.rhs.us [
    i8 10, label %if.end21.us
    i8 13, label %land.lhs.true11.us
  ]

land.lhs.true11.us:                               ; preds = %postClockEnabledBlock14
  %add.ptr.us = getelementptr inbounds i8, i8* %call.us55, i64 2
  %20 = load i8, i8* %add.ptr.us, align 1, !tbaa !397
  %cmp13.us = icmp eq i8 %20, 10
  %21 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %21, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %land.lhs.true11.us
  %22 = load i64, i64* @LocalLC
  %23 = add i64 4, %22
  store i64 %23, i64* @LocalLC
  %commit17 = icmp ugt i64 %23, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %24 = add i32 %21, 1
  store i32 %24, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %23)
  %25 = load i32, i32* @lc_disabled_count
  %26 = sub i32 %25, 1
  store i32 %26, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %land.lhs.true11.us, %postInstrumentation18
  br i1 %cmp13.us, label %if.end21.us, label %land.rhs.us

if.end21.us:                                      ; preds = %postClockEnabledBlock21, %postClockEnabledBlock14
  %.sink67 = phi i32 [ 2, %postClockEnabledBlock21 ], [ 1, %postClockEnabledBlock14 ]
  %sub.ptr.lhs.cast.us = ptrtoint i8* %incdec.ptr.us to i64
  %sub.ptr.sub.us = sub i64 %sub.ptr.lhs.cast.us, %sub.ptr.rhs.cast17
  %27 = trunc i64 %sub.ptr.sub.us to i32
  %conv5.us = add i32 %.sink67, %27
  %tobool.us = icmp eq i32 %conv5.us, 0
  %28 = load i32, i32* @lc_disabled_count
  %clock_running22 = icmp eq i32 %28, 0
  br i1 %clock_running22, label %if_clock_enabled23, label %postClockEnabledBlock28

if_clock_enabled23:                               ; preds = %if.end21.us
  %29 = load i64, i64* @LocalLC
  %30 = add i64 6, %29
  store i64 %30, i64* @LocalLC
  %commit24 = icmp ugt i64 %30, 5000
  br i1 %commit24, label %pushBlock26, label %postInstrumentation25

pushBlock26:                                      ; preds = %if_clock_enabled23
  %31 = add i32 %28, 1
  store i32 %31, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler27 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler27(i64 %30)
  %32 = load i32, i32* @lc_disabled_count
  %33 = sub i32 %32, 1
  store i32 %33, i32* @lc_disabled_count
  br label %postInstrumentation25

postInstrumentation25:                            ; preds = %if_clock_enabled23, %pushBlock26
  br label %postClockEnabledBlock28

postClockEnabledBlock28:                          ; preds = %if.end21.us, %postInstrumentation25
  br i1 %tobool.us, label %land.rhs.us, label %if.then25

land.rhs:                                         ; preds = %postClockEnabledBlock42, %entry
  %temp.052 = phi i8* [ %incdec.ptr, %postClockEnabledBlock42 ], [ %data, %entry ]
  %call = tail call i8* @strchr(i8* nonnull %temp.052, i32 10) #20
  %cmp = icmp eq i8* %call, null
  %34 = load i32, i32* @lc_disabled_count
  %clock_running29 = icmp eq i32 %34, 0
  br i1 %clock_running29, label %if_clock_enabled30, label %postClockEnabledBlock35

if_clock_enabled30:                               ; preds = %land.rhs
  %35 = load i64, i64* @LocalLC
  %36 = add i64 3, %35
  store i64 %36, i64* @LocalLC
  %commit31 = icmp ugt i64 %36, 5000
  br i1 %commit31, label %pushBlock33, label %postInstrumentation32

pushBlock33:                                      ; preds = %if_clock_enabled30
  %37 = add i32 %34, 1
  store i32 %37, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler34 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler34(i64 %36)
  %38 = load i32, i32* @lc_disabled_count
  %39 = sub i32 %38, 1
  store i32 %39, i32* @lc_disabled_count
  br label %postInstrumentation32

postInstrumentation32:                            ; preds = %if_clock_enabled30, %pushBlock33
  br label %postClockEnabledBlock35

postClockEnabledBlock35:                          ; preds = %land.rhs, %postInstrumentation32
  br i1 %cmp, label %while.end, label %while.body

while.body:                                       ; preds = %postClockEnabledBlock35
  %incdec.ptr = getelementptr inbounds i8, i8* %call, i64 1
  %40 = load i8, i8* %incdec.ptr, align 1, !tbaa !397
  %cmp3 = icmp ne i8 %40, 10
  %sub.ptr.lhs.cast = ptrtoint i8* %incdec.ptr to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast17
  %41 = trunc i64 %sub.ptr.sub to i32
  %conv5 = add i32 %41, 1
  %tobool64 = icmp eq i32 %conv5, 0
  %tobool = or i1 %tobool64, %cmp3
  %42 = load i32, i32* @lc_disabled_count
  %clock_running36 = icmp eq i32 %42, 0
  br i1 %clock_running36, label %if_clock_enabled37, label %postClockEnabledBlock42

if_clock_enabled37:                               ; preds = %while.body
  %43 = load i64, i64* @LocalLC
  %44 = add i64 10, %43
  store i64 %44, i64* @LocalLC
  %commit38 = icmp ugt i64 %44, 5000
  br i1 %commit38, label %pushBlock40, label %postInstrumentation39

pushBlock40:                                      ; preds = %if_clock_enabled37
  %45 = add i32 %42, 1
  store i32 %45, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler41 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler41(i64 %44)
  %46 = load i32, i32* @lc_disabled_count
  %47 = sub i32 %46, 1
  store i32 %47, i32* @lc_disabled_count
  br label %postInstrumentation39

postInstrumentation39:                            ; preds = %if_clock_enabled37, %pushBlock40
  br label %postClockEnabledBlock42

postClockEnabledBlock42:                          ; preds = %while.body, %postInstrumentation39
  br i1 %tobool, label %land.rhs, label %if.then25

while.end:                                        ; preds = %postClockEnabledBlock35, %postClockEnabledBlock7, %postClockEnabledBlock
  store i8 %0, i8* %arrayidx, align 1, !tbaa !397
  br label %if.end28

if.then25:                                        ; preds = %postClockEnabledBlock42, %postClockEnabledBlock28
  %hdr_len.0.lcssa = phi i32 [ %conv5.us, %postClockEnabledBlock28 ], [ %conv5, %postClockEnabledBlock42 ]
  store i8 %0, i8* %arrayidx, align 1, !tbaa !397
  %sub = add nsw i32 %hdr_len.0.lcssa, -1
  %idxprom26 = sext i32 %sub to i64
  %arrayidx27 = getelementptr inbounds i8, i8* %data, i64 %idxprom26
  store i8 0, i8* %arrayidx27, align 1, !tbaa !397
  br label %if.end28

if.end28:                                         ; preds = %if.then25, %while.end
  %hdr_len.050 = phi i32 [ 0, %while.end ], [ %hdr_len.0.lcssa, %if.then25 ]
  ret i32 %hdr_len.050
}

; Function Attrs: nofree nounwind readonly
declare i8* @strchr(i8*, i32) local_unnamed_addr #9

; Function Attrs: nounwind readonly uwtable
define i32 @is_http_request(i8* nocapture readonly %data, i32 %len) local_unnamed_addr #13 {
entry:
  %cmp = icmp ugt i32 %len, 2
  br i1 %cmp, label %land.lhs.true, label %if.end9

land.lhs.true:                                    ; preds = %entry
  %call = tail call i32 @strncmp(i8* %data, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i64 3) #20
  %tobool = icmp eq i32 %call, 0
  %0 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %0, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %land.lhs.true
  %1 = load i64, i64* @LocalLC
  %2 = add i64 3, %1
  store i64 %2, i64* @LocalLC
  %commit = icmp ugt i64 %2, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %3 = add i32 %0, 1
  store i32 %3, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %2)
  %4 = load i32, i32* @lc_disabled_count
  %5 = sub i32 %4, 1
  store i32 %5, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %land.lhs.true, %postInstrumentation
  br i1 %tobool, label %return, label %if.end

if.end:                                           ; preds = %postClockEnabledBlock
  %cmp3 = icmp ugt i32 %len, 3
  %6 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %6, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %if.end
  %7 = load i64, i64* @LocalLC
  %8 = add i64 2, %7
  store i64 %8, i64* @LocalLC
  %commit3 = icmp ugt i64 %8, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %9 = add i32 %6, 1
  store i32 %9, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %8)
  %10 = load i32, i32* @lc_disabled_count
  %11 = sub i32 %10, 1
  store i32 %11, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %if.end, %postInstrumentation4
  br i1 %cmp3, label %land.lhs.true5, label %if.end9

land.lhs.true5:                                   ; preds = %postClockEnabledBlock7
  %call6 = tail call i32 @strncmp(i8* %data, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.1.1, i64 0, i64 0), i64 4) #20
  %tobool7 = icmp eq i32 %call6, 0
  %12 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %12, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %land.lhs.true5
  %13 = load i64, i64* @LocalLC
  %14 = add i64 3, %13
  store i64 %14, i64* @LocalLC
  %commit10 = icmp ugt i64 %14, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %15 = add i32 %12, 1
  store i32 %15, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %14)
  %16 = load i32, i32* @lc_disabled_count
  %17 = sub i32 %16, 1
  store i32 %17, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %land.lhs.true5, %postInstrumentation11
  br i1 %tobool7, label %return, label %if.end9

if.end9:                                          ; preds = %postClockEnabledBlock14, %postClockEnabledBlock7, %entry
  %18 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %18, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %if.end9
  %19 = load i64, i64* @LocalLC
  %20 = add i64 1, %19
  store i64 %20, i64* @LocalLC
  %commit17 = icmp ugt i64 %20, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %21 = add i32 %18, 1
  store i32 %21, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %20)
  %22 = load i32, i32* @lc_disabled_count
  %23 = sub i32 %22, 1
  store i32 %23, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %if.end9, %postInstrumentation18
  br label %return

return:                                           ; preds = %postClockEnabledBlock21, %postClockEnabledBlock14, %postClockEnabledBlock
  %retval.0 = phi i32 [ 0, %postClockEnabledBlock21 ], [ 1, %postClockEnabledBlock ], [ 2, %postClockEnabledBlock14 ]
  ret i32 %retval.0
}

; Function Attrs: nounwind readonly uwtable
define i32 @is_http_response(i8* nocapture readonly %data, i32 %len) local_unnamed_addr #13 {
entry:
  %cmp = icmp ult i32 %len, 4
  br i1 %cmp, label %return, label %if.end

if.end:                                           ; preds = %entry
  %call = tail call i32 @strncmp(i8* %data, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.2.2, i64 0, i64 0), i64 4) #20
  %tobool = icmp eq i32 %call, 0
  %. = zext i1 %tobool to i32
  br label %return

return:                                           ; preds = %if.end, %entry
  %retval.0 = phi i32 [ 0, %entry ], [ %., %if.end ]
  ret i32 %retval.0
}

; Function Attrs: nofree nounwind uwtable
define i8* @http_header_str_val(i8* readonly %buf, i8* nocapture readonly %key, i32 %keylen, i8* %value, i32 %value_len) local_unnamed_addr #7 {
entry:
  %call.i = tail call i64 @strlen(i8* %key) #20
  %add.ptr11.i = getelementptr inbounds i8, i8* %key, i64 1
  %conv.i = shl i64 %call.i, 32
  %sext.i = add i64 %conv.i, -4294967296
  %conv12.i = ashr exact i64 %sext.i, 32
  br label %while.cond.i

while.cond.i:                                     ; preds = %postClockEnabledBlock21, %entry
  %p.0.i = phi i8* [ %buf, %entry ], [ %incdec.ptr.i, %postClockEnabledBlock21 ]
  %0 = load i8, i8* %p.0.i, align 1, !tbaa !397
  %tobool.i = icmp eq i8 %0, 0
  %1 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %1, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %while.cond.i
  %2 = load i64, i64* @LocalLC
  %3 = add i64 3, %2
  store i64 %3, i64* @LocalLC
  %commit = icmp ugt i64 %3, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %4 = add i32 %1, 1
  store i32 %4, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %3)
  %5 = load i32, i32* @lc_disabled_count
  %6 = sub i32 %5, 1
  store i32 %6, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %while.cond.i, %postInstrumentation
  br i1 %tobool.i, label %cleanup.sink.split, label %land.rhs.lr.ph.i

land.rhs.lr.ph.i:                                 ; preds = %postClockEnabledBlock
  %7 = load i8, i8* %key, align 1, !tbaa !397
  %8 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %8, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %land.rhs.lr.ph.i
  %9 = load i64, i64* @LocalLC
  %10 = add i64 2, %9
  store i64 %10, i64* @LocalLC
  %commit3 = icmp ugt i64 %10, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %11 = add i32 %8, 1
  store i32 %11, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %10)
  %12 = load i32, i32* @lc_disabled_count
  %13 = sub i32 %12, 1
  store i32 %13, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %land.rhs.lr.ph.i, %postInstrumentation4
  br label %land.rhs.i

land.rhs.i:                                       ; preds = %postClockEnabledBlock14, %postClockEnabledBlock7
  %p.132.i = phi i8* [ %p.0.i, %postClockEnabledBlock7 ], [ %incdec.ptr.i, %postClockEnabledBlock14 ]
  %14 = phi i8 [ %0, %postClockEnabledBlock7 ], [ %.pr.i, %postClockEnabledBlock14 ]
  %cmp.i = icmp eq i8 %14, %7
  %incdec.ptr.i = getelementptr inbounds i8, i8* %p.132.i, i64 1
  br i1 %cmp.i, label %if.end.i, label %while.body7.i

while.body7.i:                                    ; preds = %land.rhs.i
  %.pr.i = load i8, i8* %incdec.ptr.i, align 1, !tbaa !397
  %tobool3.i = icmp eq i8 %.pr.i, 0
  %15 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %15, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %while.body7.i
  %16 = load i64, i64* @LocalLC
  %17 = add i64 6, %16
  store i64 %17, i64* @LocalLC
  %commit10 = icmp ugt i64 %17, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %18 = add i32 %15, 1
  store i32 %18, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %17)
  %19 = load i32, i32* @lc_disabled_count
  %20 = sub i32 %19, 1
  store i32 %20, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %while.body7.i, %postInstrumentation11
  br i1 %tobool3.i, label %cleanup.sink.split, label %land.rhs.i

if.end.i:                                         ; preds = %land.rhs.i
  %call13.i = tail call i32 @strncasecmp(i8* nonnull %incdec.ptr.i, i8* nonnull %add.ptr11.i, i64 %conv12.i) #20
  %tobool14.i = icmp eq i32 %call13.i, 0
  %21 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %21, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %if.end.i
  %22 = load i64, i64* @LocalLC
  %23 = add i64 6, %22
  store i64 %23, i64* @LocalLC
  %commit17 = icmp ugt i64 %23, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %24 = add i32 %21, 1
  store i32 %24, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %23)
  %25 = load i32, i32* @lc_disabled_count
  %26 = sub i32 %25, 1
  store i32 %26, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %if.end.i, %postInstrumentation18
  br i1 %tobool14.i, label %nre_strcasestr.exit, label %while.cond.i

nre_strcasestr.exit:                              ; preds = %postClockEnabledBlock21
  %cmp = icmp eq i8* %p.132.i, null
  %27 = load i32, i32* @lc_disabled_count
  %clock_running22 = icmp eq i32 %27, 0
  br i1 %clock_running22, label %if_clock_enabled23, label %postClockEnabledBlock28

if_clock_enabled23:                               ; preds = %nre_strcasestr.exit
  %28 = load i64, i64* @LocalLC
  %29 = add i64 2, %28
  store i64 %29, i64* @LocalLC
  %commit24 = icmp ugt i64 %29, 5000
  br i1 %commit24, label %pushBlock26, label %postInstrumentation25

pushBlock26:                                      ; preds = %if_clock_enabled23
  %30 = add i32 %27, 1
  store i32 %30, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler27 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler27(i64 %29)
  %31 = load i32, i32* @lc_disabled_count
  %32 = sub i32 %31, 1
  store i32 %32, i32* @lc_disabled_count
  br label %postInstrumentation25

postInstrumentation25:                            ; preds = %if_clock_enabled23, %pushBlock26
  br label %postClockEnabledBlock28

postClockEnabledBlock28:                          ; preds = %nre_strcasestr.exit, %postInstrumentation25
  br i1 %cmp, label %cleanup.sink.split, label %if.end

if.end:                                           ; preds = %postClockEnabledBlock28
  %idx.ext = sext i32 %keylen to i64
  %add.ptr = getelementptr inbounds i8, i8* %p.132.i, i64 %idx.ext
  %33 = load i32, i32* @lc_disabled_count
  %clock_running29 = icmp eq i32 %33, 0
  br i1 %clock_running29, label %if_clock_enabled30, label %postClockEnabledBlock35

if_clock_enabled30:                               ; preds = %if.end
  %34 = load i64, i64* @LocalLC
  %35 = add i64 3, %34
  store i64 %35, i64* @LocalLC
  %commit31 = icmp ugt i64 %35, 5000
  br i1 %commit31, label %pushBlock33, label %postInstrumentation32

pushBlock33:                                      ; preds = %if_clock_enabled30
  %36 = add i32 %33, 1
  store i32 %36, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler34 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler34(i64 %35)
  %37 = load i32, i32* @lc_disabled_count
  %38 = sub i32 %37, 1
  store i32 %38, i32* @lc_disabled_count
  br label %postInstrumentation32

postInstrumentation32:                            ; preds = %if_clock_enabled30, %pushBlock33
  br label %postClockEnabledBlock35

postClockEnabledBlock35:                          ; preds = %if.end, %postInstrumentation32
  br label %while.cond

while.cond:                                       ; preds = %postClockEnabledBlock56, %postClockEnabledBlock35
  %temp.0 = phi i8* [ %add.ptr, %postClockEnabledBlock35 ], [ %incdec.ptr, %postClockEnabledBlock56 ]
  %39 = load i8, i8* %temp.0, align 1, !tbaa !397
  %40 = load i32, i32* @lc_disabled_count
  %clock_running36 = icmp eq i32 %40, 0
  br i1 %clock_running36, label %if_clock_enabled37, label %postClockEnabledBlock42

if_clock_enabled37:                               ; preds = %while.cond
  %41 = load i64, i64* @LocalLC
  %42 = add i64 2, %41
  store i64 %42, i64* @LocalLC
  %commit38 = icmp ugt i64 %42, 5000
  br i1 %commit38, label %pushBlock40, label %postInstrumentation39

pushBlock40:                                      ; preds = %if_clock_enabled37
  %43 = add i32 %40, 1
  store i32 %43, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler41 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler41(i64 %42)
  %44 = load i32, i32* @lc_disabled_count
  %45 = sub i32 %44, 1
  store i32 %45, i32* @lc_disabled_count
  br label %postInstrumentation39

postInstrumentation39:                            ; preds = %if_clock_enabled37, %pushBlock40
  br label %postClockEnabledBlock42

postClockEnabledBlock42:                          ; preds = %while.cond, %postInstrumentation39
  switch i8 %39, label %while.cond19.preheader [
    i8 9, label %while.body
    i8 32, label %while.body
    i8 0, label %cleanup.sink.split
    i8 13, label %cleanup.sink.split
    i8 10, label %cleanup.sink.split
  ]

while.cond19.preheader:                           ; preds = %postClockEnabledBlock42
  %sub = add nsw i32 %value_len, -1
  %46 = sext i32 %sub to i64
  %47 = load i32, i32* @lc_disabled_count
  %clock_running43 = icmp eq i32 %47, 0
  br i1 %clock_running43, label %if_clock_enabled44, label %postClockEnabledBlock49

if_clock_enabled44:                               ; preds = %while.cond19.preheader
  %48 = load i64, i64* @LocalLC
  %49 = add i64 3, %48
  store i64 %49, i64* @LocalLC
  %commit45 = icmp ugt i64 %49, 5000
  br i1 %commit45, label %pushBlock47, label %postInstrumentation46

pushBlock47:                                      ; preds = %if_clock_enabled44
  %50 = add i32 %47, 1
  store i32 %50, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler48 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler48(i64 %49)
  %51 = load i32, i32* @lc_disabled_count
  %52 = sub i32 %51, 1
  store i32 %52, i32* @lc_disabled_count
  br label %postInstrumentation46

postInstrumentation46:                            ; preds = %if_clock_enabled44, %pushBlock47
  br label %postClockEnabledBlock49

postClockEnabledBlock49:                          ; preds = %while.cond19.preheader, %postInstrumentation46
  br label %while.cond19

while.body:                                       ; preds = %postClockEnabledBlock42, %postClockEnabledBlock42
  %incdec.ptr = getelementptr inbounds i8, i8* %temp.0, i64 1
  %53 = load i32, i32* @lc_disabled_count
  %clock_running50 = icmp eq i32 %53, 0
  br i1 %clock_running50, label %if_clock_enabled51, label %postClockEnabledBlock56

if_clock_enabled51:                               ; preds = %while.body
  %54 = load i64, i64* @LocalLC
  %55 = add i64 2, %54
  store i64 %55, i64* @LocalLC
  %commit52 = icmp ugt i64 %55, 5000
  br i1 %commit52, label %pushBlock54, label %postInstrumentation53

pushBlock54:                                      ; preds = %if_clock_enabled51
  %56 = add i32 %53, 1
  store i32 %56, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler55 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler55(i64 %55)
  %57 = load i32, i32* @lc_disabled_count
  %58 = sub i32 %57, 1
  store i32 %58, i32* @lc_disabled_count
  br label %postInstrumentation53

postInstrumentation53:                            ; preds = %if_clock_enabled51, %pushBlock54
  br label %postClockEnabledBlock56

postClockEnabledBlock56:                          ; preds = %while.body, %postInstrumentation53
  br label %while.cond

while.cond19:                                     ; preds = %postClockEnabledBlock77, %postClockEnabledBlock49
  %indvars.iv = phi i64 [ 0, %postClockEnabledBlock49 ], [ %indvars.iv.next, %postClockEnabledBlock77 ]
  %59 = phi i8 [ %39, %postClockEnabledBlock49 ], [ %.pr, %postClockEnabledBlock77 ]
  %temp.1 = phi i8* [ %temp.0, %postClockEnabledBlock49 ], [ %incdec.ptr34, %postClockEnabledBlock77 ]
  %60 = load i32, i32* @lc_disabled_count
  %clock_running57 = icmp eq i32 %60, 0
  br i1 %clock_running57, label %if_clock_enabled58, label %postClockEnabledBlock63

if_clock_enabled58:                               ; preds = %while.cond19
  %61 = load i64, i64* @LocalLC
  %62 = add i64 1, %61
  store i64 %62, i64* @LocalLC
  %commit59 = icmp ugt i64 %62, 5000
  br i1 %commit59, label %pushBlock61, label %postInstrumentation60

pushBlock61:                                      ; preds = %if_clock_enabled58
  %63 = add i32 %60, 1
  store i32 %63, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler62 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler62(i64 %62)
  %64 = load i32, i32* @lc_disabled_count
  %65 = sub i32 %64, 1
  store i32 %65, i32* @lc_disabled_count
  br label %postInstrumentation60

postInstrumentation60:                            ; preds = %if_clock_enabled58, %pushBlock61
  br label %postClockEnabledBlock63

postClockEnabledBlock63:                          ; preds = %while.cond19, %postInstrumentation60
  switch i8 %59, label %land.rhs29 [
    i8 0, label %while.end35
    i8 13, label %while.end35
    i8 10, label %while.end35
  ]

land.rhs29:                                       ; preds = %postClockEnabledBlock63
  %cmp30 = icmp slt i64 %indvars.iv, %46
  %66 = load i32, i32* @lc_disabled_count
  %clock_running64 = icmp eq i32 %66, 0
  br i1 %clock_running64, label %if_clock_enabled65, label %postClockEnabledBlock70

if_clock_enabled65:                               ; preds = %land.rhs29
  %67 = load i64, i64* @LocalLC
  %68 = add i64 2, %67
  store i64 %68, i64* @LocalLC
  %commit66 = icmp ugt i64 %68, 5000
  br i1 %commit66, label %pushBlock68, label %postInstrumentation67

pushBlock68:                                      ; preds = %if_clock_enabled65
  %69 = add i32 %66, 1
  store i32 %69, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler69 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler69(i64 %68)
  %70 = load i32, i32* @lc_disabled_count
  %71 = sub i32 %70, 1
  store i32 %71, i32* @lc_disabled_count
  br label %postInstrumentation67

postInstrumentation67:                            ; preds = %if_clock_enabled65, %pushBlock68
  br label %postClockEnabledBlock70

postClockEnabledBlock70:                          ; preds = %land.rhs29, %postInstrumentation67
  br i1 %cmp30, label %while.body33, label %while.end35

while.body33:                                     ; preds = %postClockEnabledBlock70
  %incdec.ptr34 = getelementptr inbounds i8, i8* %temp.1, i64 1
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %arrayidx = getelementptr inbounds i8, i8* %value, i64 %indvars.iv
  store i8 %59, i8* %arrayidx, align 1, !tbaa !397
  %.pr = load i8, i8* %incdec.ptr34, align 1, !tbaa !397
  %72 = load i32, i32* @lc_disabled_count
  %clock_running71 = icmp eq i32 %72, 0
  br i1 %clock_running71, label %if_clock_enabled72, label %postClockEnabledBlock77

if_clock_enabled72:                               ; preds = %while.body33
  %73 = load i64, i64* @LocalLC
  %74 = add i64 6, %73
  store i64 %74, i64* @LocalLC
  %commit73 = icmp ugt i64 %74, 5000
  br i1 %commit73, label %pushBlock75, label %postInstrumentation74

pushBlock75:                                      ; preds = %if_clock_enabled72
  %75 = add i32 %72, 1
  store i32 %75, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler76 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler76(i64 %74)
  %76 = load i32, i32* @lc_disabled_count
  %77 = sub i32 %76, 1
  store i32 %77, i32* @lc_disabled_count
  br label %postInstrumentation74

postInstrumentation74:                            ; preds = %if_clock_enabled72, %pushBlock75
  br label %postClockEnabledBlock77

postClockEnabledBlock77:                          ; preds = %while.body33, %postInstrumentation74
  br label %while.cond19

while.end35:                                      ; preds = %postClockEnabledBlock70, %postClockEnabledBlock63, %postClockEnabledBlock63, %postClockEnabledBlock63
  %78 = trunc i64 %indvars.iv to i32
  %idxprom36 = and i64 %indvars.iv, 4294967295
  %arrayidx37 = getelementptr inbounds i8, i8* %value, i64 %idxprom36
  store i8 0, i8* %arrayidx37, align 1, !tbaa !397
  %cmp38 = icmp eq i32 %78, 0
  %79 = load i32, i32* @lc_disabled_count
  %clock_running78 = icmp eq i32 %79, 0
  br i1 %clock_running78, label %if_clock_enabled79, label %postClockEnabledBlock84

if_clock_enabled79:                               ; preds = %while.end35
  %80 = load i64, i64* @LocalLC
  %81 = add i64 6, %80
  store i64 %81, i64* @LocalLC
  %commit80 = icmp ugt i64 %81, 5000
  br i1 %commit80, label %pushBlock82, label %postInstrumentation81

pushBlock82:                                      ; preds = %if_clock_enabled79
  %82 = add i32 %79, 1
  store i32 %82, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler83 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler83(i64 %81)
  %83 = load i32, i32* @lc_disabled_count
  %84 = sub i32 %83, 1
  store i32 %84, i32* @lc_disabled_count
  br label %postInstrumentation81

postInstrumentation81:                            ; preds = %if_clock_enabled79, %pushBlock82
  br label %postClockEnabledBlock84

postClockEnabledBlock84:                          ; preds = %while.end35, %postInstrumentation81
  br i1 %cmp38, label %cleanup.sink.split, label %cleanup

cleanup.sink.split:                               ; preds = %postClockEnabledBlock84, %postClockEnabledBlock42, %postClockEnabledBlock42, %postClockEnabledBlock42, %postClockEnabledBlock28, %postClockEnabledBlock14, %postClockEnabledBlock
  store i8 0, i8* %value, align 1, !tbaa !397
  %85 = load i32, i32* @lc_disabled_count
  %clock_running85 = icmp eq i32 %85, 0
  br i1 %clock_running85, label %if_clock_enabled86, label %postClockEnabledBlock91

if_clock_enabled86:                               ; preds = %cleanup.sink.split
  %86 = load i64, i64* @LocalLC
  %87 = add i64 2, %86
  store i64 %87, i64* @LocalLC
  %commit87 = icmp ugt i64 %87, 5000
  br i1 %commit87, label %pushBlock89, label %postInstrumentation88

pushBlock89:                                      ; preds = %if_clock_enabled86
  %88 = add i32 %85, 1
  store i32 %88, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler90 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler90(i64 %87)
  %89 = load i32, i32* @lc_disabled_count
  %90 = sub i32 %89, 1
  store i32 %90, i32* @lc_disabled_count
  br label %postInstrumentation88

postInstrumentation88:                            ; preds = %if_clock_enabled86, %pushBlock89
  br label %postClockEnabledBlock91

postClockEnabledBlock91:                          ; preds = %cleanup.sink.split, %postInstrumentation88
  br label %cleanup

cleanup:                                          ; preds = %postClockEnabledBlock91, %postClockEnabledBlock84
  %retval.0 = phi i8* [ %value, %postClockEnabledBlock84 ], [ null, %postClockEnabledBlock91 ]
  ret i8* %retval.0
}

; Function Attrs: argmemonly nofree nounwind readonly
declare i64 @strlen(i8* nocapture) local_unnamed_addr #14

; Function Attrs: nofree nounwind readonly
declare i32 @strncasecmp(i8* nocapture, i8* nocapture, i64) local_unnamed_addr #9

; Function Attrs: nounwind uwtable
define i64 @http_header_long_val(i8* readonly %response, i8* nocapture readonly %key, i32 %key_len) local_unnamed_addr #0 {
entry:
  %value = alloca [50 x i8], align 16
  %0 = getelementptr inbounds [50 x i8], [50 x i8]* %value, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 50, i8* nonnull %0) #16
  %call.i.i = tail call i64 @strlen(i8* %key) #20
  %add.ptr11.i.i = getelementptr inbounds i8, i8* %key, i64 1
  %conv.i.i = shl i64 %call.i.i, 32
  %sext.i.i = add i64 %conv.i.i, -4294967296
  %conv12.i.i = ashr exact i64 %sext.i.i, 32
  br label %while.cond.i.i

while.cond.i.i:                                   ; preds = %postClockEnabledBlock21, %entry
  %p.0.i.i = phi i8* [ %response, %entry ], [ %incdec.ptr.i.i, %postClockEnabledBlock21 ]
  %1 = load i8, i8* %p.0.i.i, align 1, !tbaa !397
  %tobool.i.i = icmp eq i8 %1, 0
  %2 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %2, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %while.cond.i.i
  %3 = load i64, i64* @LocalLC
  %4 = add i64 3, %3
  store i64 %4, i64* @LocalLC
  %commit = icmp ugt i64 %4, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %5 = add i32 %2, 1
  store i32 %5, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %4)
  %6 = load i32, i32* @lc_disabled_count
  %7 = sub i32 %6, 1
  store i32 %7, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %while.cond.i.i, %postInstrumentation
  br i1 %tobool.i.i, label %if.then.i, label %land.rhs.lr.ph.i.i

land.rhs.lr.ph.i.i:                               ; preds = %postClockEnabledBlock
  %8 = load i8, i8* %key, align 1, !tbaa !397
  %9 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %9, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %land.rhs.lr.ph.i.i
  %10 = load i64, i64* @LocalLC
  %11 = add i64 2, %10
  store i64 %11, i64* @LocalLC
  %commit3 = icmp ugt i64 %11, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %12 = add i32 %9, 1
  store i32 %12, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %11)
  %13 = load i32, i32* @lc_disabled_count
  %14 = sub i32 %13, 1
  store i32 %14, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %land.rhs.lr.ph.i.i, %postInstrumentation4
  br label %land.rhs.i.i

land.rhs.i.i:                                     ; preds = %postClockEnabledBlock14, %postClockEnabledBlock7
  %p.132.i.i = phi i8* [ %p.0.i.i, %postClockEnabledBlock7 ], [ %incdec.ptr.i.i, %postClockEnabledBlock14 ]
  %15 = phi i8 [ %1, %postClockEnabledBlock7 ], [ %.pr.i.i, %postClockEnabledBlock14 ]
  %cmp.i.i = icmp eq i8 %15, %8
  %incdec.ptr.i.i = getelementptr inbounds i8, i8* %p.132.i.i, i64 1
  br i1 %cmp.i.i, label %if.end.i.i, label %while.body7.i.i

while.body7.i.i:                                  ; preds = %land.rhs.i.i
  %.pr.i.i = load i8, i8* %incdec.ptr.i.i, align 1, !tbaa !397
  %tobool3.i.i = icmp eq i8 %.pr.i.i, 0
  %16 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %16, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %while.body7.i.i
  %17 = load i64, i64* @LocalLC
  %18 = add i64 6, %17
  store i64 %18, i64* @LocalLC
  %commit10 = icmp ugt i64 %18, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %19 = add i32 %16, 1
  store i32 %19, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %18)
  %20 = load i32, i32* @lc_disabled_count
  %21 = sub i32 %20, 1
  store i32 %21, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %while.body7.i.i, %postInstrumentation11
  br i1 %tobool3.i.i, label %if.then.i, label %land.rhs.i.i

if.end.i.i:                                       ; preds = %land.rhs.i.i
  %call13.i.i = tail call i32 @strncasecmp(i8* nonnull %incdec.ptr.i.i, i8* nonnull %add.ptr11.i.i, i64 %conv12.i.i) #20
  %tobool14.i.i = icmp eq i32 %call13.i.i, 0
  %22 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %22, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %if.end.i.i
  %23 = load i64, i64* @LocalLC
  %24 = add i64 6, %23
  store i64 %24, i64* @LocalLC
  %commit17 = icmp ugt i64 %24, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %25 = add i32 %22, 1
  store i32 %25, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %24)
  %26 = load i32, i32* @lc_disabled_count
  %27 = sub i32 %26, 1
  store i32 %27, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %if.end.i.i, %postInstrumentation18
  br i1 %tobool14.i.i, label %nre_strcasestr.exit.i, label %while.cond.i.i

nre_strcasestr.exit.i:                            ; preds = %postClockEnabledBlock21
  %cmp.i = icmp eq i8* %p.132.i.i, null
  %28 = load i32, i32* @lc_disabled_count
  %clock_running22 = icmp eq i32 %28, 0
  br i1 %clock_running22, label %if_clock_enabled23, label %postClockEnabledBlock28

if_clock_enabled23:                               ; preds = %nre_strcasestr.exit.i
  %29 = load i64, i64* @LocalLC
  %30 = add i64 2, %29
  store i64 %30, i64* @LocalLC
  %commit24 = icmp ugt i64 %30, 5000
  br i1 %commit24, label %pushBlock26, label %postInstrumentation25

pushBlock26:                                      ; preds = %if_clock_enabled23
  %31 = add i32 %28, 1
  store i32 %31, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler27 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler27(i64 %30)
  %32 = load i32, i32* @lc_disabled_count
  %33 = sub i32 %32, 1
  store i32 %33, i32* @lc_disabled_count
  br label %postInstrumentation25

postInstrumentation25:                            ; preds = %if_clock_enabled23, %pushBlock26
  br label %postClockEnabledBlock28

postClockEnabledBlock28:                          ; preds = %nre_strcasestr.exit.i, %postInstrumentation25
  br i1 %cmp.i, label %if.then.i, label %if.end.i

if.then.i:                                        ; preds = %postClockEnabledBlock28, %postClockEnabledBlock14, %postClockEnabledBlock
  store i8 0, i8* %0, align 16, !tbaa !397
  br label %cleanup

if.end.i:                                         ; preds = %postClockEnabledBlock28
  %idx.ext.i = sext i32 %key_len to i64
  %add.ptr.i = getelementptr inbounds i8, i8* %p.132.i.i, i64 %idx.ext.i
  %34 = load i32, i32* @lc_disabled_count
  %clock_running29 = icmp eq i32 %34, 0
  br i1 %clock_running29, label %if_clock_enabled30, label %postClockEnabledBlock35

if_clock_enabled30:                               ; preds = %if.end.i
  %35 = load i64, i64* @LocalLC
  %36 = add i64 3, %35
  store i64 %36, i64* @LocalLC
  %commit31 = icmp ugt i64 %36, 5000
  br i1 %commit31, label %pushBlock33, label %postInstrumentation32

pushBlock33:                                      ; preds = %if_clock_enabled30
  %37 = add i32 %34, 1
  store i32 %37, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler34 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler34(i64 %36)
  %38 = load i32, i32* @lc_disabled_count
  %39 = sub i32 %38, 1
  store i32 %39, i32* @lc_disabled_count
  br label %postInstrumentation32

postInstrumentation32:                            ; preds = %if_clock_enabled30, %pushBlock33
  br label %postClockEnabledBlock35

postClockEnabledBlock35:                          ; preds = %if.end.i, %postInstrumentation32
  br label %while.cond.i

while.cond.i:                                     ; preds = %postClockEnabledBlock49, %postClockEnabledBlock35
  %temp.0.i = phi i8* [ %add.ptr.i, %postClockEnabledBlock35 ], [ %incdec.ptr.i, %postClockEnabledBlock49 ]
  %40 = load i8, i8* %temp.0.i, align 1, !tbaa !397
  %41 = load i32, i32* @lc_disabled_count
  %clock_running36 = icmp eq i32 %41, 0
  br i1 %clock_running36, label %if_clock_enabled37, label %postClockEnabledBlock42

if_clock_enabled37:                               ; preds = %while.cond.i
  %42 = load i64, i64* @LocalLC
  %43 = add i64 2, %42
  store i64 %43, i64* @LocalLC
  %commit38 = icmp ugt i64 %43, 5000
  br i1 %commit38, label %pushBlock40, label %postInstrumentation39

pushBlock40:                                      ; preds = %if_clock_enabled37
  %44 = add i32 %41, 1
  store i32 %44, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler41 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler41(i64 %43)
  %45 = load i32, i32* @lc_disabled_count
  %46 = sub i32 %45, 1
  store i32 %46, i32* @lc_disabled_count
  br label %postInstrumentation39

postInstrumentation39:                            ; preds = %if_clock_enabled37, %pushBlock40
  br label %postClockEnabledBlock42

postClockEnabledBlock42:                          ; preds = %while.cond.i, %postInstrumentation39
  switch i8 %40, label %while.cond19.i [
    i8 9, label %while.body.i
    i8 32, label %while.body.i
    i8 0, label %if.then17.i
    i8 13, label %if.then17.i
    i8 10, label %if.then17.i
  ]

while.body.i:                                     ; preds = %postClockEnabledBlock42, %postClockEnabledBlock42
  %incdec.ptr.i = getelementptr inbounds i8, i8* %temp.0.i, i64 1
  %47 = load i32, i32* @lc_disabled_count
  %clock_running43 = icmp eq i32 %47, 0
  br i1 %clock_running43, label %if_clock_enabled44, label %postClockEnabledBlock49

if_clock_enabled44:                               ; preds = %while.body.i
  %48 = load i64, i64* @LocalLC
  %49 = add i64 2, %48
  store i64 %49, i64* @LocalLC
  %commit45 = icmp ugt i64 %49, 5000
  br i1 %commit45, label %pushBlock47, label %postInstrumentation46

pushBlock47:                                      ; preds = %if_clock_enabled44
  %50 = add i32 %47, 1
  store i32 %50, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler48 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler48(i64 %49)
  %51 = load i32, i32* @lc_disabled_count
  %52 = sub i32 %51, 1
  store i32 %52, i32* @lc_disabled_count
  br label %postInstrumentation46

postInstrumentation46:                            ; preds = %if_clock_enabled44, %pushBlock47
  br label %postClockEnabledBlock49

postClockEnabledBlock49:                          ; preds = %while.body.i, %postInstrumentation46
  br label %while.cond.i

if.then17.i:                                      ; preds = %postClockEnabledBlock42, %postClockEnabledBlock42, %postClockEnabledBlock42
  store i8 0, i8* %0, align 16, !tbaa !397
  br label %cleanup

while.cond19.i:                                   ; preds = %postClockEnabledBlock70, %postClockEnabledBlock42
  %indvars.iv.i = phi i64 [ %indvars.iv.next.i, %postClockEnabledBlock70 ], [ 0, %postClockEnabledBlock42 ]
  %53 = phi i8 [ %.pr.i, %postClockEnabledBlock70 ], [ %40, %postClockEnabledBlock42 ]
  %temp.1.i = phi i8* [ %incdec.ptr34.i, %postClockEnabledBlock70 ], [ %temp.0.i, %postClockEnabledBlock42 ]
  %54 = load i32, i32* @lc_disabled_count
  %clock_running50 = icmp eq i32 %54, 0
  br i1 %clock_running50, label %if_clock_enabled51, label %postClockEnabledBlock56

if_clock_enabled51:                               ; preds = %while.cond19.i
  %55 = load i64, i64* @LocalLC
  %56 = add i64 1, %55
  store i64 %56, i64* @LocalLC
  %commit52 = icmp ugt i64 %56, 5000
  br i1 %commit52, label %pushBlock54, label %postInstrumentation53

pushBlock54:                                      ; preds = %if_clock_enabled51
  %57 = add i32 %54, 1
  store i32 %57, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler55 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler55(i64 %56)
  %58 = load i32, i32* @lc_disabled_count
  %59 = sub i32 %58, 1
  store i32 %59, i32* @lc_disabled_count
  br label %postInstrumentation53

postInstrumentation53:                            ; preds = %if_clock_enabled51, %pushBlock54
  br label %postClockEnabledBlock56

postClockEnabledBlock56:                          ; preds = %while.cond19.i, %postInstrumentation53
  switch i8 %53, label %land.rhs29.i [
    i8 0, label %while.end35.i
    i8 13, label %while.end35.i
    i8 10, label %while.end35.i
  ]

land.rhs29.i:                                     ; preds = %postClockEnabledBlock56
  %exitcond = icmp eq i64 %indvars.iv.i, 49
  br i1 %exitcond, label %while.end35.i.thread, label %while.body33.i

while.end35.i.thread:                             ; preds = %land.rhs29.i
  %arrayidx37.i27 = getelementptr inbounds [50 x i8], [50 x i8]* %value, i64 0, i64 49
  store i8 0, i8* %arrayidx37.i27, align 1, !tbaa !397
  %60 = load i32, i32* @lc_disabled_count
  %clock_running57 = icmp eq i32 %60, 0
  br i1 %clock_running57, label %if_clock_enabled58, label %postClockEnabledBlock63

if_clock_enabled58:                               ; preds = %while.end35.i.thread
  %61 = load i64, i64* @LocalLC
  %62 = add i64 5, %61
  store i64 %62, i64* @LocalLC
  %commit59 = icmp ugt i64 %62, 5000
  br i1 %commit59, label %pushBlock61, label %postInstrumentation60

pushBlock61:                                      ; preds = %if_clock_enabled58
  %63 = add i32 %60, 1
  store i32 %63, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler62 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler62(i64 %62)
  %64 = load i32, i32* @lc_disabled_count
  %65 = sub i32 %64, 1
  store i32 %65, i32* @lc_disabled_count
  br label %postInstrumentation60

postInstrumentation60:                            ; preds = %if_clock_enabled58, %pushBlock61
  br label %postClockEnabledBlock63

postClockEnabledBlock63:                          ; preds = %while.end35.i.thread, %postInstrumentation60
  br label %if.end

while.body33.i:                                   ; preds = %land.rhs29.i
  %incdec.ptr34.i = getelementptr inbounds i8, i8* %temp.1.i, i64 1
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %arrayidx.i = getelementptr inbounds [50 x i8], [50 x i8]* %value, i64 0, i64 %indvars.iv.i
  store i8 %53, i8* %arrayidx.i, align 1, !tbaa !397
  %.pr.i = load i8, i8* %incdec.ptr34.i, align 1, !tbaa !397
  %66 = load i32, i32* @lc_disabled_count
  %clock_running64 = icmp eq i32 %66, 0
  br i1 %clock_running64, label %if_clock_enabled65, label %postClockEnabledBlock70

if_clock_enabled65:                               ; preds = %while.body33.i
  %67 = load i64, i64* @LocalLC
  %68 = add i64 8, %67
  store i64 %68, i64* @LocalLC
  %commit66 = icmp ugt i64 %68, 5000
  br i1 %commit66, label %pushBlock68, label %postInstrumentation67

pushBlock68:                                      ; preds = %if_clock_enabled65
  %69 = add i32 %66, 1
  store i32 %69, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler69 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler69(i64 %68)
  %70 = load i32, i32* @lc_disabled_count
  %71 = sub i32 %70, 1
  store i32 %71, i32* @lc_disabled_count
  br label %postInstrumentation67

postInstrumentation67:                            ; preds = %if_clock_enabled65, %pushBlock68
  br label %postClockEnabledBlock70

postClockEnabledBlock70:                          ; preds = %while.body33.i, %postInstrumentation67
  br label %while.cond19.i

while.end35.i:                                    ; preds = %postClockEnabledBlock56, %postClockEnabledBlock56, %postClockEnabledBlock56
  %72 = trunc i64 %indvars.iv.i to i32
  %idxprom36.i = and i64 %indvars.iv.i, 4294967295
  %arrayidx37.i = getelementptr inbounds [50 x i8], [50 x i8]* %value, i64 0, i64 %idxprom36.i
  store i8 0, i8* %arrayidx37.i, align 1, !tbaa !397
  %cmp38.i = icmp eq i32 %72, 0
  %73 = load i32, i32* @lc_disabled_count
  %clock_running71 = icmp eq i32 %73, 0
  br i1 %clock_running71, label %if_clock_enabled72, label %postClockEnabledBlock77

if_clock_enabled72:                               ; preds = %while.end35.i
  %74 = load i64, i64* @LocalLC
  %75 = add i64 6, %74
  store i64 %75, i64* @LocalLC
  %commit73 = icmp ugt i64 %75, 5000
  br i1 %commit73, label %pushBlock75, label %postInstrumentation74

pushBlock75:                                      ; preds = %if_clock_enabled72
  %76 = add i32 %73, 1
  store i32 %76, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler76 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler76(i64 %75)
  %77 = load i32, i32* @lc_disabled_count
  %78 = sub i32 %77, 1
  store i32 %78, i32* @lc_disabled_count
  br label %postInstrumentation74

postInstrumentation74:                            ; preds = %if_clock_enabled72, %pushBlock75
  br label %postClockEnabledBlock77

postClockEnabledBlock77:                          ; preds = %while.end35.i, %postInstrumentation74
  br i1 %cmp38.i, label %if.then40.i, label %if.end

if.then40.i:                                      ; preds = %postClockEnabledBlock77
  store i8 0, i8* %0, align 16, !tbaa !397
  br label %cleanup

if.end:                                           ; preds = %postClockEnabledBlock77, %postClockEnabledBlock63
  %call1 = call i64 @strtol(i8* nocapture nonnull %0, i8** null, i32 10) #16
  %call2 = tail call i32* @__errno_location() #11
  %79 = load i32, i32* %call2, align 4, !tbaa !417
  %80 = load i32, i32* @lc_disabled_count
  %clock_running78 = icmp eq i32 %80, 0
  br i1 %clock_running78, label %if_clock_enabled79, label %postClockEnabledBlock84

if_clock_enabled79:                               ; preds = %if.end
  %81 = load i64, i64* @LocalLC
  %82 = add i64 4, %81
  store i64 %82, i64* @LocalLC
  %commit80 = icmp ugt i64 %82, 5000
  br i1 %commit80, label %pushBlock82, label %postInstrumentation81

pushBlock82:                                      ; preds = %if_clock_enabled79
  %83 = add i32 %80, 1
  store i32 %83, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler83 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler83(i64 %82)
  %84 = load i32, i32* @lc_disabled_count
  %85 = sub i32 %84, 1
  store i32 %85, i32* @lc_disabled_count
  br label %postInstrumentation81

postInstrumentation81:                            ; preds = %if_clock_enabled79, %pushBlock82
  br label %postClockEnabledBlock84

postClockEnabledBlock84:                          ; preds = %if.end, %postInstrumentation81
  switch i32 %79, label %if.end7 [
    i32 22, label %cleanup_dummy
    i32 34, label %cleanup_dummy
  ]

if.end7:                                          ; preds = %postClockEnabledBlock84
  %86 = load i32, i32* @lc_disabled_count
  %clock_running85 = icmp eq i32 %86, 0
  br i1 %clock_running85, label %if_clock_enabled86, label %postClockEnabledBlock91

if_clock_enabled86:                               ; preds = %if.end7
  %87 = load i64, i64* @LocalLC
  %88 = add i64 1, %87
  store i64 %88, i64* @LocalLC
  %commit87 = icmp ugt i64 %88, 5000
  br i1 %commit87, label %pushBlock89, label %postInstrumentation88

pushBlock89:                                      ; preds = %if_clock_enabled86
  %89 = add i32 %86, 1
  store i32 %89, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler90 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler90(i64 %88)
  %90 = load i32, i32* @lc_disabled_count
  %91 = sub i32 %90, 1
  store i32 %91, i32* @lc_disabled_count
  br label %postInstrumentation88

postInstrumentation88:                            ; preds = %if_clock_enabled86, %pushBlock89
  br label %postClockEnabledBlock91

postClockEnabledBlock91:                          ; preds = %if.end7, %postInstrumentation88
  br label %cleanup_dummy

cleanup_dummy:                                    ; preds = %postClockEnabledBlock84, %postClockEnabledBlock84, %postClockEnabledBlock91
  %retval.0.ph = phi i64 [ -1, %postClockEnabledBlock84 ], [ -1, %postClockEnabledBlock84 ], [ %call1, %postClockEnabledBlock91 ]
  br label %cleanup

cleanup:                                          ; preds = %cleanup_dummy, %if.then40.i, %if.then17.i, %if.then.i
  %retval.0 = phi i64 [ -1, %if.then.i ], [ -1, %if.then17.i ], [ -1, %if.then40.i ], [ %retval.0.ph, %cleanup_dummy ]
  call void @llvm.lifetime.end.p0i8(i64 50, i8* nonnull %0) #16
  ret i64 %retval.0
}

; Function Attrs: nofree nounwind uwtable
define i32 @http_parse_first_resp_line(i8* nocapture readonly %data, i32 %len, i32* nocapture %scode, i32* nocapture %ver) local_unnamed_addr #7 {
entry:
  %call = tail call i32 @strncmp(i8* %data, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.2.2, i64 0, i64 0), i64 4) #20
  %cmp = icmp eq i32 %call, 0
  br i1 %cmp, label %if.end, label %cleanup

if.end:                                           ; preds = %entry
  %add.ptr = getelementptr inbounds i8, i8* %data, i64 5
  %call1 = tail call i32 @strncmp(i8* nonnull %add.ptr, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.3.3, i64 0, i64 0), i64 3) #20
  %cmp2 = icmp eq i32 %call1, 0
  br i1 %cmp2, label %if.end9, label %if.else

if.else:                                          ; preds = %if.end
  %call4 = tail call i32 @strncmp(i8* nonnull %add.ptr, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.4.4, i64 0, i64 0), i64 3) #20
  %cmp5 = icmp eq i32 %call4, 0
  %. = zext i1 %cmp5 to i32
  br label %if.end9

if.end9:                                          ; preds = %if.else, %if.end
  %.sink = phi i32 [ 2, %if.end ], [ %., %if.else ]
  store i32 %.sink, i32* %ver, align 4, !tbaa !417
  %add.ptr10 = getelementptr inbounds i8, i8* %data, i64 9
  %call11 = tail call i64 @strtol(i8* nocapture nonnull %add.ptr10, i8** null, i32 10) #16
  %conv = trunc i64 %call11 to i32
  store i32 %conv, i32* %scode, align 4, !tbaa !417
  %call12 = tail call i32* @__errno_location() #11
  %0 = load i32, i32* %call12, align 4, !tbaa !417
  %1 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %1, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %if.end9
  %2 = load i64, i64* @LocalLC
  %3 = add i64 14, %2
  store i64 %3, i64* @LocalLC
  %commit = icmp ugt i64 %3, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %4 = add i32 %1, 1
  store i32 %4, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %3)
  %5 = load i32, i32* @lc_disabled_count
  %6 = sub i32 %5, 1
  store i32 %6, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %if.end9, %postInstrumentation
  switch i32 %0, label %if.end19 [
    i32 22, label %cleanup_dummy
    i32 34, label %cleanup_dummy
  ]

if.end19:                                         ; preds = %postClockEnabledBlock
  %7 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %7, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %if.end19
  %8 = load i64, i64* @LocalLC
  %9 = add i64 1, %8
  store i64 %9, i64* @LocalLC
  %commit3 = icmp ugt i64 %9, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %10 = add i32 %7, 1
  store i32 %10, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %9)
  %11 = load i32, i32* @lc_disabled_count
  %12 = sub i32 %11, 1
  store i32 %12, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %if.end19, %postInstrumentation4
  br label %cleanup_dummy

cleanup_dummy:                                    ; preds = %postClockEnabledBlock, %postClockEnabledBlock, %postClockEnabledBlock7
  %retval.0.ph = phi i32 [ 0, %postClockEnabledBlock ], [ 0, %postClockEnabledBlock ], [ 1, %postClockEnabledBlock7 ]
  %13 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %13, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %cleanup_dummy
  %14 = load i64, i64* @LocalLC
  %15 = add i64 1, %14
  store i64 %15, i64* @LocalLC
  %commit10 = icmp ugt i64 %15, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %16 = add i32 %13, 1
  store i32 %16, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %15)
  %17 = load i32, i32* @lc_disabled_count
  %18 = sub i32 %17, 1
  store i32 %18, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %cleanup_dummy, %postInstrumentation11
  br label %cleanup

cleanup:                                          ; preds = %postClockEnabledBlock14, %entry
  %retval.0 = phi i32 [ 0, %entry ], [ %retval.0.ph, %postClockEnabledBlock14 ]
  ret i32 %retval.0
}

; Function Attrs: nounwind uwtable
define i64 @http_header_date(i8* readonly %data, i8* nocapture readonly %field, i32 %len) local_unnamed_addr #0 {
entry:
  %buf = alloca [256 x i8], align 16
  %0 = getelementptr inbounds [256 x i8], [256 x i8]* %buf, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 256, i8* nonnull %0) #16
  %call.i.i = tail call i64 @strlen(i8* %field) #20
  %add.ptr11.i.i = getelementptr inbounds i8, i8* %field, i64 1
  %conv.i.i = shl i64 %call.i.i, 32
  %sext.i.i = add i64 %conv.i.i, -4294967296
  %conv12.i.i = ashr exact i64 %sext.i.i, 32
  br label %while.cond.i.i

while.cond.i.i:                                   ; preds = %postClockEnabledBlock21, %entry
  %p.0.i.i = phi i8* [ %data, %entry ], [ %incdec.ptr.i.i, %postClockEnabledBlock21 ]
  %1 = load i8, i8* %p.0.i.i, align 1, !tbaa !397
  %tobool.i.i = icmp eq i8 %1, 0
  %2 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %2, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %while.cond.i.i
  %3 = load i64, i64* @LocalLC
  %4 = add i64 3, %3
  store i64 %4, i64* @LocalLC
  %commit = icmp ugt i64 %4, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %5 = add i32 %2, 1
  store i32 %5, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %4)
  %6 = load i32, i32* @lc_disabled_count
  %7 = sub i32 %6, 1
  store i32 %7, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %while.cond.i.i, %postInstrumentation
  br i1 %tobool.i.i, label %if.then.i, label %land.rhs.lr.ph.i.i

land.rhs.lr.ph.i.i:                               ; preds = %postClockEnabledBlock
  %8 = load i8, i8* %field, align 1, !tbaa !397
  %9 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %9, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %land.rhs.lr.ph.i.i
  %10 = load i64, i64* @LocalLC
  %11 = add i64 2, %10
  store i64 %11, i64* @LocalLC
  %commit3 = icmp ugt i64 %11, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %12 = add i32 %9, 1
  store i32 %12, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %11)
  %13 = load i32, i32* @lc_disabled_count
  %14 = sub i32 %13, 1
  store i32 %14, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %land.rhs.lr.ph.i.i, %postInstrumentation4
  br label %land.rhs.i.i

land.rhs.i.i:                                     ; preds = %postClockEnabledBlock14, %postClockEnabledBlock7
  %p.132.i.i = phi i8* [ %p.0.i.i, %postClockEnabledBlock7 ], [ %incdec.ptr.i.i, %postClockEnabledBlock14 ]
  %15 = phi i8 [ %1, %postClockEnabledBlock7 ], [ %.pr.i.i, %postClockEnabledBlock14 ]
  %cmp.i.i = icmp eq i8 %15, %8
  %incdec.ptr.i.i = getelementptr inbounds i8, i8* %p.132.i.i, i64 1
  br i1 %cmp.i.i, label %if.end.i.i, label %while.body7.i.i

while.body7.i.i:                                  ; preds = %land.rhs.i.i
  %.pr.i.i = load i8, i8* %incdec.ptr.i.i, align 1, !tbaa !397
  %tobool3.i.i = icmp eq i8 %.pr.i.i, 0
  %16 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %16, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %while.body7.i.i
  %17 = load i64, i64* @LocalLC
  %18 = add i64 6, %17
  store i64 %18, i64* @LocalLC
  %commit10 = icmp ugt i64 %18, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %19 = add i32 %16, 1
  store i32 %19, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %18)
  %20 = load i32, i32* @lc_disabled_count
  %21 = sub i32 %20, 1
  store i32 %21, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %while.body7.i.i, %postInstrumentation11
  br i1 %tobool3.i.i, label %if.then.i, label %land.rhs.i.i

if.end.i.i:                                       ; preds = %land.rhs.i.i
  %call13.i.i = tail call i32 @strncasecmp(i8* nonnull %incdec.ptr.i.i, i8* nonnull %add.ptr11.i.i, i64 %conv12.i.i) #20
  %tobool14.i.i = icmp eq i32 %call13.i.i, 0
  %22 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %22, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %if.end.i.i
  %23 = load i64, i64* @LocalLC
  %24 = add i64 6, %23
  store i64 %24, i64* @LocalLC
  %commit17 = icmp ugt i64 %24, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %25 = add i32 %22, 1
  store i32 %25, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %24)
  %26 = load i32, i32* @lc_disabled_count
  %27 = sub i32 %26, 1
  store i32 %27, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %if.end.i.i, %postInstrumentation18
  br i1 %tobool14.i.i, label %nre_strcasestr.exit.i, label %while.cond.i.i

nre_strcasestr.exit.i:                            ; preds = %postClockEnabledBlock21
  %cmp.i = icmp eq i8* %p.132.i.i, null
  %28 = load i32, i32* @lc_disabled_count
  %clock_running22 = icmp eq i32 %28, 0
  br i1 %clock_running22, label %if_clock_enabled23, label %postClockEnabledBlock28

if_clock_enabled23:                               ; preds = %nre_strcasestr.exit.i
  %29 = load i64, i64* @LocalLC
  %30 = add i64 2, %29
  store i64 %30, i64* @LocalLC
  %commit24 = icmp ugt i64 %30, 5000
  br i1 %commit24, label %pushBlock26, label %postInstrumentation25

pushBlock26:                                      ; preds = %if_clock_enabled23
  %31 = add i32 %28, 1
  store i32 %31, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler27 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler27(i64 %30)
  %32 = load i32, i32* @lc_disabled_count
  %33 = sub i32 %32, 1
  store i32 %33, i32* @lc_disabled_count
  br label %postInstrumentation25

postInstrumentation25:                            ; preds = %if_clock_enabled23, %pushBlock26
  br label %postClockEnabledBlock28

postClockEnabledBlock28:                          ; preds = %nre_strcasestr.exit.i, %postInstrumentation25
  br i1 %cmp.i, label %if.then.i, label %if.end.i

if.then.i:                                        ; preds = %postClockEnabledBlock28, %postClockEnabledBlock14, %postClockEnabledBlock
  store i8 0, i8* %0, align 16, !tbaa !397
  br label %cleanup

if.end.i:                                         ; preds = %postClockEnabledBlock28
  %idx.ext.i = sext i32 %len to i64
  %add.ptr.i = getelementptr inbounds i8, i8* %p.132.i.i, i64 %idx.ext.i
  %34 = load i32, i32* @lc_disabled_count
  %clock_running29 = icmp eq i32 %34, 0
  br i1 %clock_running29, label %if_clock_enabled30, label %postClockEnabledBlock35

if_clock_enabled30:                               ; preds = %if.end.i
  %35 = load i64, i64* @LocalLC
  %36 = add i64 3, %35
  store i64 %36, i64* @LocalLC
  %commit31 = icmp ugt i64 %36, 5000
  br i1 %commit31, label %pushBlock33, label %postInstrumentation32

pushBlock33:                                      ; preds = %if_clock_enabled30
  %37 = add i32 %34, 1
  store i32 %37, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler34 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler34(i64 %36)
  %38 = load i32, i32* @lc_disabled_count
  %39 = sub i32 %38, 1
  store i32 %39, i32* @lc_disabled_count
  br label %postInstrumentation32

postInstrumentation32:                            ; preds = %if_clock_enabled30, %pushBlock33
  br label %postClockEnabledBlock35

postClockEnabledBlock35:                          ; preds = %if.end.i, %postInstrumentation32
  br label %while.cond.i

while.cond.i:                                     ; preds = %postClockEnabledBlock49, %postClockEnabledBlock35
  %temp.0.i = phi i8* [ %add.ptr.i, %postClockEnabledBlock35 ], [ %incdec.ptr.i, %postClockEnabledBlock49 ]
  %40 = load i8, i8* %temp.0.i, align 1, !tbaa !397
  %41 = load i32, i32* @lc_disabled_count
  %clock_running36 = icmp eq i32 %41, 0
  br i1 %clock_running36, label %if_clock_enabled37, label %postClockEnabledBlock42

if_clock_enabled37:                               ; preds = %while.cond.i
  %42 = load i64, i64* @LocalLC
  %43 = add i64 2, %42
  store i64 %43, i64* @LocalLC
  %commit38 = icmp ugt i64 %43, 5000
  br i1 %commit38, label %pushBlock40, label %postInstrumentation39

pushBlock40:                                      ; preds = %if_clock_enabled37
  %44 = add i32 %41, 1
  store i32 %44, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler41 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler41(i64 %43)
  %45 = load i32, i32* @lc_disabled_count
  %46 = sub i32 %45, 1
  store i32 %46, i32* @lc_disabled_count
  br label %postInstrumentation39

postInstrumentation39:                            ; preds = %if_clock_enabled37, %pushBlock40
  br label %postClockEnabledBlock42

postClockEnabledBlock42:                          ; preds = %while.cond.i, %postInstrumentation39
  switch i8 %40, label %while.cond19.i [
    i8 9, label %while.body.i
    i8 32, label %while.body.i
    i8 0, label %if.then17.i
    i8 13, label %if.then17.i
    i8 10, label %if.then17.i
  ]

while.body.i:                                     ; preds = %postClockEnabledBlock42, %postClockEnabledBlock42
  %incdec.ptr.i = getelementptr inbounds i8, i8* %temp.0.i, i64 1
  %47 = load i32, i32* @lc_disabled_count
  %clock_running43 = icmp eq i32 %47, 0
  br i1 %clock_running43, label %if_clock_enabled44, label %postClockEnabledBlock49

if_clock_enabled44:                               ; preds = %while.body.i
  %48 = load i64, i64* @LocalLC
  %49 = add i64 2, %48
  store i64 %49, i64* @LocalLC
  %commit45 = icmp ugt i64 %49, 5000
  br i1 %commit45, label %pushBlock47, label %postInstrumentation46

pushBlock47:                                      ; preds = %if_clock_enabled44
  %50 = add i32 %47, 1
  store i32 %50, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler48 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler48(i64 %49)
  %51 = load i32, i32* @lc_disabled_count
  %52 = sub i32 %51, 1
  store i32 %52, i32* @lc_disabled_count
  br label %postInstrumentation46

postInstrumentation46:                            ; preds = %if_clock_enabled44, %pushBlock47
  br label %postClockEnabledBlock49

postClockEnabledBlock49:                          ; preds = %while.body.i, %postInstrumentation46
  br label %while.cond.i

if.then17.i:                                      ; preds = %postClockEnabledBlock42, %postClockEnabledBlock42, %postClockEnabledBlock42
  store i8 0, i8* %0, align 16, !tbaa !397
  br label %cleanup

while.cond19.i:                                   ; preds = %postClockEnabledBlock70, %postClockEnabledBlock42
  %indvars.iv.i = phi i64 [ %indvars.iv.next.i, %postClockEnabledBlock70 ], [ 0, %postClockEnabledBlock42 ]
  %53 = phi i8 [ %.pr.i, %postClockEnabledBlock70 ], [ %40, %postClockEnabledBlock42 ]
  %temp.1.i = phi i8* [ %incdec.ptr34.i, %postClockEnabledBlock70 ], [ %temp.0.i, %postClockEnabledBlock42 ]
  %54 = load i32, i32* @lc_disabled_count
  %clock_running50 = icmp eq i32 %54, 0
  br i1 %clock_running50, label %if_clock_enabled51, label %postClockEnabledBlock56

if_clock_enabled51:                               ; preds = %while.cond19.i
  %55 = load i64, i64* @LocalLC
  %56 = add i64 1, %55
  store i64 %56, i64* @LocalLC
  %commit52 = icmp ugt i64 %56, 5000
  br i1 %commit52, label %pushBlock54, label %postInstrumentation53

pushBlock54:                                      ; preds = %if_clock_enabled51
  %57 = add i32 %54, 1
  store i32 %57, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler55 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler55(i64 %56)
  %58 = load i32, i32* @lc_disabled_count
  %59 = sub i32 %58, 1
  store i32 %59, i32* @lc_disabled_count
  br label %postInstrumentation53

postInstrumentation53:                            ; preds = %if_clock_enabled51, %pushBlock54
  br label %postClockEnabledBlock56

postClockEnabledBlock56:                          ; preds = %while.cond19.i, %postInstrumentation53
  switch i8 %53, label %land.rhs29.i [
    i8 0, label %while.end35.i
    i8 13, label %while.end35.i
    i8 10, label %while.end35.i
  ]

land.rhs29.i:                                     ; preds = %postClockEnabledBlock56
  %exitcond = icmp eq i64 %indvars.iv.i, 255
  br i1 %exitcond, label %while.end35.i.thread, label %while.body33.i

while.end35.i.thread:                             ; preds = %land.rhs29.i
  %arrayidx37.i17 = getelementptr inbounds [256 x i8], [256 x i8]* %buf, i64 0, i64 255
  store i8 0, i8* %arrayidx37.i17, align 1, !tbaa !397
  %60 = load i32, i32* @lc_disabled_count
  %clock_running57 = icmp eq i32 %60, 0
  br i1 %clock_running57, label %if_clock_enabled58, label %postClockEnabledBlock63

if_clock_enabled58:                               ; preds = %while.end35.i.thread
  %61 = load i64, i64* @LocalLC
  %62 = add i64 5, %61
  store i64 %62, i64* @LocalLC
  %commit59 = icmp ugt i64 %62, 5000
  br i1 %commit59, label %pushBlock61, label %postInstrumentation60

pushBlock61:                                      ; preds = %if_clock_enabled58
  %63 = add i32 %60, 1
  store i32 %63, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler62 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler62(i64 %62)
  %64 = load i32, i32* @lc_disabled_count
  %65 = sub i32 %64, 1
  store i32 %65, i32* @lc_disabled_count
  br label %postInstrumentation60

postInstrumentation60:                            ; preds = %if_clock_enabled58, %pushBlock61
  br label %postClockEnabledBlock63

postClockEnabledBlock63:                          ; preds = %while.end35.i.thread, %postInstrumentation60
  br label %if.end

while.body33.i:                                   ; preds = %land.rhs29.i
  %incdec.ptr34.i = getelementptr inbounds i8, i8* %temp.1.i, i64 1
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  %arrayidx.i = getelementptr inbounds [256 x i8], [256 x i8]* %buf, i64 0, i64 %indvars.iv.i
  store i8 %53, i8* %arrayidx.i, align 1, !tbaa !397
  %.pr.i = load i8, i8* %incdec.ptr34.i, align 1, !tbaa !397
  %66 = load i32, i32* @lc_disabled_count
  %clock_running64 = icmp eq i32 %66, 0
  br i1 %clock_running64, label %if_clock_enabled65, label %postClockEnabledBlock70

if_clock_enabled65:                               ; preds = %while.body33.i
  %67 = load i64, i64* @LocalLC
  %68 = add i64 8, %67
  store i64 %68, i64* @LocalLC
  %commit66 = icmp ugt i64 %68, 5000
  br i1 %commit66, label %pushBlock68, label %postInstrumentation67

pushBlock68:                                      ; preds = %if_clock_enabled65
  %69 = add i32 %66, 1
  store i32 %69, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler69 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler69(i64 %68)
  %70 = load i32, i32* @lc_disabled_count
  %71 = sub i32 %70, 1
  store i32 %71, i32* @lc_disabled_count
  br label %postInstrumentation67

postInstrumentation67:                            ; preds = %if_clock_enabled65, %pushBlock68
  br label %postClockEnabledBlock70

postClockEnabledBlock70:                          ; preds = %while.body33.i, %postInstrumentation67
  br label %while.cond19.i

while.end35.i:                                    ; preds = %postClockEnabledBlock56, %postClockEnabledBlock56, %postClockEnabledBlock56
  %72 = trunc i64 %indvars.iv.i to i32
  %idxprom36.i = and i64 %indvars.iv.i, 4294967295
  %arrayidx37.i = getelementptr inbounds [256 x i8], [256 x i8]* %buf, i64 0, i64 %idxprom36.i
  store i8 0, i8* %arrayidx37.i, align 1, !tbaa !397
  %cmp38.i = icmp eq i32 %72, 0
  %73 = load i32, i32* @lc_disabled_count
  %clock_running71 = icmp eq i32 %73, 0
  br i1 %clock_running71, label %if_clock_enabled72, label %postClockEnabledBlock77

if_clock_enabled72:                               ; preds = %while.end35.i
  %74 = load i64, i64* @LocalLC
  %75 = add i64 6, %74
  store i64 %75, i64* @LocalLC
  %commit73 = icmp ugt i64 %75, 5000
  br i1 %commit73, label %pushBlock75, label %postInstrumentation74

pushBlock75:                                      ; preds = %if_clock_enabled72
  %76 = add i32 %73, 1
  store i32 %76, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler76 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler76(i64 %75)
  %77 = load i32, i32* @lc_disabled_count
  %78 = sub i32 %77, 1
  store i32 %78, i32* @lc_disabled_count
  br label %postInstrumentation74

postInstrumentation74:                            ; preds = %if_clock_enabled72, %pushBlock75
  br label %postClockEnabledBlock77

postClockEnabledBlock77:                          ; preds = %while.end35.i, %postInstrumentation74
  br i1 %cmp38.i, label %if.then40.i, label %if.end

if.then40.i:                                      ; preds = %postClockEnabledBlock77
  store i8 0, i8* %0, align 16, !tbaa !397
  br label %cleanup

if.end:                                           ; preds = %postClockEnabledBlock77, %postClockEnabledBlock63
  %call2 = call i64 @httpdate_to_timet(i8* nonnull %0) #16
  br label %cleanup

cleanup:                                          ; preds = %if.end, %if.then40.i, %if.then17.i, %if.then.i
  %retval.0 = phi i64 [ %call2, %if.end ], [ -1, %if.then.i ], [ -1, %if.then17.i ], [ -1, %if.then40.i ]
  call void @llvm.lifetime.end.p0i8(i64 256, i8* nonnull %0) #16
  ret i64 %retval.0
}

; Function Attrs: nounwind readonly uwtable
define i32 @http_check_header_field(i8* readonly %data, i8* nocapture readonly %field) local_unnamed_addr #13 {
entry:
  %call.i = tail call i64 @strlen(i8* %field) #20
  %add.ptr11.i = getelementptr inbounds i8, i8* %field, i64 1
  %conv.i = shl i64 %call.i, 32
  %sext.i = add i64 %conv.i, -4294967296
  %conv12.i = ashr exact i64 %sext.i, 32
  br label %while.cond.i

while.cond.i:                                     ; preds = %postClockEnabledBlock21, %entry
  %p.0.i = phi i8* [ %data, %entry ], [ %incdec.ptr.i, %postClockEnabledBlock21 ]
  %0 = load i8, i8* %p.0.i, align 1, !tbaa !397
  %tobool.i = icmp eq i8 %0, 0
  %1 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %1, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %while.cond.i
  %2 = load i64, i64* @LocalLC
  %3 = add i64 3, %2
  store i64 %3, i64* @LocalLC
  %commit = icmp ugt i64 %3, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %4 = add i32 %1, 1
  store i32 %4, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %3)
  %5 = load i32, i32* @lc_disabled_count
  %6 = sub i32 %5, 1
  store i32 %6, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %while.cond.i, %postInstrumentation
  br i1 %tobool.i, label %nre_strcasestr.exit, label %land.rhs.lr.ph.i

land.rhs.lr.ph.i:                                 ; preds = %postClockEnabledBlock
  %7 = load i8, i8* %field, align 1, !tbaa !397
  %8 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %8, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %land.rhs.lr.ph.i
  %9 = load i64, i64* @LocalLC
  %10 = add i64 2, %9
  store i64 %10, i64* @LocalLC
  %commit3 = icmp ugt i64 %10, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %11 = add i32 %8, 1
  store i32 %11, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %10)
  %12 = load i32, i32* @lc_disabled_count
  %13 = sub i32 %12, 1
  store i32 %13, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %land.rhs.lr.ph.i, %postInstrumentation4
  br label %land.rhs.i

land.rhs.i:                                       ; preds = %postClockEnabledBlock14, %postClockEnabledBlock7
  %p.132.i = phi i8* [ %p.0.i, %postClockEnabledBlock7 ], [ %incdec.ptr.i, %postClockEnabledBlock14 ]
  %14 = phi i8 [ %0, %postClockEnabledBlock7 ], [ %.pr.i, %postClockEnabledBlock14 ]
  %cmp.i = icmp eq i8 %14, %7
  %incdec.ptr.i = getelementptr inbounds i8, i8* %p.132.i, i64 1
  br i1 %cmp.i, label %if.end.i, label %while.body7.i

while.body7.i:                                    ; preds = %land.rhs.i
  %.pr.i = load i8, i8* %incdec.ptr.i, align 1, !tbaa !397
  %tobool3.i = icmp eq i8 %.pr.i, 0
  %15 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %15, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %while.body7.i
  %16 = load i64, i64* @LocalLC
  %17 = add i64 6, %16
  store i64 %17, i64* @LocalLC
  %commit10 = icmp ugt i64 %17, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %18 = add i32 %15, 1
  store i32 %18, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %17)
  %19 = load i32, i32* @lc_disabled_count
  %20 = sub i32 %19, 1
  store i32 %20, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %while.body7.i, %postInstrumentation11
  br i1 %tobool3.i, label %nre_strcasestr.exit, label %land.rhs.i

if.end.i:                                         ; preds = %land.rhs.i
  %call13.i = tail call i32 @strncasecmp(i8* nonnull %incdec.ptr.i, i8* nonnull %add.ptr11.i, i64 %conv12.i) #20
  %tobool14.i = icmp eq i32 %call13.i, 0
  %21 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %21, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %if.end.i
  %22 = load i64, i64* @LocalLC
  %23 = add i64 6, %22
  store i64 %23, i64* @LocalLC
  %commit17 = icmp ugt i64 %23, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %24 = add i32 %21, 1
  store i32 %24, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %23)
  %25 = load i32, i32* @lc_disabled_count
  %26 = sub i32 %25, 1
  store i32 %26, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %if.end.i, %postInstrumentation18
  br i1 %tobool14.i, label %nre_strcasestr.exit, label %while.cond.i

nre_strcasestr.exit:                              ; preds = %postClockEnabledBlock21, %postClockEnabledBlock14, %postClockEnabledBlock
  %retval.0.i = phi i8* [ null, %postClockEnabledBlock14 ], [ %p.132.i, %postClockEnabledBlock21 ], [ null, %postClockEnabledBlock ]
  %tobool = icmp ne i8* %retval.0.i, null
  %. = zext i1 %tobool to i32
  ret i32 %.
}

; Function Attrs: nofree nounwind uwtable
define i8* @http_get_http_version_resp(i8* nocapture readonly %data, i32 %len, i8* %value, i32 %value_len) local_unnamed_addr #7 {
entry:
  %cmp = icmp ult i32 %len, 4
  br i1 %cmp, label %cleanup, label %if.end

if.end:                                           ; preds = %entry
  %call = tail call i32 @strncmp(i8* %data, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.2.2, i64 0, i64 0), i64 4) #20
  %tobool = icmp eq i32 %call, 0
  %0 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %0, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %if.end
  %1 = load i64, i64* @LocalLC
  %2 = add i64 3, %1
  store i64 %2, i64* @LocalLC
  %commit = icmp ugt i64 %2, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %3 = add i32 %0, 1
  store i32 %3, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %2)
  %4 = load i32, i32* @lc_disabled_count
  %5 = sub i32 %4, 1
  store i32 %5, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %if.end, %postInstrumentation
  br i1 %tobool, label %while.cond.preheader, label %cleanup_dummy

while.cond.preheader:                             ; preds = %postClockEnabledBlock
  %sub = add nsw i32 %value_len, -1
  %6 = sext i32 %sub to i64
  %7 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %7, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %while.cond.preheader
  %8 = load i64, i64* @LocalLC
  %9 = add i64 3, %8
  store i64 %9, i64* @LocalLC
  %commit3 = icmp ugt i64 %9, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %10 = add i32 %7, 1
  store i32 %10, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %9)
  %11 = load i32, i32* @lc_disabled_count
  %12 = sub i32 %11, 1
  store i32 %12, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %while.cond.preheader, %postInstrumentation4
  br label %while.cond

while.cond:                                       ; preds = %postClockEnabledBlock28, %postClockEnabledBlock7
  %indvars.iv = phi i64 [ 0, %postClockEnabledBlock7 ], [ %indvars.iv.next, %postClockEnabledBlock28 ]
  %temp.0 = phi i8* [ %data, %postClockEnabledBlock7 ], [ %incdec.ptr, %postClockEnabledBlock28 ]
  %13 = load i8, i8* %temp.0, align 1, !tbaa !397
  %14 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %14, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %while.cond
  %15 = load i64, i64* @LocalLC
  %16 = add i64 2, %15
  store i64 %16, i64* @LocalLC
  %commit10 = icmp ugt i64 %16, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %17 = add i32 %14, 1
  store i32 %17, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %16)
  %18 = load i32, i32* @lc_disabled_count
  %19 = sub i32 %18, 1
  store i32 %19, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %while.cond, %postInstrumentation11
  switch i8 %13, label %land.rhs [
    i8 0, label %while.end
    i8 32, label %while.end
    i8 9, label %while.end
  ]

land.rhs:                                         ; preds = %postClockEnabledBlock14
  %cmp12 = icmp slt i64 %indvars.iv, %6
  %20 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %20, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %land.rhs
  %21 = load i64, i64* @LocalLC
  %22 = add i64 2, %21
  store i64 %22, i64* @LocalLC
  %commit17 = icmp ugt i64 %22, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %23 = add i32 %20, 1
  store i32 %23, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %22)
  %24 = load i32, i32* @lc_disabled_count
  %25 = sub i32 %24, 1
  store i32 %25, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %land.rhs, %postInstrumentation18
  br i1 %cmp12, label %while.body, label %while.end

while.body:                                       ; preds = %postClockEnabledBlock21
  %incdec.ptr = getelementptr inbounds i8, i8* %temp.0, i64 1
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %arrayidx = getelementptr inbounds i8, i8* %value, i64 %indvars.iv
  store i8 %13, i8* %arrayidx, align 1, !tbaa !397
  %26 = load i32, i32* @lc_disabled_count
  %clock_running22 = icmp eq i32 %26, 0
  br i1 %clock_running22, label %if_clock_enabled23, label %postClockEnabledBlock28

if_clock_enabled23:                               ; preds = %while.body
  %27 = load i64, i64* @LocalLC
  %28 = add i64 5, %27
  store i64 %28, i64* @LocalLC
  %commit24 = icmp ugt i64 %28, 5000
  br i1 %commit24, label %pushBlock26, label %postInstrumentation25

pushBlock26:                                      ; preds = %if_clock_enabled23
  %29 = add i32 %26, 1
  store i32 %29, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler27 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler27(i64 %28)
  %30 = load i32, i32* @lc_disabled_count
  %31 = sub i32 %30, 1
  store i32 %31, i32* @lc_disabled_count
  br label %postInstrumentation25

postInstrumentation25:                            ; preds = %if_clock_enabled23, %pushBlock26
  br label %postClockEnabledBlock28

postClockEnabledBlock28:                          ; preds = %while.body, %postInstrumentation25
  br label %while.cond

while.end:                                        ; preds = %postClockEnabledBlock21, %postClockEnabledBlock14, %postClockEnabledBlock14, %postClockEnabledBlock14
  %idxprom14 = and i64 %indvars.iv, 4294967295
  %arrayidx15 = getelementptr inbounds i8, i8* %value, i64 %idxprom14
  %32 = load i32, i32* @lc_disabled_count
  %clock_running29 = icmp eq i32 %32, 0
  br i1 %clock_running29, label %if_clock_enabled30, label %postClockEnabledBlock35

if_clock_enabled30:                               ; preds = %while.end
  %33 = load i64, i64* @LocalLC
  %34 = add i64 3, %33
  store i64 %34, i64* @LocalLC
  %commit31 = icmp ugt i64 %34, 5000
  br i1 %commit31, label %pushBlock33, label %postInstrumentation32

pushBlock33:                                      ; preds = %if_clock_enabled30
  %35 = add i32 %32, 1
  store i32 %35, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler34 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler34(i64 %34)
  %36 = load i32, i32* @lc_disabled_count
  %37 = sub i32 %36, 1
  store i32 %37, i32* @lc_disabled_count
  br label %postInstrumentation32

postInstrumentation32:                            ; preds = %if_clock_enabled30, %pushBlock33
  br label %postClockEnabledBlock35

postClockEnabledBlock35:                          ; preds = %while.end, %postInstrumentation32
  br label %cleanup_dummy

cleanup_dummy:                                    ; preds = %postClockEnabledBlock, %postClockEnabledBlock35
  %arrayidx15.sink.ph = phi i8* [ %value, %postClockEnabledBlock ], [ %arrayidx15, %postClockEnabledBlock35 ]
  %retval.0.ph = phi i8* [ null, %postClockEnabledBlock ], [ %value, %postClockEnabledBlock35 ]
  %38 = load i32, i32* @lc_disabled_count
  %clock_running36 = icmp eq i32 %38, 0
  br i1 %clock_running36, label %if_clock_enabled37, label %postClockEnabledBlock42

if_clock_enabled37:                               ; preds = %cleanup_dummy
  %39 = load i64, i64* @LocalLC
  %40 = add i64 1, %39
  store i64 %40, i64* @LocalLC
  %commit38 = icmp ugt i64 %40, 5000
  br i1 %commit38, label %pushBlock40, label %postInstrumentation39

pushBlock40:                                      ; preds = %if_clock_enabled37
  %41 = add i32 %38, 1
  store i32 %41, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler41 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler41(i64 %40)
  %42 = load i32, i32* @lc_disabled_count
  %43 = sub i32 %42, 1
  store i32 %43, i32* @lc_disabled_count
  br label %postInstrumentation39

postInstrumentation39:                            ; preds = %if_clock_enabled37, %pushBlock40
  br label %postClockEnabledBlock42

postClockEnabledBlock42:                          ; preds = %cleanup_dummy, %postInstrumentation39
  br label %cleanup

cleanup:                                          ; preds = %postClockEnabledBlock42, %entry
  %arrayidx15.sink = phi i8* [ %value, %entry ], [ %arrayidx15.sink.ph, %postClockEnabledBlock42 ]
  %retval.0 = phi i8* [ null, %entry ], [ %retval.0.ph, %postClockEnabledBlock42 ]
  store i8 0, i8* %arrayidx15.sink, align 1, !tbaa !397
  ret i8* %retval.0
}

; Function Attrs: nofree nounwind uwtable
define i8* @http_get_url(i8* readonly %data, i32 %data_len, i8* nocapture %value, i32 %value_len) local_unnamed_addr #7 {
entry:
  %call = tail call i32 @strncmp(i8* %data, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i64 3) #20
  %tobool = icmp eq i32 %call, 0
  br i1 %tobool, label %if.end, label %cleanup

if.end:                                           ; preds = %entry
  %add.ptr = getelementptr inbounds i8, i8* %data, i64 4
  br label %while.cond

while.cond:                                       ; preds = %while.body, %if.end
  %ret.0 = phi i8* [ %add.ptr, %if.end ], [ %incdec.ptr, %while.body ]
  %0 = load i8, i8* %ret.0, align 1, !tbaa !397
  %1 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %1, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %while.cond
  %2 = load i64, i64* @LocalLC
  %3 = add i64 6, %2
  store i64 %3, i64* @LocalLC
  %commit = icmp ugt i64 %3, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %4 = add i32 %1, 1
  store i32 %4, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %3)
  %5 = load i32, i32* @lc_disabled_count
  %6 = sub i32 %5, 1
  store i32 %6, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %while.cond, %postInstrumentation
  switch i8 %0, label %while.cond7.preheader [
    i8 9, label %while.body
    i8 32, label %while.body
  ]

while.cond7.preheader:                            ; preds = %postClockEnabledBlock
  %sub = add nsw i32 %value_len, -1
  %7 = sext i32 %sub to i64
  %8 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %8, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %while.cond7.preheader
  %9 = load i64, i64* @LocalLC
  %10 = add i64 7, %9
  store i64 %10, i64* @LocalLC
  %commit3 = icmp ugt i64 %10, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %11 = add i32 %8, 1
  store i32 %11, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %10)
  %12 = load i32, i32* @lc_disabled_count
  %13 = sub i32 %12, 1
  store i32 %13, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %while.cond7.preheader, %postInstrumentation4
  br label %while.cond7

while.body:                                       ; preds = %postClockEnabledBlock, %postClockEnabledBlock
  %incdec.ptr = getelementptr inbounds i8, i8* %ret.0, i64 1
  br label %while.cond

while.cond7:                                      ; preds = %postClockEnabledBlock28, %postClockEnabledBlock7
  %indvars.iv = phi i64 [ 0, %postClockEnabledBlock7 ], [ %indvars.iv.next, %postClockEnabledBlock28 ]
  %14 = phi i8 [ %0, %postClockEnabledBlock7 ], [ %.pr, %postClockEnabledBlock28 ]
  %temp.0 = phi i8* [ %ret.0, %postClockEnabledBlock7 ], [ %incdec.ptr18, %postClockEnabledBlock28 ]
  %15 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %15, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %while.cond7
  %16 = load i64, i64* @LocalLC
  %17 = add i64 1, %16
  store i64 %17, i64* @LocalLC
  %commit10 = icmp ugt i64 %17, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %18 = add i32 %15, 1
  store i32 %18, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %17)
  %19 = load i32, i32* @lc_disabled_count
  %20 = sub i32 %19, 1
  store i32 %20, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %while.cond7, %postInstrumentation11
  switch i8 %14, label %land.rhs13 [
    i8 0, label %while.end19
    i8 32, label %while.end19
  ]

land.rhs13:                                       ; preds = %postClockEnabledBlock14
  %cmp14 = icmp slt i64 %indvars.iv, %7
  %21 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %21, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %land.rhs13
  %22 = load i64, i64* @LocalLC
  %23 = add i64 2, %22
  store i64 %23, i64* @LocalLC
  %commit17 = icmp ugt i64 %23, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %24 = add i32 %21, 1
  store i32 %24, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %23)
  %25 = load i32, i32* @lc_disabled_count
  %26 = sub i32 %25, 1
  store i32 %26, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %land.rhs13, %postInstrumentation18
  br i1 %cmp14, label %while.body17, label %while.end19

while.body17:                                     ; preds = %postClockEnabledBlock21
  %incdec.ptr18 = getelementptr inbounds i8, i8* %temp.0, i64 1
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %arrayidx = getelementptr inbounds i8, i8* %value, i64 %indvars.iv
  store i8 %14, i8* %arrayidx, align 1, !tbaa !397
  %.pr = load i8, i8* %incdec.ptr18, align 1, !tbaa !397
  %27 = load i32, i32* @lc_disabled_count
  %clock_running22 = icmp eq i32 %27, 0
  br i1 %clock_running22, label %if_clock_enabled23, label %postClockEnabledBlock28

if_clock_enabled23:                               ; preds = %while.body17
  %28 = load i64, i64* @LocalLC
  %29 = add i64 6, %28
  store i64 %29, i64* @LocalLC
  %commit24 = icmp ugt i64 %29, 5000
  br i1 %commit24, label %pushBlock26, label %postInstrumentation25

pushBlock26:                                      ; preds = %if_clock_enabled23
  %30 = add i32 %27, 1
  store i32 %30, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler27 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler27(i64 %29)
  %31 = load i32, i32* @lc_disabled_count
  %32 = sub i32 %31, 1
  store i32 %32, i32* @lc_disabled_count
  br label %postInstrumentation25

postInstrumentation25:                            ; preds = %if_clock_enabled23, %pushBlock26
  br label %postClockEnabledBlock28

postClockEnabledBlock28:                          ; preds = %while.body17, %postInstrumentation25
  br label %while.cond7

while.end19:                                      ; preds = %postClockEnabledBlock21, %postClockEnabledBlock14, %postClockEnabledBlock14
  %idxprom20 = and i64 %indvars.iv, 4294967295
  %arrayidx21 = getelementptr inbounds i8, i8* %value, i64 %idxprom20
  %33 = load i32, i32* @lc_disabled_count
  %clock_running29 = icmp eq i32 %33, 0
  br i1 %clock_running29, label %if_clock_enabled30, label %postClockEnabledBlock35

if_clock_enabled30:                               ; preds = %while.end19
  %34 = load i64, i64* @LocalLC
  %35 = add i64 3, %34
  store i64 %35, i64* @LocalLC
  %commit31 = icmp ugt i64 %35, 5000
  br i1 %commit31, label %pushBlock33, label %postInstrumentation32

pushBlock33:                                      ; preds = %if_clock_enabled30
  %36 = add i32 %33, 1
  store i32 %36, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler34 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler34(i64 %35)
  %37 = load i32, i32* @lc_disabled_count
  %38 = sub i32 %37, 1
  store i32 %38, i32* @lc_disabled_count
  br label %postInstrumentation32

postInstrumentation32:                            ; preds = %if_clock_enabled30, %pushBlock33
  br label %postClockEnabledBlock35

postClockEnabledBlock35:                          ; preds = %while.end19, %postInstrumentation32
  br label %cleanup

cleanup:                                          ; preds = %postClockEnabledBlock35, %entry
  %arrayidx21.sink = phi i8* [ %arrayidx21, %postClockEnabledBlock35 ], [ %value, %entry ]
  %retval.0 = phi i8* [ %ret.0, %postClockEnabledBlock35 ], [ null, %entry ]
  store i8 0, i8* %arrayidx21.sink, align 1, !tbaa !397
  ret i8* %retval.0
}

; Function Attrs: nofree nounwind uwtable
define i32 @http_get_status_code(i8* nocapture readonly %response) local_unnamed_addr #7 {
entry:
  br label %while.cond

while.cond:                                       ; preds = %postClockEnabledBlock14, %entry
  %temp.0 = phi i8* [ %response, %entry ], [ %incdec.ptr3, %postClockEnabledBlock14 ]
  %0 = load i8, i8* %temp.0, align 1, !tbaa !397
  %tobool = icmp eq i8 %0, 0
  %1 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %1, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %while.cond
  %2 = load i64, i64* @LocalLC
  %3 = add i64 3, %2
  store i64 %3, i64* @LocalLC
  %commit = icmp ugt i64 %3, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %4 = add i32 %1, 1
  store i32 %4, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %3)
  %5 = load i32, i32* @lc_disabled_count
  %6 = sub i32 %5, 1
  store i32 %6, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %while.cond, %postInstrumentation
  br i1 %tobool, label %while.end, label %land.rhs

land.rhs:                                         ; preds = %postClockEnabledBlock
  %incdec.ptr = getelementptr inbounds i8, i8* %temp.0, i64 1
  %cmp = icmp eq i8 %0, 32
  %7 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %7, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %land.rhs
  %8 = load i64, i64* @LocalLC
  %9 = add i64 3, %8
  store i64 %9, i64* @LocalLC
  %commit3 = icmp ugt i64 %9, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %10 = add i32 %7, 1
  store i32 %10, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %9)
  %11 = load i32, i32* @lc_disabled_count
  %12 = sub i32 %11, 1
  store i32 %12, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %land.rhs, %postInstrumentation4
  br i1 %cmp, label %while.end, label %lor.end

lor.end:                                          ; preds = %postClockEnabledBlock7
  %incdec.ptr3 = getelementptr inbounds i8, i8* %temp.0, i64 2
  %13 = load i8, i8* %incdec.ptr, align 1, !tbaa !397
  %cmp5 = icmp eq i8 %13, 9
  %14 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %14, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %lor.end
  %15 = load i64, i64* @LocalLC
  %16 = add i64 4, %15
  store i64 %16, i64* @LocalLC
  %commit10 = icmp ugt i64 %16, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %17 = add i32 %14, 1
  store i32 %17, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %16)
  %18 = load i32, i32* @lc_disabled_count
  %19 = sub i32 %18, 1
  store i32 %19, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %lor.end, %postInstrumentation11
  br i1 %cmp5, label %while.end, label %while.cond

while.end:                                        ; preds = %postClockEnabledBlock14, %postClockEnabledBlock7, %postClockEnabledBlock
  %temp.2 = phi i8* [ %incdec.ptr3, %postClockEnabledBlock14 ], [ %temp.0, %postClockEnabledBlock ], [ %incdec.ptr, %postClockEnabledBlock7 ]
  %call = tail call i64 @strtol(i8* nocapture %temp.2, i8** null, i32 10) #16
  %call8 = tail call i32* @__errno_location() #11
  %20 = load i32, i32* %call8, align 4, !tbaa !417
  %21 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %21, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %while.end
  %22 = load i64, i64* @LocalLC
  %23 = add i64 4, %22
  store i64 %23, i64* @LocalLC
  %commit17 = icmp ugt i64 %23, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %24 = add i32 %21, 1
  store i32 %24, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %23)
  %25 = load i32, i32* @lc_disabled_count
  %26 = sub i32 %25, 1
  store i32 %26, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %while.end, %postInstrumentation18
  switch i32 %20, label %if.end [
    i32 22, label %cleanup
    i32 34, label %cleanup
  ]

if.end:                                           ; preds = %postClockEnabledBlock21
  %conv7 = trunc i64 %call to i32
  %27 = load i32, i32* @lc_disabled_count
  %clock_running22 = icmp eq i32 %27, 0
  br i1 %clock_running22, label %if_clock_enabled23, label %postClockEnabledBlock28

if_clock_enabled23:                               ; preds = %if.end
  %28 = load i64, i64* @LocalLC
  %29 = add i64 2, %28
  store i64 %29, i64* @LocalLC
  %commit24 = icmp ugt i64 %29, 5000
  br i1 %commit24, label %pushBlock26, label %postInstrumentation25

pushBlock26:                                      ; preds = %if_clock_enabled23
  %30 = add i32 %27, 1
  store i32 %30, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler27 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler27(i64 %29)
  %31 = load i32, i32* @lc_disabled_count
  %32 = sub i32 %31, 1
  store i32 %32, i32* @lc_disabled_count
  br label %postInstrumentation25

postInstrumentation25:                            ; preds = %if_clock_enabled23, %pushBlock26
  br label %postClockEnabledBlock28

postClockEnabledBlock28:                          ; preds = %if.end, %postInstrumentation25
  br label %cleanup

cleanup:                                          ; preds = %postClockEnabledBlock28, %postClockEnabledBlock21, %postClockEnabledBlock21
  %retval.0 = phi i32 [ %conv7, %postClockEnabledBlock28 ], [ -1, %postClockEnabledBlock21 ], [ -1, %postClockEnabledBlock21 ]
  ret i32 %retval.0
}

; Function Attrs: nofree nounwind uwtable
define i32 @http_get_maxage(i8* readonly %cache_ctl, i32 %len) local_unnamed_addr #7 {
entry:
  %0 = load i8, i8* %cache_ctl, align 1, !tbaa !397
  %tobool = icmp eq i8 %0, 0
  br i1 %tobool, label %return, label %land.rhs.i

land.rhs.i:                                       ; preds = %postClockEnabledBlock9, %entry
  %p.132.i = phi i8* [ %incdec.ptr.i, %postClockEnabledBlock9 ], [ %cache_ctl, %entry ]
  %1 = phi i8 [ %.be89, %postClockEnabledBlock9 ], [ %0, %entry ]
  %cmp.i = icmp eq i8 %1, 109
  %incdec.ptr.i = getelementptr inbounds i8, i8* %p.132.i, i64 1
  br i1 %cmp.i, label %if.end.i, label %while.body7.i

while.body7.i:                                    ; preds = %land.rhs.i
  %.pr.i = load i8, i8* %incdec.ptr.i, align 1, !tbaa !397
  %tobool3.i = icmp eq i8 %.pr.i, 0
  %2 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %2, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %while.body7.i
  %3 = load i64, i64* @LocalLC
  %4 = add i64 6, %3
  store i64 %4, i64* @LocalLC
  %commit = icmp ugt i64 %4, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %5 = add i32 %2, 1
  store i32 %5, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %4)
  %6 = load i32, i32* @lc_disabled_count
  %7 = sub i32 %6, 1
  store i32 %7, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %while.body7.i, %postInstrumentation
  br i1 %tobool3.i, label %if.end11, label %land.rhs.i.backedge

land.rhs.i.backedge:                              ; preds = %postClockEnabledBlock16, %postClockEnabledBlock
  %.be89 = phi i8 [ %.pr.i, %postClockEnabledBlock ], [ %.pre, %postClockEnabledBlock16 ]
  %8 = load i32, i32* @lc_disabled_count
  %clock_running3 = icmp eq i32 %8, 0
  br i1 %clock_running3, label %if_clock_enabled4, label %postClockEnabledBlock9

if_clock_enabled4:                                ; preds = %land.rhs.i.backedge
  %9 = load i64, i64* @LocalLC
  %10 = add i64 1, %9
  store i64 %10, i64* @LocalLC
  %commit5 = icmp ugt i64 %10, 5000
  br i1 %commit5, label %pushBlock7, label %postInstrumentation6

pushBlock7:                                       ; preds = %if_clock_enabled4
  %11 = add i32 %8, 1
  store i32 %11, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler8 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler8(i64 %10)
  %12 = load i32, i32* @lc_disabled_count
  %13 = sub i32 %12, 1
  store i32 %13, i32* @lc_disabled_count
  br label %postInstrumentation6

postInstrumentation6:                             ; preds = %if_clock_enabled4, %pushBlock7
  br label %postClockEnabledBlock9

postClockEnabledBlock9:                           ; preds = %land.rhs.i.backedge, %postInstrumentation6
  br label %land.rhs.i

if.end.i:                                         ; preds = %land.rhs.i
  %call13.i = tail call i32 @strncasecmp(i8* nonnull %incdec.ptr.i, i8* nonnull getelementptr inbounds ([9 x i8], [9 x i8]* @.str.5.5, i64 0, i64 1), i64 7) #20
  %tobool14.i = icmp eq i32 %call13.i, 0
  br i1 %tobool14.i, label %if.then2, label %if.end.i.while.cond.i_crit_edge

if.end.i.while.cond.i_crit_edge:                  ; preds = %if.end.i
  %.pre = load i8, i8* %incdec.ptr.i, align 1, !tbaa !397
  %tobool.i = icmp eq i8 %.pre, 0
  %14 = load i32, i32* @lc_disabled_count
  %clock_running10 = icmp eq i32 %14, 0
  br i1 %clock_running10, label %if_clock_enabled11, label %postClockEnabledBlock16

if_clock_enabled11:                               ; preds = %if.end.i.while.cond.i_crit_edge
  %15 = load i64, i64* @LocalLC
  %16 = add i64 9, %15
  store i64 %16, i64* @LocalLC
  %commit12 = icmp ugt i64 %16, 5000
  br i1 %commit12, label %pushBlock14, label %postInstrumentation13

pushBlock14:                                      ; preds = %if_clock_enabled11
  %17 = add i32 %14, 1
  store i32 %17, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler15 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler15(i64 %16)
  %18 = load i32, i32* @lc_disabled_count
  %19 = sub i32 %18, 1
  store i32 %19, i32* @lc_disabled_count
  br label %postInstrumentation13

postInstrumentation13:                            ; preds = %if_clock_enabled11, %pushBlock14
  br label %postClockEnabledBlock16

postClockEnabledBlock16:                          ; preds = %if.end.i.while.cond.i_crit_edge, %postInstrumentation13
  br i1 %tobool.i, label %if.end11, label %land.rhs.i.backedge

if.then2:                                         ; preds = %if.end.i
  %add.ptr = getelementptr inbounds i8, i8* %p.132.i, i64 9
  %call3 = tail call i64 @strtol(i8* nocapture nonnull %add.ptr, i8** null, i32 10) #16
  %call4 = tail call i32* @__errno_location() #11
  %20 = load i32, i32* %call4, align 4, !tbaa !417
  %21 = load i32, i32* @lc_disabled_count
  %clock_running17 = icmp eq i32 %21, 0
  br i1 %clock_running17, label %if_clock_enabled18, label %postClockEnabledBlock23

if_clock_enabled18:                               ; preds = %if.then2
  %22 = load i64, i64* @LocalLC
  %23 = add i64 11, %22
  store i64 %23, i64* @LocalLC
  %commit19 = icmp ugt i64 %23, 5000
  br i1 %commit19, label %pushBlock21, label %postInstrumentation20

pushBlock21:                                      ; preds = %if_clock_enabled18
  %24 = add i32 %21, 1
  store i32 %24, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler22 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler22(i64 %23)
  %25 = load i32, i32* @lc_disabled_count
  %26 = sub i32 %25, 1
  store i32 %26, i32* @lc_disabled_count
  br label %postInstrumentation20

postInstrumentation20:                            ; preds = %if_clock_enabled18, %pushBlock21
  br label %postClockEnabledBlock23

postClockEnabledBlock23:                          ; preds = %if.then2, %postInstrumentation20
  switch i32 %20, label %if.end10 [
    i32 22, label %return_dummy
    i32 34, label %return_dummy
  ]

if.end10:                                         ; preds = %postClockEnabledBlock23
  %conv = trunc i64 %call3 to i32
  %27 = load i32, i32* @lc_disabled_count
  %clock_running24 = icmp eq i32 %27, 0
  br i1 %clock_running24, label %if_clock_enabled25, label %postClockEnabledBlock30

if_clock_enabled25:                               ; preds = %if.end10
  %28 = load i64, i64* @LocalLC
  %29 = add i64 2, %28
  store i64 %29, i64* @LocalLC
  %commit26 = icmp ugt i64 %29, 5000
  br i1 %commit26, label %pushBlock28, label %postInstrumentation27

pushBlock28:                                      ; preds = %if_clock_enabled25
  %30 = add i32 %27, 1
  store i32 %30, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler29 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler29(i64 %29)
  %31 = load i32, i32* @lc_disabled_count
  %32 = sub i32 %31, 1
  store i32 %32, i32* @lc_disabled_count
  br label %postInstrumentation27

postInstrumentation27:                            ; preds = %if_clock_enabled25, %pushBlock28
  br label %postClockEnabledBlock30

postClockEnabledBlock30:                          ; preds = %if.end10, %postInstrumentation27
  br label %return_dummy

if.end11:                                         ; preds = %postClockEnabledBlock16, %postClockEnabledBlock
  %tobool.i4185 = icmp eq i8 %0, 0
  %33 = load i32, i32* @lc_disabled_count
  %clock_running31 = icmp eq i32 %33, 0
  br i1 %clock_running31, label %if_clock_enabled32, label %postClockEnabledBlock37

if_clock_enabled32:                               ; preds = %if.end11
  %34 = load i64, i64* @LocalLC
  %35 = add i64 2, %34
  store i64 %35, i64* @LocalLC
  %commit33 = icmp ugt i64 %35, 5000
  br i1 %commit33, label %pushBlock35, label %postInstrumentation34

pushBlock35:                                      ; preds = %if_clock_enabled32
  %36 = add i32 %33, 1
  store i32 %36, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler36 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler36(i64 %35)
  %37 = load i32, i32* @lc_disabled_count
  %38 = sub i32 %37, 1
  store i32 %38, i32* @lc_disabled_count
  br label %postInstrumentation34

postInstrumentation34:                            ; preds = %if_clock_enabled32, %pushBlock35
  br label %postClockEnabledBlock37

postClockEnabledBlock37:                          ; preds = %if.end11, %postInstrumentation34
  br i1 %tobool.i4185, label %return_dummy1, label %land.rhs.i47

land.rhs.i47:                                     ; preds = %postClockEnabledBlock51, %postClockEnabledBlock37
  %p.132.i44 = phi i8* [ %incdec.ptr.i46, %postClockEnabledBlock51 ], [ %cache_ctl, %postClockEnabledBlock37 ]
  %39 = phi i8 [ %.be, %postClockEnabledBlock51 ], [ %0, %postClockEnabledBlock37 ]
  %cmp.i45 = icmp eq i8 %39, 115
  %incdec.ptr.i46 = getelementptr inbounds i8, i8* %p.132.i44, i64 1
  br i1 %cmp.i45, label %if.end.i53, label %while.body7.i50

while.body7.i50:                                  ; preds = %land.rhs.i47
  %.pr.i48 = load i8, i8* %incdec.ptr.i46, align 1, !tbaa !397
  %tobool3.i49 = icmp eq i8 %.pr.i48, 0
  %40 = load i32, i32* @lc_disabled_count
  %clock_running38 = icmp eq i32 %40, 0
  br i1 %clock_running38, label %if_clock_enabled39, label %postClockEnabledBlock44

if_clock_enabled39:                               ; preds = %while.body7.i50
  %41 = load i64, i64* @LocalLC
  %42 = add i64 6, %41
  store i64 %42, i64* @LocalLC
  %commit40 = icmp ugt i64 %42, 5000
  br i1 %commit40, label %pushBlock42, label %postInstrumentation41

pushBlock42:                                      ; preds = %if_clock_enabled39
  %43 = add i32 %40, 1
  store i32 %43, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler43 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler43(i64 %42)
  %44 = load i32, i32* @lc_disabled_count
  %45 = sub i32 %44, 1
  store i32 %45, i32* @lc_disabled_count
  br label %postInstrumentation41

postInstrumentation41:                            ; preds = %if_clock_enabled39, %pushBlock42
  br label %postClockEnabledBlock44

postClockEnabledBlock44:                          ; preds = %while.body7.i50, %postInstrumentation41
  br i1 %tobool3.i49, label %return_dummy1, label %land.rhs.i47.backedge

land.rhs.i47.backedge:                            ; preds = %postClockEnabledBlock58, %postClockEnabledBlock44
  %.be = phi i8 [ %.pr.i48, %postClockEnabledBlock44 ], [ %.pre72, %postClockEnabledBlock58 ]
  %46 = load i32, i32* @lc_disabled_count
  %clock_running45 = icmp eq i32 %46, 0
  br i1 %clock_running45, label %if_clock_enabled46, label %postClockEnabledBlock51

if_clock_enabled46:                               ; preds = %land.rhs.i47.backedge
  %47 = load i64, i64* @LocalLC
  %48 = add i64 1, %47
  store i64 %48, i64* @LocalLC
  %commit47 = icmp ugt i64 %48, 5000
  br i1 %commit47, label %pushBlock49, label %postInstrumentation48

pushBlock49:                                      ; preds = %if_clock_enabled46
  %49 = add i32 %46, 1
  store i32 %49, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler50 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler50(i64 %48)
  %50 = load i32, i32* @lc_disabled_count
  %51 = sub i32 %50, 1
  store i32 %51, i32* @lc_disabled_count
  br label %postInstrumentation48

postInstrumentation48:                            ; preds = %if_clock_enabled46, %pushBlock49
  br label %postClockEnabledBlock51

postClockEnabledBlock51:                          ; preds = %land.rhs.i47.backedge, %postInstrumentation48
  br label %land.rhs.i47

if.end.i53:                                       ; preds = %land.rhs.i47
  %call13.i51 = tail call i32 @strncasecmp(i8* nonnull %incdec.ptr.i46, i8* nonnull getelementptr inbounds ([10 x i8], [10 x i8]* @.str.6.6, i64 0, i64 1), i64 8) #20
  %tobool14.i52 = icmp eq i32 %call13.i51, 0
  br i1 %tobool14.i52, label %nre_strcasestr.exit55, label %if.end.i53.while.cond.i42_crit_edge

if.end.i53.while.cond.i42_crit_edge:              ; preds = %if.end.i53
  %.pre72 = load i8, i8* %incdec.ptr.i46, align 1, !tbaa !397
  %tobool.i41 = icmp eq i8 %.pre72, 0
  %52 = load i32, i32* @lc_disabled_count
  %clock_running52 = icmp eq i32 %52, 0
  br i1 %clock_running52, label %if_clock_enabled53, label %postClockEnabledBlock58

if_clock_enabled53:                               ; preds = %if.end.i53.while.cond.i42_crit_edge
  %53 = load i64, i64* @LocalLC
  %54 = add i64 9, %53
  store i64 %54, i64* @LocalLC
  %commit54 = icmp ugt i64 %54, 5000
  br i1 %commit54, label %pushBlock56, label %postInstrumentation55

pushBlock56:                                      ; preds = %if_clock_enabled53
  %55 = add i32 %52, 1
  store i32 %55, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler57 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler57(i64 %54)
  %56 = load i32, i32* @lc_disabled_count
  %57 = sub i32 %56, 1
  store i32 %57, i32* @lc_disabled_count
  br label %postInstrumentation55

postInstrumentation55:                            ; preds = %if_clock_enabled53, %pushBlock56
  br label %postClockEnabledBlock58

postClockEnabledBlock58:                          ; preds = %if.end.i53.while.cond.i42_crit_edge, %postInstrumentation55
  br i1 %tobool.i41, label %return_dummy1, label %land.rhs.i47.backedge

nre_strcasestr.exit55:                            ; preds = %if.end.i53
  %tobool13 = icmp eq i8* %p.132.i44, null
  %58 = load i32, i32* @lc_disabled_count
  %clock_running59 = icmp eq i32 %58, 0
  br i1 %clock_running59, label %if_clock_enabled60, label %postClockEnabledBlock65

if_clock_enabled60:                               ; preds = %nre_strcasestr.exit55
  %59 = load i64, i64* @LocalLC
  %60 = add i64 8, %59
  store i64 %60, i64* @LocalLC
  %commit61 = icmp ugt i64 %60, 5000
  br i1 %commit61, label %pushBlock63, label %postInstrumentation62

pushBlock63:                                      ; preds = %if_clock_enabled60
  %61 = add i32 %58, 1
  store i32 %61, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler64 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler64(i64 %60)
  %62 = load i32, i32* @lc_disabled_count
  %63 = sub i32 %62, 1
  store i32 %63, i32* @lc_disabled_count
  br label %postInstrumentation62

postInstrumentation62:                            ; preds = %if_clock_enabled60, %pushBlock63
  br label %postClockEnabledBlock65

postClockEnabledBlock65:                          ; preds = %nre_strcasestr.exit55, %postInstrumentation62
  br i1 %tobool13, label %return_dummy1_dummy, label %if.then14

if.then14:                                        ; preds = %postClockEnabledBlock65
  %add.ptr15 = getelementptr inbounds i8, i8* %p.132.i44, i64 10
  %call16 = tail call i64 @strtol(i8* nocapture nonnull %add.ptr15, i8** null, i32 10) #16
  %call18 = tail call i32* @__errno_location() #11
  %64 = load i32, i32* %call18, align 4, !tbaa !417
  %65 = load i32, i32* @lc_disabled_count
  %clock_running66 = icmp eq i32 %65, 0
  br i1 %clock_running66, label %if_clock_enabled67, label %postClockEnabledBlock72

if_clock_enabled67:                               ; preds = %if.then14
  %66 = load i64, i64* @LocalLC
  %67 = add i64 5, %66
  store i64 %67, i64* @LocalLC
  %commit68 = icmp ugt i64 %67, 5000
  br i1 %commit68, label %pushBlock70, label %postInstrumentation69

pushBlock70:                                      ; preds = %if_clock_enabled67
  %68 = add i32 %65, 1
  store i32 %68, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler71 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler71(i64 %67)
  %69 = load i32, i32* @lc_disabled_count
  %70 = sub i32 %69, 1
  store i32 %70, i32* @lc_disabled_count
  br label %postInstrumentation69

postInstrumentation69:                            ; preds = %if_clock_enabled67, %pushBlock70
  br label %postClockEnabledBlock72

postClockEnabledBlock72:                          ; preds = %if.then14, %postInstrumentation69
  switch i32 %64, label %if.end26 [
    i32 22, label %return_dummy1_dummy_dummy
    i32 34, label %return_dummy1_dummy_dummy
  ]

if.end26:                                         ; preds = %postClockEnabledBlock72
  %conv17 = trunc i64 %call16 to i32
  %71 = load i32, i32* @lc_disabled_count
  %clock_running73 = icmp eq i32 %71, 0
  br i1 %clock_running73, label %if_clock_enabled74, label %postClockEnabledBlock79

if_clock_enabled74:                               ; preds = %if.end26
  %72 = load i64, i64* @LocalLC
  %73 = add i64 2, %72
  store i64 %73, i64* @LocalLC
  %commit75 = icmp ugt i64 %73, 5000
  br i1 %commit75, label %pushBlock77, label %postInstrumentation76

pushBlock77:                                      ; preds = %if_clock_enabled74
  %74 = add i32 %71, 1
  store i32 %74, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler78 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler78(i64 %73)
  %75 = load i32, i32* @lc_disabled_count
  %76 = sub i32 %75, 1
  store i32 %76, i32* @lc_disabled_count
  br label %postInstrumentation76

postInstrumentation76:                            ; preds = %if_clock_enabled74, %pushBlock77
  br label %postClockEnabledBlock79

postClockEnabledBlock79:                          ; preds = %if.end26, %postInstrumentation76
  br label %return_dummy1_dummy_dummy

return_dummy:                                     ; preds = %postClockEnabledBlock23, %postClockEnabledBlock23, %postClockEnabledBlock30
  %retval.1.ph = phi i32 [ -1, %postClockEnabledBlock23 ], [ -1, %postClockEnabledBlock23 ], [ %conv, %postClockEnabledBlock30 ]
  %77 = load i32, i32* @lc_disabled_count
  %clock_running80 = icmp eq i32 %77, 0
  br i1 %clock_running80, label %if_clock_enabled81, label %postClockEnabledBlock86

if_clock_enabled81:                               ; preds = %return_dummy
  %78 = load i64, i64* @LocalLC
  %79 = add i64 1, %78
  store i64 %79, i64* @LocalLC
  %commit82 = icmp ugt i64 %79, 5000
  br i1 %commit82, label %pushBlock84, label %postInstrumentation83

pushBlock84:                                      ; preds = %if_clock_enabled81
  %80 = add i32 %77, 1
  store i32 %80, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler85 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler85(i64 %79)
  %81 = load i32, i32* @lc_disabled_count
  %82 = sub i32 %81, 1
  store i32 %82, i32* @lc_disabled_count
  br label %postInstrumentation83

postInstrumentation83:                            ; preds = %if_clock_enabled81, %pushBlock84
  br label %postClockEnabledBlock86

postClockEnabledBlock86:                          ; preds = %return_dummy, %postInstrumentation83
  br label %return

return_dummy1_dummy_dummy:                        ; preds = %postClockEnabledBlock72, %postClockEnabledBlock72, %postClockEnabledBlock79
  %retval.1.ph2.ph.ph = phi i32 [ -1, %postClockEnabledBlock72 ], [ -1, %postClockEnabledBlock72 ], [ %conv17, %postClockEnabledBlock79 ]
  %83 = load i32, i32* @lc_disabled_count
  %clock_running87 = icmp eq i32 %83, 0
  br i1 %clock_running87, label %if_clock_enabled88, label %postClockEnabledBlock93

if_clock_enabled88:                               ; preds = %return_dummy1_dummy_dummy
  %84 = load i64, i64* @LocalLC
  %85 = add i64 1, %84
  store i64 %85, i64* @LocalLC
  %commit89 = icmp ugt i64 %85, 5000
  br i1 %commit89, label %pushBlock91, label %postInstrumentation90

pushBlock91:                                      ; preds = %if_clock_enabled88
  %86 = add i32 %83, 1
  store i32 %86, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler92 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler92(i64 %85)
  %87 = load i32, i32* @lc_disabled_count
  %88 = sub i32 %87, 1
  store i32 %88, i32* @lc_disabled_count
  br label %postInstrumentation90

postInstrumentation90:                            ; preds = %if_clock_enabled88, %pushBlock91
  br label %postClockEnabledBlock93

postClockEnabledBlock93:                          ; preds = %return_dummy1_dummy_dummy, %postInstrumentation90
  br label %return_dummy1_dummy

return_dummy1_dummy:                              ; preds = %postClockEnabledBlock93, %postClockEnabledBlock65
  %retval.1.ph2.ph = phi i32 [ -1, %postClockEnabledBlock65 ], [ %retval.1.ph2.ph.ph, %postClockEnabledBlock93 ]
  %89 = load i32, i32* @lc_disabled_count
  %clock_running94 = icmp eq i32 %89, 0
  br i1 %clock_running94, label %if_clock_enabled95, label %postClockEnabledBlock100

if_clock_enabled95:                               ; preds = %return_dummy1_dummy
  %90 = load i64, i64* @LocalLC
  %91 = add i64 1, %90
  store i64 %91, i64* @LocalLC
  %commit96 = icmp ugt i64 %91, 5000
  br i1 %commit96, label %pushBlock98, label %postInstrumentation97

pushBlock98:                                      ; preds = %if_clock_enabled95
  %92 = add i32 %89, 1
  store i32 %92, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler99 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler99(i64 %91)
  %93 = load i32, i32* @lc_disabled_count
  %94 = sub i32 %93, 1
  store i32 %94, i32* @lc_disabled_count
  br label %postInstrumentation97

postInstrumentation97:                            ; preds = %if_clock_enabled95, %pushBlock98
  br label %postClockEnabledBlock100

postClockEnabledBlock100:                         ; preds = %return_dummy1_dummy, %postInstrumentation97
  br label %return_dummy1

return_dummy1:                                    ; preds = %postClockEnabledBlock100, %postClockEnabledBlock37, %postClockEnabledBlock44, %postClockEnabledBlock58
  %retval.1.ph2 = phi i32 [ -1, %postClockEnabledBlock58 ], [ -1, %postClockEnabledBlock44 ], [ -1, %postClockEnabledBlock37 ], [ %retval.1.ph2.ph, %postClockEnabledBlock100 ]
  %95 = load i32, i32* @lc_disabled_count
  %clock_running101 = icmp eq i32 %95, 0
  br i1 %clock_running101, label %if_clock_enabled102, label %postClockEnabledBlock107

if_clock_enabled102:                              ; preds = %return_dummy1
  %96 = load i64, i64* @LocalLC
  %97 = add i64 1, %96
  store i64 %97, i64* @LocalLC
  %commit103 = icmp ugt i64 %97, 5000
  br i1 %commit103, label %pushBlock105, label %postInstrumentation104

pushBlock105:                                     ; preds = %if_clock_enabled102
  %98 = add i32 %95, 1
  store i32 %98, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler106 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler106(i64 %97)
  %99 = load i32, i32* @lc_disabled_count
  %100 = sub i32 %99, 1
  store i32 %100, i32* @lc_disabled_count
  br label %postInstrumentation104

postInstrumentation104:                           ; preds = %if_clock_enabled102, %pushBlock105
  br label %postClockEnabledBlock107

postClockEnabledBlock107:                         ; preds = %return_dummy1, %postInstrumentation104
  br label %return

return:                                           ; preds = %postClockEnabledBlock107, %postClockEnabledBlock86, %entry
  %retval.1 = phi i32 [ -1, %entry ], [ %retval.1.ph, %postClockEnabledBlock86 ], [ %retval.1.ph2, %postClockEnabledBlock107 ]
  ret i32 %retval.1
}

; Function Attrs: nounwind uwtable
define i64 @httpdate_to_timet(i8* nocapture readonly %str) local_unnamed_addr #0 {
entry:
  %str_mon = alloca [500 x i8], align 16
  %str_wday = alloca [500 x i8], align 16
  %tm_sec = alloca i32, align 4
  %tm_min = alloca i32, align 4
  %tm_hour = alloca i32, align 4
  %tm_mday = alloca i32, align 4
  %tm_year = alloca i32, align 4
  %0 = getelementptr inbounds [500 x i8], [500 x i8]* %str_mon, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 500, i8* nonnull %0) #16
  %1 = getelementptr inbounds [500 x i8], [500 x i8]* %str_wday, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 500, i8* nonnull %1) #16
  %2 = bitcast i32* %tm_sec to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %2) #16
  %3 = bitcast i32* %tm_min to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %3) #16
  %4 = bitcast i32* %tm_hour to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %4) #16
  %5 = bitcast i32* %tm_mday to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %5) #16
  %6 = bitcast i32* %tm_year to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %6) #16
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %cp.0 = phi i8* [ %str, %entry ], [ %incdec.ptr, %for.inc ]
  %7 = load i8, i8* %cp.0, align 1, !tbaa !397
  %8 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %8, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %for.cond
  %9 = load i64, i64* @LocalLC
  %10 = add i64 6, %9
  store i64 %10, i64* @LocalLC
  %commit = icmp ugt i64 %10, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %11 = add i32 %8, 1
  store i32 %11, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %10)
  %12 = load i32, i32* @lc_disabled_count
  %13 = sub i32 %12, 1
  store i32 %13, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %for.cond, %postInstrumentation
  switch i8 %7, label %for.end [
    i8 32, label %for.inc
    i8 9, label %for.inc
  ]

for.inc:                                          ; preds = %postClockEnabledBlock, %postClockEnabledBlock
  %incdec.ptr = getelementptr inbounds i8, i8* %cp.0, i64 1
  br label %for.cond

for.end:                                          ; preds = %postClockEnabledBlock
  %call = call i32 (i8*, i8*, ...) @__isoc99_sscanf(i8* %cp.0, i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.14, i64 0, i64 0), i32* nonnull %tm_mday, i8* nonnull %0, i32* nonnull %tm_year, i32* nonnull %tm_hour, i32* nonnull %tm_min, i32* nonnull %tm_sec) #16
  %cmp5 = icmp eq i32 %call, 6
  br i1 %cmp5, label %land.lhs.true, label %if.else

land.lhs.true:                                    ; preds = %for.end
  %.b.i = load i1, i1* @scan_mon.sorted, align 4
  br i1 %.b.i, label %if.end.i, label %if.then.i

if.then.i:                                        ; preds = %land.lhs.true
  call void @qsort(i8* bitcast ([23 x %struct.strlong]* @scan_mon.mon_tab to i8*), i64 23, i64 16, i32 (i8*, i8*)* nonnull @strlong_compare) #16
  store i1 true, i1* @scan_mon.sorted, align 4
  br label %if.end.i

if.end.i:                                         ; preds = %if.then.i, %land.lhs.true
  %14 = load i8, i8* %0, align 16, !tbaa !397
  %cmp14.i.i = icmp eq i8 %14, 0
  %15 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %15, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %if.end.i
  %16 = load i64, i64* @LocalLC
  %17 = add i64 6, %16
  store i64 %17, i64* @LocalLC
  %commit3 = icmp ugt i64 %17, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %18 = add i32 %15, 1
  store i32 %18, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %17)
  %19 = load i32, i32* @lc_disabled_count
  %20 = sub i32 %19, 1
  store i32 %20, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %if.end.i, %postInstrumentation4
  br i1 %cmp14.i.i, label %for.cond.i376.preheader, label %for.body.lr.ph.i.i

for.body.lr.ph.i.i:                               ; preds = %postClockEnabledBlock7
  %call.i.i = tail call i16** @__ctype_b_loc() #11
  br label %for.body.i.i

for.body.i.i:                                     ; preds = %for.inc.i.i, %for.body.lr.ph.i.i
  %21 = phi i8 [ %14, %for.body.lr.ph.i.i ], [ %33, %for.inc.i.i ]
  %str.addr.015.i.i = phi i8* [ %0, %for.body.lr.ph.i.i ], [ %incdec.ptr.i.i, %for.inc.i.i ]
  %22 = load i16*, i16** %call.i.i, align 8, !tbaa !86
  %idxprom.i.i = sext i8 %21 to i64
  %arrayidx.i.i = getelementptr inbounds i16, i16* %22, i64 %idxprom.i.i
  %23 = load i16, i16* %arrayidx.i.i, align 2, !tbaa !592
  %24 = and i16 %23, 256
  %tobool.i.i = icmp eq i16 %24, 0
  %25 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %25, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %for.body.i.i
  %26 = load i64, i64* @LocalLC
  %27 = add i64 14, %26
  store i64 %27, i64* @LocalLC
  %commit10 = icmp ugt i64 %27, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %28 = add i32 %25, 1
  store i32 %28, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %27)
  %29 = load i32, i32* @lc_disabled_count
  %30 = sub i32 %29, 1
  store i32 %30, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %for.body.i.i, %postInstrumentation11
  br i1 %tobool.i.i, label %for.inc.i.i, label %if.then.i.i

if.then.i.i:                                      ; preds = %postClockEnabledBlock14
  %call4.i.i = tail call i32** @__ctype_tolower_loc() #11
  %31 = load i32*, i32** %call4.i.i, align 8, !tbaa !86
  %arrayidx7.i.i = getelementptr inbounds i32, i32* %31, i64 %idxprom.i.i
  %32 = load i32, i32* %arrayidx7.i.i, align 4, !tbaa !417
  %conv8.i.i = trunc i32 %32 to i8
  store i8 %conv8.i.i, i8* %str.addr.015.i.i, align 1, !tbaa !397
  br label %for.inc.i.i

for.inc.i.i:                                      ; preds = %if.then.i.i, %postClockEnabledBlock14
  %incdec.ptr.i.i = getelementptr inbounds i8, i8* %str.addr.015.i.i, i64 1
  %33 = load i8, i8* %incdec.ptr.i.i, align 1, !tbaa !397
  %cmp.i.i = icmp eq i8 %33, 0
  br i1 %cmp.i.i, label %for.cond.i376.preheader, label %for.body.i.i

for.cond.i376.preheader:                          ; preds = %for.inc.i.i, %postClockEnabledBlock7
  %34 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %34, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %for.cond.i376.preheader
  %35 = load i64, i64* @LocalLC
  %36 = add i64 3, %35
  store i64 %36, i64* @LocalLC
  %commit17 = icmp ugt i64 %36, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %37 = add i32 %34, 1
  store i32 %37, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %36)
  %38 = load i32, i32* @lc_disabled_count
  %39 = sub i32 %38, 1
  store i32 %39, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %for.cond.i376.preheader, %postInstrumentation18
  br label %for.cond.i376

for.cond.i376:                                    ; preds = %postClockEnabledBlock35, %postClockEnabledBlock21
  %h.0.i368 = phi i32 [ %h.1.i385, %postClockEnabledBlock35 ], [ 22, %postClockEnabledBlock21 ]
  %l.0.i369 = phi i32 [ %l.1.i386, %postClockEnabledBlock35 ], [ 0, %postClockEnabledBlock21 ]
  %add.i370 = add nsw i32 %l.0.i369, %h.0.i368
  %div.i371 = sdiv i32 %add.i370, 2
  %idxprom.i372 = sext i32 %div.i371 to i64
  %s.i373 = getelementptr inbounds [23 x %struct.strlong], [23 x %struct.strlong]* @scan_mon.mon_tab, i64 0, i64 %idxprom.i372, i32 0
  %40 = load i8*, i8** %s.i373, align 16, !tbaa !593
  %call.i374 = call i32 @strcmp(i8* nonnull %0, i8* %40) #20
  %cmp.i375 = icmp slt i32 %call.i374, 0
  br i1 %cmp.i375, label %if.then.i378, label %if.else.i380

if.then.i378:                                     ; preds = %for.cond.i376
  %sub1.i377 = add nsw i32 %div.i371, -1
  br label %if.end9.i388

if.else.i380:                                     ; preds = %for.cond.i376
  %cmp2.i379 = icmp eq i32 %call.i374, 0
  %41 = load i32, i32* @lc_disabled_count
  %clock_running22 = icmp eq i32 %41, 0
  br i1 %clock_running22, label %if_clock_enabled23, label %postClockEnabledBlock28

if_clock_enabled23:                               ; preds = %if.else.i380
  %42 = load i64, i64* @LocalLC
  %43 = add i64 10, %42
  store i64 %43, i64* @LocalLC
  %commit24 = icmp ugt i64 %43, 5000
  br i1 %commit24, label %pushBlock26, label %postInstrumentation25

pushBlock26:                                      ; preds = %if_clock_enabled23
  %44 = add i32 %41, 1
  store i32 %44, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler27 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler27(i64 %43)
  %45 = load i32, i32* @lc_disabled_count
  %46 = sub i32 %45, 1
  store i32 %46, i32* @lc_disabled_count
  br label %postInstrumentation25

postInstrumentation25:                            ; preds = %if_clock_enabled23, %pushBlock26
  br label %postClockEnabledBlock28

postClockEnabledBlock28:                          ; preds = %if.else.i380, %postInstrumentation25
  br i1 %cmp2.i379, label %if.end144, label %if.then3.i382

if.then3.i382:                                    ; preds = %postClockEnabledBlock28
  %add4.i381 = add nsw i32 %div.i371, 1
  br label %if.end9.i388

if.end9.i388:                                     ; preds = %if.then3.i382, %if.then.i378
  %h.1.i385 = phi i32 [ %sub1.i377, %if.then.i378 ], [ %h.0.i368, %if.then3.i382 ]
  %l.1.i386 = phi i32 [ %l.0.i369, %if.then.i378 ], [ %add4.i381, %if.then3.i382 ]
  %cmp10.i387 = icmp slt i32 %h.1.i385, %l.1.i386
  %47 = load i32, i32* @lc_disabled_count
  %clock_running29 = icmp eq i32 %47, 0
  br i1 %clock_running29, label %if_clock_enabled30, label %postClockEnabledBlock35

if_clock_enabled30:                               ; preds = %if.end9.i388
  %48 = load i64, i64* @LocalLC
  %49 = add i64 8, %48
  store i64 %49, i64* @LocalLC
  %commit31 = icmp ugt i64 %49, 5000
  br i1 %commit31, label %pushBlock33, label %postInstrumentation32

pushBlock33:                                      ; preds = %if_clock_enabled30
  %50 = add i32 %47, 1
  store i32 %50, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler34 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler34(i64 %49)
  %51 = load i32, i32* @lc_disabled_count
  %52 = sub i32 %51, 1
  store i32 %52, i32* @lc_disabled_count
  br label %postInstrumentation32

postInstrumentation32:                            ; preds = %if_clock_enabled30, %pushBlock33
  br label %postClockEnabledBlock35

postClockEnabledBlock35:                          ; preds = %if.end9.i388, %postInstrumentation32
  br i1 %cmp10.i387, label %if.else, label %for.cond.i376

if.else:                                          ; preds = %postClockEnabledBlock35, %for.end
  %call17 = call i32 (i8*, i8*, ...) @__isoc99_sscanf(i8* %cp.0, i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.1.15, i64 0, i64 0), i32* nonnull %tm_mday, i8* nonnull %0, i32* nonnull %tm_year, i32* nonnull %tm_hour, i32* nonnull %tm_min, i32* nonnull %tm_sec) #16
  %cmp18 = icmp eq i32 %call17, 6
  %53 = load i32, i32* @lc_disabled_count
  %clock_running36 = icmp eq i32 %53, 0
  br i1 %clock_running36, label %if_clock_enabled37, label %postClockEnabledBlock42

if_clock_enabled37:                               ; preds = %if.else
  %54 = load i64, i64* @LocalLC
  %55 = add i64 3, %54
  store i64 %55, i64* @LocalLC
  %commit38 = icmp ugt i64 %55, 5000
  br i1 %commit38, label %pushBlock40, label %postInstrumentation39

pushBlock40:                                      ; preds = %if_clock_enabled37
  %56 = add i32 %53, 1
  store i32 %56, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler41 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler41(i64 %55)
  %57 = load i32, i32* @lc_disabled_count
  %58 = sub i32 %57, 1
  store i32 %58, i32* @lc_disabled_count
  br label %postInstrumentation39

postInstrumentation39:                            ; preds = %if_clock_enabled37, %pushBlock40
  br label %postClockEnabledBlock42

postClockEnabledBlock42:                          ; preds = %if.else, %postInstrumentation39
  br i1 %cmp18, label %land.lhs.true20, label %if.else32

land.lhs.true20:                                  ; preds = %postClockEnabledBlock42
  %.b.i181 = load i1, i1* @scan_mon.sorted, align 4
  br i1 %.b.i181, label %if.end.i184, label %if.then.i182

if.then.i182:                                     ; preds = %land.lhs.true20
  call void @qsort(i8* bitcast ([23 x %struct.strlong]* @scan_mon.mon_tab to i8*), i64 23, i64 16, i32 (i8*, i8*)* nonnull @strlong_compare) #16
  store i1 true, i1* @scan_mon.sorted, align 4
  br label %if.end.i184

if.end.i184:                                      ; preds = %if.then.i182, %land.lhs.true20
  %59 = load i8, i8* %0, align 16, !tbaa !397
  %cmp14.i.i183 = icmp eq i8 %59, 0
  %60 = load i32, i32* @lc_disabled_count
  %clock_running43 = icmp eq i32 %60, 0
  br i1 %clock_running43, label %if_clock_enabled44, label %postClockEnabledBlock49

if_clock_enabled44:                               ; preds = %if.end.i184
  %61 = load i64, i64* @LocalLC
  %62 = add i64 6, %61
  store i64 %62, i64* @LocalLC
  %commit45 = icmp ugt i64 %62, 5000
  br i1 %commit45, label %pushBlock47, label %postInstrumentation46

pushBlock47:                                      ; preds = %if_clock_enabled44
  %63 = add i32 %60, 1
  store i32 %63, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler48 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler48(i64 %62)
  %64 = load i32, i32* @lc_disabled_count
  %65 = sub i32 %64, 1
  store i32 %65, i32* @lc_disabled_count
  br label %postInstrumentation46

postInstrumentation46:                            ; preds = %if_clock_enabled44, %pushBlock47
  br label %postClockEnabledBlock49

postClockEnabledBlock49:                          ; preds = %if.end.i184, %postInstrumentation46
  br i1 %cmp14.i.i183, label %for.cond.i398.preheader, label %for.body.lr.ph.i.i186

for.body.lr.ph.i.i186:                            ; preds = %postClockEnabledBlock49
  %call.i.i185 = tail call i16** @__ctype_b_loc() #11
  br label %for.body.i.i191

for.body.i.i191:                                  ; preds = %for.inc.i.i198, %for.body.lr.ph.i.i186
  %66 = phi i8 [ %59, %for.body.lr.ph.i.i186 ], [ %78, %for.inc.i.i198 ]
  %str.addr.015.i.i187 = phi i8* [ %0, %for.body.lr.ph.i.i186 ], [ %incdec.ptr.i.i196, %for.inc.i.i198 ]
  %67 = load i16*, i16** %call.i.i185, align 8, !tbaa !86
  %idxprom.i.i188 = sext i8 %66 to i64
  %arrayidx.i.i189 = getelementptr inbounds i16, i16* %67, i64 %idxprom.i.i188
  %68 = load i16, i16* %arrayidx.i.i189, align 2, !tbaa !592
  %69 = and i16 %68, 256
  %tobool.i.i190 = icmp eq i16 %69, 0
  %70 = load i32, i32* @lc_disabled_count
  %clock_running50 = icmp eq i32 %70, 0
  br i1 %clock_running50, label %if_clock_enabled51, label %postClockEnabledBlock56

if_clock_enabled51:                               ; preds = %for.body.i.i191
  %71 = load i64, i64* @LocalLC
  %72 = add i64 14, %71
  store i64 %72, i64* @LocalLC
  %commit52 = icmp ugt i64 %72, 5000
  br i1 %commit52, label %pushBlock54, label %postInstrumentation53

pushBlock54:                                      ; preds = %if_clock_enabled51
  %73 = add i32 %70, 1
  store i32 %73, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler55 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler55(i64 %72)
  %74 = load i32, i32* @lc_disabled_count
  %75 = sub i32 %74, 1
  store i32 %75, i32* @lc_disabled_count
  br label %postInstrumentation53

postInstrumentation53:                            ; preds = %if_clock_enabled51, %pushBlock54
  br label %postClockEnabledBlock56

postClockEnabledBlock56:                          ; preds = %for.body.i.i191, %postInstrumentation53
  br i1 %tobool.i.i190, label %for.inc.i.i198, label %if.then.i.i195

if.then.i.i195:                                   ; preds = %postClockEnabledBlock56
  %call4.i.i192 = tail call i32** @__ctype_tolower_loc() #11
  %76 = load i32*, i32** %call4.i.i192, align 8, !tbaa !86
  %arrayidx7.i.i193 = getelementptr inbounds i32, i32* %76, i64 %idxprom.i.i188
  %77 = load i32, i32* %arrayidx7.i.i193, align 4, !tbaa !417
  %conv8.i.i194 = trunc i32 %77 to i8
  store i8 %conv8.i.i194, i8* %str.addr.015.i.i187, align 1, !tbaa !397
  br label %for.inc.i.i198

for.inc.i.i198:                                   ; preds = %if.then.i.i195, %postClockEnabledBlock56
  %incdec.ptr.i.i196 = getelementptr inbounds i8, i8* %str.addr.015.i.i187, i64 1
  %78 = load i8, i8* %incdec.ptr.i.i196, align 1, !tbaa !397
  %cmp.i.i197 = icmp eq i8 %78, 0
  br i1 %cmp.i.i197, label %for.cond.i398.preheader, label %for.body.i.i191

for.cond.i398.preheader:                          ; preds = %for.inc.i.i198, %postClockEnabledBlock49
  %79 = load i32, i32* @lc_disabled_count
  %clock_running57 = icmp eq i32 %79, 0
  br i1 %clock_running57, label %if_clock_enabled58, label %postClockEnabledBlock63

if_clock_enabled58:                               ; preds = %for.cond.i398.preheader
  %80 = load i64, i64* @LocalLC
  %81 = add i64 3, %80
  store i64 %81, i64* @LocalLC
  %commit59 = icmp ugt i64 %81, 5000
  br i1 %commit59, label %pushBlock61, label %postInstrumentation60

pushBlock61:                                      ; preds = %if_clock_enabled58
  %82 = add i32 %79, 1
  store i32 %82, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler62 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler62(i64 %81)
  %83 = load i32, i32* @lc_disabled_count
  %84 = sub i32 %83, 1
  store i32 %84, i32* @lc_disabled_count
  br label %postInstrumentation60

postInstrumentation60:                            ; preds = %if_clock_enabled58, %pushBlock61
  br label %postClockEnabledBlock63

postClockEnabledBlock63:                          ; preds = %for.cond.i398.preheader, %postInstrumentation60
  br label %for.cond.i398

for.cond.i398:                                    ; preds = %postClockEnabledBlock77, %postClockEnabledBlock63
  %h.0.i391 = phi i32 [ %h.1.i407, %postClockEnabledBlock77 ], [ 22, %postClockEnabledBlock63 ]
  %l.0.i392 = phi i32 [ %l.1.i408, %postClockEnabledBlock77 ], [ 0, %postClockEnabledBlock63 ]
  %add.i393 = add nsw i32 %l.0.i392, %h.0.i391
  %div.i394 = sdiv i32 %add.i393, 2
  %idxprom.i395 = sext i32 %div.i394 to i64
  %s.i396 = getelementptr inbounds [23 x %struct.strlong], [23 x %struct.strlong]* @scan_mon.mon_tab, i64 0, i64 %idxprom.i395, i32 0
  %85 = load i8*, i8** %s.i396, align 16, !tbaa !593
  %call.i = call i32 @strcmp(i8* nonnull %0, i8* %85) #20
  %cmp.i397 = icmp slt i32 %call.i, 0
  br i1 %cmp.i397, label %if.then.i400, label %if.else.i402

if.then.i400:                                     ; preds = %for.cond.i398
  %sub1.i399 = add nsw i32 %div.i394, -1
  br label %if.end9.i410

if.else.i402:                                     ; preds = %for.cond.i398
  %cmp2.i401 = icmp eq i32 %call.i, 0
  %86 = load i32, i32* @lc_disabled_count
  %clock_running64 = icmp eq i32 %86, 0
  br i1 %clock_running64, label %if_clock_enabled65, label %postClockEnabledBlock70

if_clock_enabled65:                               ; preds = %if.else.i402
  %87 = load i64, i64* @LocalLC
  %88 = add i64 10, %87
  store i64 %88, i64* @LocalLC
  %commit66 = icmp ugt i64 %88, 5000
  br i1 %commit66, label %pushBlock68, label %postInstrumentation67

pushBlock68:                                      ; preds = %if_clock_enabled65
  %89 = add i32 %86, 1
  store i32 %89, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler69 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler69(i64 %88)
  %90 = load i32, i32* @lc_disabled_count
  %91 = sub i32 %90, 1
  store i32 %91, i32* @lc_disabled_count
  br label %postInstrumentation67

postInstrumentation67:                            ; preds = %if_clock_enabled65, %pushBlock68
  br label %postClockEnabledBlock70

postClockEnabledBlock70:                          ; preds = %if.else.i402, %postInstrumentation67
  br i1 %cmp2.i401, label %if.end144, label %if.then3.i404

if.then3.i404:                                    ; preds = %postClockEnabledBlock70
  %add4.i403 = add nsw i32 %div.i394, 1
  br label %if.end9.i410

if.end9.i410:                                     ; preds = %if.then3.i404, %if.then.i400
  %h.1.i407 = phi i32 [ %sub1.i399, %if.then.i400 ], [ %h.0.i391, %if.then3.i404 ]
  %l.1.i408 = phi i32 [ %l.0.i392, %if.then.i400 ], [ %add4.i403, %if.then3.i404 ]
  %cmp10.i409 = icmp slt i32 %h.1.i407, %l.1.i408
  %92 = load i32, i32* @lc_disabled_count
  %clock_running71 = icmp eq i32 %92, 0
  br i1 %clock_running71, label %if_clock_enabled72, label %postClockEnabledBlock77

if_clock_enabled72:                               ; preds = %if.end9.i410
  %93 = load i64, i64* @LocalLC
  %94 = add i64 8, %93
  store i64 %94, i64* @LocalLC
  %commit73 = icmp ugt i64 %94, 5000
  br i1 %commit73, label %pushBlock75, label %postInstrumentation74

pushBlock75:                                      ; preds = %if_clock_enabled72
  %95 = add i32 %92, 1
  store i32 %95, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler76 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler76(i64 %94)
  %96 = load i32, i32* @lc_disabled_count
  %97 = sub i32 %96, 1
  store i32 %97, i32* @lc_disabled_count
  br label %postInstrumentation74

postInstrumentation74:                            ; preds = %if_clock_enabled72, %pushBlock75
  br label %postClockEnabledBlock77

postClockEnabledBlock77:                          ; preds = %if.end9.i410, %postInstrumentation74
  br i1 %cmp10.i409, label %if.else32, label %for.cond.i398

if.else32:                                        ; preds = %postClockEnabledBlock77, %postClockEnabledBlock42
  %call34 = call i32 (i8*, i8*, ...) @__isoc99_sscanf(i8* %cp.0, i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.2.16, i64 0, i64 0), i32* nonnull %tm_hour, i32* nonnull %tm_min, i32* nonnull %tm_sec, i32* nonnull %tm_mday, i8* nonnull %0, i32* nonnull %tm_year) #16
  %cmp35 = icmp eq i32 %call34, 6
  %98 = load i32, i32* @lc_disabled_count
  %clock_running78 = icmp eq i32 %98, 0
  br i1 %clock_running78, label %if_clock_enabled79, label %postClockEnabledBlock84

if_clock_enabled79:                               ; preds = %if.else32
  %99 = load i64, i64* @LocalLC
  %100 = add i64 3, %99
  store i64 %100, i64* @LocalLC
  %commit80 = icmp ugt i64 %100, 5000
  br i1 %commit80, label %pushBlock82, label %postInstrumentation81

pushBlock82:                                      ; preds = %if_clock_enabled79
  %101 = add i32 %98, 1
  store i32 %101, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler83 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler83(i64 %100)
  %102 = load i32, i32* @lc_disabled_count
  %103 = sub i32 %102, 1
  store i32 %103, i32* @lc_disabled_count
  br label %postInstrumentation81

postInstrumentation81:                            ; preds = %if_clock_enabled79, %pushBlock82
  br label %postClockEnabledBlock84

postClockEnabledBlock84:                          ; preds = %if.else32, %postInstrumentation81
  br i1 %cmp35, label %land.lhs.true37, label %if.else49

land.lhs.true37:                                  ; preds = %postClockEnabledBlock84
  %.b.i201 = load i1, i1* @scan_mon.sorted, align 4
  br i1 %.b.i201, label %if.end.i204, label %if.then.i202

if.then.i202:                                     ; preds = %land.lhs.true37
  call void @qsort(i8* bitcast ([23 x %struct.strlong]* @scan_mon.mon_tab to i8*), i64 23, i64 16, i32 (i8*, i8*)* nonnull @strlong_compare) #16
  store i1 true, i1* @scan_mon.sorted, align 4
  br label %if.end.i204

if.end.i204:                                      ; preds = %if.then.i202, %land.lhs.true37
  %104 = load i8, i8* %0, align 16, !tbaa !397
  %cmp14.i.i203 = icmp eq i8 %104, 0
  %105 = load i32, i32* @lc_disabled_count
  %clock_running85 = icmp eq i32 %105, 0
  br i1 %clock_running85, label %if_clock_enabled86, label %postClockEnabledBlock91

if_clock_enabled86:                               ; preds = %if.end.i204
  %106 = load i64, i64* @LocalLC
  %107 = add i64 6, %106
  store i64 %107, i64* @LocalLC
  %commit87 = icmp ugt i64 %107, 5000
  br i1 %commit87, label %pushBlock89, label %postInstrumentation88

pushBlock89:                                      ; preds = %if_clock_enabled86
  %108 = add i32 %105, 1
  store i32 %108, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler90 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler90(i64 %107)
  %109 = load i32, i32* @lc_disabled_count
  %110 = sub i32 %109, 1
  store i32 %110, i32* @lc_disabled_count
  br label %postInstrumentation88

postInstrumentation88:                            ; preds = %if_clock_enabled86, %pushBlock89
  br label %postClockEnabledBlock91

postClockEnabledBlock91:                          ; preds = %if.end.i204, %postInstrumentation88
  br i1 %cmp14.i.i203, label %for.cond.i421.preheader, label %for.body.lr.ph.i.i206

for.body.lr.ph.i.i206:                            ; preds = %postClockEnabledBlock91
  %call.i.i205 = tail call i16** @__ctype_b_loc() #11
  br label %for.body.i.i211

for.body.i.i211:                                  ; preds = %for.inc.i.i218, %for.body.lr.ph.i.i206
  %111 = phi i8 [ %104, %for.body.lr.ph.i.i206 ], [ %123, %for.inc.i.i218 ]
  %str.addr.015.i.i207 = phi i8* [ %0, %for.body.lr.ph.i.i206 ], [ %incdec.ptr.i.i216, %for.inc.i.i218 ]
  %112 = load i16*, i16** %call.i.i205, align 8, !tbaa !86
  %idxprom.i.i208 = sext i8 %111 to i64
  %arrayidx.i.i209 = getelementptr inbounds i16, i16* %112, i64 %idxprom.i.i208
  %113 = load i16, i16* %arrayidx.i.i209, align 2, !tbaa !592
  %114 = and i16 %113, 256
  %tobool.i.i210 = icmp eq i16 %114, 0
  %115 = load i32, i32* @lc_disabled_count
  %clock_running92 = icmp eq i32 %115, 0
  br i1 %clock_running92, label %if_clock_enabled93, label %postClockEnabledBlock98

if_clock_enabled93:                               ; preds = %for.body.i.i211
  %116 = load i64, i64* @LocalLC
  %117 = add i64 14, %116
  store i64 %117, i64* @LocalLC
  %commit94 = icmp ugt i64 %117, 5000
  br i1 %commit94, label %pushBlock96, label %postInstrumentation95

pushBlock96:                                      ; preds = %if_clock_enabled93
  %118 = add i32 %115, 1
  store i32 %118, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler97 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler97(i64 %117)
  %119 = load i32, i32* @lc_disabled_count
  %120 = sub i32 %119, 1
  store i32 %120, i32* @lc_disabled_count
  br label %postInstrumentation95

postInstrumentation95:                            ; preds = %if_clock_enabled93, %pushBlock96
  br label %postClockEnabledBlock98

postClockEnabledBlock98:                          ; preds = %for.body.i.i211, %postInstrumentation95
  br i1 %tobool.i.i210, label %for.inc.i.i218, label %if.then.i.i215

if.then.i.i215:                                   ; preds = %postClockEnabledBlock98
  %call4.i.i212 = tail call i32** @__ctype_tolower_loc() #11
  %121 = load i32*, i32** %call4.i.i212, align 8, !tbaa !86
  %arrayidx7.i.i213 = getelementptr inbounds i32, i32* %121, i64 %idxprom.i.i208
  %122 = load i32, i32* %arrayidx7.i.i213, align 4, !tbaa !417
  %conv8.i.i214 = trunc i32 %122 to i8
  store i8 %conv8.i.i214, i8* %str.addr.015.i.i207, align 1, !tbaa !397
  br label %for.inc.i.i218

for.inc.i.i218:                                   ; preds = %if.then.i.i215, %postClockEnabledBlock98
  %incdec.ptr.i.i216 = getelementptr inbounds i8, i8* %str.addr.015.i.i207, i64 1
  %123 = load i8, i8* %incdec.ptr.i.i216, align 1, !tbaa !397
  %cmp.i.i217 = icmp eq i8 %123, 0
  br i1 %cmp.i.i217, label %for.cond.i421.preheader, label %for.body.i.i211

for.cond.i421.preheader:                          ; preds = %for.inc.i.i218, %postClockEnabledBlock91
  %124 = load i32, i32* @lc_disabled_count
  %clock_running99 = icmp eq i32 %124, 0
  br i1 %clock_running99, label %if_clock_enabled100, label %postClockEnabledBlock105

if_clock_enabled100:                              ; preds = %for.cond.i421.preheader
  %125 = load i64, i64* @LocalLC
  %126 = add i64 3, %125
  store i64 %126, i64* @LocalLC
  %commit101 = icmp ugt i64 %126, 5000
  br i1 %commit101, label %pushBlock103, label %postInstrumentation102

pushBlock103:                                     ; preds = %if_clock_enabled100
  %127 = add i32 %124, 1
  store i32 %127, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler104 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler104(i64 %126)
  %128 = load i32, i32* @lc_disabled_count
  %129 = sub i32 %128, 1
  store i32 %129, i32* @lc_disabled_count
  br label %postInstrumentation102

postInstrumentation102:                           ; preds = %if_clock_enabled100, %pushBlock103
  br label %postClockEnabledBlock105

postClockEnabledBlock105:                         ; preds = %for.cond.i421.preheader, %postInstrumentation102
  br label %for.cond.i421

for.cond.i421:                                    ; preds = %postClockEnabledBlock119, %postClockEnabledBlock105
  %h.0.i413 = phi i32 [ %h.1.i430, %postClockEnabledBlock119 ], [ 22, %postClockEnabledBlock105 ]
  %l.0.i414 = phi i32 [ %l.1.i431, %postClockEnabledBlock119 ], [ 0, %postClockEnabledBlock105 ]
  %add.i415 = add nsw i32 %l.0.i414, %h.0.i413
  %div.i416 = sdiv i32 %add.i415, 2
  %idxprom.i417 = sext i32 %div.i416 to i64
  %s.i418 = getelementptr inbounds [23 x %struct.strlong], [23 x %struct.strlong]* @scan_mon.mon_tab, i64 0, i64 %idxprom.i417, i32 0
  %130 = load i8*, i8** %s.i418, align 16, !tbaa !593
  %call.i419 = call i32 @strcmp(i8* nonnull %0, i8* %130) #20
  %cmp.i420 = icmp slt i32 %call.i419, 0
  br i1 %cmp.i420, label %if.then.i423, label %if.else.i425

if.then.i423:                                     ; preds = %for.cond.i421
  %sub1.i422 = add nsw i32 %div.i416, -1
  br label %if.end9.i433

if.else.i425:                                     ; preds = %for.cond.i421
  %cmp2.i424 = icmp eq i32 %call.i419, 0
  %131 = load i32, i32* @lc_disabled_count
  %clock_running106 = icmp eq i32 %131, 0
  br i1 %clock_running106, label %if_clock_enabled107, label %postClockEnabledBlock112

if_clock_enabled107:                              ; preds = %if.else.i425
  %132 = load i64, i64* @LocalLC
  %133 = add i64 10, %132
  store i64 %133, i64* @LocalLC
  %commit108 = icmp ugt i64 %133, 5000
  br i1 %commit108, label %pushBlock110, label %postInstrumentation109

pushBlock110:                                     ; preds = %if_clock_enabled107
  %134 = add i32 %131, 1
  store i32 %134, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler111 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler111(i64 %133)
  %135 = load i32, i32* @lc_disabled_count
  %136 = sub i32 %135, 1
  store i32 %136, i32* @lc_disabled_count
  br label %postInstrumentation109

postInstrumentation109:                           ; preds = %if_clock_enabled107, %pushBlock110
  br label %postClockEnabledBlock112

postClockEnabledBlock112:                         ; preds = %if.else.i425, %postInstrumentation109
  br i1 %cmp2.i424, label %if.end144, label %if.then3.i427

if.then3.i427:                                    ; preds = %postClockEnabledBlock112
  %add4.i426 = add nsw i32 %div.i416, 1
  br label %if.end9.i433

if.end9.i433:                                     ; preds = %if.then3.i427, %if.then.i423
  %h.1.i430 = phi i32 [ %sub1.i422, %if.then.i423 ], [ %h.0.i413, %if.then3.i427 ]
  %l.1.i431 = phi i32 [ %l.0.i414, %if.then.i423 ], [ %add4.i426, %if.then3.i427 ]
  %cmp10.i432 = icmp slt i32 %h.1.i430, %l.1.i431
  %137 = load i32, i32* @lc_disabled_count
  %clock_running113 = icmp eq i32 %137, 0
  br i1 %clock_running113, label %if_clock_enabled114, label %postClockEnabledBlock119

if_clock_enabled114:                              ; preds = %if.end9.i433
  %138 = load i64, i64* @LocalLC
  %139 = add i64 8, %138
  store i64 %139, i64* @LocalLC
  %commit115 = icmp ugt i64 %139, 5000
  br i1 %commit115, label %pushBlock117, label %postInstrumentation116

pushBlock117:                                     ; preds = %if_clock_enabled114
  %140 = add i32 %137, 1
  store i32 %140, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler118 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler118(i64 %139)
  %141 = load i32, i32* @lc_disabled_count
  %142 = sub i32 %141, 1
  store i32 %142, i32* @lc_disabled_count
  br label %postInstrumentation116

postInstrumentation116:                           ; preds = %if_clock_enabled114, %pushBlock117
  br label %postClockEnabledBlock119

postClockEnabledBlock119:                         ; preds = %if.end9.i433, %postInstrumentation116
  br i1 %cmp10.i432, label %if.else49, label %for.cond.i421

if.else49:                                        ; preds = %postClockEnabledBlock119, %postClockEnabledBlock84
  %call51 = call i32 (i8*, i8*, ...) @__isoc99_sscanf(i8* %cp.0, i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.3.17, i64 0, i64 0), i32* nonnull %tm_hour, i32* nonnull %tm_min, i32* nonnull %tm_sec, i32* nonnull %tm_mday, i8* nonnull %0, i32* nonnull %tm_year) #16
  %cmp52 = icmp eq i32 %call51, 6
  %143 = load i32, i32* @lc_disabled_count
  %clock_running120 = icmp eq i32 %143, 0
  br i1 %clock_running120, label %if_clock_enabled121, label %postClockEnabledBlock126

if_clock_enabled121:                              ; preds = %if.else49
  %144 = load i64, i64* @LocalLC
  %145 = add i64 3, %144
  store i64 %145, i64* @LocalLC
  %commit122 = icmp ugt i64 %145, 5000
  br i1 %commit122, label %pushBlock124, label %postInstrumentation123

pushBlock124:                                     ; preds = %if_clock_enabled121
  %146 = add i32 %143, 1
  store i32 %146, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler125 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler125(i64 %145)
  %147 = load i32, i32* @lc_disabled_count
  %148 = sub i32 %147, 1
  store i32 %148, i32* @lc_disabled_count
  br label %postInstrumentation123

postInstrumentation123:                           ; preds = %if_clock_enabled121, %pushBlock124
  br label %postClockEnabledBlock126

postClockEnabledBlock126:                         ; preds = %if.else49, %postInstrumentation123
  br i1 %cmp52, label %land.lhs.true54, label %if.else66

land.lhs.true54:                                  ; preds = %postClockEnabledBlock126
  %.b.i221 = load i1, i1* @scan_mon.sorted, align 4
  br i1 %.b.i221, label %if.end.i224, label %if.then.i222

if.then.i222:                                     ; preds = %land.lhs.true54
  call void @qsort(i8* bitcast ([23 x %struct.strlong]* @scan_mon.mon_tab to i8*), i64 23, i64 16, i32 (i8*, i8*)* nonnull @strlong_compare) #16
  store i1 true, i1* @scan_mon.sorted, align 4
  br label %if.end.i224

if.end.i224:                                      ; preds = %if.then.i222, %land.lhs.true54
  %149 = load i8, i8* %0, align 16, !tbaa !397
  %cmp14.i.i223 = icmp eq i8 %149, 0
  %150 = load i32, i32* @lc_disabled_count
  %clock_running127 = icmp eq i32 %150, 0
  br i1 %clock_running127, label %if_clock_enabled128, label %postClockEnabledBlock133

if_clock_enabled128:                              ; preds = %if.end.i224
  %151 = load i64, i64* @LocalLC
  %152 = add i64 6, %151
  store i64 %152, i64* @LocalLC
  %commit129 = icmp ugt i64 %152, 5000
  br i1 %commit129, label %pushBlock131, label %postInstrumentation130

pushBlock131:                                     ; preds = %if_clock_enabled128
  %153 = add i32 %150, 1
  store i32 %153, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler132 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler132(i64 %152)
  %154 = load i32, i32* @lc_disabled_count
  %155 = sub i32 %154, 1
  store i32 %155, i32* @lc_disabled_count
  br label %postInstrumentation130

postInstrumentation130:                           ; preds = %if_clock_enabled128, %pushBlock131
  br label %postClockEnabledBlock133

postClockEnabledBlock133:                         ; preds = %if.end.i224, %postInstrumentation130
  br i1 %cmp14.i.i223, label %for.cond.i444.preheader, label %for.body.lr.ph.i.i226

for.body.lr.ph.i.i226:                            ; preds = %postClockEnabledBlock133
  %call.i.i225 = tail call i16** @__ctype_b_loc() #11
  br label %for.body.i.i231

for.body.i.i231:                                  ; preds = %for.inc.i.i238, %for.body.lr.ph.i.i226
  %156 = phi i8 [ %149, %for.body.lr.ph.i.i226 ], [ %168, %for.inc.i.i238 ]
  %str.addr.015.i.i227 = phi i8* [ %0, %for.body.lr.ph.i.i226 ], [ %incdec.ptr.i.i236, %for.inc.i.i238 ]
  %157 = load i16*, i16** %call.i.i225, align 8, !tbaa !86
  %idxprom.i.i228 = sext i8 %156 to i64
  %arrayidx.i.i229 = getelementptr inbounds i16, i16* %157, i64 %idxprom.i.i228
  %158 = load i16, i16* %arrayidx.i.i229, align 2, !tbaa !592
  %159 = and i16 %158, 256
  %tobool.i.i230 = icmp eq i16 %159, 0
  %160 = load i32, i32* @lc_disabled_count
  %clock_running134 = icmp eq i32 %160, 0
  br i1 %clock_running134, label %if_clock_enabled135, label %postClockEnabledBlock140

if_clock_enabled135:                              ; preds = %for.body.i.i231
  %161 = load i64, i64* @LocalLC
  %162 = add i64 14, %161
  store i64 %162, i64* @LocalLC
  %commit136 = icmp ugt i64 %162, 5000
  br i1 %commit136, label %pushBlock138, label %postInstrumentation137

pushBlock138:                                     ; preds = %if_clock_enabled135
  %163 = add i32 %160, 1
  store i32 %163, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler139 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler139(i64 %162)
  %164 = load i32, i32* @lc_disabled_count
  %165 = sub i32 %164, 1
  store i32 %165, i32* @lc_disabled_count
  br label %postInstrumentation137

postInstrumentation137:                           ; preds = %if_clock_enabled135, %pushBlock138
  br label %postClockEnabledBlock140

postClockEnabledBlock140:                         ; preds = %for.body.i.i231, %postInstrumentation137
  br i1 %tobool.i.i230, label %for.inc.i.i238, label %if.then.i.i235

if.then.i.i235:                                   ; preds = %postClockEnabledBlock140
  %call4.i.i232 = tail call i32** @__ctype_tolower_loc() #11
  %166 = load i32*, i32** %call4.i.i232, align 8, !tbaa !86
  %arrayidx7.i.i233 = getelementptr inbounds i32, i32* %166, i64 %idxprom.i.i228
  %167 = load i32, i32* %arrayidx7.i.i233, align 4, !tbaa !417
  %conv8.i.i234 = trunc i32 %167 to i8
  store i8 %conv8.i.i234, i8* %str.addr.015.i.i227, align 1, !tbaa !397
  br label %for.inc.i.i238

for.inc.i.i238:                                   ; preds = %if.then.i.i235, %postClockEnabledBlock140
  %incdec.ptr.i.i236 = getelementptr inbounds i8, i8* %str.addr.015.i.i227, i64 1
  %168 = load i8, i8* %incdec.ptr.i.i236, align 1, !tbaa !397
  %cmp.i.i237 = icmp eq i8 %168, 0
  br i1 %cmp.i.i237, label %for.cond.i444.preheader, label %for.body.i.i231

for.cond.i444.preheader:                          ; preds = %for.inc.i.i238, %postClockEnabledBlock133
  %169 = load i32, i32* @lc_disabled_count
  %clock_running141 = icmp eq i32 %169, 0
  br i1 %clock_running141, label %if_clock_enabled142, label %postClockEnabledBlock147

if_clock_enabled142:                              ; preds = %for.cond.i444.preheader
  %170 = load i64, i64* @LocalLC
  %171 = add i64 3, %170
  store i64 %171, i64* @LocalLC
  %commit143 = icmp ugt i64 %171, 5000
  br i1 %commit143, label %pushBlock145, label %postInstrumentation144

pushBlock145:                                     ; preds = %if_clock_enabled142
  %172 = add i32 %169, 1
  store i32 %172, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler146 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler146(i64 %171)
  %173 = load i32, i32* @lc_disabled_count
  %174 = sub i32 %173, 1
  store i32 %174, i32* @lc_disabled_count
  br label %postInstrumentation144

postInstrumentation144:                           ; preds = %if_clock_enabled142, %pushBlock145
  br label %postClockEnabledBlock147

postClockEnabledBlock147:                         ; preds = %for.cond.i444.preheader, %postInstrumentation144
  br label %for.cond.i444

for.cond.i444:                                    ; preds = %postClockEnabledBlock161, %postClockEnabledBlock147
  %h.0.i436 = phi i32 [ %h.1.i453, %postClockEnabledBlock161 ], [ 22, %postClockEnabledBlock147 ]
  %l.0.i437 = phi i32 [ %l.1.i454, %postClockEnabledBlock161 ], [ 0, %postClockEnabledBlock147 ]
  %add.i438 = add nsw i32 %l.0.i437, %h.0.i436
  %div.i439 = sdiv i32 %add.i438, 2
  %idxprom.i440 = sext i32 %div.i439 to i64
  %s.i441 = getelementptr inbounds [23 x %struct.strlong], [23 x %struct.strlong]* @scan_mon.mon_tab, i64 0, i64 %idxprom.i440, i32 0
  %175 = load i8*, i8** %s.i441, align 16, !tbaa !593
  %call.i442 = call i32 @strcmp(i8* nonnull %0, i8* %175) #20
  %cmp.i443 = icmp slt i32 %call.i442, 0
  br i1 %cmp.i443, label %if.then.i446, label %if.else.i448

if.then.i446:                                     ; preds = %for.cond.i444
  %sub1.i445 = add nsw i32 %div.i439, -1
  br label %if.end9.i456

if.else.i448:                                     ; preds = %for.cond.i444
  %cmp2.i447 = icmp eq i32 %call.i442, 0
  %176 = load i32, i32* @lc_disabled_count
  %clock_running148 = icmp eq i32 %176, 0
  br i1 %clock_running148, label %if_clock_enabled149, label %postClockEnabledBlock154

if_clock_enabled149:                              ; preds = %if.else.i448
  %177 = load i64, i64* @LocalLC
  %178 = add i64 10, %177
  store i64 %178, i64* @LocalLC
  %commit150 = icmp ugt i64 %178, 5000
  br i1 %commit150, label %pushBlock152, label %postInstrumentation151

pushBlock152:                                     ; preds = %if_clock_enabled149
  %179 = add i32 %176, 1
  store i32 %179, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler153 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler153(i64 %178)
  %180 = load i32, i32* @lc_disabled_count
  %181 = sub i32 %180, 1
  store i32 %181, i32* @lc_disabled_count
  br label %postInstrumentation151

postInstrumentation151:                           ; preds = %if_clock_enabled149, %pushBlock152
  br label %postClockEnabledBlock154

postClockEnabledBlock154:                         ; preds = %if.else.i448, %postInstrumentation151
  br i1 %cmp2.i447, label %if.end144, label %if.then3.i450

if.then3.i450:                                    ; preds = %postClockEnabledBlock154
  %add4.i449 = add nsw i32 %div.i439, 1
  br label %if.end9.i456

if.end9.i456:                                     ; preds = %if.then3.i450, %if.then.i446
  %h.1.i453 = phi i32 [ %sub1.i445, %if.then.i446 ], [ %h.0.i436, %if.then3.i450 ]
  %l.1.i454 = phi i32 [ %l.0.i437, %if.then.i446 ], [ %add4.i449, %if.then3.i450 ]
  %cmp10.i455 = icmp slt i32 %h.1.i453, %l.1.i454
  %182 = load i32, i32* @lc_disabled_count
  %clock_running155 = icmp eq i32 %182, 0
  br i1 %clock_running155, label %if_clock_enabled156, label %postClockEnabledBlock161

if_clock_enabled156:                              ; preds = %if.end9.i456
  %183 = load i64, i64* @LocalLC
  %184 = add i64 8, %183
  store i64 %184, i64* @LocalLC
  %commit157 = icmp ugt i64 %184, 5000
  br i1 %commit157, label %pushBlock159, label %postInstrumentation158

pushBlock159:                                     ; preds = %if_clock_enabled156
  %185 = add i32 %182, 1
  store i32 %185, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler160 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler160(i64 %184)
  %186 = load i32, i32* @lc_disabled_count
  %187 = sub i32 %186, 1
  store i32 %187, i32* @lc_disabled_count
  br label %postInstrumentation158

postInstrumentation158:                           ; preds = %if_clock_enabled156, %pushBlock159
  br label %postClockEnabledBlock161

postClockEnabledBlock161:                         ; preds = %if.end9.i456, %postInstrumentation158
  br i1 %cmp10.i455, label %if.else66, label %for.cond.i444

if.else66:                                        ; preds = %postClockEnabledBlock161, %postClockEnabledBlock126
  %call69 = call i32 (i8*, i8*, ...) @__isoc99_sscanf(i8* %cp.0, i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.4.18, i64 0, i64 0), i8* nonnull %1, i32* nonnull %tm_mday, i8* nonnull %0, i32* nonnull %tm_year, i32* nonnull %tm_hour, i32* nonnull %tm_min, i32* nonnull %tm_sec) #16
  %cmp70 = icmp eq i32 %call69, 7
  %188 = load i32, i32* @lc_disabled_count
  %clock_running162 = icmp eq i32 %188, 0
  br i1 %clock_running162, label %if_clock_enabled163, label %postClockEnabledBlock168

if_clock_enabled163:                              ; preds = %if.else66
  %189 = load i64, i64* @LocalLC
  %190 = add i64 3, %189
  store i64 %190, i64* @LocalLC
  %commit164 = icmp ugt i64 %190, 5000
  br i1 %commit164, label %pushBlock166, label %postInstrumentation165

pushBlock166:                                     ; preds = %if_clock_enabled163
  %191 = add i32 %188, 1
  store i32 %191, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler167 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler167(i64 %190)
  %192 = load i32, i32* @lc_disabled_count
  %193 = sub i32 %192, 1
  store i32 %193, i32* @lc_disabled_count
  br label %postInstrumentation165

postInstrumentation165:                           ; preds = %if_clock_enabled163, %pushBlock166
  br label %postClockEnabledBlock168

postClockEnabledBlock168:                         ; preds = %if.else66, %postInstrumentation165
  br i1 %cmp70, label %land.lhs.true72, label %if.else90

land.lhs.true72:                                  ; preds = %postClockEnabledBlock168
  %.b.i241 = load i1, i1* @scan_wday.sorted, align 4
  br i1 %.b.i241, label %if.end.i244, label %if.then.i242

if.then.i242:                                     ; preds = %land.lhs.true72
  call void @qsort(i8* bitcast ([14 x %struct.strlong]* @scan_wday.wday_tab to i8*), i64 14, i64 16, i32 (i8*, i8*)* nonnull @strlong_compare) #16
  store i1 true, i1* @scan_wday.sorted, align 4
  br label %if.end.i244

if.end.i244:                                      ; preds = %if.then.i242, %land.lhs.true72
  %194 = load i8, i8* %1, align 16, !tbaa !397
  %cmp14.i.i243 = icmp eq i8 %194, 0
  %195 = load i32, i32* @lc_disabled_count
  %clock_running169 = icmp eq i32 %195, 0
  br i1 %clock_running169, label %if_clock_enabled170, label %postClockEnabledBlock175

if_clock_enabled170:                              ; preds = %if.end.i244
  %196 = load i64, i64* @LocalLC
  %197 = add i64 6, %196
  store i64 %197, i64* @LocalLC
  %commit171 = icmp ugt i64 %197, 5000
  br i1 %commit171, label %pushBlock173, label %postInstrumentation172

pushBlock173:                                     ; preds = %if_clock_enabled170
  %198 = add i32 %195, 1
  store i32 %198, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler174 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler174(i64 %197)
  %199 = load i32, i32* @lc_disabled_count
  %200 = sub i32 %199, 1
  store i32 %200, i32* @lc_disabled_count
  br label %postInstrumentation172

postInstrumentation172:                           ; preds = %if_clock_enabled170, %pushBlock173
  br label %postClockEnabledBlock175

postClockEnabledBlock175:                         ; preds = %if.end.i244, %postInstrumentation172
  br i1 %cmp14.i.i243, label %for.cond.i467.preheader, label %for.body.lr.ph.i.i246

for.body.lr.ph.i.i246:                            ; preds = %postClockEnabledBlock175
  %call.i.i245 = tail call i16** @__ctype_b_loc() #11
  br label %for.body.i.i251

for.body.i.i251:                                  ; preds = %for.inc.i.i258, %for.body.lr.ph.i.i246
  %201 = phi i8 [ %194, %for.body.lr.ph.i.i246 ], [ %213, %for.inc.i.i258 ]
  %str.addr.015.i.i247 = phi i8* [ %1, %for.body.lr.ph.i.i246 ], [ %incdec.ptr.i.i256, %for.inc.i.i258 ]
  %202 = load i16*, i16** %call.i.i245, align 8, !tbaa !86
  %idxprom.i.i248 = sext i8 %201 to i64
  %arrayidx.i.i249 = getelementptr inbounds i16, i16* %202, i64 %idxprom.i.i248
  %203 = load i16, i16* %arrayidx.i.i249, align 2, !tbaa !592
  %204 = and i16 %203, 256
  %tobool.i.i250 = icmp eq i16 %204, 0
  %205 = load i32, i32* @lc_disabled_count
  %clock_running176 = icmp eq i32 %205, 0
  br i1 %clock_running176, label %if_clock_enabled177, label %postClockEnabledBlock182

if_clock_enabled177:                              ; preds = %for.body.i.i251
  %206 = load i64, i64* @LocalLC
  %207 = add i64 14, %206
  store i64 %207, i64* @LocalLC
  %commit178 = icmp ugt i64 %207, 5000
  br i1 %commit178, label %pushBlock180, label %postInstrumentation179

pushBlock180:                                     ; preds = %if_clock_enabled177
  %208 = add i32 %205, 1
  store i32 %208, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler181 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler181(i64 %207)
  %209 = load i32, i32* @lc_disabled_count
  %210 = sub i32 %209, 1
  store i32 %210, i32* @lc_disabled_count
  br label %postInstrumentation179

postInstrumentation179:                           ; preds = %if_clock_enabled177, %pushBlock180
  br label %postClockEnabledBlock182

postClockEnabledBlock182:                         ; preds = %for.body.i.i251, %postInstrumentation179
  br i1 %tobool.i.i250, label %for.inc.i.i258, label %if.then.i.i255

if.then.i.i255:                                   ; preds = %postClockEnabledBlock182
  %call4.i.i252 = tail call i32** @__ctype_tolower_loc() #11
  %211 = load i32*, i32** %call4.i.i252, align 8, !tbaa !86
  %arrayidx7.i.i253 = getelementptr inbounds i32, i32* %211, i64 %idxprom.i.i248
  %212 = load i32, i32* %arrayidx7.i.i253, align 4, !tbaa !417
  %conv8.i.i254 = trunc i32 %212 to i8
  store i8 %conv8.i.i254, i8* %str.addr.015.i.i247, align 1, !tbaa !397
  br label %for.inc.i.i258

for.inc.i.i258:                                   ; preds = %if.then.i.i255, %postClockEnabledBlock182
  %incdec.ptr.i.i256 = getelementptr inbounds i8, i8* %str.addr.015.i.i247, i64 1
  %213 = load i8, i8* %incdec.ptr.i.i256, align 1, !tbaa !397
  %cmp.i.i257 = icmp eq i8 %213, 0
  br i1 %cmp.i.i257, label %for.cond.i467.preheader, label %for.body.i.i251

for.cond.i467.preheader:                          ; preds = %for.inc.i.i258, %postClockEnabledBlock175
  %214 = load i32, i32* @lc_disabled_count
  %clock_running183 = icmp eq i32 %214, 0
  br i1 %clock_running183, label %if_clock_enabled184, label %postClockEnabledBlock189

if_clock_enabled184:                              ; preds = %for.cond.i467.preheader
  %215 = load i64, i64* @LocalLC
  %216 = add i64 3, %215
  store i64 %216, i64* @LocalLC
  %commit185 = icmp ugt i64 %216, 5000
  br i1 %commit185, label %pushBlock187, label %postInstrumentation186

pushBlock187:                                     ; preds = %if_clock_enabled184
  %217 = add i32 %214, 1
  store i32 %217, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler188 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler188(i64 %216)
  %218 = load i32, i32* @lc_disabled_count
  %219 = sub i32 %218, 1
  store i32 %219, i32* @lc_disabled_count
  br label %postInstrumentation186

postInstrumentation186:                           ; preds = %if_clock_enabled184, %pushBlock187
  br label %postClockEnabledBlock189

postClockEnabledBlock189:                         ; preds = %for.cond.i467.preheader, %postInstrumentation186
  br label %for.cond.i467

for.cond.i467:                                    ; preds = %postClockEnabledBlock203, %postClockEnabledBlock189
  %h.0.i459 = phi i32 [ %h.1.i476, %postClockEnabledBlock203 ], [ 13, %postClockEnabledBlock189 ]
  %l.0.i460 = phi i32 [ %l.1.i477, %postClockEnabledBlock203 ], [ 0, %postClockEnabledBlock189 ]
  %add.i461 = add nsw i32 %l.0.i460, %h.0.i459
  %div.i462 = sdiv i32 %add.i461, 2
  %idxprom.i463 = sext i32 %div.i462 to i64
  %s.i464 = getelementptr inbounds [14 x %struct.strlong], [14 x %struct.strlong]* @scan_wday.wday_tab, i64 0, i64 %idxprom.i463, i32 0
  %220 = load i8*, i8** %s.i464, align 16, !tbaa !593
  %call.i465 = call i32 @strcmp(i8* nonnull %1, i8* %220) #20
  %cmp.i466 = icmp slt i32 %call.i465, 0
  br i1 %cmp.i466, label %if.then.i469, label %if.else.i471

if.then.i469:                                     ; preds = %for.cond.i467
  %sub1.i468 = add nsw i32 %div.i462, -1
  br label %if.end9.i479

if.else.i471:                                     ; preds = %for.cond.i467
  %cmp2.i470 = icmp eq i32 %call.i465, 0
  %221 = load i32, i32* @lc_disabled_count
  %clock_running190 = icmp eq i32 %221, 0
  br i1 %clock_running190, label %if_clock_enabled191, label %postClockEnabledBlock196

if_clock_enabled191:                              ; preds = %if.else.i471
  %222 = load i64, i64* @LocalLC
  %223 = add i64 10, %222
  store i64 %223, i64* @LocalLC
  %commit192 = icmp ugt i64 %223, 5000
  br i1 %commit192, label %pushBlock194, label %postInstrumentation193

pushBlock194:                                     ; preds = %if_clock_enabled191
  %224 = add i32 %221, 1
  store i32 %224, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler195 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler195(i64 %223)
  %225 = load i32, i32* @lc_disabled_count
  %226 = sub i32 %225, 1
  store i32 %226, i32* @lc_disabled_count
  br label %postInstrumentation193

postInstrumentation193:                           ; preds = %if_clock_enabled191, %pushBlock194
  br label %postClockEnabledBlock196

postClockEnabledBlock196:                         ; preds = %if.else.i471, %postInstrumentation193
  br i1 %cmp2.i470, label %land.lhs.true76, label %if.then3.i473

if.then3.i473:                                    ; preds = %postClockEnabledBlock196
  %add4.i472 = add nsw i32 %div.i462, 1
  br label %if.end9.i479

if.end9.i479:                                     ; preds = %if.then3.i473, %if.then.i469
  %h.1.i476 = phi i32 [ %sub1.i468, %if.then.i469 ], [ %h.0.i459, %if.then3.i473 ]
  %l.1.i477 = phi i32 [ %l.0.i460, %if.then.i469 ], [ %add4.i472, %if.then3.i473 ]
  %cmp10.i478 = icmp slt i32 %h.1.i476, %l.1.i477
  %227 = load i32, i32* @lc_disabled_count
  %clock_running197 = icmp eq i32 %227, 0
  br i1 %clock_running197, label %if_clock_enabled198, label %postClockEnabledBlock203

if_clock_enabled198:                              ; preds = %if.end9.i479
  %228 = load i64, i64* @LocalLC
  %229 = add i64 8, %228
  store i64 %229, i64* @LocalLC
  %commit199 = icmp ugt i64 %229, 5000
  br i1 %commit199, label %pushBlock201, label %postInstrumentation200

pushBlock201:                                     ; preds = %if_clock_enabled198
  %230 = add i32 %227, 1
  store i32 %230, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler202 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler202(i64 %229)
  %231 = load i32, i32* @lc_disabled_count
  %232 = sub i32 %231, 1
  store i32 %232, i32* @lc_disabled_count
  br label %postInstrumentation200

postInstrumentation200:                           ; preds = %if_clock_enabled198, %pushBlock201
  br label %postClockEnabledBlock203

postClockEnabledBlock203:                         ; preds = %if.end9.i479, %postInstrumentation200
  br i1 %cmp10.i478, label %if.else90, label %for.cond.i467

land.lhs.true76:                                  ; preds = %postClockEnabledBlock196
  %.b.i260 = load i1, i1* @scan_mon.sorted, align 4
  br i1 %.b.i260, label %if.end.i263, label %if.then.i261

if.then.i261:                                     ; preds = %land.lhs.true76
  call void @qsort(i8* bitcast ([23 x %struct.strlong]* @scan_mon.mon_tab to i8*), i64 23, i64 16, i32 (i8*, i8*)* nonnull @strlong_compare) #16
  store i1 true, i1* @scan_mon.sorted, align 4
  br label %if.end.i263

if.end.i263:                                      ; preds = %if.then.i261, %land.lhs.true76
  %233 = load i8, i8* %0, align 16, !tbaa !397
  %cmp14.i.i262 = icmp eq i8 %233, 0
  %234 = load i32, i32* @lc_disabled_count
  %clock_running204 = icmp eq i32 %234, 0
  br i1 %clock_running204, label %if_clock_enabled205, label %postClockEnabledBlock210

if_clock_enabled205:                              ; preds = %if.end.i263
  %235 = load i64, i64* @LocalLC
  %236 = add i64 6, %235
  store i64 %236, i64* @LocalLC
  %commit206 = icmp ugt i64 %236, 5000
  br i1 %commit206, label %pushBlock208, label %postInstrumentation207

pushBlock208:                                     ; preds = %if_clock_enabled205
  %237 = add i32 %234, 1
  store i32 %237, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler209 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler209(i64 %236)
  %238 = load i32, i32* @lc_disabled_count
  %239 = sub i32 %238, 1
  store i32 %239, i32* @lc_disabled_count
  br label %postInstrumentation207

postInstrumentation207:                           ; preds = %if_clock_enabled205, %pushBlock208
  br label %postClockEnabledBlock210

postClockEnabledBlock210:                         ; preds = %if.end.i263, %postInstrumentation207
  br i1 %cmp14.i.i262, label %for.cond.i490.preheader, label %for.body.lr.ph.i.i265

for.body.lr.ph.i.i265:                            ; preds = %postClockEnabledBlock210
  %call.i.i264 = tail call i16** @__ctype_b_loc() #11
  br label %for.body.i.i270

for.body.i.i270:                                  ; preds = %for.inc.i.i277, %for.body.lr.ph.i.i265
  %240 = phi i8 [ %233, %for.body.lr.ph.i.i265 ], [ %252, %for.inc.i.i277 ]
  %str.addr.015.i.i266 = phi i8* [ %0, %for.body.lr.ph.i.i265 ], [ %incdec.ptr.i.i275, %for.inc.i.i277 ]
  %241 = load i16*, i16** %call.i.i264, align 8, !tbaa !86
  %idxprom.i.i267 = sext i8 %240 to i64
  %arrayidx.i.i268 = getelementptr inbounds i16, i16* %241, i64 %idxprom.i.i267
  %242 = load i16, i16* %arrayidx.i.i268, align 2, !tbaa !592
  %243 = and i16 %242, 256
  %tobool.i.i269 = icmp eq i16 %243, 0
  %244 = load i32, i32* @lc_disabled_count
  %clock_running211 = icmp eq i32 %244, 0
  br i1 %clock_running211, label %if_clock_enabled212, label %postClockEnabledBlock217

if_clock_enabled212:                              ; preds = %for.body.i.i270
  %245 = load i64, i64* @LocalLC
  %246 = add i64 14, %245
  store i64 %246, i64* @LocalLC
  %commit213 = icmp ugt i64 %246, 5000
  br i1 %commit213, label %pushBlock215, label %postInstrumentation214

pushBlock215:                                     ; preds = %if_clock_enabled212
  %247 = add i32 %244, 1
  store i32 %247, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler216 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler216(i64 %246)
  %248 = load i32, i32* @lc_disabled_count
  %249 = sub i32 %248, 1
  store i32 %249, i32* @lc_disabled_count
  br label %postInstrumentation214

postInstrumentation214:                           ; preds = %if_clock_enabled212, %pushBlock215
  br label %postClockEnabledBlock217

postClockEnabledBlock217:                         ; preds = %for.body.i.i270, %postInstrumentation214
  br i1 %tobool.i.i269, label %for.inc.i.i277, label %if.then.i.i274

if.then.i.i274:                                   ; preds = %postClockEnabledBlock217
  %call4.i.i271 = tail call i32** @__ctype_tolower_loc() #11
  %250 = load i32*, i32** %call4.i.i271, align 8, !tbaa !86
  %arrayidx7.i.i272 = getelementptr inbounds i32, i32* %250, i64 %idxprom.i.i267
  %251 = load i32, i32* %arrayidx7.i.i272, align 4, !tbaa !417
  %conv8.i.i273 = trunc i32 %251 to i8
  store i8 %conv8.i.i273, i8* %str.addr.015.i.i266, align 1, !tbaa !397
  br label %for.inc.i.i277

for.inc.i.i277:                                   ; preds = %if.then.i.i274, %postClockEnabledBlock217
  %incdec.ptr.i.i275 = getelementptr inbounds i8, i8* %str.addr.015.i.i266, i64 1
  %252 = load i8, i8* %incdec.ptr.i.i275, align 1, !tbaa !397
  %cmp.i.i276 = icmp eq i8 %252, 0
  br i1 %cmp.i.i276, label %for.cond.i490.preheader, label %for.body.i.i270

for.cond.i490.preheader:                          ; preds = %for.inc.i.i277, %postClockEnabledBlock210
  %253 = load i32, i32* @lc_disabled_count
  %clock_running218 = icmp eq i32 %253, 0
  br i1 %clock_running218, label %if_clock_enabled219, label %postClockEnabledBlock224

if_clock_enabled219:                              ; preds = %for.cond.i490.preheader
  %254 = load i64, i64* @LocalLC
  %255 = add i64 3, %254
  store i64 %255, i64* @LocalLC
  %commit220 = icmp ugt i64 %255, 5000
  br i1 %commit220, label %pushBlock222, label %postInstrumentation221

pushBlock222:                                     ; preds = %if_clock_enabled219
  %256 = add i32 %253, 1
  store i32 %256, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler223 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler223(i64 %255)
  %257 = load i32, i32* @lc_disabled_count
  %258 = sub i32 %257, 1
  store i32 %258, i32* @lc_disabled_count
  br label %postInstrumentation221

postInstrumentation221:                           ; preds = %if_clock_enabled219, %pushBlock222
  br label %postClockEnabledBlock224

postClockEnabledBlock224:                         ; preds = %for.cond.i490.preheader, %postInstrumentation221
  br label %for.cond.i490

for.cond.i490:                                    ; preds = %postClockEnabledBlock238, %postClockEnabledBlock224
  %h.0.i482 = phi i32 [ %h.1.i499, %postClockEnabledBlock238 ], [ 22, %postClockEnabledBlock224 ]
  %l.0.i483 = phi i32 [ %l.1.i500, %postClockEnabledBlock238 ], [ 0, %postClockEnabledBlock224 ]
  %add.i484 = add nsw i32 %l.0.i483, %h.0.i482
  %div.i485 = sdiv i32 %add.i484, 2
  %idxprom.i486 = sext i32 %div.i485 to i64
  %s.i487 = getelementptr inbounds [23 x %struct.strlong], [23 x %struct.strlong]* @scan_mon.mon_tab, i64 0, i64 %idxprom.i486, i32 0
  %259 = load i8*, i8** %s.i487, align 16, !tbaa !593
  %call.i488 = call i32 @strcmp(i8* nonnull %0, i8* %259) #20
  %cmp.i489 = icmp slt i32 %call.i488, 0
  br i1 %cmp.i489, label %if.then.i492, label %if.else.i494

if.then.i492:                                     ; preds = %for.cond.i490
  %sub1.i491 = add nsw i32 %div.i485, -1
  br label %if.end9.i502

if.else.i494:                                     ; preds = %for.cond.i490
  %cmp2.i493 = icmp eq i32 %call.i488, 0
  %260 = load i32, i32* @lc_disabled_count
  %clock_running225 = icmp eq i32 %260, 0
  br i1 %clock_running225, label %if_clock_enabled226, label %postClockEnabledBlock231

if_clock_enabled226:                              ; preds = %if.else.i494
  %261 = load i64, i64* @LocalLC
  %262 = add i64 10, %261
  store i64 %262, i64* @LocalLC
  %commit227 = icmp ugt i64 %262, 5000
  br i1 %commit227, label %pushBlock229, label %postInstrumentation228

pushBlock229:                                     ; preds = %if_clock_enabled226
  %263 = add i32 %260, 1
  store i32 %263, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler230 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler230(i64 %262)
  %264 = load i32, i32* @lc_disabled_count
  %265 = sub i32 %264, 1
  store i32 %265, i32* @lc_disabled_count
  br label %postInstrumentation228

postInstrumentation228:                           ; preds = %if_clock_enabled226, %pushBlock229
  br label %postClockEnabledBlock231

postClockEnabledBlock231:                         ; preds = %if.else.i494, %postInstrumentation228
  br i1 %cmp2.i493, label %if.end144, label %if.then3.i496

if.then3.i496:                                    ; preds = %postClockEnabledBlock231
  %add4.i495 = add nsw i32 %div.i485, 1
  br label %if.end9.i502

if.end9.i502:                                     ; preds = %if.then3.i496, %if.then.i492
  %h.1.i499 = phi i32 [ %sub1.i491, %if.then.i492 ], [ %h.0.i482, %if.then3.i496 ]
  %l.1.i500 = phi i32 [ %l.0.i483, %if.then.i492 ], [ %add4.i495, %if.then3.i496 ]
  %cmp10.i501 = icmp slt i32 %h.1.i499, %l.1.i500
  %266 = load i32, i32* @lc_disabled_count
  %clock_running232 = icmp eq i32 %266, 0
  br i1 %clock_running232, label %if_clock_enabled233, label %postClockEnabledBlock238

if_clock_enabled233:                              ; preds = %if.end9.i502
  %267 = load i64, i64* @LocalLC
  %268 = add i64 8, %267
  store i64 %268, i64* @LocalLC
  %commit234 = icmp ugt i64 %268, 5000
  br i1 %commit234, label %pushBlock236, label %postInstrumentation235

pushBlock236:                                     ; preds = %if_clock_enabled233
  %269 = add i32 %266, 1
  store i32 %269, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler237 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler237(i64 %268)
  %270 = load i32, i32* @lc_disabled_count
  %271 = sub i32 %270, 1
  store i32 %271, i32* @lc_disabled_count
  br label %postInstrumentation235

postInstrumentation235:                           ; preds = %if_clock_enabled233, %pushBlock236
  br label %postClockEnabledBlock238

postClockEnabledBlock238:                         ; preds = %if.end9.i502, %postInstrumentation235
  br i1 %cmp10.i501, label %if.else90, label %for.cond.i490

if.else90:                                        ; preds = %postClockEnabledBlock238, %postClockEnabledBlock203, %postClockEnabledBlock168
  %call93 = call i32 (i8*, i8*, ...) @__isoc99_sscanf(i8* %cp.0, i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.5.19, i64 0, i64 0), i8* nonnull %1, i32* nonnull %tm_mday, i8* nonnull %0, i32* nonnull %tm_year, i32* nonnull %tm_hour, i32* nonnull %tm_min, i32* nonnull %tm_sec) #16
  %cmp94 = icmp eq i32 %call93, 7
  %272 = load i32, i32* @lc_disabled_count
  %clock_running239 = icmp eq i32 %272, 0
  br i1 %clock_running239, label %if_clock_enabled240, label %postClockEnabledBlock245

if_clock_enabled240:                              ; preds = %if.else90
  %273 = load i64, i64* @LocalLC
  %274 = add i64 3, %273
  store i64 %274, i64* @LocalLC
  %commit241 = icmp ugt i64 %274, 5000
  br i1 %commit241, label %pushBlock243, label %postInstrumentation242

pushBlock243:                                     ; preds = %if_clock_enabled240
  %275 = add i32 %272, 1
  store i32 %275, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler244 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler244(i64 %274)
  %276 = load i32, i32* @lc_disabled_count
  %277 = sub i32 %276, 1
  store i32 %277, i32* @lc_disabled_count
  br label %postInstrumentation242

postInstrumentation242:                           ; preds = %if_clock_enabled240, %pushBlock243
  br label %postClockEnabledBlock245

postClockEnabledBlock245:                         ; preds = %if.else90, %postInstrumentation242
  br i1 %cmp94, label %land.lhs.true96, label %if.else114

land.lhs.true96:                                  ; preds = %postClockEnabledBlock245
  %.b.i280 = load i1, i1* @scan_wday.sorted, align 4
  br i1 %.b.i280, label %if.end.i283, label %if.then.i281

if.then.i281:                                     ; preds = %land.lhs.true96
  call void @qsort(i8* bitcast ([14 x %struct.strlong]* @scan_wday.wday_tab to i8*), i64 14, i64 16, i32 (i8*, i8*)* nonnull @strlong_compare) #16
  store i1 true, i1* @scan_wday.sorted, align 4
  br label %if.end.i283

if.end.i283:                                      ; preds = %if.then.i281, %land.lhs.true96
  %278 = load i8, i8* %1, align 16, !tbaa !397
  %cmp14.i.i282 = icmp eq i8 %278, 0
  %279 = load i32, i32* @lc_disabled_count
  %clock_running246 = icmp eq i32 %279, 0
  br i1 %clock_running246, label %if_clock_enabled247, label %postClockEnabledBlock252

if_clock_enabled247:                              ; preds = %if.end.i283
  %280 = load i64, i64* @LocalLC
  %281 = add i64 6, %280
  store i64 %281, i64* @LocalLC
  %commit248 = icmp ugt i64 %281, 5000
  br i1 %commit248, label %pushBlock250, label %postInstrumentation249

pushBlock250:                                     ; preds = %if_clock_enabled247
  %282 = add i32 %279, 1
  store i32 %282, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler251 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler251(i64 %281)
  %283 = load i32, i32* @lc_disabled_count
  %284 = sub i32 %283, 1
  store i32 %284, i32* @lc_disabled_count
  br label %postInstrumentation249

postInstrumentation249:                           ; preds = %if_clock_enabled247, %pushBlock250
  br label %postClockEnabledBlock252

postClockEnabledBlock252:                         ; preds = %if.end.i283, %postInstrumentation249
  br i1 %cmp14.i.i282, label %for.cond.i513.preheader, label %for.body.lr.ph.i.i285

for.body.lr.ph.i.i285:                            ; preds = %postClockEnabledBlock252
  %call.i.i284 = tail call i16** @__ctype_b_loc() #11
  br label %for.body.i.i290

for.body.i.i290:                                  ; preds = %for.inc.i.i297, %for.body.lr.ph.i.i285
  %285 = phi i8 [ %278, %for.body.lr.ph.i.i285 ], [ %297, %for.inc.i.i297 ]
  %str.addr.015.i.i286 = phi i8* [ %1, %for.body.lr.ph.i.i285 ], [ %incdec.ptr.i.i295, %for.inc.i.i297 ]
  %286 = load i16*, i16** %call.i.i284, align 8, !tbaa !86
  %idxprom.i.i287 = sext i8 %285 to i64
  %arrayidx.i.i288 = getelementptr inbounds i16, i16* %286, i64 %idxprom.i.i287
  %287 = load i16, i16* %arrayidx.i.i288, align 2, !tbaa !592
  %288 = and i16 %287, 256
  %tobool.i.i289 = icmp eq i16 %288, 0
  %289 = load i32, i32* @lc_disabled_count
  %clock_running253 = icmp eq i32 %289, 0
  br i1 %clock_running253, label %if_clock_enabled254, label %postClockEnabledBlock259

if_clock_enabled254:                              ; preds = %for.body.i.i290
  %290 = load i64, i64* @LocalLC
  %291 = add i64 14, %290
  store i64 %291, i64* @LocalLC
  %commit255 = icmp ugt i64 %291, 5000
  br i1 %commit255, label %pushBlock257, label %postInstrumentation256

pushBlock257:                                     ; preds = %if_clock_enabled254
  %292 = add i32 %289, 1
  store i32 %292, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler258 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler258(i64 %291)
  %293 = load i32, i32* @lc_disabled_count
  %294 = sub i32 %293, 1
  store i32 %294, i32* @lc_disabled_count
  br label %postInstrumentation256

postInstrumentation256:                           ; preds = %if_clock_enabled254, %pushBlock257
  br label %postClockEnabledBlock259

postClockEnabledBlock259:                         ; preds = %for.body.i.i290, %postInstrumentation256
  br i1 %tobool.i.i289, label %for.inc.i.i297, label %if.then.i.i294

if.then.i.i294:                                   ; preds = %postClockEnabledBlock259
  %call4.i.i291 = tail call i32** @__ctype_tolower_loc() #11
  %295 = load i32*, i32** %call4.i.i291, align 8, !tbaa !86
  %arrayidx7.i.i292 = getelementptr inbounds i32, i32* %295, i64 %idxprom.i.i287
  %296 = load i32, i32* %arrayidx7.i.i292, align 4, !tbaa !417
  %conv8.i.i293 = trunc i32 %296 to i8
  store i8 %conv8.i.i293, i8* %str.addr.015.i.i286, align 1, !tbaa !397
  br label %for.inc.i.i297

for.inc.i.i297:                                   ; preds = %if.then.i.i294, %postClockEnabledBlock259
  %incdec.ptr.i.i295 = getelementptr inbounds i8, i8* %str.addr.015.i.i286, i64 1
  %297 = load i8, i8* %incdec.ptr.i.i295, align 1, !tbaa !397
  %cmp.i.i296 = icmp eq i8 %297, 0
  br i1 %cmp.i.i296, label %for.cond.i513.preheader, label %for.body.i.i290

for.cond.i513.preheader:                          ; preds = %for.inc.i.i297, %postClockEnabledBlock252
  %298 = load i32, i32* @lc_disabled_count
  %clock_running260 = icmp eq i32 %298, 0
  br i1 %clock_running260, label %if_clock_enabled261, label %postClockEnabledBlock266

if_clock_enabled261:                              ; preds = %for.cond.i513.preheader
  %299 = load i64, i64* @LocalLC
  %300 = add i64 3, %299
  store i64 %300, i64* @LocalLC
  %commit262 = icmp ugt i64 %300, 5000
  br i1 %commit262, label %pushBlock264, label %postInstrumentation263

pushBlock264:                                     ; preds = %if_clock_enabled261
  %301 = add i32 %298, 1
  store i32 %301, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler265 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler265(i64 %300)
  %302 = load i32, i32* @lc_disabled_count
  %303 = sub i32 %302, 1
  store i32 %303, i32* @lc_disabled_count
  br label %postInstrumentation263

postInstrumentation263:                           ; preds = %if_clock_enabled261, %pushBlock264
  br label %postClockEnabledBlock266

postClockEnabledBlock266:                         ; preds = %for.cond.i513.preheader, %postInstrumentation263
  br label %for.cond.i513

for.cond.i513:                                    ; preds = %postClockEnabledBlock280, %postClockEnabledBlock266
  %h.0.i505 = phi i32 [ %h.1.i522, %postClockEnabledBlock280 ], [ 13, %postClockEnabledBlock266 ]
  %l.0.i506 = phi i32 [ %l.1.i523, %postClockEnabledBlock280 ], [ 0, %postClockEnabledBlock266 ]
  %add.i507 = add nsw i32 %l.0.i506, %h.0.i505
  %div.i508 = sdiv i32 %add.i507, 2
  %idxprom.i509 = sext i32 %div.i508 to i64
  %s.i510 = getelementptr inbounds [14 x %struct.strlong], [14 x %struct.strlong]* @scan_wday.wday_tab, i64 0, i64 %idxprom.i509, i32 0
  %304 = load i8*, i8** %s.i510, align 16, !tbaa !593
  %call.i511 = call i32 @strcmp(i8* nonnull %1, i8* %304) #20
  %cmp.i512 = icmp slt i32 %call.i511, 0
  br i1 %cmp.i512, label %if.then.i515, label %if.else.i517

if.then.i515:                                     ; preds = %for.cond.i513
  %sub1.i514 = add nsw i32 %div.i508, -1
  br label %if.end9.i525

if.else.i517:                                     ; preds = %for.cond.i513
  %cmp2.i516 = icmp eq i32 %call.i511, 0
  %305 = load i32, i32* @lc_disabled_count
  %clock_running267 = icmp eq i32 %305, 0
  br i1 %clock_running267, label %if_clock_enabled268, label %postClockEnabledBlock273

if_clock_enabled268:                              ; preds = %if.else.i517
  %306 = load i64, i64* @LocalLC
  %307 = add i64 10, %306
  store i64 %307, i64* @LocalLC
  %commit269 = icmp ugt i64 %307, 5000
  br i1 %commit269, label %pushBlock271, label %postInstrumentation270

pushBlock271:                                     ; preds = %if_clock_enabled268
  %308 = add i32 %305, 1
  store i32 %308, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler272 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler272(i64 %307)
  %309 = load i32, i32* @lc_disabled_count
  %310 = sub i32 %309, 1
  store i32 %310, i32* @lc_disabled_count
  br label %postInstrumentation270

postInstrumentation270:                           ; preds = %if_clock_enabled268, %pushBlock271
  br label %postClockEnabledBlock273

postClockEnabledBlock273:                         ; preds = %if.else.i517, %postInstrumentation270
  br i1 %cmp2.i516, label %land.lhs.true100, label %if.then3.i519

if.then3.i519:                                    ; preds = %postClockEnabledBlock273
  %add4.i518 = add nsw i32 %div.i508, 1
  br label %if.end9.i525

if.end9.i525:                                     ; preds = %if.then3.i519, %if.then.i515
  %h.1.i522 = phi i32 [ %sub1.i514, %if.then.i515 ], [ %h.0.i505, %if.then3.i519 ]
  %l.1.i523 = phi i32 [ %l.0.i506, %if.then.i515 ], [ %add4.i518, %if.then3.i519 ]
  %cmp10.i524 = icmp slt i32 %h.1.i522, %l.1.i523
  %311 = load i32, i32* @lc_disabled_count
  %clock_running274 = icmp eq i32 %311, 0
  br i1 %clock_running274, label %if_clock_enabled275, label %postClockEnabledBlock280

if_clock_enabled275:                              ; preds = %if.end9.i525
  %312 = load i64, i64* @LocalLC
  %313 = add i64 8, %312
  store i64 %313, i64* @LocalLC
  %commit276 = icmp ugt i64 %313, 5000
  br i1 %commit276, label %pushBlock278, label %postInstrumentation277

pushBlock278:                                     ; preds = %if_clock_enabled275
  %314 = add i32 %311, 1
  store i32 %314, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler279 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler279(i64 %313)
  %315 = load i32, i32* @lc_disabled_count
  %316 = sub i32 %315, 1
  store i32 %316, i32* @lc_disabled_count
  br label %postInstrumentation277

postInstrumentation277:                           ; preds = %if_clock_enabled275, %pushBlock278
  br label %postClockEnabledBlock280

postClockEnabledBlock280:                         ; preds = %if.end9.i525, %postInstrumentation277
  br i1 %cmp10.i524, label %if.else114, label %for.cond.i513

land.lhs.true100:                                 ; preds = %postClockEnabledBlock273
  %.b.i300 = load i1, i1* @scan_mon.sorted, align 4
  br i1 %.b.i300, label %if.end.i303, label %if.then.i301

if.then.i301:                                     ; preds = %land.lhs.true100
  call void @qsort(i8* bitcast ([23 x %struct.strlong]* @scan_mon.mon_tab to i8*), i64 23, i64 16, i32 (i8*, i8*)* nonnull @strlong_compare) #16
  store i1 true, i1* @scan_mon.sorted, align 4
  br label %if.end.i303

if.end.i303:                                      ; preds = %if.then.i301, %land.lhs.true100
  %317 = load i8, i8* %0, align 16, !tbaa !397
  %cmp14.i.i302 = icmp eq i8 %317, 0
  %318 = load i32, i32* @lc_disabled_count
  %clock_running281 = icmp eq i32 %318, 0
  br i1 %clock_running281, label %if_clock_enabled282, label %postClockEnabledBlock287

if_clock_enabled282:                              ; preds = %if.end.i303
  %319 = load i64, i64* @LocalLC
  %320 = add i64 6, %319
  store i64 %320, i64* @LocalLC
  %commit283 = icmp ugt i64 %320, 5000
  br i1 %commit283, label %pushBlock285, label %postInstrumentation284

pushBlock285:                                     ; preds = %if_clock_enabled282
  %321 = add i32 %318, 1
  store i32 %321, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler286 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler286(i64 %320)
  %322 = load i32, i32* @lc_disabled_count
  %323 = sub i32 %322, 1
  store i32 %323, i32* @lc_disabled_count
  br label %postInstrumentation284

postInstrumentation284:                           ; preds = %if_clock_enabled282, %pushBlock285
  br label %postClockEnabledBlock287

postClockEnabledBlock287:                         ; preds = %if.end.i303, %postInstrumentation284
  br i1 %cmp14.i.i302, label %for.cond.i536.preheader, label %for.body.lr.ph.i.i305

for.body.lr.ph.i.i305:                            ; preds = %postClockEnabledBlock287
  %call.i.i304 = tail call i16** @__ctype_b_loc() #11
  br label %for.body.i.i310

for.body.i.i310:                                  ; preds = %for.inc.i.i317, %for.body.lr.ph.i.i305
  %324 = phi i8 [ %317, %for.body.lr.ph.i.i305 ], [ %336, %for.inc.i.i317 ]
  %str.addr.015.i.i306 = phi i8* [ %0, %for.body.lr.ph.i.i305 ], [ %incdec.ptr.i.i315, %for.inc.i.i317 ]
  %325 = load i16*, i16** %call.i.i304, align 8, !tbaa !86
  %idxprom.i.i307 = sext i8 %324 to i64
  %arrayidx.i.i308 = getelementptr inbounds i16, i16* %325, i64 %idxprom.i.i307
  %326 = load i16, i16* %arrayidx.i.i308, align 2, !tbaa !592
  %327 = and i16 %326, 256
  %tobool.i.i309 = icmp eq i16 %327, 0
  %328 = load i32, i32* @lc_disabled_count
  %clock_running288 = icmp eq i32 %328, 0
  br i1 %clock_running288, label %if_clock_enabled289, label %postClockEnabledBlock294

if_clock_enabled289:                              ; preds = %for.body.i.i310
  %329 = load i64, i64* @LocalLC
  %330 = add i64 14, %329
  store i64 %330, i64* @LocalLC
  %commit290 = icmp ugt i64 %330, 5000
  br i1 %commit290, label %pushBlock292, label %postInstrumentation291

pushBlock292:                                     ; preds = %if_clock_enabled289
  %331 = add i32 %328, 1
  store i32 %331, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler293 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler293(i64 %330)
  %332 = load i32, i32* @lc_disabled_count
  %333 = sub i32 %332, 1
  store i32 %333, i32* @lc_disabled_count
  br label %postInstrumentation291

postInstrumentation291:                           ; preds = %if_clock_enabled289, %pushBlock292
  br label %postClockEnabledBlock294

postClockEnabledBlock294:                         ; preds = %for.body.i.i310, %postInstrumentation291
  br i1 %tobool.i.i309, label %for.inc.i.i317, label %if.then.i.i314

if.then.i.i314:                                   ; preds = %postClockEnabledBlock294
  %call4.i.i311 = tail call i32** @__ctype_tolower_loc() #11
  %334 = load i32*, i32** %call4.i.i311, align 8, !tbaa !86
  %arrayidx7.i.i312 = getelementptr inbounds i32, i32* %334, i64 %idxprom.i.i307
  %335 = load i32, i32* %arrayidx7.i.i312, align 4, !tbaa !417
  %conv8.i.i313 = trunc i32 %335 to i8
  store i8 %conv8.i.i313, i8* %str.addr.015.i.i306, align 1, !tbaa !397
  br label %for.inc.i.i317

for.inc.i.i317:                                   ; preds = %if.then.i.i314, %postClockEnabledBlock294
  %incdec.ptr.i.i315 = getelementptr inbounds i8, i8* %str.addr.015.i.i306, i64 1
  %336 = load i8, i8* %incdec.ptr.i.i315, align 1, !tbaa !397
  %cmp.i.i316 = icmp eq i8 %336, 0
  br i1 %cmp.i.i316, label %for.cond.i536.preheader, label %for.body.i.i310

for.cond.i536.preheader:                          ; preds = %for.inc.i.i317, %postClockEnabledBlock287
  %337 = load i32, i32* @lc_disabled_count
  %clock_running295 = icmp eq i32 %337, 0
  br i1 %clock_running295, label %if_clock_enabled296, label %postClockEnabledBlock301

if_clock_enabled296:                              ; preds = %for.cond.i536.preheader
  %338 = load i64, i64* @LocalLC
  %339 = add i64 3, %338
  store i64 %339, i64* @LocalLC
  %commit297 = icmp ugt i64 %339, 5000
  br i1 %commit297, label %pushBlock299, label %postInstrumentation298

pushBlock299:                                     ; preds = %if_clock_enabled296
  %340 = add i32 %337, 1
  store i32 %340, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler300 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler300(i64 %339)
  %341 = load i32, i32* @lc_disabled_count
  %342 = sub i32 %341, 1
  store i32 %342, i32* @lc_disabled_count
  br label %postInstrumentation298

postInstrumentation298:                           ; preds = %if_clock_enabled296, %pushBlock299
  br label %postClockEnabledBlock301

postClockEnabledBlock301:                         ; preds = %for.cond.i536.preheader, %postInstrumentation298
  br label %for.cond.i536

for.cond.i536:                                    ; preds = %postClockEnabledBlock315, %postClockEnabledBlock301
  %h.0.i528 = phi i32 [ %h.1.i545, %postClockEnabledBlock315 ], [ 22, %postClockEnabledBlock301 ]
  %l.0.i529 = phi i32 [ %l.1.i546, %postClockEnabledBlock315 ], [ 0, %postClockEnabledBlock301 ]
  %add.i530 = add nsw i32 %l.0.i529, %h.0.i528
  %div.i531 = sdiv i32 %add.i530, 2
  %idxprom.i532 = sext i32 %div.i531 to i64
  %s.i533 = getelementptr inbounds [23 x %struct.strlong], [23 x %struct.strlong]* @scan_mon.mon_tab, i64 0, i64 %idxprom.i532, i32 0
  %343 = load i8*, i8** %s.i533, align 16, !tbaa !593
  %call.i534 = call i32 @strcmp(i8* nonnull %0, i8* %343) #20
  %cmp.i535 = icmp slt i32 %call.i534, 0
  br i1 %cmp.i535, label %if.then.i538, label %if.else.i540

if.then.i538:                                     ; preds = %for.cond.i536
  %sub1.i537 = add nsw i32 %div.i531, -1
  br label %if.end9.i548

if.else.i540:                                     ; preds = %for.cond.i536
  %cmp2.i539 = icmp eq i32 %call.i534, 0
  %344 = load i32, i32* @lc_disabled_count
  %clock_running302 = icmp eq i32 %344, 0
  br i1 %clock_running302, label %if_clock_enabled303, label %postClockEnabledBlock308

if_clock_enabled303:                              ; preds = %if.else.i540
  %345 = load i64, i64* @LocalLC
  %346 = add i64 10, %345
  store i64 %346, i64* @LocalLC
  %commit304 = icmp ugt i64 %346, 5000
  br i1 %commit304, label %pushBlock306, label %postInstrumentation305

pushBlock306:                                     ; preds = %if_clock_enabled303
  %347 = add i32 %344, 1
  store i32 %347, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler307 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler307(i64 %346)
  %348 = load i32, i32* @lc_disabled_count
  %349 = sub i32 %348, 1
  store i32 %349, i32* @lc_disabled_count
  br label %postInstrumentation305

postInstrumentation305:                           ; preds = %if_clock_enabled303, %pushBlock306
  br label %postClockEnabledBlock308

postClockEnabledBlock308:                         ; preds = %if.else.i540, %postInstrumentation305
  br i1 %cmp2.i539, label %if.end144, label %if.then3.i542

if.then3.i542:                                    ; preds = %postClockEnabledBlock308
  %add4.i541 = add nsw i32 %div.i531, 1
  br label %if.end9.i548

if.end9.i548:                                     ; preds = %if.then3.i542, %if.then.i538
  %h.1.i545 = phi i32 [ %sub1.i537, %if.then.i538 ], [ %h.0.i528, %if.then3.i542 ]
  %l.1.i546 = phi i32 [ %l.0.i529, %if.then.i538 ], [ %add4.i541, %if.then3.i542 ]
  %cmp10.i547 = icmp slt i32 %h.1.i545, %l.1.i546
  %350 = load i32, i32* @lc_disabled_count
  %clock_running309 = icmp eq i32 %350, 0
  br i1 %clock_running309, label %if_clock_enabled310, label %postClockEnabledBlock315

if_clock_enabled310:                              ; preds = %if.end9.i548
  %351 = load i64, i64* @LocalLC
  %352 = add i64 8, %351
  store i64 %352, i64* @LocalLC
  %commit311 = icmp ugt i64 %352, 5000
  br i1 %commit311, label %pushBlock313, label %postInstrumentation312

pushBlock313:                                     ; preds = %if_clock_enabled310
  %353 = add i32 %350, 1
  store i32 %353, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler314 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler314(i64 %352)
  %354 = load i32, i32* @lc_disabled_count
  %355 = sub i32 %354, 1
  store i32 %355, i32* @lc_disabled_count
  br label %postInstrumentation312

postInstrumentation312:                           ; preds = %if_clock_enabled310, %pushBlock313
  br label %postClockEnabledBlock315

postClockEnabledBlock315:                         ; preds = %if.end9.i548, %postInstrumentation312
  br i1 %cmp10.i547, label %if.else114, label %for.cond.i536

if.else114:                                       ; preds = %postClockEnabledBlock315, %postClockEnabledBlock280, %postClockEnabledBlock245
  %call117 = call i32 (i8*, i8*, ...) @__isoc99_sscanf(i8* %cp.0, i8* getelementptr inbounds ([39 x i8], [39 x i8]* @.str.6.20, i64 0, i64 0), i8* nonnull %1, i8* nonnull %0, i32* nonnull %tm_mday, i32* nonnull %tm_hour, i32* nonnull %tm_min, i32* nonnull %tm_sec, i32* nonnull %tm_year) #16
  %cmp118 = icmp eq i32 %call117, 7
  %356 = load i32, i32* @lc_disabled_count
  %clock_running316 = icmp eq i32 %356, 0
  br i1 %clock_running316, label %if_clock_enabled317, label %postClockEnabledBlock322

if_clock_enabled317:                              ; preds = %if.else114
  %357 = load i64, i64* @LocalLC
  %358 = add i64 3, %357
  store i64 %358, i64* @LocalLC
  %commit318 = icmp ugt i64 %358, 5000
  br i1 %commit318, label %pushBlock320, label %postInstrumentation319

pushBlock320:                                     ; preds = %if_clock_enabled317
  %359 = add i32 %356, 1
  store i32 %359, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler321 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler321(i64 %358)
  %360 = load i32, i32* @lc_disabled_count
  %361 = sub i32 %360, 1
  store i32 %361, i32* @lc_disabled_count
  br label %postInstrumentation319

postInstrumentation319:                           ; preds = %if_clock_enabled317, %pushBlock320
  br label %postClockEnabledBlock322

postClockEnabledBlock322:                         ; preds = %if.else114, %postInstrumentation319
  br i1 %cmp118, label %land.lhs.true120, label %cleanup

land.lhs.true120:                                 ; preds = %postClockEnabledBlock322
  %.b.i320 = load i1, i1* @scan_wday.sorted, align 4
  br i1 %.b.i320, label %if.end.i323, label %if.then.i321

if.then.i321:                                     ; preds = %land.lhs.true120
  call void @qsort(i8* bitcast ([14 x %struct.strlong]* @scan_wday.wday_tab to i8*), i64 14, i64 16, i32 (i8*, i8*)* nonnull @strlong_compare) #16
  store i1 true, i1* @scan_wday.sorted, align 4
  br label %if.end.i323

if.end.i323:                                      ; preds = %if.then.i321, %land.lhs.true120
  %362 = load i8, i8* %1, align 16, !tbaa !397
  %cmp14.i.i322 = icmp eq i8 %362, 0
  %363 = load i32, i32* @lc_disabled_count
  %clock_running323 = icmp eq i32 %363, 0
  br i1 %clock_running323, label %if_clock_enabled324, label %postClockEnabledBlock329

if_clock_enabled324:                              ; preds = %if.end.i323
  %364 = load i64, i64* @LocalLC
  %365 = add i64 6, %364
  store i64 %365, i64* @LocalLC
  %commit325 = icmp ugt i64 %365, 5000
  br i1 %commit325, label %pushBlock327, label %postInstrumentation326

pushBlock327:                                     ; preds = %if_clock_enabled324
  %366 = add i32 %363, 1
  store i32 %366, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler328 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler328(i64 %365)
  %367 = load i32, i32* @lc_disabled_count
  %368 = sub i32 %367, 1
  store i32 %368, i32* @lc_disabled_count
  br label %postInstrumentation326

postInstrumentation326:                           ; preds = %if_clock_enabled324, %pushBlock327
  br label %postClockEnabledBlock329

postClockEnabledBlock329:                         ; preds = %if.end.i323, %postInstrumentation326
  br i1 %cmp14.i.i322, label %for.cond.i559.preheader, label %for.body.lr.ph.i.i325

for.body.lr.ph.i.i325:                            ; preds = %postClockEnabledBlock329
  %call.i.i324 = tail call i16** @__ctype_b_loc() #11
  br label %for.body.i.i330

for.body.i.i330:                                  ; preds = %for.inc.i.i337, %for.body.lr.ph.i.i325
  %369 = phi i8 [ %362, %for.body.lr.ph.i.i325 ], [ %381, %for.inc.i.i337 ]
  %str.addr.015.i.i326 = phi i8* [ %1, %for.body.lr.ph.i.i325 ], [ %incdec.ptr.i.i335, %for.inc.i.i337 ]
  %370 = load i16*, i16** %call.i.i324, align 8, !tbaa !86
  %idxprom.i.i327 = sext i8 %369 to i64
  %arrayidx.i.i328 = getelementptr inbounds i16, i16* %370, i64 %idxprom.i.i327
  %371 = load i16, i16* %arrayidx.i.i328, align 2, !tbaa !592
  %372 = and i16 %371, 256
  %tobool.i.i329 = icmp eq i16 %372, 0
  %373 = load i32, i32* @lc_disabled_count
  %clock_running330 = icmp eq i32 %373, 0
  br i1 %clock_running330, label %if_clock_enabled331, label %postClockEnabledBlock336

if_clock_enabled331:                              ; preds = %for.body.i.i330
  %374 = load i64, i64* @LocalLC
  %375 = add i64 14, %374
  store i64 %375, i64* @LocalLC
  %commit332 = icmp ugt i64 %375, 5000
  br i1 %commit332, label %pushBlock334, label %postInstrumentation333

pushBlock334:                                     ; preds = %if_clock_enabled331
  %376 = add i32 %373, 1
  store i32 %376, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler335 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler335(i64 %375)
  %377 = load i32, i32* @lc_disabled_count
  %378 = sub i32 %377, 1
  store i32 %378, i32* @lc_disabled_count
  br label %postInstrumentation333

postInstrumentation333:                           ; preds = %if_clock_enabled331, %pushBlock334
  br label %postClockEnabledBlock336

postClockEnabledBlock336:                         ; preds = %for.body.i.i330, %postInstrumentation333
  br i1 %tobool.i.i329, label %for.inc.i.i337, label %if.then.i.i334

if.then.i.i334:                                   ; preds = %postClockEnabledBlock336
  %call4.i.i331 = tail call i32** @__ctype_tolower_loc() #11
  %379 = load i32*, i32** %call4.i.i331, align 8, !tbaa !86
  %arrayidx7.i.i332 = getelementptr inbounds i32, i32* %379, i64 %idxprom.i.i327
  %380 = load i32, i32* %arrayidx7.i.i332, align 4, !tbaa !417
  %conv8.i.i333 = trunc i32 %380 to i8
  store i8 %conv8.i.i333, i8* %str.addr.015.i.i326, align 1, !tbaa !397
  br label %for.inc.i.i337

for.inc.i.i337:                                   ; preds = %if.then.i.i334, %postClockEnabledBlock336
  %incdec.ptr.i.i335 = getelementptr inbounds i8, i8* %str.addr.015.i.i326, i64 1
  %381 = load i8, i8* %incdec.ptr.i.i335, align 1, !tbaa !397
  %cmp.i.i336 = icmp eq i8 %381, 0
  br i1 %cmp.i.i336, label %for.cond.i559.preheader, label %for.body.i.i330

for.cond.i559.preheader:                          ; preds = %for.inc.i.i337, %postClockEnabledBlock329
  %382 = load i32, i32* @lc_disabled_count
  %clock_running337 = icmp eq i32 %382, 0
  br i1 %clock_running337, label %if_clock_enabled338, label %postClockEnabledBlock343

if_clock_enabled338:                              ; preds = %for.cond.i559.preheader
  %383 = load i64, i64* @LocalLC
  %384 = add i64 3, %383
  store i64 %384, i64* @LocalLC
  %commit339 = icmp ugt i64 %384, 5000
  br i1 %commit339, label %pushBlock341, label %postInstrumentation340

pushBlock341:                                     ; preds = %if_clock_enabled338
  %385 = add i32 %382, 1
  store i32 %385, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler342 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler342(i64 %384)
  %386 = load i32, i32* @lc_disabled_count
  %387 = sub i32 %386, 1
  store i32 %387, i32* @lc_disabled_count
  br label %postInstrumentation340

postInstrumentation340:                           ; preds = %if_clock_enabled338, %pushBlock341
  br label %postClockEnabledBlock343

postClockEnabledBlock343:                         ; preds = %for.cond.i559.preheader, %postInstrumentation340
  br label %for.cond.i559

for.cond.i559:                                    ; preds = %postClockEnabledBlock357, %postClockEnabledBlock343
  %h.0.i551 = phi i32 [ %h.1.i568, %postClockEnabledBlock357 ], [ 13, %postClockEnabledBlock343 ]
  %l.0.i552 = phi i32 [ %l.1.i569, %postClockEnabledBlock357 ], [ 0, %postClockEnabledBlock343 ]
  %add.i553 = add nsw i32 %l.0.i552, %h.0.i551
  %div.i554 = sdiv i32 %add.i553, 2
  %idxprom.i555 = sext i32 %div.i554 to i64
  %s.i556 = getelementptr inbounds [14 x %struct.strlong], [14 x %struct.strlong]* @scan_wday.wday_tab, i64 0, i64 %idxprom.i555, i32 0
  %388 = load i8*, i8** %s.i556, align 16, !tbaa !593
  %call.i557 = call i32 @strcmp(i8* nonnull %1, i8* %388) #20
  %cmp.i558 = icmp slt i32 %call.i557, 0
  br i1 %cmp.i558, label %if.then.i561, label %if.else.i563

if.then.i561:                                     ; preds = %for.cond.i559
  %sub1.i560 = add nsw i32 %div.i554, -1
  br label %if.end9.i571

if.else.i563:                                     ; preds = %for.cond.i559
  %cmp2.i562 = icmp eq i32 %call.i557, 0
  %389 = load i32, i32* @lc_disabled_count
  %clock_running344 = icmp eq i32 %389, 0
  br i1 %clock_running344, label %if_clock_enabled345, label %postClockEnabledBlock350

if_clock_enabled345:                              ; preds = %if.else.i563
  %390 = load i64, i64* @LocalLC
  %391 = add i64 10, %390
  store i64 %391, i64* @LocalLC
  %commit346 = icmp ugt i64 %391, 5000
  br i1 %commit346, label %pushBlock348, label %postInstrumentation347

pushBlock348:                                     ; preds = %if_clock_enabled345
  %392 = add i32 %389, 1
  store i32 %392, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler349 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler349(i64 %391)
  %393 = load i32, i32* @lc_disabled_count
  %394 = sub i32 %393, 1
  store i32 %394, i32* @lc_disabled_count
  br label %postInstrumentation347

postInstrumentation347:                           ; preds = %if_clock_enabled345, %pushBlock348
  br label %postClockEnabledBlock350

postClockEnabledBlock350:                         ; preds = %if.else.i563, %postInstrumentation347
  br i1 %cmp2.i562, label %land.lhs.true124, label %if.then3.i565

if.then3.i565:                                    ; preds = %postClockEnabledBlock350
  %add4.i564 = add nsw i32 %div.i554, 1
  br label %if.end9.i571

if.end9.i571:                                     ; preds = %if.then3.i565, %if.then.i561
  %h.1.i568 = phi i32 [ %sub1.i560, %if.then.i561 ], [ %h.0.i551, %if.then3.i565 ]
  %l.1.i569 = phi i32 [ %l.0.i552, %if.then.i561 ], [ %add4.i564, %if.then3.i565 ]
  %cmp10.i570 = icmp slt i32 %h.1.i568, %l.1.i569
  %395 = load i32, i32* @lc_disabled_count
  %clock_running351 = icmp eq i32 %395, 0
  br i1 %clock_running351, label %if_clock_enabled352, label %postClockEnabledBlock357

if_clock_enabled352:                              ; preds = %if.end9.i571
  %396 = load i64, i64* @LocalLC
  %397 = add i64 8, %396
  store i64 %397, i64* @LocalLC
  %commit353 = icmp ugt i64 %397, 5000
  br i1 %commit353, label %pushBlock355, label %postInstrumentation354

pushBlock355:                                     ; preds = %if_clock_enabled352
  %398 = add i32 %395, 1
  store i32 %398, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler356 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler356(i64 %397)
  %399 = load i32, i32* @lc_disabled_count
  %400 = sub i32 %399, 1
  store i32 %400, i32* @lc_disabled_count
  br label %postInstrumentation354

postInstrumentation354:                           ; preds = %if_clock_enabled352, %pushBlock355
  br label %postClockEnabledBlock357

postClockEnabledBlock357:                         ; preds = %if.end9.i571, %postInstrumentation354
  br i1 %cmp10.i570, label %cleanup, label %for.cond.i559

land.lhs.true124:                                 ; preds = %postClockEnabledBlock350
  %.b.i340 = load i1, i1* @scan_mon.sorted, align 4
  br i1 %.b.i340, label %if.end.i343, label %if.then.i341

if.then.i341:                                     ; preds = %land.lhs.true124
  call void @qsort(i8* bitcast ([23 x %struct.strlong]* @scan_mon.mon_tab to i8*), i64 23, i64 16, i32 (i8*, i8*)* nonnull @strlong_compare) #16
  store i1 true, i1* @scan_mon.sorted, align 4
  br label %if.end.i343

if.end.i343:                                      ; preds = %if.then.i341, %land.lhs.true124
  %401 = load i8, i8* %0, align 16, !tbaa !397
  %cmp14.i.i342 = icmp eq i8 %401, 0
  %402 = load i32, i32* @lc_disabled_count
  %clock_running358 = icmp eq i32 %402, 0
  br i1 %clock_running358, label %if_clock_enabled359, label %postClockEnabledBlock364

if_clock_enabled359:                              ; preds = %if.end.i343
  %403 = load i64, i64* @LocalLC
  %404 = add i64 6, %403
  store i64 %404, i64* @LocalLC
  %commit360 = icmp ugt i64 %404, 5000
  br i1 %commit360, label %pushBlock362, label %postInstrumentation361

pushBlock362:                                     ; preds = %if_clock_enabled359
  %405 = add i32 %402, 1
  store i32 %405, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler363 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler363(i64 %404)
  %406 = load i32, i32* @lc_disabled_count
  %407 = sub i32 %406, 1
  store i32 %407, i32* @lc_disabled_count
  br label %postInstrumentation361

postInstrumentation361:                           ; preds = %if_clock_enabled359, %pushBlock362
  br label %postClockEnabledBlock364

postClockEnabledBlock364:                         ; preds = %if.end.i343, %postInstrumentation361
  br i1 %cmp14.i.i342, label %for.cond.i.preheader, label %for.body.lr.ph.i.i345

for.body.lr.ph.i.i345:                            ; preds = %postClockEnabledBlock364
  %call.i.i344 = tail call i16** @__ctype_b_loc() #11
  br label %for.body.i.i350

for.body.i.i350:                                  ; preds = %for.inc.i.i357, %for.body.lr.ph.i.i345
  %408 = phi i8 [ %401, %for.body.lr.ph.i.i345 ], [ %420, %for.inc.i.i357 ]
  %str.addr.015.i.i346 = phi i8* [ %0, %for.body.lr.ph.i.i345 ], [ %incdec.ptr.i.i355, %for.inc.i.i357 ]
  %409 = load i16*, i16** %call.i.i344, align 8, !tbaa !86
  %idxprom.i.i347 = sext i8 %408 to i64
  %arrayidx.i.i348 = getelementptr inbounds i16, i16* %409, i64 %idxprom.i.i347
  %410 = load i16, i16* %arrayidx.i.i348, align 2, !tbaa !592
  %411 = and i16 %410, 256
  %tobool.i.i349 = icmp eq i16 %411, 0
  %412 = load i32, i32* @lc_disabled_count
  %clock_running365 = icmp eq i32 %412, 0
  br i1 %clock_running365, label %if_clock_enabled366, label %postClockEnabledBlock371

if_clock_enabled366:                              ; preds = %for.body.i.i350
  %413 = load i64, i64* @LocalLC
  %414 = add i64 14, %413
  store i64 %414, i64* @LocalLC
  %commit367 = icmp ugt i64 %414, 5000
  br i1 %commit367, label %pushBlock369, label %postInstrumentation368

pushBlock369:                                     ; preds = %if_clock_enabled366
  %415 = add i32 %412, 1
  store i32 %415, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler370 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler370(i64 %414)
  %416 = load i32, i32* @lc_disabled_count
  %417 = sub i32 %416, 1
  store i32 %417, i32* @lc_disabled_count
  br label %postInstrumentation368

postInstrumentation368:                           ; preds = %if_clock_enabled366, %pushBlock369
  br label %postClockEnabledBlock371

postClockEnabledBlock371:                         ; preds = %for.body.i.i350, %postInstrumentation368
  br i1 %tobool.i.i349, label %for.inc.i.i357, label %if.then.i.i354

if.then.i.i354:                                   ; preds = %postClockEnabledBlock371
  %call4.i.i351 = tail call i32** @__ctype_tolower_loc() #11
  %418 = load i32*, i32** %call4.i.i351, align 8, !tbaa !86
  %arrayidx7.i.i352 = getelementptr inbounds i32, i32* %418, i64 %idxprom.i.i347
  %419 = load i32, i32* %arrayidx7.i.i352, align 4, !tbaa !417
  %conv8.i.i353 = trunc i32 %419 to i8
  store i8 %conv8.i.i353, i8* %str.addr.015.i.i346, align 1, !tbaa !397
  br label %for.inc.i.i357

for.inc.i.i357:                                   ; preds = %if.then.i.i354, %postClockEnabledBlock371
  %incdec.ptr.i.i355 = getelementptr inbounds i8, i8* %str.addr.015.i.i346, i64 1
  %420 = load i8, i8* %incdec.ptr.i.i355, align 1, !tbaa !397
  %cmp.i.i356 = icmp eq i8 %420, 0
  br i1 %cmp.i.i356, label %for.cond.i.preheader, label %for.body.i.i350

for.cond.i.preheader:                             ; preds = %for.inc.i.i357, %postClockEnabledBlock364
  %421 = load i32, i32* @lc_disabled_count
  %clock_running372 = icmp eq i32 %421, 0
  br i1 %clock_running372, label %if_clock_enabled373, label %postClockEnabledBlock378

if_clock_enabled373:                              ; preds = %for.cond.i.preheader
  %422 = load i64, i64* @LocalLC
  %423 = add i64 3, %422
  store i64 %423, i64* @LocalLC
  %commit374 = icmp ugt i64 %423, 5000
  br i1 %commit374, label %pushBlock376, label %postInstrumentation375

pushBlock376:                                     ; preds = %if_clock_enabled373
  %424 = add i32 %421, 1
  store i32 %424, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler377 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler377(i64 %423)
  %425 = load i32, i32* @lc_disabled_count
  %426 = sub i32 %425, 1
  store i32 %426, i32* @lc_disabled_count
  br label %postInstrumentation375

postInstrumentation375:                           ; preds = %if_clock_enabled373, %pushBlock376
  br label %postClockEnabledBlock378

postClockEnabledBlock378:                         ; preds = %for.cond.i.preheader, %postInstrumentation375
  br label %for.cond.i

for.cond.i:                                       ; preds = %postClockEnabledBlock392, %postClockEnabledBlock378
  %h.0.i = phi i32 [ %h.1.i, %postClockEnabledBlock392 ], [ 22, %postClockEnabledBlock378 ]
  %l.0.i = phi i32 [ %l.1.i, %postClockEnabledBlock392 ], [ 0, %postClockEnabledBlock378 ]
  %add.i362 = add nsw i32 %l.0.i, %h.0.i
  %div.i363 = sdiv i32 %add.i362, 2
  %idxprom.i364 = sext i32 %div.i363 to i64
  %s.i = getelementptr inbounds [23 x %struct.strlong], [23 x %struct.strlong]* @scan_mon.mon_tab, i64 0, i64 %idxprom.i364, i32 0
  %427 = load i8*, i8** %s.i, align 16, !tbaa !593
  %call.i365 = call i32 @strcmp(i8* nonnull %0, i8* %427) #20
  %cmp.i366 = icmp slt i32 %call.i365, 0
  br i1 %cmp.i366, label %if.then.i367, label %if.else.i

if.then.i367:                                     ; preds = %for.cond.i
  %sub1.i = add nsw i32 %div.i363, -1
  br label %if.end9.i

if.else.i:                                        ; preds = %for.cond.i
  %cmp2.i = icmp eq i32 %call.i365, 0
  %428 = load i32, i32* @lc_disabled_count
  %clock_running379 = icmp eq i32 %428, 0
  br i1 %clock_running379, label %if_clock_enabled380, label %postClockEnabledBlock385

if_clock_enabled380:                              ; preds = %if.else.i
  %429 = load i64, i64* @LocalLC
  %430 = add i64 10, %429
  store i64 %430, i64* @LocalLC
  %commit381 = icmp ugt i64 %430, 5000
  br i1 %commit381, label %pushBlock383, label %postInstrumentation382

pushBlock383:                                     ; preds = %if_clock_enabled380
  %431 = add i32 %428, 1
  store i32 %431, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler384 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler384(i64 %430)
  %432 = load i32, i32* @lc_disabled_count
  %433 = sub i32 %432, 1
  store i32 %433, i32* @lc_disabled_count
  br label %postInstrumentation382

postInstrumentation382:                           ; preds = %if_clock_enabled380, %pushBlock383
  br label %postClockEnabledBlock385

postClockEnabledBlock385:                         ; preds = %if.else.i, %postInstrumentation382
  br i1 %cmp2.i, label %if.end144, label %if.then3.i

if.then3.i:                                       ; preds = %postClockEnabledBlock385
  %add4.i = add nsw i32 %div.i363, 1
  br label %if.end9.i

if.end9.i:                                        ; preds = %if.then3.i, %if.then.i367
  %h.1.i = phi i32 [ %sub1.i, %if.then.i367 ], [ %h.0.i, %if.then3.i ]
  %l.1.i = phi i32 [ %l.0.i, %if.then.i367 ], [ %add4.i, %if.then3.i ]
  %cmp10.i = icmp slt i32 %h.1.i, %l.1.i
  %434 = load i32, i32* @lc_disabled_count
  %clock_running386 = icmp eq i32 %434, 0
  br i1 %clock_running386, label %if_clock_enabled387, label %postClockEnabledBlock392

if_clock_enabled387:                              ; preds = %if.end9.i
  %435 = load i64, i64* @LocalLC
  %436 = add i64 8, %435
  store i64 %436, i64* @LocalLC
  %commit388 = icmp ugt i64 %436, 5000
  br i1 %commit388, label %pushBlock390, label %postInstrumentation389

pushBlock390:                                     ; preds = %if_clock_enabled387
  %437 = add i32 %434, 1
  store i32 %437, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler391 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler391(i64 %436)
  %438 = load i32, i32* @lc_disabled_count
  %439 = sub i32 %438, 1
  store i32 %439, i32* @lc_disabled_count
  br label %postInstrumentation389

postInstrumentation389:                           ; preds = %if_clock_enabled387, %pushBlock390
  br label %postClockEnabledBlock392

postClockEnabledBlock392:                         ; preds = %if.end9.i, %postInstrumentation389
  br i1 %cmp10.i, label %cleanup, label %for.cond.i

if.end144:                                        ; preds = %postClockEnabledBlock385, %postClockEnabledBlock308, %postClockEnabledBlock231, %postClockEnabledBlock154, %postClockEnabledBlock112, %postClockEnabledBlock70, %postClockEnabledBlock28
  %idxprom.i395.sink = phi i64 [ %idxprom.i364, %postClockEnabledBlock385 ], [ %idxprom.i532, %postClockEnabledBlock308 ], [ %idxprom.i486, %postClockEnabledBlock231 ], [ %idxprom.i440, %postClockEnabledBlock154 ], [ %idxprom.i417, %postClockEnabledBlock112 ], [ %idxprom.i395, %postClockEnabledBlock70 ], [ %idxprom.i372, %postClockEnabledBlock28 ]
  %l8.i405 = getelementptr inbounds [23 x %struct.strlong], [23 x %struct.strlong]* @scan_mon.mon_tab, i64 0, i64 %idxprom.i395.sink, i32 1
  %tm.sroa.35.0.in = load i64, i64* %l8.i405, align 8, !tbaa !595
  %tm.sroa.43.0 = load i32, i32* %tm_year, align 4, !tbaa !417
  %tm.sroa.35.0 = trunc i64 %tm.sroa.35.0.in to i32
  %tm.sroa.27.0 = load i32, i32* %tm_mday, align 4, !tbaa !417
  %tm.sroa.19.0 = load i32, i32* %tm_hour, align 4, !tbaa !417
  %tm.sroa.11.0 = load i32, i32* %tm_min, align 4, !tbaa !417
  %tm.sroa.0.0 = load i32, i32* %tm_sec, align 4, !tbaa !417
  %cmp146 = icmp sgt i32 %tm.sroa.43.0, 1900
  br i1 %cmp146, label %if.then148, label %if.else150

if.then148:                                       ; preds = %if.end144
  %sub = add nsw i32 %tm.sroa.43.0, -1900
  br label %if.end157

if.else150:                                       ; preds = %if.end144
  %cmp152 = icmp slt i32 %tm.sroa.43.0, 70
  %add = add nsw i32 %tm.sroa.43.0, 100
  %spec.select = select i1 %cmp152, i32 %add, i32 %tm.sroa.43.0
  br label %if.end157

if.end157:                                        ; preds = %if.else150, %if.then148
  %tm.sroa.43.1 = phi i32 [ %sub, %if.then148 ], [ %spec.select, %if.else150 ]
  %440 = mul i32 %tm.sroa.43.1, 365
  %mul.i = add i32 %440, -25550
  %conv.i = sext i32 %mul.i to i64
  %sub3.i = add nsw i32 %tm.sroa.43.1, -69
  %div.i = sdiv i32 %sub3.i, 4
  %conv4.i = sext i32 %div.i to i64
  %add.i = add nsw i64 %conv.i, %conv4.i
  %cmp.i = icmp sgt i32 %tm.sroa.43.1, 200
  br i1 %cmp.i, label %if.end.i360, label %if.end23.i

if.end.i360:                                      ; preds = %if.end157
  %sub9.i = add nsw i32 %tm.sroa.43.1, -101
  %div10.i = sdiv i32 %sub9.i, 100
  %conv11.i = sext i32 %div10.i to i64
  %sub12.i = sub nsw i64 %add.i, %conv11.i
  %cmp14.i = icmp sgt i32 %tm.sroa.43.1, 500
  br i1 %cmp14.i, label %if.then16.i, label %if.end23.i_dummy

if.then16.i:                                      ; preds = %if.end.i360
  %div2075.i = udiv i32 %sub9.i, 400
  %conv21.i = zext i32 %div2075.i to i64
  %add22.i = add nsw i64 %sub12.i, %conv21.i
  br label %if.end23.i_dummy

if.end23.i_dummy:                                 ; preds = %if.end.i360, %if.then16.i
  %t.1.i.ph = phi i64 [ %sub12.i, %if.end.i360 ], [ %add22.i, %if.then16.i ]
  br label %if.end23.i

if.end23.i:                                       ; preds = %if.end23.i_dummy, %if.end157
  %t.1.i = phi i64 [ %add.i, %if.end157 ], [ %t.1.i.ph, %if.end23.i_dummy ]
  %sext = shl i64 %tm.sroa.35.0.in, 32
  %idxprom.i = ashr exact i64 %sext, 32
  %arrayidx.i = getelementptr inbounds [12 x i32], [12 x i32]* @tm_to_time.monthtab, i64 0, i64 %idxprom.i
  %441 = load i32, i32* %arrayidx.i, align 4, !tbaa !417
  %conv24.i = sext i32 %441 to i64
  %add25.i = add nsw i64 %t.1.i, %conv24.i
  %cmp27.i = icmp sgt i32 %tm.sroa.35.0, 1
  %442 = load i32, i32* @lc_disabled_count
  %clock_running393 = icmp eq i32 %442, 0
  br i1 %clock_running393, label %if_clock_enabled394, label %postClockEnabledBlock399

if_clock_enabled394:                              ; preds = %if.end23.i
  %443 = load i64, i64* @LocalLC
  %444 = add i64 34, %443
  store i64 %444, i64* @LocalLC
  %commit395 = icmp ugt i64 %444, 5000
  br i1 %commit395, label %pushBlock397, label %postInstrumentation396

pushBlock397:                                     ; preds = %if_clock_enabled394
  %445 = add i32 %442, 1
  store i32 %445, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler398 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler398(i64 %444)
  %446 = load i32, i32* @lc_disabled_count
  %447 = sub i32 %446, 1
  store i32 %447, i32* @lc_disabled_count
  br label %postInstrumentation396

postInstrumentation396:                           ; preds = %if_clock_enabled394, %pushBlock397
  br label %postClockEnabledBlock399

postClockEnabledBlock399:                         ; preds = %if.end23.i, %postInstrumentation396
  br i1 %cmp27.i, label %land.lhs.true.i, label %tm_to_time.exit

land.lhs.true.i:                                  ; preds = %postClockEnabledBlock399
  %rem.i.i = srem i32 %tm.sroa.43.1, 400
  %tobool.i.i361 = icmp eq i32 %rem.i.i, 0
  br i1 %tobool.i.i361, label %is_leap.exit.thread71.i, label %cond.true.i.i

is_leap.exit.thread71.i:                          ; preds = %land.lhs.true.i
  %inc74.i = add nsw i64 %add25.i, 1
  br label %tm_to_time.exit_dummy

cond.true.i.i:                                    ; preds = %land.lhs.true.i
  %rem1.i.i = srem i32 %tm.sroa.43.1, 100
  %tobool2.i.i = icmp eq i32 %rem1.i.i, 0
  %448 = load i32, i32* @lc_disabled_count
  %clock_running400 = icmp eq i32 %448, 0
  br i1 %clock_running400, label %if_clock_enabled401, label %postClockEnabledBlock406

if_clock_enabled401:                              ; preds = %cond.true.i.i
  %449 = load i64, i64* @LocalLC
  %450 = add i64 6, %449
  store i64 %450, i64* @LocalLC
  %commit402 = icmp ugt i64 %450, 5000
  br i1 %commit402, label %pushBlock404, label %postInstrumentation403

pushBlock404:                                     ; preds = %if_clock_enabled401
  %451 = add i32 %448, 1
  store i32 %451, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler405 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler405(i64 %450)
  %452 = load i32, i32* @lc_disabled_count
  %453 = sub i32 %452, 1
  store i32 %453, i32* @lc_disabled_count
  br label %postInstrumentation403

postInstrumentation403:                           ; preds = %if_clock_enabled401, %pushBlock404
  br label %postClockEnabledBlock406

postClockEnabledBlock406:                         ; preds = %cond.true.i.i, %postInstrumentation403
  br i1 %tobool2.i.i, label %is_leap.exit.thread.i, label %is_leap.exit.i

is_leap.exit.i:                                   ; preds = %postClockEnabledBlock406
  %rem412.i.i = and i32 %tm.sroa.43.1, 3
  %tobool5.i.i = icmp eq i32 %rem412.i.i, 0
  %inc.i = add nsw i64 %add25.i, 1
  %454 = load i32, i32* @lc_disabled_count
  %clock_running407 = icmp eq i32 %454, 0
  br i1 %clock_running407, label %if_clock_enabled408, label %postClockEnabledBlock413

if_clock_enabled408:                              ; preds = %is_leap.exit.i
  %455 = load i64, i64* @LocalLC
  %456 = add i64 4, %455
  store i64 %456, i64* @LocalLC
  %commit409 = icmp ugt i64 %456, 5000
  br i1 %commit409, label %pushBlock411, label %postInstrumentation410

pushBlock411:                                     ; preds = %if_clock_enabled408
  %457 = add i32 %454, 1
  store i32 %457, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler412 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler412(i64 %456)
  %458 = load i32, i32* @lc_disabled_count
  %459 = sub i32 %458, 1
  store i32 %459, i32* @lc_disabled_count
  br label %postInstrumentation410

postInstrumentation410:                           ; preds = %if_clock_enabled408, %pushBlock411
  br label %postClockEnabledBlock413

postClockEnabledBlock413:                         ; preds = %is_leap.exit.i, %postInstrumentation410
  br i1 %tobool5.i.i, label %tm_to_time.exit_dummy_dummy, label %is_leap.exit.thread.i

is_leap.exit.thread.i:                            ; preds = %postClockEnabledBlock413, %postClockEnabledBlock406
  %460 = load i32, i32* @lc_disabled_count
  %clock_running414 = icmp eq i32 %460, 0
  br i1 %clock_running414, label %if_clock_enabled415, label %postClockEnabledBlock420

if_clock_enabled415:                              ; preds = %is_leap.exit.thread.i
  %461 = load i64, i64* @LocalLC
  %462 = add i64 1, %461
  store i64 %462, i64* @LocalLC
  %commit416 = icmp ugt i64 %462, 5000
  br i1 %commit416, label %pushBlock418, label %postInstrumentation417

pushBlock418:                                     ; preds = %if_clock_enabled415
  %463 = add i32 %460, 1
  store i32 %463, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler419 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler419(i64 %462)
  %464 = load i32, i32* @lc_disabled_count
  %465 = sub i32 %464, 1
  store i32 %465, i32* @lc_disabled_count
  br label %postInstrumentation417

postInstrumentation417:                           ; preds = %if_clock_enabled415, %pushBlock418
  br label %postClockEnabledBlock420

postClockEnabledBlock420:                         ; preds = %is_leap.exit.thread.i, %postInstrumentation417
  br label %tm_to_time.exit_dummy_dummy

tm_to_time.exit_dummy_dummy:                      ; preds = %postClockEnabledBlock420, %postClockEnabledBlock413
  %t.2.i.ph.ph = phi i64 [ %add25.i, %postClockEnabledBlock420 ], [ %inc.i, %postClockEnabledBlock413 ]
  br label %tm_to_time.exit_dummy

tm_to_time.exit_dummy:                            ; preds = %tm_to_time.exit_dummy_dummy, %is_leap.exit.thread71.i
  %t.2.i.ph = phi i64 [ %inc74.i, %is_leap.exit.thread71.i ], [ %t.2.i.ph.ph, %tm_to_time.exit_dummy_dummy ]
  %466 = load i32, i32* @lc_disabled_count
  %clock_running421 = icmp eq i32 %466, 0
  br i1 %clock_running421, label %if_clock_enabled422, label %postClockEnabledBlock427

if_clock_enabled422:                              ; preds = %tm_to_time.exit_dummy
  %467 = load i64, i64* @LocalLC
  %468 = add i64 4, %467
  store i64 %468, i64* @LocalLC
  %commit423 = icmp ugt i64 %468, 5000
  br i1 %commit423, label %pushBlock425, label %postInstrumentation424

pushBlock425:                                     ; preds = %if_clock_enabled422
  %469 = add i32 %466, 1
  store i32 %469, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler426 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler426(i64 %468)
  %470 = load i32, i32* @lc_disabled_count
  %471 = sub i32 %470, 1
  store i32 %471, i32* @lc_disabled_count
  br label %postInstrumentation424

postInstrumentation424:                           ; preds = %if_clock_enabled422, %pushBlock425
  br label %postClockEnabledBlock427

postClockEnabledBlock427:                         ; preds = %tm_to_time.exit_dummy, %postInstrumentation424
  br label %tm_to_time.exit

tm_to_time.exit:                                  ; preds = %postClockEnabledBlock427, %postClockEnabledBlock399
  %t.2.i = phi i64 [ %add25.i, %postClockEnabledBlock399 ], [ %t.2.i.ph, %postClockEnabledBlock427 ]
  %sub32.i = add nsw i32 %tm.sroa.27.0, -1
  %conv33.i = sext i32 %sub32.i to i64
  %add34.i = add nsw i64 %t.2.i, %conv33.i
  %mul35.i = mul nsw i64 %add34.i, 24
  %conv36.i = sext i32 %tm.sroa.19.0 to i64
  %add37.i = add nsw i64 %mul35.i, %conv36.i
  %mul38.i = mul nsw i64 %add37.i, 60
  %conv39.i = sext i32 %tm.sroa.11.0 to i64
  %add40.i = add nsw i64 %mul38.i, %conv39.i
  %mul41.i = mul nsw i64 %add40.i, 60
  %conv42.i = sext i32 %tm.sroa.0.0 to i64
  %add43.i = add nsw i64 %mul41.i, %conv42.i
  %472 = load i32, i32* @lc_disabled_count
  %clock_running428 = icmp eq i32 %472, 0
  br i1 %clock_running428, label %if_clock_enabled429, label %postClockEnabledBlock434

if_clock_enabled429:                              ; preds = %tm_to_time.exit
  %473 = load i64, i64* @LocalLC
  %474 = add i64 13, %473
  store i64 %474, i64* @LocalLC
  %commit430 = icmp ugt i64 %474, 5000
  br i1 %commit430, label %pushBlock432, label %postInstrumentation431

pushBlock432:                                     ; preds = %if_clock_enabled429
  %475 = add i32 %472, 1
  store i32 %475, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler433 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler433(i64 %474)
  %476 = load i32, i32* @lc_disabled_count
  %477 = sub i32 %476, 1
  store i32 %477, i32* @lc_disabled_count
  br label %postInstrumentation431

postInstrumentation431:                           ; preds = %if_clock_enabled429, %pushBlock432
  br label %postClockEnabledBlock434

postClockEnabledBlock434:                         ; preds = %tm_to_time.exit, %postInstrumentation431
  br label %cleanup

cleanup:                                          ; preds = %postClockEnabledBlock434, %postClockEnabledBlock392, %postClockEnabledBlock357, %postClockEnabledBlock322
  %retval.0 = phi i64 [ %add43.i, %postClockEnabledBlock434 ], [ -1, %postClockEnabledBlock322 ], [ -1, %postClockEnabledBlock392 ], [ -1, %postClockEnabledBlock357 ]
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %6) #16
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %5) #16
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %4) #16
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #16
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %2) #16
  call void @llvm.lifetime.end.p0i8(i64 500, i8* nonnull %1) #16
  call void @llvm.lifetime.end.p0i8(i64 500, i8* nonnull %0) #16
  ret i64 %retval.0
}

; Function Attrs: nofree nounwind
declare i32 @__isoc99_sscanf(i8* nocapture readonly, i8* nocapture readonly, ...) local_unnamed_addr #4

; Function Attrs: nounwind readonly uwtable
define internal i32 @strlong_compare(i8* nocapture readonly %v1, i8* nocapture readonly %v2) #13 {
entry:
  %s = bitcast i8* %v1 to i8**
  %0 = load i8*, i8** %s, align 8, !tbaa !593
  %s1 = bitcast i8* %v2 to i8**
  %1 = load i8*, i8** %s1, align 8, !tbaa !593
  %call = tail call i32 @strcmp(i8* %0, i8* %1) #20
  ret i32 %call
}

; Function Attrs: nofree
declare void @qsort(i8*, i64, i64, i32 (i8*, i8*)* nocapture) local_unnamed_addr #15

; Function Attrs: nounwind readnone
declare i16** @__ctype_b_loc() local_unnamed_addr #12

; Function Attrs: nounwind readnone
declare i32** @__ctype_tolower_loc() local_unnamed_addr #12

; Function Attrs: nofree nounwind readonly
declare i32 @strcmp(i8* nocapture, i8* nocapture) local_unnamed_addr #9

; Function Attrs: nounwind uwtable
define i32 @timet_to_httpdate(i64 %t, i8* nocapture %str, i32 %strlen) local_unnamed_addr #0 {
entry:
  %t.addr = alloca i64, align 8
  %gm = alloca %struct.tm, align 8
  store i64 %t, i64* %t.addr, align 8, !tbaa !596
  %0 = bitcast %struct.tm* %gm to i8*
  call void @llvm.lifetime.start.p0i8(i64 56, i8* nonnull %0) #16
  %call = call %struct.tm* @gmtime_r(i64* nonnull %t.addr, %struct.tm* nonnull %gm) #16
  %cmp = icmp eq %struct.tm* %call, null
  br i1 %cmp, label %cleanup, label %if.end

if.end:                                           ; preds = %entry
  %conv = sext i32 %strlen to i64
  %tm_wday = getelementptr inbounds %struct.tm, %struct.tm* %gm, i64 0, i32 6
  %1 = load i32, i32* %tm_wday, align 8, !tbaa !597
  %idxprom = sext i32 %1 to i64
  %arrayidx = getelementptr inbounds [7 x i8*], [7 x i8*]* @timet_to_httpdate.day_of_week, i64 0, i64 %idxprom
  %2 = load i8*, i8** %arrayidx, align 8, !tbaa !86
  %tm_mday = getelementptr inbounds %struct.tm, %struct.tm* %gm, i64 0, i32 3
  %3 = load i32, i32* %tm_mday, align 4, !tbaa !599
  %tm_mon = getelementptr inbounds %struct.tm, %struct.tm* %gm, i64 0, i32 4
  %4 = load i32, i32* %tm_mon, align 8, !tbaa !600
  %idxprom1 = sext i32 %4 to i64
  %arrayidx2 = getelementptr inbounds [12 x i8*], [12 x i8*]* @timet_to_httpdate.months, i64 0, i64 %idxprom1
  %5 = load i8*, i8** %arrayidx2, align 8, !tbaa !86
  %tm_year = getelementptr inbounds %struct.tm, %struct.tm* %gm, i64 0, i32 5
  %6 = load i32, i32* %tm_year, align 4, !tbaa !601
  %add = add nsw i32 %6, 1900
  %tm_hour = getelementptr inbounds %struct.tm, %struct.tm* %gm, i64 0, i32 2
  %7 = load i32, i32* %tm_hour, align 8, !tbaa !602
  %tm_min = getelementptr inbounds %struct.tm, %struct.tm* %gm, i64 0, i32 1
  %8 = load i32, i32* %tm_min, align 4, !tbaa !603
  %tm_sec = getelementptr inbounds %struct.tm, %struct.tm* %gm, i64 0, i32 0
  %9 = load i32, i32* %tm_sec, align 8, !tbaa !604
  %call3 = call i32 (i8*, i64, i8*, ...) @snprintf(i8* %str, i64 %conv, i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str.26.37, i64 0, i64 0), i8* %2, i32 %3, i8* %5, i32 %add, i32 %7, i32 %8, i32 %9) #16
  %cmp4 = icmp eq i32 %call3, %strlen
  %. = sext i1 %cmp4 to i32
  br label %cleanup

cleanup:                                          ; preds = %if.end, %entry
  %retval.0 = phi i32 [ -1, %entry ], [ %., %if.end ]
  call void @llvm.lifetime.end.p0i8(i64 56, i8* nonnull %0) #16
  ret i32 %retval.0
}

; Function Attrs: nounwind
declare %struct.tm* @gmtime_r(i64*, %struct.tm*) local_unnamed_addr #10

; Function Attrs: nofree nounwind
declare i32 @snprintf(i8* nocapture, i64, i8* nocapture readonly, ...) local_unnamed_addr #4

; Function Attrs: nounwind uwtable
define i32 @GetNumCPUCores() local_unnamed_addr #0 {
entry:
  %call = tail call i64 @sysconf(i32 84) #16
  %conv = trunc i64 %call to i32
  ret i32 %conv
}

; Function Attrs: nounwind
declare i64 @sysconf(i32) local_unnamed_addr #10

; Function Attrs: nounwind uwtable
define i32 @AffinitizeThreadToCore(i32 %core) local_unnamed_addr #0 {
entry:
  %call = tail call i64 @sysconf(i32 84) #16
  %conv = trunc i64 %call to i32
  %cmp = icmp sgt i32 %core, -1
  %cmp2 = icmp sgt i32 %conv, %core
  %or.cond = and i1 %cmp, %cmp2
  br i1 %or.cond, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !86
  %call4 = tail call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %0, i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str.64, i64 0, i64 0), i32 %core) #17
  br label %cleanup

if.end:                                           ; preds = %entry
  %sext = shl i64 %call, 32
  %conv5 = ashr exact i64 %sext, 32
  %call6 = tail call %struct.cpu_set_t* @__sched_cpualloc(i64 %conv5) #16
  %cmp7 = icmp eq %struct.cpu_set_t* %call6, null
  br i1 %cmp7, label %if.then9, label %do.body

if.then9:                                         ; preds = %if.end
  %1 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !86
  %call10 = tail call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %1, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1.65, i64 0, i64 0), i32 %conv) #17
  br label %cleanup_dummy

do.body:                                          ; preds = %if.end
  %2 = bitcast %struct.cpu_set_t* %call6 to i8*
  tail call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %2, i8 0, i64 %conv5, i1 false)
  %conv13 = sext i32 %core to i64
  %div = lshr i64 %conv13, 3
  %cmp15 = icmp ult i64 %div, %conv5
  br i1 %cmp15, label %cond.true, label %cond.end

cond.true:                                        ; preds = %do.body
  %rem = and i64 %conv13, 63
  %shl = shl i64 1, %rem
  %div17 = lshr i64 %conv13, 6
  %arrayidx = getelementptr inbounds %struct.cpu_set_t, %struct.cpu_set_t* %call6, i64 0, i32 0, i64 %div17
  %3 = load i64, i64* %arrayidx, align 8, !tbaa !596
  %or = or i64 %3, %shl
  store i64 %or, i64* %arrayidx, align 8, !tbaa !596
  br label %cond.end

cond.end:                                         ; preds = %cond.true, %do.body
  %call19 = tail call i32 @sched_setaffinity(i32 0, i64 %conv5, %struct.cpu_set_t* nonnull %call6) #16
  tail call void @__sched_cpufree(%struct.cpu_set_t* nonnull %call6) #16
  br label %cleanup_dummy

cleanup_dummy:                                    ; preds = %if.then9, %cond.end
  %retval.0.ph = phi i32 [ %call19, %cond.end ], [ -1, %if.then9 ]
  br label %cleanup

cleanup:                                          ; preds = %cleanup_dummy, %if.then
  %retval.0 = phi i32 [ -1, %if.then ], [ %retval.0.ph, %cleanup_dummy ]
  ret i32 %retval.0
}

; Function Attrs: nounwind
declare %struct.cpu_set_t* @__sched_cpualloc(i64) local_unnamed_addr #10

; Function Attrs: nounwind
declare i32 @sched_setaffinity(i32, i64, %struct.cpu_set_t*) local_unnamed_addr #10

; Function Attrs: nounwind
declare void @__sched_cpufree(%struct.cpu_set_t*) local_unnamed_addr #10

; Function Attrs: nounwind uwtable
define i32 @CreateServerSocket(i32 %port, i32 %isNonBlocking) local_unnamed_addr #0 {
entry:
  %addr = alloca %struct.sockaddr_in, align 4
  %doLinger = alloca %struct.timezone, align 4
  %doReuse = alloca i32, align 4
  %0 = bitcast %struct.sockaddr_in* %addr to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %0) #16
  %1 = bitcast %struct.timezone* %doLinger to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1) #16
  %2 = bitcast i32* %doReuse to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %2) #16
  store i32 1, i32* %doReuse, align 4, !tbaa !417
  %call = tail call i32 @socket(i32 2, i32 1, i32 6) #16
  %cmp = icmp slt i32 %call, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %3 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !86
  %call1 = tail call i32* @__errno_location() #11
  %4 = load i32, i32* %call1, align 4, !tbaa !417
  %call3 = tail call i8* @strerror(i32 %4) #16
  %call4 = tail call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %3, i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.2.66, i64 0, i64 0), i32 %4, i8* %call3) #17
  br label %cleanup

if.end:                                           ; preds = %entry
  %l_linger = getelementptr inbounds %struct.timezone, %struct.timezone* %doLinger, i64 0, i32 1
  store i32 0, i32* %l_linger, align 4, !tbaa !605
  %l_onoff = getelementptr inbounds %struct.timezone, %struct.timezone* %doLinger, i64 0, i32 0
  store i32 0, i32* %l_onoff, align 4, !tbaa !607
  %call5 = call i32 @setsockopt(i32 %call, i32 1, i32 13, i8* nonnull %1, i32 8) #16
  %cmp6 = icmp eq i32 %call5, -1
  br i1 %cmp6, label %if.then7, label %if.end9

if.then7:                                         ; preds = %if.end
  %call8 = call i32 @close(i32 %call) #16
  br label %cleanup_dummy

if.end9:                                          ; preds = %if.end
  %call10 = call i32 @setsockopt(i32 %call, i32 1, i32 2, i8* nonnull %2, i32 4) #16
  %cmp11 = icmp eq i32 %call10, -1
  br i1 %cmp11, label %if.then12, label %if.end14

if.then12:                                        ; preds = %if.end9
  %call13 = call i32 @close(i32 %call) #16
  br label %cleanup_dummy_dummy

if.end14:                                         ; preds = %if.end9
  %tobool = icmp eq i32 %isNonBlocking, 0
  %5 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %5, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %if.end14
  %6 = load i64, i64* @LocalLC
  %7 = add i64 25, %6
  store i64 %7, i64* @LocalLC
  %commit = icmp ugt i64 %7, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %8 = add i32 %5, 1
  store i32 %8, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %7)
  %9 = load i32, i32* @lc_disabled_count
  %10 = sub i32 %9, 1
  store i32 %10, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %if.end14, %postInstrumentation
  br i1 %tobool, label %if.end25, label %if.then15

if.then15:                                        ; preds = %postClockEnabledBlock
  %call16 = call i32 (i32, i32, ...) @fcntl(i32 %call, i32 4, i32 2048) #16
  %cmp17 = icmp slt i32 %call16, 0
  %11 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %11, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %if.then15
  %12 = load i64, i64* @LocalLC
  %13 = add i64 3, %12
  store i64 %13, i64* @LocalLC
  %commit3 = icmp ugt i64 %13, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %14 = add i32 %11, 1
  store i32 %14, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %13)
  %15 = load i32, i32* @lc_disabled_count
  %16 = sub i32 %15, 1
  store i32 %16, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %if.then15, %postInstrumentation4
  br i1 %cmp17, label %if.then18, label %if.end25

if.then18:                                        ; preds = %postClockEnabledBlock7
  %17 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !86
  %call19 = tail call i32* @__errno_location() #11
  %18 = load i32, i32* %call19, align 4, !tbaa !417
  %call21 = call i8* @strerror(i32 %18) #16
  %call22 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %17, i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.3.67, i64 0, i64 0), i32 %18, i8* %call21) #17
  %call23 = call i32 @close(i32 %call) #16
  %19 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %19, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %if.then18
  %20 = load i64, i64* @LocalLC
  %21 = add i64 7, %20
  store i64 %21, i64* @LocalLC
  %commit10 = icmp ugt i64 %21, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %22 = add i32 %19, 1
  store i32 %22, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %21)
  %23 = load i32, i32* @lc_disabled_count
  %24 = sub i32 %23, 1
  store i32 %24, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %if.then18, %postInstrumentation11
  br label %cleanup_dummy_dummy_dummy

if.end25:                                         ; preds = %postClockEnabledBlock7, %postClockEnabledBlock
  call void @llvm.memset.p0i8.i64(i8* nonnull align 4 %0, i8 0, i64 16, i1 false)
  %sin_family = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %addr, i64 0, i32 0
  store i16 2, i16* %sin_family, align 4, !tbaa !257
  %s_addr = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %addr, i64 0, i32 2, i32 0
  store i32 0, i32* %s_addr, align 4, !tbaa !265
  %conv = trunc i32 %port to i16
  %25 = call i1 @llvm.is.constant.i16(i16 %conv)
  br i1 %25, label %if.then37, label %if.else46

if.then37:                                        ; preds = %if.end25
  %rev = call i16 @llvm.bswap.i16(i16 %conv)
  br label %if.end47

if.else46:                                        ; preds = %if.end25
  %26 = call i16 asm "rorw $$8, ${0:w}", "=r,0,~{cc},~{dirflag},~{fpsr},~{flags}"(i16 %conv) #11, !srcloc !608
  br label %if.end47

if.end47:                                         ; preds = %if.else46, %if.then37
  %__v35.0 = phi i16 [ %rev, %if.then37 ], [ %26, %if.else46 ]
  %sin_port = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %addr, i64 0, i32 1
  store i16 %__v35.0, i16* %sin_port, align 2, !tbaa !317
  %27 = bitcast %struct.sockaddr_in* %addr to %struct.sockaddr*
  %call49 = call i32 @bind(i32 %call, %struct.sockaddr* nonnull %27, i32 16) #16
  %cmp50 = icmp slt i32 %call49, 0
  br i1 %cmp50, label %if.then52, label %if.end58

if.then52:                                        ; preds = %if.end47
  %28 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !86
  %call53 = tail call i32* @__errno_location() #11
  %29 = load i32, i32* %call53, align 4, !tbaa !417
  %call55 = call i8* @strerror(i32 %29) #16
  %call56 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %28, i8* getelementptr inbounds ([32 x i8], [32 x i8]* @.str.4.68, i64 0, i64 0), i32 %29, i8* %call55) #17
  %call57 = call i32 @close(i32 %call) #16
  br label %cleanup_dummy_dummy_dummy_dummy

if.end58:                                         ; preds = %if.end47
  %call59 = call i32 @listen(i32 %call, i32 1024) #16
  %cmp60 = icmp slt i32 %call59, 0
  br i1 %cmp60, label %if.then62, label %cleanup_dummy_dummy_dummy_dummy_dummy

if.then62:                                        ; preds = %if.end58
  %call63 = call i32 @close(i32 %call) #16
  br label %cleanup_dummy_dummy_dummy_dummy_dummy

cleanup_dummy_dummy_dummy_dummy_dummy:            ; preds = %if.end58, %if.then62
  %retval.0.ph.ph.ph.ph.ph = phi i32 [ %call, %if.end58 ], [ -1, %if.then62 ]
  br label %cleanup_dummy_dummy_dummy_dummy

cleanup_dummy_dummy_dummy_dummy:                  ; preds = %cleanup_dummy_dummy_dummy_dummy_dummy, %if.then52
  %retval.0.ph.ph.ph.ph = phi i32 [ -1, %if.then52 ], [ %retval.0.ph.ph.ph.ph.ph, %cleanup_dummy_dummy_dummy_dummy_dummy ]
  %30 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %30, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %cleanup_dummy_dummy_dummy_dummy
  %31 = load i64, i64* @LocalLC
  %32 = add i64 20, %31
  store i64 %32, i64* @LocalLC
  %commit17 = icmp ugt i64 %32, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %33 = add i32 %30, 1
  store i32 %33, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %32)
  %34 = load i32, i32* @lc_disabled_count
  %35 = sub i32 %34, 1
  store i32 %35, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %cleanup_dummy_dummy_dummy_dummy, %postInstrumentation18
  br label %cleanup_dummy_dummy_dummy

cleanup_dummy_dummy_dummy:                        ; preds = %postClockEnabledBlock21, %postClockEnabledBlock14
  %retval.0.ph.ph.ph = phi i32 [ -1, %postClockEnabledBlock14 ], [ %retval.0.ph.ph.ph.ph, %postClockEnabledBlock21 ]
  br label %cleanup_dummy_dummy

cleanup_dummy_dummy:                              ; preds = %cleanup_dummy_dummy_dummy, %if.then12
  %retval.0.ph.ph = phi i32 [ -1, %if.then12 ], [ %retval.0.ph.ph.ph, %cleanup_dummy_dummy_dummy ]
  br label %cleanup_dummy

cleanup_dummy:                                    ; preds = %cleanup_dummy_dummy, %if.then7
  %retval.0.ph = phi i32 [ -1, %if.then7 ], [ %retval.0.ph.ph, %cleanup_dummy_dummy ]
  br label %cleanup

cleanup:                                          ; preds = %cleanup_dummy, %if.then
  %retval.0 = phi i32 [ -1, %if.then ], [ %retval.0.ph, %cleanup_dummy ]
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %2) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1) #16
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %0) #16
  ret i32 %retval.0
}

; Function Attrs: nounwind
declare i32 @socket(i32, i32, i32) local_unnamed_addr #10

; Function Attrs: nounwind
declare i32 @setsockopt(i32, i32, i32, i8*, i32) local_unnamed_addr #10

declare i32 @close(i32) local_unnamed_addr #2

declare i32 @fcntl(i32, i32, ...) local_unnamed_addr #2

; Function Attrs: nounwind
declare i32 @bind(i32, %struct.sockaddr*, i32) local_unnamed_addr #10

; Function Attrs: nounwind
declare i32 @listen(i32, i32) local_unnamed_addr #10

; Function Attrs: nounwind uwtable
define i32 @CreateConnectionSocket(i32 %netAddr, i32 %portNum, i32 %nonBlocking) local_unnamed_addr #0 {
entry:
  %saddr = alloca %struct.sockaddr_in, align 4
  %doLinger = alloca %struct.timezone, align 4
  %doReuse = alloca i32, align 4
  %0 = bitcast %struct.sockaddr_in* %saddr to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %0) #16
  %1 = bitcast %struct.timezone* %doLinger to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %1) #16
  %2 = bitcast i32* %doReuse to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %2) #16
  store i32 1, i32* %doReuse, align 4, !tbaa !417
  %call = tail call i32 @socket(i32 2, i32 1, i32 6) #16
  %cmp = icmp slt i32 %call, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %3 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !86
  %call1 = tail call i32* @__errno_location() #11
  %4 = load i32, i32* %call1, align 4, !tbaa !417
  %call2 = tail call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %3, i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.5.69, i64 0, i64 0), i32 %4) #17
  br label %cleanup

if.end:                                           ; preds = %entry
  %l_linger = getelementptr inbounds %struct.timezone, %struct.timezone* %doLinger, i64 0, i32 1
  store i32 0, i32* %l_linger, align 4, !tbaa !605
  %l_onoff = getelementptr inbounds %struct.timezone, %struct.timezone* %doLinger, i64 0, i32 0
  store i32 0, i32* %l_onoff, align 4, !tbaa !607
  %call3 = call i32 @setsockopt(i32 %call, i32 1, i32 13, i8* nonnull %1, i32 8) #16
  %cmp4 = icmp eq i32 %call3, -1
  br i1 %cmp4, label %if.then5, label %if.end7

if.then5:                                         ; preds = %if.end
  %call6 = call i32 @close(i32 %call) #16
  br label %cleanup_dummy

if.end7:                                          ; preds = %if.end
  %call8 = call i32 @setsockopt(i32 %call, i32 1, i32 2, i8* nonnull %2, i32 4) #16
  %cmp9 = icmp eq i32 %call8, -1
  br i1 %cmp9, label %if.then10, label %if.end12

if.then10:                                        ; preds = %if.end7
  %call11 = call i32 @close(i32 %call) #16
  br label %cleanup_dummy_dummy

if.end12:                                         ; preds = %if.end7
  %tobool = icmp eq i32 %nonBlocking, 0
  %5 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %5, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %if.end12
  %6 = load i64, i64* @LocalLC
  %7 = add i64 25, %6
  store i64 %7, i64* @LocalLC
  %commit = icmp ugt i64 %7, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %8 = add i32 %5, 1
  store i32 %8, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %7)
  %9 = load i32, i32* @lc_disabled_count
  %10 = sub i32 %9, 1
  store i32 %10, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %if.end12, %postInstrumentation
  br i1 %tobool, label %if.end21, label %if.then13

if.then13:                                        ; preds = %postClockEnabledBlock
  %call14 = call i32 (i32, i32, ...) @fcntl(i32 %call, i32 4, i32 2048) #16
  %cmp15 = icmp slt i32 %call14, 0
  %11 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %11, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %if.then13
  %12 = load i64, i64* @LocalLC
  %13 = add i64 3, %12
  store i64 %13, i64* @LocalLC
  %commit3 = icmp ugt i64 %13, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %14 = add i32 %11, 1
  store i32 %14, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %13)
  %15 = load i32, i32* @lc_disabled_count
  %16 = sub i32 %15, 1
  store i32 %16, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %if.then13, %postInstrumentation4
  br i1 %cmp15, label %if.then16, label %if.end21

if.then16:                                        ; preds = %postClockEnabledBlock7
  %17 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !86
  %call17 = tail call i32* @__errno_location() #11
  %18 = load i32, i32* %call17, align 4, !tbaa !417
  %call18 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %17, i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.6.70, i64 0, i64 0), i32 %18) #17
  %call19 = call i32 @close(i32 %call) #16
  %19 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %19, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %if.then16
  %20 = load i64, i64* @LocalLC
  %21 = add i64 6, %20
  store i64 %21, i64* @LocalLC
  %commit10 = icmp ugt i64 %21, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %22 = add i32 %19, 1
  store i32 %22, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %21)
  %23 = load i32, i32* @lc_disabled_count
  %24 = sub i32 %23, 1
  store i32 %24, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %if.then16, %postInstrumentation11
  br label %cleanup_dummy_dummy_dummy

if.end21:                                         ; preds = %postClockEnabledBlock7, %postClockEnabledBlock
  %sin_family = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %saddr, i64 0, i32 0
  store i16 2, i16* %sin_family, align 4, !tbaa !257
  %s_addr = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %saddr, i64 0, i32 2, i32 0
  store i32 %netAddr, i32* %s_addr, align 4, !tbaa !265
  %conv = trunc i32 %portNum to i16
  %25 = call i1 @llvm.is.constant.i16(i16 %conv)
  br i1 %25, label %if.then22, label %if.else

if.then22:                                        ; preds = %if.end21
  %rev = call i16 @llvm.bswap.i16(i16 %conv)
  br label %if.end27

if.else:                                          ; preds = %if.end21
  %26 = call i16 asm "rorw $$8, ${0:w}", "=r,0,~{cc},~{dirflag},~{fpsr},~{flags}"(i16 %conv) #11, !srcloc !609
  br label %if.end27

if.end27:                                         ; preds = %if.else, %if.then22
  %__v.0 = phi i16 [ %rev, %if.then22 ], [ %26, %if.else ]
  %sin_port = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %saddr, i64 0, i32 1
  store i16 %__v.0, i16* %sin_port, align 2, !tbaa !317
  %27 = bitcast %struct.sockaddr_in* %saddr to %struct.sockaddr*
  %call28 = call i32 @connect(i32 %call, %struct.sockaddr* nonnull %27, i32 16) #16
  %cmp29 = icmp slt i32 %call28, 0
  br i1 %cmp29, label %if.then31, label %cleanup_dummy_dummy_dummy_dummy

if.then31:                                        ; preds = %if.end27
  %call32 = tail call i32* @__errno_location() #11
  %28 = load i32, i32* %call32, align 4, !tbaa !417
  %cmp33 = icmp eq i32 %28, 115
  br i1 %cmp33, label %cleanup_dummy_dummy_dummy_dummy_dummy, label %if.end36

if.end36:                                         ; preds = %if.then31
  %29 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !86
  %30 = load i32, i32* %s_addr, align 4
  %call39 = call i8* @inet_ntoa(i32 %30) #16
  %31 = load i32, i32* %call32, align 4, !tbaa !417
  %call41 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %29, i8* getelementptr inbounds ([53 x i8], [53 x i8]* @.str.7.71, i64 0, i64 0), i8* %call39, i32 %portNum, i32 %31) #17
  %call42 = call i32 @close(i32 %call) #16
  br label %cleanup_dummy_dummy_dummy_dummy_dummy

cleanup_dummy_dummy_dummy_dummy_dummy:            ; preds = %if.then31, %if.end36
  %retval.0.ph.ph.ph.ph.ph = phi i32 [ %call, %if.then31 ], [ -1, %if.end36 ]
  br label %cleanup_dummy_dummy_dummy_dummy

cleanup_dummy_dummy_dummy_dummy:                  ; preds = %cleanup_dummy_dummy_dummy_dummy_dummy, %if.end27
  %retval.0.ph.ph.ph.ph = phi i32 [ %call, %if.end27 ], [ %retval.0.ph.ph.ph.ph.ph, %cleanup_dummy_dummy_dummy_dummy_dummy ]
  %32 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %32, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %cleanup_dummy_dummy_dummy_dummy
  %33 = load i64, i64* @LocalLC
  %34 = add i64 16, %33
  store i64 %34, i64* @LocalLC
  %commit17 = icmp ugt i64 %34, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %35 = add i32 %32, 1
  store i32 %35, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %34)
  %36 = load i32, i32* @lc_disabled_count
  %37 = sub i32 %36, 1
  store i32 %37, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %cleanup_dummy_dummy_dummy_dummy, %postInstrumentation18
  br label %cleanup_dummy_dummy_dummy

cleanup_dummy_dummy_dummy:                        ; preds = %postClockEnabledBlock21, %postClockEnabledBlock14
  %retval.0.ph.ph.ph = phi i32 [ -1, %postClockEnabledBlock14 ], [ %retval.0.ph.ph.ph.ph, %postClockEnabledBlock21 ]
  br label %cleanup_dummy_dummy

cleanup_dummy_dummy:                              ; preds = %cleanup_dummy_dummy_dummy, %if.then10
  %retval.0.ph.ph = phi i32 [ -1, %if.then10 ], [ %retval.0.ph.ph.ph, %cleanup_dummy_dummy_dummy ]
  br label %cleanup_dummy

cleanup_dummy:                                    ; preds = %cleanup_dummy_dummy, %if.then5
  %retval.0.ph = phi i32 [ -1, %if.then5 ], [ %retval.0.ph.ph, %cleanup_dummy_dummy ]
  br label %cleanup

cleanup:                                          ; preds = %cleanup_dummy, %if.then
  %retval.0 = phi i32 [ -1, %if.then ], [ %retval.0.ph, %cleanup_dummy ]
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %2) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %1) #16
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %0) #16
  ret i32 %retval.0
}

declare i32 @connect(i32, %struct.sockaddr*, i32) local_unnamed_addr #2

; Function Attrs: nounwind
declare i8* @inet_ntoa(i32) local_unnamed_addr #10

; Function Attrs: nounwind uwtable
define void @ParseOptions(i32 %argc, i8** nocapture readonly %argv, %struct.Options* nocapture readonly %ops) local_unnamed_addr #0 {
entry:
  %cmp68 = icmp sgt i32 %argc, 1
  br i1 %cmp68, label %for.cond1.preheader.lr.ph, label %for.end31

for.cond1.preheader.lr.ph:                        ; preds = %entry
  %op_name62 = getelementptr inbounds %struct.Options, %struct.Options* %ops, i64 0, i32 0
  %0 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %0, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %for.cond1.preheader.lr.ph
  %1 = load i64, i64* @LocalLC
  %2 = add i64 2, %1
  store i64 %2, i64* @LocalLC
  %commit = icmp ugt i64 %2, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %3 = add i32 %0, 1
  store i32 %3, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %2)
  %4 = load i32, i32* @lc_disabled_count
  %5 = sub i32 %4, 1
  store i32 %5, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %for.cond1.preheader.lr.ph, %postInstrumentation
  br label %for.cond1.preheader

for.cond1.preheader:                              ; preds = %postClockEnabledBlock63, %postClockEnabledBlock
  %indvars.iv78 = phi i64 [ 1, %postClockEnabledBlock ], [ %indvars.iv.next79, %postClockEnabledBlock63 ]
  %i.069 = phi i32 [ 1, %postClockEnabledBlock ], [ %inc30, %postClockEnabledBlock63 ]
  %6 = load i8*, i8** %op_name62, align 8, !tbaa !610
  %tobool63 = icmp eq i8* %6, null
  br i1 %tobool63, label %if.then24.loopexit81.split.loop.exit, label %for.body2.lr.ph

for.body2.lr.ph:                                  ; preds = %for.cond1.preheader
  %arrayidx7 = getelementptr inbounds i8*, i8** %argv, i64 %indvars.iv78
  %7 = load i8*, i8** %arrayidx7, align 8, !tbaa !86
  %call106 = tail call i32 @strcmp(i8* nonnull %6, i8* %7) #20
  %cmp8107 = icmp eq i32 %call106, 0
  %8 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %8, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %for.body2.lr.ph
  %9 = load i64, i64* @LocalLC
  %10 = add i64 8, %9
  store i64 %10, i64* @LocalLC
  %commit3 = icmp ugt i64 %10, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %11 = add i32 %8, 1
  store i32 %11, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %10)
  %12 = load i32, i32* @lc_disabled_count
  %13 = sub i32 %12, 1
  store i32 %13, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %for.body2.lr.ph, %postInstrumentation4
  br i1 %cmp8107, label %if.then, label %for.cond1

for.cond1:                                        ; preds = %postClockEnabledBlock14, %postClockEnabledBlock7
  %indvars.iv.next108 = phi i64 [ %indvars.iv.next, %postClockEnabledBlock14 ], [ 1, %postClockEnabledBlock7 ]
  %op_name = getelementptr inbounds %struct.Options, %struct.Options* %ops, i64 %indvars.iv.next108, i32 0
  %14 = load i8*, i8** %op_name, align 8, !tbaa !610
  %tobool = icmp eq i8* %14, null
  br i1 %tobool, label %if.then24.loopexit, label %for.body2

for.body2:                                        ; preds = %for.cond1
  %call = tail call i32 @strcmp(i8* nonnull %14, i8* %7) #20
  %cmp8 = icmp eq i32 %call, 0
  %indvars.iv.next = add nuw i64 %indvars.iv.next108, 1
  %15 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %15, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %for.body2
  %16 = load i64, i64* @LocalLC
  %17 = add i64 8, %16
  store i64 %17, i64* @LocalLC
  %commit10 = icmp ugt i64 %17, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %18 = add i32 %15, 1
  store i32 %18, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %17)
  %19 = load i32, i32* @lc_disabled_count
  %20 = sub i32 %19, 1
  store i32 %20, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %for.body2, %postInstrumentation11
  br i1 %cmp8, label %if.then, label %for.cond1

if.then:                                          ; preds = %postClockEnabledBlock14, %postClockEnabledBlock7
  %indvars.iv.lcssa = phi i64 [ 0, %postClockEnabledBlock7 ], [ %indvars.iv.next108, %postClockEnabledBlock14 ]
  %op_name66.lcssa = phi i8** [ %op_name62, %postClockEnabledBlock7 ], [ %op_name, %postClockEnabledBlock14 ]
  %21 = add nuw nsw i64 %indvars.iv78, 1
  %22 = trunc i64 %21 to i32
  %cmp9 = icmp slt i32 %22, %argc
  br i1 %cmp9, label %for.end, label %if.then10

if.then10:                                        ; preds = %if.then
  %23 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !86
  %call13 = tail call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %23, i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.8.72, i64 0, i64 0), i8* %7) #17
  tail call void @exit(i32 -1) #18
  %24 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %24, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %if.then10
  %25 = load i64, i64* @LocalLC
  %26 = add i64 4, %25
  store i64 %26, i64* @LocalLC
  %commit17 = icmp ugt i64 %26, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %27 = add i32 %24, 1
  store i32 %27, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %26)
  %28 = load i32, i32* @lc_disabled_count
  %29 = sub i32 %28, 1
  store i32 %29, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %if.then10, %postInstrumentation18
  unreachable

for.end:                                          ; preds = %if.then
  %arrayidx15 = getelementptr inbounds i8*, i8** %argv, i64 %21
  %30 = bitcast i8** %arrayidx15 to i64*
  %31 = load i64, i64* %30, align 8, !tbaa !86
  %op_varptr = getelementptr inbounds %struct.Options, %struct.Options* %ops, i64 %indvars.iv.lcssa, i32 1
  %32 = bitcast i8*** %op_varptr to i64**
  %33 = load i64*, i64** %32, align 8, !tbaa !612
  store i64 %31, i64* %33, align 8, !tbaa !86
  %.pr = load i8*, i8** %op_name66.lcssa, align 8, !tbaa !610
  %cmp23 = icmp eq i8* %.pr, null
  %34 = load i32, i32* @lc_disabled_count
  %clock_running22 = icmp eq i32 %34, 0
  br i1 %clock_running22, label %if_clock_enabled23, label %postClockEnabledBlock28

if_clock_enabled23:                               ; preds = %for.end
  %35 = load i64, i64* @LocalLC
  %36 = add i64 14, %35
  store i64 %36, i64* @LocalLC
  %commit24 = icmp ugt i64 %36, 5000
  br i1 %commit24, label %pushBlock26, label %postInstrumentation25

pushBlock26:                                      ; preds = %if_clock_enabled23
  %37 = add i32 %34, 1
  store i32 %37, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler27 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler27(i64 %36)
  %38 = load i32, i32* @lc_disabled_count
  %39 = sub i32 %38, 1
  store i32 %39, i32* @lc_disabled_count
  br label %postInstrumentation25

postInstrumentation25:                            ; preds = %if_clock_enabled23, %pushBlock26
  br label %postClockEnabledBlock28

postClockEnabledBlock28:                          ; preds = %for.end, %postInstrumentation25
  br i1 %cmp23, label %if.then24.loopexit81.split.loop.exit90, label %for.inc29

if.then24.loopexit:                               ; preds = %for.cond1
  %40 = trunc i64 %indvars.iv78 to i32
  %41 = load i32, i32* @lc_disabled_count
  %clock_running29 = icmp eq i32 %41, 0
  br i1 %clock_running29, label %if_clock_enabled30, label %postClockEnabledBlock35

if_clock_enabled30:                               ; preds = %if.then24.loopexit
  %42 = load i64, i64* @LocalLC
  %43 = add i64 6, %42
  store i64 %43, i64* @LocalLC
  %commit31 = icmp ugt i64 %43, 5000
  br i1 %commit31, label %pushBlock33, label %postInstrumentation32

pushBlock33:                                      ; preds = %if_clock_enabled30
  %44 = add i32 %41, 1
  store i32 %44, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler34 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler34(i64 %43)
  %45 = load i32, i32* @lc_disabled_count
  %46 = sub i32 %45, 1
  store i32 %46, i32* @lc_disabled_count
  br label %postInstrumentation32

postInstrumentation32:                            ; preds = %if_clock_enabled30, %pushBlock33
  br label %postClockEnabledBlock35

postClockEnabledBlock35:                          ; preds = %if.then24.loopexit, %postInstrumentation32
  br label %if.then24

if.then24.loopexit81.split.loop.exit:             ; preds = %for.cond1.preheader
  %47 = trunc i64 %indvars.iv78 to i32
  %48 = load i32, i32* @lc_disabled_count
  %clock_running36 = icmp eq i32 %48, 0
  br i1 %clock_running36, label %if_clock_enabled37, label %postClockEnabledBlock42

if_clock_enabled37:                               ; preds = %if.then24.loopexit81.split.loop.exit
  %49 = load i64, i64* @LocalLC
  %50 = add i64 5, %49
  store i64 %50, i64* @LocalLC
  %commit38 = icmp ugt i64 %50, 5000
  br i1 %commit38, label %pushBlock40, label %postInstrumentation39

pushBlock40:                                      ; preds = %if_clock_enabled37
  %51 = add i32 %48, 1
  store i32 %51, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler41 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler41(i64 %50)
  %52 = load i32, i32* @lc_disabled_count
  %53 = sub i32 %52, 1
  store i32 %53, i32* @lc_disabled_count
  br label %postInstrumentation39

postInstrumentation39:                            ; preds = %if_clock_enabled37, %pushBlock40
  br label %postClockEnabledBlock42

postClockEnabledBlock42:                          ; preds = %if.then24.loopexit81.split.loop.exit, %postInstrumentation39
  br label %if.then24

if.then24.loopexit81.split.loop.exit90:           ; preds = %postClockEnabledBlock28
  %add.le = add nuw nsw i32 %i.069, 1
  %54 = load i32, i32* @lc_disabled_count
  %clock_running43 = icmp eq i32 %54, 0
  br i1 %clock_running43, label %if_clock_enabled44, label %postClockEnabledBlock49

if_clock_enabled44:                               ; preds = %if.then24.loopexit81.split.loop.exit90
  %55 = load i64, i64* @LocalLC
  %56 = add i64 2, %55
  store i64 %56, i64* @LocalLC
  %commit45 = icmp ugt i64 %56, 5000
  br i1 %commit45, label %pushBlock47, label %postInstrumentation46

pushBlock47:                                      ; preds = %if_clock_enabled44
  %57 = add i32 %54, 1
  store i32 %57, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler48 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler48(i64 %56)
  %58 = load i32, i32* @lc_disabled_count
  %59 = sub i32 %58, 1
  store i32 %59, i32* @lc_disabled_count
  br label %postInstrumentation46

postInstrumentation46:                            ; preds = %if_clock_enabled44, %pushBlock47
  br label %postClockEnabledBlock49

postClockEnabledBlock49:                          ; preds = %if.then24.loopexit81.split.loop.exit90, %postInstrumentation46
  br label %if.then24

if.then24:                                        ; preds = %postClockEnabledBlock49, %postClockEnabledBlock42, %postClockEnabledBlock35
  %i.153 = phi i32 [ %40, %postClockEnabledBlock35 ], [ %47, %postClockEnabledBlock42 ], [ %add.le, %postClockEnabledBlock49 ]
  %60 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !86
  %idxprom25 = sext i32 %i.153 to i64
  %arrayidx26 = getelementptr inbounds i8*, i8** %argv, i64 %idxprom25
  %61 = load i8*, i8** %arrayidx26, align 8, !tbaa !86
  %call27 = tail call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %60, i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.9.73, i64 0, i64 0), i8* %61) #17
  tail call void @exit(i32 -1) #18
  %62 = load i32, i32* @lc_disabled_count
  %clock_running50 = icmp eq i32 %62, 0
  br i1 %clock_running50, label %if_clock_enabled51, label %postClockEnabledBlock56

if_clock_enabled51:                               ; preds = %if.then24
  %63 = load i64, i64* @LocalLC
  %64 = add i64 7, %63
  store i64 %64, i64* @LocalLC
  %commit52 = icmp ugt i64 %64, 5000
  br i1 %commit52, label %pushBlock54, label %postInstrumentation53

pushBlock54:                                      ; preds = %if_clock_enabled51
  %65 = add i32 %62, 1
  store i32 %65, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler55 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler55(i64 %64)
  %66 = load i32, i32* @lc_disabled_count
  %67 = sub i32 %66, 1
  store i32 %67, i32* @lc_disabled_count
  br label %postInstrumentation53

postInstrumentation53:                            ; preds = %if_clock_enabled51, %pushBlock54
  br label %postClockEnabledBlock56

postClockEnabledBlock56:                          ; preds = %if.then24, %postInstrumentation53
  unreachable

for.inc29:                                        ; preds = %postClockEnabledBlock28
  %indvars.iv.next79 = add nuw i64 %indvars.iv78, 2
  %inc30 = add nuw nsw i32 %i.069, 2
  %68 = trunc i64 %indvars.iv.next79 to i32
  %cmp = icmp slt i32 %68, %argc
  %69 = load i32, i32* @lc_disabled_count
  %clock_running57 = icmp eq i32 %69, 0
  br i1 %clock_running57, label %if_clock_enabled58, label %postClockEnabledBlock63

if_clock_enabled58:                               ; preds = %for.inc29
  %70 = load i64, i64* @LocalLC
  %71 = add i64 5, %70
  store i64 %71, i64* @LocalLC
  %commit59 = icmp ugt i64 %71, 5000
  br i1 %commit59, label %pushBlock61, label %postInstrumentation60

pushBlock61:                                      ; preds = %if_clock_enabled58
  %72 = add i32 %69, 1
  store i32 %72, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler62 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler62(i64 %71)
  %73 = load i32, i32* @lc_disabled_count
  %74 = sub i32 %73, 1
  store i32 %74, i32* @lc_disabled_count
  br label %postInstrumentation60

postInstrumentation60:                            ; preds = %if_clock_enabled58, %pushBlock61
  br label %postClockEnabledBlock63

postClockEnabledBlock63:                          ; preds = %for.inc29, %postInstrumentation60
  br i1 %cmp, label %for.cond1.preheader, label %for.end31

for.end31:                                        ; preds = %postClockEnabledBlock63, %entry
  %75 = load i32, i32* @lc_disabled_count
  %clock_running64 = icmp eq i32 %75, 0
  br i1 %clock_running64, label %if_clock_enabled65, label %postClockEnabledBlock70

if_clock_enabled65:                               ; preds = %for.end31
  %76 = load i64, i64* @LocalLC
  %77 = add i64 1, %76
  store i64 %77, i64* @LocalLC
  %commit66 = icmp ugt i64 %77, 5000
  br i1 %commit66, label %pushBlock68, label %postInstrumentation67

pushBlock68:                                      ; preds = %if_clock_enabled65
  %78 = add i32 %75, 1
  store i32 %78, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler69 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler69(i64 %77)
  %79 = load i32, i32* @lc_disabled_count
  %80 = sub i32 %79, 1
  store i32 %80, i32* @lc_disabled_count
  br label %postInstrumentation67

postInstrumentation67:                            ; preds = %if_clock_enabled65, %pushBlock68
  br label %postClockEnabledBlock70

postClockEnabledBlock70:                          ; preds = %for.end31, %postInstrumentation67
  ret void
}

; Function Attrs: nofree nounwind uwtable
define void @PrintOptions(%struct.Options* nocapture readonly %ops, i32 %printVal) local_unnamed_addr #7 {
entry:
  %tobool = icmp ne i32 %printVal, 0
  %.sink = select i1 %tobool, i8* getelementptr inbounds ([41 x i8], [41 x i8]* @str.15, i64 0, i64 0), i8* getelementptr inbounds ([39 x i8], [39 x i8]* @str.74, i64 0, i64 0)
  %puts = tail call i32 @puts(i8* %.sink)
  %op_name20 = getelementptr inbounds %struct.Options, %struct.Options* %ops, i64 0, i32 0
  %0 = load i8*, i8** %op_name20, align 8, !tbaa !610
  %tobool221 = icmp eq i8* %0, null
  br i1 %tobool221, label %for.end, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %entry
  %1 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %1, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %for.body.lr.ph
  %2 = load i64, i64* @LocalLC
  %3 = add i64 1, %2
  store i64 %3, i64* @LocalLC
  %commit = icmp ugt i64 %3, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %4 = add i32 %1, 1
  store i32 %4, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %3)
  %5 = load i32, i32* @lc_disabled_count
  %6 = sub i32 %5, 1
  store i32 %6, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %for.body.lr.ph, %postInstrumentation
  br i1 %tobool, label %for.body.us, label %for.body

for.body.us:                                      ; preds = %postClockEnabledBlock7, %postClockEnabledBlock
  %indvars.iv = phi i64 [ %indvars.iv.next, %postClockEnabledBlock7 ], [ 0, %postClockEnabledBlock ]
  %7 = phi i8* [ %9, %postClockEnabledBlock7 ], [ %0, %postClockEnabledBlock ]
  %op_varptr.us = getelementptr inbounds %struct.Options, %struct.Options* %ops, i64 %indvars.iv, i32 1
  %8 = load i8**, i8*** %op_varptr.us, align 8, !tbaa !612
  %cond.us = load i8*, i8** %8, align 8, !tbaa !86
  %call11.us = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.12.75, i64 0, i64 0), i8* nonnull %7, i8* %cond.us)
  %indvars.iv.next = add nuw i64 %indvars.iv, 1
  %op_name.us = getelementptr inbounds %struct.Options, %struct.Options* %ops, i64 %indvars.iv.next, i32 0
  %9 = load i8*, i8** %op_name.us, align 8, !tbaa !610
  %tobool2.us = icmp eq i8* %9, null
  %10 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %10, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %for.body.us
  %11 = load i64, i64* @LocalLC
  %12 = add i64 9, %11
  store i64 %12, i64* @LocalLC
  %commit3 = icmp ugt i64 %12, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %13 = add i32 %10, 1
  store i32 %13, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %12)
  %14 = load i32, i32* @lc_disabled_count
  %15 = sub i32 %14, 1
  store i32 %15, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %for.body.us, %postInstrumentation4
  br i1 %tobool2.us, label %for.end_dummy, label %for.body.us

for.body:                                         ; preds = %postClockEnabledBlock14, %postClockEnabledBlock
  %indvars.iv25 = phi i64 [ %indvars.iv.next26, %postClockEnabledBlock14 ], [ 0, %postClockEnabledBlock ]
  %16 = phi i8* [ %17, %postClockEnabledBlock14 ], [ %0, %postClockEnabledBlock ]
  %op_comment = getelementptr inbounds %struct.Options, %struct.Options* %ops, i64 %indvars.iv25, i32 2
  %cond = load i8*, i8** %op_comment, align 8, !tbaa !86
  %call11 = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.12.75, i64 0, i64 0), i8* nonnull %16, i8* %cond)
  %indvars.iv.next26 = add nuw i64 %indvars.iv25, 1
  %op_name = getelementptr inbounds %struct.Options, %struct.Options* %ops, i64 %indvars.iv.next26, i32 0
  %17 = load i8*, i8** %op_name, align 8, !tbaa !610
  %tobool2 = icmp eq i8* %17, null
  %18 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %18, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %for.body
  %19 = load i64, i64* @LocalLC
  %20 = add i64 8, %19
  store i64 %20, i64* @LocalLC
  %commit10 = icmp ugt i64 %20, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %21 = add i32 %18, 1
  store i32 %21, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %20)
  %22 = load i32, i32* @lc_disabled_count
  %23 = sub i32 %22, 1
  store i32 %23, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %for.body, %postInstrumentation11
  br i1 %tobool2, label %for.end_dummy, label %for.body

for.end_dummy:                                    ; preds = %postClockEnabledBlock7, %postClockEnabledBlock14
  %24 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %24, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %for.end_dummy
  %25 = load i64, i64* @LocalLC
  %26 = add i64 1, %25
  store i64 %26, i64* @LocalLC
  %commit17 = icmp ugt i64 %26, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %27 = add i32 %24, 1
  store i32 %27, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %26)
  %28 = load i32, i32* @lc_disabled_count
  %29 = sub i32 %28, 1
  store i32 %29, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %for.end_dummy, %postInstrumentation18
  br label %for.end

for.end:                                          ; preds = %postClockEnabledBlock21, %entry
  ret void
}

; Function Attrs: nounwind readonly uwtable
define i8* @GetHeaderString(i8* readonly %buf, i8* nocapture readonly %header, i32 %hdrsize) local_unnamed_addr #13 {
entry:
  %call = tail call i8* @strstr(i8* %buf, i8* %header) #20
  %tobool = icmp eq i8* %call, null
  br i1 %tobool, label %cleanup, label %if.then

if.then:                                          ; preds = %entry
  %idx.ext = sext i32 %hdrsize to i64
  %add.ptr = getelementptr inbounds i8, i8* %call, i64 %idx.ext
  %0 = load i8, i8* %add.ptr, align 1, !tbaa !397
  %tobool115 = icmp eq i8 %0, 0
  %1 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %1, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %if.then
  %2 = load i64, i64* @LocalLC
  %3 = add i64 5, %2
  store i64 %3, i64* @LocalLC
  %commit = icmp ugt i64 %3, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %4 = add i32 %1, 1
  store i32 %4, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %3)
  %5 = load i32, i32* @lc_disabled_count
  %6 = sub i32 %5, 1
  store i32 %6, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %if.then, %postInstrumentation
  br i1 %tobool115, label %cleanup_dummy, label %land.rhs.lr.ph

land.rhs.lr.ph:                                   ; preds = %postClockEnabledBlock
  %call2 = tail call i16** @__ctype_b_loc() #11
  %7 = load i16*, i16** %call2, align 8, !tbaa !86
  %8 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %8, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %land.rhs.lr.ph
  %9 = load i64, i64* @LocalLC
  %10 = add i64 3, %9
  store i64 %10, i64* @LocalLC
  %commit3 = icmp ugt i64 %10, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %11 = add i32 %8, 1
  store i32 %11, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %10)
  %12 = load i32, i32* @lc_disabled_count
  %13 = sub i32 %12, 1
  store i32 %13, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %land.rhs.lr.ph, %postInstrumentation4
  br label %land.rhs

land.rhs:                                         ; preds = %postClockEnabledBlock21, %postClockEnabledBlock7
  %14 = phi i8 [ %0, %postClockEnabledBlock7 ], [ %23, %postClockEnabledBlock21 ]
  %temp.016 = phi i8* [ %add.ptr, %postClockEnabledBlock7 ], [ %incdec.ptr, %postClockEnabledBlock21 ]
  %idxprom = sext i8 %14 to i64
  %arrayidx = getelementptr inbounds i16, i16* %7, i64 %idxprom
  %15 = load i16, i16* %arrayidx, align 2, !tbaa !592
  %16 = and i16 %15, 8192
  %tobool5 = icmp eq i16 %16, 0
  %17 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %17, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %land.rhs
  %18 = load i64, i64* @LocalLC
  %19 = add i64 6, %18
  store i64 %19, i64* @LocalLC
  %commit10 = icmp ugt i64 %19, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %20 = add i32 %17, 1
  store i32 %20, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %19)
  %21 = load i32, i32* @lc_disabled_count
  %22 = sub i32 %21, 1
  store i32 %22, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %land.rhs, %postInstrumentation11
  br i1 %tobool5, label %cleanup_dummy, label %while.body

while.body:                                       ; preds = %postClockEnabledBlock14
  %incdec.ptr = getelementptr inbounds i8, i8* %temp.016, i64 1
  %23 = load i8, i8* %incdec.ptr, align 1, !tbaa !397
  %tobool1 = icmp eq i8 %23, 0
  %24 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %24, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %while.body
  %25 = load i64, i64* @LocalLC
  %26 = add i64 4, %25
  store i64 %26, i64* @LocalLC
  %commit17 = icmp ugt i64 %26, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %27 = add i32 %24, 1
  store i32 %27, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %26)
  %28 = load i32, i32* @lc_disabled_count
  %29 = sub i32 %28, 1
  store i32 %29, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %while.body, %postInstrumentation18
  br i1 %tobool1, label %cleanup_dummy, label %land.rhs

cleanup_dummy:                                    ; preds = %postClockEnabledBlock, %postClockEnabledBlock14, %postClockEnabledBlock21
  %retval.0.ph = phi i8* [ %temp.016, %postClockEnabledBlock14 ], [ null, %postClockEnabledBlock21 ], [ null, %postClockEnabledBlock ]
  %30 = load i32, i32* @lc_disabled_count
  %clock_running22 = icmp eq i32 %30, 0
  br i1 %clock_running22, label %if_clock_enabled23, label %postClockEnabledBlock28

if_clock_enabled23:                               ; preds = %cleanup_dummy
  %31 = load i64, i64* @LocalLC
  %32 = add i64 1, %31
  store i64 %32, i64* @LocalLC
  %commit24 = icmp ugt i64 %32, 5000
  br i1 %commit24, label %pushBlock26, label %postInstrumentation25

pushBlock26:                                      ; preds = %if_clock_enabled23
  %33 = add i32 %30, 1
  store i32 %33, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler27 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler27(i64 %32)
  %34 = load i32, i32* @lc_disabled_count
  %35 = sub i32 %34, 1
  store i32 %35, i32* @lc_disabled_count
  br label %postInstrumentation25

postInstrumentation25:                            ; preds = %if_clock_enabled23, %pushBlock26
  br label %postClockEnabledBlock28

postClockEnabledBlock28:                          ; preds = %cleanup_dummy, %postInstrumentation25
  br label %cleanup

cleanup:                                          ; preds = %postClockEnabledBlock28, %entry
  %retval.0 = phi i8* [ null, %entry ], [ %retval.0.ph, %postClockEnabledBlock28 ]
  ret i8* %retval.0
}

; Function Attrs: nofree nounwind readonly
declare i8* @strstr(i8*, i8* nocapture) local_unnamed_addr #9

; Function Attrs: nofree nounwind uwtable
define i32 @GetHeaderLong(i8* readonly %buf, i8* nocapture readonly %header, i32 %hdrsize, i64* nocapture %val) local_unnamed_addr #7 {
entry:
  %call.i = tail call i8* @strstr(i8* %buf, i8* %header) #20
  %tobool.i = icmp eq i8* %call.i, null
  br i1 %tobool.i, label %cleanup, label %if.then.i

if.then.i:                                        ; preds = %entry
  %idx.ext.i = sext i32 %hdrsize to i64
  %add.ptr.i = getelementptr inbounds i8, i8* %call.i, i64 %idx.ext.i
  %0 = load i8, i8* %add.ptr.i, align 1, !tbaa !397
  %tobool115.i = icmp eq i8 %0, 0
  %1 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %1, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %if.then.i
  %2 = load i64, i64* @LocalLC
  %3 = add i64 5, %2
  store i64 %3, i64* @LocalLC
  %commit = icmp ugt i64 %3, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %4 = add i32 %1, 1
  store i32 %4, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %3)
  %5 = load i32, i32* @lc_disabled_count
  %6 = sub i32 %5, 1
  store i32 %6, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %if.then.i, %postInstrumentation
  br i1 %tobool115.i, label %cleanup_dummy, label %land.rhs.lr.ph.i

land.rhs.lr.ph.i:                                 ; preds = %postClockEnabledBlock
  %call2.i = tail call i16** @__ctype_b_loc() #11
  %7 = load i16*, i16** %call2.i, align 8, !tbaa !86
  %8 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %8, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %land.rhs.lr.ph.i
  %9 = load i64, i64* @LocalLC
  %10 = add i64 3, %9
  store i64 %10, i64* @LocalLC
  %commit3 = icmp ugt i64 %10, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %11 = add i32 %8, 1
  store i32 %11, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %10)
  %12 = load i32, i32* @lc_disabled_count
  %13 = sub i32 %12, 1
  store i32 %13, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %land.rhs.lr.ph.i, %postInstrumentation4
  br label %land.rhs.i

land.rhs.i:                                       ; preds = %postClockEnabledBlock14, %postClockEnabledBlock7
  %14 = phi i8 [ %0, %postClockEnabledBlock7 ], [ %17, %postClockEnabledBlock14 ]
  %temp.016.i = phi i8* [ %add.ptr.i, %postClockEnabledBlock7 ], [ %incdec.ptr.i, %postClockEnabledBlock14 ]
  %idxprom.i = sext i8 %14 to i64
  %arrayidx.i = getelementptr inbounds i16, i16* %7, i64 %idxprom.i
  %15 = load i16, i16* %arrayidx.i, align 2, !tbaa !592
  %16 = and i16 %15, 8192
  %tobool5.i = icmp eq i16 %16, 0
  br i1 %tobool5.i, label %if.then, label %while.body.i

while.body.i:                                     ; preds = %land.rhs.i
  %incdec.ptr.i = getelementptr inbounds i8, i8* %temp.016.i, i64 1
  %17 = load i8, i8* %incdec.ptr.i, align 1, !tbaa !397
  %tobool1.i = icmp eq i8 %17, 0
  %18 = load i32, i32* @lc_disabled_count
  %clock_running8 = icmp eq i32 %18, 0
  br i1 %clock_running8, label %if_clock_enabled9, label %postClockEnabledBlock14

if_clock_enabled9:                                ; preds = %while.body.i
  %19 = load i64, i64* @LocalLC
  %20 = add i64 10, %19
  store i64 %20, i64* @LocalLC
  %commit10 = icmp ugt i64 %20, 5000
  br i1 %commit10, label %pushBlock12, label %postInstrumentation11

pushBlock12:                                      ; preds = %if_clock_enabled9
  %21 = add i32 %18, 1
  store i32 %21, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler13 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler13(i64 %20)
  %22 = load i32, i32* @lc_disabled_count
  %23 = sub i32 %22, 1
  store i32 %23, i32* @lc_disabled_count
  br label %postInstrumentation11

postInstrumentation11:                            ; preds = %if_clock_enabled9, %pushBlock12
  br label %postClockEnabledBlock14

postClockEnabledBlock14:                          ; preds = %while.body.i, %postInstrumentation11
  br i1 %tobool1.i, label %cleanup_dummy, label %land.rhs.i

if.then:                                          ; preds = %land.rhs.i
  %call1 = tail call i64 @strtol(i8* nocapture nonnull %temp.016.i, i8** null, i32 10) #16
  %call2 = tail call i32* @__errno_location() #11
  %24 = load i32, i32* %call2, align 4, !tbaa !417
  %25 = load i32, i32* @lc_disabled_count
  %clock_running15 = icmp eq i32 %25, 0
  br i1 %clock_running15, label %if_clock_enabled16, label %postClockEnabledBlock21

if_clock_enabled16:                               ; preds = %if.then
  %26 = load i64, i64* @LocalLC
  %27 = add i64 10, %26
  store i64 %27, i64* @LocalLC
  %commit17 = icmp ugt i64 %27, 5000
  br i1 %commit17, label %pushBlock19, label %postInstrumentation18

pushBlock19:                                      ; preds = %if_clock_enabled16
  %28 = add i32 %25, 1
  store i32 %28, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler20 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler20(i64 %27)
  %29 = load i32, i32* @lc_disabled_count
  %30 = sub i32 %29, 1
  store i32 %30, i32* @lc_disabled_count
  br label %postInstrumentation18

postInstrumentation18:                            ; preds = %if_clock_enabled16, %pushBlock19
  br label %postClockEnabledBlock21

postClockEnabledBlock21:                          ; preds = %if.then, %postInstrumentation18
  switch i32 %24, label %if.then6 [
    i32 34, label %cleanup_dummy_dummy
    i32 22, label %cleanup_dummy_dummy
  ]

if.then6:                                         ; preds = %postClockEnabledBlock21
  store i64 %call1, i64* %val, align 8, !tbaa !596
  %31 = load i32, i32* @lc_disabled_count
  %clock_running22 = icmp eq i32 %31, 0
  br i1 %clock_running22, label %if_clock_enabled23, label %postClockEnabledBlock28

if_clock_enabled23:                               ; preds = %if.then6
  %32 = load i64, i64* @LocalLC
  %33 = add i64 2, %32
  store i64 %33, i64* @LocalLC
  %commit24 = icmp ugt i64 %33, 5000
  br i1 %commit24, label %pushBlock26, label %postInstrumentation25

pushBlock26:                                      ; preds = %if_clock_enabled23
  %34 = add i32 %31, 1
  store i32 %34, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler27 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler27(i64 %33)
  %35 = load i32, i32* @lc_disabled_count
  %36 = sub i32 %35, 1
  store i32 %36, i32* @lc_disabled_count
  br label %postInstrumentation25

postInstrumentation25:                            ; preds = %if_clock_enabled23, %pushBlock26
  br label %postClockEnabledBlock28

postClockEnabledBlock28:                          ; preds = %if.then6, %postInstrumentation25
  br label %cleanup_dummy_dummy

cleanup_dummy_dummy:                              ; preds = %postClockEnabledBlock28, %postClockEnabledBlock21, %postClockEnabledBlock21
  %retval.0.ph.ph = phi i32 [ 1, %postClockEnabledBlock28 ], [ 0, %postClockEnabledBlock21 ], [ 0, %postClockEnabledBlock21 ]
  %37 = load i32, i32* @lc_disabled_count
  %clock_running29 = icmp eq i32 %37, 0
  br i1 %clock_running29, label %if_clock_enabled30, label %postClockEnabledBlock35

if_clock_enabled30:                               ; preds = %cleanup_dummy_dummy
  %38 = load i64, i64* @LocalLC
  %39 = add i64 1, %38
  store i64 %39, i64* @LocalLC
  %commit31 = icmp ugt i64 %39, 5000
  br i1 %commit31, label %pushBlock33, label %postInstrumentation32

pushBlock33:                                      ; preds = %if_clock_enabled30
  %40 = add i32 %37, 1
  store i32 %40, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler34 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler34(i64 %39)
  %41 = load i32, i32* @lc_disabled_count
  %42 = sub i32 %41, 1
  store i32 %42, i32* @lc_disabled_count
  br label %postInstrumentation32

postInstrumentation32:                            ; preds = %if_clock_enabled30, %pushBlock33
  br label %postClockEnabledBlock35

postClockEnabledBlock35:                          ; preds = %cleanup_dummy_dummy, %postInstrumentation32
  br label %cleanup_dummy

cleanup_dummy:                                    ; preds = %postClockEnabledBlock35, %postClockEnabledBlock, %postClockEnabledBlock14
  %retval.0.ph = phi i32 [ 0, %postClockEnabledBlock14 ], [ 0, %postClockEnabledBlock ], [ %retval.0.ph.ph, %postClockEnabledBlock35 ]
  %43 = load i32, i32* @lc_disabled_count
  %clock_running36 = icmp eq i32 %43, 0
  br i1 %clock_running36, label %if_clock_enabled37, label %postClockEnabledBlock42

if_clock_enabled37:                               ; preds = %cleanup_dummy
  %44 = load i64, i64* @LocalLC
  %45 = add i64 1, %44
  store i64 %45, i64* @LocalLC
  %commit38 = icmp ugt i64 %45, 5000
  br i1 %commit38, label %pushBlock40, label %postInstrumentation39

pushBlock40:                                      ; preds = %if_clock_enabled37
  %46 = add i32 %43, 1
  store i32 %46, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler41 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler41(i64 %45)
  %47 = load i32, i32* @lc_disabled_count
  %48 = sub i32 %47, 1
  store i32 %48, i32* @lc_disabled_count
  br label %postInstrumentation39

postInstrumentation39:                            ; preds = %if_clock_enabled37, %pushBlock40
  br label %postClockEnabledBlock42

postClockEnabledBlock42:                          ; preds = %cleanup_dummy, %postInstrumentation39
  br label %cleanup

cleanup:                                          ; preds = %postClockEnabledBlock42, %entry
  %retval.0 = phi i32 [ 0, %entry ], [ %retval.0.ph, %postClockEnabledBlock42 ]
  ret i32 %retval.0
}

; Function Attrs: nounwind uwtable
define i32 @mystrtol(i8* %nptr, i32 %base) local_unnamed_addr #0 {
entry:
  %endptr = alloca i8*, align 8
  %0 = bitcast i8** %endptr to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %0) #16
  %call = tail call i32* @__errno_location() #11
  store i32 0, i32* %call, align 4, !tbaa !417
  %call1 = call i64 @strtol(i8* %nptr, i8** nonnull %endptr, i32 10) #16
  %conv = trunc i64 %call1 to i32
  %1 = load i32, i32* %call, align 4, !tbaa !417
  %cmp12 = icmp ne i32 %1, 0
  %cmp15 = icmp eq i32 %conv, 0
  %or.cond = and i1 %cmp12, %cmp15
  br i1 %or.cond, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  tail call void @perror(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.13.76, i64 0, i64 0)) #17
  tail call void @exit(i32 1) #18
  %2 = load i32, i32* @lc_disabled_count
  %clock_running = icmp eq i32 %2, 0
  br i1 %clock_running, label %if_clock_enabled, label %postClockEnabledBlock

if_clock_enabled:                                 ; preds = %if.then
  %3 = load i64, i64* @LocalLC
  %4 = add i64 3, %3
  store i64 %4, i64* @LocalLC
  %commit = icmp ugt i64 %4, 5000
  br i1 %commit, label %pushBlock, label %postInstrumentation

pushBlock:                                        ; preds = %if_clock_enabled
  %5 = add i32 %2, 1
  store i32 %5, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler(i64 %4)
  %6 = load i32, i32* @lc_disabled_count
  %7 = sub i32 %6, 1
  store i32 %7, i32* @lc_disabled_count
  br label %postInstrumentation

postInstrumentation:                              ; preds = %if_clock_enabled, %pushBlock
  br label %postClockEnabledBlock

postClockEnabledBlock:                            ; preds = %if.then, %postInstrumentation
  unreachable

if.end:                                           ; preds = %entry
  %8 = load i8*, i8** %endptr, align 8, !tbaa !86
  %cmp17 = icmp eq i8* %8, %nptr
  br i1 %cmp17, label %if.then19, label %if.end21

if.then19:                                        ; preds = %if.end
  %9 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !tbaa !86
  %10 = tail call i64 @fwrite(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.14.77, i64 0, i64 0), i64 22, i64 1, %struct._IO_FILE* %9) #17
  tail call void @exit(i32 1) #18
  %11 = load i32, i32* @lc_disabled_count
  %clock_running1 = icmp eq i32 %11, 0
  br i1 %clock_running1, label %if_clock_enabled2, label %postClockEnabledBlock7

if_clock_enabled2:                                ; preds = %if.then19
  %12 = load i64, i64* @LocalLC
  %13 = add i64 4, %12
  store i64 %13, i64* @LocalLC
  %commit3 = icmp ugt i64 %13, 5000
  br i1 %commit3, label %pushBlock5, label %postInstrumentation4

pushBlock5:                                       ; preds = %if_clock_enabled2
  %14 = add i32 %11, 1
  store i32 %14, i32* @lc_disabled_count
  store i64 9, i64* @LocalLC
  %ci_handler6 = load void (i64)*, void (i64)** @intvActionHook
  call void %ci_handler6(i64 %13)
  %15 = load i32, i32* @lc_disabled_count
  %16 = sub i32 %15, 1
  store i32 %16, i32* @lc_disabled_count
  br label %postInstrumentation4

postInstrumentation4:                             ; preds = %if_clock_enabled2, %pushBlock5
  br label %postClockEnabledBlock7

postClockEnabledBlock7:                           ; preds = %if.then19, %postInstrumentation4
  unreachable

if.end21:                                         ; preds = %if.end
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %0) #16
  ret i32 %conv
}

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nounwind }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind readnone speculatable }
attributes #4 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { noreturn nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nofree nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { argmemonly nounwind }
attributes #9 = { nofree nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #11 = { nounwind readnone }
attributes #12 = { nounwind readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #13 = { nounwind readonly uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #14 = { argmemonly nofree nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #15 = { nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #16 = { nounwind }
attributes #17 = { cold }
attributes #18 = { noreturn nounwind }
attributes #19 = { cold nounwind }
attributes #20 = { nounwind readonly }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!68, !68, !68, !68}
!llvm.module.flags = !{!69, !70, !71, !72}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "mtcp_ctx", scope: !2, file: !10, line: 90, type: !15, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.0 (https://github.com/bitslab/logicalclock.git b7571fe1ee88fc60fd4cf52c38f899c904bc1700)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !5, globals: !59, nameTableKind: None)
!3 = !DIFile(filename: "/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/mtcp-server/apps/perf/client.c", directory: "/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/mtcp-server/apps/perf")
!4 = !{}
!5 = !{!6, !7, !8, !22, !29, !45, !13, !57}
!6 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!7 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!8 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !9, size: 64)
!9 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "thread_context", file: !10, line: 66, size: 128, elements: !11)
!10 = !DIFile(filename: "client.c", directory: "/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/mtcp-server/apps/perf")
!11 = !{!12, !14}
!12 = !DIDerivedType(tag: DW_TAG_member, name: "core", scope: !9, file: !10, line: 68, baseType: !13, size: 32)
!13 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!14 = !DIDerivedType(tag: DW_TAG_member, name: "mctx", scope: !9, file: !10, line: 69, baseType: !15, size: 64, offset: 64)
!15 = !DIDerivedType(tag: DW_TAG_typedef, name: "mctx_t", file: !16, line: 48, baseType: !17)
!16 = !DIFile(filename: "../../mtcp//include/mtcp_api.h", directory: "/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/mtcp-server/apps/perf")
!17 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !18, size: 64)
!18 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "mtcp_context", file: !16, line: 43, size: 128, elements: !19)
!19 = !{!20, !21}
!20 = !DIDerivedType(tag: DW_TAG_member, name: "cpu", scope: !18, file: !16, line: 45, baseType: !13, size: 32)
!21 = !DIDerivedType(tag: DW_TAG_member, name: "mtcp_thr_ctx", scope: !18, file: !16, line: 46, baseType: !6, size: 64, offset: 64)
!22 = !DIDerivedType(tag: DW_TAG_typedef, name: "in_addr_t", file: !23, line: 30, baseType: !24)
!23 = !DIFile(filename: "/usr/include/netinet/in.h", directory: "")
!24 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !25, line: 26, baseType: !26)
!25 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/stdint-uintn.h", directory: "")
!26 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !27, line: 41, baseType: !28)
!27 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types.h", directory: "")
!28 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!29 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !30, size: 64)
!30 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "mtcp_epoll_event", file: !31, line: 44, size: 128, elements: !32)
!31 = !DIFile(filename: "../../mtcp//include/mtcp_epoll.h", directory: "/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/mtcp-server/apps/perf")
!32 = !{!33, !34}
!33 = !DIDerivedType(tag: DW_TAG_member, name: "events", scope: !30, file: !31, line: 46, baseType: !24, size: 32)
!34 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !30, file: !31, line: 47, baseType: !35, size: 64, offset: 64)
!35 = !DIDerivedType(tag: DW_TAG_typedef, name: "mtcp_epoll_data_t", file: !31, line: 42, baseType: !36)
!36 = distinct !DICompositeType(tag: DW_TAG_union_type, name: "mtcp_epoll_data", file: !31, line: 36, size: 64, elements: !37)
!37 = !{!38, !39, !40, !41}
!38 = !DIDerivedType(tag: DW_TAG_member, name: "ptr", scope: !36, file: !31, line: 38, baseType: !6, size: 64)
!39 = !DIDerivedType(tag: DW_TAG_member, name: "sockid", scope: !36, file: !31, line: 39, baseType: !13, size: 32)
!40 = !DIDerivedType(tag: DW_TAG_member, name: "u32", scope: !36, file: !31, line: 40, baseType: !24, size: 32)
!41 = !DIDerivedType(tag: DW_TAG_member, name: "u64", scope: !36, file: !31, line: 41, baseType: !42, size: 64)
!42 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !25, line: 27, baseType: !43)
!43 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint64_t", file: !27, line: 44, baseType: !44)
!44 = !DIBasicType(name: "long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!45 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !46, size: 64)
!46 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sockaddr", file: !47, line: 175, size: 128, elements: !48)
!47 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/socket.h", directory: "")
!48 = !{!49, !52}
!49 = !DIDerivedType(tag: DW_TAG_member, name: "sa_family", scope: !46, file: !47, line: 177, baseType: !50, size: 16)
!50 = !DIDerivedType(tag: DW_TAG_typedef, name: "sa_family_t", file: !51, line: 28, baseType: !7)
!51 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/sockaddr.h", directory: "")
!52 = !DIDerivedType(tag: DW_TAG_member, name: "sa_data", scope: !46, file: !47, line: 178, baseType: !53, size: 112, offset: 16)
!53 = !DICompositeType(tag: DW_TAG_array_type, baseType: !54, size: 112, elements: !55)
!54 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!55 = !{!56}
!56 = !DISubrange(count: 14)
!57 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !58, size: 64)
!58 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !54, size: 64)
!59 = !{!60, !0}
!60 = !DIGlobalVariableExpression(var: !61, expr: !DIExpression())
!61 = distinct !DIGlobalVariable(name: "intvActionHook", scope: !2, file: !62, line: 6, type: !63, isLocal: false, isDefinition: true)
!62 = !DIFile(filename: "ci_lib.h", directory: "/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/mtcp-server/apps/perf")
!63 = !DIDerivedType(tag: DW_TAG_typedef, name: "ci_handler", file: !62, line: 1, baseType: !64)
!64 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !65, size: 64)
!65 = !DISubroutineType(types: !66)
!66 = !{null, !67}
!67 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!68 = !{!"clang version 9.0.0 (https://github.com/bitslab/logicalclock.git b7571fe1ee88fc60fd4cf52c38f899c904bc1700)"}
!69 = !{i32 2, !"Dwarf Version", i32 4}
!70 = !{i32 2, !"Debug Info Version", i32 3}
!71 = !{i32 1, !"wchar_size", i32 4}
!72 = !{i32 7, !"PIC Level", i32 2}
!73 = distinct !DISubprogram(name: "init_stats", scope: !74, file: !74, line: 5, type: !75, scopeLine: 5, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !4)
!74 = !DIFile(filename: "TriggerAction.h", directory: "/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/mtcp-server/apps/perf")
!75 = !DISubroutineType(types: !76)
!76 = !{null}
!77 = !DILocation(line: 7, column: 5, scope: !73)
!78 = !DILocation(line: 8, column: 5, scope: !73)
!79 = !DILocation(line: 12, column: 3, scope: !73)
!80 = distinct !DISubprogram(name: "compiler_interrupt_handler", scope: !74, file: !74, line: 14, type: !65, scopeLine: 14, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !81)
!81 = !{!82}
!82 = !DILocalVariable(name: "ic", arg: 1, scope: !80, file: !74, line: 14, type: !67)
!83 = !DILocation(line: 0, scope: !80)
!84 = !DILocation(line: 15, column: 16, scope: !85)
!85 = distinct !DILexicalBlock(scope: !80, file: !74, line: 15, column: 8)
!86 = !{!87, !87, i64 0}
!87 = !{!"any pointer", !88, i64 0}
!88 = !{!"omnipotent char", !89, i64 0}
!89 = !{!"Simple C/C++ TBAA"}
!90 = !DILocation(line: 15, column: 26, scope: !85)
!91 = !{!92, !87, i64 8}
!92 = !{!"mtcp_context", !93, i64 0, !87, i64 8}
!93 = !{!"int", !88, i64 0}
!94 = !DILocation(line: 15, column: 8, scope: !85)
!95 = !DILocation(line: 15, column: 8, scope: !80)
!96 = !DILocation(line: 17, column: 7, scope: !97)
!97 = distinct !DILexicalBlock(scope: !85, file: !74, line: 15, column: 40)
!98 = !DILocation(line: 18, column: 5, scope: !97)
!99 = !DILocation(line: 20, column: 7, scope: !85)
!100 = !DILocation(line: 21, column: 3, scope: !80)
!101 = distinct !DISubprogram(name: "SignalHandler", scope: !10, file: !10, line: 73, type: !102, scopeLine: 74, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !104)
!102 = !DISubroutineType(types: !103)
!103 = !{null, !13}
!104 = !{!105}
!105 = !DILocalVariable(name: "signum", arg: 1, scope: !101, file: !10, line: 73, type: !13)
!106 = !DILocation(line: 0, scope: !101)
!107 = !DILocation(line: 75, column: 2, scope: !101)
!108 = !DILocation(line: 76, column: 2, scope: !101)
!109 = distinct !DISubprogram(name: "print_usage", scope: !10, file: !10, line: 80, type: !102, scopeLine: 81, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !110)
!110 = !{!111}
!111 = !DILocalVariable(name: "mode", arg: 1, scope: !109, file: !10, line: 80, type: !13)
!112 = !DILocation(line: 0, scope: !109)
!113 = !DILocation(line: 82, column: 24, scope: !114)
!114 = distinct !DILexicalBlock(scope: !109, file: !10, line: 82, column: 6)
!115 = !DILocation(line: 83, column: 3, scope: !116)
!116 = distinct !DILexicalBlock(scope: !114, file: !10, line: 82, column: 38)
!117 = !DILocation(line: 84, column: 2, scope: !116)
!118 = !DILocation(line: 85, column: 24, scope: !119)
!119 = distinct !DILexicalBlock(scope: !109, file: !10, line: 85, column: 6)
!120 = !DILocation(line: 86, column: 3, scope: !121)
!121 = distinct !DILexicalBlock(scope: !119, file: !10, line: 85, column: 38)
!122 = !DILocation(line: 87, column: 2, scope: !121)
!123 = !DILocation(line: 88, column: 1, scope: !109)
!124 = distinct !DISubprogram(name: "main", scope: !10, file: !10, line: 92, type: !125, scopeLine: 93, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !127)
!125 = !DISubroutineType(types: !126)
!126 = !{!13, !13, !57}
!127 = !{!128, !129, !130, !131, !132, !133, !134, !144, !145, !146, !147, !148, !149, !166, !167, !168, !169, !170, !171, !172, !173, !174, !175, !176, !178, !186, !187, !194, !195, !198, !202, !203, !204, !208, !209, !213, !214, !217, !218}
!128 = !DILocalVariable(name: "argc", arg: 1, scope: !124, file: !10, line: 92, type: !13)
!129 = !DILocalVariable(name: "argv", arg: 2, scope: !124, file: !10, line: 92, type: !57)
!130 = !DILocalVariable(name: "ret", scope: !124, file: !10, line: 95, type: !13)
!131 = !DILocalVariable(name: "i", scope: !124, file: !10, line: 95, type: !13)
!132 = !DILocalVariable(name: "c", scope: !124, file: !10, line: 95, type: !13)
!133 = !DILocalVariable(name: "mctx", scope: !124, file: !10, line: 98, type: !15)
!134 = !DILocalVariable(name: "mcfg", scope: !124, file: !10, line: 99, type: !135)
!135 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "mtcp_conf", file: !16, line: 30, size: 224, elements: !136)
!136 = !{!137, !138, !139, !140, !141, !142, !143}
!137 = !DIDerivedType(tag: DW_TAG_member, name: "num_cores", scope: !135, file: !16, line: 32, baseType: !13, size: 32)
!138 = !DIDerivedType(tag: DW_TAG_member, name: "max_concurrency", scope: !135, file: !16, line: 33, baseType: !13, size: 32, offset: 32)
!139 = !DIDerivedType(tag: DW_TAG_member, name: "max_num_buffers", scope: !135, file: !16, line: 35, baseType: !13, size: 32, offset: 64)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "rcvbuf_size", scope: !135, file: !16, line: 36, baseType: !13, size: 32, offset: 96)
!141 = !DIDerivedType(tag: DW_TAG_member, name: "sndbuf_size", scope: !135, file: !16, line: 37, baseType: !13, size: 32, offset: 128)
!142 = !DIDerivedType(tag: DW_TAG_member, name: "tcp_timewait", scope: !135, file: !16, line: 39, baseType: !13, size: 32, offset: 160)
!143 = !DIDerivedType(tag: DW_TAG_member, name: "tcp_timeout", scope: !135, file: !16, line: 40, baseType: !13, size: 32, offset: 192)
!144 = !DILocalVariable(name: "ctx", scope: !124, file: !10, line: 100, type: !8)
!145 = !DILocalVariable(name: "events", scope: !124, file: !10, line: 101, type: !29)
!146 = !DILocalVariable(name: "ev", scope: !124, file: !10, line: 102, type: !30)
!147 = !DILocalVariable(name: "core", scope: !124, file: !10, line: 103, type: !13)
!148 = !DILocalVariable(name: "ep_id", scope: !124, file: !10, line: 104, type: !13)
!149 = !DILocalVariable(name: "saddr", scope: !124, file: !10, line: 107, type: !150)
!150 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sockaddr_in", file: !23, line: 237, size: 128, elements: !151)
!151 = !{!152, !153, !157, !161}
!152 = !DIDerivedType(tag: DW_TAG_member, name: "sin_family", scope: !150, file: !23, line: 239, baseType: !50, size: 16)
!153 = !DIDerivedType(tag: DW_TAG_member, name: "sin_port", scope: !150, file: !23, line: 240, baseType: !154, size: 16, offset: 16)
!154 = !DIDerivedType(tag: DW_TAG_typedef, name: "in_port_t", file: !23, line: 119, baseType: !155)
!155 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !25, line: 25, baseType: !156)
!156 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint16_t", file: !27, line: 39, baseType: !7)
!157 = !DIDerivedType(tag: DW_TAG_member, name: "sin_addr", scope: !150, file: !23, line: 241, baseType: !158, size: 32, offset: 32)
!158 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in_addr", file: !23, line: 31, size: 32, elements: !159)
!159 = !{!160}
!160 = !DIDerivedType(tag: DW_TAG_member, name: "s_addr", scope: !158, file: !23, line: 33, baseType: !22, size: 32)
!161 = !DIDerivedType(tag: DW_TAG_member, name: "sin_zero", scope: !150, file: !23, line: 244, baseType: !162, size: 64, offset: 64)
!162 = !DICompositeType(tag: DW_TAG_array_type, baseType: !163, size: 64, elements: !164)
!163 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!164 = !{!165}
!165 = !DISubrange(count: 8)
!166 = !DILocalVariable(name: "daddr", scope: !124, file: !10, line: 107, type: !150)
!167 = !DILocalVariable(name: "sockfd", scope: !124, file: !10, line: 108, type: !13)
!168 = !DILocalVariable(name: "backlog", scope: !124, file: !10, line: 109, type: !13)
!169 = !DILocalVariable(name: "sec_to_send", scope: !124, file: !10, line: 112, type: !13)
!170 = !DILocalVariable(name: "wrote", scope: !124, file: !10, line: 113, type: !13)
!171 = !DILocalVariable(name: "read", scope: !124, file: !10, line: 114, type: !13)
!172 = !DILocalVariable(name: "bytes_sent", scope: !124, file: !10, line: 115, type: !13)
!173 = !DILocalVariable(name: "events_ready", scope: !124, file: !10, line: 116, type: !13)
!174 = !DILocalVariable(name: "nevents", scope: !124, file: !10, line: 117, type: !13)
!175 = !DILocalVariable(name: "sent_close", scope: !124, file: !10, line: 118, type: !13)
!176 = !DILocalVariable(name: "elapsed_time", scope: !124, file: !10, line: 121, type: !177)
!177 = !DIBasicType(name: "double", size: 64, encoding: DW_ATE_float)
!178 = !DILocalVariable(name: "t1", scope: !124, file: !10, line: 122, type: !179)
!179 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "timeval", file: !180, line: 8, size: 128, elements: !181)
!180 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/struct_timeval.h", directory: "")
!181 = !{!182, !184}
!182 = !DIDerivedType(tag: DW_TAG_member, name: "tv_sec", scope: !179, file: !180, line: 10, baseType: !183, size: 64)
!183 = !DIDerivedType(tag: DW_TAG_typedef, name: "__time_t", file: !27, line: 148, baseType: !67)
!184 = !DIDerivedType(tag: DW_TAG_member, name: "tv_usec", scope: !179, file: !180, line: 11, baseType: !185, size: 64, offset: 64)
!185 = !DIDerivedType(tag: DW_TAG_typedef, name: "__suseconds_t", file: !27, line: 150, baseType: !67)
!186 = !DILocalVariable(name: "t2", scope: !124, file: !10, line: 122, type: !179)
!187 = !DILocalVariable(name: "ts_start", scope: !124, file: !10, line: 123, type: !188)
!188 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "timespec", file: !189, line: 8, size: 128, elements: !190)
!189 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/struct_timespec.h", directory: "")
!190 = !{!191, !192}
!191 = !DIDerivedType(tag: DW_TAG_member, name: "tv_sec", scope: !188, file: !189, line: 10, baseType: !183, size: 64)
!192 = !DIDerivedType(tag: DW_TAG_member, name: "tv_nsec", scope: !188, file: !189, line: 11, baseType: !193, size: 64, offset: 64)
!193 = !DIDerivedType(tag: DW_TAG_typedef, name: "__syscall_slong_t", file: !27, line: 184, baseType: !67)
!194 = !DILocalVariable(name: "now", scope: !124, file: !10, line: 123, type: !188)
!195 = !DILocalVariable(name: "end_time", scope: !124, file: !10, line: 124, type: !196)
!196 = !DIDerivedType(tag: DW_TAG_typedef, name: "time_t", file: !197, line: 7, baseType: !183)
!197 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/time_t.h", directory: "")
!198 = !DILocalVariable(name: "buf", scope: !124, file: !10, line: 127, type: !199)
!199 = !DICompositeType(tag: DW_TAG_array_type, baseType: !54, size: 65536, elements: !200)
!200 = !{!201}
!201 = !DISubrange(count: 8192)
!202 = !DILocalVariable(name: "rcvbuf", scope: !124, file: !10, line: 128, type: !199)
!203 = !DILocalVariable(name: "mode", scope: !124, file: !10, line: 131, type: !13)
!204 = !DILocalVariable(name: "__v", scope: !205, file: !10, line: 150, type: !7)
!205 = distinct !DILexicalBlock(scope: !206, file: !10, line: 150, column: 20)
!206 = distinct !DILexicalBlock(scope: !207, file: !10, line: 138, column: 40)
!207 = distinct !DILexicalBlock(scope: !124, file: !10, line: 138, column: 6)
!208 = !DILocalVariable(name: "__x", scope: !205, file: !10, line: 150, type: !7)
!209 = !DILocalVariable(name: "__v", scope: !210, file: !10, line: 164, type: !7)
!210 = distinct !DILexicalBlock(scope: !211, file: !10, line: 164, column: 20)
!211 = distinct !DILexicalBlock(scope: !212, file: !10, line: 153, column: 47)
!212 = distinct !DILexicalBlock(scope: !207, file: !10, line: 153, column: 13)
!213 = !DILocalVariable(name: "__x", scope: !210, file: !10, line: 164, type: !7)
!214 = !DILocalVariable(name: "i", scope: !215, file: !10, line: 333, type: !13)
!215 = distinct !DILexicalBlock(scope: !216, file: !10, line: 333, column: 3)
!216 = distinct !DILexicalBlock(scope: !124, file: !10, line: 330, column: 12)
!217 = !DILabel(scope: !124, name: "end_wait_loop", file: !10, line: 293)
!218 = !DILabel(scope: !124, name: "stop_timer", file: !10, line: 361)
!219 = !DILocation(line: 0, scope: !124)
!220 = !DILocation(line: 7, column: 5, scope: !73, inlinedAt: !221)
!221 = distinct !DILocation(line: 94, column: 3, scope: !124)
!222 = !DILocation(line: 8, column: 5, scope: !73, inlinedAt: !221)
!223 = !DILocation(line: 99, column: 2, scope: !124)
!224 = !DILocation(line: 102, column: 2, scope: !124)
!225 = !DILocation(line: 107, column: 2, scope: !124)
!226 = !DILocation(line: 122, column: 2, scope: !124)
!227 = !DILocation(line: 123, column: 2, scope: !124)
!228 = !DILocation(line: 127, column: 2, scope: !124)
!229 = !DILocation(line: 127, column: 7, scope: !124)
!230 = !DILocation(line: 128, column: 2, scope: !124)
!231 = !DILocation(line: 128, column: 7, scope: !124)
!232 = !DILocation(line: 133, column: 11, scope: !233)
!233 = distinct !DILexicalBlock(scope: !124, file: !10, line: 133, column: 6)
!234 = !DILocation(line: 133, column: 6, scope: !124)
!235 = !DILocation(line: 0, scope: !109, inlinedAt: !236)
!236 = distinct !DILocation(line: 134, column: 3, scope: !237)
!237 = distinct !DILexicalBlock(scope: !233, file: !10, line: 133, column: 16)
!238 = !DILocation(line: 83, column: 3, scope: !116, inlinedAt: !236)
!239 = !DILocation(line: 86, column: 3, scope: !121, inlinedAt: !236)
!240 = !DILocation(line: 135, column: 3, scope: !237)
!241 = !DILocation(line: 138, column: 14, scope: !207)
!242 = !DILocation(line: 138, column: 6, scope: !207)
!243 = !DILocation(line: 138, column: 34, scope: !207)
!244 = !DILocation(line: 138, column: 6, scope: !124)
!245 = !DILocation(line: 139, column: 12, scope: !246)
!246 = distinct !DILexicalBlock(scope: !206, file: !10, line: 139, column: 7)
!247 = !DILocation(line: 0, scope: !206)
!248 = !DILocation(line: 139, column: 7, scope: !206)
!249 = !DILocation(line: 0, scope: !109, inlinedAt: !250)
!250 = distinct !DILocation(line: 140, column: 4, scope: !251)
!251 = distinct !DILexicalBlock(scope: !246, file: !10, line: 139, column: 17)
!252 = !DILocation(line: 83, column: 3, scope: !116, inlinedAt: !250)
!253 = !DILocation(line: 141, column: 4, scope: !251)
!254 = !DILocation(line: 145, column: 3, scope: !206)
!255 = !DILocation(line: 148, column: 9, scope: !206)
!256 = !DILocation(line: 148, column: 20, scope: !206)
!257 = !{!258, !259, i64 0}
!258 = !{!"sockaddr_in", !259, i64 0, !259, i64 2, !260, i64 4, !88, i64 8}
!259 = !{!"short", !88, i64 0}
!260 = !{!"in_addr", !93, i64 0}
!261 = !DILocation(line: 149, column: 37, scope: !206)
!262 = !DILocation(line: 149, column: 27, scope: !206)
!263 = !DILocation(line: 149, column: 18, scope: !206)
!264 = !DILocation(line: 149, column: 25, scope: !206)
!265 = !{!258, !93, i64 4}
!266 = !DILocation(line: 150, column: 20, scope: !205)
!267 = !DILocalVariable(name: "__nptr", arg: 1, scope: !268, file: !269, line: 361, type: !272)
!268 = distinct !DISubprogram(name: "atoi", scope: !269, file: !269, line: 361, type: !270, scopeLine: 362, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !274)
!269 = !DIFile(filename: "/usr/include/stdlib.h", directory: "")
!270 = !DISubroutineType(types: !271)
!271 = !{!13, !272}
!272 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !273, size: 64)
!273 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !54)
!274 = !{!267}
!275 = !DILocation(line: 0, scope: !268, inlinedAt: !276)
!276 = distinct !DILocation(line: 150, column: 20, scope: !205)
!277 = !DILocation(line: 363, column: 16, scope: !268, inlinedAt: !276)
!278 = !DILocation(line: 0, scope: !205)
!279 = !DILocation(line: 150, column: 20, scope: !280)
!280 = distinct !DILexicalBlock(scope: !205, file: !10, line: 150, column: 20)
!281 = !{i32 -2146122450}
!282 = !DILocation(line: 153, column: 13, scope: !212)
!283 = !DILocation(line: 153, column: 41, scope: !212)
!284 = !DILocation(line: 153, column: 13, scope: !207)
!285 = !DILocation(line: 154, column: 12, scope: !286)
!286 = distinct !DILexicalBlock(scope: !211, file: !10, line: 154, column: 7)
!287 = !DILocation(line: 0, scope: !211)
!288 = !DILocation(line: 154, column: 7, scope: !211)
!289 = !DILocation(line: 0, scope: !109, inlinedAt: !290)
!290 = distinct !DILocation(line: 155, column: 4, scope: !291)
!291 = distinct !DILexicalBlock(scope: !286, file: !10, line: 154, column: 17)
!292 = !DILocation(line: 86, column: 3, scope: !121, inlinedAt: !290)
!293 = !DILocation(line: 156, column: 4, scope: !291)
!294 = !DILocation(line: 160, column: 3, scope: !211)
!295 = !DILocation(line: 162, column: 9, scope: !211)
!296 = !DILocation(line: 162, column: 20, scope: !211)
!297 = !DILocation(line: 163, column: 37, scope: !211)
!298 = !DILocation(line: 163, column: 27, scope: !211)
!299 = !DILocation(line: 163, column: 18, scope: !211)
!300 = !DILocation(line: 163, column: 25, scope: !211)
!301 = !DILocation(line: 164, column: 20, scope: !210)
!302 = !DILocation(line: 0, scope: !268, inlinedAt: !303)
!303 = distinct !DILocation(line: 164, column: 20, scope: !210)
!304 = !DILocation(line: 363, column: 16, scope: !268, inlinedAt: !303)
!305 = !DILocation(line: 0, scope: !210)
!306 = !DILocation(line: 164, column: 20, scope: !307)
!307 = distinct !DILexicalBlock(scope: !210, file: !10, line: 164, column: 20)
!308 = !{i32 -2146121895}
!309 = !DILocation(line: 168, column: 3, scope: !310)
!310 = distinct !DILexicalBlock(scope: !212, file: !10, line: 167, column: 9)
!311 = !DILocation(line: 0, scope: !109, inlinedAt: !312)
!312 = distinct !DILocation(line: 169, column: 3, scope: !310)
!313 = !DILocation(line: 83, column: 3, scope: !116, inlinedAt: !312)
!314 = !DILocation(line: 86, column: 3, scope: !121, inlinedAt: !312)
!315 = !DILocation(line: 172, column: 6, scope: !124)
!316 = !DILocation(line: 0, scope: !207)
!317 = !{!258, !259, i64 2}
!318 = !DILocation(line: 178, column: 2, scope: !124)
!319 = !DILocation(line: 179, column: 7, scope: !124)
!320 = !DILocation(line: 179, column: 17, scope: !124)
!321 = !{!322, !93, i64 0}
!322 = !{!"mtcp_conf", !93, i64 0, !93, i64 4, !93, i64 8, !93, i64 12, !93, i64 16, !93, i64 20, !93, i64 24}
!323 = !DILocation(line: 180, column: 2, scope: !124)
!324 = !DILocation(line: 182, column: 8, scope: !124)
!325 = !DILocation(line: 182, column: 2, scope: !124)
!326 = !DILocation(line: 185, column: 2, scope: !124)
!327 = !DILocation(line: 186, column: 6, scope: !328)
!328 = distinct !DILexicalBlock(scope: !124, file: !10, line: 186, column: 6)
!329 = !DILocation(line: 186, column: 6, scope: !124)
!330 = !DILocation(line: 187, column: 3, scope: !331)
!331 = distinct !DILexicalBlock(scope: !328, file: !10, line: 186, column: 32)
!332 = !DILocation(line: 188, column: 3, scope: !331)
!333 = !DILocation(line: 192, column: 2, scope: !124)
!334 = !DILocation(line: 193, column: 7, scope: !124)
!335 = !DILocation(line: 193, column: 23, scope: !124)
!336 = !{!322, !93, i64 4}
!337 = !DILocation(line: 194, column: 7, scope: !124)
!338 = !DILocation(line: 194, column: 23, scope: !124)
!339 = !{!322, !93, i64 8}
!340 = !DILocation(line: 195, column: 2, scope: !124)
!341 = !DILocation(line: 198, column: 2, scope: !124)
!342 = !DILocation(line: 200, column: 2, scope: !124)
!343 = !DILocation(line: 201, column: 2, scope: !124)
!344 = !DILocation(line: 209, column: 14, scope: !124)
!345 = !DILocation(line: 210, column: 7, scope: !346)
!346 = distinct !DILexicalBlock(scope: !124, file: !10, line: 210, column: 6)
!347 = !DILocation(line: 210, column: 6, scope: !124)
!348 = !DILocation(line: 211, column: 3, scope: !349)
!349 = distinct !DILexicalBlock(scope: !346, file: !10, line: 210, column: 18)
!350 = !DILocation(line: 212, column: 3, scope: !349)
!351 = !DILocation(line: 215, column: 12, scope: !124)
!352 = !DILocation(line: 217, column: 11, scope: !353)
!353 = distinct !DILexicalBlock(scope: !124, file: !10, line: 217, column: 6)
!354 = !DILocation(line: 217, column: 6, scope: !124)
!355 = !DILocation(line: 219, column: 3, scope: !356)
!356 = distinct !DILexicalBlock(scope: !353, file: !10, line: 217, column: 25)
!357 = !DILocation(line: 220, column: 60, scope: !356)
!358 = !DILocation(line: 220, column: 74, scope: !356)
!359 = !DILocation(line: 220, column: 68, scope: !356)
!360 = !DILocation(line: 220, column: 3, scope: !356)
!361 = !DILocation(line: 221, column: 2, scope: !356)
!362 = !DILocation(line: 223, column: 2, scope: !124)
!363 = !DILocation(line: 224, column: 44, scope: !124)
!364 = !DILocation(line: 224, column: 10, scope: !124)
!365 = !DILocation(line: 225, column: 51, scope: !124)
!366 = !DILocation(line: 225, column: 46, scope: !124)
!367 = !DILocation(line: 225, column: 39, scope: !124)
!368 = !DILocation(line: 225, column: 11, scope: !124)
!369 = !DILocation(line: 226, column: 7, scope: !370)
!370 = distinct !DILexicalBlock(scope: !124, file: !10, line: 226, column: 6)
!371 = !DILocation(line: 226, column: 6, scope: !124)
!372 = !DILocation(line: 227, column: 3, scope: !373)
!373 = distinct !DILexicalBlock(scope: !370, file: !10, line: 226, column: 15)
!374 = !DILocation(line: 228, column: 3, scope: !373)
!375 = !DILocation(line: 232, column: 2, scope: !124)
!376 = !DILocation(line: 233, column: 11, scope: !124)
!377 = !DILocation(line: 234, column: 13, scope: !378)
!378 = distinct !DILexicalBlock(scope: !124, file: !10, line: 234, column: 6)
!379 = !DILocation(line: 234, column: 6, scope: !124)
!380 = !DILocation(line: 235, column: 3, scope: !381)
!381 = distinct !DILexicalBlock(scope: !378, file: !10, line: 234, column: 18)
!382 = !DILocation(line: 236, column: 3, scope: !381)
!383 = !DILocation(line: 239, column: 8, scope: !124)
!384 = !DILocation(line: 240, column: 10, scope: !385)
!385 = distinct !DILexicalBlock(scope: !124, file: !10, line: 240, column: 6)
!386 = !DILocation(line: 240, column: 6, scope: !124)
!387 = !DILocation(line: 241, column: 3, scope: !388)
!388 = distinct !DILexicalBlock(scope: !385, file: !10, line: 240, column: 15)
!389 = !DILocation(line: 242, column: 3, scope: !388)
!390 = !DILocation(line: 245, column: 5, scope: !124)
!391 = !DILocation(line: 245, column: 12, scope: !124)
!392 = !{!393, !93, i64 0}
!393 = !{!"mtcp_epoll_event", !93, i64 0, !88, i64 8}
!394 = !DILocation(line: 246, column: 5, scope: !124)
!395 = !DILocation(line: 246, column: 10, scope: !124)
!396 = !DILocation(line: 246, column: 17, scope: !124)
!397 = !{!88, !88, i64 0}
!398 = !DILocation(line: 247, column: 2, scope: !124)
!399 = !DILocation(line: 249, column: 11, scope: !400)
!400 = distinct !DILexicalBlock(scope: !124, file: !10, line: 249, column: 6)
!401 = !DILocation(line: 249, column: 6, scope: !124)
!402 = !DILocation(line: 250, column: 33, scope: !403)
!403 = distinct !DILexicalBlock(scope: !400, file: !10, line: 249, column: 25)
!404 = !DILocation(line: 250, column: 9, scope: !403)
!405 = !DILocation(line: 251, column: 11, scope: !406)
!406 = distinct !DILexicalBlock(scope: !403, file: !10, line: 251, column: 7)
!407 = !DILocation(line: 251, column: 7, scope: !403)
!408 = !DILocation(line: 252, column: 4, scope: !409)
!409 = distinct !DILexicalBlock(scope: !406, file: !10, line: 251, column: 16)
!410 = !DILocation(line: 253, column: 3, scope: !409)
!411 = !DILocation(line: 255, column: 9, scope: !403)
!412 = !DILocation(line: 256, column: 11, scope: !413)
!413 = distinct !DILexicalBlock(scope: !403, file: !10, line: 256, column: 7)
!414 = !DILocation(line: 256, column: 7, scope: !403)
!415 = !DILocation(line: 257, column: 4, scope: !416)
!416 = distinct !DILexicalBlock(scope: !413, file: !10, line: 256, column: 16)
!417 = !{!93, !93, i64 0}
!418 = !DILocation(line: 258, column: 3, scope: !416)
!419 = !DILocation(line: 262, column: 14, scope: !420)
!420 = distinct !DILexicalBlock(scope: !403, file: !10, line: 260, column: 13)
!421 = !DILocation(line: 263, column: 16, scope: !422)
!422 = distinct !DILexicalBlock(scope: !420, file: !10, line: 263, column: 8)
!423 = !DILocation(line: 263, column: 8, scope: !420)
!424 = !DILocation(line: 270, column: 4, scope: !425)
!425 = distinct !DILexicalBlock(scope: !420, file: !10, line: 270, column: 4)
!426 = !DILocation(line: 270, column: 18, scope: !427)
!427 = distinct !DILexicalBlock(scope: !425, file: !10, line: 270, column: 4)
!428 = distinct !{!428, !429, !430}
!429 = !DILocation(line: 260, column: 3, scope: !403)
!430 = !DILocation(line: 291, column: 3, scope: !403)
!431 = !DILocation(line: 264, column: 9, scope: !432)
!432 = distinct !DILexicalBlock(scope: !433, file: !10, line: 264, column: 9)
!433 = distinct !DILexicalBlock(scope: !422, file: !10, line: 263, column: 21)
!434 = !DILocation(line: 264, column: 15, scope: !432)
!435 = !DILocation(line: 264, column: 9, scope: !433)
!436 = !DILocation(line: 265, column: 6, scope: !437)
!437 = distinct !DILexicalBlock(scope: !432, file: !10, line: 264, column: 25)
!438 = !DILocation(line: 266, column: 5, scope: !437)
!439 = !DILocation(line: 271, column: 19, scope: !440)
!440 = distinct !DILexicalBlock(scope: !441, file: !10, line: 271, column: 9)
!441 = distinct !DILexicalBlock(scope: !427, file: !10, line: 270, column: 34)
!442 = !DILocation(line: 271, column: 24, scope: !440)
!443 = !DILocation(line: 271, column: 31, scope: !440)
!444 = !DILocation(line: 271, column: 9, scope: !441)
!445 = !DILocation(line: 272, column: 10, scope: !446)
!446 = distinct !DILexicalBlock(scope: !440, file: !10, line: 271, column: 42)
!447 = !DILocation(line: 273, column: 12, scope: !448)
!448 = distinct !DILexicalBlock(scope: !446, file: !10, line: 273, column: 10)
!449 = !DILocation(line: 273, column: 10, scope: !446)
!450 = !DILocation(line: 274, column: 13, scope: !451)
!451 = distinct !DILexicalBlock(scope: !452, file: !10, line: 274, column: 11)
!452 = distinct !DILexicalBlock(scope: !448, file: !10, line: 273, column: 18)
!453 = !DILocation(line: 274, column: 11, scope: !452)
!454 = !DILocation(line: 275, column: 8, scope: !455)
!455 = distinct !DILexicalBlock(scope: !451, file: !10, line: 274, column: 30)
!456 = !DILocation(line: 276, column: 7, scope: !455)
!457 = !DILocation(line: 277, column: 7, scope: !452)
!458 = !DILocation(line: 278, column: 6, scope: !452)
!459 = !DILocation(line: 279, column: 7, scope: !460)
!460 = distinct !DILexicalBlock(scope: !448, file: !10, line: 278, column: 13)
!461 = !DILocation(line: 281, column: 6, scope: !446)
!462 = !DILocation(line: 283, column: 16, scope: !446)
!463 = !DILocation(line: 284, column: 21, scope: !446)
!464 = !DILocation(line: 285, column: 6, scope: !446)
!465 = !DILocation(line: 286, column: 6, scope: !446)
!466 = !DILocation(line: 288, column: 6, scope: !467)
!467 = distinct !DILexicalBlock(scope: !440, file: !10, line: 287, column: 12)
!468 = !DILocation(line: 270, column: 30, scope: !427)
!469 = distinct !{!469, !424, !470}
!470 = !DILocation(line: 290, column: 4, scope: !425)
!471 = !DILocation(line: 293, column: 1, scope: !124)
!472 = !DILocation(line: 296, column: 6, scope: !124)
!473 = !DILocation(line: 297, column: 3, scope: !474)
!474 = distinct !DILexicalBlock(scope: !475, file: !10, line: 296, column: 25)
!475 = distinct !DILexicalBlock(scope: !124, file: !10, line: 296, column: 6)
!476 = !DILocation(line: 298, column: 36, scope: !474)
!477 = !DILocation(line: 298, column: 9, scope: !474)
!478 = !DILocation(line: 299, column: 11, scope: !479)
!479 = distinct !DILexicalBlock(scope: !474, file: !10, line: 299, column: 7)
!480 = !DILocation(line: 299, column: 7, scope: !474)
!481 = !DILocation(line: 300, column: 4, scope: !482)
!482 = distinct !DILexicalBlock(scope: !479, file: !10, line: 299, column: 16)
!483 = !DILocation(line: 301, column: 8, scope: !484)
!484 = distinct !DILexicalBlock(scope: !482, file: !10, line: 301, column: 8)
!485 = !DILocation(line: 301, column: 14, scope: !484)
!486 = !DILocation(line: 301, column: 8, scope: !482)
!487 = !DILocation(line: 302, column: 5, scope: !488)
!488 = distinct !DILexicalBlock(scope: !484, file: !10, line: 301, column: 30)
!489 = !DILocation(line: 303, column: 5, scope: !488)
!490 = !DILocation(line: 304, column: 5, scope: !488)
!491 = !DILocation(line: 307, column: 3, scope: !474)
!492 = !DILocation(line: 308, column: 2, scope: !474)
!493 = !DILocation(line: 310, column: 2, scope: !124)
!494 = !DILocation(line: 311, column: 22, scope: !124)
!495 = !{!496, !497, i64 0}
!496 = !{!"timespec", !497, i64 0, !497, i64 8}
!497 = !{!"long", !88, i64 0}
!498 = !DILocation(line: 311, column: 31, scope: !124)
!499 = !DILocation(line: 313, column: 2, scope: !124)
!500 = !DILocation(line: 314, column: 2, scope: !124)
!501 = !DILocation(line: 314, column: 17, scope: !124)
!502 = !DILocation(line: 316, column: 2, scope: !124)
!503 = !DILocation(line: 317, column: 11, scope: !504)
!504 = distinct !DILexicalBlock(scope: !124, file: !10, line: 316, column: 12)
!505 = !DILocation(line: 318, column: 14, scope: !504)
!506 = !DILocation(line: 319, column: 13, scope: !507)
!507 = distinct !DILexicalBlock(scope: !504, file: !10, line: 319, column: 7)
!508 = !DILocation(line: 319, column: 7, scope: !504)
!509 = distinct !{!509, !502, !510}
!510 = !DILocation(line: 323, column: 2, scope: !124)
!511 = !DILocation(line: 311, column: 29, scope: !124)
!512 = !DILocation(line: 320, column: 4, scope: !513)
!513 = distinct !DILexicalBlock(scope: !507, file: !10, line: 319, column: 18)
!514 = !DILocation(line: 0, scope: !515)
!515 = distinct !DILexicalBlock(scope: !516, file: !10, line: 346, column: 9)
!516 = distinct !DILexicalBlock(scope: !517, file: !10, line: 343, column: 50)
!517 = distinct !DILexicalBlock(scope: !518, file: !10, line: 343, column: 15)
!518 = distinct !DILexicalBlock(scope: !519, file: !10, line: 335, column: 8)
!519 = distinct !DILexicalBlock(scope: !520, file: !10, line: 333, column: 42)
!520 = distinct !DILexicalBlock(scope: !215, file: !10, line: 333, column: 3)
!521 = !DILocation(line: 330, column: 2, scope: !124)
!522 = !DILocation(line: 333, column: 3, scope: !215)
!523 = !DILocation(line: 332, column: 65, scope: !216)
!524 = !DILocation(line: 332, column: 18, scope: !216)
!525 = !DILocation(line: 0, scope: !215)
!526 = !DILocation(line: 333, column: 21, scope: !520)
!527 = !DILocation(line: 334, column: 4, scope: !528)
!528 = distinct !DILexicalBlock(scope: !529, file: !10, line: 334, column: 4)
!529 = distinct !DILexicalBlock(scope: !519, file: !10, line: 334, column: 4)
!530 = !DILocation(line: 334, column: 4, scope: !529)
!531 = !DILocation(line: 335, column: 18, scope: !518)
!532 = !DILocation(line: 335, column: 25, scope: !518)
!533 = !DILocation(line: 335, column: 8, scope: !519)
!534 = !DILocation(line: 336, column: 12, scope: !535)
!535 = distinct !DILexicalBlock(scope: !518, file: !10, line: 335, column: 41)
!536 = !DILocation(line: 337, column: 14, scope: !537)
!537 = distinct !DILexicalBlock(scope: !535, file: !10, line: 337, column: 9)
!538 = !DILocation(line: 337, column: 9, scope: !535)
!539 = !DILocation(line: 343, column: 32, scope: !517)
!540 = !DILocation(line: 343, column: 15, scope: !518)
!541 = !DILocation(line: 345, column: 5, scope: !516)
!542 = !DILocation(line: 346, column: 13, scope: !515)
!543 = !DILocation(line: 346, column: 20, scope: !515)
!544 = !DILocation(line: 346, column: 9, scope: !516)
!545 = !DILocation(line: 347, column: 14, scope: !546)
!546 = distinct !DILexicalBlock(scope: !515, file: !10, line: 346, column: 32)
!547 = !DILocation(line: 348, column: 17, scope: !546)
!548 = !DILocation(line: 350, column: 5, scope: !546)
!549 = !DILocation(line: 350, column: 17, scope: !550)
!550 = distinct !DILexicalBlock(scope: !515, file: !10, line: 350, column: 16)
!551 = !DILocation(line: 350, column: 16, scope: !515)
!552 = !DILocation(line: 351, column: 6, scope: !553)
!553 = distinct !DILexicalBlock(scope: !550, file: !10, line: 350, column: 29)
!554 = !DILocation(line: 352, column: 6, scope: !553)
!555 = !DILocation(line: 353, column: 6, scope: !553)
!556 = !DILocation(line: 355, column: 5, scope: !553)
!557 = !DILocation(line: 333, column: 38, scope: !520)
!558 = distinct !{!558, !522, !559}
!559 = !DILocation(line: 357, column: 3, scope: !215)
!560 = !DILocation(line: 340, column: 6, scope: !561)
!561 = distinct !DILexicalBlock(scope: !537, file: !10, line: 339, column: 12)
!562 = !DILocation(line: 361, column: 1, scope: !124)
!563 = !DILocation(line: 362, column: 2, scope: !124)
!564 = !DILocation(line: 364, column: 2, scope: !124)
!565 = !DILocation(line: 365, column: 2, scope: !124)
!566 = !DILocation(line: 366, column: 2, scope: !124)
!567 = !DILocation(line: 368, column: 2, scope: !124)
!568 = !DILocation(line: 369, column: 21, scope: !124)
!569 = !{!570, !497, i64 0}
!570 = !{!"timeval", !497, i64 0, !497, i64 8}
!571 = !DILocation(line: 369, column: 33, scope: !124)
!572 = !DILocation(line: 369, column: 28, scope: !124)
!573 = !DILocation(line: 369, column: 17, scope: !124)
!574 = !DILocation(line: 370, column: 22, scope: !124)
!575 = !{!570, !497, i64 8}
!576 = !DILocation(line: 370, column: 35, scope: !124)
!577 = !DILocation(line: 370, column: 30, scope: !124)
!578 = !DILocation(line: 370, column: 18, scope: !124)
!579 = !DILocation(line: 370, column: 44, scope: !124)
!580 = !DILocation(line: 370, column: 15, scope: !124)
!581 = !DILocation(line: 371, column: 2, scope: !124)
!582 = !DILocation(line: 372, column: 2, scope: !124)
!583 = !DILocation(line: 373, column: 41, scope: !124)
!584 = !DILocation(line: 373, column: 52, scope: !124)
!585 = !DILocation(line: 373, column: 58, scope: !124)
!586 = !DILocation(line: 373, column: 71, scope: !124)
!587 = !DILocation(line: 373, column: 2, scope: !124)
!588 = !DILocation(line: 375, column: 2, scope: !124)
!589 = !DILocation(line: 377, column: 2, scope: !124)
!590 = !DILocation(line: 379, column: 2, scope: !124)
!591 = !DILocation(line: 380, column: 1, scope: !124)
!592 = !{!259, !259, i64 0}
!593 = !{!594, !87, i64 0}
!594 = !{!"strlong", !87, i64 0, !497, i64 8}
!595 = !{!594, !497, i64 8}
!596 = !{!497, !497, i64 0}
!597 = !{!598, !93, i64 24}
!598 = !{!"tm", !93, i64 0, !93, i64 4, !93, i64 8, !93, i64 12, !93, i64 16, !93, i64 20, !93, i64 24, !93, i64 28, !93, i64 32, !497, i64 40, !87, i64 48}
!599 = !{!598, !93, i64 12}
!600 = !{!598, !93, i64 16}
!601 = !{!598, !93, i64 20}
!602 = !{!598, !93, i64 8}
!603 = !{!598, !93, i64 4}
!604 = !{!598, !93, i64 0}
!605 = !{!606, !93, i64 4}
!606 = !{!"linger", !93, i64 0, !93, i64 4}
!607 = !{!606, !93, i64 0}
!608 = !{i32 -2146824310}
!609 = !{i32 -2146823664}
!610 = !{!611, !87, i64 0}
!611 = !{!"Options", !87, i64 0, !87, i64 8, !87, i64 16}
!612 = !{!611, !87, i64 8}
