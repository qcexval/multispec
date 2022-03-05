#!/bin/bash

if [ $# != 4 ]
then
  echo "Usage: ./os2spec_ab.sh {SF or SO} {number of Wigner geoms} {delta} {gsa, em, st, esa, ta}"
  echo "Example: ./os2spec_ab.sh SF 10 0.1 gsa"
  echo "Info: Convolution parameters can be changed in this sh file."
  echo "      gsa = ground-state absorption (normally starting root is 1)"
  echo "      em  = spontaneous emission (normally starting root is 2) "
  echo "      st  = stimulated emission (normally starting root is 2) "
  echo "      esa = excited-state absorption (transient absorption, normally starting root is 2)"
  echo "      ta = transient absorption"
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
  tempc=1
  temp=300.0
  refr_in=1.000
  
  # Fixed variables:
  file="variables.inp"
  vardir="../"
  spin="$1"
  #Nconfgsa=`grep "Nconfgsa=" ../$file | sed 's/Nconfgsa=//'`
  Nconf="$2"
  Nconfgsa=0
  Nconfem=0
  Nconfesa=0
  nrootsgsa=0
  nrootsem=0
  nrootsesa=0

  methodM=`grep "methodM=" $vardir/$file | sed 's/methodM=//' | sed 's/^[[:space:]]*//'`
  name="${methodM}_${spin}"

  inp4semic=input_${spin}

  stype="$4"
##############################################################################

  # Setting the variables

  if [ "$stype" == "gsa" ]; then Nconfgsa=$Nconf; nrootsgsa=`tail -1 res1_${name}_gsa.dat|gawk '{print $1}'`; fi
  if [ "$stype" == "em" ] || [ "$stype" == "st" ]; then Nconfem=$Nconf; nrootsem=`tail -1 res1_${name}_em.dat|gawk '{print $1}'`; fi
  if [ "$stype" == "esa" ]; then Nconfesa=$Nconf; nrootsesa=`tail -1 res1_${name}_esa.dat|gawk '{print $1}'`; fi
  if [ "$stype" == "ta" ]
  then 
    Nconfgsa=$Nconf; Nconfem=$Nconf; Nconfesa=$Nconf
    nrootsgsa=`tail -1 res1_${name}_gsa.dat|gawk '{print $1}'`
    nrootsem=`tail -1 res1_${name}_em.dat|gawk '{print $1}'`
    nrootsesa=`tail -1 res1_${name}_esa.dat|gawk '{print $1}'`
  fi 



  # Updating info in $file

  sed -i "s/delta=.*/delta=$delta/" ../$file

  # Creating directory for files
  
  dir="Nconf${Nconf}_d${delta}"
  mkdir $dir

  # Preparing the file for the convolution

  echo "${name}                !name for output files " > $inp4semic 
  echo "${name}_gsa            !name for ground state absorption (gsa) files " >> $inp4semic 
  echo "${name}_em             !name for emission (em) files " >> $inp4semic 
  echo "${name}_esa            !name for excited state absorption (esa) files " >> $inp4semic 
  echo "$Nconfgsa $nrootsgsa   !number of geometries, number of roots (gsa)" >> $inp4semic 
  echo "$Nconfem $nrootsem     !number of geometries, number of roots (em)" >> $inp4semic 
  echo "$Nconfesa $nrootsesa   !number of geometries, number of roots (esa)" >> $inp4semic 
  echo "$E0 $EK $DE            !E0, EK, DE (ev)" >> $inp4semic 
  echo "$nm0 $nmK $Dnm         !nm0, nmK, Dnm (nm)" >> $inp4semic 
  echo "$delta $delta $delta   !delta_gsa, delta_em, delta_esa (eV)" >> $inp4semic 
  echo "$tempc $temp           !temperature correction : on(1) off(0), temperature (K)" >> $inp4semic 
  echo "1.45 1.44 1.44         !refractive index (abs region), refractive index (fluo region), refractive index (esa region)" >> $inp4semic 
  echo "1.00                   !photoluminescence quantum yield (plqy)" >> $inp4semic 

  echo "$inp4semic" | ./os2spec.x 

  echo "***********************************************************************"
  echo "Convolution parameters:"
  echo "- Wavelength range: $nm0 - $nmK (can be changed inside the sh file)"
  echo "- Broadening delta: $delta"
  echo "Folder: $dir"
  echo "***********************************************************************"
  
  # Adding info of Nconfgsa and delta in the file titles

  mv spectr_${name}.txt $dir
  mv eps_spectr_${name}.txt $dir
  mv gamma_spectr_${name}.txt $dir
  mv spectr_nm_${name}.txt $dir
  mv eps_nm_spectr_${name}.txt $dir
  mv gamma_nm_spectr_${name}.txt $dir
  mv msgs_${name} $dir
  
  mv $inp4semic $dir

fi
