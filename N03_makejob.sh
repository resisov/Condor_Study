#!/bin/bash

maxfile=20
tmp=condor_out
if [ ! -d condor_out ]; then mkdir condor_out; fi
cp N03_sampling.sh $tmp
cp data.list $tmp


nfile=`cat data.list | wc -l`
nfile=`expr $maxfile + $nfile - 1`
nJob=`expr $nfile / $maxfile`

cat << EOF > $tmp/job.jds
executable = N03_sampling.sh
universe = vanilla
output   = condorOut_\$(Process).out
error    = condorErr_\$(Process).err
log      = condor_logfile.log
should_transfer_files = yes
transfer_input_files = data.list
when_to_transfer_output = ON_EXIT
arguments = \$(Process) $maxfile data.list
queue $nJob
EOF



cd $tmp
condor_submit job.jds
