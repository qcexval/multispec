#!/bin/bash

if [ $# != 4 ]
then
  echo "Usage: ./deconvolute.sh {SF or SO} {number of Wigner geoms} {delta} {gsa, em, st, esa}"
  echo "Example: ./deconvolute.sh SF 10 0.3 gsa"
else

##############################################################################
  # Fixed variables:
  file="variables.inp"
  vardir="../"
  spin="$1"
  inp4semic=input_${spin}
  #Nconf=`grep "Nconf=" ../$file | sed 's/Nconf=//'`
  Nconf="$2"
  methodM=`grep "methodM=" $vardir/$file | sed 's/methodM=//' | sed 's/^[[:space:]]*//'`
  #delta=`grep "delta=" ../$file | sed 's/delta=//' | sed 's/^[[:space:]]*//'`
  delta="$3"
  name="${methodM}_${spin}"
  dir="Nconf${Nconf}_d${delta}"
  stype="$4"
  r2dec=`tail -1 res1_${name}_gsa.dat | gawk '{print $1}'`
##############################################################################

  gnufileIN="nm_spectr_${name}_Nconf${Nconf}_d${delta}_${stype}.gnu"
  gnufileOUT="nm_spectr_${name}_Nconf${Nconf}_d${delta}_${stype}.deconv.gnu"
  cat $gnufileIN > $gnufileOUT

  # Setting the variables

  if [ "$stype" == "gsa" ]; then r2dec=`tail -1 res1_${name}_gsa.dat|gawk '{print $1}'`; fi
  if [ "$stype" == "em" ] || [ "$stype" == "st" ]; then r2dec=`tail -1 res1_${name}_em.dat|gawk '{print $1}'`; fi
  if [ "$stype" == "esa" ]; then r2dec=`tail -1 res1_${name}_esa.dat|gawk '{print $1}'`; fi
  if [ "$stype" == "ta" ]; then echo "Deconvolution not for ta!"; exit; fi

  for root in `seq 1 1 $r2dec`
  do
    for conf in `seq 1 1 $Nconf`
    do
      if [ "$stype" == "gsa" ]; then log="res${conf}_${name}_gsa.dat"; out="res${conf}_${name}_r${root}_gsa.dat"; fi
      if [ "$stype" == "em" ] || [ "$stype" == "st" ]; then log="res${conf}_${name}_em.dat"; out="res${conf}_${name}_r${root}_em.dat"; fi
      if [ "$stype" == "esa" ]; then log="res${conf}_${name}_esa.dat"; out="res${conf}_${name}_r${root}_esa.dat"; fi
  
      sed -n $[ root],$[ root]p $log | gawk "// {print \$1,\$2,\$3}" > $out

    done

    SpState="${spin}_r${root}"
    sed -e "s/\$nrootsgsa/1/" -e "s/\$nrootsem/1/" -e "s/\$nrootsesa/1/" os2spec.sh > semi4deconv.sh
    chmod u+x semi4deconv.sh
    ./semi4deconv.sh $SpState $Nconf $delta $stype > tmp
    rm -f semi4deconv.sh tmp

    mv res*_${name}_r${root}* $dir

    datafile="spectr_nm_${name}_r${root}.txt"
    datafileem="gamma_nm_spectr_${name}_r${root}.txt"

    if [ "$stype" == "gsa" ]
    then
      echo "replot \"$dir\/$datafile\" u 1:(\$2*1E17) w l lw 2 title \"1->${root}\" " >> $gnufileOUT
    elif [ "$stype" == "st" ]
    then
      echo "replot \"$dir\/$datafile\" u 1:(\$4*1E17) w l lw 2 title \"${r2dec}->${root}\" " >> $gnufileOUT
    elif [ "$stype" == "esa" ]
    then
      label=$(( $root - 1))
      echo "replot \"$dir\/$datafile\" u 1:(\$6*1E17) w l lw 2 title \"trans ${label}\" " >> $gnufileOUT
    elif [ "$stype" == "em" ]
    then
      echo "replot \"$dir\/$datafileem\" u 1:(\$2*1E12) w l lw 2 title \"${r2dec}->${root}\" " >> $gnufileOUT
    else
      echo "Error in 4th argument: Choose only either gsa, em, st or esa!"
    fi


  done
  
  echo ""
  echo "##########################################################################################"
  echo "Type gnuplot -p $gnufileOUT for plotting!"
  echo "##########################################################################################"
  echo ""

  gnuplot -p $gnufileOUT 

fi
