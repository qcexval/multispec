#!/bin/bash

#usage
#g0 - initial geom
#gt - final geom
#nod - qcexnodNOD

#if [ $# != 4 ]
#then
#        echo "wrong usage"
#      #  echo "./send_queue.sh {general name} {method} {initial geom} {node}"
#        echo "./send_queue.sh {general name} {method} {num geoms} {jobs per node}"
#else

##############################################################################
  # Variables to change:
  iniconf=41                               # initial geom to calculate
  numconf=10                               # num geoms to calculate
  jxnod="2"                                # jobs per node

  # Fixed variables:
  file="variables.inp"
  method=`grep "method=" generate_inps_molcas.sh | sed 's/method=//' | sed 's/^[[:space:]]*//'`
  #method="cas16in12_vtzp_32sa_7ms"         # method
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
#  prefix="HgOboxH2O"
  sufix=WignerQM
  name="${prefix}.${sufix}"
##############################################################################

  totcyc=$[ $numconf / $jxnod ]
#  echo $totcyc

  for i in `seq 1 1 $totcyc`
  do

  g0=$[$iniconf + $jxnod * $i - $jxnod ]
  gt=$[$iniconf + $i * $jxnod - 1]

  sed -e "s/@NAME@/$name/g" -e "s/@METHOD@/$method/g" -e "s/XX/$g0/g" -e "s/YY/$gt/g" -e "s/qcexnodZZ/1/g" -e "s/ppn=1/ppn=2/g" template_lzMolcas > run_mol_${g0}_${gt}_random
  qsub run_mol_${g0}_${gt}_random
#echo $g0 $gt

  done
#fi
