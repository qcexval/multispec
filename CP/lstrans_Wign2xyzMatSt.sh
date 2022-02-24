#!/bin/bash

countOut=0

##############################################################################
  # Variables to change:
  file="variables.inp"

  # Fixed variables:
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  nameNX="$prefix.WignerQM"
  #nameNX="lum_wat_amina"
  #prefix="lum_wat_aminabNaH"
  name="QM_MatSt"
  sufix="car.xyz"
##############################################################################

for geom in `ls ${name}_${prefix}*${sufix}`
do

for i in 1 2 3 4 
do
countIn=$[countOut + i]
lstrans project=g${countIn}_${geom}_Wig4Mat reffile=${geom} inifile=../newtonX/g${countIn}_${nameNX}.NOsol.xyz  --noreorder
#echo $countIn
done
countOut=$[countOut + 4]

done
