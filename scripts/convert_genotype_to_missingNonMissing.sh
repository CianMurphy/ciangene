#!/bin/bash

ldak=/cluster/project8/vyp/cian/support/ldak/ldak
#rootODir=/scratch2/vyp-scratch2/ciangene
rootODir=/scratch2/vyp-scratch2/cian/
release=February2015
rootODir=${1-$rootODir}
release=${2-$release}
plink=/share/apps/genomics/plink-1.07-x86_64/plink
bDir=${rootODir}/UCLex_${release}/

## if [ ! -e ${bDir}/read_depth ]; then mkdir ${bDir}/read_depth; fi ## Not needed as I dont use read depth info right now and bim and fam are now made in first.step.R

## genotype to missing non missing
GenotypeMatrix=$bDir"allChr_snpStats"  
missingNonMissing=$bDir"Matrix.calls.Missing.NonMissing"
phenFile=$bDir"Phenotypes" 
echo "Working with genotype matrix $GenotypeMatrix"

#sed 's/0/2/g' $GenotypeMatrix".sp" | sed 's/1/2/g' | sed 's/NA/1/g' > $missingNonMissing".sp"
#rm $missingNonMissing".bim"; ln -s $bDir"UCLex_${release}.bim" $missingNonMissing".bim"
#rm $missingNonMissing".fam"; ln -s $bDir"UCLex_${release}.fam" $missingNonMissing".fam"
#$ldak --make-bed $missingNonMissing --sp $missingNonMissing

runSh='sh /cluster/project8/vyp/cian/scripts/bash/runBashCluster.sh'
Names=$bDir"GroupNames"
nbGroups=$(wc -l $Names | awk {'print $1}') 

oDir=$bDir"CaseControlMissingness/"
if [ ! -e $oDir ]; then mkdir $oDir; fi

for pheno in $(seq 72 $nbGroups)
do
	batch=$(sed -n $pheno'p' $Names) # ; echo $batch
	oFile=$oDir"missing_"$batch.sh
	echo "
	for chr in {1..23}
	do
	$plink --noweb --allow-no-sex --bfile $bDir"allChr_snpStats_out" --test-missing --missing --chr "'$chr'" \
	--out $oDir/$batch"_missing_""'$chr'" --pheno $phenFile"_fastlmm" --mpheno $pheno --pfilter 1e-3
	done
	" > $oFile
	$runSh $oFile
done




