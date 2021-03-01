#!/bin/bash

compile_lc() {
  program=$1
  LOG_FILE=${program}_acc_log.txt
  ERROR_LOG_FILE=${program}_acc_err.txt
  AD=100
  CLOCK=1
  PI=5000
  CI=1000
  LEVEL=1
  CONFIG=2

  rm -f lib/libphoenix.a ./tests/kmeans/${program} ./tests/$program/${program}-seq ./tests/$program/${program}-pthread
  rm -f $LOG_FILE $ERROR_LOG_FILE

  echo "cleaning..."
  CONFIG=$CONFIG make clean -C ./src -f Makefile.lc > $LOG_FILE 2>>$ERROR_LOG_FILE
  CONFIG=$CONFIG make -C ./tests -f Makefile.lc ${program}-clean >>$LOG_FILE 2>>$ERROR_LOG_FILE 

  echo "compiling..."
  #ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./src -f Makefile.lc >>$LOG_FILE 2>>$ERROR_LOG_FILE 
  #ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./tests -f Makefile.lc $program >>$LOG_FILE 2>>$ERROR_LOG_FILE 
  echo "CONFIG=$CONFIG ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./src -f Makefile.lc"
  CONFIG=$CONFIG ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./src -f Makefile.lc 
  CONFIG=$CONFIG ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./tests -f Makefile.lc $program

#EXTRA_FLAGS="-DAVG_STATS -DPERF_CNTR" CONFIG=$CONFIG ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./src -f Makefile.lc 
#EXTRA_FLAGS="-DAVG_STATS -DPERF_CNTR" CONFIG=$CONFIG ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./tests -f Makefile.lc $program

#EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" CONFIG=$CONFIG ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./src -f Makefile.lc 
#EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" CONFIG=$CONFIG ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./tests -f Makefile.lc $program
}

compile_lc_fiber() {
  program=$1
  LOG_FILE=${program}_acc_log.txt
  ERROR_LOG_FILE=${program}_acc_err.txt
  AD=100
  CLOCK=1
  PI=5000
  CI=1000
  LEVEL=1
  CONFIG=2
  DIR=`pwd`
  LIBFIBER_DIR=$DIR"/../../libfiber/"
  LIBFIBER_INCL_DIR=$LIBFIBER_DIR"/include"

  rm -f lib/libphoenix.a ./tests/kmeans/${program} ./tests/$program/${program}-seq ./tests/$program/${program}-pthread
  rm -f $LOG_FILE $ERROR_LOG_FILE

  echo "cleaning..."
  CONFIG=$CONFIG make clean -C ./src -f Makefile.lc.fiber > $LOG_FILE 2>>$ERROR_LOG_FILE
  CONFIG=$CONFIG make -C ./tests -f Makefile.lc ${program}-clean >>$LOG_FILE 2>>$ERROR_LOG_FILE 

  echo "compiling..."
  #ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./src -f Makefile.lc >>$LOG_FILE 2>>$ERROR_LOG_FILE 
  #ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./tests -f Makefile.lc $program >>$LOG_FILE 2>>$ERROR_LOG_FILE 
  echo "CONFIG=$CONFIG ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./src -f Makefile.lc.fiber"
  CONFIG=$CONFIG ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./src -f Makefile.lc.fiber 
  EXTRA_FLAGS="-DLIBFIBER  -I$LIBFIBER_INCL_DIR -L$LIBFIBER_DIR -Wl,-rpath,$LIBFIBER_DIR -lfiber" CONFIG=$CONFIG ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEVEL make -C ./tests -f Makefile.lc $program
}

compile_orig() {
  program=$1
  LOG_FILE=${program}_acc_log.txt
  ERROR_LOG_FILE=${program}_acc_err.txt
#EXTRA_FLAGS="EXTRA_FLAGS=\"-DPAPI -DIC_THRESHOLD=5000\""

  make clean -C src -f Makefile.orig > $LOG_FILE 2>>$ERROR_LOG_FILE
  make -C tests -f Makefile.orig $program-clean >> $LOG_FILE 2>>$ERROR_LOG_FILE

#EXTRA_FLAGS="-DPAPI -DIC_THRESHOLD=5000" make -C src -f Makefile.orig
#EXTRA_FLAGS="-DPAPI -DIC_THRESHOLD=5000" make -C tests -f Makefile.orig $program

  make -C src -f Makefile.orig
  make -C tests -f Makefile.orig $program

#make -C src -f Makefile.orig > $LOG_FILE 2>>$ERROR_LOG_FILE
#make -C tests -f Makefile.orig $program >> $LOG_FILE 2>>$ERROR_LOG_FILE
}

compile_orig_fiber() {
  program=$1
  LOG_FILE=${program}_acc_log.txt
  ERROR_LOG_FILE=${program}_acc_err.txt
  DIR=`pwd`
  LIBFIBER_DIR=$DIR"/../../libfiber/"
  LIBFIBER_INCL_DIR=$LIBFIBER_DIR"/include"

  make clean -C src -f Makefile.orig.fiber
  make -C tests -f Makefile.orig $program-clean

  make -C src -f Makefile.orig.fiber
  echo "EXTRA_FLAGS=\"-DLIBFIBER  -I$LIBFIBER_INCL_DIR -L$LIBFIBER_DIR -Wl,-rpath,$LIBFIBER_DIR -lfiber\" make -C tests -f Makefile.orig $program"
  EXTRA_FLAGS="-DLIBFIBER  -I$LIBFIBER_INCL_DIR -L$LIBFIBER_DIR -Wl,-rpath,$LIBFIBER_DIR -lfiber" make -C tests -f Makefile.orig $program
#make -C src -f Makefile.orig > $LOG_FILE 2>>$ERROR_LOG_FILE
#make -C tests -f Makefile.orig $program >> $LOG_FILE 2>>$ERROR_LOG_FILE
}

run() {
  THREADS=1
  echo "running $1..."
  program=$1
  case "$1" in
    histogram)
      echo "MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp > out"
      MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp > out
      ;;
    kmeans)
      echo "MR_NUMTHREADS=$THREADS ./tests/$program/$program -d 100 -c 10 -p 500000 -s 50"
      MR_NUMTHREADS=$THREADS ./tests/$program/$program -d 100 -c 10 -p 500000 -s 50
      ;;
    pca)
      echo "MR_NUMTHREADS=$THREADS ./tests/$program/$program -r 1000 -c 1000 -s 1000"
      MR_NUMTHREADS=$THREADS ./tests/$program/$program -r 1000 -c 1000 -s 1000
      ;;
    matrix_multiply) 
      echo "MR_NUMTHREADS=$THREADS ./tests/$program/$program 900 600 1"
      MR_NUMTHREADS=$THREADS ./tests/$program/$program 900 600 1
      ;;
    string_match) 
      echo "MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_100MB.txt"
      MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_100MB.txt
      ;;
    linear_regression) 
      echo "MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_500MB.txt"
      MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_500MB.txt
      ;;
    word_count)
      echo "MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/word_50MB.txt"
      MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/word_50MB.txt
      ;;
  esac
}

#compile_orig matrix_multiply
#compile matrix_multiply

#compile kmeans
#compile pca
#compile matrix_multiply
#compile_orig histogram
#compile histogram
#compile linear_regression
#compile string_match
#compile word_count


compile_all() {
  for bench in $*
  do

    compile_lc $bench
    echo "COMPILED LC $bench"
    sleep 2
#run $bench
    echo "Ran $bench"
    sleep 5

    compile_orig $bench
    echo "COMPILED ORIG $bench"
    sleep 2
#run $bench
    echo "Ran $bench"
    sleep 5

    if [ 1 -eq 1 ]; then
      compile_lc_fiber $bench
      echo "COMPILED LC FIBER $bench"
      sleep 2
      run $bench
      echo "Ran $bench"
      sleep 2

      compile_orig_fiber $bench
      echo "COMPILED ORIG FIBER $bench"
      sleep 2
      run $bench
      echo "Ran $bench"
      sleep 2
    fi

  done
}

#compile_orig histogram
#compile_lc histogram
compile_orig_fiber histogram
#compile_lc_fiber histogram
#compile_all histogram #kmeans pca matrix_multiply string_match linear_regression word_count
sleep 2
run histogram 

exit
sleep 5
run kmeans 
sleep 5
run pca 
sleep 5
run matrix_multiply 
sleep 5
run string_match 
sleep 5
run linear_regression 
sleep 5
run word_count
sleep 5

exit
compile_all histogram

#run
compile_lc_fiber histogram #kmeans pca matrix_multiply string_match linear_regression word_count

#2.8s
run histogram 
sleep 2
run word_count
#2.6s
run kmeans 
sleep 2
#1.3s
run pca 
sleep 2
#2.2s
run matrix_multiply 
sleep 2
#0.9s
run string_match 
sleep 2
#4.7s
run linear_regression 
sleep 2
#3.5s
run word_count
