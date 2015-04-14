#/bin/sh

#rootODir=/scratch2/vyp-scratch2/ciangene
rootODir=/scratch2/vyp-scratch2/cian/
release=February2015
rootODir=${1-$rootODir}
release=${2-$release}
bDir=${rootODir}/UCLex_${release}/

runSh='sh /cluster/project8/vyp/cian/scripts/bash/runBashCluster.sh'
Groups=$bDir"GroupNames"
nbGroups=$(wc -l  $Groups | awk '{print $1}') 
templateScript="/cluster/project8/vyp/cian/data/UCLex/UCLex_August/Scripts/ciangene/scripts/LDAK/LDAK_res.sh"
variants=$bDir"/Clean_variants_Func"

iPhenotype=$bDir"/NewPhenotypeFile"
phenotype=$bDir/phenotype_res

oFolder=$bDir"/LDAK_gene_tests_all_phenos_flt/"
if [ ! -e $oFolder ]; then mkdir $oFolder; fi

head -1 $iPhenotype  > $bDir/tmp
nbCols=$(wc $bDir/tmp | awk '{print $2}')
nbGroups=$(expr $nbCols - 2)

for pheno in $(seq 6 $nbGroups) 
#for pheno in {79,90,91,102} # skipping the first few random phenos
do
	tt=$(expr $pheno + 2)
	batch=$(awk "{print \$$tt}" $bDir/tmp)
	for maf in {0.0000001,0.001}
	do
		for missing in {0.000001,9}
		do
			oFile=LDAK_${batch}_${maf}_${missing}.res.sh
			target=$oFolder/$oFile
			echo "minMaf='$maf' ; "'minMaf=$(echo $minMaf/10|bc -l)'"; "'minMaf=$(echo $minMaf | sed 's/0*$//')'" " > $target	
			echo "missing='$missing' ; "'missing=$(echo $missing/10|bc -l)'"; "'missing=$(echo $missing | sed 's/0*$//')'"" >> $target	
			echo "phenotypes='$phenotype' ; mPheno=$pheno ; pheno='$batch'"  >> $target
			echo "extract='$variants' ; role='Func'" >> $target
			cat $templateScript >> $target
			cd $oFolder ; $runSh $oFile ; cd ..
			#sh $target
			done
	done
done

