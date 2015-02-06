#/bin/sh

shopt -s expand_aliases
source ~/.bashrc

release=October2014

nbGroups=$(tail -1 nb.groups | awk '{print $1}') 
echo $nbGroups "phenotypes for LDAK to chew on"

templateScript="LDAK.sh"

oFolder="./LDAK_gene_tests_all_phenos"
rm -r $oFolder ; mkdir $oFolder

for pheno in $(seq 1 $nbGroups)
do
	batch=$(sed -n $pheno'p' Groups)
	target=$oFolder"/"$batch".LDAK.sh"
	
	echo "phenotypes='/cluster/project8/vyp/cian/data/UCLex/UCLex_${release}/All_phenotypes/All_phenotypes' ; mPheno='$pheno' ; pheno='$batch'"  > $target
	echo "extract='/cluster/project8/vyp/cian/data/UCLex/UCLex_${release}/All_phenotypes/LDAK/SNP.data.extract' ; role='Func'" >> $target
	cat $templateScript >> $target
	cd $oFolder ; sh $batch".LDAK.sh" ; cd ..
done
