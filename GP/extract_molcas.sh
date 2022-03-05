#!/bin/bash

##############################################################################################################
#
# Contents of this script:
#
# - Function extract_rassi_SO_ab
# - Function extract_rassi_SF_ab
# - Function extract_rassi_SO_em
# - Function extract_rassi_SF_em
# - Main program 
#
##############################################################################################################


function extract_rassi_SO_ab {

  rm -f tmp1 tmp2 tmp3 tmp4

  name="$1"
  Nconf=$2
  ver=$3
  absfromroot=$4
  stype=$5

  for conf in `seq 1 1 $Nconf`
  do
    log="g${conf}_${name}.log"
    out="res${conf}_${name}_SO_${stype}.dat"

    # Getting number of SO Nroots from .log file
    Nroots=`grep -a 'SO-RASSI State' $log | tail -1 | sed -e 's/State//' | gawk "// {print \\$3}"`
    totroots=`grep -a 'SO-RASSI State' $log | tail -1 | sed -e 's/State//' | gawk "// {print \\$3}"`

    # Grepping number of SO and its energy.
    # Putting two columns in temporary file ./tmp1

    num=`grep -a -n 'Rel lowest level(eV)' $log | tail -1 | cut -d":" -f 1`
    sed -n $[ num + 2],$[ num + 1 + Nroots]p $log | gawk "// {print \$1,\$3}" > tmp1
  
    # Grepping spectral properties section.
    # Putting Nroots + 30 columns in temporary file ./tmp2

    i=$absfromroot
    excnum=1   # Counting electronic transitions

    ##################################
    # Get from the log the f values
    j=$(( $i ))
    while [ "$j" -ge "$i" ] && [ "$j" -le "$totroots" ]
    do
      if [ "$ver" == "7" ]
      then
        sed -n '/++ Dipole Trans Strengths (SO states):/,/++ Total transition strengths for the second-order expansion of the wave vector (SO states)/p' $log | gawk "\$1 == $i {print \$0}" | gawk "\$2 == $j {print \$1,\$2,\$3}" >> tmp2
      elif [ "$ver" == "8" ]
      then
        sed -n '/++ Dipole transition strengths (SO states):/,/++ Total transition strengths for the second-order expansion of the wave vector (SO states)/p' $log | gawk "\$1 == $i {print \$0}" | gawk "\$2 == $j {print \$1,\$2,\$3}" >> tmp2
      elif [ "$ver" == "OM" ]
      then
        sed -n '/++ Dipole transition strengths (SO states):/,/++ Velocity transition strengths (SO states):/p' $log | gawk "\$1 == $i {print \$0}" | gawk "\$2 == $j {print \$1,\$2,\$3}" >> tmp2
      fi

      ##################################
      #Filling empty transtions with f=0.000
      dip=`gawk "\\$1 == $i {print \\$0}" tmp2 | gawk "\\$2 == $j {print \\$1,\\$2,\\$3}"`
      if [ "$dip" == "" ]
      then
        echo "$i $j 0.0000000E+00" >> tmp3
      else
        echo "$dip" >> tmp3
      fi
      ##################################
      # Calculate Delta-E
      eini=`gawk "\\$1 == $i {print \\$2}" tmp1`
      efinal=`gawk "\\$1 == $j {print \\$2}" tmp1`
      fvalue=`gawk "\\$1 == $i {print \\$0}" tmp3 | gawk "\\$2 == $j {print \\$3}"`
      #	  gawk "{print \$i,\$j,(\$efinal-\$eini)*\$ev}" >> tmp4
      #   let deltaE=($efinal-$eini)*$ev 
      # deltaE=$(( ($efinal-$eini)*$ev )) 
      # deltaE=$(( efinal*ev-eini*ev )) 
      deltaE=`echo "$efinal-$eini" | bc -l`
      echo "$excnum $i $j $deltaE $fvalue" >> tmp4
      excnum=$(( $excnum + 1))
      ##################################
      j=$(( $j + 1))
    done

    gawk '{print $1,$4,$5}' tmp4 > $out
    echo "$out ---> Done!"
    rm tmp1 tmp2 tmp3 tmp4

  done

}

function extract_rassi_SF_ab {

  rm -f tmp1 tmp2 tmp3 tmp4

  name="$1"
  Nconf=$2
  ver=$3
  absfromroot=$4
  stype=$5

  for conf in `seq 1 1 $Nconf`
  do
    log="g${conf}_${name}.log"
    out="res${conf}_${name}_SF_${stype}.dat"

    # Getting number of SF Nroots from .log file
    Nroots=`grep -a ' RASSI State' $log | tail -1 | sed -e 's/State//' | gawk "// {print \\$3}"`
    totroots=`grep -a ' RASSI State' $log | tail -1 | sed -e 's/State//' | gawk "// {print \\$3}"`

    # Grepping number of SO and its energy.
    # Putting two columns in temporary file ./tmp1

    num=`grep -a -n 'Rel lowest level(eV)' $log | head -1 | cut -d":" -f 1`
    sed -n $[ num + 2],$[ num + 1 + Nroots]p $log | gawk "// {print \$1,\$3}" > tmpord

    # Sort data of tmpord file energy wise and then copy the ordered SF in tmp1
    sort -s -n -k 1,1 tmpord > tmp1
  
    # Grepping spectral properties section.
    # Putting Nroots + 30 columns in temporary file ./tmp2

    i=$absfromroot
    excnum=1   # Counting electronic transitions

    ##################################
    # Get from the log the f values
    j=$(( $i ))
    while [ "$j" -ge "$i" ] && [ "$j" -le "$totroots" ]
    do
      if [ "$ver" == "7" ]
      then
        sed -n '/++ Dipole Trans Strengths (spin-free states):/,/++ Total transition strengths for the second-order expansion of the wave vector (spin-free states)/p' $log | gawk "\$1 == $i {print \$0}" | gawk "\$2 == $j {print \$1,\$2,\$3}" >> tmp2
      elif [ "$ver" == "8" ]
      then
        sed -n '/++ Dipole transition strengths (spin-free states):/,/++ Total transition strengths for the second-order expansion of the wave vector (spin-free states)/p' $log | gawk "\$1 == $i {print \$0}" | gawk "\$2 == $j {print \$1,\$2,\$3}" >> tmp2
      elif [ "$ver" == "OM" ]
      then
        sed -n '/++ Dipole transition strengths (spin-free states):/,/++ Velocity transition strengths (spin-free states):/p' $log | gawk "\$1 == $i {print \$0}" | gawk "\$2 == $j {print \$1,\$2,\$3}" >> tmp2
      fi

      ##################################
      #Filling empty transtions with f=0.000
      dip=`gawk "\\$1 == $i {print \\$0}" tmp2 | gawk "\\$2 == $j {print \\$1,\\$2,\\$3}"`
      if [ "$dip" == "" ]
      then
        echo "$i $j 0.0000000E+00" >> tmp3
      else
        echo "$dip" >> tmp3
      fi
      ##################################
      # Calculate Delta-E
      eini=`gawk "\\$1 == $i {print \\$2}" tmp1`
      #eini=`gawk "NR == $i {print \\$2}" tmp1`
      efinal=`gawk "\\$1 == $j {print \\$2}" tmp1`
      #efinal=`gawk "NR == $j {print \\$2}" tmp1`
      fvalue=`gawk "\\$1 == $i {print \\$0}" tmp3 | gawk "\\$2 == $j {print \\$3}"`
      #  gawk "{print \$i,\$j,(\$efinal-\$eini)*\$ev}" >> tmp4
      #  let deltaE=($efinal-$eini)*$ev 
      # deltaE=$(( ($efinal-$eini)*$ev )) 
      # deltaE=$(( efinal*ev-eini*ev )) 
      deltaE=`echo "$efinal-$eini" | bc -l`
      echo "$excnum $i $j $deltaE $fvalue" >> tmp4
      excnum=$(( $excnum + 1))
      ##################################
      j=$(( $j + 1))

    done
 
    gawk '{print $1,$4,$5}' tmp4 > $out
    echo "$out ---> Done!"
    rm tmp1 tmp2 tmp3 tmp4

  done

}

function extract_rassi_SO_em {

  rm -f tmp1 tmp2 tmp3 tmp4

  name="$1"
  Nconf=$2
  ver=$3
  emfromroot=$4
  stype=$5

  for conf in `seq 1 1 $Nconf`
  do
    log="g${conf}_${name}.log"
    out="res${conf}_${name}_SO_${stype}.dat"

    # Getting number of SO Nroots from .log file
    Nroots=`grep -a 'SO-RASSI State' $log | tail -1 | sed -e 's/State//' | gawk "// {print \\$3}"`
    totroots=`grep -a 'SO-RASSI State' $log | tail -1 | sed -e 's/State//' | gawk "// {print \\$3}"`

    # Grepping number of SO and its energy.
    # Putting two columns in temporary file ./tmp1

    num=`grep -a -n 'Rel lowest level(eV)' $log | tail -1 | cut -d":" -f 1`
    sed -n $[ num + 2],$[ num + 1 + Nroots]p $log | gawk "// {print \$1,\$3}" > tmp1
  
    # Grepping spectral properties section.
    # Putting Nroots + 30 columns in temporary file ./tmp2

    i=$emfromroot
    excnum=1   # Counting electronic transitions

    ##################################
    # Get from the log the f values
    j=1
    while [ "$j" -le "$i" ] 
    do
      if [ "$ver" == "7" ]
      then
        sed -n '/++ Dipole Trans Strengths (SO states):/,/++ Total transition strengths for the second-order expansion of the wave vector (SO states)/p' $log | gawk "\$1 == $j {print \$0}" | gawk "\$2 == $i {print \$2,\$1,\$3}" >> tmp2
      elif [ "$ver" == "8" ]
      then
        sed -n '/++ Dipole transition strengths (SO states):/,/++ Total transition strengths for the second-order expansion of the wave vector (SO states)/p' $log | gawk "\$1 == $j {print \$0}" | gawk "\$2 == $i {print \$2,\$1,\$3}" >> tmp2
      elif [ "$ver" == "OM" ]
      then
        sed -n '/++ Dipole transition strengths (SO states):/,/++ Velocity transition strengths (SO states):/p' $log | gawk "\$1 == $j {print \$0}" | gawk "\$2 == $i {print \$2,\$1,\$3}" >> tmp2
      fi

      ##################################
      #Filling empty transtions with f=0.000
      dip=`gawk "\\$1 == $i {print \\$0}" tmp2 | gawk "\\$2 == $j {print \\$1,\\$2,\\$3}"`
      if [ "$dip" == "" ]
      then
        echo "$i $j 0.0000000E+00" >> tmp3
      else
        echo "$dip" >> tmp3
      fi
      ##################################
      # Calculate Delta-E
      efinal=`gawk "\\$1 == $i {print \\$2}" tmp1`
      eini=`gawk "\\$1 == $j {print \\$2}" tmp1`
      fvalue=`gawk "\\$1 == $i {print \\$0}" tmp3 | gawk "\\$2 == $j {print \\$3}"`
      #	  gawk "{print \$i,\$j,(\$efinal-\$eini)*\$ev}" >> tmp4
      #   let deltaE=($efinal-$eini)*$ev 
      # deltaE=$(( ($efinal-$eini)*$ev )) 
      # deltaE=$(( efinal*ev-eini*ev )) 
      deltaE=`echo "$efinal-$eini" | bc -l`
      echo "$excnum $i $j $deltaE $fvalue" >> tmp4
      excnum=$(( $excnum + 1))
      ##################################
      j=$(( $j + 1))
    done

    gawk '{print $1,$4,$5}' tmp4 > $out
    echo "$out ---> Done!"
    rm tmp1 tmp2 tmp3 tmp4

  done

}

function extract_rassi_SF_em {

  rm -f tmp1 tmp2 tmp3 tmp4

  name="$1"
  Nconf=$2
  ver=$3
  emfromroot=$4
  stype=$5

  for conf in `seq 1 1 $Nconf`
  do
    log="g${conf}_${name}.log"
    out="res${conf}_${name}_SF_${stype}.dat"

    # Getting number of SF Nroots from .log file
    Nroots=`grep -a ' RASSI State' $log | tail -1 | sed -e 's/State//' | gawk "// {print \\$3}"`
    totroots=`grep -a ' RASSI State' $log | tail -1 | sed -e 's/State//' | gawk "// {print \\$3}"`

    # Grepping number of SO and its energy.
    # Putting two columns in temporary file ./tmp1

    num=`grep -a -n 'Rel lowest level(eV)' $log | head -1 | cut -d":" -f 1`
    sed -n $[ num + 2],$[ num + 1 + Nroots]p $log | gawk "// {print \$1,\$3}" > tmpord

    # Sort data of tmpord file energy wise and then copy the ordered SF in tmp1
    sort -s -n -k 1,1 tmpord > tmp1
  
    # Grepping spectral properties section.
    # Putting Nroots + 30 columns in temporary file ./tmp2

    i=$emfromroot
    excnum=1   # Counting electronic transitions

    ##################################
    # Get from the log the f values
    j=1
    while [ "$j" -le "$i" ] 
    do
      if [ "$ver" == "7" ]
      then
        sed -n '/++ Dipole Trans Strengths (spin-free states):/,/++ Total transition strengths for the second-order expansion of the wave vector (spin-free states)/p' $log | gawk "\$1 == $j {print \$0}" | gawk "\$2 == $i {print \$2,\$1,\$3}" >> tmp2
      elif [ "$ver" == "8" ]
      then
        sed -n '/++ Dipole transition strengths (spin-free states):/,/++ Total transition strengths for the second-order expansion of the wave vector (spin-free states)/p' $log | gawk "\$1 == $j {print \$0}" | gawk "\$2 == $i {print \$2,\$1,\$3}" >> tmp2
      elif [ "$ver" == "OM" ]
      then
        sed -n '/++ Dipole transition strengths (spin-free states):/,/++ Velocity transition strengths (spin-free states):/p' $log | gawk "\$1 == $j {print \$0}" | gawk "\$2 == $i {print \$2,\$1,\$3}" >> tmp2
      fi

      ##################################
      #Filling empty transtions with f=0.000
      dip=`gawk "\\$1 == $i {print \\$0}" tmp2 | gawk "\\$2 == $j {print \\$1,\\$2,\\$3}"`
      if [ "$dip" == "" ]
      then
        echo "$i $j 0.0000000E+00" >> tmp3
      else
        echo "$dip" >> tmp3
      fi
      ##################################
      # Calculate Delta-E
      efinal=`gawk "\\$1 == $i {print \\$2}" tmp1`
      #eini=`gawk "NR == $i {print \\$2}" tmp1`
      eini=`gawk "\\$1 == $j {print \\$2}" tmp1`
      #efinal=`gawk "NR == $j {print \\$2}" tmp1`
      fvalue=`gawk "\\$1 == $i {print \\$0}" tmp3 | gawk "\\$2 == $j {print \\$3}"`
      #  gawk "{print \$i,\$j,(\$efinal-\$eini)*\$ev}" >> tmp4
      #  let deltaE=($efinal-$eini)*$ev 
      # deltaE=$(( ($efinal-$eini)*$ev )) 
      # deltaE=$(( efinal*ev-eini*ev )) 
      deltaE=`echo "$efinal-$eini" | bc -l`
      echo "$excnum $i $j $deltaE $fvalue" >> tmp4
      excnum=$(( $excnum + 1))
      ##################################
      j=$(( $j + 1))

    done
 
    gawk '{print $1,$4,$5}' tmp4 > $out
    echo "$out ---> Done!"
    rm tmp1 tmp2 tmp3 tmp4

  done

}

#####################################################################################################################
#
# The SCRIPT begins here
#
#####################################################################################################################

if [ $# != 4 ]
then
  echo "Usage: ./extract_molcas_SF.sh {SF or SO} {molcas version: 7, 8 or OM} {gsa, em, esa} {starting root}"
  echo "Example: ./extract_molcas.sh SF OM gsa 1"
  echo "Info: gsa = ground-state absorption (normally starting root is 1)"
  echo "      em  = spontaneous emission (normally starting root is 2) "
  echo "      esa = excited-state absorption (normally starting root is 2)"
else
  ##############################################################################
  # Variables:
  spin="$1"
  ver="$2"      # Molcas version
  stype="$3"
  stroot="$4"

  file="variables.inp"
  vardir="../../"
  methodM=`grep "methodM=" $vardir/$file | sed 's/methodM=//' | sed 's/^[[:space:]]*//'`
  #methodM=caspt2_6in5_anorccvdzp_5s_4t
  Nconf=`grep "Nconf=" $vardir/$file | sed 's/Nconf=//'`
  #Nconf=10
  ##############################################################################

  error=0

  for conf in `seq 1 1 $Nconf`
  do
    log="g${conf}_${methodM}.log"
    if [ -e $log ]
    then
      error=0
    else
      echo "File: $log DOES NOT EXIST!!!"
      error=1
    fi
  done

  if [ $error == 1 ]
  then
    echo "Exiting!!!"
  else
    if [ $spin == "SF" ]
    then
      if [ $stype == "gsa" ] || [ $stype == "esa" ]
      then
        extract_rassi_SF_ab $methodM $Nconf $ver $stroot $stype
      elif [ $stype == "em" ]
      then
        extract_rassi_SF_em $methodM $Nconf $ver $stroot $stype
      else
        echo "Error in 3rd argument: Choose only either gsa, em or esa!"
      fi
    elif [ $spin == "SO" ]
    then
      if [ $stype == "gsa" ] || [ $stype == "esa" ]
      then
        extract_rassi_SO_ab $methodM $Nconf $ver $stroot $stype
      elif [ $stype == "em" ]
      then
        extract_rassi_SO_em $methodM $Nconf $ver $stroot $stype
      else
        echo "Error in 3rd argument: Choose only either gsa, em or esa!"
      fi
    else
      echo "Error in 1st argument: Choose only either SF or SO!"
    fi
  fi
fi
