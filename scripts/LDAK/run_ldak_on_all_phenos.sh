#/bin/sh

shopt -s expand_aliases
source ~/.bashrc

release=February2015

bDir=/scratch2/vyp-scratch2/cian/UCLex_${release}/
Groups=$bDir"GroupNames"
nbGroups=$(wc -l  $Groups | awk '{print $1}') 
templateScript="LDAK.sh"

oFolder=$bDir"LDAK_gene_tests_all_phenos"
rm -r $oFolder ; mkdir $oFolder

for pheno in $(seq 1 $nbGroups)
do
	batch=$(sed -n $pheno'p' $Groups)
	target=$oFolder"/"$batch".LDAK.sh"
	
	echo "phenotypes='/scratch2/vyp-scratch2/cian/UCLex_${release}/Phenotypes' ; mPheno='$pheno' ; pheno='$batch'"  > $target
	echo "extract='/cluster/project8/vyp/cian/data/UCLex/UCLex_${release}/All_phenotypes/LDAK/SNP.data.extract' ; role='Func'" >> $target
	cat $templateScript >> $target
	cd $oFolder ; sh $batch".LDAK.sh" ; cd ..
done
