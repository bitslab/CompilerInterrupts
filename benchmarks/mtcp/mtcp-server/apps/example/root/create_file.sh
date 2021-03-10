#!/bin/bash

rm -f file_*
start=64 # 64B
end=1073741824 # 1GB

sz=$start
echo "Creating file of size $sz bytes"
for i in $(seq 1 $sz); do echo -n "1" >> file_${sz}_bytes ; done

while [ $sz -le $end ]; do
  old_sz=$sz
  sz=`expr $sz \* 4`
  echo "Creating file of size $sz bytes"
  cat file_${old_sz}_bytes file_${old_sz}_bytes file_${old_sz}_bytes file_${old_sz}_bytes >> file_${sz}_bytes
done
