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
genes=/SAN/biomed/biomed14/vyp-scratch/cian/LDAK/genesldak_ref.txt
kinship=$bDir"TechKin"
data=$bDir"allChr_snpStats"
phenotypes=$bDir"Phenotypes"
groups=$bDir"cohort.summary"

Names=$bDir"GroupNames"
awk '{print $4}' $groups > tmp
tail -n +2 "tmp" > $Names
rm tmp
nbGroups=$(wc -l $groups | awk {'print $1}') 

oDir=$bdir"KinshipDecomposition"
if [ ! -e $oDir ]; then mkdir $obDir; fi

for pheno in $(seq 1 $nbGroups)
do
	batch=$(sed -n $pheno'p' $Names)
	$ldak --reml $batch --grm $kinship --bfile $data --pheno $phenotypes --mpheno $pheno
	
	if [ $pheno=1 ] 
	then
		awk '{ print $1, $1, $5}' $batch".indi.res" > $bDir"NewPhenotypeFile"
	fi 
	if [ $pheno>1 ] 
	then
		paste -d' ' $bDir"NewPhenotypeFile" <(awk '{print $NF}' $batch".indi.res")
	fi 

done


