#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

release=October2014

Variants=/cluster/project8/vyp/cian/data/UCLex/UCLex_${release}/Single_variant/Sanity_Check/test
outputFile=/cluster/project8/vyp/cian/data/UCLex/UCLex_${release}/Single_variant/Sanity_Check/test_out 

while read variant
do
	echo $variant
	chr=$(echo $variant | cut -f1 -d"_")
	ChrFile=/scratch2/vyp-scratch2/cian/UCLex_${release}/chr_${chr}_variants
	head -1 $ChrFile > $outputFile
	grep $variant $ChrFile >> $outputFile
done < $Variants
