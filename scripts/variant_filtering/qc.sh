#!/bin/bash

ldak=/cluster/project8/vyp/cian/support/ldak/ldak
Rbin=/cluster/project8/vyp/vincent/Software/R-3.1.2/bin/R
plink=/share/apps/genomics/plink-1.07-x86_64/plink
ldak=/cluster/project8/vyp/cian/support/ldak/ldak
#rootODir=/scratch2/vyp-scratch2/ciangene
rootODir=/scratch2/vyp-scratch2/cian/
release=February2015
rootODir=${1-$rootODir}
release=${2-$release}
bDir=${rootODir}/UCLex_${release}/

iData=$bDir"allChr_snpStats"
ln -s $bDir"UCLex_${release}.bim" $iData".bim"
ln -s $bDir"UCLex_${release}.fam" $iData".fam"
$ldak --make-bed $iData --sp $iData

data=$bDir"allChr_snpStats_out" 
$plink --noweb --allow-no-sex --bfile $data --freq --out $bDir/gstats
$plink --noweb --allow-no-sex --bfile $data --missing --out $bDir/gstats
$plink --noweb --allow-no-sex --bfile $data --hardy --out $bDir/gstats
 
oFile=$bDir/plot.qc.R
echo "dir<-'"$bDir"'" > $oFile
echo '
	miss <- read.table(paste0(dir,"gstats.lmiss"),header=T )
	frq <- read.table(paste0(dir,"gstats.frq"),header=T )

	pdf(paste0(dir, "/gstats.pdf") )
		par(mfrow=c(2,2))  
		plot(density(miss$F_MISS), xlab="Missingness", main = "UCLex_Missingness")		
		hist(frq$MAF, xlab="MAF", main = "UCLex_MAF", breaks=100, ylim=c(0,10000))
	dev.off() 

	' >> $oFile
$Rbin CMD BATCH --no-save --no-restore $oFile
