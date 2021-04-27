#!/bin/bash

for ((i=1630; i<1730; i+=100)); do
for ((j=10; 2*j<$i; j+=40)); do
./Condom_run.sh "${i}_${j}_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz" $i $j
done
done
