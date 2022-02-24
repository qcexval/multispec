#!/bin/bash

function extract_rassi_SF
{
name="$1"
Nconf=$2
ver=$3
for conf in `seq 1 1 $Nconf`
do
  log="g${conf}_${name}.log"
  out="res${conf}_${name}.SF.dat"

  # Getting number of SF Nroots from .log file
  Nroots=`grep -a '   RASSI State' $log | tail -1 | sed -e 's/State//' | gawk "// {print \\$3}"`

  # Grepping number of SF and its energy.
  # Putting two columns in temporary file ./tmp1

  num=`grep -a -n 'Rel lowest level(eV)' $log | head -1 | cut -d":" -f 1`
  sed -n $[ num + 2],$[ num + 1 + Nroots]p $log | gawk "// {print \$1,\$3}" > tmp1
  
  # Grepping spectral properties section.
  # Putting Nroots + 30 columns in temporary file ./tmp2


  if [ "$ver" == "7" ]
  then
    grep -a -A $[ Nroots + 30 ] 'Dipole Trans Strengths' $log | gawk "/  1 /" >tmp2
  elif [ "$ver" == "8" ]
  then
    grep -a -A $[ Nroots + 30 ] 'Dipole transition strengths:' $log | gawk "/  1 /" >tmp2
  fi
  # Adding f=0.00000 for the transitions not listed
  # in special properties section. This is the security
  # for molcas8.
  # Putting one column in temporary file ./tmp3

  (
  echo "0.0000000E+00"  # for the ground state No 1
  for i in `seq 2 1 $Nroots`
  do
          dip=`gawk "/ $i / {print \\$3}" tmp2`
          if [ "$dip" == "" ]
          then
                  echo "0.0000000E+00"
          else
                  echo "$dip"
          fi
  done
  ) > tmp3

# Merging two files tmp1 and tmp3
# gives final resXXX_SF.dat file,
# containing 3 columns:
# Nstate dEne(eV) f
# Ready for semiclassical.x program
  paste tmp1 tmp3 > $out
done
rm tmp1 tmp2 tmp3
}

#if [ $# != 4 ]
#then
#  echo "Usage:"
#  echo "./extract_molcas.sh {general_name} {method} {number of files} {molcas version}"
#else
##############################################################################
  # Variables to change:
  ver=8      # Molcas version

  # Fixed variables:
  file="variables.inp"
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  method=`grep "method=" generate_inps_molcas.sh | sed 's/method=//' | sed 's/^[[:space:]]*//'`
  #prefix="HgOboxH2O"
  #Nconf=`grep "Nconf=" ../$file | sed 's/Nconf=//'`
  Nconf="100"
  sufix=WignerQM
  name=${prefix}.${sufix}_${method}
#template="molcas_routine_mp2_cs"
##############################################################################

  error=0
  for conf in `seq 1 1 $Nconf`
  do
  log="g${conf}_${prefix}.${sufix}_${method}.log"
  #  log="g${conf}_${name}_${method}.log"
    if [ -e $log ]
    then
## for molcas7
      if [ "$ver" == "7" ]
      then
        testt="`grep -c 'Happy landing' $log`"
        if [ "$testt" == "1" ]
        then
          echo "Calculations: $log  <--- finished correctly"
        else
          echo "Calculations: $log  <--- ERROR"
        fi
# for molcas8
      elif [ "$ver" == "8" ]
      then
        testt="`grep -c 'Special properties section' $log`"
        if [ "$testt" == "1" ]
        then
          echo "Calculations: $log  <--- finished correctly"
        else
          echo "Calculations: $log  <--- ERROR"
        fi
      fi
    else
      echo "File: $log DOES NOT EXIST!!!"
      error=1
    fi
  done
  if [ $error == 1 ]
  then
    echo "Exiting!!!"
  else
    extract_rassi_SF $name $Nconf $ver
  fi
#fi
