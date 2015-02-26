#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc


release=February2015
bDir=/scratch2/vyp-scratch2/cian/UCLex_${release}/
Groups=$bDir"GroupNames"
nbGroups=$(wc -l  $Groups | awk '{print $1}') 
data=$bDir"allChr_snpStats_out"
Pheno=$bDir"Phenotypes"
covar=$bDir"TechPCs.vect"
phenos=$(wc -l  $Groups | awk '{print $1}') 

oDir=$bDir"Single_variant_tests/"
mkdir $oDir

cwd=$(pwd)

for pheno in $(seq 73  $nbGroups)
do
	batch=$(sed -n $pheno'p' $Groups)	
	oFile=$oDir"run_${batch}.sh"
	echo "
	plink --noweb  --bfile $data --fisher    --pheno $Pheno --adjust --mpheno $pheno --out $oDir$batch"_fisher"
	plink --noweb  --bfile $data --logistic  --pheno $Pheno --adjust --mpheno $pheno --out $oDir$batch"_logistic_no_covars"	
	plink --noweb  --bfile $data --logistic  --pheno $Pheno --adjust --mpheno $pheno --covar $covar --covar-number 1,2 --out $oDir$batch"_logistic_tech_pcs_covars"
	" > $oFile
	cd $oDir; runSh "run_${batch}.sh" ; cd $cwd
done

