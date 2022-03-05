#!/bin/bash

if [ $# != 1 ]
then
        echo "Usage: ./send_queue_G.sh {qcexnod}"
        echo "Example: ./send_queue_G.sh qcexnod17"
        echo "Info for random node: ./send_queue_G.sh 1"
else

##############################################################################
  # Variables:

  file="variables.inp"
  vardir="../"
  methodG=`grep "methodG=" $vardir/$file | sed 's/methodG=//' | sed 's/^[[:space:]]*//'`
  name="${methodG}"
  nod="$1"
##############################################################################

  sed -e "s/@LOGNAME@/$LOGNAME/g" -e "s/@NAME@/$name/g" -e "s/@ZZ@/$nod/g" template_lzGaussian > run_gau_NOD${nod}
  qsub run_gau_NOD${nod}
fi
