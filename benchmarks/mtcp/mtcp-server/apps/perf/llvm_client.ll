; ModuleID = 'client.c'
source_filename = "client.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.mtcp_context = type { i32, i8* }
%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.mtcp_conf = type { i32, i32, i32, i32, i32, i32, i32 }
%struct.mtcp_epoll_event = type { i32, %union.mtcp_epoll_data }
%union.mtcp_epoll_data = type { i8* }
%struct.sockaddr_in = type { i16, i16, %struct.in_addr, [8 x i8] }
%struct.in_addr = type { i32 }
%struct.timeval = type { i64, i64 }
%struct.timespec = type { i64, i64 }
%struct.sockaddr = type { i16, [14 x i8] }
%struct.timezone = type { i32, i32 }

@mtcp_ctx = dso_local thread_local local_unnamed_addr global %struct.mtcp_context* null, align 8, !dbg !0
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
@.str.36 = private unnamed_addr constant [50 x i8] c"[DEBUG] Got FIN-ACK from receiver (%d bytes): %s\0A\00", align 1
@.str.37 = private unnamed_addr constant [45 x i8] c"[DEBUG] Done writing... waiting for FIN-ACK\0A\00", align 1
@.str.38 = private unnamed_addr constant [41 x i8] c"[DEBUG] Done reading. Closing socket...\0A\00", align 1
@.str.39 = private unnamed_addr constant [24 x i8] c"[DEBUG] Socket closed.\0A\00", align 1
@.str.41 = private unnamed_addr constant [18 x i8] c"Time elapsed: %f\0A\00", align 1
@.str.42 = private unnamed_addr constant [22 x i8] c"Total bytes sent: %d\0A\00", align 1
@.str.43 = private unnamed_addr constant [26 x i8] c"Throughput: %.3fMbit/sec\0A\00", align 1
@intvActionHook = common dso_local local_unnamed_addr global void (i64)* null, align 8, !dbg !60
@str = private unnamed_addr constant [29 x i8] c"CI version of app is running\00", align 1
@str.44 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1

; Function Attrs: nounwind uwtable
define dso_local void @init_stats() local_unnamed_addr #0 !dbg !72 {
entry:
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @str, i64 0, i64 0)), !dbg !76
  %call1 = tail call i32 @register_ci(void (i64)* nonnull @compiler_interrupt_handler) #13, !dbg !77
  ret void, !dbg !78
}

; Function Attrs: nofree nounwind
declare dso_local i32 @printf(i8* nocapture readonly, ...) local_unnamed_addr #1

declare dso_local i32 @register_ci(void (i64)*) local_unnamed_addr #2

; Function Attrs: nounwind uwtable
define dso_local void @compiler_interrupt_handler(i64 %ic) #0 !dbg !79 {
entry:
  call void @llvm.dbg.value(metadata i64 undef, metadata !81, metadata !DIExpression()), !dbg !82
  %0 = load %struct.mtcp_context*, %struct.mtcp_context** @mtcp_ctx, align 8, !dbg !83, !tbaa !85
  %mtcp_thr_ctx = getelementptr inbounds %struct.mtcp_context, %struct.mtcp_context* %0, i64 0, i32 1, !dbg !89
  %1 = load i8*, i8** %mtcp_thr_ctx, align 8, !dbg !89, !tbaa !90
  %tobool = icmp eq i8* %1, null, !dbg !93
  br i1 %tobool, label %if.else, label %if.then, !dbg !94

if.then:                                          ; preds = %entry
  tail call void @RunMainLoop(i8* nonnull %1) #13, !dbg !95
  br label %if.end, !dbg !97

if.else:                                          ; preds = %entry
  %call = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.1, i64 0, i64 0)), !dbg !98
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  ret void, !dbg !99
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #3

declare dso_local void @RunMainLoop(i8*) local_unnamed_addr #2

; Function Attrs: noreturn nounwind uwtable
define dso_local void @SignalHandler(i32 %signum) #4 !dbg !100 {
entry:
  call void @llvm.dbg.value(metadata i32 undef, metadata !104, metadata !DIExpression()), !dbg !105
  %0 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !106, !tbaa !85
  %1 = tail call i64 @fwrite(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.2, i64 0, i64 0), i64 16, i64 1, %struct._IO_FILE* %0) #14, !dbg !106
  tail call void @exit(i32 -1) #15, !dbg !107
  unreachable, !dbg !107
}

; Function Attrs: nofree nounwind
declare dso_local i32 @fprintf(%struct._IO_FILE* nocapture, i8* nocapture readonly, ...) local_unnamed_addr #1

; Function Attrs: noreturn nounwind
declare dso_local void @exit(i32) local_unnamed_addr #5

; Function Attrs: nofree nounwind uwtable
define dso_local void @print_usage(i32 %mode) local_unnamed_addr #6 !dbg !108 {
entry:
  call void @llvm.dbg.value(metadata i32 %mode, metadata !110, metadata !DIExpression()), !dbg !111
  %0 = icmp ult i32 %mode, 2, !dbg !112
  br i1 %0, label %if.then, label %if.end, !dbg !112

if.then:                                          ; preds = %entry
  %1 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !114, !tbaa !85
  %2 = tail call i64 @fwrite(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.3, i64 0, i64 0), i64 73, i64 1, %struct._IO_FILE* %1) #14, !dbg !114
  br label %if.end, !dbg !116

if.end:                                           ; preds = %entry, %if.then
  %3 = and i32 %mode, -3, !dbg !117
  %4 = icmp eq i32 %3, 0, !dbg !117
  br i1 %4, label %if.then5, label %if.end7, !dbg !117

if.then5:                                         ; preds = %if.end
  %5 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !119, !tbaa !85
  %6 = tail call i64 @fwrite(i8* getelementptr inbounds ([62 x i8], [62 x i8]* @.str.4, i64 0, i64 0), i64 61, i64 1, %struct._IO_FILE* %5) #14, !dbg !119
  br label %if.end7, !dbg !121

if.end7:                                          ; preds = %if.end, %if.then5
  ret void, !dbg !122
}

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** nocapture readonly %argv) local_unnamed_addr #0 !dbg !123 {
entry:
  %mcfg = alloca %struct.mtcp_conf, align 4
  %ev = alloca %struct.mtcp_epoll_event, align 8
  %saddr = alloca %struct.sockaddr_in, align 4
  %daddr = alloca %struct.sockaddr_in, align 4
  %t1 = alloca %struct.timeval, align 8
  %t2 = alloca %struct.timeval, align 8
  %ts_start = alloca %struct.timespec, align 8
  %now = alloca %struct.timespec, align 8
  %buf = alloca [8192 x i8], align 16
  %rcvbuf = alloca [8192 x i8], align 16
  call void @llvm.dbg.value(metadata i32 %argc, metadata !127, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i8** %argv, metadata !128, metadata !DIExpression()), !dbg !218
  %puts.i = tail call i32 @puts(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @str, i64 0, i64 0)) #13, !dbg !219
  %call1.i = tail call i32 @register_ci(void (i64)* nonnull @compiler_interrupt_handler) #13, !dbg !221
  %0 = bitcast %struct.mtcp_conf* %mcfg to i8*, !dbg !222
  call void @llvm.lifetime.start.p0i8(i64 28, i8* nonnull %0) #13, !dbg !222
  %1 = bitcast %struct.mtcp_epoll_event* %ev to i8*, !dbg !223
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %1) #13, !dbg !223
  call void @llvm.dbg.value(metadata i32 0, metadata !146, metadata !DIExpression()), !dbg !218
  %2 = bitcast %struct.sockaddr_in* %saddr to i8*, !dbg !224
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %2) #13, !dbg !224
  %3 = bitcast %struct.sockaddr_in* %daddr to i8*, !dbg !224
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %3) #13, !dbg !224
  call void @llvm.dbg.value(metadata i32 3, metadata !167, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 0, metadata !169, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 0, metadata !170, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 0, metadata !171, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 0, metadata !172, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 0, metadata !173, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 0, metadata !174, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata double 0.000000e+00, metadata !175, metadata !DIExpression()), !dbg !218
  %4 = bitcast %struct.timeval* %t1 to i8*, !dbg !225
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %4) #13, !dbg !225
  %5 = bitcast %struct.timeval* %t2 to i8*, !dbg !225
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %5) #13, !dbg !225
  %6 = bitcast %struct.timespec* %ts_start to i8*, !dbg !226
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %6) #13, !dbg !226
  %7 = bitcast %struct.timespec* %now to i8*, !dbg !226
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %7) #13, !dbg !226
  %8 = getelementptr inbounds [8192 x i8], [8192 x i8]* %buf, i64 0, i64 0, !dbg !227
  call void @llvm.lifetime.start.p0i8(i64 8192, i8* nonnull %8) #13, !dbg !227
  call void @llvm.dbg.declare(metadata [8192 x i8]* %buf, metadata !197, metadata !DIExpression()), !dbg !228
  %9 = getelementptr inbounds [8192 x i8], [8192 x i8]* %rcvbuf, i64 0, i64 0, !dbg !229
  call void @llvm.lifetime.start.p0i8(i64 8192, i8* nonnull %9) #13, !dbg !229
  call void @llvm.dbg.declare(metadata [8192 x i8]* %rcvbuf, metadata !201, metadata !DIExpression()), !dbg !230
  call void @llvm.dbg.value(metadata i32 0, metadata !202, metadata !DIExpression()), !dbg !218
  %cmp = icmp slt i32 %argc, 2, !dbg !231
  br i1 %cmp, label %if.then, label %if.end, !dbg !233

if.then:                                          ; preds = %entry
  call void @llvm.dbg.value(metadata i32 0, metadata !110, metadata !DIExpression()) #13, !dbg !234
  %10 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !237, !tbaa !85
  %11 = tail call i64 @fwrite(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.3, i64 0, i64 0), i64 73, i64 1, %struct._IO_FILE* %10) #16, !dbg !237
  %12 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !238, !tbaa !85
  %13 = tail call i64 @fwrite(i8* getelementptr inbounds ([62 x i8], [62 x i8]* @.str.4, i64 0, i64 0), i64 61, i64 1, %struct._IO_FILE* %12) #16, !dbg !238
  br label %cleanup308, !dbg !239

if.end:                                           ; preds = %entry
  %arrayidx = getelementptr inbounds i8*, i8** %argv, i64 1, !dbg !240
  %14 = load i8*, i8** %arrayidx, align 8, !dbg !240, !tbaa !85
  %call = tail call i32 @strncmp(i8* %14, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.5, i64 0, i64 0), i64 4) #17, !dbg !241
  %cmp1 = icmp eq i32 %call, 0, !dbg !242
  br i1 %cmp1, label %if.then2, label %if.else19, !dbg !243

if.then2:                                         ; preds = %if.end
  %cmp3 = icmp slt i32 %argc, 5, !dbg !244
  %15 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !246, !tbaa !85
  br i1 %cmp3, label %if.then4, label %if.end5, !dbg !247

if.then4:                                         ; preds = %if.then2
  call void @llvm.dbg.value(metadata i32 1, metadata !110, metadata !DIExpression()) #13, !dbg !248
  %16 = tail call i64 @fwrite(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.3, i64 0, i64 0), i64 73, i64 1, %struct._IO_FILE* %15) #16, !dbg !251
  br label %cleanup308, !dbg !252

if.end5:                                          ; preds = %if.then2
  call void @llvm.dbg.value(metadata i32 1, metadata !202, metadata !DIExpression()), !dbg !218
  %17 = tail call i64 @fwrite(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.6, i64 0, i64 0), i64 18, i64 1, %struct._IO_FILE* %15) #14, !dbg !253
  %sin_family = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %daddr, i64 0, i32 0, !dbg !254
  store i16 2, i16* %sin_family, align 4, !dbg !255, !tbaa !256
  %arrayidx7 = getelementptr inbounds i8*, i8** %argv, i64 2, !dbg !260
  %18 = load i8*, i8** %arrayidx7, align 8, !dbg !260, !tbaa !85
  %call8 = tail call i32 @inet_addr(i8* %18) #13, !dbg !261
  %s_addr = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %daddr, i64 0, i32 2, i32 0, !dbg !262
  store i32 %call8, i32* %s_addr, align 4, !dbg !263, !tbaa !264
  %arrayidx9 = getelementptr inbounds i8*, i8** %argv, i64 3, !dbg !265
  %19 = load i8*, i8** %arrayidx9, align 8, !dbg !265, !tbaa !85
  call void @llvm.dbg.value(metadata i8* %19, metadata !266, metadata !DIExpression()) #13, !dbg !274
  %call.i = tail call i64 @strtol(i8* nocapture nonnull %19, i8** null, i32 10) #13, !dbg !276
  %conv = trunc i64 %call.i to i16, !dbg !265
  call void @llvm.dbg.value(metadata i16 %conv, metadata !207, metadata !DIExpression()), !dbg !277
  %20 = tail call i1 @llvm.is.constant.i16(i16 %conv), !dbg !278
  br i1 %20, label %if.then11, label %if.else, !dbg !265

if.then11:                                        ; preds = %if.end5
  %rev458 = tail call i16 @llvm.bswap.i16(i16 %conv)
  call void @llvm.dbg.value(metadata i16 %rev458, metadata !203, metadata !DIExpression()), !dbg !277
  br label %if.end63, !dbg !278

if.else:                                          ; preds = %if.end5
  %21 = tail call i16 asm "rorw $$8, ${0:w}", "=r,0,~{cc},~{dirflag},~{fpsr},~{flags}"(i16 %conv) #10, !dbg !278, !srcloc !280
  call void @llvm.dbg.value(metadata i16 %21, metadata !203, metadata !DIExpression()), !dbg !277
  br label %if.end63

if.else19:                                        ; preds = %if.end
  %call21 = tail call i32 @strncmp(i8* %14, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.7, i64 0, i64 0), i64 4) #17, !dbg !281
  %cmp22 = icmp eq i32 %call21, 0, !dbg !282
  br i1 %cmp22, label %if.then24, label %if.end59, !dbg !283

if.then24:                                        ; preds = %if.else19
  %cmp25 = icmp slt i32 %argc, 4, !dbg !284
  %22 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !286, !tbaa !85
  br i1 %cmp25, label %if.then27, label %if.end28, !dbg !287

if.then27:                                        ; preds = %if.then24
  call void @llvm.dbg.value(metadata i32 2, metadata !110, metadata !DIExpression()) #13, !dbg !288
  %23 = tail call i64 @fwrite(i8* getelementptr inbounds ([62 x i8], [62 x i8]* @.str.4, i64 0, i64 0), i64 61, i64 1, %struct._IO_FILE* %22) #16, !dbg !291
  br label %cleanup308, !dbg !292

if.end28:                                         ; preds = %if.then24
  call void @llvm.dbg.value(metadata i32 2, metadata !202, metadata !DIExpression()), !dbg !218
  %24 = tail call i64 @fwrite(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.8, i64 0, i64 0), i64 18, i64 1, %struct._IO_FILE* %22) #14, !dbg !293
  %sin_family30 = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %saddr, i64 0, i32 0, !dbg !294
  store i16 2, i16* %sin_family30, align 4, !dbg !295, !tbaa !256
  %arrayidx31 = getelementptr inbounds i8*, i8** %argv, i64 2, !dbg !296
  %25 = load i8*, i8** %arrayidx31, align 8, !dbg !296, !tbaa !85
  %call32 = tail call i32 @inet_addr(i8* %25) #13, !dbg !297
  %s_addr34 = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %saddr, i64 0, i32 2, i32 0, !dbg !298
  store i32 %call32, i32* %s_addr34, align 4, !dbg !299, !tbaa !264
  %arrayidx37 = getelementptr inbounds i8*, i8** %argv, i64 3, !dbg !300
  %26 = load i8*, i8** %arrayidx37, align 8, !dbg !300, !tbaa !85
  call void @llvm.dbg.value(metadata i8* %26, metadata !266, metadata !DIExpression()) #13, !dbg !301
  %call.i461 = tail call i64 @strtol(i8* nocapture nonnull %26, i8** null, i32 10) #13, !dbg !303
  %conv39 = trunc i64 %call.i461 to i16, !dbg !300
  call void @llvm.dbg.value(metadata i16 %conv39, metadata !212, metadata !DIExpression()), !dbg !304
  %27 = tail call i1 @llvm.is.constant.i16(i16 %conv39), !dbg !305
  br i1 %27, label %if.then40, label %if.else49, !dbg !300

if.then40:                                        ; preds = %if.end28
  %rev = tail call i16 @llvm.bswap.i16(i16 %conv39)
  call void @llvm.dbg.value(metadata i16 %rev, metadata !208, metadata !DIExpression()), !dbg !304
  br label %if.end63, !dbg !305

if.else49:                                        ; preds = %if.end28
  %28 = tail call i16 asm "rorw $$8, ${0:w}", "=r,0,~{cc},~{dirflag},~{fpsr},~{flags}"(i16 %conv39) #10, !dbg !305, !srcloc !307
  call void @llvm.dbg.value(metadata i16 %28, metadata !208, metadata !DIExpression()), !dbg !304
  br label %if.end63

if.end59:                                         ; preds = %if.else19
  %29 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !308, !tbaa !85
  %call57 = tail call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %29, i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.9, i64 0, i64 0), i8* %14) #14, !dbg !308
  call void @llvm.dbg.value(metadata i32 0, metadata !110, metadata !DIExpression()) #13, !dbg !310
  %30 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !312, !tbaa !85
  %31 = tail call i64 @fwrite(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.3, i64 0, i64 0), i64 73, i64 1, %struct._IO_FILE* %30) #16, !dbg !312
  %32 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !313, !tbaa !85
  %33 = tail call i64 @fwrite(i8* getelementptr inbounds ([62 x i8], [62 x i8]* @.str.4, i64 0, i64 0), i64 61, i64 1, %struct._IO_FILE* %32) #16, !dbg !313
  call void @llvm.dbg.value(metadata i32 0, metadata !202, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 undef, metadata !168, metadata !DIExpression()), !dbg !218
  br label %cleanup308, !dbg !314

if.end63:                                         ; preds = %if.then40, %if.else49, %if.then11, %if.else
  %daddr.sink = phi %struct.sockaddr_in* [ %daddr, %if.else ], [ %daddr, %if.then11 ], [ %saddr, %if.else49 ], [ %saddr, %if.then40 ]
  %__v.0.sink = phi i16 [ %21, %if.else ], [ %rev458, %if.then11 ], [ %28, %if.else49 ], [ %rev, %if.then40 ]
  %mode.0.ph = phi i32 [ 1, %if.else ], [ 1, %if.then11 ], [ 2, %if.else49 ], [ 2, %if.then40 ]
  %sin_port = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %daddr.sink, i64 0, i32 1, !dbg !315
  store i16 %__v.0.sink, i16* %sin_port, align 2, !dbg !315, !tbaa !316
  %arrayidx17 = getelementptr inbounds i8*, i8** %argv, i64 4, !dbg !315
  %34 = load i8*, i8** %arrayidx17, align 8, !dbg !315, !tbaa !85
  %call.i459 = tail call i64 @strtol(i8* nocapture nonnull %34, i8** null, i32 10) #13, !dbg !315
  call void @llvm.dbg.value(metadata i32 0, metadata !202, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 undef, metadata !168, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata %struct.mtcp_conf* %mcfg, metadata !133, metadata !DIExpression(DW_OP_deref)), !dbg !218
  %call64 = call i32 @mtcp_getconf(%struct.mtcp_conf* nonnull %mcfg) #13, !dbg !317
  %num_cores = getelementptr inbounds %struct.mtcp_conf, %struct.mtcp_conf* %mcfg, i64 0, i32 0, !dbg !318
  store i32 1, i32* %num_cores, align 4, !dbg !319, !tbaa !320
  call void @llvm.dbg.value(metadata %struct.mtcp_conf* %mcfg, metadata !133, metadata !DIExpression(DW_OP_deref)), !dbg !218
  %call65 = call i32 @mtcp_setconf(%struct.mtcp_conf* nonnull %mcfg) #13, !dbg !322
  %call66 = call i64 @time(i64* null) #13, !dbg !323
  %conv67 = trunc i64 %call66 to i32, !dbg !323
  call void @srand(i32 %conv67) #13, !dbg !324
  %35 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !325, !tbaa !85
  %36 = call i64 @fwrite(i8* getelementptr inbounds ([31 x i8], [31 x i8]* @.str.10, i64 0, i64 0), i64 30, i64 1, %struct._IO_FILE* %35) #14, !dbg !325
  %call69 = call i32 @mtcp_init(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.11, i64 0, i64 0)) #13, !dbg !326
  %tobool = icmp eq i32 %call69, 0, !dbg !326
  br i1 %tobool, label %if.end72, label %if.then70, !dbg !328

if.then70:                                        ; preds = %if.end63
  %37 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !329, !tbaa !85
  %38 = call i64 @fwrite(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.12, i64 0, i64 0), i64 28, i64 1, %struct._IO_FILE* %37) #14, !dbg !329
  br label %cleanup308, !dbg !331

if.end72:                                         ; preds = %if.end63
  call void @llvm.dbg.value(metadata %struct.mtcp_conf* %mcfg, metadata !133, metadata !DIExpression(DW_OP_deref)), !dbg !218
  %call73 = call i32 @mtcp_getconf(%struct.mtcp_conf* nonnull %mcfg) #13, !dbg !332
  %max_concurrency = getelementptr inbounds %struct.mtcp_conf, %struct.mtcp_conf* %mcfg, i64 0, i32 1, !dbg !333
  store i32 3, i32* %max_concurrency, align 4, !dbg !334, !tbaa !335
  %max_num_buffers = getelementptr inbounds %struct.mtcp_conf, %struct.mtcp_conf* %mcfg, i64 0, i32 2, !dbg !336
  store i32 3, i32* %max_num_buffers, align 4, !dbg !337, !tbaa !338
  call void @llvm.dbg.value(metadata %struct.mtcp_conf* %mcfg, metadata !133, metadata !DIExpression(DW_OP_deref)), !dbg !218
  %call74 = call i32 @mtcp_setconf(%struct.mtcp_conf* nonnull %mcfg) #13, !dbg !339
  %call75 = call void (i32)* @mtcp_register_signal(i32 2, void (i32)* nonnull @SignalHandler) #13, !dbg !340
  %39 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !341, !tbaa !85
  %40 = call i64 @fwrite(i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.13, i64 0, i64 0), i64 35, i64 1, %struct._IO_FILE* %39) #14, !dbg !341
  %call77 = call i32 @mtcp_core_affinitize(i32 0) #13, !dbg !342
  %call84 = call %struct.mtcp_context* @mtcp_create_context(i32 0) #13, !dbg !343
  %tobool87 = icmp eq %struct.mtcp_context* %call84, null, !dbg !344
  br i1 %tobool87, label %if.then88, label %if.end90, !dbg !346

if.then88:                                        ; preds = %if.end72
  %41 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !347, !tbaa !85
  %42 = call i64 @fwrite(i8* getelementptr inbounds ([32 x i8], [32 x i8]* @.str.16, i64 0, i64 0), i64 31, i64 1, %struct._IO_FILE* %41) #14, !dbg !347
  br label %cleanup308, !dbg !349

if.end90:                                         ; preds = %if.end72
  call void @llvm.dbg.value(metadata %struct.mtcp_context* %call84, metadata !132, metadata !DIExpression()), !dbg !218
  store %struct.mtcp_context* %call84, %struct.mtcp_context** @mtcp_ctx, align 8, !dbg !350, !tbaa !85
  %cmp93 = icmp eq i32 %mode.0.ph, 1, !dbg !351
  br i1 %cmp93, label %if.then95, label %if.end102, !dbg !353

if.then95:                                        ; preds = %if.end90
  %43 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !354, !tbaa !85
  %44 = call i64 @fwrite(i8* getelementptr inbounds ([46 x i8], [46 x i8]* @.str.17, i64 0, i64 0), i64 45, i64 1, %struct._IO_FILE* %43) #14, !dbg !354
  %s_addr98 = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %daddr, i64 0, i32 2, i32 0, !dbg !356
  %45 = load i32, i32* %s_addr98, align 4, !dbg !356, !tbaa !264
  %sin_port99 = getelementptr inbounds %struct.sockaddr_in, %struct.sockaddr_in* %daddr, i64 0, i32 1, !dbg !357
  %46 = load i16, i16* %sin_port99, align 2, !dbg !357, !tbaa !316
  %conv100 = zext i16 %46 to i32, !dbg !358
  %call101 = call i32 @mtcp_init_rss(%struct.mtcp_context* nonnull %call84, i32 0, i32 1, i32 %45, i32 %conv100) #13, !dbg !359
  br label %if.end102, !dbg !360

if.end102:                                        ; preds = %if.then95, %if.end90
  %47 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !361, !tbaa !85
  %48 = call i64 @fwrite(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.18, i64 0, i64 0), i64 28, i64 1, %struct._IO_FILE* %47) #14, !dbg !361
  %49 = load i32, i32* %max_num_buffers, align 4, !dbg !362, !tbaa !338
  %call106 = call i32 @mtcp_epoll_create(%struct.mtcp_context* nonnull %call84, i32 %49) #13, !dbg !363
  call void @llvm.dbg.value(metadata i32 %call106, metadata !147, metadata !DIExpression()), !dbg !218
  %50 = load i32, i32* %max_num_buffers, align 4, !dbg !364, !tbaa !338
  %conv108 = sext i32 %50 to i64, !dbg !365
  %call109 = call noalias i8* @calloc(i64 %conv108, i64 16) #13, !dbg !366
  %51 = bitcast i8* %call109 to %struct.mtcp_epoll_event*, !dbg !367
  call void @llvm.dbg.value(metadata %struct.mtcp_epoll_event* %51, metadata !144, metadata !DIExpression()), !dbg !218
  %tobool110 = icmp eq i8* %call109, null, !dbg !368
  %52 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !218, !tbaa !85
  br i1 %tobool110, label %if.then111, label %if.end113, !dbg !370

if.then111:                                       ; preds = %if.end102
  %53 = call i64 @fwrite(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.19, i64 0, i64 0), i64 27, i64 1, %struct._IO_FILE* %52) #14, !dbg !371
  br label %cleanup308, !dbg !373

if.end113:                                        ; preds = %if.end102
  %54 = call i64 @fwrite(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.20, i64 0, i64 0), i64 27, i64 1, %struct._IO_FILE* %52) #14, !dbg !374
  %call115 = call i32 @mtcp_socket(%struct.mtcp_context* nonnull %call84, i32 2, i32 1, i32 0) #13, !dbg !375
  call void @llvm.dbg.value(metadata i32 %call115, metadata !166, metadata !DIExpression()), !dbg !218
  %cmp116 = icmp slt i32 %call115, 0, !dbg !376
  br i1 %cmp116, label %if.then118, label %if.end120, !dbg !378

if.then118:                                       ; preds = %if.end113
  %55 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !379, !tbaa !85
  %56 = call i64 @fwrite(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.21, i64 0, i64 0), i64 25, i64 1, %struct._IO_FILE* %55) #14, !dbg !379
  br label %cleanup308, !dbg !381

if.end120:                                        ; preds = %if.end113
  %call121 = call i32 @mtcp_setsock_nonblock(%struct.mtcp_context* nonnull %call84, i32 %call115) #13, !dbg !382
  call void @llvm.dbg.value(metadata i32 %call121, metadata !129, metadata !DIExpression()), !dbg !218
  %cmp122 = icmp slt i32 %call121, 0, !dbg !383
  br i1 %cmp122, label %if.then124, label %if.end126, !dbg !385

if.then124:                                       ; preds = %if.end120
  %57 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !386, !tbaa !85
  %58 = call i64 @fwrite(i8* getelementptr inbounds ([43 x i8], [43 x i8]* @.str.22, i64 0, i64 0), i64 42, i64 1, %struct._IO_FILE* %57) #14, !dbg !386
  br label %cleanup308, !dbg !388

if.end126:                                        ; preds = %if.end120
  %events127 = getelementptr inbounds %struct.mtcp_epoll_event, %struct.mtcp_epoll_event* %ev, i64 0, i32 0, !dbg !389
  store i32 1, i32* %events127, align 8, !dbg !390, !tbaa !391
  %data = getelementptr inbounds %struct.mtcp_epoll_event, %struct.mtcp_epoll_event* %ev, i64 0, i32 1, !dbg !393
  %sockid = bitcast %union.mtcp_epoll_data* %data to i32*, !dbg !394
  store i32 %call115, i32* %sockid, align 8, !dbg !395, !tbaa !396
  call void @llvm.dbg.value(metadata %struct.mtcp_epoll_event* %ev, metadata !145, metadata !DIExpression(DW_OP_deref)), !dbg !218
  %call128 = call i32 @mtcp_epoll_ctl(%struct.mtcp_context* nonnull %call84, i32 %call106, i32 1, i32 %call115, %struct.mtcp_epoll_event* nonnull %ev) #13, !dbg !397
  %cmp129 = icmp eq i32 %mode.0.ph, 2, !dbg !398
  br i1 %cmp129, label %if.then131, label %end_wait_loop, !dbg !400

if.then131:                                       ; preds = %if.end126
  %59 = bitcast %struct.sockaddr_in* %saddr to %struct.sockaddr*, !dbg !401
  %call132 = call i32 @mtcp_bind(%struct.mtcp_context* nonnull %call84, i32 %call115, %struct.sockaddr* nonnull %59, i32 16) #13, !dbg !403
  call void @llvm.dbg.value(metadata i32 %call132, metadata !129, metadata !DIExpression()), !dbg !218
  %cmp133 = icmp slt i32 %call132, 0, !dbg !404
  br i1 %cmp133, label %if.then135, label %if.end137, !dbg !406

if.then135:                                       ; preds = %if.then131
  %60 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !407, !tbaa !85
  %61 = call i64 @fwrite(i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.23, i64 0, i64 0), i64 40, i64 1, %struct._IO_FILE* %60) #14, !dbg !407
  br label %if.end137, !dbg !409

if.end137:                                        ; preds = %if.then135, %if.then131
  %call138 = call i32 @mtcp_listen(%struct.mtcp_context* nonnull %call84, i32 %call115, i32 3) #13, !dbg !410
  call void @llvm.dbg.value(metadata i32 %call138, metadata !129, metadata !DIExpression()), !dbg !218
  %cmp139 = icmp slt i32 %call138, 0, !dbg !411
  br i1 %cmp139, label %if.then141, label %if.end145, !dbg !413

if.then141:                                       ; preds = %if.end137
  %62 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !414, !tbaa !85
  %call142 = tail call i32* @__errno_location() #10, !dbg !414
  %63 = load i32, i32* %call142, align 4, !dbg !414, !tbaa !416
  %call143 = call i8* @strerror(i32 %63) #13, !dbg !414
  %call144 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %62, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.24, i64 0, i64 0), i8* %call143) #14, !dbg !414
  br label %if.end145, !dbg !417

if.end145:                                        ; preds = %if.then141, %if.end137
  %call146482 = call i32 @mtcp_epoll_wait(%struct.mtcp_context* nonnull %call84, i32 %call106, %struct.mtcp_epoll_event* nonnull %51, i32 30000, i32 -1) #13, !dbg !418
  call void @llvm.dbg.value(metadata i32 %call146482, metadata !173, metadata !DIExpression()), !dbg !218
  %cmp147483 = icmp slt i32 %call146482, 0, !dbg !420
  br i1 %cmp147483, label %if.then149, label %for.cond.preheader, !dbg !422

while.cond.loopexit:                              ; preds = %if.else184, %for.cond.preheader
  %call146 = call i32 @mtcp_epoll_wait(%struct.mtcp_context* nonnull %call84, i32 %call106, %struct.mtcp_epoll_event* nonnull %51, i32 30000, i32 -1) #13, !dbg !418
  call void @llvm.dbg.value(metadata i32 %call146, metadata !173, metadata !DIExpression()), !dbg !218
  %cmp147 = icmp slt i32 %call146, 0, !dbg !420
  br i1 %cmp147, label %if.then149, label %for.cond.preheader, !dbg !422

for.cond.preheader:                               ; preds = %if.end145, %while.cond.loopexit
  %call146484 = phi i32 [ %call146, %while.cond.loopexit ], [ %call146482, %if.end145 ]
  call void @llvm.dbg.value(metadata i32 0, metadata !130, metadata !DIExpression()), !dbg !218
  %cmp156480 = icmp sgt i32 %call146484, 0, !dbg !423
  br i1 %cmp156480, label %for.body.preheader, label %while.cond.loopexit, !dbg !426, !llvm.loop !427

for.body.preheader:                               ; preds = %for.cond.preheader
  %wide.trip.count489 = zext i32 %call146484 to i64, !dbg !423
  br label %for.body, !dbg !426

if.then149:                                       ; preds = %while.cond.loopexit, %if.end145
  %call150 = tail call i32* @__errno_location() #10, !dbg !430
  %64 = load i32, i32* %call150, align 4, !dbg !430, !tbaa !416
  %cmp151 = icmp eq i32 %64, 4, !dbg !433
  br i1 %cmp151, label %cleanup308, label %if.then153, !dbg !434

if.then153:                                       ; preds = %if.then149
  call void @perror(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.25, i64 0, i64 0)) #14, !dbg !435
  br label %cleanup308, !dbg !437

for.body:                                         ; preds = %if.else184, %for.body.preheader
  %indvars.iv487 = phi i64 [ 0, %for.body.preheader ], [ %indvars.iv.next488, %if.else184 ]
  call void @llvm.dbg.value(metadata i64 %indvars.iv487, metadata !130, metadata !DIExpression()), !dbg !218
  %data159 = getelementptr inbounds %struct.mtcp_epoll_event, %struct.mtcp_epoll_event* %51, i64 %indvars.iv487, i32 1, !dbg !438
  %sockid160 = bitcast %union.mtcp_epoll_data* %data159 to i32*, !dbg !441
  %65 = load i32, i32* %sockid160, align 8, !dbg !441, !tbaa !396
  %cmp161 = icmp eq i32 %65, %call115, !dbg !442
  br i1 %cmp161, label %if.then163, label %if.else184, !dbg !443

if.then163:                                       ; preds = %for.body
  %call164 = call i32 @mtcp_accept(%struct.mtcp_context* nonnull %call84, i32 %call115, %struct.sockaddr* null, i32* null) #13, !dbg !444
  call void @llvm.dbg.value(metadata i32 %call164, metadata !131, metadata !DIExpression()), !dbg !218
  %cmp165 = icmp sgt i32 %call164, -1, !dbg !446
  br i1 %cmp165, label %if.then167, label %if.else174, !dbg !448

if.then167:                                       ; preds = %if.then163
  %cmp168 = icmp sgt i32 %call164, 9999, !dbg !449
  br i1 %cmp168, label %if.then170, label %if.end172, !dbg !452

if.then170:                                       ; preds = %if.then167
  %66 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !453, !tbaa !85
  %call171 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %66, i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.26, i64 0, i64 0), i32 %call164) #14, !dbg !453
  br label %if.end172, !dbg !455

if.end172:                                        ; preds = %if.then170, %if.then167
  %67 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !456, !tbaa !85
  %68 = call i64 @fwrite(i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.27, i64 0, i64 0), i64 32, i64 1, %struct._IO_FILE* %67) #14, !dbg !456
  br label %if.end178, !dbg !457

if.else174:                                       ; preds = %if.then163
  %69 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !458, !tbaa !85
  %call175 = tail call i32* @__errno_location() #10, !dbg !458
  %70 = load i32, i32* %call175, align 4, !dbg !458, !tbaa !416
  %call176 = call i8* @strerror(i32 %70) #13, !dbg !458
  %call177 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %69, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.28, i64 0, i64 0), i8* %call176) #14, !dbg !458
  br label %if.end178

if.end178:                                        ; preds = %if.else174, %if.end172
  call void @llvm.dbg.value(metadata %struct.mtcp_epoll_event* %ev, metadata !145, metadata !DIExpression(DW_OP_deref)), !dbg !218
  %call179 = call i32 @mtcp_epoll_ctl(%struct.mtcp_context* nonnull %call84, i32 %call106, i32 2, i32 %call115, %struct.mtcp_epoll_event* nonnull %ev) #13, !dbg !460
  call void @llvm.dbg.value(metadata i32 %call164, metadata !166, metadata !DIExpression()), !dbg !218
  store i32 5, i32* %events127, align 8, !dbg !461, !tbaa !391
  store i32 %call164, i32* %sockid, align 8, !dbg !462, !tbaa !396
  call void @llvm.dbg.value(metadata %struct.mtcp_epoll_event* %ev, metadata !145, metadata !DIExpression(DW_OP_deref)), !dbg !218
  %call183 = call i32 @mtcp_epoll_ctl(%struct.mtcp_context* nonnull %call84, i32 %call106, i32 1, i32 %call164, %struct.mtcp_epoll_event* nonnull %ev) #13, !dbg !463
  br label %end_wait_loop, !dbg !464

if.else184:                                       ; preds = %for.body
  %71 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !465, !tbaa !85
  %72 = call i64 @fwrite(i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str.29, i64 0, i64 0), i64 34, i64 1, %struct._IO_FILE* %71) #14, !dbg !465
  %indvars.iv.next488 = add nuw nsw i64 %indvars.iv487, 1, !dbg !467
  call void @llvm.dbg.value(metadata i32 undef, metadata !130, metadata !DIExpression(DW_OP_plus_uconst, 1, DW_OP_stack_value)), !dbg !218
  %exitcond490 = icmp eq i64 %indvars.iv.next488, %wide.trip.count489, !dbg !423
  br i1 %exitcond490, label %while.cond.loopexit, label %for.body, !dbg !426, !llvm.loop !468

end_wait_loop:                                    ; preds = %if.end126, %if.end178
  %sockfd.0 = phi i32 [ %call164, %if.end178 ], [ %call115, %if.end126 ], !dbg !218
  call void @llvm.dbg.value(metadata i32 %sockfd.0, metadata !166, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.label(metadata !216), !dbg !470
  br i1 %cmp93, label %if.then190, label %if.end205, !dbg !471

if.then190:                                       ; preds = %end_wait_loop
  %73 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !472, !tbaa !85
  %74 = call i64 @fwrite(i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.30, i64 0, i64 0), i64 29, i64 1, %struct._IO_FILE* %73) #14, !dbg !472
  %75 = bitcast %struct.sockaddr_in* %daddr to %struct.sockaddr*, !dbg !475
  %call192 = call i32 @mtcp_connect(%struct.mtcp_context* nonnull %call84, i32 %sockfd.0, %struct.sockaddr* nonnull %75, i32 16) #13, !dbg !476
  call void @llvm.dbg.value(metadata i32 %call192, metadata !129, metadata !DIExpression()), !dbg !218
  %cmp193 = icmp slt i32 %call192, 0, !dbg !477
  br i1 %cmp193, label %if.then195, label %if.end203, !dbg !479

if.then195:                                       ; preds = %if.then190
  %76 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !480, !tbaa !85
  %77 = call i64 @fwrite(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.31, i64 0, i64 0), i64 21, i64 1, %struct._IO_FILE* %76) #14, !dbg !480
  %call197 = tail call i32* @__errno_location() #10, !dbg !482
  %78 = load i32, i32* %call197, align 4, !dbg !482, !tbaa !416
  %cmp198 = icmp eq i32 %78, 115, !dbg !484
  br i1 %cmp198, label %if.end203, label %if.then200, !dbg !485

if.then200:                                       ; preds = %if.then195
  call void @perror(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.32, i64 0, i64 0)) #14, !dbg !486
  %call201 = call i32 @mtcp_close(%struct.mtcp_context* nonnull %call84, i32 %sockfd.0) #13, !dbg !488
  br label %cleanup308, !dbg !489

if.end203:                                        ; preds = %if.then195, %if.then190
  %79 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !490, !tbaa !85
  %80 = call i64 @fwrite(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.33, i64 0, i64 0), i64 28, i64 1, %struct._IO_FILE* %79) #14, !dbg !490
  br label %if.end205, !dbg !491

if.end205:                                        ; preds = %if.end203, %end_wait_loop
  call void @llvm.dbg.value(metadata %struct.timespec* %ts_start, metadata !186, metadata !DIExpression(DW_OP_deref)), !dbg !218
  %call206 = call i32 @clock_gettime(i32 1, %struct.timespec* nonnull %ts_start) #13, !dbg !492
  %tv_sec = getelementptr inbounds %struct.timespec, %struct.timespec* %ts_start, i64 0, i32 0, !dbg !493
  %81 = load i64, i64* %tv_sec, align 8, !dbg !493, !tbaa !494
  %sext = shl i64 %call.i459, 32, !dbg !497
  %conv207 = ashr exact i64 %sext, 32, !dbg !497
  call void @llvm.dbg.value(metadata i64 %add, metadata !194, metadata !DIExpression()), !dbg !218
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 %8, i8 -112, i64 8192, i1 false), !dbg !498
  %arrayidx208 = getelementptr inbounds [8192 x i8], [8192 x i8]* %buf, i64 0, i64 8191, !dbg !499
  store i8 0, i8* %arrayidx208, align 1, !dbg !500, !tbaa !396
  br label %while.cond209, !dbg !501

while.cond209:                                    ; preds = %while.cond209, %if.end205
  %bytes_sent.0 = phi i32 [ 0, %if.end205 ], [ %add215, %while.cond209 ], !dbg !218
  call void @llvm.dbg.value(metadata i32 %bytes_sent.0, metadata !171, metadata !DIExpression()), !dbg !218
  %call213 = call i64 @mtcp_write(%struct.mtcp_context* %call84, i32 %sockfd.0, i8* nonnull %8, i64 8192) #13, !dbg !502
  %conv214 = trunc i64 %call213 to i32, !dbg !502
  call void @llvm.dbg.value(metadata i32 %conv214, metadata !169, metadata !DIExpression()), !dbg !218
  %add215 = add nsw i32 %bytes_sent.0, %conv214, !dbg !504
  call void @llvm.dbg.value(metadata i32 %add215, metadata !171, metadata !DIExpression()), !dbg !218
  %cmp216 = icmp sgt i32 %conv214, 0, !dbg !505
  br i1 %cmp216, label %if.then218, label %while.cond209, !dbg !507, !llvm.loop !508

if.then218:                                       ; preds = %while.cond209
  %add = add nsw i64 %81, %conv207, !dbg !510
  call void @llvm.dbg.value(metadata %struct.timeval* %t1, metadata !177, metadata !DIExpression(DW_OP_deref)), !dbg !218
  %call219 = call i32 @gettimeofday(%struct.timeval* nonnull %t1, %struct.timezone* null) #13, !dbg !511
  %tv_sec264 = getelementptr inbounds %struct.timespec, %struct.timespec* %now, i64 0, i32 0, !dbg !513
  br label %while.cond221.outer, !dbg !520

while.cond221.outer:                              ; preds = %for.inc285, %if.then218
  %bytes_sent.1.ph = phi i32 [ %add215, %if.then218 ], [ %bytes_sent.3, %for.inc285 ]
  %sent_close.0.ph = phi i32 [ 0, %if.then218 ], [ %sent_close.2, %for.inc285 ]
  br label %while.cond221, !dbg !521

while.cond221:                                    ; preds = %while.cond221.outer, %while.cond221
  call void @llvm.dbg.value(metadata i32 %sent_close.0.ph, metadata !174, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 %bytes_sent.1.ph, metadata !171, metadata !DIExpression()), !dbg !218
  %82 = load i32, i32* %max_num_buffers, align 4, !dbg !522, !tbaa !338
  %call225 = call i32 @mtcp_epoll_wait(%struct.mtcp_context* %call84, i32 %call106, %struct.mtcp_epoll_event* nonnull %51, i32 %82, i32 -1) #13, !dbg !523
  call void @llvm.dbg.value(metadata i32 %call225, metadata !172, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 0, metadata !213, metadata !DIExpression()), !dbg !524
  call void @llvm.dbg.value(metadata i32 %sent_close.0.ph, metadata !174, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 %bytes_sent.1.ph, metadata !171, metadata !DIExpression()), !dbg !218
  %cmp228475 = icmp sgt i32 %call225, 0, !dbg !525
  br i1 %cmp228475, label %for.body230.preheader, label %while.cond221, !dbg !521

for.body230.preheader:                            ; preds = %while.cond221
  %wide.trip.count = zext i32 %call225 to i64, !dbg !525
  br label %for.body230, !dbg !521

for.body230:                                      ; preds = %for.inc285, %for.body230.preheader
  %indvars.iv = phi i64 [ 0, %for.body230.preheader ], [ %indvars.iv.next, %for.inc285 ]
  %sent_close.1477 = phi i32 [ %sent_close.0.ph, %for.body230.preheader ], [ %sent_close.2, %for.inc285 ]
  %bytes_sent.2476 = phi i32 [ %bytes_sent.1.ph, %for.body230.preheader ], [ %bytes_sent.3, %for.inc285 ]
  call void @llvm.dbg.value(metadata i64 %indvars.iv, metadata !213, metadata !DIExpression()), !dbg !524
  call void @llvm.dbg.value(metadata i32 %sent_close.1477, metadata !174, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476, metadata !171, metadata !DIExpression()), !dbg !218
  %data233 = getelementptr inbounds %struct.mtcp_epoll_event, %struct.mtcp_epoll_event* %51, i64 %indvars.iv, i32 1, !dbg !526
  %sockid234 = bitcast %union.mtcp_epoll_data* %data233 to i32*, !dbg !526
  %83 = load i32, i32* %sockid234, align 8, !dbg !526, !tbaa !396
  %cmp235 = icmp eq i32 %sockfd.0, %83, !dbg !526
  br i1 %cmp235, label %if.end239, label %if.else238, !dbg !529

if.else238:                                       ; preds = %for.body230
  call void @__assert_fail(i8* getelementptr inbounds ([32 x i8], [32 x i8]* @.str.34, i64 0, i64 0), i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.35, i64 0, i64 0), i32 334, i8* getelementptr inbounds ([23 x i8], [23 x i8]* @__PRETTY_FUNCTION__.main, i64 0, i64 0)) #15, !dbg !526
  unreachable, !dbg !526

if.end239:                                        ; preds = %for.body230
  %events242 = getelementptr inbounds %struct.mtcp_epoll_event, %struct.mtcp_epoll_event* %51, i64 %indvars.iv, i32 0, !dbg !530
  %84 = load i32, i32* %events242, align 8, !dbg !530, !tbaa !391
  %and243 = and i32 %84, 1, !dbg !531
  %tobool244 = icmp eq i32 %and243, 0, !dbg !531
  br i1 %tobool244, label %if.else256, label %if.then245, !dbg !532

if.then245:                                       ; preds = %if.end239
  %call248 = call i64 @mtcp_read(%struct.mtcp_context* %call84, i32 %sockfd.0, i8* nonnull %9, i64 8192) #13, !dbg !533
  %conv249 = trunc i64 %call248 to i32, !dbg !533
  call void @llvm.dbg.value(metadata i32 %conv249, metadata !170, metadata !DIExpression()), !dbg !218
  %cmp250 = icmp slt i32 %conv249, 1, !dbg !535
  br i1 %cmp250, label %for.inc285, label %stop_timer, !dbg !537

if.else256:                                       ; preds = %if.end239
  %cmp260 = icmp eq i32 %84, 4, !dbg !538
  br i1 %cmp260, label %if.then262, label %for.inc285, !dbg !539

if.then262:                                       ; preds = %if.else256
  call void @llvm.dbg.value(metadata %struct.timespec* %now, metadata !193, metadata !DIExpression(DW_OP_deref)), !dbg !218
  %call263 = call i32 @clock_gettime(i32 1, %struct.timespec* nonnull %now) #13, !dbg !540
  %85 = load i64, i64* %tv_sec264, align 8, !dbg !541, !tbaa !494
  %cmp265 = icmp slt i64 %85, %add, !dbg !542
  br i1 %cmp265, label %if.then267, label %if.else273, !dbg !543

if.then267:                                       ; preds = %if.then262
  %call270 = call i64 @mtcp_write(%struct.mtcp_context* %call84, i32 %sockfd.0, i8* nonnull %8, i64 8192) #13, !dbg !544
  %conv271 = trunc i64 %call270 to i32, !dbg !544
  call void @llvm.dbg.value(metadata i32 %conv271, metadata !169, metadata !DIExpression()), !dbg !218
  %add272 = add nsw i32 %bytes_sent.2476, %conv271, !dbg !546
  call void @llvm.dbg.value(metadata i32 %add272, metadata !171, metadata !DIExpression()), !dbg !218
  br label %for.inc285, !dbg !547

if.else273:                                       ; preds = %if.then262
  %tobool274 = icmp eq i32 %sent_close.1477, 0, !dbg !548
  br i1 %tobool274, label %if.then275, label %for.inc285, !dbg !550

if.then275:                                       ; preds = %if.else273
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 %8, i8 -106, i64 8192, i1 false), !dbg !551
  %call279 = call i64 @mtcp_write(%struct.mtcp_context* %call84, i32 %sockfd.0, i8* nonnull %8, i64 1) #13, !dbg !553
  %86 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !554, !tbaa !85
  %87 = call i64 @fwrite(i8* getelementptr inbounds ([45 x i8], [45 x i8]* @.str.37, i64 0, i64 0), i64 44, i64 1, %struct._IO_FILE* %86) #14, !dbg !554
  call void @llvm.dbg.value(metadata i32 1, metadata !174, metadata !DIExpression()), !dbg !218
  br label %for.inc285, !dbg !555

for.inc285:                                       ; preds = %if.else273, %if.then267, %if.then275, %if.else256, %if.then245
  %bytes_sent.3 = phi i32 [ %bytes_sent.2476, %if.then245 ], [ %add272, %if.then267 ], [ %bytes_sent.2476, %if.else273 ], [ %bytes_sent.2476, %if.then275 ], [ %bytes_sent.2476, %if.else256 ], !dbg !218
  %sent_close.2 = phi i32 [ %sent_close.1477, %if.then245 ], [ %sent_close.1477, %if.then267 ], [ %sent_close.1477, %if.else273 ], [ 1, %if.then275 ], [ %sent_close.1477, %if.else256 ], !dbg !218
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1, !dbg !556
  call void @llvm.dbg.value(metadata i32 undef, metadata !213, metadata !DIExpression(DW_OP_plus_uconst, 1, DW_OP_stack_value)), !dbg !524
  call void @llvm.dbg.value(metadata i32 %sent_close.2, metadata !174, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 %bytes_sent.3, metadata !171, metadata !DIExpression()), !dbg !218
  %exitcond = icmp eq i64 %indvars.iv.next, %wide.trip.count, !dbg !525
  br i1 %exitcond, label %while.cond221.outer, label %for.body230, !dbg !521, !llvm.loop !557

stop_timer:                                       ; preds = %if.then245
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476, metadata !171, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476, metadata !171, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476, metadata !171, metadata !DIExpression()), !dbg !218
  %conv249.le = trunc i64 %call248 to i32, !dbg !533
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476, metadata !171, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476, metadata !171, metadata !DIExpression()), !dbg !218
  call void @llvm.dbg.value(metadata i32 %bytes_sent.2476, metadata !171, metadata !DIExpression()), !dbg !218
  %88 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !559, !tbaa !85
  %call255 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %88, i8* getelementptr inbounds ([50 x i8], [50 x i8]* @.str.36, i64 0, i64 0), i32 %conv249.le, i8* nonnull %9) #14, !dbg !559
  call void @llvm.dbg.label(metadata !217), !dbg !561
  call void @llvm.dbg.value(metadata %struct.timeval* %t2, metadata !185, metadata !DIExpression(DW_OP_deref)), !dbg !218
  %call288 = call i32 @gettimeofday(%struct.timeval* nonnull %t2, %struct.timezone* null) #13, !dbg !562
  %89 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !563, !tbaa !85
  %90 = call i64 @fwrite(i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.38, i64 0, i64 0), i64 40, i64 1, %struct._IO_FILE* %89) #14, !dbg !563
  %call290 = call i32 @mtcp_close(%struct.mtcp_context* nonnull %call84, i32 %sockfd.0) #13, !dbg !564
  %91 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8, !dbg !565, !tbaa !85
  %92 = call i64 @fwrite(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.39, i64 0, i64 0), i64 23, i64 1, %struct._IO_FILE* %91) #14, !dbg !565
  %puts = call i32 @puts(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @str.44, i64 0, i64 0)), !dbg !566
  %tv_sec293 = getelementptr inbounds %struct.timeval, %struct.timeval* %t2, i64 0, i32 0, !dbg !567
  %93 = load i64, i64* %tv_sec293, align 8, !dbg !567, !tbaa !568
  %tv_sec294 = getelementptr inbounds %struct.timeval, %struct.timeval* %t1, i64 0, i32 0, !dbg !570
  %94 = load i64, i64* %tv_sec294, align 8, !dbg !570, !tbaa !568
  %sub = sub nsw i64 %93, %94, !dbg !571
  %conv295 = sitofp i64 %sub to double, !dbg !572
  call void @llvm.dbg.value(metadata double %conv295, metadata !175, metadata !DIExpression()), !dbg !218
  %tv_usec = getelementptr inbounds %struct.timeval, %struct.timeval* %t2, i64 0, i32 1, !dbg !573
  %95 = load i64, i64* %tv_usec, align 8, !dbg !573, !tbaa !574
  %tv_usec296 = getelementptr inbounds %struct.timeval, %struct.timeval* %t1, i64 0, i32 1, !dbg !575
  %96 = load i64, i64* %tv_usec296, align 8, !dbg !575, !tbaa !574
  %sub297 = sub nsw i64 %95, %96, !dbg !576
  %conv298 = sitofp i64 %sub297 to double, !dbg !577
  %div = fdiv double %conv298, 1.000000e+06, !dbg !578
  %add299 = fadd double %div, %conv295, !dbg !579
  call void @llvm.dbg.value(metadata double %add299, metadata !175, metadata !DIExpression()), !dbg !218
  %call300 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.41, i64 0, i64 0), double %add299), !dbg !580
  %call301 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.42, i64 0, i64 0), i32 %bytes_sent.2476), !dbg !581
  %conv302 = sitofp i32 %bytes_sent.2476 to double, !dbg !582
  %mul303 = fmul double %conv302, 8.000000e+00, !dbg !583
  %div304 = fdiv double %mul303, 1.000000e+06, !dbg !584
  %div305 = fdiv double %div304, %add299, !dbg !585
  %call306 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.43, i64 0, i64 0), double %div305), !dbg !586
  call void @mtcp_destroy_context(%struct.mtcp_context* %call84) #13, !dbg !587
  call void (...) @mtcp_destroy() #13, !dbg !588
  br label %cleanup308, !dbg !589

cleanup308:                                       ; preds = %if.end59, %if.then153, %if.then149, %stop_timer, %if.then200, %if.then124, %if.then118, %if.then111, %if.then88, %if.then70, %if.then27, %if.then4, %if.then
  %retval.0 = phi i32 [ -1, %if.then ], [ -1, %if.then4 ], [ -1, %if.then70 ], [ -1, %if.then118 ], [ -1, %if.then124 ], [ -1, %if.then200 ], [ 0, %stop_timer ], [ -1, %if.then111 ], [ -1, %if.then88 ], [ -1, %if.then27 ], [ -1, %if.end59 ], [ -1, %if.then149 ], [ -1, %if.then153 ]
  call void @llvm.lifetime.end.p0i8(i64 8192, i8* nonnull %9) #13, !dbg !590
  call void @llvm.lifetime.end.p0i8(i64 8192, i8* nonnull %8) #13, !dbg !590
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %7) #13, !dbg !590
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %6) #13, !dbg !590
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %5) #13, !dbg !590
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %4) #13, !dbg !590
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %3) #13, !dbg !590
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %2) #13, !dbg !590
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %1) #13, !dbg !590
  call void @llvm.lifetime.end.p0i8(i64 28, i8* nonnull %0) #13, !dbg !590
  ret i32 %retval.0, !dbg !590
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #7

; Function Attrs: nofree nounwind readonly
declare dso_local i32 @strncmp(i8* nocapture, i8* nocapture, i64) local_unnamed_addr #8

; Function Attrs: nounwind
declare dso_local i32 @inet_addr(i8*) local_unnamed_addr #9

; Function Attrs: nounwind readnone
declare i1 @llvm.is.constant.i16(i16) #10

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #7

declare dso_local i32 @mtcp_getconf(%struct.mtcp_conf*) local_unnamed_addr #2

declare dso_local i32 @mtcp_setconf(%struct.mtcp_conf*) local_unnamed_addr #2

; Function Attrs: nounwind
declare dso_local void @srand(i32) local_unnamed_addr #9

; Function Attrs: nounwind
declare dso_local i64 @time(i64*) local_unnamed_addr #9

declare dso_local i32 @mtcp_init(i8*) local_unnamed_addr #2

declare dso_local void (i32)* @mtcp_register_signal(i32, void (i32)*) local_unnamed_addr #2

declare dso_local i32 @mtcp_core_affinitize(i32) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare dso_local noalias i8* @calloc(i64, i64) local_unnamed_addr #1

; Function Attrs: nofree nounwind
declare dso_local void @perror(i8* nocapture readonly) local_unnamed_addr #1

declare dso_local %struct.mtcp_context* @mtcp_create_context(i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_init_rss(%struct.mtcp_context*, i32, i32, i32, i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_epoll_create(%struct.mtcp_context*, i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_socket(%struct.mtcp_context*, i32, i32, i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_setsock_nonblock(%struct.mtcp_context*, i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_epoll_ctl(%struct.mtcp_context*, i32, i32, i32, %struct.mtcp_epoll_event*) local_unnamed_addr #2

declare dso_local i32 @mtcp_bind(%struct.mtcp_context*, i32, %struct.sockaddr*, i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_listen(%struct.mtcp_context*, i32, i32) local_unnamed_addr #2

; Function Attrs: nounwind
declare dso_local i8* @strerror(i32) local_unnamed_addr #9

; Function Attrs: nounwind readnone
declare dso_local i32* @__errno_location() local_unnamed_addr #11

declare dso_local i32 @mtcp_epoll_wait(%struct.mtcp_context*, i32, %struct.mtcp_epoll_event*, i32, i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_accept(%struct.mtcp_context*, i32, %struct.sockaddr*, i32*) local_unnamed_addr #2

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.label(metadata) #3

declare dso_local i32 @mtcp_connect(%struct.mtcp_context*, i32, %struct.sockaddr*, i32) local_unnamed_addr #2

declare dso_local i32 @mtcp_close(%struct.mtcp_context*, i32) local_unnamed_addr #2

; Function Attrs: nounwind
declare dso_local i32 @clock_gettime(i32, %struct.timespec*) local_unnamed_addr #9

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #7

declare dso_local i64 @mtcp_write(%struct.mtcp_context*, i32, i8*, i64) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare dso_local i32 @gettimeofday(%struct.timeval* nocapture, %struct.timezone* nocapture) local_unnamed_addr #1

; Function Attrs: noreturn nounwind
declare dso_local void @__assert_fail(i8*, i8*, i32, i8*) local_unnamed_addr #5

declare dso_local i64 @mtcp_read(%struct.mtcp_context*, i32, i8*, i64) local_unnamed_addr #2

declare dso_local void @mtcp_destroy_context(%struct.mtcp_context*) local_unnamed_addr #2

declare dso_local void @mtcp_destroy(...) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare dso_local i64 @strtol(i8* readonly, i8** nocapture, i32) local_unnamed_addr #1

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.value(metadata, metadata, metadata) #3

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #12

; Function Attrs: nofree nounwind
declare i64 @fwrite(i8* nocapture, i64, i64, %struct._IO_FILE* nocapture) local_unnamed_addr #12

; Function Attrs: nounwind readnone speculatable
declare i16 @llvm.bswap.i16(i16) #3

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind readnone speculatable }
attributes #4 = { noreturn nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nofree nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { argmemonly nounwind }
attributes #8 = { nofree nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { nounwind readnone }
attributes #11 = { nounwind readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #12 = { nofree nounwind }
attributes #13 = { nounwind }
attributes #14 = { cold }
attributes #15 = { noreturn nounwind }
attributes #16 = { cold nounwind }
attributes #17 = { nounwind readonly }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!68, !69, !70}
!llvm.ident = !{!71}

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
!68 = !{i32 2, !"Dwarf Version", i32 4}
!69 = !{i32 2, !"Debug Info Version", i32 3}
!70 = !{i32 1, !"wchar_size", i32 4}
!71 = !{!"clang version 9.0.0 (https://github.com/bitslab/logicalclock.git b7571fe1ee88fc60fd4cf52c38f899c904bc1700)"}
!72 = distinct !DISubprogram(name: "init_stats", scope: !73, file: !73, line: 5, type: !74, scopeLine: 5, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !4)
!73 = !DIFile(filename: "TriggerAction.h", directory: "/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/mtcp-server/apps/perf")
!74 = !DISubroutineType(types: !75)
!75 = !{null}
!76 = !DILocation(line: 7, column: 5, scope: !72)
!77 = !DILocation(line: 8, column: 5, scope: !72)
!78 = !DILocation(line: 12, column: 3, scope: !72)
!79 = distinct !DISubprogram(name: "compiler_interrupt_handler", scope: !73, file: !73, line: 14, type: !65, scopeLine: 14, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !80)
!80 = !{!81}
!81 = !DILocalVariable(name: "ic", arg: 1, scope: !79, file: !73, line: 14, type: !67)
!82 = !DILocation(line: 0, scope: !79)
!83 = !DILocation(line: 15, column: 16, scope: !84)
!84 = distinct !DILexicalBlock(scope: !79, file: !73, line: 15, column: 8)
!85 = !{!86, !86, i64 0}
!86 = !{!"any pointer", !87, i64 0}
!87 = !{!"omnipotent char", !88, i64 0}
!88 = !{!"Simple C/C++ TBAA"}
!89 = !DILocation(line: 15, column: 26, scope: !84)
!90 = !{!91, !86, i64 8}
!91 = !{!"mtcp_context", !92, i64 0, !86, i64 8}
!92 = !{!"int", !87, i64 0}
!93 = !DILocation(line: 15, column: 8, scope: !84)
!94 = !DILocation(line: 15, column: 8, scope: !79)
!95 = !DILocation(line: 17, column: 7, scope: !96)
!96 = distinct !DILexicalBlock(scope: !84, file: !73, line: 15, column: 40)
!97 = !DILocation(line: 18, column: 5, scope: !96)
!98 = !DILocation(line: 20, column: 7, scope: !84)
!99 = !DILocation(line: 21, column: 3, scope: !79)
!100 = distinct !DISubprogram(name: "SignalHandler", scope: !10, file: !10, line: 73, type: !101, scopeLine: 74, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !103)
!101 = !DISubroutineType(types: !102)
!102 = !{null, !13}
!103 = !{!104}
!104 = !DILocalVariable(name: "signum", arg: 1, scope: !100, file: !10, line: 73, type: !13)
!105 = !DILocation(line: 0, scope: !100)
!106 = !DILocation(line: 75, column: 2, scope: !100)
!107 = !DILocation(line: 76, column: 2, scope: !100)
!108 = distinct !DISubprogram(name: "print_usage", scope: !10, file: !10, line: 80, type: !101, scopeLine: 81, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !109)
!109 = !{!110}
!110 = !DILocalVariable(name: "mode", arg: 1, scope: !108, file: !10, line: 80, type: !13)
!111 = !DILocation(line: 0, scope: !108)
!112 = !DILocation(line: 82, column: 24, scope: !113)
!113 = distinct !DILexicalBlock(scope: !108, file: !10, line: 82, column: 6)
!114 = !DILocation(line: 83, column: 3, scope: !115)
!115 = distinct !DILexicalBlock(scope: !113, file: !10, line: 82, column: 38)
!116 = !DILocation(line: 84, column: 2, scope: !115)
!117 = !DILocation(line: 85, column: 24, scope: !118)
!118 = distinct !DILexicalBlock(scope: !108, file: !10, line: 85, column: 6)
!119 = !DILocation(line: 86, column: 3, scope: !120)
!120 = distinct !DILexicalBlock(scope: !118, file: !10, line: 85, column: 38)
!121 = !DILocation(line: 87, column: 2, scope: !120)
!122 = !DILocation(line: 88, column: 1, scope: !108)
!123 = distinct !DISubprogram(name: "main", scope: !10, file: !10, line: 92, type: !124, scopeLine: 93, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !126)
!124 = !DISubroutineType(types: !125)
!125 = !{!13, !13, !57}
!126 = !{!127, !128, !129, !130, !131, !132, !133, !143, !144, !145, !146, !147, !148, !165, !166, !167, !168, !169, !170, !171, !172, !173, !174, !175, !177, !185, !186, !193, !194, !197, !201, !202, !203, !207, !208, !212, !213, !216, !217}
!127 = !DILocalVariable(name: "argc", arg: 1, scope: !123, file: !10, line: 92, type: !13)
!128 = !DILocalVariable(name: "argv", arg: 2, scope: !123, file: !10, line: 92, type: !57)
!129 = !DILocalVariable(name: "ret", scope: !123, file: !10, line: 95, type: !13)
!130 = !DILocalVariable(name: "i", scope: !123, file: !10, line: 95, type: !13)
!131 = !DILocalVariable(name: "c", scope: !123, file: !10, line: 95, type: !13)
!132 = !DILocalVariable(name: "mctx", scope: !123, file: !10, line: 98, type: !15)
!133 = !DILocalVariable(name: "mcfg", scope: !123, file: !10, line: 99, type: !134)
!134 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "mtcp_conf", file: !16, line: 30, size: 224, elements: !135)
!135 = !{!136, !137, !138, !139, !140, !141, !142}
!136 = !DIDerivedType(tag: DW_TAG_member, name: "num_cores", scope: !134, file: !16, line: 32, baseType: !13, size: 32)
!137 = !DIDerivedType(tag: DW_TAG_member, name: "max_concurrency", scope: !134, file: !16, line: 33, baseType: !13, size: 32, offset: 32)
!138 = !DIDerivedType(tag: DW_TAG_member, name: "max_num_buffers", scope: !134, file: !16, line: 35, baseType: !13, size: 32, offset: 64)
!139 = !DIDerivedType(tag: DW_TAG_member, name: "rcvbuf_size", scope: !134, file: !16, line: 36, baseType: !13, size: 32, offset: 96)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "sndbuf_size", scope: !134, file: !16, line: 37, baseType: !13, size: 32, offset: 128)
!141 = !DIDerivedType(tag: DW_TAG_member, name: "tcp_timewait", scope: !134, file: !16, line: 39, baseType: !13, size: 32, offset: 160)
!142 = !DIDerivedType(tag: DW_TAG_member, name: "tcp_timeout", scope: !134, file: !16, line: 40, baseType: !13, size: 32, offset: 192)
!143 = !DILocalVariable(name: "ctx", scope: !123, file: !10, line: 100, type: !8)
!144 = !DILocalVariable(name: "events", scope: !123, file: !10, line: 101, type: !29)
!145 = !DILocalVariable(name: "ev", scope: !123, file: !10, line: 102, type: !30)
!146 = !DILocalVariable(name: "core", scope: !123, file: !10, line: 103, type: !13)
!147 = !DILocalVariable(name: "ep_id", scope: !123, file: !10, line: 104, type: !13)
!148 = !DILocalVariable(name: "saddr", scope: !123, file: !10, line: 107, type: !149)
!149 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sockaddr_in", file: !23, line: 237, size: 128, elements: !150)
!150 = !{!151, !152, !156, !160}
!151 = !DIDerivedType(tag: DW_TAG_member, name: "sin_family", scope: !149, file: !23, line: 239, baseType: !50, size: 16)
!152 = !DIDerivedType(tag: DW_TAG_member, name: "sin_port", scope: !149, file: !23, line: 240, baseType: !153, size: 16, offset: 16)
!153 = !DIDerivedType(tag: DW_TAG_typedef, name: "in_port_t", file: !23, line: 119, baseType: !154)
!154 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !25, line: 25, baseType: !155)
!155 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint16_t", file: !27, line: 39, baseType: !7)
!156 = !DIDerivedType(tag: DW_TAG_member, name: "sin_addr", scope: !149, file: !23, line: 241, baseType: !157, size: 32, offset: 32)
!157 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in_addr", file: !23, line: 31, size: 32, elements: !158)
!158 = !{!159}
!159 = !DIDerivedType(tag: DW_TAG_member, name: "s_addr", scope: !157, file: !23, line: 33, baseType: !22, size: 32)
!160 = !DIDerivedType(tag: DW_TAG_member, name: "sin_zero", scope: !149, file: !23, line: 244, baseType: !161, size: 64, offset: 64)
!161 = !DICompositeType(tag: DW_TAG_array_type, baseType: !162, size: 64, elements: !163)
!162 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!163 = !{!164}
!164 = !DISubrange(count: 8)
!165 = !DILocalVariable(name: "daddr", scope: !123, file: !10, line: 107, type: !149)
!166 = !DILocalVariable(name: "sockfd", scope: !123, file: !10, line: 108, type: !13)
!167 = !DILocalVariable(name: "backlog", scope: !123, file: !10, line: 109, type: !13)
!168 = !DILocalVariable(name: "sec_to_send", scope: !123, file: !10, line: 112, type: !13)
!169 = !DILocalVariable(name: "wrote", scope: !123, file: !10, line: 113, type: !13)
!170 = !DILocalVariable(name: "read", scope: !123, file: !10, line: 114, type: !13)
!171 = !DILocalVariable(name: "bytes_sent", scope: !123, file: !10, line: 115, type: !13)
!172 = !DILocalVariable(name: "events_ready", scope: !123, file: !10, line: 116, type: !13)
!173 = !DILocalVariable(name: "nevents", scope: !123, file: !10, line: 117, type: !13)
!174 = !DILocalVariable(name: "sent_close", scope: !123, file: !10, line: 118, type: !13)
!175 = !DILocalVariable(name: "elapsed_time", scope: !123, file: !10, line: 121, type: !176)
!176 = !DIBasicType(name: "double", size: 64, encoding: DW_ATE_float)
!177 = !DILocalVariable(name: "t1", scope: !123, file: !10, line: 122, type: !178)
!178 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "timeval", file: !179, line: 8, size: 128, elements: !180)
!179 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/struct_timeval.h", directory: "")
!180 = !{!181, !183}
!181 = !DIDerivedType(tag: DW_TAG_member, name: "tv_sec", scope: !178, file: !179, line: 10, baseType: !182, size: 64)
!182 = !DIDerivedType(tag: DW_TAG_typedef, name: "__time_t", file: !27, line: 148, baseType: !67)
!183 = !DIDerivedType(tag: DW_TAG_member, name: "tv_usec", scope: !178, file: !179, line: 11, baseType: !184, size: 64, offset: 64)
!184 = !DIDerivedType(tag: DW_TAG_typedef, name: "__suseconds_t", file: !27, line: 150, baseType: !67)
!185 = !DILocalVariable(name: "t2", scope: !123, file: !10, line: 122, type: !178)
!186 = !DILocalVariable(name: "ts_start", scope: !123, file: !10, line: 123, type: !187)
!187 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "timespec", file: !188, line: 8, size: 128, elements: !189)
!188 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/struct_timespec.h", directory: "")
!189 = !{!190, !191}
!190 = !DIDerivedType(tag: DW_TAG_member, name: "tv_sec", scope: !187, file: !188, line: 10, baseType: !182, size: 64)
!191 = !DIDerivedType(tag: DW_TAG_member, name: "tv_nsec", scope: !187, file: !188, line: 11, baseType: !192, size: 64, offset: 64)
!192 = !DIDerivedType(tag: DW_TAG_typedef, name: "__syscall_slong_t", file: !27, line: 184, baseType: !67)
!193 = !DILocalVariable(name: "now", scope: !123, file: !10, line: 123, type: !187)
!194 = !DILocalVariable(name: "end_time", scope: !123, file: !10, line: 124, type: !195)
!195 = !DIDerivedType(tag: DW_TAG_typedef, name: "time_t", file: !196, line: 7, baseType: !182)
!196 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/time_t.h", directory: "")
!197 = !DILocalVariable(name: "buf", scope: !123, file: !10, line: 127, type: !198)
!198 = !DICompositeType(tag: DW_TAG_array_type, baseType: !54, size: 65536, elements: !199)
!199 = !{!200}
!200 = !DISubrange(count: 8192)
!201 = !DILocalVariable(name: "rcvbuf", scope: !123, file: !10, line: 128, type: !198)
!202 = !DILocalVariable(name: "mode", scope: !123, file: !10, line: 131, type: !13)
!203 = !DILocalVariable(name: "__v", scope: !204, file: !10, line: 150, type: !7)
!204 = distinct !DILexicalBlock(scope: !205, file: !10, line: 150, column: 20)
!205 = distinct !DILexicalBlock(scope: !206, file: !10, line: 138, column: 40)
!206 = distinct !DILexicalBlock(scope: !123, file: !10, line: 138, column: 6)
!207 = !DILocalVariable(name: "__x", scope: !204, file: !10, line: 150, type: !7)
!208 = !DILocalVariable(name: "__v", scope: !209, file: !10, line: 164, type: !7)
!209 = distinct !DILexicalBlock(scope: !210, file: !10, line: 164, column: 20)
!210 = distinct !DILexicalBlock(scope: !211, file: !10, line: 153, column: 47)
!211 = distinct !DILexicalBlock(scope: !206, file: !10, line: 153, column: 13)
!212 = !DILocalVariable(name: "__x", scope: !209, file: !10, line: 164, type: !7)
!213 = !DILocalVariable(name: "i", scope: !214, file: !10, line: 333, type: !13)
!214 = distinct !DILexicalBlock(scope: !215, file: !10, line: 333, column: 3)
!215 = distinct !DILexicalBlock(scope: !123, file: !10, line: 330, column: 12)
!216 = !DILabel(scope: !123, name: "end_wait_loop", file: !10, line: 293)
!217 = !DILabel(scope: !123, name: "stop_timer", file: !10, line: 361)
!218 = !DILocation(line: 0, scope: !123)
!219 = !DILocation(line: 7, column: 5, scope: !72, inlinedAt: !220)
!220 = distinct !DILocation(line: 94, column: 3, scope: !123)
!221 = !DILocation(line: 8, column: 5, scope: !72, inlinedAt: !220)
!222 = !DILocation(line: 99, column: 2, scope: !123)
!223 = !DILocation(line: 102, column: 2, scope: !123)
!224 = !DILocation(line: 107, column: 2, scope: !123)
!225 = !DILocation(line: 122, column: 2, scope: !123)
!226 = !DILocation(line: 123, column: 2, scope: !123)
!227 = !DILocation(line: 127, column: 2, scope: !123)
!228 = !DILocation(line: 127, column: 7, scope: !123)
!229 = !DILocation(line: 128, column: 2, scope: !123)
!230 = !DILocation(line: 128, column: 7, scope: !123)
!231 = !DILocation(line: 133, column: 11, scope: !232)
!232 = distinct !DILexicalBlock(scope: !123, file: !10, line: 133, column: 6)
!233 = !DILocation(line: 133, column: 6, scope: !123)
!234 = !DILocation(line: 0, scope: !108, inlinedAt: !235)
!235 = distinct !DILocation(line: 134, column: 3, scope: !236)
!236 = distinct !DILexicalBlock(scope: !232, file: !10, line: 133, column: 16)
!237 = !DILocation(line: 83, column: 3, scope: !115, inlinedAt: !235)
!238 = !DILocation(line: 86, column: 3, scope: !120, inlinedAt: !235)
!239 = !DILocation(line: 135, column: 3, scope: !236)
!240 = !DILocation(line: 138, column: 14, scope: !206)
!241 = !DILocation(line: 138, column: 6, scope: !206)
!242 = !DILocation(line: 138, column: 34, scope: !206)
!243 = !DILocation(line: 138, column: 6, scope: !123)
!244 = !DILocation(line: 139, column: 12, scope: !245)
!245 = distinct !DILexicalBlock(scope: !205, file: !10, line: 139, column: 7)
!246 = !DILocation(line: 0, scope: !205)
!247 = !DILocation(line: 139, column: 7, scope: !205)
!248 = !DILocation(line: 0, scope: !108, inlinedAt: !249)
!249 = distinct !DILocation(line: 140, column: 4, scope: !250)
!250 = distinct !DILexicalBlock(scope: !245, file: !10, line: 139, column: 17)
!251 = !DILocation(line: 83, column: 3, scope: !115, inlinedAt: !249)
!252 = !DILocation(line: 141, column: 4, scope: !250)
!253 = !DILocation(line: 145, column: 3, scope: !205)
!254 = !DILocation(line: 148, column: 9, scope: !205)
!255 = !DILocation(line: 148, column: 20, scope: !205)
!256 = !{!257, !258, i64 0}
!257 = !{!"sockaddr_in", !258, i64 0, !258, i64 2, !259, i64 4, !87, i64 8}
!258 = !{!"short", !87, i64 0}
!259 = !{!"in_addr", !92, i64 0}
!260 = !DILocation(line: 149, column: 37, scope: !205)
!261 = !DILocation(line: 149, column: 27, scope: !205)
!262 = !DILocation(line: 149, column: 18, scope: !205)
!263 = !DILocation(line: 149, column: 25, scope: !205)
!264 = !{!257, !92, i64 4}
!265 = !DILocation(line: 150, column: 20, scope: !204)
!266 = !DILocalVariable(name: "__nptr", arg: 1, scope: !267, file: !268, line: 361, type: !271)
!267 = distinct !DISubprogram(name: "atoi", scope: !268, file: !268, line: 361, type: !269, scopeLine: 362, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !273)
!268 = !DIFile(filename: "/usr/include/stdlib.h", directory: "")
!269 = !DISubroutineType(types: !270)
!270 = !{!13, !271}
!271 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !272, size: 64)
!272 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !54)
!273 = !{!266}
!274 = !DILocation(line: 0, scope: !267, inlinedAt: !275)
!275 = distinct !DILocation(line: 150, column: 20, scope: !204)
!276 = !DILocation(line: 363, column: 16, scope: !267, inlinedAt: !275)
!277 = !DILocation(line: 0, scope: !204)
!278 = !DILocation(line: 150, column: 20, scope: !279)
!279 = distinct !DILexicalBlock(scope: !204, file: !10, line: 150, column: 20)
!280 = !{i32 -2146122450}
!281 = !DILocation(line: 153, column: 13, scope: !211)
!282 = !DILocation(line: 153, column: 41, scope: !211)
!283 = !DILocation(line: 153, column: 13, scope: !206)
!284 = !DILocation(line: 154, column: 12, scope: !285)
!285 = distinct !DILexicalBlock(scope: !210, file: !10, line: 154, column: 7)
!286 = !DILocation(line: 0, scope: !210)
!287 = !DILocation(line: 154, column: 7, scope: !210)
!288 = !DILocation(line: 0, scope: !108, inlinedAt: !289)
!289 = distinct !DILocation(line: 155, column: 4, scope: !290)
!290 = distinct !DILexicalBlock(scope: !285, file: !10, line: 154, column: 17)
!291 = !DILocation(line: 86, column: 3, scope: !120, inlinedAt: !289)
!292 = !DILocation(line: 156, column: 4, scope: !290)
!293 = !DILocation(line: 160, column: 3, scope: !210)
!294 = !DILocation(line: 162, column: 9, scope: !210)
!295 = !DILocation(line: 162, column: 20, scope: !210)
!296 = !DILocation(line: 163, column: 37, scope: !210)
!297 = !DILocation(line: 163, column: 27, scope: !210)
!298 = !DILocation(line: 163, column: 18, scope: !210)
!299 = !DILocation(line: 163, column: 25, scope: !210)
!300 = !DILocation(line: 164, column: 20, scope: !209)
!301 = !DILocation(line: 0, scope: !267, inlinedAt: !302)
!302 = distinct !DILocation(line: 164, column: 20, scope: !209)
!303 = !DILocation(line: 363, column: 16, scope: !267, inlinedAt: !302)
!304 = !DILocation(line: 0, scope: !209)
!305 = !DILocation(line: 164, column: 20, scope: !306)
!306 = distinct !DILexicalBlock(scope: !209, file: !10, line: 164, column: 20)
!307 = !{i32 -2146121895}
!308 = !DILocation(line: 168, column: 3, scope: !309)
!309 = distinct !DILexicalBlock(scope: !211, file: !10, line: 167, column: 9)
!310 = !DILocation(line: 0, scope: !108, inlinedAt: !311)
!311 = distinct !DILocation(line: 169, column: 3, scope: !309)
!312 = !DILocation(line: 83, column: 3, scope: !115, inlinedAt: !311)
!313 = !DILocation(line: 86, column: 3, scope: !120, inlinedAt: !311)
!314 = !DILocation(line: 172, column: 6, scope: !123)
!315 = !DILocation(line: 0, scope: !206)
!316 = !{!257, !258, i64 2}
!317 = !DILocation(line: 178, column: 2, scope: !123)
!318 = !DILocation(line: 179, column: 7, scope: !123)
!319 = !DILocation(line: 179, column: 17, scope: !123)
!320 = !{!321, !92, i64 0}
!321 = !{!"mtcp_conf", !92, i64 0, !92, i64 4, !92, i64 8, !92, i64 12, !92, i64 16, !92, i64 20, !92, i64 24}
!322 = !DILocation(line: 180, column: 2, scope: !123)
!323 = !DILocation(line: 182, column: 8, scope: !123)
!324 = !DILocation(line: 182, column: 2, scope: !123)
!325 = !DILocation(line: 185, column: 2, scope: !123)
!326 = !DILocation(line: 186, column: 6, scope: !327)
!327 = distinct !DILexicalBlock(scope: !123, file: !10, line: 186, column: 6)
!328 = !DILocation(line: 186, column: 6, scope: !123)
!329 = !DILocation(line: 187, column: 3, scope: !330)
!330 = distinct !DILexicalBlock(scope: !327, file: !10, line: 186, column: 32)
!331 = !DILocation(line: 188, column: 3, scope: !330)
!332 = !DILocation(line: 192, column: 2, scope: !123)
!333 = !DILocation(line: 193, column: 7, scope: !123)
!334 = !DILocation(line: 193, column: 23, scope: !123)
!335 = !{!321, !92, i64 4}
!336 = !DILocation(line: 194, column: 7, scope: !123)
!337 = !DILocation(line: 194, column: 23, scope: !123)
!338 = !{!321, !92, i64 8}
!339 = !DILocation(line: 195, column: 2, scope: !123)
!340 = !DILocation(line: 198, column: 2, scope: !123)
!341 = !DILocation(line: 200, column: 2, scope: !123)
!342 = !DILocation(line: 201, column: 2, scope: !123)
!343 = !DILocation(line: 209, column: 14, scope: !123)
!344 = !DILocation(line: 210, column: 7, scope: !345)
!345 = distinct !DILexicalBlock(scope: !123, file: !10, line: 210, column: 6)
!346 = !DILocation(line: 210, column: 6, scope: !123)
!347 = !DILocation(line: 211, column: 3, scope: !348)
!348 = distinct !DILexicalBlock(scope: !345, file: !10, line: 210, column: 18)
!349 = !DILocation(line: 212, column: 3, scope: !348)
!350 = !DILocation(line: 215, column: 12, scope: !123)
!351 = !DILocation(line: 217, column: 11, scope: !352)
!352 = distinct !DILexicalBlock(scope: !123, file: !10, line: 217, column: 6)
!353 = !DILocation(line: 217, column: 6, scope: !123)
!354 = !DILocation(line: 219, column: 3, scope: !355)
!355 = distinct !DILexicalBlock(scope: !352, file: !10, line: 217, column: 25)
!356 = !DILocation(line: 220, column: 60, scope: !355)
!357 = !DILocation(line: 220, column: 74, scope: !355)
!358 = !DILocation(line: 220, column: 68, scope: !355)
!359 = !DILocation(line: 220, column: 3, scope: !355)
!360 = !DILocation(line: 221, column: 2, scope: !355)
!361 = !DILocation(line: 223, column: 2, scope: !123)
!362 = !DILocation(line: 224, column: 44, scope: !123)
!363 = !DILocation(line: 224, column: 10, scope: !123)
!364 = !DILocation(line: 225, column: 51, scope: !123)
!365 = !DILocation(line: 225, column: 46, scope: !123)
!366 = !DILocation(line: 225, column: 39, scope: !123)
!367 = !DILocation(line: 225, column: 11, scope: !123)
!368 = !DILocation(line: 226, column: 7, scope: !369)
!369 = distinct !DILexicalBlock(scope: !123, file: !10, line: 226, column: 6)
!370 = !DILocation(line: 226, column: 6, scope: !123)
!371 = !DILocation(line: 227, column: 3, scope: !372)
!372 = distinct !DILexicalBlock(scope: !369, file: !10, line: 226, column: 15)
!373 = !DILocation(line: 228, column: 3, scope: !372)
!374 = !DILocation(line: 232, column: 2, scope: !123)
!375 = !DILocation(line: 233, column: 11, scope: !123)
!376 = !DILocation(line: 234, column: 13, scope: !377)
!377 = distinct !DILexicalBlock(scope: !123, file: !10, line: 234, column: 6)
!378 = !DILocation(line: 234, column: 6, scope: !123)
!379 = !DILocation(line: 235, column: 3, scope: !380)
!380 = distinct !DILexicalBlock(scope: !377, file: !10, line: 234, column: 18)
!381 = !DILocation(line: 236, column: 3, scope: !380)
!382 = !DILocation(line: 239, column: 8, scope: !123)
!383 = !DILocation(line: 240, column: 10, scope: !384)
!384 = distinct !DILexicalBlock(scope: !123, file: !10, line: 240, column: 6)
!385 = !DILocation(line: 240, column: 6, scope: !123)
!386 = !DILocation(line: 241, column: 3, scope: !387)
!387 = distinct !DILexicalBlock(scope: !384, file: !10, line: 240, column: 15)
!388 = !DILocation(line: 242, column: 3, scope: !387)
!389 = !DILocation(line: 245, column: 5, scope: !123)
!390 = !DILocation(line: 245, column: 12, scope: !123)
!391 = !{!392, !92, i64 0}
!392 = !{!"mtcp_epoll_event", !92, i64 0, !87, i64 8}
!393 = !DILocation(line: 246, column: 5, scope: !123)
!394 = !DILocation(line: 246, column: 10, scope: !123)
!395 = !DILocation(line: 246, column: 17, scope: !123)
!396 = !{!87, !87, i64 0}
!397 = !DILocation(line: 247, column: 2, scope: !123)
!398 = !DILocation(line: 249, column: 11, scope: !399)
!399 = distinct !DILexicalBlock(scope: !123, file: !10, line: 249, column: 6)
!400 = !DILocation(line: 249, column: 6, scope: !123)
!401 = !DILocation(line: 250, column: 33, scope: !402)
!402 = distinct !DILexicalBlock(scope: !399, file: !10, line: 249, column: 25)
!403 = !DILocation(line: 250, column: 9, scope: !402)
!404 = !DILocation(line: 251, column: 11, scope: !405)
!405 = distinct !DILexicalBlock(scope: !402, file: !10, line: 251, column: 7)
!406 = !DILocation(line: 251, column: 7, scope: !402)
!407 = !DILocation(line: 252, column: 4, scope: !408)
!408 = distinct !DILexicalBlock(scope: !405, file: !10, line: 251, column: 16)
!409 = !DILocation(line: 253, column: 3, scope: !408)
!410 = !DILocation(line: 255, column: 9, scope: !402)
!411 = !DILocation(line: 256, column: 11, scope: !412)
!412 = distinct !DILexicalBlock(scope: !402, file: !10, line: 256, column: 7)
!413 = !DILocation(line: 256, column: 7, scope: !402)
!414 = !DILocation(line: 257, column: 4, scope: !415)
!415 = distinct !DILexicalBlock(scope: !412, file: !10, line: 256, column: 16)
!416 = !{!92, !92, i64 0}
!417 = !DILocation(line: 258, column: 3, scope: !415)
!418 = !DILocation(line: 262, column: 14, scope: !419)
!419 = distinct !DILexicalBlock(scope: !402, file: !10, line: 260, column: 13)
!420 = !DILocation(line: 263, column: 16, scope: !421)
!421 = distinct !DILexicalBlock(scope: !419, file: !10, line: 263, column: 8)
!422 = !DILocation(line: 263, column: 8, scope: !419)
!423 = !DILocation(line: 270, column: 18, scope: !424)
!424 = distinct !DILexicalBlock(scope: !425, file: !10, line: 270, column: 4)
!425 = distinct !DILexicalBlock(scope: !419, file: !10, line: 270, column: 4)
!426 = !DILocation(line: 270, column: 4, scope: !425)
!427 = distinct !{!427, !428, !429}
!428 = !DILocation(line: 260, column: 3, scope: !402)
!429 = !DILocation(line: 291, column: 3, scope: !402)
!430 = !DILocation(line: 264, column: 9, scope: !431)
!431 = distinct !DILexicalBlock(scope: !432, file: !10, line: 264, column: 9)
!432 = distinct !DILexicalBlock(scope: !421, file: !10, line: 263, column: 21)
!433 = !DILocation(line: 264, column: 15, scope: !431)
!434 = !DILocation(line: 264, column: 9, scope: !432)
!435 = !DILocation(line: 265, column: 6, scope: !436)
!436 = distinct !DILexicalBlock(scope: !431, file: !10, line: 264, column: 25)
!437 = !DILocation(line: 266, column: 5, scope: !436)
!438 = !DILocation(line: 271, column: 19, scope: !439)
!439 = distinct !DILexicalBlock(scope: !440, file: !10, line: 271, column: 9)
!440 = distinct !DILexicalBlock(scope: !424, file: !10, line: 270, column: 34)
!441 = !DILocation(line: 271, column: 24, scope: !439)
!442 = !DILocation(line: 271, column: 31, scope: !439)
!443 = !DILocation(line: 271, column: 9, scope: !440)
!444 = !DILocation(line: 272, column: 10, scope: !445)
!445 = distinct !DILexicalBlock(scope: !439, file: !10, line: 271, column: 42)
!446 = !DILocation(line: 273, column: 12, scope: !447)
!447 = distinct !DILexicalBlock(scope: !445, file: !10, line: 273, column: 10)
!448 = !DILocation(line: 273, column: 10, scope: !445)
!449 = !DILocation(line: 274, column: 13, scope: !450)
!450 = distinct !DILexicalBlock(scope: !451, file: !10, line: 274, column: 11)
!451 = distinct !DILexicalBlock(scope: !447, file: !10, line: 273, column: 18)
!452 = !DILocation(line: 274, column: 11, scope: !451)
!453 = !DILocation(line: 275, column: 8, scope: !454)
!454 = distinct !DILexicalBlock(scope: !450, file: !10, line: 274, column: 30)
!455 = !DILocation(line: 276, column: 7, scope: !454)
!456 = !DILocation(line: 277, column: 7, scope: !451)
!457 = !DILocation(line: 278, column: 6, scope: !451)
!458 = !DILocation(line: 279, column: 7, scope: !459)
!459 = distinct !DILexicalBlock(scope: !447, file: !10, line: 278, column: 13)
!460 = !DILocation(line: 281, column: 6, scope: !445)
!461 = !DILocation(line: 283, column: 16, scope: !445)
!462 = !DILocation(line: 284, column: 21, scope: !445)
!463 = !DILocation(line: 285, column: 6, scope: !445)
!464 = !DILocation(line: 286, column: 6, scope: !445)
!465 = !DILocation(line: 288, column: 6, scope: !466)
!466 = distinct !DILexicalBlock(scope: !439, file: !10, line: 287, column: 12)
!467 = !DILocation(line: 270, column: 30, scope: !424)
!468 = distinct !{!468, !426, !469}
!469 = !DILocation(line: 290, column: 4, scope: !425)
!470 = !DILocation(line: 293, column: 1, scope: !123)
!471 = !DILocation(line: 296, column: 6, scope: !123)
!472 = !DILocation(line: 297, column: 3, scope: !473)
!473 = distinct !DILexicalBlock(scope: !474, file: !10, line: 296, column: 25)
!474 = distinct !DILexicalBlock(scope: !123, file: !10, line: 296, column: 6)
!475 = !DILocation(line: 298, column: 36, scope: !473)
!476 = !DILocation(line: 298, column: 9, scope: !473)
!477 = !DILocation(line: 299, column: 11, scope: !478)
!478 = distinct !DILexicalBlock(scope: !473, file: !10, line: 299, column: 7)
!479 = !DILocation(line: 299, column: 7, scope: !473)
!480 = !DILocation(line: 300, column: 4, scope: !481)
!481 = distinct !DILexicalBlock(scope: !478, file: !10, line: 299, column: 16)
!482 = !DILocation(line: 301, column: 8, scope: !483)
!483 = distinct !DILexicalBlock(scope: !481, file: !10, line: 301, column: 8)
!484 = !DILocation(line: 301, column: 14, scope: !483)
!485 = !DILocation(line: 301, column: 8, scope: !481)
!486 = !DILocation(line: 302, column: 5, scope: !487)
!487 = distinct !DILexicalBlock(scope: !483, file: !10, line: 301, column: 30)
!488 = !DILocation(line: 303, column: 5, scope: !487)
!489 = !DILocation(line: 304, column: 5, scope: !487)
!490 = !DILocation(line: 307, column: 3, scope: !473)
!491 = !DILocation(line: 308, column: 2, scope: !473)
!492 = !DILocation(line: 310, column: 2, scope: !123)
!493 = !DILocation(line: 311, column: 22, scope: !123)
!494 = !{!495, !496, i64 0}
!495 = !{!"timespec", !496, i64 0, !496, i64 8}
!496 = !{!"long", !87, i64 0}
!497 = !DILocation(line: 311, column: 31, scope: !123)
!498 = !DILocation(line: 313, column: 2, scope: !123)
!499 = !DILocation(line: 314, column: 2, scope: !123)
!500 = !DILocation(line: 314, column: 17, scope: !123)
!501 = !DILocation(line: 316, column: 2, scope: !123)
!502 = !DILocation(line: 317, column: 11, scope: !503)
!503 = distinct !DILexicalBlock(scope: !123, file: !10, line: 316, column: 12)
!504 = !DILocation(line: 318, column: 14, scope: !503)
!505 = !DILocation(line: 319, column: 13, scope: !506)
!506 = distinct !DILexicalBlock(scope: !503, file: !10, line: 319, column: 7)
!507 = !DILocation(line: 319, column: 7, scope: !503)
!508 = distinct !{!508, !501, !509}
!509 = !DILocation(line: 323, column: 2, scope: !123)
!510 = !DILocation(line: 311, column: 29, scope: !123)
!511 = !DILocation(line: 320, column: 4, scope: !512)
!512 = distinct !DILexicalBlock(scope: !506, file: !10, line: 319, column: 18)
!513 = !DILocation(line: 0, scope: !514)
!514 = distinct !DILexicalBlock(scope: !515, file: !10, line: 346, column: 9)
!515 = distinct !DILexicalBlock(scope: !516, file: !10, line: 343, column: 50)
!516 = distinct !DILexicalBlock(scope: !517, file: !10, line: 343, column: 15)
!517 = distinct !DILexicalBlock(scope: !518, file: !10, line: 335, column: 8)
!518 = distinct !DILexicalBlock(scope: !519, file: !10, line: 333, column: 42)
!519 = distinct !DILexicalBlock(scope: !214, file: !10, line: 333, column: 3)
!520 = !DILocation(line: 330, column: 2, scope: !123)
!521 = !DILocation(line: 333, column: 3, scope: !214)
!522 = !DILocation(line: 332, column: 65, scope: !215)
!523 = !DILocation(line: 332, column: 18, scope: !215)
!524 = !DILocation(line: 0, scope: !214)
!525 = !DILocation(line: 333, column: 21, scope: !519)
!526 = !DILocation(line: 334, column: 4, scope: !527)
!527 = distinct !DILexicalBlock(scope: !528, file: !10, line: 334, column: 4)
!528 = distinct !DILexicalBlock(scope: !518, file: !10, line: 334, column: 4)
!529 = !DILocation(line: 334, column: 4, scope: !528)
!530 = !DILocation(line: 335, column: 18, scope: !517)
!531 = !DILocation(line: 335, column: 25, scope: !517)
!532 = !DILocation(line: 335, column: 8, scope: !518)
!533 = !DILocation(line: 336, column: 12, scope: !534)
!534 = distinct !DILexicalBlock(scope: !517, file: !10, line: 335, column: 41)
!535 = !DILocation(line: 337, column: 14, scope: !536)
!536 = distinct !DILexicalBlock(scope: !534, file: !10, line: 337, column: 9)
!537 = !DILocation(line: 337, column: 9, scope: !534)
!538 = !DILocation(line: 343, column: 32, scope: !516)
!539 = !DILocation(line: 343, column: 15, scope: !517)
!540 = !DILocation(line: 345, column: 5, scope: !515)
!541 = !DILocation(line: 346, column: 13, scope: !514)
!542 = !DILocation(line: 346, column: 20, scope: !514)
!543 = !DILocation(line: 346, column: 9, scope: !515)
!544 = !DILocation(line: 347, column: 14, scope: !545)
!545 = distinct !DILexicalBlock(scope: !514, file: !10, line: 346, column: 32)
!546 = !DILocation(line: 348, column: 17, scope: !545)
!547 = !DILocation(line: 350, column: 5, scope: !545)
!548 = !DILocation(line: 350, column: 17, scope: !549)
!549 = distinct !DILexicalBlock(scope: !514, file: !10, line: 350, column: 16)
!550 = !DILocation(line: 350, column: 16, scope: !514)
!551 = !DILocation(line: 351, column: 6, scope: !552)
!552 = distinct !DILexicalBlock(scope: !549, file: !10, line: 350, column: 29)
!553 = !DILocation(line: 352, column: 6, scope: !552)
!554 = !DILocation(line: 353, column: 6, scope: !552)
!555 = !DILocation(line: 355, column: 5, scope: !552)
!556 = !DILocation(line: 333, column: 38, scope: !519)
!557 = distinct !{!557, !521, !558}
!558 = !DILocation(line: 357, column: 3, scope: !214)
!559 = !DILocation(line: 340, column: 6, scope: !560)
!560 = distinct !DILexicalBlock(scope: !536, file: !10, line: 339, column: 12)
!561 = !DILocation(line: 361, column: 1, scope: !123)
!562 = !DILocation(line: 362, column: 2, scope: !123)
!563 = !DILocation(line: 364, column: 2, scope: !123)
!564 = !DILocation(line: 365, column: 2, scope: !123)
!565 = !DILocation(line: 366, column: 2, scope: !123)
!566 = !DILocation(line: 368, column: 2, scope: !123)
!567 = !DILocation(line: 369, column: 21, scope: !123)
!568 = !{!569, !496, i64 0}
!569 = !{!"timeval", !496, i64 0, !496, i64 8}
!570 = !DILocation(line: 369, column: 33, scope: !123)
!571 = !DILocation(line: 369, column: 28, scope: !123)
!572 = !DILocation(line: 369, column: 17, scope: !123)
!573 = !DILocation(line: 370, column: 22, scope: !123)
!574 = !{!569, !496, i64 8}
!575 = !DILocation(line: 370, column: 35, scope: !123)
!576 = !DILocation(line: 370, column: 30, scope: !123)
!577 = !DILocation(line: 370, column: 18, scope: !123)
!578 = !DILocation(line: 370, column: 44, scope: !123)
!579 = !DILocation(line: 370, column: 15, scope: !123)
!580 = !DILocation(line: 371, column: 2, scope: !123)
!581 = !DILocation(line: 372, column: 2, scope: !123)
!582 = !DILocation(line: 373, column: 41, scope: !123)
!583 = !DILocation(line: 373, column: 52, scope: !123)
!584 = !DILocation(line: 373, column: 58, scope: !123)
!585 = !DILocation(line: 373, column: 71, scope: !123)
!586 = !DILocation(line: 373, column: 2, scope: !123)
!587 = !DILocation(line: 375, column: 2, scope: !123)
!588 = !DILocation(line: 377, column: 2, scope: !123)
!589 = !DILocation(line: 379, column: 2, scope: !123)
!590 = !DILocation(line: 380, column: 1, scope: !123)
