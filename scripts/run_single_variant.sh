#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

bDir='/cluster/project8/vyp/cian/data/UCLex/UCLex_October2014/Lambiase_case_control/support/'
ivfPheno=$bDir'IVF.pheno'
sadPheno=$bDir'Lambiase_vs_UCLex_phenotype_file'

mkdir bin

for fil in {1..23}
do

ivfOut=ivf_fisher_${fil}.R
echo "fil <- $fil"  > $ivfOut
echo "pheno  <- '$ivfPheno'" >> $ivfOut
cat single_variant_fisher.R >> $ivfOut
runR $ivfOut

sadOut=Lambiase_vs_UCL_fisher_${fil}.R
echo "fil <- $fil"  > $sadOut
echo "pheno  <- '$sadPheno'" >> $sadOut
cat single_variant_fisher.R >> $sadOut
runR $sadOut

done
