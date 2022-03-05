#!/bin/bash


if [ $# != 1 ]
then
  echo "Usage: ./checklogs.sh {molcas version: 7, 8 or OM}"
  echo "Example ./cheklogs.sh OM"
else

##############################################################################
  # Variables:
  ver="$1"      # Molcas version

  file="variables.inp"
  vardir="../../"
  methodM=`grep "methodM=" $vardir/$file | sed 's/methodM=//' | sed 's/^[[:space:]]*//'`
  Nconf=`grep "Nconf=" $vardir/$file | sed 's/Nconf=//'`
  template="molcas_input.template"
##############################################################################

#rm -f g*.inp
  
  # Printing jobs termination

  outdata="checklogs.status"
  echo "-----------------------------------------------------------------" > $outdata
  echo "Status of log files for Computations ${methodM}" >> $outdata
  echo "-----------------------------------------------------------------" >> $outdata


  for conf in `seq 1 1 $Nconf`
  do
    log="g${conf}_${methodM}.log"

    if [ -e $log ]
    then
      ## for molcas7
      if [ "$ver" == "7" ]
      then
        testt="`grep -c 'Happy landing' $log`"
        if [ "$testt" == "1" ]
        then
          echo "Calculations: $log  <--- finished correctly" >> $outdata
        else
          echo "Calculations: $log  <--- ERROR" >> $outdata
        fi
      # for molcas8
      elif [ "$ver" == "8" ]
      then
        testt="`grep -c 'Special properties section' $log`"
        if [ "$testt" == "1" ]
        then
          echo "Calculations: $log  <--- finished correctly" >> $outdata
        else
          echo "Calculations: $log  <--- ERROR" >> $outdata
        fi
      # for molcas8
      elif [ "$ver" == "OM" ]
      then
        testt="`grep -c 'Special properties section' $log`"
        if [ "$testt" == "1" ]
        then
          echo "Calculations: $log  <--- finished correctly" >> $outdata
        else
          echo "Calculations: $log  <--- ERROR" >> $outdata
        fi
      fi
    else
      echo "File: $log DOES NOT EXIST!!!" >> $outdata
    fi
  done
  cat $outdata
  echo "*********************************************"
  echo "Verify also Job termination in $outdata file!"
  echo "*********************************************"

  # Verification of the Reference weights in CASPT2

  outdataWG="checklogs.refWeightsPT2"
  echo "#---------------------------------------------------------------------------------------" > $outdataWG
  echo "#Reference weights in CASPT2 for the files ${methodM}" >> $outdataWG
  echo "#---------------------------------------------------------------------------------------" >> $outdataWG

  for conf in `seq 1 1 $Nconf`
  do
    log="g${conf}_${methodM}.log"
    ref=`grep "ence weig" $log | gawk '{print $3}'`
    echo "$ref" >> $outdataWG

    # Preparing gnuplot
    inp4gnu=refweights.gnu

    echo "set terminal wxt size 800,400" > $inp4gnu
    echo "set lmargin 11" >> $inp4gnu


    echo "set xtics nomirror out" >> $inp4gnu
    echo "set ytics nomirror out" >> $inp4gnu
    echo "set encoding iso_8859_1" >> $inp4gnu
    echo "set xlabel 'Wigner geom * Nr roots' font 'Helvetica,16'" >> $inp4gnu
    echo "set xlabel offset 0,-0.4" >> $inp4gnu
    echo "set ylabel 'Ref Weight of all Roots' font 'Helvetica,16'" >> $inp4gnu
    echo "set ylabel offset -0.4,0" >> $inp4gnu
    echo "set xrange [*:*]" >> $inp4gnu
    echo "set yrange [0:1]" >> $inp4gnu
    echo "set ytics font 'Helvetica,16' nomirror" >> $inp4gnu
    echo "set xtics font 'Helvetica,16' nomirror" >> $inp4gnu
    echo "set key font \"Helvetica,14\"" >> $inp4gnu
    echo "set key inside" >> $inp4gnu

    echo "set border 3" >> $inp4gnu

    echo "set style fill  transparent solid 0.50 border" >> $inp4gnu

    echo "plot \"$outdataWG\" w linesp lc 2 notitle " >> $inp4gnu

  done

  echo "**************************************************************************************"
  echo "Verify Ref Weights of CASPT2 in $outdataWG file"
  echo "and with gnuplot -p $inp4gnu !"
  echo "**************************************************************************************"

fi
