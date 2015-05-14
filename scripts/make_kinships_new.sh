#!/bin/bash

ldak=/cluster/project8/vyp/cian/support/ldak/ldak
R=/share/apps/R-3.1.0/bin/R
#rootODir=/scratch2/vyp-scratch2/ciangene
rootODir=/scratch2/vyp-scratch2/cian/
release=February2015
rootODir=${1-$rootODir}
release=${2-$release}
bDir=${rootODir}/UCLex_${release}/

missingNonMissing=$bDir"/Matrix.calls.Missing.NonMissing_out"
techOut=$bDir"/TechKin"
extract=$bDir"Clean_variants"
## Some basic parameters: 
minObs=0		## SNP needs to be present in 90% samples to be included. 
minMaf=0.000001			## SNP with MAF >= this are retained
maxMaf=0.5				## SNP with MAF <= this are retained # for techKIN maf is missingness rate. 
minVar=0.0000001			## SNP with variance >= this are retained? 
## maxTime=500			## Nb minutes calculation allowed run for. 


######### Tech Kin
$ldak --calc-kins-direct $techOut --bfile $missingNonMissing --ignore-weights YES --kinship-raw YES \
 --minmaf $minMaf --maxmaf $maxMaf --minvar $minVar --minobs $minObs --extract $extract 
$ldak --pca $bDir"TechPCs" --grm $techOut --extract $extract


oFile=$bDir/plot.techpca.R
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

	pdf(paste0(dir, "/TechPCA.pdf") ) 
	for(i in 1:nb.groups)
#	for(i in 72:nb.groups)
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
	file <- read.table(paste0(dir,"TechPCs.values"), header=F)
	file$sd <- file[,1]^.5
	file$var <- file[,1]^2 / sum(file[,1]^2)
	plot(file$var*100, xlab = "Technical Principal Components" , ylab = "Proportion Variance Explained (%)", main = "Variance explained by each Principal Component") 
	dev.off() 

	' >> $oFile
$R CMD BATCH --no-save --no-restore $oFile



######### Pop Kin
missingNonMissing=$bDir"/allChr_snpStats_out"
techOut=$bDir"/PopKin"

$ldak --calc-kins-direct $techOut --bfile $missingNonMissing --ignore-weights YES --kinship-raw YES \
--minmaf $minMaf --maxmaf $maxMaf --minvar $minVar --minobs $minObs  --extract $extract 
$ldak --pca $bDir"popPCs" --grm $techOut  --extract $extract


oFile=$bDir/plot.popPca.R
echo "dir<-'"$bDir"'" > $oFile
echo '
	file <- read.table(paste0(dir, "popPCs.vect"), header=F) 
	groups <- read.table(paste0(dir, "Sample.cohort"), header=F)
	uniq.groups <- unique(groups[,2])
	nb.groups <- length(uniq.groups)

	buffer <- 0.01
	xmin <- min(file[,3]) - buffer
	xmax <- max(file[,3]) + buffer
	ymin <- min(file[,4]) - buffer
	ymax <- max(file[,4]) + buffer

	pdf(paste0(dir, "/popPCA.pdf") ) 
	for(i in 1:nb.groups)
#	for(i in 72:nb.groups)
	{
		hit <- which(groups[,2] == uniq.groups[i])
		if(i==1)
		{
		plot(file[hit,3], file[hit,4], 
			xlab = "PC1", ylab = "PC2", 
			xlim=c(xmin, xmax), 
			ylim=c(ymin, ymax), 
			main = paste("popPCA", date()) ,
			col=i
			) 
		} else
		{
			points(file[hit,3], file[hit,4], col=i)
		}
	}
	file <- read.table(paste0(dir,"popPCs.values"), header=F)
	# file$sd <- file[,1]^.5
	file$var <- file[,1]^2 / sum(file[,1]^2)
	plot(file$var*100, xlab = "Genotype Principal Components" , ylab = "Proportion Variance Explained (%)", main = "Variance explained by each Principal Component") 
	dev.off() 

	' >> $oFile
$R CMD BATCH --no-save --no-restore $oFile




