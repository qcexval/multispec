#!/bin/bash

if [ $# != 1 ]
then
  echo "Usage:"
  echo "./gaus2car.sh {gaussian file with charges}"
else

gausfile="$1"

  # Fixed variables:
  file="variables.inp"
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  outfile="$prefix.car"

outfilexyz="geom.xyz"
outfilechg="chg.data"

export LC_NUMERIC=C   # Force point as decimal separator in printf command

# Obtaining data from gaussian file

QM=`grep "NAtoms" $gausfile | head -1 | gawk '{print $2}'`
grep -B $QM "Charges from ESP fit wi" $gausfile | head -$QM > $outfilechg 
grep -A $QM "Symbolic Z-Matrix" $gausfile | tail -$QM > $outfilexyz 

# Printing xyz and charges to car format

echo "!BIOSYM archive 3" > $outfile
echo "PBC=OFF" >> $outfile
echo "Materials Studio Generated CAR File" >> $outfile
echo "!DATE Sun May 03 13:56:28 2020" >> $outfile
#echo "PBC   20.0000   20.0000   20.0000   90.0000   90.0000   90.0000 (P1)" >> $outfile

for i in `seq 1 1 $QM`
do
  label=`gawk "NR == $[i] {print \\$1}" $outfilexyz`
  labelnum=${label}${i}
  x=`gawk "NR == $[i] {print \\$2}" $outfilexyz`
  y=`gawk "NR == $[i] {print \\$3}" $outfilexyz`
  z=`gawk "NR == $[i] {print \\$4}" $outfilexyz`
  chg=`gawk "NR == $[i] {print \\$3}" $outfilechg`
#echo $x $y $z $chg

   printf "%-5s %14.9f %14.9f %14.9f %-4s %-6i %-7s %-2s %+5.3f\n" $labelnum $x $y $z "XXXX" "1" "xx" $label $chg   >> $outfile

done

echo "end" >> $outfile
echo "end" >> $outfile

fi
