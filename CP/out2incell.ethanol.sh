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
  #Nconf=`grep "Nconf=" ../$file | sed 's/Nconf=//'`
  Nconf=1
  file="variables.inp"
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  #prefix="HgOboxH2O"
  sufix="Wigner.5ps_MtSt"
  QM=`grep "QM=" ../$file | sed 's/QM=//'`
  #QM="2"
##############################################################################

rm -f ${prefix}.${sufix}.QM.movie 

# Charges of ethanol obtained from Mat Studio using UFF 
chg_c1=-0.334   
chg_c2=-0.002
chg_o=-0.773
chg_h1=0.167
chg_h2=0.086
chg_h3=0.174
chg_h4=0.181
chg_h5=0.153
chg_h6=0.349
########################################################

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

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "C" {print $2,$3,$4}' > ${geom}.MM_C
        MM_C=`wc -l ${geom}.MM_C | gawk "{print \\$1}"`

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "O" {print $2,$3,$4}' > ${geom}.MM_O
        MM_O=`wc -l ${geom}.MM_O | gawk "{print \\$1}"`

        tail -$[ $nlines - 5 - $QM ] ${geom} | gawk ' /XXXX/ {print $0}' | gawk ' $8 == "H" {print $2,$3,$4}' > ${geom}.MM_H
        MM_H=`wc -l ${geom}.MM_H | gawk "{print \\$1}"`

	#for j in 1 2
	for j in `seq 1 1 $MM_O`
	do
          x=`gawk " NR == $j {print \\$1}" ${geom}.MM_O`
          y=`gawk " NR == $j {print \\$2}" ${geom}.MM_O`
          z=`gawk " NR == $j {print \\$3}" ${geom}.MM_O`

	  pos_c1=$[ 2 * $j - 1]
          x_c1=`gawk " NR == $pos_c1 {print \\$1}" ${geom}.MM_C`
          y_c1=`gawk " NR == $pos_c1 {print \\$2}" ${geom}.MM_C`
          z_c1=`gawk " NR == $pos_c1 {print \\$3}" ${geom}.MM_C`

	  pos_c2=$[ 2 * $j ]
          x_c2=`gawk " NR == $pos_c2 {print \\$1}" ${geom}.MM_C`
          y_c2=`gawk " NR == $pos_c2 {print \\$2}" ${geom}.MM_C`
          z_c2=`gawk " NR == $pos_c2 {print \\$3}" ${geom}.MM_C`

	  pos_h1=$[ 6 * $j - 5]
          x_h1=`gawk " NR == $pos_h1 {print \\$1}" ${geom}.MM_H`
          y_h1=`gawk " NR == $pos_h1 {print \\$2}" ${geom}.MM_H`
          z_h1=`gawk " NR == $pos_h1 {print \\$3}" ${geom}.MM_H`

	  pos_h2=$[ 6 * $j - 4]
          x_h2=`gawk " NR == $pos_h2 {print \\$1}" ${geom}.MM_H`
          y_h2=`gawk " NR == $pos_h2 {print \\$2}" ${geom}.MM_H`
          z_h2=`gawk " NR == $pos_h2 {print \\$3}" ${geom}.MM_H`

	  pos_h3=$[ 6 * $j - 3]
          x_h3=`gawk " NR == $pos_h3 {print \\$1}" ${geom}.MM_H`
          y_h3=`gawk " NR == $pos_h3 {print \\$2}" ${geom}.MM_H`
          z_h3=`gawk " NR == $pos_h3 {print \\$3}" ${geom}.MM_H`

	  pos_h4=$[ 6 * $j - 2]
          x_h4=`gawk " NR == $pos_h4 {print \\$1}" ${geom}.MM_H`
          y_h4=`gawk " NR == $pos_h4 {print \\$2}" ${geom}.MM_H`
          z_h4=`gawk " NR == $pos_h4 {print \\$3}" ${geom}.MM_H`

	  pos_h5=$[ 6 * $j - 1]
          x_h5=`gawk " NR == $pos_h5 {print \\$1}" ${geom}.MM_H`
          y_h5=`gawk " NR == $pos_h5 {print \\$2}" ${geom}.MM_H`
          z_h5=`gawk " NR == $pos_h5 {print \\$3}" ${geom}.MM_H`

	  pos_h6=$[ 6 * $j ]
          x_h6=`gawk " NR == $pos_h6 {print \\$1}" ${geom}.MM_H`
          y_h6=`gawk " NR == $pos_h6 {print \\$2}" ${geom}.MM_H`
          z_h6=`gawk " NR == $pos_h6 {print \\$3}" ${geom}.MM_H`

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
	x_c1=`bc -l <<< "$x_c1 + $xcell"`
	x_c2=`bc -l <<< "$x_c2 + $xcell"`
	x_h1=`bc -l <<< "$x_h1 + $xcell"`
	x_h2=`bc -l <<< "$x_h2 + $xcell"`
	x_h3=`bc -l <<< "$x_h3 + $xcell"`
	x_h4=`bc -l <<< "$x_h4 + $xcell"`
	x_h5=`bc -l <<< "$x_h5 + $xcell"`
	x_h6=`bc -l <<< "$x_h6 + $xcell"`
   done
fi
#Para x pos
if (( $(echo "$x > $xref+$xcell/2" | bc -l) ))
then
   while (( $(echo "$x > $xref+$xcell/2" | bc -l) ))
   do
	x=`bc -l <<< "$x - $xcell"`
	x_c1=`bc -l <<< "$x_c1 - $xcell"`
	x_c2=`bc -l <<< "$x_c2 - $xcell"`
	x_h1=`bc -l <<< "$x_h1 - $xcell"`
	x_h2=`bc -l <<< "$x_h2 - $xcell"`
	x_h3=`bc -l <<< "$x_h3 - $xcell"`
	x_h4=`bc -l <<< "$x_h4 - $xcell"`
	x_h5=`bc -l <<< "$x_h5 - $xcell"`
	x_h6=`bc -l <<< "$x_h6 - $xcell"`
   done
fi
#Para y neg
if (( $(echo "$y < $yref-$ycell/2" | bc -l) ))
then
   while (( $(echo "$y < $yref-$ycell/2" | bc -l) ))
   do
	y=`bc -l <<< "$y + $ycell"`
	y_c1=`bc -l <<< "$y_c1 + $ycell"`
	y_c2=`bc -l <<< "$y_c2 + $ycell"`
	y_h1=`bc -l <<< "$y_h1 + $ycell"`
	y_h2=`bc -l <<< "$y_h2 + $ycell"`
	y_h3=`bc -l <<< "$y_h3 + $ycell"`
	y_h4=`bc -l <<< "$y_h4 + $ycell"`
	y_h5=`bc -l <<< "$y_h5 + $ycell"`
	y_h6=`bc -l <<< "$y_h6 + $ycell"`
   done
fi
#Para y pos
if (( $(echo "$y > $yref+$ycell/2" | bc -l) ))
then
   while (( $(echo "$y > $yref+$ycell/2" | bc -l) ))
   do
	y=`bc -l <<< "$y - $ycell"`
	y_c1=`bc -l <<< "$y_c1 - $ycell"`
	y_c2=`bc -l <<< "$y_c2 - $ycell"`
	y_h1=`bc -l <<< "$y_h1 - $ycell"`
	y_h2=`bc -l <<< "$y_h2 - $ycell"`
	y_h3=`bc -l <<< "$y_h3 - $ycell"`
	y_h4=`bc -l <<< "$y_h4 - $ycell"`
	y_h5=`bc -l <<< "$y_h5 - $ycell"`
	y_h6=`bc -l <<< "$y_h6 - $ycell"`
   done
fi
#Para z neg
if (( $(echo "$z < $zref-$zcell/2" | bc -l) ))
then
   while (( $(echo "$z < $zref-$zcell/2" | bc -l) ))
   do
	z=`bc -l <<< "$z + $zcell"`
	z_c1=`bc -l <<< "$z_c1 + $zcell"`
	z_c2=`bc -l <<< "$z_c2 + $zcell"`
	z_h1=`bc -l <<< "$z_h1 + $zcell"`
	z_h2=`bc -l <<< "$z_h2 + $zcell"`
	z_h3=`bc -l <<< "$z_h3 + $zcell"`
	z_h4=`bc -l <<< "$z_h4 + $zcell"`
	z_h5=`bc -l <<< "$z_h5 + $zcell"`
	z_h6=`bc -l <<< "$z_h6 + $zcell"`
   done
fi
#Para z pos
if (( $(echo "$z > $zref+$zcell/2" | bc -l) ))
then
   while (( $(echo "$z > $zref+$zcell/2" | bc -l) ))
   do
	z=`bc -l <<< "$z - $zcell"`
	z_c1=`bc -l <<< "$z_c1 - $zcell"`
	z_c2=`bc -l <<< "$z_c2 - $zcell"`
	z_h1=`bc -l <<< "$z_h1 - $zcell"`
	z_h2=`bc -l <<< "$z_h2 - $zcell"`
	z_h3=`bc -l <<< "$z_h3 - $zcell"`
	z_h4=`bc -l <<< "$z_h4 - $zcell"`
	z_h5=`bc -l <<< "$z_h5 - $zcell"`
	z_h6=`bc -l <<< "$z_h6 - $zcell"`
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
	                   x_c1rad=`bc -l <<< "$x_c1 + $i*$xcell"`
	                   y_c1rad=`bc -l <<< "$y_c1 + $j*$ycell"`
	                   z_c1rad=`bc -l <<< "$z_c1 + $k*$zcell"`
	                   x_c2rad=`bc -l <<< "$x_c2 + $i*$xcell"`
	                   y_c2rad=`bc -l <<< "$y_c2 + $j*$ycell"`
	                   z_c2rad=`bc -l <<< "$z_c2 + $k*$zcell"`

	                   x_h1rad=`bc -l <<< "$x_h1 + $i*$xcell"`
	                   y_h1rad=`bc -l <<< "$y_h1 + $j*$ycell"`
	                   z_h1rad=`bc -l <<< "$z_h1 + $k*$zcell"`
	                   x_h2rad=`bc -l <<< "$x_h2 + $i*$xcell"`
	                   y_h2rad=`bc -l <<< "$y_h2 + $j*$ycell"`
	                   z_h2rad=`bc -l <<< "$z_h2 + $k*$zcell"`
	                   x_h3rad=`bc -l <<< "$x_h3 + $i*$xcell"`
	                   y_h3rad=`bc -l <<< "$y_h3 + $j*$ycell"`
	                   z_h3rad=`bc -l <<< "$z_h3 + $k*$zcell"`
	                   x_h4rad=`bc -l <<< "$x_h4 + $i*$xcell"`
	                   y_h4rad=`bc -l <<< "$y_h4 + $j*$ycell"`
	                   z_h4rad=`bc -l <<< "$z_h4 + $k*$zcell"`
	                   x_h5rad=`bc -l <<< "$x_h5 + $i*$xcell"`
	                   y_h5rad=`bc -l <<< "$y_h5 + $j*$ycell"`
	                   z_h5rad=`bc -l <<< "$z_h5 + $k*$zcell"`
	                   x_h6rad=`bc -l <<< "$x_h6 + $i*$xcell"`
	                   y_h6rad=`bc -l <<< "$y_h6 + $j*$ycell"`
	                   z_h6rad=`bc -l <<< "$z_h6 + $k*$zcell"`
                          # res=`ruby -e "puts '%.2f' % Math.sqrt(($xrad-$xref)*($xrad-$xref)+($yrad-$yref)*($yrad-$yref)+($zrad-$zref)*($zrad-$zref))"`
			  #res=`bc -l <<< "$xrad-$xref"`
			  #echo $res
			  #res=`bc -l <<< "(($xrad-$xref)*($xrad-$xref)+($yrad-$yref)*($yrad-$yref)+($zrad-$zref)*($zrad-$zref))"`
			  res=$(echo "sqrt(($xrad - $xref)*($xrad - $xref)+($yrad - $yref)*($yrad - $yref)+($zrad - $zref)*($zrad - $zref))" | bc -l)
                           if (( $(echo "$res < 20.00" | bc -l) ))
                           then
                             echo "O $xrad $yrad $zrad" >> ${geom}.MMrad

                             echo "C $x_c1rad $y_c1rad $z_c1rad" >> ${geom}.MMrad
                             echo "C $x_c2rad $y_c2rad $z_c2rad" >> ${geom}.MMrad

                             echo "H $x_h1rad $y_h1rad $z_h1rad" >> ${geom}.MMrad
                             echo "H $x_h2rad $y_h2rad $z_h2rad" >> ${geom}.MMrad
                             echo "H $x_h3rad $y_h3rad $z_h3rad" >> ${geom}.MMrad
                             echo "H $x_h4rad $y_h4rad $z_h4rad" >> ${geom}.MMrad
                             echo "H $x_h5rad $y_h5rad $z_h5rad" >> ${geom}.MMrad
                             echo "H $x_h6rad $y_h6rad $z_h6rad" >> ${geom}.MMrad

                             echo "$xrad $yrad $zrad $chg_o 0.0 0.0 0.0" >> ${geom}.XField

                             echo "$x_c1rad $y_c1rad $z_c1rad $chg_c1 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_c2rad $y_c2rad $z_c2rad $chg_c2 0.0 0.0 0.0" >> ${geom}.XField

                             echo "$x_h1rad $y_h1rad $z_h1rad $chg_h1 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_h2rad $y_h2rad $z_h2rad $chg_h2 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_h3rad $y_h3rad $z_h3rad $chg_h3 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_h4rad $y_h4rad $z_h4rad $chg_h4 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_h5rad $y_h5rad $z_h5rad $chg_h5 0.0 0.0 0.0" >> ${geom}.XField
                             echo "$x_h6rad $y_h6rad $z_h6rad $chg_h6 0.0 0.0 0.0" >> ${geom}.XField
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
