#!/bin/bash

##############################################################################
  # Variables to change:

  # Fixed variables:
  file="variables.inp"
  Nconf=`grep "Nconf=" ../$file | sed 's/Nconf=//'`
  #Nconf="100"                              # number of geoms
  name="QM_MatSt"
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  #prefix="lum_dmso_iminabNaHopt"
  dir="$prefix.car_shortName_dir"
##############################################################################

mkdir $dir

for conf in `seq 1 1 $Nconf`
do

file=`ls g${conf}.${prefix}*.car`
cp ${file} ./$dir/g${conf}.${prefix}.Wigner.car 

done

rm -f $prefix.car_from_Wigner.tar.gz
tar -cvf  $prefix.car_from_Wigner.tar  $dir
gzip $prefix.car_from_Wigner.tar

rm -r $dir
