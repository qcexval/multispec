#!/bin/bash

if [ $# != 1 ]
then
  echo "Usage: ./convert_nx_xyz.sh {gs, es}"
  echo "Example: ./convert_nx_xyz.sh gs"
else

##############################################################################

  # Variables:

  job="$1"
  file="variables.inp"
  vardir="../"
  fileNXgeoms="final_output"
  file4f90="variables4f90.inp"
  Nconf=`grep "Nconf=" $vardir/$file | sed "s/Nconf=//"`
#  methodG=`grep "methodG=" $vardir/$file | sed 's/methodG=//' | sed 's/^[[:space:]]*//'`
  QMall=`grep "numat =" initqp_input | sed 's/numat =//'`
##############################################################################

  if [ "$job" == "gs" ]; then methodG=`grep "methodGgs=" $vardir/$file | sed 's/methodGgs=//' | sed 's/^[[:space:]]*//'`; fi
  if [ "$job" == "es" ]; then methodG=`grep "methodGes=" $vardir/$file | sed 's/methodGes=//' | sed 's/^[[:space:]]*//'`; fi

  echo "$fileNXgeoms" > $file4f90 
  echo "$QMall" >> $file4f90 
  echo "$Nconf" >> $file4f90 
  echo "$methodG" >> $file4f90 

  ./convert_nx_xyz.x 

  for conf in `seq 1 1 $Nconf`
  do
    ./xyz2xyznum.sh   g${conf}_${methodG}.xyz 
  done

fi
