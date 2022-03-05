#!/bin/bash

if [ $# != 2 ]
then
  echo "Usage: ./gaus2nx.sh {number of Wigner geoms} {gs, es}"
  echo "Example: ./gaus2nx.sh gs"
  echo "Info: NewtonX path must be defined in this sh script!"
  echo "Info: Default parameter for NewtonX can be modified in this sh script."
else

##############################################################################
  # Variables:

  file="variables.inp"
  vardir="../"
  outNX="initqp_input"
  pathNX="/soft/NewtonX/NX-2-B18/bin"
  Nconf="$1"
  job="$2"

##############################################################################

  # Reading info in $file

  if [ "$job" == "gs" ]; then methodG=`grep "methodGgs=" $vardir/$file | sed 's/methodGgs=//' | sed 's/^[[:space:]]*//'`; fi
  if [ "$job" == "es" ]; then methodG=`grep "methodGes=" $vardir/$file | sed 's/methodGes=//' | sed 's/^[[:space:]]*//'`; fi

  gausfile="$methodG.log"

  # Updating info in $file

  sed -i "s/Nconf=.*/Nconf=$Nconf/" $vardir/$file

  # Obtaining data from gaussian file

  QMall=`grep "NAtoms" $gausfile | head -1 | gawk '{print $2}'`

  # Obtaining geometries

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

  ./convert_nx_xyz.sh $job


fi
