#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

R=/share/apps/R-3.1.0/bin/R
runSh='sh /cluster/project8/vyp/cian/scripts/bash/runBashCluster.sh'
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
Pheno=$bDir"Phenotypes_fastlmm"
covar=$bDir"TechPCs.vect"
phenos=$(wc -l  $Groups | awk '{print $1}') 

oDir=$bDir"Single_variant_tests/"
if [ ! -e $oDir ]; then mkdir $oDir; fi

cwd=$(pwd)
for pheno in $(seq 79 $nbGroups)
do
	batch=$(sed -n $pheno'p' $Groups)	
	oFile=$oDir"/run_${batch}.sh"
	echo "
	plink --noweb  --bfile $data --assoc --counts --allow-no-sex  --pheno $Pheno --adjust --mpheno $pheno --out $oDir$batch"_counts_assoc"
	plink --noweb  --bfile $data --fisher --allow-no-sex  --pheno $Pheno --adjust --mpheno $pheno --out $oDir$batch"_fisher"
	plink --noweb  --bfile $data --logistic --allow-no-sex --pheno $Pheno --adjust --mpheno $pheno --out $oDir$batch"_logistic_no_covars"	
	plink --noweb  --bfile $data --logistic  --hide-covar --allow-no-sex --pheno $Pheno --adjust --mpheno $pheno --covar $covar --covar-number 1-2 --out $oDir$batch"_logistic_tech_pcs_covars"
	" > $oFile
	cd $oDir; $runSh "run_${batch}.sh" ; cd $cwd
done






