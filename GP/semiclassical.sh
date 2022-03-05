#!/bin/bash

if [ $# != 3 ]
then
  echo "Usage: ./semiclassical.sh {SF or SO} {number of Wigner geoms} {delta}"
  echo "Example: ./semiclassical.sh SF 10 0.1"
  echo "Info: Convolution parameters can be changed in this sh file."
else

##############################################################################
  # Variables to change to set up the spectrum:
  E0=2.0d0
  EK=9.0d0
  DE=0.001d0
  nm0=100.0d0       # Shorter wavelenght for the convolution
  nmK=1200.0d0      # Longer wavelenght for the convolution
  Dnm=1.0d0
  delta="$3"
  tempc=0
  temp=0.0
  refr_in=1.000

  
  # Fixed variables:
  file="variables.inp"
  vardir="../"
  spin="$1"
  #Nconf=`grep "Nconf=" ../$file | sed 's/Nconf=//'`
  Nconf="$2"
  methodM=`grep "methodM=" $vardir/$file | sed 's/methodM=//' | sed 's/^[[:space:]]*//'`
  name="${methodM}_${spin}"
  nroots=`tail -1 res1_${name}.dat|gawk '{print $1}'`

  inp4semic=input_${spin}
  dir="Nconf${Nconf}_d${delta}"
##############################################################################

  # Updating info in $file

  sed -i "s/delta=.*/delta=$delta/" $vardir/$file

  # Creating directory for files
  
  mkdir $dir

  # Preparing the file for the convolution

  echo "$name                  !name" > $inp4semic 
  echo "$Nconf $nroots         !number of geometries, number of roots" >> $inp4semic 
  echo "$E0 $EK $DE            !E0, EK, DE (ev)" >> $inp4semic 
  echo "$nm0 $nmK $Dnm         !nm0, nmK, Dnm (nm)" >> $inp4semic 
  echo "$delta                 !delta (eV)" >> $inp4semic 
  echo "$tempc $temp $refr_in  !temperature correction : on(1) off(0), temperature (K), refraction index" >> $inp4semic 

  echo "$inp4semic" | ./semiclassical.x 

  echo "***********************************************************************"
  echo "Convolution parameters:"
  echo "- Wavelength range: $nm0 - $nmK (can be changed inside the sh file)"
  echo "- Broadening delta: $delta"
  echo "Folder: $dir"
  echo "***********************************************************************"
  
  # Adding info of Nconf and delta in the file titles

  mv spectr_${name} $dir
  mv eps_spectr_${name} $dir
  mv nm_spectr_${name} $dir
  mv eps_nm_spectr_${name} $dir
  mv msgs_${name} $dir
  
  mv $inp4semic $dir

fi
