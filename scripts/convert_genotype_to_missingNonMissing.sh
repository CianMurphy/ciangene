#!/bin/bash

ldak=/cluster/project8/vyp/cian/support/ldak/ldak

rootODir=$1
release=$2
#rootODir=/scratch2/vyp-scratch2/ciangene
rootODir=/scratch2/vyp-scratch2/cian
release=February2015
rootODir=${1-$rootODir}
release=${2-$release}

bDir=${rootODir}/UCLex_${release}/

## if [ ! -e ${bDir}/read_depth ]; then mkdir ${bDir}/read_depth; fi ## Not needed as I dont use read depth info right now and bim and fam are now made in first.step.R

## genotype to missing non missing
GenotypeMatrix=$bDir"/allChr_snpStats.sp" ## fixed file name. 
missingNonMissing=$bDir"/Matrix.calls.Missing.NonMissing.sp"

echo "Working with genotype matrix $GenotypeMatrix"

sed 's/0/2/g' $GenotypeMatrix | sed 's/1/2/g' | sed 's/NA/1/g' > $missingNonMissing

ln -s $bDir"UCLex_${release}.bim" $GenotypeMatrix".bim"
ln -s $bDir"UCLex_${release}.fam" $GenotypeMatrix".fam"

$ldak --make-bed $GenotypeMatrix --sp $GenotypeMatrix
$ldak --make-bed $missingNonMissing --sp $missingNonMissing


## Some basic parameters: 
## minObs=0.9 			## SNP needs to be present in 90% samples to be included. 
minMaf=0.000001			## SNP with MAF >= this are retained
maxMaf=0.1			## SNP with MAF <= this are retained
minVar=0.001			## SNP with variance >= this are retained? 
## maxTime=500			## Nb minutes calculation allowed run for. 
hwe=0.0001

$ldak --calc-kins-direct $bDir"TechKin" --bfile $missingNonMissing --ignore-weights YES --kinship-raw YES --minmaf $minMaf --maxmaf $maxMaf --minvar  $minVar --hwe $hwe

