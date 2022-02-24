#!/bin/bash

#if [ $# -le 1 ]
#then
#  echo "Usage:"
#  echo "./extractQM_from_car.sh {general name} {number of QM atoms}"
#else

##############################################################################
  # Variables to change:

  # Fixed variables:
  file="variables.inp"
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  #prefix="lum_wat_aminabNaH"               # project name
  QM=`grep "QM=" ../$file | sed 's/QM=//'`
  #QM="18"                                  # number of QM atoms
  name="QM_MatSt"
##############################################################################

rm -f ${name}.movie 

#count=0
for geom in `ls $prefix*.car`
do
	# QM part
#	count=$[ $count+1 ]
        echo $QM > ${name}_${geom}.xyz
	echo -e "" >> ${name}_${geom}.xyz 

	# When the solute is at the end of car:
#	tail -$[ $QM + 2 ] $geom | head -$[ $QM ] | gawk '{print $1, $2, $3, $4}' >> ${name}_${geom}.xyz
	# When the solute is at the begining of car:
	head -$[ $QM + 5 ] $geom | tail -$[ $QM ] | gawk '{print $1, $2, $3, $4}' >> ${name}_${geom}.xyz

#	rm -f g${count}_${name}.xyz.tmp  
	cat ${name}_${geom}.xyz  >> ${name}.movie 

	# Xfield part
#        nat=`head -1 ${geom} | gawk "{print \\$1}"`
#	MM=$[ $nat - $QM ]
#	echo "XField = $MM Angstrom" > g${count}_${name}.XField
#	sed -n $[ $QM + 2],$[nat + 1]p $geom | gawk '{print $3, $4, $5}' > g${count}_${name}.XField.xyz.tmp
#	sed -n $[ $QM + 2],$[nat + 1]p $geom | gawk '{print $6}' > g${count}_${name}.XField.chg.tmp
#	sed -i 's/2001/-0.834/g'  g${count}_${name}.XField.chg.tmp
#	sed -i 's/2002/0.417/g'  g${count}_${name}.XField.chg.tmp
#	gawk '{print $1, "0.0 0.0 0.0"}' g${count}_${name}.XField.chg.tmp > g${count}_${name}.XField.chg.extra.tmp
#	paste  g${count}_${name}.XField.xyz.tmp g${count}_${name}.XField.chg.extra.tmp >> g${count}_${name}.XField
#	rm -f g${count}_${name}.XField.xyz.tmp g${count}_${name}.XField.chg.tmp g${count}_${name}.XField.chg.extra.tmp
done

#fi
