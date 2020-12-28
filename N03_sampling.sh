#!/bin/bash

thisIndex=$1
maxFile=$2
listFile=$3

firstIndex=`expr $thisIndex \* $maxFile + 1`
lastIndex=`expr $firstIndex + $maxFile - 1`
inFiles=""
index=0

for file in `cat $listFile`
do
    ((index++))
    if [ $index -ge $firstIndex ] && [ $index -le $lastIndex ]; then
        echo "$index $file"
        inFiles="$inFiles $file"
    fi
done

echo $inFiles
