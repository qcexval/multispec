#!/bin/bash

#if [ $# -le 0 ]
#then
#  echo "Usage:"
#  echo "./out2incell.sh {number of QM atoms}"
#else

#name="$1"
#QM="$1"

##############################################################################
  # Variables to change:

  # Fixed variables:
  Nconf=`grep "Nconf=" ../$file | sed 's/Nconf=//'`
  file="variables.inp"
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  #prefix="HgOboxH2O"
  sufix="Wigner.5ps_MtSt"
  QM=`grep "QM=" ../$file | sed 's/QM=//'`
  #QM="2"
##############################################################################

rm -f ${prefix}.${sufix}.QM.movie 

count=0
for i in `seq 1 1 $Nconf`
#for i in {80..80}
#for i in 1
do
	geom=`ls g${i}.$prefix.$sufix.car`
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
        gawk '{gsub(NR-2,"",$1);print}' ${geom}.xyz >> ${prefix}.${sufix}.QM.movie 

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

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "O" {print $2,$3,$4}' > ${geom}.MM_O
        MM_O=`wc -l ${geom}.MM_O | gawk "{print \\$1}"`
	chg_O=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "O" {print $9}' | tail -1` 
	echo $chg_O

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" {print $2,$3,$4}' > ${geom}.MM_H
        MM_H=`wc -l ${geom}.MM_H | gawk "{print \\$1}"`
	chg_H=`tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" {print $9}' | tail -1` 
	echo $chg_H

	#for j in 1 2
	for j in `seq 1 1 $MM_O`
	do
          x=`gawk " NR == $j {print \\$1}" ${geom}.MM_O`
          y=`gawk " NR == $j {print \\$2}" ${geom}.MM_O`
          z=`gawk " NR == $j {print \\$3}" ${geom}.MM_O`
	  pos_h1=$[ 2 * $j - 1]
          x_h1=`gawk " NR == $pos_h1 {print \\$1}" ${geom}.MM_H`
          y_h1=`gawk " NR == $pos_h1 {print \\$2}" ${geom}.MM_H`
          z_h1=`gawk " NR == $pos_h1 {print \\$3}" ${geom}.MM_H`
	  pos_h2=$[ 2 * $j ]
          x_h2=`gawk " NR == $pos_h2 {print \\$1}" ${geom}.MM_H`
          y_h2=`gawk " NR == $pos_h2 {print \\$2}" ${geom}.MM_H`
          z_h2=`gawk " NR == $pos_h2 {print \\$3}" ${geom}.MM_H`
#	  echo "x=$x y=$y z=$z"
#	  echo "xref=$xref yref=$yref zref=$zref"

###################
# Moving water molecules to main cell around solute
###################
#Para x neg
if (( $(echo "$x < $xref-$xcell/2" | bc -l) ))
then
   while (( $(echo "$x < $xref-$xcell/2" | bc -l) ))
   do
	x=`bc -l <<< "$x + $xcell"`
	x_h1=`bc -l <<< "$x_h1 + $xcell"`
	x_h2=`bc -l <<< "$x_h2 + $xcell"`
   done
fi
#Para x pos
if (( $(echo "$x > $xref+$xcell/2" | bc -l) ))
then
   while (( $(echo "$x > $xref+$xcell/2" | bc -l) ))
   do
	x=`bc -l <<< "$x - $xcell"`
	x_h1=`bc -l <<< "$x_h1 - $xcell"`
	x_h2=`bc -l <<< "$x_h2 - $xcell"`
   done
fi
#Para y neg
if (( $(echo "$y < $yref-$ycell/2" | bc -l) ))
then
   while (( $(echo "$y < $yref-$ycell/2" | bc -l) ))
   do
	y=`bc -l <<< "$y + $ycell"`
	y_h1=`bc -l <<< "$y_h1 + $ycell"`
	y_h2=`bc -l <<< "$y_h2 + $ycell"`
   done
fi
#Para y pos
if (( $(echo "$y > $yref+$ycell/2" | bc -l) ))
then
   while (( $(echo "$y > $yref+$ycell/2" | bc -l) ))
   do
	y=`bc -l <<< "$y - $ycell"`
	y_h1=`bc -l <<< "$y_h1 - $ycell"`
	y_h2=`bc -l <<< "$y_h2 - $ycell"`
   done
fi
#Para z neg
if (( $(echo "$z < $zref-$zcell/2" | bc -l) ))
then
   while (( $(echo "$z < $zref-$zcell/2" | bc -l) ))
   do
	z=`bc -l <<< "$z + $zcell"`
	z_h1=`bc -l <<< "$z_h1 + $zcell"`
	z_h2=`bc -l <<< "$z_h2 + $zcell"`
   done
fi
#Para z pos
if (( $(echo "$z > $zref+$zcell/2" | bc -l) ))
then
   while (( $(echo "$z > $zref+$zcell/2" | bc -l) ))
   do
	z=`bc -l <<< "$z - $zcell"`
	z_h1=`bc -l <<< "$z_h1 - $zcell"`
	z_h2=`bc -l <<< "$z_h2 - $zcell"`
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
	                   xrad=`bc -l <<< "$x + $i*$xcell"`
	                   yrad=`bc -l <<< "$y + $j*$ycell"`
	                   zrad=`bc -l <<< "$z + $k*$zcell"`
#			   echo $xrad $yrad $zrad
	                   x_h1rad=`bc -l <<< "$x_h1 + $i*$xcell"`
	                   y_h1rad=`bc -l <<< "$y_h1 + $j*$ycell"`
	                   z_h1rad=`bc -l <<< "$z_h1 + $k*$zcell"`
	                   x_h2rad=`bc -l <<< "$x_h2 + $i*$xcell"`
	                   y_h2rad=`bc -l <<< "$y_h2 + $j*$ycell"`
	                   z_h2rad=`bc -l <<< "$z_h2 + $k*$zcell"`
                          # res=`ruby -e "puts '%.2f' % Math.sqrt(($xrad-$xref)*($xrad-$xref)+($yrad-$yref)*($yrad-$yref)+($zrad-$zref)*($zrad-$zref))"`
			  #res=`bc -l <<< "$xrad-$xref"`
			  #echo $res
			  #res=`bc -l <<< "(($xrad-$xref)*($xrad-$xref)+($yrad-$yref)*($yrad-$yref)+($zrad-$zref)*($zrad-$zref))"`
			  res=$(echo "sqrt(($xrad - $xref)*($xrad - $xref)+($yrad - $yref)*($yrad - $yref)+($zrad - $zref)*($zrad - $zref))" | bc -l)
                           if (( $(echo "$res < 20.00" | bc -l) ))
                           then
                             echo "O $xrad $yrad $zrad" >> ${geom}.MMrad
                             echo "H $x_h1rad $y_h1rad $z_h1rad" >> ${geom}.MMrad
                             echo "H $x_h2rad $y_h2rad $z_h2rad" >> ${geom}.MMrad

                             echo "$xrad $yrad $zrad $chg_O 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_h1rad $y_h1rad $z_h1rad $chg_H 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_h2rad $y_h2rad $z_h2rad $chg_H 0.0 0.0 0.0" >> ${geom}.XField
                           fi
                        done
                done
        done
###################

	done

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
