executable = thisCondor.sh
universe = vanilla
output   = condorLog/condorLog_$(Cluster)_$(Process).log
error    = condorLog/condorLog_$(Cluster)_$(Process).log
log      = /dev/null
should_transfer_files = yes
transfer_input_files = mgrun.sh,thisCondor.sh
when_to_transfer_output = ON_EXIT
transfer_output_files = condorOut
requirements = (machine != "node06")
arguments = $(Cluster) $(Process)
queue 5
