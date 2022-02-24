#!/bin/bash

##############################################################################
  # Variables to change:

  # Fixed variables:
  file="variables.inp"
  QM=`grep "QM=" ../$file | sed 's/QM=//'`
  #QM="18"
  name="QM_MatSt"
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  #prefix="lum_wat_aminabNaH"
##############################################################################

rm -f ${name}.movie 

countOut=0

for geom in `ls $prefix*.car`
do

for i in 1 2 3 4 
do
countIn=$[countOut + i]


  nat=`wc -l $geom | gawk "{print \\$1}"`   # Number of lines in car

  # When solute is at the beginning:
  MM=$[nat - 5 - QM]   # Number of lines without QM and first lines 
  # When solute is at the end:
#  MM=$[nat - 2 - QM]   # Number of lines without QM and last lines 

  echo "$nat $MM"

  # When solute is at the beginning:
  head -5 $geom > g${countIn}.$geom.Wigner.car

  tail -$[ $QM ]  g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz > g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz.1stCOL
  head -$[ $QM + 5 ] $geom | tail -$[ $QM ] | gawk '{print $5, $6, $7, $8, $9}' > g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz.2ndCOL

  paste g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz.1stCOL g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz.2ndCOL > g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz.allCOL

  gawk '{printf "%-5s %14.9f %14.9f %14.9f %-4s %-6i %-7s %-2s %+5.3f\n", $1, $2, $3, $4, $5, $6, $7, $8, $9}' g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz.allCOL >> g${countIn}.$geom.Wigner.car

  tail -$MM $geom >> g${countIn}.$geom.Wigner.car
  # --------------------------

  # When solute is at the end:
#  head -$MM $geom > g${countIn}.$geom.Wigner.car

#  tail -$[ $QM ]  g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz > g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz.1stCOL
#  tail -$[ $QM + 2 ] $geom | head -$[ $QM ] | gawk '{print $5, $6, $7, $8, $9}' > g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz.2ndCOL

#  paste g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz.1stCOL g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz.2ndCOL > g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz.allCOL

#  gawk '{printf "%-5s %14.9f %14.9f %14.9f %-4s %-6i %-7s %-2s %+5.3f\n", $1, $2, $3, $4, $5, $6, $7, $8, $9}' g${countIn}_${name}_${geom}.xyz_Wig4Mat.trans.xyz.allCOL >> g${countIn}.$geom.Wigner.car

#  tail -2 $geom >> g${countIn}.$geom.Wigner.car
  # --------------------------

  # Delete Ctrl+M
  sed -i "s///g" g${countIn}.$geom.Wigner.car

#  sed -e 's/\^M//g' $geom.g${countIn}.Wigner.ctrlM > $geom.g${countIn}.Wigner
#  rm -f $geom.g${countIn}.Wigner.ctrlM

done
countOut=$[countOut + 4]

done
