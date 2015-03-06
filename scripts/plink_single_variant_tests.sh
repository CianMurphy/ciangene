#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

R=/share/apps/R-3.1.0/bin/R
rootODir=$1
release=$2
#rootODir=/scratch2/vyp-scratch2/ciangene
rootODir=/scratch2/vyp-scratch2/cian
release=February2015
rootODir=${1-$rootODir}
release=${2-$release}
bDir=${rootODir}/UCLex_${release}/

Groups=$bDir"GroupNames"
nbGroups=$(wc -l  $Groups | awk '{print $1}') 
data=$bDir"allChr_snpStats_out"
Pheno=$bDir"Phenotypes"
covar=$bDir"TechPCs.vect"
phenos=$(wc -l  $Groups | awk '{print $1}') 

oDir=$bDir"Single_variant_tests/"
if [ ! -e $oDir ]; then mkdir $oDir; fi

cwd=$(pwd)

for pheno in $(seq 73  $nbGroups)
do
	batch=$(sed -n $pheno'p' $Groups)	
	oFile=$oDir"run_${batch}.sh"
	echo "
	plink --noweb  --bfile $data --assoc   --counts --allow-no-sex  --pheno $Pheno --adjust --mpheno $pheno --out $oDir$batch"_assoc"
	#plink --noweb  --bfile $data --fisher  --pfilter 1e-4 --allow-no-sex  --pheno $Pheno --adjust --mpheno $pheno --out $oDir$batch"_fisher"
	#plink --noweb  --bfile $data --logistic --pfilter 1e-4 --allow-no-sex --pheno $Pheno --adjust --mpheno $pheno --out $oDir$batch"_logistic_no_covars"	
	plink --noweb  --bfile $data --logistic  --hide-covar --allow-no-sex --pheno $Pheno --adjust --mpheno $pheno --covar $covar --covar-number 1-10 --out $oDir$batch"_logistic_tech_pcs_covars"
	" > $oFile
	cd $oDir; sh "run_${batch}.sh" ; cd $cwd
done






