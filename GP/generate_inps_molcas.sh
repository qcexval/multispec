#!/bin/bash

#-----
# template - template file with all the CASSCF/MS-CASPT2/RASSI routines. Edit it for particular type of 
#	     calculations!!!
# Nconf    - number of geometry files
# name	   - general name of the geometry files (gX_name.xyz)
# method   - method of usage (only for the naming of .inp files)
#---

#(echo "$NSYM";echo " 10 10 10 10 5.0d0") | ./a.out
#if [ $# -le 0 ]
#then
#  echo "Usage:"
#  echo "./generate_inps_molcas.sh {number of geometries} {molcas input template} "
#  echo "Example ./generate_inps_molcas.sh 100 molcas_input.template "
#else

#name="$1"

##############################################################################
  # Variables to change:
  method=pt2orb

  # Fixed variables:
  file="variables.inp"
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  #prefix="HgOboxH2O"
  Nconf=`grep "Nconf=" ../$file | sed 's/Nconf=//'`
  #Nconf="1"
  sufix=WignerQM
  template="molcas_input.template"
#template="molcas_routine_mp2_cs"
##############################################################################

#rm -f g*.inp

for conf in `seq 1 1 $Nconf`
do
  geom=`ls g${conf}_$prefix.$sufix.xyz`
#  base=$(echo "$geom" | sed -e 's/\.[^.]*$//')
  inp="g${conf}_${prefix}.${sufix}_${method}.inp"

  sed -s "s/@GEOMETRY@/$geom/g" $template.head > $inp 
  cat  $template.tail >> $inp
done

#fi
