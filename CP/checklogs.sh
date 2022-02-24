#!/bin/bash

#-----
# template - template file with all the CASSCF/MS-CASPT2/RASSI routines. Edit it for particular type of 
#	     calculations!!!
# Nconf    - number of geometry files
# name	   - general name of the geometry files (gX_name.xyz)
# method   - method of usage (only for the naming of .inp files)
#---

#(echo "$NSYM";echo " 10 10 10 10 5.0d0") | ./a.out
#if [ $# -le 0 ]
#then
#  echo "Usage:"
#  echo "./generate_inps_molcas.sh {number of geometries} {molcas input template} "
#  echo "Example ./generate_inps_molcas.sh 100 molcas_input.template "
#else

#name="$1"

##############################################################################
  # Variables to change:
  ver=8      # Molcas version

  # Fixed variables:
  file="variables.inp"
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  method=`grep "method=" generate_inps_molcas.sh | sed 's/method=//' | sed 's/^[[:space:]]*//'`
  #prefix="HgOboxH2O"
  Nconf=`grep "Nconf=" ../$file | sed 's/Nconf=//'`
  #Nconf="1"
  sufix="Wigner.5ps_MtSt"
  template="molcas_input.template"
#template="molcas_routine_mp2_cs"
##############################################################################

#rm -f g*.inp

outdata="checklogs"
echo "-----------------------------------------------------------------" > $outdata
echo "Status of log files for Computations ${prefix}.${sufix}_${method}" >> $outdata
echo "-----------------------------------------------------------------" >> $outdata

for conf in `seq 1 1 $Nconf`
do
  log="g${conf}_${prefix}.${sufix}_${method}.log"

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
      fi
    else
      echo "File: $log DOES NOT EXIST!!!" >> $outdata
    fi
done

#fi
