#!/bin/bash

if [ $# != 1 ]
then
  echo "Usage:"
  echo "./gaus2nx.sh {gaussian file with opt+freq}"
else

##############################################################################
  # Variables to change:
  file="variables.inp"
  outNX="initqp_input"
  gausfile="$1"
  pathNX="/soft/NewtonX/NX-2-B18/bin"

  # Fixed variables:
#  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
#  QM=`grep "QM=" ../$file | sed 's/QM=//'`
#  Nconf=`grep "Nconf=" ../$file | sed 's/Nconf=//'`
  Nconf=100
  #nameNX="lum_wat_amina"
  #prefix="lum_wat_aminabNaH"
##############################################################################

# Obtaining data from gaussian file

QMall=`grep "NAtoms" $gausfile | head -1 | gawk '{print $2}'`

# Obtaining geometries
#  log="$gausfile"
#  numgeom=`grep -a -n 'Input orientation:' $log | tail -1 | cut -d":" -f 1`
#  sed -n $[ numgeom + 5],$[ numgeom + 4 + QMall ]p $log | gawk "// {print \$0}" > geom.xyz
#  /home/roca/bin/xyzG2M geom.xyz
./gaus2optxyz.sh $gausfile
  project=`basename $gausfile .log`

# Printing initqp_input for newtonX

echo "&dat" > $outNX
echo " nact = 2" >> $outNX
echo " numat = $QMall" >> $outNX
echo " npoints = $Nconf" >> $outNX
echo " file_geom = geom" >> $outNX
echo " iprog = 4" >> $outNX
echo " file_nmodes = $gausfile" >> $outNX
echo " anh_f = 1" >> $outNX
echo " temp = 0.0" >> $outNX
echo " ics_flg = n" >> $outNX
echo " chk_e = 0" >> $outNX
echo " iseed = -1" >> $outNX
echo " lvprt = 1" >> $outNX
echo "/" >> $outNX

# Executing newtonX

  $pathNX/xyz2nx < $project.gausopt.xyz
  $pathNX/initcond.pl < $outNX > initcond.log


fi
