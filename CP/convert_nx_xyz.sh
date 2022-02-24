#!/bin/bash


##############################################################################
  # Variables to change:

  # Fixed variables:
  file="variables.inp"
  fileNXgeoms="final_output"
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  file4f90="variables4f90.inp"
  Nconf=`grep "Nconf=" ../$file | sed "s/Nconf=//"`
  nameNX="$prefix.WignerQM"
  #prefix="lum_wat_aminabNaH"               # project name
  QM=`grep "QM=" ../$file | sed 's/QM=//'`
  QMall=`grep "numat =" initqp_input | sed 's/numat =//'`
  #QM="18"                                  # number of QM atoms
  name="QM_MatSt"
##############################################################################

echo "$fileNXgeoms" > $file4f90 
echo "$QMall" >> $file4f90 
echo "$Nconf" >> $file4f90 
echo "$nameNX" >> $file4f90 

./convert_nx_xyz.x 

for conf in `seq 1 1 $Nconf`
do
	./rm_explicitSOL.sh g${conf}_${nameNX}.xyz $QM  
	./xyz2xyznum.sh   g${conf}_${nameNX}.NOsol.xyz 

done

