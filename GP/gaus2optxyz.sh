#!/bin/bash

if [ $# != 1 ]
then
  echo "Usage:"
  echo "./gaus2optxyz.sh {gaussian file with opt+freq}"
else

##############################################################################
  # Variables to change:
  gausfile="$1"
  project=`basename $gausfile .log`

  # Fixed variables:
##############################################################################

# Obtaining data from gaussian file

QMall=`grep "NAtoms" $gausfile | head -1 | gawk '{print $2}'`

# Obtaining geometries
  log="$gausfile"


if grep -q "Standard orientation:" $log
then 
  numgeom=`grep -a -n 'Standard orientation:' $log | tail -1 | cut -d":" -f 1`
else
  numgeom=`grep -a -n 'Input orientation:' $log | tail -1 | cut -d":" -f 1`
fi
  sed -n $[ numgeom + 5],$[ numgeom + 4 + QMall ]p $log | gawk "// {print \$0}" > $project.gausopt.xyz
  /home/roca/bin/xyzG2M $project.gausopt.xyz


fi
 
