#!/bin/bash

#cd ${1%/*}
Delphes="/home/twkim/Delphes3.4.2/"
#gridpackname=`basename $1`
filename=$1
#if [ ! $gridpackname ]; then echo "usage $0 gridpack" 1>&2; exit 1; fi
#if [ ! -f $gridpackpwd ] || [ ! $gridpackname ]; then echo "Error NotFound GridPack $gridpackname" 1>&2; exit 1; fi
#echo ${gridpackname}

cat << EOF > Delphes_${2}_${3}.sh
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
export PYTHIA8=/cvmfs/cms.cern.ch/slc6_amd64_gcc530/external/pythia8/223-mlhled
export PYTHIA8DATA=\$PYTHIA8/share/Pythia8/xmldoc/
export LD_LIBRARY_PATH=\$PYTHIA8/lib:\$LD_LIBRARY_PATH

cat << EOF > config_${2}_${3}.cmnd
! 1) Settings used in the main program.

Main:numberOfEvents = 100000            ! number of events to generate
Main:timesAllowErrors = 3          ! how many aborts before run stops

! 2) Settings related to output in init(), next() and stat().

Init:showChangedSettings = on      ! list changed settings
Init:showChangedParticleData = off ! list changed particle data
Next:numberCount = 200             ! print message every n events
Next:numberShowInfo = 1            ! print event information n times
Next:numberShowProcess = 1         ! print process record n times
Next:numberShowEvent = 0           ! print event record n times

! 3) Set the input LHE file

Beams:frameType = 4
Beams:LHEF = \${filename}
$(echo 'EOF')

if [ ! -d condorDelPyOut ]; then mkdir condorDelPyOut; fi
cp config.cmnd condorDelPyOut/

ls

${Delphes}DelphesPythia8 ${Delphes}cards/CMS_PhaseII/CMS_PhaseII_200PU.tcl config.cmnd DelPh_\${filename}.root

mv DelPh_\${filename}.root condorDelPyOut/
EOF

chmod 777 Delphes_${2}_${3}.sh


cat << EOF > job_${2}_${3}.jdl
executable = Delphes_${2}_${3}.sh
universe = vanilla
output   = condorDelpyLog/condorLog_\$(Cluster).log
error    = condorDelpyLog/condorLog_\$(Cluster).log
log      = /dev/null
should_transfer_files = yes
transfer_input_files = ${Delphes}cards/CMS_PhaseII/CMS_PhaseII_200PU.tcl, /home/twkim/MinBias_100k.pileup, \$(DATAFile)
when_to_transfer_output = ON_EXIT
transfer_output_files = condorDelpyOut
requirements = (machine == "node01" || machine == "node02")
arguments = \$(Cluster), \$(DATAFile)

queue 1
EOF

if [ ! -d condorDelpyLog ]; then mkdir condorDelpyLog; fi

condor_submit job_${2}_${3}.jdl
