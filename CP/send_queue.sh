#!/bin/bash

#usage
#g0 - initial geom
#gt - final geom
#nod - qcexnodNOD

if [ $# != 3 ]
then
        echo "wrong usage"
        echo "./send_queue.sh {initial geom} {final geom} {node}"
else

##############################################################################
  # Variables to change:

  # Fixed variables:
  file="variables.inp"
  method=`grep "method=" generate_inps_molcas.sh | sed 's/method=//' | sed 's/^[[:space:]]*//'`
  #method="cas16in12_vtzp_32sa_7ms"         # method
  prefix=`grep "prefix=" ../$file | sed 's/prefix=//'`
  #prefix="lum_wat_aminabNaHopt"
  sufix="Wigner.5ps_MtSt"
  name="${prefix}.${sufix}"
##############################################################################

  # Input in command line
  g0="$1"    # initial geom
  gt="$2"    # initial geom
  nod="$3" # node to submit

  # Input in file
#  g0=45    # initial geom
#  gt=46  # final geom
#  nod=07 # node to submit

  sed -e "s/@NAME@/$name/g" -e "s/@METHOD@/$method/g" -e "s/XX/$g0/g" -e "s/YY/$gt/g" -e "s/dZZ/d$nod/g" template_lzMolcas > run_mol_${g0}_${gt}_NOD${nod}
  qsub run_mol_${g0}_${gt}_NOD${nod}
fi
