#!/bin/bash

THREADS=16
if [ $# -eq 0 ]; then
  echo "Usage: ./run_server.sh <#threads>"
  exit
else
  THREADS=$1
fi

echo "Running server with $THREADS threads"
./epserver -p ./root -N $THREADS >out 2>&1
