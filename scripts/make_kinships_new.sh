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

missingNonMissing=$bDir"/Matrix.calls.Missing.NonMissing_out"
techOut=$bDir"/TechnKin"

extract=$bDir"Clean_variants_Func"
## Some basic parameters: 
minObs=0		## SNP needs to be present in 90% samples to be included. 
minMaf=0.000001			## SNP with MAF >= this are retained
maxMaf=0.5				## SNP with MAF <= this are retained
minVar=0.0000001			## SNP with variance >= this are retained? 
## maxTime=500			## Nb minutes calculation allowed run for. 
hwe=0.0001

#$ldak --make-bed $bDir"techMatrix_filtered" --bfile $missingNonMissing --extract $extract
$ldak --calc-kins-direct $techOut --bfile $missingNonMissing --ignore-weights YES --kinship-raw YES \
--minmaf $minMaf --maxmaf $maxMaf --minvar $minVar --minobs $minObs --extract $extract 
$ldak --pca $bDir"TechPCs" --grm $missingNonMissing --extract $extract


oFile=plot.techpca.R
echo "dir<-'"$bDir"'" > $oFile
echo '
	file <- read.table(paste0(dir, "TechPCs.vect"), header=F) 
	groups <- read.table(paste0(dir, "Sample.cohort"), header=F)
	uniq.groups <- unique(groups[,2])
	nb.groups <- length(uniq.groups)

	buffer <- 0.01
	xmin <- min(file[,3]) - buffer
	xmax <- max(file[,3]) + buffer
	ymin <- min(file[,4]) - buffer
	ymax <- max(file[,4]) + buffer

	pdf("TechPCA.pdf") 
#	for(i in 1:nb.groups)
	for(i in 72:nb.groups)
	{
		hit <- which(groups[,2] == uniq.groups[i])
		if(i==1)
		{
		plot(file[hit,3], file[hit,4], 
			xlab = "PC1", ylab = "PC2", 
			xlim=c(xmin, xmax), 
			ylim=c(ymin, ymax), 
			main = paste("TechPCA", date()) ,
			col=i
			) 
		} else
		{
			points(file[hit,3], file[hit,4], col=i)
		}
	}

	namess <- FALSE
	if(namess)
	{
	plot(NULL, xlim=c(0,3), ylim=c(0,nb.groups*2))
		for(i in 1:nb.groups)
	{
		x <- 2
		y <- i+1
		text(x, y, uniq.groups[i], col=i, cex=.7)
	}
	} 
	dev.off() 

	' >> $oFile
R CMD BATCH --no-save --no-restore $oFile







