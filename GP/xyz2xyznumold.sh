#!/bin/bash

# Use here the same label and order as in Mat Studio

for geom in `ls g*.xyz`
do
echo -e "18" > $geom.tmp
echo -e "" >> $geom.tmp
gawk 'NR == 3 {print "C1", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 4 {print "C2", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 5 {print "C3", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 6 {print "C4", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 7 {print "C5", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 8 {print "C6", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 9 {print "C7", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 10 {print "O1", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 11 {print "C8", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 12 {print "O2", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 13 {print "N1", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 14 {print "O3", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 15 {print "O4", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 21 {print "H1", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 22 {print "H2", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 23 {print "H3", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 24 {print "H4", $2, $3, $4}' $geom >> $geom.tmp
gawk 'NR == 25 {print "H5", $2, $3, $4}' $geom >> $geom.tmp
done
