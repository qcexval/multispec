#!/bin/bash

if [ $# != 1 ]
then
  echo "Usage:"
  echo "./xyz2xyznum.sh {xyz file to add numbering in labels}"
else

export LC_NUMERIC=C   # Force point as decimal separator in printf command

xyzinp="$1"
tmpfile="$1.nonumbering"

mv $xyzinp $tmpfile 

QM=`head -1 $tmpfile | gawk '{print $1}'`


echo -e "$QM" > $xyzinp
echo -e "" >> $xyzinp

for i in `seq 1 1 $QM`
do
  label=`gawk "NR == $[i+2] {print \\$1}" $tmpfile`
  labelnum=${label}${i}
  x=`gawk "NR == $[i+2] {print \\$2}" $tmpfile`
  y=`gawk "NR == $[i+2] {print \\$3}" $tmpfile`
  z=`gawk "NR == $[i+2] {print \\$4}" $tmpfile`

  printf "%-5s %14.9f %14.9f %14.9f\n" $labelnum $x $y $z >> $xyzinp

done

fi
