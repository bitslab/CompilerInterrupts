#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

build_all() {
  make clean; make
}

test_demo() {
  ./ci_demo > tmp

  line_cnt=`grep "CI @ inc0" tmp | wc -l`
  if [ $line_cnt -lt 100 ]; then
    printf "${RED}Not the expected behavior. CI is enabled for increment threads.${NC}\n"
    exit
  fi

  line_cnt=`grep "CI @ dec0" tmp | wc -l`
  if [ $line_cnt -gt 1 ]; then
    printf "${RED}Not the expected behavior. CI is disabled for decrement threads.${NC}\n"
    exit
  fi

  echo "Basic test case passed"
  rm -f tmp
}

test_demo_mult_files() {
  ./ci_mult_files > tmp

  line_cnt=`grep "CI @ inc0" tmp | wc -l`
  if [ $line_cnt -lt 100 ]; then
    echo "Not the expected behavior. CI is enabled for increment threads."
    exit
  fi

  line_cnt=`grep "CI @ dec0" tmp | wc -l`
  if [ $line_cnt -gt 1 ]; then
    echo "Not the expected behavior. CI is disabled for decrement threads."
    exit
  fi

  echo "Multi-file test case passed"
  rm -f tmp
}

build_all

printf "\n${GREEN}************ Running tests ************${NC}\n"
test_demo
test_demo_mult_files
