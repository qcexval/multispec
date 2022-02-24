#!/bin/bash

#if [ $# -le 0 ]
#then
#  echo "Usage:"
#  echo "./out2incell.sh {number of QM atoms}"
#else

#name="$1"
prefix="lum_dmso_iminabNaHopt.Wigner.5ps_MtSt"
#QM="$1"
QM="18"

rm -f ${prefix}.QM.movie 

count=0
for i in {1..1}
#for i in 1
do
	geom=`ls g${i}.$prefix*.car`
        # Delete Ctrl+M 
	sed -i "s///g" ${geom}
        rm -f ${geom}.MMsel
        rm -f ${geom}.MMrad
        rm -f ${geom}.XField
	# QM part
	count=$[ $count+1 ]
        echo $QM > ${geom}.xyz
	echo -e "" >> ${geom}.xyz 
	head -$[ $QM + 5 ] $geom | tail -$[ $QM ] | gawk '{print $1, $2, $3, $4}' >> ${geom}.xyz
#	rm -f g${count}_${name}.xyz.tmp  
#	cat g${count}_${name}.xyz  >> ${name}.movie 

#       Movie QM
        gawk '{gsub(NR-2,"",$1);print}' ${geom}.xyz >> ${prefix}.QM.movie 

#       Generate several cells and print XField files
        xcell=`gawk " NR == 5 {print \\$2}" $geom`
        ycell=`gawk " NR == 5 {print \\$3}" $geom`
        zcell=`gawk " NR == 5 {print \\$4}" $geom`
#	echo $xcell
#	echo $ycell
#	echo $zcell

        nlines=`wc -l ${geom} | gawk "{print \\$1}"`

#        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $2, $3, $4, $9, "0.0 0.0 0.0"}' > ${geom}.XField
#        MM=`wc -l ${geom}.XField | gawk "{print \\$1}"`

	#Math
	xref=`tail -1 ${geom}.xyz | gawk " {print \\$2}"`
	yref=`tail -1 ${geom}.xyz | gawk " {print \\$3}"`
	zref=`tail -1 ${geom}.xyz | gawk " {print \\$4}"`

	# Get data related to the counterions 
        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "Na" && $1 ~ /^Na.*9$/ {print $2,$3,$4}' > ${geom}.MM_Na9
        MM_Na9=`wc -l ${geom}.MM_Na9 | gawk "{print \\$1}"`
	chg_Na9=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "Na" && $1 ~ /^Na.*9$/ {print $9}' | tail -1` 
	echo $chg_Na9

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "Na" && $1 ~ /^Na.*0$/ {print $2,$3,$4}' > ${geom}.MM_Na0
        MM_Na0=`wc -l ${geom}.MM_Na0 | gawk "{print \\$1}"`
	chg_Na0=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "Na" && $1 ~ /^Na.*0$/ {print $9}' | tail -1` 
	echo $chg_Na0

	# Get data related to the solvent molecules
        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "S" {print $2,$3,$4}' > ${geom}.MM_S1
        MM_S1=`wc -l ${geom}.MM_S1 | gawk "{print \\$1}"`
	chg_S1=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "S" {print $9}' | tail -1` 
	echo $chg_S1

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "O" {print $2,$3,$4}' > ${geom}.MM_O2
        MM_O2=`wc -l ${geom}.MM_O2 | gawk "{print \\$1}"`
	chg_O2=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "O" {print $9}' | tail -1` 
	echo $chg_O2

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "C" && $1 ~ /^C.*3$/ {print $2,$3,$4}' > ${geom}.MM_C3
        MM_C3=`wc -l ${geom}.MM_C3 | gawk "{print \\$1}"`
	chg_C3=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "C" && $1 ~ /^C.*3$/ {print $9}' | tail -1` 
	echo $chg_C3

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "C" && $1 ~ /^C.*4$/ {print $2,$3,$4}' > ${geom}.MM_C4
        MM_C4=`wc -l ${geom}.MM_C4 | gawk "{print \\$1}"`
	chg_C4=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "C" && $1 ~ /^C.*4$/ {print $9}' | tail -1` 
	echo $chg_C4

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" && $1 ~ /^H.*5$/ {print $2,$3,$4}' > ${geom}.MM_H5
        MM_H5=`wc -l ${geom}.MM_H5 | gawk "{print \\$1}"`
	chg_H5=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" && $1 ~ /^H.*5$/ {print $9}' | tail -1` 
	echo $chg_H5

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" && $1 ~ /^H.*6$/ {print $2,$3,$4}' > ${geom}.MM_H6
        MM_H6=`wc -l ${geom}.MM_H6 | gawk "{print \\$1}"`
	chg_H6=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" && $1 ~ /^H.*6$/ {print $9}' | tail -1` 
	echo $chg_H6

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" && $1 ~ /^H.*7$/ {print $2,$3,$4}' > ${geom}.MM_H7
        MM_H7=`wc -l ${geom}.MM_H7 | gawk "{print \\$1}"`
	chg_H7=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" && $1 ~ /^H.*7$/ {print $9}' | tail -1` 
	echo $chg_H7

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" && $1 ~ /^H.*8$/ {print $2,$3,$4}' > ${geom}.MM_H8
        MM_H8=`wc -l ${geom}.MM_H8 | gawk "{print \\$1}"`
	chg_H8=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" && $1 ~ /^H.*8$/ {print $9}' | tail -1` 
	echo $chg_H8

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" && $1 ~ /^H.*9$/ {print $2,$3,$4}' > ${geom}.MM_H9
        MM_H9=`wc -l ${geom}.MM_H9 | gawk "{print \\$1}"`
	chg_H9=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" && $1 ~ /^H.*9$/ {print $9}' | tail -1` 
	echo $chg_H9

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" && $1 ~ /^H.*0$/ {print $2,$3,$4}' > ${geom}.MM_H0
        MM_H0=`wc -l ${geom}.MM_H0 | gawk "{print \\$1}"`
	chg_H0=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" && $1 ~ /^H.*0$/ {print $9}' | tail -1` 
	echo $chg_H0

#####################################
# Loops for the counterions
#####################################
		# Counterions
          x_Na9=`gawk " NR == 1 {print \\$1}" ${geom}.MM_Na9`
          y_Na9=`gawk " NR == 1 {print \\$2}" ${geom}.MM_Na9`
          z_Na9=`gawk " NR == 1 {print \\$3}" ${geom}.MM_Na9`

          x_Na0=`gawk " NR == 1 {print \\$1}" ${geom}.MM_Na0`
          y_Na0=`gawk " NR == 1 {print \\$2}" ${geom}.MM_Na0`
          z_Na0=`gawk " NR == 1 {print \\$3}" ${geom}.MM_Na0`

###################
# Moving counterions to main cell around solute
###################
# First counterion (Na9)
###############
#Para x neg
if (( $(echo "$x_Na9 < $xref-$xcell/2" | bc -l) ))
then
   while (( $(echo "$x_Na9 < $xref-$xcell/2" | bc -l) ))
   do
	x_Na9=`bc -l <<< "$x_Na9 + $xcell"`
   done
fi
#Para x pos
if (( $(echo "$x_Na9 > $xref+$xcell/2" | bc -l) ))
then
   while (( $(echo "$x_Na9 > $xref+$xcell/2" | bc -l) ))
   do
	x_Na9=`bc -l <<< "$x_Na9 - $xcell"`
   done
fi
#Para y neg
if (( $(echo "$y_Na9 < $yref-$ycell/2" | bc -l) ))
then
   while (( $(echo "$y_Na9 < $yref-$ycell/2" | bc -l) ))
   do
	y_Na9=`bc -l <<< "$y_Na9 + $ycell"`
   done
fi
#Para y pos
if (( $(echo "$y_Na9 > $yref+$ycell/2" | bc -l) ))
then
   while (( $(echo "$y_Na9 > $yref+$ycell/2" | bc -l) ))
   do
	y_Na9=`bc -l <<< "$y_Na9 - $ycell"`
   done
fi
#Para z neg
if (( $(echo "$z_Na9 < $zref-$zcell/2" | bc -l) ))
then
   while (( $(echo "$z_Na9 < $zref-$zcell/2" | bc -l) ))
   do
	z_Na9=`bc -l <<< "$z_Na9 + $zcell"`
   done
fi
#Para z pos
if (( $(echo "$z_Na9 > $zref+$zcell/2" | bc -l) ))
then
   while (( $(echo "$z_Na9 > $zref+$zcell/2" | bc -l) ))
   do
	z_Na9=`bc -l <<< "$z_Na9 - $zcell"`
   done
fi
###################
# Second counterion (Na0)
###############
#Para x neg
if (( $(echo "$x_Na0 < $xref-$xcell/2" | bc -l) ))
then
   while (( $(echo "$x_Na0 < $xref-$xcell/2" | bc -l) ))
   do
	x_Na0=`bc -l <<< "$x_Na0 + $xcell"`
   done
fi
#Para x pos
if (( $(echo "$x_Na0 > $xref+$xcell/2" | bc -l) ))
then
   while (( $(echo "$x_Na0 > $xref+$xcell/2" | bc -l) ))
   do
	x_Na0=`bc -l <<< "$x_Na0 - $xcell"`
   done
fi
#Para y neg
if (( $(echo "$y_Na0 < $yref-$ycell/2" | bc -l) ))
then
   while (( $(echo "$y_Na0 < $yref-$ycell/2" | bc -l) ))
   do
	y_Na0=`bc -l <<< "$y_Na0 + $ycell"`
   done
fi
#Para y pos
if (( $(echo "$y_Na0 > $yref+$ycell/2" | bc -l) ))
then
   while (( $(echo "$y_Na0 > $yref+$ycell/2" | bc -l) ))
   do
	y_Na0=`bc -l <<< "$y_Na0 - $ycell"`
   done
fi
#Para z neg
if (( $(echo "$z_Na0 < $zref-$zcell/2" | bc -l) ))
then
   while (( $(echo "$z_Na0 < $zref-$zcell/2" | bc -l) ))
   do
	z_Na0=`bc -l <<< "$z_Na0 + $zcell"`
   done
fi
#Para z pos
if (( $(echo "$z_Na0 > $zref+$zcell/2" | bc -l) ))
then
   while (( $(echo "$z_Na0 > $zref+$zcell/2" | bc -l) ))
   do
	z_Na0=`bc -l <<< "$z_Na0 - $zcell"`
   done
fi

        # Getting xyz position and charge of counterions 
        echo "Na $x_Na9 $y_Na9 $z_Na9" >> ${geom}.MMrad
        echo "Na $x_Na0 $y_Na0 $z_Na0" >> ${geom}.MMrad
        echo "$x_Na9 $y_Na9 $z_Na9 $chg_Na9 0.0 0.0 0.0" >> ${geom}.XField
        echo "$x_Na0 $y_Na0 $z_Na0 $chg_Na0 0.0 0.0 0.0" >> ${geom}.XField


#####################################
# Loops for solvent
#####################################

	#for j in 1 2
	for j in `seq 1 1 $MM_S1`
	do

		# Solvent atoms
          x_S1=`gawk " NR == $j {print \\$1}" ${geom}.MM_S1`
          y_S1=`gawk " NR == $j {print \\$2}" ${geom}.MM_S1`
          z_S1=`gawk " NR == $j {print \\$3}" ${geom}.MM_S1`

          x_O2=`gawk " NR == $j {print \\$1}" ${geom}.MM_O2`
          y_O2=`gawk " NR == $j {print \\$2}" ${geom}.MM_O2`
          z_O2=`gawk " NR == $j {print \\$3}" ${geom}.MM_O2`

          x_C3=`gawk " NR == $j {print \\$1}" ${geom}.MM_C3`
          y_C3=`gawk " NR == $j {print \\$2}" ${geom}.MM_C3`
          z_C3=`gawk " NR == $j {print \\$3}" ${geom}.MM_C3`

          x_C4=`gawk " NR == $j {print \\$1}" ${geom}.MM_C4`
          y_C4=`gawk " NR == $j {print \\$2}" ${geom}.MM_C4`
          z_C4=`gawk " NR == $j {print \\$3}" ${geom}.MM_C4`

          x_H5=`gawk " NR == $j {print \\$1}" ${geom}.MM_H5`
          y_H5=`gawk " NR == $j {print \\$2}" ${geom}.MM_H5`
          z_H5=`gawk " NR == $j {print \\$3}" ${geom}.MM_H5`

          x_H6=`gawk " NR == $j {print \\$1}" ${geom}.MM_H6`
          y_H6=`gawk " NR == $j {print \\$2}" ${geom}.MM_H6`
          z_H6=`gawk " NR == $j {print \\$3}" ${geom}.MM_H6`

          x_H7=`gawk " NR == $j {print \\$1}" ${geom}.MM_H7`
          y_H7=`gawk " NR == $j {print \\$2}" ${geom}.MM_H7`
          z_H7=`gawk " NR == $j {print \\$3}" ${geom}.MM_H7`

          x_H8=`gawk " NR == $j {print \\$1}" ${geom}.MM_H8`
          y_H8=`gawk " NR == $j {print \\$2}" ${geom}.MM_H8`
          z_H8=`gawk " NR == $j {print \\$3}" ${geom}.MM_H8`

          x_H9=`gawk " NR == $j {print \\$1}" ${geom}.MM_H9`
          y_H9=`gawk " NR == $j {print \\$2}" ${geom}.MM_H9`
          z_H9=`gawk " NR == $j {print \\$3}" ${geom}.MM_H9`

          x_H0=`gawk " NR == $j {print \\$1}" ${geom}.MM_H0`
          y_H0=`gawk " NR == $j {print \\$2}" ${geom}.MM_H0`
          z_H0=`gawk " NR == $j {print \\$3}" ${geom}.MM_H0`

#	  pos_h1=$[ 2 * $j - 1]
#          x_h1=`gawk " NR == $pos_h1 {print \\$1}" ${geom}.MM_H`
#          y_h1=`gawk " NR == $pos_h1 {print \\$2}" ${geom}.MM_H`
#          z_h1=`gawk " NR == $pos_h1 {print \\$3}" ${geom}.MM_H`
#	  pos_h2=$[ 2 * $j ]
#          x_h2=`gawk " NR == $pos_h2 {print \\$1}" ${geom}.MM_H`
#          y_h2=`gawk " NR == $pos_h2 {print \\$2}" ${geom}.MM_H`
#          z_h2=`gawk " NR == $pos_h2 {print \\$3}" ${geom}.MM_H`
#	  echo "x=$x y=$y z=$z"
#	  echo "xref=$xref yref=$yref zref=$zref"


###################
# Moving solvent molecules to main cell around solute
###################
#Para x neg
if (( $(echo "$x_S1 < $xref-$xcell/2" | bc -l) ))
then
   while (( $(echo "$x_S1 < $xref-$xcell/2" | bc -l) ))
   do
	x_S1=`bc -l <<< "$x_S1 + $xcell"`
	x_O2=`bc -l <<< "$x_O2 + $xcell"`
	x_C3=`bc -l <<< "$x_C3 + $xcell"`
	x_C4=`bc -l <<< "$x_C4 + $xcell"`
	x_H5=`bc -l <<< "$x_H5 + $xcell"`
	x_H6=`bc -l <<< "$x_H6 + $xcell"`
	x_H7=`bc -l <<< "$x_H7 + $xcell"`
	x_H8=`bc -l <<< "$x_H8 + $xcell"`
	x_H9=`bc -l <<< "$x_H9 + $xcell"`
	x_H0=`bc -l <<< "$x_H0 + $xcell"`
   done
fi
#Para x pos
if (( $(echo "$x_S1 > $xref+$xcell/2" | bc -l) ))
then
   while (( $(echo "$x_S1 > $xref+$xcell/2" | bc -l) ))
   do
	x_S1=`bc -l <<< "$x_S1 - $xcell"`
	x_O2=`bc -l <<< "$x_O2 - $xcell"`
	x_C3=`bc -l <<< "$x_C3 - $xcell"`
	x_C4=`bc -l <<< "$x_C4 - $xcell"`
	x_H5=`bc -l <<< "$x_H5 - $xcell"`
	x_H6=`bc -l <<< "$x_H6 - $xcell"`
	x_H7=`bc -l <<< "$x_H7 - $xcell"`
	x_H8=`bc -l <<< "$x_H8 - $xcell"`
	x_H9=`bc -l <<< "$x_H9 - $xcell"`
	x_H0=`bc -l <<< "$x_H0 - $xcell"`
   done
fi
#Para y neg
if (( $(echo "$y_S1 < $yref-$ycell/2" | bc -l) ))
then
   while (( $(echo "$y_S1 < $yref-$ycell/2" | bc -l) ))
   do
	y_S1=`bc -l <<< "$y_S1 + $ycell"`
	y_O2=`bc -l <<< "$y_O2 + $xcell"`
	y_C3=`bc -l <<< "$y_C3 + $xcell"`
	y_C4=`bc -l <<< "$y_C4 + $xcell"`
	y_H5=`bc -l <<< "$y_H5 + $xcell"`
	y_H6=`bc -l <<< "$y_H6 + $xcell"`
	y_H7=`bc -l <<< "$y_H7 + $xcell"`
	y_H8=`bc -l <<< "$y_H8 + $xcell"`
	y_H9=`bc -l <<< "$y_H9 + $xcell"`
	y_H0=`bc -l <<< "$y_H0 + $xcell"`
   done
fi
#Para y pos
if (( $(echo "$y_S1 > $yref+$ycell/2" | bc -l) ))
then
   while (( $(echo "$y_S1 > $yref+$ycell/2" | bc -l) ))
   do
	y_S1=`bc -l <<< "$y_S1 - $ycell"`
	y_O2=`bc -l <<< "$y_O2 - $xcell"`
	y_C3=`bc -l <<< "$y_C3 - $xcell"`
	y_C4=`bc -l <<< "$y_C4 - $xcell"`
	y_H5=`bc -l <<< "$y_H5 - $xcell"`
	y_H6=`bc -l <<< "$y_H6 - $xcell"`
	y_H7=`bc -l <<< "$y_H7 - $xcell"`
	y_H8=`bc -l <<< "$y_H8 - $xcell"`
	y_H9=`bc -l <<< "$y_H9 - $xcell"`
	y_H0=`bc -l <<< "$y_H0 - $xcell"`
   done
fi
#Para z neg
if (( $(echo "$z_S1 < $zref-$zcell/2" | bc -l) ))
then
   while (( $(echo "$z_S1 < $zref-$zcell/2" | bc -l) ))
   do
	z_S1=`bc -l <<< "$z_S1 + $zcell"`
	z_O2=`bc -l <<< "$z_O2 + $xcell"`
	z_C3=`bc -l <<< "$z_C3 + $xcell"`
	z_C4=`bc -l <<< "$z_C4 + $xcell"`
	z_H5=`bc -l <<< "$z_H5 + $xcell"`
	z_H6=`bc -l <<< "$z_H6 + $xcell"`
	z_H7=`bc -l <<< "$z_H7 + $xcell"`
	z_H8=`bc -l <<< "$z_H8 + $xcell"`
	z_H9=`bc -l <<< "$z_H9 + $xcell"`
	z_H0=`bc -l <<< "$z_H0 + $xcell"`
   done
fi
#Para z pos
if (( $(echo "$z_S1 > $zref+$zcell/2" | bc -l) ))
then
   while (( $(echo "$z_S1 > $zref+$zcell/2" | bc -l) ))
   do
	z_S1=`bc -l <<< "$z_S1 - $zcell"`
	z_O2=`bc -l <<< "$z_O2 - $xcell"`
	z_C3=`bc -l <<< "$z_C3 - $xcell"`
	z_C4=`bc -l <<< "$z_C4 - $xcell"`
	z_H5=`bc -l <<< "$z_H5 - $xcell"`
	z_H6=`bc -l <<< "$z_H6 - $xcell"`
	z_H7=`bc -l <<< "$z_H7 - $xcell"`
	z_H8=`bc -l <<< "$z_H8 - $xcell"`
	z_H9=`bc -l <<< "$z_H9 - $xcell"`
	z_H0=`bc -l <<< "$z_H0 - $xcell"`
   done
fi

#echo "Final x=" $x 
#echo "Final y=" $y 
#echo "Final z=" $z 
###################

#echo "O $x $y $z" >> ${geom}.MMsel
#echo "H $x_h1 $y_h1 $z_h1" >> ${geom}.MMsel
#echo "H $x_h2 $y_h2 $z_h2" >> ${geom}.MMsel


###################
# Images of the cell
###################
	for i in -1 0 1  
	do
		for j in -1 0 1 
		do
			for k in -1 0 1 
			do
	                   x_S1rad=`bc -l <<< "$x_S1 + $i*$xcell"`
	                   y_S1rad=`bc -l <<< "$y_S1 + $j*$ycell"`
	                   z_S1rad=`bc -l <<< "$z_S1 + $k*$zcell"`
#			   echo $xrad $yrad $zrad
	                   x_O2rad=`bc -l <<< "$x_O2 + $i*$xcell"`
	                   y_O2rad=`bc -l <<< "$y_O2 + $j*$ycell"`
	                   z_O2rad=`bc -l <<< "$z_O2 + $k*$zcell"`

	                   x_C3rad=`bc -l <<< "$x_C3 + $i*$xcell"`
	                   y_C3rad=`bc -l <<< "$y_C3 + $j*$ycell"`
	                   z_C3rad=`bc -l <<< "$z_C3 + $k*$zcell"`

	                   x_C4rad=`bc -l <<< "$x_C4 + $i*$xcell"`
	                   y_C4rad=`bc -l <<< "$y_C4 + $j*$ycell"`
	                   z_C4rad=`bc -l <<< "$z_C4 + $k*$zcell"`

	                   x_H5rad=`bc -l <<< "$x_H5 + $i*$xcell"`
	                   y_H5rad=`bc -l <<< "$y_H5 + $j*$ycell"`
	                   z_H5rad=`bc -l <<< "$z_H5 + $k*$zcell"`

	                   x_H6rad=`bc -l <<< "$x_H6 + $i*$xcell"`
	                   y_H6rad=`bc -l <<< "$y_H6 + $j*$ycell"`
	                   z_H6rad=`bc -l <<< "$z_H6 + $k*$zcell"`

	                   x_H7rad=`bc -l <<< "$x_H7 + $i*$xcell"`
	                   y_H7rad=`bc -l <<< "$y_H7 + $j*$ycell"`
	                   z_H7rad=`bc -l <<< "$z_H7 + $k*$zcell"`

	                   x_H8rad=`bc -l <<< "$x_H8 + $i*$xcell"`
	                   y_H8rad=`bc -l <<< "$y_H8 + $j*$ycell"`
	                   z_H8rad=`bc -l <<< "$z_H8 + $k*$zcell"`

	                   x_H9rad=`bc -l <<< "$x_H9 + $i*$xcell"`
	                   y_H9rad=`bc -l <<< "$y_H9 + $j*$ycell"`
	                   z_H9rad=`bc -l <<< "$z_H9 + $k*$zcell"`

	                   x_H0rad=`bc -l <<< "$x_H0 + $i*$xcell"`
	                   y_H0rad=`bc -l <<< "$y_H0 + $j*$ycell"`
	                   z_H0rad=`bc -l <<< "$z_H0 + $k*$zcell"`


                          # res=`ruby -e "puts '%.2f' % Math.sqrt(($xrad-$xref)*($xrad-$xref)+($yrad-$yref)*($yrad-$yref)+($zrad-$zref)*($zrad-$zref))"`
			  #res=`bc -l <<< "$xrad-$xref"`
			  #echo $res
			  #res=`bc -l <<< "(($xrad-$xref)*($xrad-$xref)+($yrad-$yref)*($yrad-$yref)+($zrad-$zref)*($zrad-$zref))"`
			  res=$(echo "sqrt(($x_S1rad - $xref)*($x_S1rad - $xref)+($y_S1rad - $yref)*($y_S1rad - $yref)+($z_S1rad - $zref)*($z_S1rad - $zref))" | bc -l)
                           if (( $(echo "$res < 20.00" | bc -l) ))
                           then
                             echo "S $x_S1rad $y_S1rad $z_S1rad" >> ${geom}.MMrad
                             echo "O $x_O2rad $y_O2rad $z_O2rad" >> ${geom}.MMrad
                             echo "C $x_C3rad $y_C3rad $z_C3rad" >> ${geom}.MMrad
                             echo "C $x_C4rad $y_C4rad $z_C4rad" >> ${geom}.MMrad
                             echo "H $x_H5rad $y_H5rad $z_H5rad" >> ${geom}.MMrad
                             echo "H $x_H6rad $y_H6rad $z_H6rad" >> ${geom}.MMrad
                             echo "H $x_H7rad $y_H7rad $z_H7rad" >> ${geom}.MMrad
                             echo "H $x_H8rad $y_H8rad $z_H8rad" >> ${geom}.MMrad
                             echo "H $x_H9rad $y_H9rad $z_H9rad" >> ${geom}.MMrad
                             echo "H $x_H0rad $y_H0rad $z_H0rad" >> ${geom}.MMrad

                             echo "$x_S1rad $y_S1rad $z_S1rad $chg_S1 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_O2rad $y_O2rad $z_O2rad $chg_O2 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_C3rad $y_C3rad $z_C3rad $chg_C3 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_C4rad $y_C4rad $z_C4rad $chg_C4 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_H5rad $y_H5rad $z_H5rad $chg_H5 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_H6rad $y_H6rad $z_H6rad $chg_H6 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_H7rad $y_H7rad $z_H7rad $chg_H7 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_H8rad $y_H8rad $z_H8rad $chg_H8 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_H9rad $y_H9rad $z_H9rad $chg_H9 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_H0rad $y_H0rad $z_H0rad $chg_H0 0.0 0.0 0.0" >> ${geom}.XField
                           fi
                        done
                done
        done
    done

	# Preparing XField.xyz file
        n_MMXF=`wc -l ${geom}.XField | gawk "{print \\$1}"`
	echo "XField = $n_MMXF Angstrom" > ${geom}.XField.xyz
	cat ${geom}.XField >> ${geom}.XField.xyz

	# Molden geom of QM and all MM cells
        echo $[QM+n_MMXF] > ${geom}.coord4molden.xyz
	echo -e "" >> ${geom}.coord4molden.xyz 
        gawk '{gsub(NR-2,"",$1);print}' ${geom}.xyz >> ${geom}.QM.coord4molden 
        tail -$QM ${geom}.QM.coord4molden >> ${geom}.coord4molden.xyz 
        cat ${geom}.MMrad >> ${geom}.coord4molden.xyz
done

#fi
