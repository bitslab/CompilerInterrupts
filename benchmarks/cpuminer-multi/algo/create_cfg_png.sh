#!/bin/bash

if [ $# -eq 1 ]; then
  file=$1
else
  file="llvm_fence_test.ll"
fi

/mnt/nilanjana/bin/opt -dot-cfg-only -S < $file > /dev/null
while read line; do
  func_def=`echo $line | grep define`
  if [ ! -z "$func_def" ]
  then
    func_name=`echo $func_def | cut -d'@' -f 2 | cut -d'(' -f 1`
    dot_name=".$func_name.dot"
    png_name="$func_name.png"
    echo $dot_name
    dot -Tpng $dot_name -o $png_name
    rm -f $dot_name
  fi
done < $file
