#!/bin/bash

diam=2
visc=0.01

for Re in $(seq 40 10 500)
do
velo=`echo $Re/$diam*$visc | bc`
echo $velo
cp -r template Re_$Re
cat template/U1 > Re_$Re/0/U
echo "        value           uniform ($velo 0 0);" >> Re_$Re/0/U
cat template/U2 >> Re_$Re/0/U

cd Re_$Re

./runcase.sh

rm -fr processor*

cd ..

done


