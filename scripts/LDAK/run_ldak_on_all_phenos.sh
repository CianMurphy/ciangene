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
#rm -r $oFolder ; mkdir $oFolder

#for pheno in $(seq 1 $nbGroups) # skipping the first few random phenos
#for pheno in {73..90}
for pheno in {73..73}
do
	batch=$(sed -n $pheno'p' $Groups)
	target=$oFolder"/"$batch".LDAK.sh"
	
#	for maf in {1..5}
	for maf in {5..5}
	do

#		for missing in {1..10}
		for missing in {1..1}
		do

			echo "minMaf='$maf' ; "'minMaf=$(echo $minMaf/10|bc -l)'"; "'minMaf=$(echo $minMaf | sed 's/0*$//')'" " > $target	
			echo "missing='$missing' ; "'missing=$(echo $missing/10|bc -l)'"; "'missing=$(echo $missing | sed 's/0*$//')'"" >> $target	
			echo "phenotypes='$phenotype' ; mPheno=$pheno ; pheno='$batch'"  >> $target
			echo "extract='$variants' ; role='Func'" >> $target
			cat $templateScript >> $target
			cd $oFolder ; sh $batch".LDAK.sh" ; cd ..

			done
	done
done


