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
templateScript="/cluster/project8/vyp/cian/data/UCLex/ciangene/scripts/LDAK/LDAK.sh"
variants=$bDir"/Clean_variants_func_rare"
phenotype=$bDir"/Phenotypes"
kinship=/cluster/project8/vyp/cian/data/UCLex/ciangene/scripts/TK_maf_0.1_callRate_0.7
oFolder=$bDir"/LDAK_gene_tests_all_phenos_new/"
if [ ! -e $oFolder ]; then mkdir $oFolder; fi
cd $oFolder 


## Chosen Kinship 
##  Model 					MeanVarianceExplained   MAF 	CallRate	FILTER
##   TK_maf_0.1_callRate_0.7.progress            0.75121400

nbGroups=106
for pheno in $(seq 73 $nbGroups) 
do
	batch=$(sed -n $pheno'p' $Groups)
	for maf in {0.00001,0.001}
	do

		for missing in {0.00001,0.5,0.9}
		do

#			for kinship in $(find /cluster/project8/vyp/cian/data/UCLex/ciangene/scripts/ -name '*details' )
#			do 
				tmp=$(basename $kinship)
				kin=${tmp%.grm.details}
				kinName=${kinship%.grm.details}

				oFile=${batch}_${maf}_${missing}_${kin}.LDAK.sh
				target=$oFolder/$oFile
				echo "minMaf='$maf' ; "'minMaf=$(echo $minMaf/10|bc -l)'"; "'minMaf=$(echo $minMaf | sed 's/0*$//')'" " > $target	
				echo "missing='$missing' ; "'missing=$(echo $missing/10|bc -l)'"; "'missing=$(echo $missing | sed 's/0*$//')'"" >> $target	
				echo "phenotypes='$phenotype' ; mPheno=$pheno ; pheno='$batch'"  >> $target
				echo "extract='$variants' ; role='Func'" >> $target
				echo "kinship='$kinName' ; kin='$kin'" >> $target
				cat $templateScript >> $target
				$runSh $oFile
#			done
		done
	done
#sleep 2m
done
