#!/bin/bash

if [ $# != 3 ]
then
        echo "Usage: ./send_queue_M.sh {initial geom} {final geom} {qcexnod}"
        echo "Example: ./send_queue_M.sh 1 2 qcexnod17"
else

##############################################################################
  # Variables:

  file="variables.inp"
  vardir="../../"
  methodM=`grep "methodM=" $vardir/$file | sed 's/methodM=//' | sed 's/^[[:space:]]*//'`
  name="${methodM}"
##############################################################################

  # Input in command line
  g0="$1"    # initial geom
  gt="$2"    # initial geom
  nod="$3" # node to submit

  # Input in file
#  g0=45    # initial geom
#  gt=46  # final geom
#  nod=07 # node to submit

  sed -e "s/@LOGNAME@/$LOGNAME/g" -e "s/@NAME@/$name/g" -e "s/@XX@/$g0/g" -e "s/@YY@/$gt/g" -e "s/@ZZ@/$nod/g" template_lzMolcas > run_mol_${g0}_${gt}_NOD${nod}
  qsub run_mol_${g0}_${gt}_NOD${nod}
fi
