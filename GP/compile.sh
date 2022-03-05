#!/bin/bash

#-----
# Compilation of required fortran programs
# prepared for the semi-classical modelling
# of UV-Vis spectrum
#---
#-----
# Requirements:
# gfortran, lapack
#---
echo "Compiling semiclassical.f90 ..."
gfortran -o semiclassical.x semiclassical.f90
echo "semiclassical.x  <---- complete!"
echo "--"
echo "Compiling os2spec.f90 ..."
gfortran -o os2spec.x os2spec.f90
echo "semiclassical.x  <---- complete!"
echo "--"
echo "Compiling convert_nx_xyz.f90 ..."
gfortran -o convert_nx_xyz.x convert_nx_xyz.f90
echo "convert_nx_xyz.x  <---- complete!"
echo "--"
