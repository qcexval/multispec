#!/bin/bash

##############################################################################
  # Variables to change:
  inp4semic=input_SF
  E0=2.0d0
  EK=9.0d0
  DE=0.001d0
  nm0=170.0d0
  nmK=1200.0d0
  Dnm=1.0d0
  delta=0.1
  tempc=0
  temp=0.0
  refr_in=1.000

  
  # Fixed variables:
  file="variables.inp"
  #method=`grep "method=" ../molcas.vee/generate_inps_molcas.sh | sed 's/method=//' | sed 's/^[[:space:]]*//'`
  method=cas16in12_vtzp_32sa_7ms
  #prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  prefix=HgOboxH2O
  sufix="Wigner.5ps_MtSt"
  name="${prefix}.${sufix}_${method}.SF"
  nroots=`tail -1 res1_${name}.dat|gawk '{print $1}'`
  #Nconf=`grep "Nconf=" ../$file | sed 's/Nconf=//'`
  Nconf=100
##############################################################################

echo "$name                  !name" > $inp4semic 
echo "$Nconf $nroots         !number of geometries, number of roots" >> $inp4semic 
echo "$E0 $EK $DE            !E0, EK, DE (ev)" >> $inp4semic 
echo "$nm0 $nmK $Dnm         !nm0, nmK, Dnm (nm)" >> $inp4semic 
echo "$delta                 !delta (eV)" >> $inp4semic 
echo "$tempc $temp $refr_in  !temperature correction : on(1) off(0), temperature (K), refraction index" >> $inp4semic 

echo "$inp4semic" | ./semiclassical.x 

