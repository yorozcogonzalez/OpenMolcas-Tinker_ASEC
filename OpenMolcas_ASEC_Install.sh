#!/bin/bash

#
#  Before running this script be sure cmaker is working
#

cont="b"
while [[ $cont != "y" && $cont != "n" ]]; do
   echo ""
   echo " OpenMolcas-Tinker will be downloaded and installed here:"
   echo "$PWD"
   echo ""
   echo "Is it ok? (y/n)"
   read cont
done

module load Compilers/cmake3.9.2

if [[ $cont == "n" ]]; then
   exit 0
fi
if [[ -d "OpenMolcas" ]]; then
   echo "OpenMolcas folder exists"
   exit 0
fi
if [[ -d "build" ]]; then
   echo "build folder exists"
   exit 0
fi
git clone https://gitlab.com/Molcas/OpenMolcas.git
cd OpenMolcas
git submodule update --init External/lapack
sed -i "s/      nMax=100/      nMax=10000/" src/slapaf_util/box.f
sed -i "/Logical IfOpened/a\ \ \ \ \ \ Logical Do_ESPF" src/rasscf/rasscf.f
sed -i "/ but consider extending it to other cases/a\ \ \ \ \ \ call DecideOnESPF(Do_ESPF)" src/rasscf/rasscf.f
sed -i "/call DecideOnESPF(Do_ESPF)/a\ \ \ \ \ \ !write(LF,*) ' |rasscf> DecideOnESPF == ',Do_ESPF" src/rasscf/rasscf.f
sed -i "s/.or.domcpdftDMRG))THEN/.or.domcpdftDMRG.or.Do_ESPF))THEN/" src/rasscf/rasscf.f
cd ..
mkdir build
cd build
cmake ../OpenMolcas
make

cp ../get_tinker_Openmolcas sbin/get_tinker
cp ../OpenMolcas/Tools/patch2tinker/patch_tinker-6.3.3.diff sbin
pymolcas get_tinker

