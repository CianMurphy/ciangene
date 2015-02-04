#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

bDir='/cluster/project8/vyp/cian/data/UCLex/UCLex_October2014/Lambiase_case_control/support/'
Pheno='/cluster/project8/vyp/cian/data/UCLex/UCLex_October2014/All_phenotypes/All_phenotypes'

mkdir bin

for fil in {1..23}
do
	phenos=$(cat nb.groups)
	for phen in  $(seq 1 $phenos)
	do
		oFile=$(sed -n $phen'p' Groups)
		ivfOut=bin/UCLex_fisher_${oFile}_${fil}.R
		echo "fil <- $fil"  > $ivfOut
		echo "pheno  <- '$Pheno'" >> $ivfOut
		echo "phenoType  <- $phen" >> $ivfOut
		echo "oFile  <- '$oFile'" >> $ivfOut
		cat single_variant_fisher.R >> $ivfOut
		target=$(basename $ivfOut)
		cd bin; runR $target; cd ..
	done
done
