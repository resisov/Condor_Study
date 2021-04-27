#!/bin/bash

#cd ${1%/*}

#gridpackname=`basename $1`
#gridpackpwd=`readlink -e $gridpackname`
#if [ ! $gridpackname ]; then echo "usage $0 gridpack" 1>&2; exit 1; fi
#if [ ! -f $gridpackpwd ] || [ ! $gridpackname ]; then echo "Error NotFound GridPack $gridpackname" 1>&2; exit 1; fi

cat << EOF > Executor.sh
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

#tar -xvf $gridpackname
echo "${1}_${2}"
if [ ! -d "${1}_${2}" ]; then mkdir "${1}_${2}"; fi
python make_proc_card.py ${1} ${2}
python make_run_card.py ${1} ${2}
python make_spin_card.py ${1} ${2}
python make_param_card.py ${1} ${2}

#mkdir DMsignal/${1}_${2}
source gridpack_generation.sh ${1}_${2} ${1}_${2}
#./runcmsgrid.sh 1 \$RANDOM

ls
ls "${1}_${2}"

if [ ! -d condorOut ]; then mkdir condorOut; fi
mv *.xz condorOut/
#mv cmsgrid_final.lhe condorOut/events_${1}_${2}.lhe
EOF

chmod 777 Executor.sh
cat << EOF > job.jdl
executable = Executor.sh
universe = vanilla
output   = condorLog/condorLog_\$(Cluster).log
error    = condorLog/condorLog_\$(Cluster).log
log      = /dev/null
should_transfer_files = yes
transfer_input_files = make_proc_card.py, make_run_card.py, make_spin_card.py, make_param_card.py, gridpack_generation.sh
when_to_transfer_output = ON_EXIT
transfer_output_files = condorOut
requirements = (machine == "node04" || machine == "node05")
arguments = \$(Cluster)

getenv = true

queue 1
EOF

if [ ! -d condorLog ]; then mkdir condorLog; fi

condor_submit job.jdl
