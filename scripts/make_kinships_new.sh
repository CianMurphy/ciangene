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


missingNonMissing=$bDir"/Matrix.calls.Missing.NonMissing"
techOut=$bDir"/Technical_Kinship"


## Some basic parameters: 
minObs=0.9 			## SNP needs to be present in 90% samples to be included. 
minMaf=0.000001			## SNP with MAF >= this are retained
maxMaf=0.5				## SNP with MAF <= this are retained
minVar=0.0000001			## SNP with variance >= this are retained? 
## maxTime=500			## Nb minutes calculation allowed run for. 
hwe=0.0001

$ldak --calc-kins-direct $bDir"TechKin" --bfile $missingNonMissing"_out" --ignore-weights YES \
--kinship-raw YES --minmaf $minMaf --maxmaf $maxMaf --minvar $minVar --minobs $minObs ## --extract 
$ldak --pca $bDir"TechPCs" --grm $bDir"TechKin"


oFile=plot.techpca.R
echo "dir<-'"$bDir"'" > $oFile
echo '
	file <- read.table(paste0(dir, "TechPCs.vect"), header=F) 
	pdf("TechPCA.pdf") 
		plot(file[,3], file[,4], xlab = "PC1", ylab = "PC2", main = paste("TechPCA", date()) ) 
	dev.off() 

	' >> $oFile
R CMD BATCH --no-save --no-restore $oFile




