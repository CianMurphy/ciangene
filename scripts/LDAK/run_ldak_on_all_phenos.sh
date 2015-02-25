#/bin/sh

shopt -s expand_aliases
source ~/.bashrc

release=February2015

bDir=/scratch2/vyp-scratch2/cian/UCLex_${release}/
Groups=$bDir"GroupNames"
nbGroups=$(wc -l  $Groups | awk '{print $1}') 
templateScript="/cluster/project8/vyp/cian/data/UCLex/UCLex_August/Scripts/ciangene/scripts/LDAK/LDAK.sh"
variants=$bDir"Clean_variants_Func"
phenotype=$bDir"Phenotypes"

oFolder=$bDir"LDAK_gene_tests_all_phenos"
rm -r $oFolder ; mkdir $oFolder

for pheno in $(seq 73 $nbGroups) # skipping the first few random phenos
do
	batch=$(sed -n $pheno'p' $Groups)
	target=$oFolder"/"$batch".LDAK.sh"
	
	echo "phenotypes='$phenotype' ; mPheno='$pheno' ; pheno='$batch'"  > $target
	echo "extract='$variants' ; role='Func'" >> $target
	cat $templateScript >> $target
	cd $oFolder ; sh $batch".LDAK.sh" ; cd ..
done
