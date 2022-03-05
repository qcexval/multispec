#!/bin/bash

if [ $# != 3 ]
then
  echo "Usage: ./generate_inp_gaussian.sh {initial xyz coord file} {method} {gs, es}"
  echo "Example: ./generate_inp_gaussian.sh acrolein.xyz b3lyp_631Gdp"
  echo "Info:  gs = ground state"
  echo "       es = excited state"
else

##############################################################################
  # Variables:

  file="variables.inp"
  vardir="../"
  geom="$1"
  methodG="$2"
  template="gaussian_input.template"
  job="$3"
##############################################################################

  # Updating info in $file

  if [ "$job" == "gs" ]; then sed -i "s/methodGgs=.*/methodGgs=$methodG/" $vardir/$file; fi
  if [ "$job" == "es" ]; then sed -i "s/methodGes=.*/methodGes=$methodG/" $vardir/$file; fi


  # Generating gaussian input 

  name="${methodG}"
  inp="${methodG}.com"

  sed -s "s/@INP@/$name/g" $template > $inp 
  tail -n +3 $geom >> $inp 
  echo "" >> $inp

fi
