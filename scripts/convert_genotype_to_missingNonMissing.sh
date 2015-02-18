#!/bin/bash

ldak=/cluster/project8/vyp/cian/support/ldak/ldak

rootODir=/scratch2/vyp-scratch2/ciangene
release=February2015

rootODir=$1
release=$2

bDir=${rootODir}/UCLex_${release}

if [ ! -e ${bDir}/read_depth ]; then mkdir ${bDir}/read_depth; fi



## genotype to missing non missing
GenotypeMatrix=$bDir"/allChr_snpStats"
tmp=$bDir"tmp"
missingNonMissing=$bDir"/Matrix.calls.Missing.NonMissing.sp"

echo "Working with genotype matrix $GenotypeMatrix"

sed 's/0/2/g' $GenotypeMatrix | sed 's/1/2/g' | sed 's/NA/1/g' > $missingNonMissing
#sed 's/1/2/g' $tmp > $tmp"2" ; rm $tmp
#sed 's/NA/1/g' $tmp"2" > $missingNonMissing ; rm $tmp"2"

#ln -s $bDir"/read_depth/Depth_Matrix.bim" $GenotypeMatrix".bim"
#ln -s $bDir"/read_depth/Depth_Matrix.fam" $GenotypeMatrix".fam"

$ldak --make-bed $GenotypeMatrix --sp $GenotypeMatrix

