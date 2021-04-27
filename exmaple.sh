#!/bin/bash

# Make excution file
cat << EOF > thisCondor.sh
#!/bin/bash

cd
source cmsset_del
cd CMSSW_9_1_0_pre3/src/
cmsenv
cd /home/twkim/gitdir/Condor_Study
EOF

chmod +x thisCondor.sh

# MG5 run
cat << EOF > mgrun.sh
cd /home/twkim/MG5_aMC_v2_7_3
./bin/mg5_aMC
generate p p > t t~
output ctest
0
0
0
EOF

# Make description file
cat << EOF > thisJob.jdl
executable = thisCondor.sh
universe = vanilla
output   = condorLog/condorLog_\$(Cluster)_\$(Process).log
error    = condorLog/condorLog_\$(Cluster)_\$(Process).log
log      = /dev/null
should_transfer_files = yes
transfer_input_files = mgrun.sh,thisCondor.sh
when_to_transfer_output = ON_EXIT
transfer_output_files = condorOut
requirements = (machine != "node06")
arguments = \$(Cluster) \$(Process)
queue 5
EOF

if [ ! -d condorLog ]; then mkdir condorLog; fi

# Submit job
condor_submit thisJob.jdl
