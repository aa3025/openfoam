#!/bin/bash

# this script launches N reconstructPar processes on a local machine, where N is number of CPUs on the system
# It assigns uniformly all the timesteps between CPUs
# Launch from your OpenFOAM case folder

module load openfoam/last

# first we get startTime, endTime and dt from the case itself:
start=`cat system/controlDict | grep startTime | tr -s " " | cut -d' ' -f2 | cut -d';' -f1`
stop=`cat system/controlDict | grep endTime | tr -s " " | cut -d' ' -f2 | cut -d';' -f1 | tail -1`
writeInterval=`cat system/controlDict | grep writeInterval | tr -s " " | cut -d' ' -f2 | cut -d';' -f1 | tail -1`
deltaT=`cat system/controlDict | grep deltaT | tr -s " " | cut -d' ' -f2 | cut -d';' -f1 | tail -1`

dt=$(echo "${deltaT}*${writeInterval}" |bc) # OpenFoam solution write interval [seconds], leave as decimal! (i.e. dt = deltaT * writeInterval)

cpus=`lscpu | grep "CPU(s):" |tr -s " " | cut -d' ' -f2` # how many reconstructPar processes to launch (e.g. Nr of CPUs we have)
cpus=$SLURM_NTASKS

echo "Reconstructing from $start to $stop with step $dt on $cpus CPUs"

##### magic: ###### picking time instants for each cpu
step=`expr $dt*$cpus | bc`
last=`expr $stop-$dt | bc`
end=`expr $dt*$cpus+$start-1 | bc`

declare -a times=()
cpu=0
for i in `seq $start $dt $end`; do
   times[$cpu]=$(seq -s, $i $step $stop)
   cpu=$((cpu + 1))
done

# Launching reconstructPar one after another without wait
for i in ${times[@]}; do
reconstructPar -time $i | grep "Time = " &
echo ""
done

# Waiting untill all processes will finish
while true
  do
  pids=`pgrep -u $(id -u) reconstructPar`
  if [ -z "$pids" ]
    then
      echo "Finished!"
      exit 0
  else
    sleep 5
  fi
done

# rm -fr processor* # optional if you want to clean up space

