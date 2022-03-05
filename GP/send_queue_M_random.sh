#!/bin/bash

if [ $# != 3 ]
then
  echo "Usage: ./send_queue_M_random.sh {initial geom to calculate} {num geoms} {jobs per node}"
  echo "Example: ./send_queue_M_random.sh 6 4 2"
else

##############################################################################
  # Variables to change:
  iniconf="$1"                               # initial geom to calculate
  numconf="$2"                               # num geoms to calculate
  jxnod="$3"                                 # jobs per node

  # Fixed variables:
  file="variables.inp"
  vardir="../../"
  methodM=`grep "methodM=" $vardir/$file | sed 's/methodM=//' | sed 's/^[[:space:]]*//'`
  name="${methodM}"
##############################################################################

  totcyc=$[ $numconf / $jxnod ]

  for i in `seq 1 1 $totcyc`
  do

    g0=$[$iniconf + $jxnod * $i - $jxnod ]
    gt=$[$iniconf + $i * $jxnod - 1]

    sed -e "s/@LOGNAME@/$LOGNAME/g" -e "s/@NAME@/$name/g" -e "s/@XX@/$g0/g" -e "s/@YY@/$gt/g" -e "s/@ZZ@/1/g" template_lzMolcas > run_mol_${g0}_${gt}_random
    qsub run_mol_${g0}_${gt}_random

  done
fi
