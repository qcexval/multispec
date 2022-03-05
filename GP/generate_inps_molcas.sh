#!/bin/bash


if [ $# != 2 ]
then
  echo "Usage: ./generate_inps_molcas.sh {method} {gs, es}"
  echo "Example ./generate_inps_molcas.sh caspt2_6in5_anosvdzp gs"
else

##############################################################################

  # Variables:

  file="variables.inp"
  vardir="../../"
  methodM="$1"
  #methodG=`grep "methodG=" $vardir/$file | sed 's/methodG=//' | sed 's/^[[:space:]]*//'`
  Nconf=`grep "Nconf=" $vardir/$file | sed 's/Nconf=//'`
  template="molcas_input.template"
  job="$2"

##############################################################################

  # Reading info in $file

  if [ "$job" == "gs" ]; then methodG=`grep "methodGgs=" $vardir/$file | sed 's/methodGgs=//' | sed 's/^[[:space:]]*//'`; fi
  if [ "$job" == "es" ]; then methodG=`grep "methodGes=" $vardir/$file | sed 's/methodGes=//' | sed 's/^[[:space:]]*//'`; fi

  # Updating info in $file

  sed -i "s/methodM=.*/methodM=$methodM/" $vardir/$file

  # Generating the molcas input files 

  for conf in `seq 1 1 $Nconf`
  do
    geom=`ls g${conf}_${methodG}.xyz`
    inp="g${conf}_${methodM}.inp"

    sed -s "s/@GEOMETRY@/$geom/g" $template > $inp 
  done

fi
