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
		awk '{ print $1, $1, $5}' $batch".indi.res" > $bDir".NewPhenotypeFiletmp"
	fi 
	if [ $pheno>1 ] 
	then
		paste -d' ' $bDir".NewPhenotypeFiletmp" <(awk '{print $NF}' $batch".indi.res")
	fi 

done

tail -n +2 $bDir".NewPhenotypeFile" > $bDir"NewPhenotypeFile"

echo '
	files <- list.files(pattern = "res")
	pdf("Residuals.pdf") 
	par(mfrow=c(2,2))  
	lapply(files, function(x)) 
	{
		name <- gsub(x, pattern = "\\.indi\\.res", replacement = "") 
		file <- read.table(x, header=T ) 
		with(file, plot(Phenotype, Residual), xlab = name)
	}
	dev.off() 
	' > plot.residuals.R
R CMD BATCH --no-save --no-restore plot.residuals.R

