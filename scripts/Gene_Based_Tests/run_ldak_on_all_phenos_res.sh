#/bin/sh

#rootODir=/scratch2/vyp-scratch2/ciangene
rootODir=/scratch2/vyp-scratch2/cian/
release=July2015
rootODir=${1-$rootODir}
release=${2-$release}
bDir=${rootODir}/UCLex_${release}/

runSh='sh /cluster/project8/vyp/cian/scripts/bash/runBashCluster.sh'
Groups=${bDir}cohort.list
nbGroups=$(wc -l  $Groups | awk '{print $1}') 
#templateScript="/cluster/project8/vyp/cian/data/UCLex/UCLex_August/Scripts/ciangene/scripts/LDAK/ldak_techres_DepthKin.sh"
templateScript=/cluster/project8/vyp/cian/data/UCLex/ciangene/scripts/LDAK/ldak_techres_DepthKin.sh
variants=${bDir}External_Control_data/

phenotype=/scratch2/vyp-scratch2/cian/UCLex_${release}/Clean_pheno_subset
oFolder=$bDir"/LDAK_gene_tests_all_phenos/"
if [ -e $oFolder ]; then rm -fr $oFolder ; fi ; mkdir $oFolder

for pheno in $(seq 1 16) 
#for pheno in {79,90,91,102} # skipping the first few random phenos
do
	#tt=$(expr $pheno + 2)
	#batch=$(awk "{print \$$tt}" $bDir/tmp)
	batch=$(sed $pheno'q;d' $Groups)
	for maf in {0.0000001,0.001}
	do
		for missing in {0.000001,9}
		do
			oFile=LDAK_${batch}_${maf}_${missing}.sh
			target=$oFolder/$oFile
			echo "minMaf='$maf' ; "'minMaf=$(echo $minMaf/10|bc -l)'"; "'minMaf=$(echo $minMaf | sed 's/0*$//')'" " > $target	
			echo "missing='$missing' ; "'missing=$(echo $missing/10|bc -l)'"; "'missing=$(echo $missing | sed 's/0*$//')'"" >> $target	
			echo "phenotypes='$phenotype' ; mPheno=$pheno ; pheno='$batch'"  >> $target
			echo "extract=${variants}${batch}_rare_func_variants ; role='Func'" >> $target
			cat $templateScript >> $target
			cd $oFolder ; $runSh $oFile ; cd ..
			#sh $target
			done
	done
done

