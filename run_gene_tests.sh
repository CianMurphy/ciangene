#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

ldak="/cluster/project8/vyp/cian/support/ldak/ldak.4.5"
data="/scratch2/vyp-scratch2/cian/UCLex_August2014/Genotype_Matrix"
genes="/SAN/biomed/biomed14/vyp-scratch/cian/LDAK/genesldak_ref.txt"
weights="/scratch2/vyp-scratch2/cian/UCLex_August2014/Genotype_weights/re-weightsALL" 

kinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/Depth_weights/kinshipALL"


phenotypes="/cluster/project8/vyp/cian/data/UCLex/UCLex_April2014c/mainset/UCLex_AprilC_All_phenotypes_for_fastLMM"
# pheno=14 # 21 is Syrris
maf=0.00001
missing=0.9

for pheno in `seq 1 23`;
	do   

out=$(sed -n "$pheno"'p' /cluster/project8/vyp/cian/data/UCLex/UCLex_April2014c/mainset/Groups)

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


oDir="perm_with_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/"
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



oDir="with_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/"
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


# $ldak --decompose output --grm $kinship 
# $ldak --reml ALevine --grm $kinship --pheno $phenotypes --mpheno 1 --eigen output


done



