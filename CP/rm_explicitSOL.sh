#!/bin/bash

if [ $# != 2 ]
then
  echo "Usage:"
  echo "./rm_explicitSOL.sh {xyz file} {number of QM atoms without explicit solvent}"
else

inpxyz="$1"
QM="$2"
project=`basename $inpxyz .xyz`

outxyz_NOsol="$project.NOsol.xyz"

# Printing xyz without explicit solvent

echo "$QM" > $outxyz_NOsol
echo -e "" >> $outxyz_NOsol
sed -n $[ 3],$[ QM + 2]p $inpxyz | gawk "// {print \$0}" >> $outxyz_NOsol

fi
