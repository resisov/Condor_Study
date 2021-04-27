#!/bin/bash

#cd ${1%/*}

#gridpackname=`basename $1`
gridpack=$1
#if [ ! $gridpackname ]; then echo "usage $0 gridpack" 1>&2; exit 1; fi
#if [ ! -f $gridpackpwd ] || [ ! $gridpackname ]; then echo "Error NotFound GridPack $gridpackname" 1>&2; exit 1; fi
#echo ${gridpackname}

cat << EOF > Executor_${2}_${3}.sh
#!/bin/bash
export SCRAM_ARCH=slc6_amd64_gcc530
export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
echo "\$VO_CMS_SW_DIR \$SCRAM_ARCH"
source \$VO_CMS_SW_DIR/cmsset_default.sh
export SSL_CERT_DIR='/etc/grid-security/certificates'

(
cd /cvmfs/cms.cern.ch/slc6_amd64_gcc530/cms/cmssw/CMSSW_9_1_0_pre3/
eval \`scramv1 runtime -sh\`
)

tar -xvf $gridpack
./runcmsgrid.sh 100000 \$RANDOM

ls

if [ ! -d condorOut ]; then mkdir condorOut; fi
mv cmsgrid_final.lhe condorOut/events_${2}_${3}.lhe
EOF

chmod 777 Executor_${2}_${3}.sh

cat << EOF > job.jdl
executable = Executor_${2}_${3}.sh
universe = vanilla
output   = condorLog/condorLog_\$(Cluster).log
error    = condorLog/condorLog_\$(Cluster).log
log      = /dev/null
should_transfer_files = yes
transfer_input_files = `readlink -e $gridpack`
when_to_transfer_output = ON_EXIT
transfer_output_files = condorOut
requirements = (machine == "node04" || machine == "node05")
arguments = \$(Cluster)

queue 1
EOF

if [ ! -d condorLog ]; then mkdir condorLog; fi

condor_submit job.jdl
