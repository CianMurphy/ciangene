#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

ldak="/cluster/project8/vyp/cian/support/ldak/ldak.4.5"
data="/scratch2/vyp-scratch2/cian/UCLex_August2014/Genotype_Matrix"
genes="/SAN/biomed/biomed14/vyp-scratch/cian/LDAK/genesldak_ref.txt"
weights="/scratch2/vyp-scratch2/cian/UCLex_August2014/Genotype_weights/re-weightsALL" 

kinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/TechKin_weights/kinshipALL"  ; kin="Tech"
#kinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/Depth_weights/kinshipALL"   ; kin="Depth"


phenotypes="/scratch2/vyp-scratch2/cian/UCLex_August2014/All_phenotypes"
# pheno=14 # 21 is Syrris
maf=0.00001
missing=0.9

groups=$(wc -l /cluster/project8/vyp/cian/data/UCLex/UCLex_August/Scripts/Groups | awk '{print $1}' ) 

#for pheno in `seq 1 23`;
for pheno in `seq 1 $groups`;
	do   

out=$(sed -n "$pheno"'p' /cluster/project8/vyp/cian/data/UCLex/UCLex_August/Scripts/Groups)

oDir="perm_no_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/"
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar 0.00001 --minobs $missing --partition $partition --permute YES
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done



oDir="no_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/"
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar 0.00001 --minobs $missing --partition $partition 
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done


oDir=$kin"_perm_with_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/"
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar 0.00001 --minobs $missing --partition $partition --grm $kinship --permute YES
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done



oDir=$kin"_with_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/"
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar 0.00001 --minobs $missing --partition $partition --grm $kinship 
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done 

	## Repeat gene tests with other kinship matrix. 
	kinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/Depth_weights/kinshipALL"   ; kin="Depth"


	oDir=$kin"_perm_with_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/"
	rm -fr $oDir ; mkdir $oDir
	#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
	$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
	Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
	for partition in $(seq 1 $Partitions)
	do
	oFile='partition_'$partition'.sh'
	echo "
	$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar 0.00001 --minobs $missing --partition $partition --grm $kinship --permute YES
	" > $oDir$oFile
	cd $oDir ; runSh $oFile ; cd .. 
	done



	oDir=$kin"_with_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/"
	rm -fr $oDir ; mkdir $oDir
	#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
	$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
	Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
	for partition in $(seq 1 $Partitions)
	do
	oFile='partition_'$partition'.sh'
	echo "
	$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar 0.00001 --minobs $missing --partition $partition --grm $kinship 
	" > $oDir$oFile
	cd $oDir ; runSh $oFile ; cd .. 
	done 





done

#############################################################################################################
################### 				Gene tests with both kinships. 
############################################################################################################
aKinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/TechKin_weights/kinshipALL"
bKinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/Depth_weights/kinshipALL"


groups=$(wc -l /cluster/project8/vyp/cian/data/UCLex/UCLex_August/Scripts/Groups | awk '{print $1}' ) 

#for pheno in `seq 1 23`;
for pheno in `seq 1 $groups`;
	do   

out=$(sed -n "$pheno"'p' /cluster/project8/vyp/cian/data/UCLex/UCLex_August/Scripts/Groups)


kin="Both"
oDir=$kin"_with_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/"
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar 0.00001 --minobs $missing --partition $partition --mgrm "../"kinships
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done 

done

#############################################################################################################
################### 				How much variance does each kinship exxplain. 
############################################################################################################

echo "
ldak="/cluster/project8/vyp/cian/support/ldak/ldak.4.5"

aKinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/TechKin_weights/kinshipALL"
bKinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/Depth_weights/kinshipALL"

$ldak --decompose tech --grm $aKinship 		
$ldak --reml ALevine.tech --grm $kinship --pheno $phenotypes --mpheno 1 --eigen tech


$ldak --decompose depth --grm $bKinship 
$ldak --reml ALevine.depth --grm $kinship --pheno $phenotypes --mpheno 1 --eigen depth


" > decompose.kinships.sh
# runSh decompose.kinships.sh







