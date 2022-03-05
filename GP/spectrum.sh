#!/bin/bash

if [ $# != 4 ]
then
  echo "Usage: ./spectrum.sh {SF or SO} {number of Wigner geoms} {delta} {gsa, em, st, esa, ta}"
  echo "Example: ./spectrum.sh SF 10 0.3 gsa"
else

##############################################################################

  # Variables:

  file="variables.inp"
  vardir="../"
  spin="$1"
  methodM=`grep "methodM=" $vardir/$file | sed 's/methodM=//' | sed 's/^[[:space:]]*//'`
  Nconf="$2"
  delta="$3"
  name="${methodM}_${spin}"
  stype="$4"
  inp4gnu="nm_spectr_${name}_Nconf${Nconf}_d${delta}_${stype}.gnu"

  dir="Nconf${Nconf}_d${delta}"
  
##############################################################################

  echo "set terminal wxt size 800,400" > $inp4gnu
  echo "set lmargin 11" >> $inp4gnu


  echo "set xtics nomirror out" >> $inp4gnu
  echo "set ytics nomirror out" >> $inp4gnu
  echo "set encoding iso_8859_1" >> $inp4gnu
  echo "set xlabel '{/Symbol l}/nm' font 'Helvetica,16'" >> $inp4gnu
  echo "set xlabel offset 0,-0.4" >> $inp4gnu
  if [ "$stype" == "em" ]
  then
    echo "set ylabel '{/Symbol G}/10^{-12}' font 'Helvetica,16'" >> $inp4gnu
  else
    echo "set ylabel '{/Symbol s}/10^{-17} cm^2' font 'Helvetica,16'" >> $inp4gnu
  fi
  echo "set ylabel offset -0.4,0" >> $inp4gnu
  echo "#set xrange [*:*]" >> $inp4gnu
  echo "set yrange [*:*]" >> $inp4gnu
  echo "set ytics font 'Helvetica,16' nomirror" >> $inp4gnu
  echo "set xtics font 'Helvetica,16' nomirror" >> $inp4gnu
  echo "set key font \"Helvetica,14\"" >> $inp4gnu
  echo "set key inside" >> $inp4gnu

  echo "set border 3" >> $inp4gnu

  echo "set style fill  transparent solid 0.50 border" >> $inp4gnu

  if [ "$stype" == "gsa" ]
  then
    echo "plot \"$dir/spectr_nm_${name}.txt\" u 1:((\$2-\$3)*1E17):((\$2+\$3)*1E17) w filledcu lw 3 lc 2 notitle, \\" >> $inp4gnu
    echo "     \"\"                             u 1:(\$2*1E17) w l lw 3 lc 2 notitle" >> $inp4gnu
  elif [ "$stype" == "st" ]
  then
    echo "plot \"$dir/spectr_nm_${name}.txt\" u 1:((\$4-\$5)*1E17):((\$4+\$5)*1E17) w filledcu lw 3 lc 2 notitle, \\" >> $inp4gnu
    echo "     \"\"                             u 1:(\$4*1E17) w l lw 3 lc 2 notitle" >> $inp4gnu
  elif [ "$stype" == "esa" ]
  then
    echo "plot \"$dir/spectr_nm_${name}.txt\" u 1:((\$6-\$7)*1E17):((\$6+\$7)*1E17) w filledcu lw 3 lc 2 notitle, \\" >> $inp4gnu
    echo "     \"\"                             u 1:(\$6*1E17) w l lw 3 lc 2 notitle" >> $inp4gnu
  elif [ "$stype" == "ta" ]
  then
    echo "plot \"$dir/spectr_nm_${name}.txt\" u 1:((\$8-\$9)*1E17):((\$8+\$9)*1E17) w filledcu lw 3 lc 2 notitle, \\" >> $inp4gnu
    echo "     \"\"                             u 1:(\$8*1E17) w l lw 3 lc 2 notitle" >> $inp4gnu
  elif [ "$stype" == "em" ]
  then
    echo "plot \"$dir/gamma_nm_spectr_${name}.txt\" u 1:((\$2-\$3)*1E12):((\$2+\$3)*1E12) w filledcu lw 3 lc 2 notitle, \\" >> $inp4gnu
    echo "     \"\"                             u 1:(\$2*1E12) w l lw 3 lc 2 notitle" >> $inp4gnu
  else
    echo "Error in 4th argument: Choose only either gsa, em, st, esa or ta!"
  fi

  # Plotting:

  echo "****************************************************"
  echo "Plotting with: gnuplot -p $inp4gnu!"
  echo "****************************************************"

  gnuplot -p $inp4gnu


fi
