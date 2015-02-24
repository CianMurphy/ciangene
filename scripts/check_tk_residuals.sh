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

oDir=$bDir"KinshipDecomposition/"
if [ ! -e $oDir ]; then mkdir $oDir; fi

for pheno in $(seq 1 $nbGroups)
do
	batch=$(sed -n $pheno'p' $Names); echo $batch
	$ldak --reml $oDir$batch --grm $kinship  --pheno $phenotypes --mpheno $pheno # --bfile $data
	
	if (( $pheno==1 ))  
	then
		awk '{ print $1, $1, $5}' $oDir$batch".indi.res" > $bDir".NewPhenotypeFiletmp"
	fi 
	if (( $pheno>1 )) 
	then
		cut -f5 $oDir$batch'.indi.res' | paste $bDir".NewPhenotypeFiletmp" - > $bDir".NewPhenotypeFiletmp"
	fi 

done

tail -n +2 $bDir".NewPhenotypeFile" > $bDir"NewPhenotypeFile"

oFile=plot.residuals.R
echo "dir<-$oDir$batch" > $oFile
echo '
	files <- list.files(dir, pattern = "res", full.names=T)
	pdf("Residuals.pdf") 
	par(mfrow=c(2,2))  
	lapply(files, function(x)) 
	{
		name <- gsub(x, pattern = "\\.indi\\.res", replacement = "") 
		file <- read.table(x, header=T ) 
		with(file, plot(Phenotype, Residual), xlab = name)
	}
	dev.off() 
	' >> $oFile
R CMD BATCH --no-save --no-restore $oFile



